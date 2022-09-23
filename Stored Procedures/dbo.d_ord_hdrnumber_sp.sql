SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
  MODIFICATION LOG
MRH 30082 ord_no_recalc_miles
DPETE 16265 Add fix settlements to Vis Disp order window
DPETE 17751 Add ord_mileage_adj_pct to return set
DPETE 19362 Add ord_unlockkey to return set, add inv_Protect so it can be protected on a row by row basis for this PTS only
DPETE 23979-22082 add ord_trlconfiguration
JTEUB 29403 Add the edi_orderstate flags matching the ord_edistate field.
LOR	PTS# 28333	add ord_mileagetable, ord_rate_mileagetable
DJM PTS 27430	Added the Billto Expiration fields to display warnings in interface.
PRB PTS34244	Added active fields for companies for blocking copying orders when cmp is inactive.
vjh pts36728	add ord_manualeventcallminutes and ord_manualcheckcallminutes
EMK PTS 37029 	Add ord_toll_cost
DPETE 41679 change default on ord_manualevent... to -1
TGRIFFIT 38846  Added 4 'GVW' fields.
DPETE 40260 recode Pauls
         recode DPETE 23776 Add ord_nomincharges
         recodeDPETE PTS30355 add bill to alt address key car_key
         recode DPETE 30082 (30583)
LOR	PTS# 42471	add split pay for agent
06/04/2009 MDH PTS 47550: Added ord_railrampdest, ord_railramporig
DCameron PTS 43237 - Added two 'dispatch' fields.
DCameron PTS 43239 - added one new field.
DJM - PTS 48277 - Added ord_broker_percent field.
PMILL PTS 48227 - Added ord_target_margin field
MTC PTS 57693 07/07/2011 Added nolocks on selects to reduce deadlocks when very a high volume DB
*/

create proc [dbo].[d_ord_hdrnumber_sp] @mov_number int 
as

SELECT	orderheader.ord_company 
	, orderheader.ord_number
	, orderheader.ord_customer 
	, orderheader.ord_bookdate 
	, orderheader.ord_bookedby 
	, orderheader.ord_status 
	, orderheader.ord_originpoint 
	, orderheader.ord_destpoint 
	, orderheader.ord_invoicestatus 
	, orderheader.ord_origincity 
	, orderheader.ord_destcity 
	, orderheader.ord_originstate 
	, orderheader.ord_deststate 
	, orderheader.ord_originregion1 
	, orderheader.ord_destregion1 
	, orderheader.ord_supplier 
	, orderheader.ord_billto 
	, orderheader.ord_startdate 
	, orderheader.ord_completiondate 
	, orderheader.ord_revtype1 
	, orderheader.ord_revtype2 
	, orderheader.ord_revtype3 
	, orderheader.ord_revtype4 
	, orderheader.ord_totalweight 
	, orderheader.ord_totalpieces 
	, orderheader.ord_totalmiles 
	, orderheader.ord_totalcharge 
	, orderheader.ord_currency 
	, orderheader.ord_currencydate 
	, orderheader.ord_totalvolume 
	, orderheader.ord_hdrnumber 
	, orderheader.ord_refnum 
	, orderheader.ord_invoicewhole 
	, orderheader.ord_remark 
	, orderheader.ord_shipper 
	, orderheader.ord_consignee 
	, orderheader.ord_pu_at 
	, orderheader.ord_dr_at 
	, orderheader.ord_originregion2 
	, orderheader.ord_originregion3 
	, orderheader.ord_originregion4 
	, orderheader.ord_destregion2 
	, orderheader.ord_destregion3 
	, orderheader.ord_destregion4 
	, orderheader.mfh_hdrnumber 
	, orderheader.ord_priority 
	, orderheader.mov_number 
	, orderheader.tar_tarriffnumber 
	, orderheader.tar_number 
	, orderheader.tar_tariffitem 
	, orderheader.ord_contact 
	, orderheader.ord_showshipper 
	, orderheader.ord_showcons 
	, orderheader.ord_subcompany 
	, orderheader.ord_lowtemp 
	, orderheader.ord_hitemp 
	, orderheader.ord_quantity 
	, orderheader.ord_rate 
	, orderheader.ord_charge 
	, orderheader.ord_rateunit 
	, orderheader.ord_unit 
	, orderheader.trl_type1 
	, orderheader.ord_driver1 
	, orderheader.ord_driver2 
	, orderheader.ord_tractor 
	, orderheader.ord_trailer 
	, orderheader.ord_length 
	, orderheader.ord_width 
	, orderheader.ord_height 
	, orderheader.ord_lengthunit
	, orderheader.ord_heightunit
	, orderheader.ord_widthunit
	, orderheader.ord_reftype
	, orderheader.cmd_code
	, orderheader.ord_description
	, orderheader.ord_terms
	, orderheader.cht_itemcode
	, orderheader.ord_origin_earliestdate
	, orderheader.ord_origin_latestdate
	, orderheader.ord_odmetermiles
	, orderheader.ord_stopcount
	, orderheader.ord_dest_earliestdate
	, orderheader.ord_dest_latestdate
	, orderheader.ref_sid
	, orderheader.ref_pickup
	, orderheader.ord_cmdvalue
	, orderheader.ord_accessorial_chrg
	, orderheader.ord_availabledate
	, orderheader.ord_miscqty
	, orderheader.ord_tempunits
	, orderheader.ord_datetaken
	, orderheader.ord_totalweightunits
	, orderheader.ord_totalvolumeunits
	, orderheader.ord_totalcountunits
	, orderheader.ord_loadtime
	, orderheader.ord_unloadtime
	, orderheader.ord_drivetime
	, orderheader.ord_rateby
	, orderheader.ord_thirdpartytype1
	, orderheader.ord_thirdpartytype2
	, 'RevType1' revtype1
	, 'RevType2' revtype2
	, 'RevType3' revtype3
	, 'RevType4' revtype4
	, 'TrlType1' ctrltype1
	, orderheader.ord_quantity_type
	, orderheader.ord_charge_type
	, orderheader.ord_fromorder
	, 'OrdMscQty1' ord_miscqty_t
	, 'TprType1' ord_thirdpartytype1_t
	, 'TprType2' ord_thirdpartytype2_t
	, orderheader.ord_mintemp
	, orderheader.ord_maxtemp
	, orderheader.ord_cod_amount     
	, orderheader.opt_trc_type4
	, orderheader.opt_trl_type4
	, 'TrcType4' opt_trc_type4_t
	, 'TrlType4' opt_trl_type4_t
	, orderheader.appt_contact
	, orderheader.appt_init
        , ord_ratingquantity
        , ord_ratingunit
        , cmp1.cmp_name ord_company_name
        , cmp2.cmp_name ord_billto_name,
	ord_trl_type2,
	ord_trl_type3,
	ord_trl_type4,
	'TrlType2' ctrltype2,
	'TrlType3' ctrltype3,
	'TrlType4' ctrltype4,
	ord_rate_type,
	ord_extrainfo1,
	ord_extrainfo2,
	ord_extrainfo3,
	ord_extrainfo4,
	ord_extrainfo5,
	ord_extrainfo6,
	ord_extrainfo7,
	ord_extrainfo8,
	ord_extrainfo9,
	ord_extrainfo10,
	ord_extrainfo11,
	ord_extrainfo12,
	ord_extrainfo13,
	ord_extrainfo14,
	ord_extrainfo15,
	ord_hideshipperaddr,
	ord_hideconsignaddr,
	ord_revenue_pay_fix,
	ord_revenue_pay,
