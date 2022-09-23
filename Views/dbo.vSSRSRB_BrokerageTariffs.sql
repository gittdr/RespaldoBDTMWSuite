SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



--select top 100 * from vSSRSRB_BrokerageTariffs

CREATE   View [dbo].[vSSRSRB_BrokerageTariffs]

As

/**
 *
 * NAME:
 * dbo.vSSRSRB_BrokerageTariffs
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 **/

select		
		trk_number as [Tariff Key Number], 
		tar_number as [Tariff Number], 
		Rate = (select top 1 tar_rate from tariffheaderstl where tar_number = TempTariff.tar_number),
		trk_carrier as [Carrier ID], 
		[Total]= (select top 1 crh_Total from carrierhistory where Crh_Carrier = TempTariff.trk_carrier),
		[On Time] = (select top 1 crh_OnTime from carrierhistory where Crh_Carrier = TempTariff.trk_carrier),
		[Charge Type] = (select top 1 cht_itemcode from tariffheaderstl where tar_number = TempTariff.tar_number),
		[Pay Type] = (select top 1 pyt_description from paytype where cht_itemcode = (select cht_itemcode from tariffheaderstl where tar_number = TempTariff.tar_number)),
		[Carrier Percent] = (select min(Crh_percent) from carrierhistory where Crh_Carrier = TempTariff.trk_carrier),
		[Carrier Average Fuel] = (select min(Crh_AveFuel) from carrierhistory where Crh_Carrier = TempTariff.trk_carrier),
		[Carrier Average Total] = (select min(Crh_AveTotal) from carrierhistory where Crh_Carrier = TempTariff.trk_carrier),
		[Average Accessorial] = (select min(Crh_AveAcc) from carrierhistory where Crh_Carrier = TempTariff.trk_carrier),
		[Carrier Name] = (select car_name from carrier where car_id = TempTariff.trk_carrier),
		[Carrier Address1] =(select car_address1 from carrier where car_id = TempTariff.trk_carrier),
		[Carrier Address2] =(select car_address2 from carrier where car_id = TempTariff.trk_carrier),
		[Carrier Scac] =(select car_scac from carrier where car_id = TempTariff.trk_carrier),
		[Carrier Phone1] =(select car_Phone1 from carrier where car_id = TempTariff.trk_carrier),
		[Carrier Phone2] =(select car_Phone2 from carrier where car_id = TempTariff.trk_carrier),
		[Carrier Contact] =(select car_contact from carrier where car_id = TempTariff.trk_carrier),
		[Carrier Phone] =(select car_phone3 from carrier where car_id = TempTariff.trk_carrier),
		[Carrier Email] =(select car_email from carrier where car_id = TempTariff.trk_carrier),
		[Carrier Currency] =(select car_currency from carrier where car_id = TempTariff.trk_carrier), -- MRH 11/13/03
		[Currency Unit] = cht_currunit,
        [Carrier City]=(select cty_name from city WITH (NOLOCK),carrier WITH (NOLOCK) where trk_carrier=car_id and city.cty_code = carrier.cty_code),
		[Carrier State]=(select cty_state from city WITH (NOLOCK),carrier WITH (NOLOCK) where trk_carrier=car_id and city.cty_code = carrier.cty_code),
		[Carrier Zip]=(select cty_zip from city WITH (NOLOCK),carrier WITH (NOLOCK) where trk_carrier=car_id and city.cty_code = carrier.cty_code)

	from (

select t.trk_number,
		t.tar_number,   
		t.trk_billto,
		t.trk_orderedby,
		t.cmp_othertype1,
		t.cmp_othertype2,
		t.cmd_code,
		t.cmd_class,
		t.trl_type1,
		t.trl_type2,
		t.trl_type3,
		t.trl_type4,
		t.trk_revtype1,
		t.trk_revtype2,
		t.trk_revtype3,
		t.trk_revtype4,
		t.trk_originpoint,
		t.trk_origincity,
		t.trk_originzip,
		t.trk_origincounty,
		t.trk_originstate,
		t.trk_destpoint,
		t.trk_destcity,
		t.trk_destzip,
		t.trk_destcounty,
		t.trk_deststate,
		t.trk_duplicateseq,
		t.trk_company,
		t.trk_carrier,
		t.trk_lghtype1,
		t.trk_load,
		t.trk_team,
		t.trk_boardcarrier,
		t.trk_minmiles,
		t.trk_maxmiles,
		t.trk_distunit,
		t.trk_minweight,
		t.trk_maxweight,
		t.trk_wgtunit,
		t.trk_minpieces,
 		t.trk_maxpieces,
		t.trk_countunit,
		t.trk_minvolume,
		t.trk_maxvolume,
		t.trk_volunit,
		t.trk_minodmiles,
		t.trk_maxodmiles,
		t.trk_odunit,
		t.mpp_type1,
		t.mpp_type2,
		t.mpp_type3,
		t.mpp_type4,
		t.trc_type1,
		t.trc_type2,
		t.trc_type3,
		t.trc_type4,
		t.cht_itemcode,
        t.trk_stoptype, 
        t.trk_delays, 
        t.trk_carryins1, 
        t.trk_carryins2, 
        t.trk_ooamileage, 
        t.trk_ooastop ,
		t.trk_minmaxmiletype,
		t.trk_terms,
		t.trk_triptype_or_region,
		t.trk_tt_or_oregion,
		t.trk_dregion,
		t.cmp_mastercompany,
		t.trk_minrevpermile,
		t.trk_maxrevpermile,
		(select min(cht_currunit) from tariffheader where tariffheader.tar_number = t.tar_number) cht_currunit,
		t.trk_primary
    FROM tariffkey t
   	
) as TempTariff
where trk_carrier <> 'UNKNOWN'

