SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROC [dbo].[d_tar_viewtariffbids_sp] @carrier char(8),
	@OriginPoint char(8) , 
	@OriginCity int , 	
	@OriginState char(2) , 
	@DestPoint char(8) , 
	@DestCity int , 
	@DestState char(2), 
	@RevType1 char(6) , 
	@RevType2 char(6) , 
	@RevType3 char(6) , 
	@RevType4 char(6) , 
	@lghtype1 char(6),
	@effectivestartingfrom datetime,
	@effectivestartingto datetime,
	@expiredfrom datetime,
	@expiredto datetime,
	@Route varchar(15),
	@masterordernumber  varchar(12),  
	@trk_originzip varchar(10), 
	@trk_destzip  varchar(10)	
AS 
/**
 * PTS 46628  Modified
 * 3-19-2010 - add zip code.
 *
 **/
 
Select trk_number, 
	trk_description, 
	tar_number, 
	trk_startdate, 
	trk_enddate, 
	trk_billto, 
	tariffkeybid.cmp_othertype1, 
	tariffkeybid.cmp_othertype2, 
	tariffkeybid.cmd_code ,
	cmd_class ,
	trl_type1  ,
	trl_type2  ,
	trl_type3  ,
	trl_type4  ,
	trk_revtype1  ,
	trk_revtype2  ,
	trk_revtype3  ,
	trk_revtype4  ,
	trk_originpoint  ,
	trk_origincity  ,
	trk_originzip  ,
	trk_originstate  ,
	trk_destpoint  ,
	trk_destcity  ,
	trk_destzip  ,
	trk_deststate  ,
	trk_minmiles  ,
	trk_minweight  ,
	trk_minpieces  ,
	trk_minvolume  ,
	trk_maxmiles  ,
	trk_maxweight  ,
	trk_maxpieces  ,
	trk_maxvolume  ,
	trk_duplicateseq  ,
	trk_primary  ,
	trk_minstops  ,
	trk_maxstops  ,
	trk_minodmiles  ,
	trk_maxodmiles  ,
	trk_minvariance,
	trk_maxvariance,	
	trk_orderedby  ,
	trk_minlength ,
	trk_maxlength ,
	trk_minwidth ,
	trk_maxwidth ,
	trk_minheight ,
	trk_maxheight ,
	trk_origincounty  ,
	trk_destcounty  ,
	trk_company  ,
	trk_carrier  ,
	trk_lghtype1  ,
	trk_load  ,
	trk_team  ,
	trk_boardcarrier  ,
	trk_distunit  ,
	trk_wgtunit  ,
	trk_countunit  ,
	trk_volunit  ,
	trk_odunit  ,
	mpp_type1  ,
	mpp_type2  ,
	mpp_type3  ,
	mpp_type4  ,
	trc_type1  ,
	trc_type2  ,
	trc_type3  ,
	trc_type4  ,
	cht_itemcode  ,
	trk_stoptype  ,
	trk_delays  ,
	trk_ooamileage  ,
	trk_ooastop  ,
	trk_carryins1  ,
	trk_carryins2  ,
	trk_minmaxmiletype ,
	trk_terms  ,
	trk_triptype_or_region  ,
	trk_tt_or_oregion  ,
	trk_dregion  ,
	tariffkeybid.cmp_mastercompany ,
	trk_mileagetable  ,
	trk_fueltableid  ,
	trk_minrevpermile ,
	trk_maxrevpermile ,
	trk_indexseq ,
	trk_stp_event  ,
	trk_return_billto  ,
	trk_return_revtype1  ,
	trk_custdoc  ,
	trk_billtoregion  ,
	last_updateby  ,
	last_updatedate  ,
	trk_partytobill  ,
	trk_partytobill_id  ,
	tch_id  ,
	rth_id  ,
	trk_originsvccenter  ,
	trk_originsvcregion  ,
	trk_destsvccenter  ,
	trk_destsvcregion  ,
	trk_lghtype2  ,
	trk_lghtype3  ,
	trk_lghtype4  ,
	trk_thirdparty  ,
	trk_thirdpartytype  ,
	trk_minsegments  ,
	trk_maxsegments  ,
	billto_othertype1  ,
	billto_othertype2  ,
	masterordernumber  ,
	mpp_id  ,
	mpp_payto  ,
	trc_number  ,
	trc_owner ,
	trl_number  ,
	trl_owner  ,
	pto_id  ,
	mpp_terminal  ,
	trc_terminal  ,
	trl_terminal  ,
	trk_primary_driver  ,
	trk_index_factor   ,
	stop_othertype1  ,
	stop_othertype2  ,
	trk_mintime  ,
	trk_billto_car_key  ,
	tariffkeybid.brn_id ,
	mpp_domicile  ,
	trk_usefor_billable  ,
	trk_route  ,
	trk_mincarriersvcdays  ,
	trk_maxcarriersvcdays  ,
	laneorigintype  ,
	lanedesttype  
INTO #temp_tariffkeybid 
FROM tariffkeybid   
		-- dont need any of these joins anymore.     
 		--join city city_origin on tariffkeybid.trk_origincity = city_origin.cty_code       
 		--join city city_dest on tariffkeybid.trk_destcity = city_dest.cty_code
 		--left outer join company ocmp on tariffkeybid.trk_originpoint = ocmp.cmp_id
 		--left outer join company dcmp on tariffkeybid.trk_destpoint = dcmp.cmp_id 	
 		   		
	WHERE 	( @carrier in ( tariffkeybid.trk_carrier , 'UNKNOWN' ) ) 
			AND ( @OriginPoint in ( tariffkeybid.trk_originpoint , 'UNKNOWN' ) ) 
			AND ( @OriginCity in ( tariffkeybid.trk_origincity , 0 ) ) 
			AND ( @OriginState in ( tariffkeybid.trk_originstate , 'XX' ) ) 
			AND ( @DestPoint in ( tariffkeybid.trk_destpoint , 'UNKNOWN' ) )  
			AND ( @DestCity in ( tariffkeybid.trk_destcity , 0 ) )  				
	 		AND ( @DestState in ( tariffkeybid.trk_deststate , 'XX' ) ) 
			AND (  @RevType1 in ( tariffkeybid.trk_revtype1 , 'UNK' ) ) 
			AND ( @RevType2 in ( tariffkeybid.trk_revtype2 , 'UNK' ) ) 
			AND ( @RevType3 in ( tariffkeybid.trk_revtype3 , 'UNK' ) )
			AND ( @RevType4 in ( tariffkeybid.trk_revtype4 , 'UNK' ) )  
			AND ( @lghtype1 in ( tariffkeybid.trk_lghtype1 , 'UNK' ) )
			AND ( @Route in ( tariffkeybid.trk_route , 'UNK' ) ) 
			AND ( tariffkeybid.trk_startdate BETWEEN @effectivestartingfrom AND @effectivestartingto ) 
			AND ( tariffkeybid.trk_enddate BETWEEN @expiredfrom AND @expiredto)
			AND ( @masterordernumber in ( isnull(tariffkeybid.masterordernumber, 'UNK'), 'UNK' ) )
			AND ( @trk_originzip in ( tariffkeybid.trk_originzip , 'UNKNOWN' ) )
			AND ( @trk_destzip in ( tariffkeybid.trk_destzip , 'UNKNOWN' ) )

select * from #temp_tariffkeybid 

GO
GRANT EXECUTE ON  [dbo].[d_tar_viewtariffbids_sp] TO [public]
GO