-- use all this case stuff until the new fields have been in use a while (9/5/2)
	ord_stlquantity = Case
		When Isnull(ord_stlquantity,0) <> 0 or IsNull(ord_stlquantity_type,0) = 1 then ord_stlquantity
	   When ord_quantity_type = 2 Then ord_quantity
		Else Isnull(ord_stlquantity,0) 
		End,
	ord_stlunit = Case
		When Isnull(ord_stlquantity,0) <> 0 or IsNull(ord_stlquantity_type,0) = 1 then IsNull(ord_stlunit,'UNK')
		When ord_quantity_type = 2 Then ord_unit
		Else Isnull(ord_stlunit,'MIL')
		End,
	ord_stlquantity_type = Case
		When IsNull(ord_stlquantity_type,0) <> 0 Then ord_stlquantity_type
		When ord_quantity_type = 2 Then 1
		Else 0
		End,
	ord_customs_document,
	ord_totalloadingmeters,
	ord_totalloadingmetersunit,
	ord_noautosplit, 
	ord_noautotransfer,
	ord_tareweight,
	ord_entryport,
	ord_exitport,
	IsNull(ord_mileage_adj_pct,0) ord_mileage_adj_pct,
	IsNull(ord_commodities_weight, 0) ord_commodities_weight,
	isnull(ord_intermodal,'N') ord_intermodal,
	isnull((select cty_nmstct from city with (nolock) where cty_code = ord_origincity),'UNKNOWN') origincity,	-- PTS 21227 - DJM
	isNull((select cty_nmstct from city with (nolock)  where cty_code = ord_destcity),'UNKNOWN') destcity,		-- PTS 21227 - DJM
	0.0000 work_qty,				-- PTS 21227 - DJM
	'UNK   ' work_unit,				-- PTS 21227 - DJM
	ord_booked_revtype1,				-- PTS 21227 - DJM
	ord_dimfactor, 
	orderheader.external_type, 
	orderheader.external_id, 