Union

	select
	0 as trk_number,
	0 as tar_number,
	0 as Rate,
	(select Crh_Carrier from CarrierHistory where Crh_Carrier = CH.Crh_Carrier),
	(select Crh_Total from CarrierHistory where Crh_Carrier = CH.Crh_Carrier),
	(select Crh_OnTime from CarrierHistory where Crh_Carrier = CH.Crh_Carrier),
	'',
	'',
	(select Crh_Percent from CarrierHistory where Crh_Carrier = CH.Crh_Carrier),
	(select Crh_AveFuel from CarrierHistory where Crh_Carrier = CH.Crh_Carrier),
	(select Crh_AveTotal from CarrierHistory where Crh_Carrier = CH.Crh_Carrier),
	(select Crh_AveAcc from CarrierHistory where Crh_Carrier = CH.Crh_Carrier), 
	(select car_name from carrier where car_id = CH.Crh_Carrier),
	(select car_address1 from carrier where car_id = CH.Crh_Carrier),
	(select car_address2 from carrier where car_id = CH.Crh_Carrier),
	(select car_scac from carrier where car_id = CH.Crh_Carrier),
	(select car_Phone1 from carrier where car_id = CH.Crh_Carrier),
	(select car_Phone2 from carrier where car_id = CH.Crh_Carrier),
	(select car_contact from carrier where car_id = CH.Crh_Carrier),
	(select car_phone3 from carrier where car_id = CH.Crh_Carrier), 
	(select car_email from carrier where car_id = CH.Crh_Carrier),
	(select car_currency from carrier where car_id = CH.Crh_Carrier),
	'' as [Currency Unit],
	[Carrier City]=(select cty_name from city WITH (NOLOCK),carrier WITH (NOLOCK) where CH.Crh_Carrier=car_id and city.cty_code = carrier.cty_code),
	[Carrier State]=(select cty_state from city WITH (NOLOCK),carrier WITH (NOLOCK) where CH.Crh_Carrier=car_id and city.cty_code = carrier.cty_code),
	[Carrier Zip]=(select cty_zip from city WITH (NOLOCK),carrier WITH (NOLOCK) where CH.Crh_Carrier=car_id and city.cty_code = carrier.cty_code)
	From CarrierHistory CH WITH (NOLOCK) 

GO
GRANT DELETE ON  [dbo].[vSSRSRB_BrokerageTariffs] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_BrokerageTariffs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_BrokerageTariffs] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_BrokerageTariffs] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_BrokerageTariffs] TO [public]
GO