--      ord_UnlockKey, 
    inv_protect = 0, 
    ord_UnlockKey, 
    ord_trlconfiguration = ISNULL(ord_trlconfiguration,'UNK'), 
    ord_trlconfiguration_t = 'EquipmConfiguration', 
    ISNULL(ord_charge_type_lh, 0) ord_charge_type_lh, 
    ISNULL(ord_raildest, 'UNKNOWN') ord_raildest, 
    ISNULL(ord_railpoolid, 'UNKNOWN') ord_railpoolid, 
    ISNULL(ord_trailer2, 'UNKNOWN') ord_trailer2, 
    ISNULL(ord_route, 'UNKNOWN') ord_route, 
    ord_route_effc_date, 
    ord_route_exp_date, 
    ord_odmetermiles_mtid = ISNULL(orderheader.ord_odmetermiles_mtid,0), 
	--JET - 2/18/08 - PTS 41018, the label should come from the gi_string2 field for the TrackBranch row.
    (select ISNULL(gi_string2, 'Branch') from generalinfo  with (nolock) where gi_name = 'TrackBranch') ord_booked_revtype1_t, 
    ISNULL(esc_tmwordersuspense, 'N') esc_tmwordersuspense, 
    ISNULL(esc_orderplanningallowed, 'Y') esc_orderplanningallowed, 
    ISNULL(esc_orderdispatchallowed, 'Y') esc_orderdispatchallowed, 
    ISNULL(esc_useractionrequired, 'N') esc_useractionrequired,
	ord_mileagetable,
	ord_rate_mileagetable,
	ISNULL(orderheader.ord_no_recalc_miles, 'N') ord_no_recalc_miles,
	0 billto_pri1_now,
	0 billto_pri1_soon,
	0 billto_pri2_now,
	0 billto_pri2_soon,
	orderheader.ord_carrier,
-- PTS 30326 -- BL (start)
	orderheader.ord_origin_zip,
	orderheader.ord_dest_zip,
-- PTS 30326 -- BL (end)
-- PTS34244 PB - Add company's active and cmpid.
	ordby_comp_active = cmp1.cmp_active,  
	origin_comp_active = orig.cmp_active,  
	dest_comp_active = dest.cmp_active,  
	billto_active = cmp2.cmp_active,
-- END PTS34244
	isnull(ord_manualeventcallminutes, -1) ord_manualeventcallminutes, --41679 isnull(ord_manualeventcallminutes, 0) ord_manualeventcallminutes,  pts35708
	isnull(ord_manualcheckcallminutes, 0) ord_manualcheckcallminutes,	--pts35708
	ord_toll_cost, --PTS 37029 EMK
    ord_gvw_unit,           --PTS 38846 TGRIFFIT
    ord_gvw_amt,            --PTS 38846 TGRIFFIT
    ord_gvw_adjstd_unit,    --PTS 38846 TGRIFFIT
    ord_gvw_adjstd_amt      --PTS 38846 TGRIFFIT
    ,ord_nomincharges = IsNull(ord_nomincharges ,'N')   -- 40260
    ,multiaddrcount = (Select count(*) from companyaddress  with (nolock) where cmp_id = ord_billto)  --40260
    ,isnull(car_key,0),   --40260
	ord_thirdparty_split,
	 ord_thirdparty_split_percent, 
	 ord_thirdpartytype3,
	 ord_railramporig, 
	 ord_railrampdest
    ,ord_cyclic_dsp_enabled     --PTS 43237 DCameron
    ,ord_preassign_ack_required --PTS 43237 DCameron
    ,ord_anc_number,            --PTS 43239 DCameron
	orderheader.ord_carrierchangecode,
	ISNULL(orderheader.GST_REQ, 'S') GST_REQ,
	ISNULL(orderheader.QST_REQ, 'S') QST_REQ,
	ISNULL(orderheader.IVA_REQ, 'S') IVA_REQ,
 	ISNULL(ord_broker_percent,0.00) ord_broker_percent,		-- PTS 48227 - DJM
 	ISNULL(ord_target_margin, 0.00) ord_target_margin,			-- PTS 48227 - PMILL
 	ord_order_source,		/* 08/19/2010 MDH PTS 52714: Added */
 	--PTS 60199 JJF 20120814
 	orderheader.ord_over_credit_limit_approved,
 	orderheader.ord_over_credit_limit_approved_by
 	--END PTS 60199 JJF 20120814
  FROM orderheader  with (nolock) LEFT OUTER JOIN company AS cmp1  with (nolock) ON orderheader.ord_company = cmp1.cmp_id 
                    LEFT OUTER JOIN company AS cmp2  with (nolock) ON orderheader.ord_billto = cmp2.cmp_id 
                    LEFT OUTER JOIN edi_orderstate  with (nolock) ON orderheader.ord_edistate = edi_orderstate.esc_code 
-- PTS34244 PRB
		    LEFT OUTER JOIN company AS orig  with (nolock) ON orderheader.ord_originpoint = orig.cmp_id  
 		    LEFT OUTER JOIN company AS dest  with (nolock) ON orderheader.ord_destpoint = dest.cmp_id
		 
-- END PTS34244
  WHERE orderheader.ord_hdrnumber in ( select distinct ord_hdrnumber from stops  with (nolock) where stops.mov_number = @mov_number) 
GO
GRANT EXECUTE ON  [dbo].[d_ord_hdrnumber_sp] TO [public]
GO
