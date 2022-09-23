SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[d_tar_viewtariffs_increase_stl_sp] 
	@Primary char(1) , 
	@Date datetime , 
	@BillTo char(8) , 
	@CmpType1 char(6) , 
	@CmpType2 char(6) , 
	@TrlType1 char(6) , 
	@TrlType2 char(6) , 
	@TrlType3 char(6) , 
	@TrlType4 char(6) , 
	@RevType1 char(6) , 
	@RevType2 char(6) , 
	@RevType3 char(6) , 
	@RevType4 char(6) , 
	@CmdCode char(8) , 
	@CmdClass char(8) , 
	@OriginPoint char(8) , 
	@OriginCity int , 
	@OriginZip char(10) , 
	@OriginCounty char(3) , 
	@OriginState char(2) , 
	@DestPoint char(8) , 
	@DestCity int , 
	@DestZip char(10) , 
	@DestCounty char(3) , 
	@DestState char(2), 
	@OrderBy char(8), 
	@DrvType1 char(6) , 
	@DrvType2 char(6) , 
	@DrvType3 char(6) ,  
	@DrvType4 char(6) ,  
	@TrcType1 char(6) ,  
	@TrcType2 char(6) ,  
	@TrcType3 char(6) ,  
	@TrcType4 char(6) ,  
	@Itemcode char(6),
	@carrier char(8),
	@boardcarrier char(6),
	@load char(6),
	@team char(6),
	@enddate datetime,
	@company char(8),
	@lghtype1 char(6),
	@tar_applyto_asset char (3),
	@table_rates_only char(1),
	@thirdparty char (8),
	@thirdpartytype char (8),
	@effectiveduringfrom datetime,
	@effectiveduringto datetime,
	@effectivestartingfrom datetime,
	@effectivestartingto datetime,
	@expiredfrom datetime,
	@expiredto datetime,
	@effectivedatesearchtype char(1),
	@pyt_itemcode VARCHAR(6)
AS 
/**
 * 
 * NAME:
 * dbo.d_tar_viewtariffs_increase_stl_sp
 *
 * TYPE:
 * [StoredProcedure|
 *
 * DESCRIPTION:
 * proc for d_tar_viewtariffs_increase_stl
 *   Used in the scroll rates window.
 *
 * RETURNS:
 * Tariffs
 *
 * RESULT SETS: 
 * dw result set
 *
 * PARAMETERS:
 * All index parameters for settlemets.
 * 
 * REVISION HISTORY:
 * Author unknown
 *	LOR	PTS# 45442	changed tariffkey.cht_itemcode to tariffheaderstl.cht_itemcode
 * 2009.06.03	vjh	PTS47730	handle multiple belongsto 
 *
 **/

If @Primary  = 'B' 
	SELECT 	tariffkey.trk_number,   
			tariffkey.tar_number,   
			tariffkey.trk_description,   
			tariffkey.trk_billto,   
			tariffkey.trk_originpoint,   
			tariffkey.trk_destpoint,   
			tariffkey.trk_startdate,   
			tariffkey.trk_enddate,   
			tariffkey.cmp_othertype1,   
			tariffkey.cmp_othertype2,   
			tariffkey.cmd_code,   
			tariffkey.cmd_class,   
			tariffkey.trl_type1,   
			tariffkey.trl_type2,   
			tariffkey.trl_type3,   
			tariffkey.trl_type4,   
			tariffkey.trk_revtype1,   
			tariffkey.trk_revtype2,   
			tariffkey.trk_revtype3,   
			tariffkey.trk_revtype4,   
			tariffkey.trk_originzip,   
			tariffkey.trk_originstate,   
			tariffkey.trk_destzip,   
			tariffkey.trk_deststate,   
			tariffkey.trk_minmiles,   
			tariffkey.trk_minweight,   
			tariffkey.trk_minpieces,   
			tariffkey.trk_minvolume,   
			tariffkey.trk_maxmiles,   
			tariffkey.trk_maxweight,   
			tariffkey.trk_maxpieces,   
			tariffkey.trk_maxvolume,   
			tariffkey.trk_minstops,   
			tariffkey.trk_maxstops,   
			tariffkey.trk_minodmiles,   
			tariffkey.trk_maxodmiles,   
			tariffkey.trk_minvariance,   
			tariffkey.trk_maxvariance,   
			tariffheaderstl.tar_description,   
			city_origin.cty_nmstct,   
			city_dest.cty_nmstct,   
			'OtherTypes1' compute_othertypes1,   
			'OtherTypes2' compute_othertypes2,   
			'RevType1' compute_revtype1,   
			'RevType2' compute_revtype2,   
			'RevType3' compute_revtype3,   
			'RevType4' compute_revtype4,   
			'TrlType1' compute_trltype1,   
			'TrlType2' compute_trltype2,   
			'TrlType3' compute_trltype3,   
			'TrlType4' compute_trltype4,   
			tariffheaderstl.tar_tarriffnumber, 
			tariffkey.trk_orderedby, 
			tariffheaderstl.tar_tariffitem, 
			tariffkey.trk_origincounty,   
			tariffkey.trk_destcounty,   
			tariffkey.trk_minlength,   
			tariffkey.trk_maxlength,   
			tariffkey.trk_minwidth,   
			tariffkey.trk_maxwidth,   
			tariffkey.trk_minheight,   
			tariffkey.trk_maxheight,
	 		tariffkey.trk_number,   
			tariffkey.tar_number,   
			tariffkey.trk_distunit,
			tariffkey.trk_wgtunit,
			tariffkey.trk_countunit,
			tariffkey.trk_volunit,
			tariffkey.trk_odunit,
			tariffkey.mpp_type1,
			tariffkey.mpp_type2,
			tariffkey.mpp_type3,
			tariffkey.mpp_type4,
			tariffkey.trc_type1,
			tariffkey.trc_type2,
			tariffkey.trc_type3,
			tariffkey.trc_type4,
			--tariffkey.cht_itemcode,
			tariffheaderstl.cht_itemcode,
			'DrvType1' compute_drvtype1, 
			'DrvType2' compute_drvtype2,   
			'DrvType3' compute_drvtype3,   
			'DrvType4' compute_drvtype4,   
			'TrcType1' compute_trctype1, 
			'TrcType2' compute_trctype2, 
			'TrcType3' compute_trctype3, 
			'TrcType4' compute_trctype4,
			tariffkey.trk_carrier,
			tariffkey.trk_boardcarrier,
			tariffkey.trk_load,
			tariffkey.trk_team,
			tariffkey.trk_company,
			tariffkey.trk_lghtype1,
			'LghType1' compute_lghtype1,
			0 taa_seq,
			boc_description  
			 ,origin =  Case IsNull(ocmp.cmp_name,'UNKNOWN') When 'UNKNOWN' then '' Else ocmp.cmp_name end
			 ,originloc = IsNull(ocmp.cmp_geoloc,'')
			 ,destination = Case IsNull(dcmp.cmp_name,'UNKNOWN') When 'UNKNOWN' then '' Else dcmp.cmp_name end
			 ,destinationloc = isnull(dcmp.cmp_geoloc,''),
			tariffkey.trk_thirdparty,
			tariffkey.trk_thirdpartytype,
			tariffheaderstl.tar_rate,
			tariffheaderstl.tar_rate new_rate,
			'PER' adjustment_type,
			4 round_to,
			0.0000 rate_adjustment,
			tariffheaderstl.tar_rowbasis,
			tariffheaderstl.tar_colbasis
 	FROM tariffkey       
 		join city city_origin on tariffkey.trk_origincity = city_origin.cty_code       
 		join city city_dest on tariffkey.trk_destcity = city_dest.cty_code
 		left outer join company ocmp on tariffkey.trk_originpoint = ocmp.cmp_id
 		left outer join company dcmp on tariffkey.trk_destpoint = dcmp.cmp_id
 		join tariffheaderstl on tariffheaderstl.tar_number = tariffkey.tar_number     
 		join backoutcodes on backoutcodes.boc_itemcode = tariffheaderstl.cht_itemcode 
								 AND @pyt_itemcode IN (tariffheaderstl.cht_itemcode, 'UNK')     
	WHERE 	( tariffkey.trk_primary = @Primary ) AND 
			--PTS 33532 JJF 20070919
			--( tariffkey.trk_startdate >= @Date ) AND 
			--( tariffkey.trk_startdate >= @Date ) AND 
			((@effectivedatesearchtype = 'B' AND (tariffkey.trk_startdate <= @effectiveduringto) and 
			(tariffkey.trk_enddate >= @effectiveduringfrom))  OR
			(@effectivedatesearchtype = 'A' AND 
				tariffkey.trk_startdate BETWEEN @effectivestartingfrom AND @effectivestartingto AND
				tariffkey.trk_enddate BETWEEN @expiredfrom AND @expiredto)) AND
			--END PTS 33532 JJF 20070919
			( @OrderBy in (tariffkey.trk_orderedby, 'UNKNOWN' )) and
			( @BillTo in ( tariffkey.trk_billto , 'UNKNOWN' ) ) AND  
			( @CmpType1 in ( tariffkey.cmp_othertype1 , 'UNK' ) ) AND  
			( @CmpType2 in ( tariffkey.cmp_othertype2 , 'UNK' ) ) AND  
			( @CmdCode in ( tariffkey.cmd_code , 'UNKNOWN' ) ) AND  
			( @CmdClass in ( tariffkey.cmd_class , 'UNKNOWN' ) ) AND  
			( @TrlType1 in ( tariffkey.trl_type1 , 'UNK' ) ) AND  
			( @TrlType2 in ( tariffkey.trl_type2 , 'UNK' ) ) AND  
			( @TrlType3 in ( tariffkey.trl_type3 , 'UNK' ) ) AND  
			( @TrlType4 in ( tariffkey.trl_type4 , 'UNK' ) ) AND  
			( @RevType1 in ( tariffkey.trk_revtype1 , 'UNK' ) ) AND  
			( @RevType2 in ( tariffkey.trk_revtype2 , 'UNK' ) ) AND  
			( @RevType3 in ( tariffkey.trk_revtype3 , 'UNK' ) ) AND  
			( @RevType4 in ( tariffkey.trk_revtype4 , 'UNK' ) ) AND  
			( @OriginPoint in ( tariffkey.trk_originpoint , 'UNKNOWN' ) ) AND  
			( @OriginCity in ( tariffkey.trk_origincity , 0 ) ) AND  
			( @OriginZip in ( tariffkey.trk_originzip , 'UNKNOWN' ) ) AND  
			( @OriginCounty in ( tariffkey.trk_origincounty , 'UNK' ) ) AND  
			( @OriginState in ( tariffkey.trk_originstate , 'XX' ) ) AND  
			( @DestPoint in ( tariffkey.trk_destpoint , 'UNKNOWN' ) ) AND  
			( @DestCity in ( tariffkey.trk_destcity , 0 ) ) AND  
			( @DestZip in ( tariffkey.trk_destzip , 'UNKNOWN' ) ) AND  
			( @DestCounty in ( tariffkey.trk_destcounty , 'UNK' ) ) AND  
			( @DestState in ( tariffkey.trk_deststate , 'XX' ) ) AND  
			( @DrvType1 in ( tariffkey.mpp_type1 , 'UNK' ) )  AND  
			( @DrvType2 in ( tariffkey.mpp_type2 , 'UNK' ) )   AND  
			( @DrvType3 in ( tariffkey.mpp_type3 , 'UNK' ) )   AND  
			( @DrvType4 in ( tariffkey.mpp_type4 , 'UNK' ) )   AND  
			( @TrcType1 in ( tariffkey.trc_type1 , 'UNK' ) )  AND  
			( @TrcType2 in ( tariffkey.trc_type2 , 'UNK' ) )  AND  
			( @TrcType3 in ( tariffkey.trc_type3 , 'UNK' ) )    AND  
			( @TrcType4 in ( tariffkey.trc_type4 , 'UNK' ) )    AND  
			--( @Itemcode in ( tariffkey.cht_itemcode , 'UNK' ) )and
			( @Itemcode in ( tariffheaderstl.cht_itemcode , 'UNK' ) )and
			( @carrier in ( tariffkey.trk_carrier , 'UNKNOWN' ) ) AND  
			( @boardcarrier in ( tariffkey.trk_boardcarrier , 'UNK' ) ) AND  
			( @load in ( tariffkey.trk_load , 'UNK' ) ) AND  
			( @team in ( tariffkey.trk_team , 'UNK' ) ) AND  
			( @company in ( tariffkey.trk_company , 'UNK' ) ) AND  
			( @lghtype1 in ( tariffkey.trk_lghtype1 , 'UNK' ) )AND 
			--PTS 33532 JJF 20070919
			--( tariffkey.trk_enddate <= @enddate )   AND
			--END PTS 33532 JJF 20070919
			(@tar_applyto_asset in (tariffheaderstl.tar_applyto_asset,'UNK')) and
			(@table_rates_only = 'N' OR (@table_rates_only = 'Y' and (tar_rowbasis <> 'NOT' OR tar_colbasis <> 'NOT'))) AND
			( @thirdparty in (tariffkey.trk_thirdparty, 'UNKNOWN')) AND
			( @thirdpartytype in (tariffkey.trk_thirdpartytype, 'UNKNOWN')) 
Else
	SELECT 	tariffkey.trk_number,   
			tariffkey.tar_number,   
			tariffkey.trk_description,   
			tariffkey.trk_billto,   
			tariffkey.trk_originpoint,   
			tariffkey.trk_destpoint,   
			tariffkey.trk_startdate,   
			tariffkey.trk_enddate,   
			tariffkey.cmp_othertype1,   
			tariffkey.cmp_othertype2,   
			tariffkey.cmd_code,   
			tariffkey.cmd_class,   
			tariffkey.trl_type1,   
			tariffkey.trl_type2,   
			tariffkey.trl_type3,   
			tariffkey.trl_type4,   
			tariffkey.trk_revtype1,   
			tariffkey.trk_revtype2,   
			tariffkey.trk_revtype3,   
			tariffkey.trk_revtype4,   
			tariffkey.trk_originzip,   
			tariffkey.trk_originstate,   
			tariffkey.trk_destzip,   
			tariffkey.trk_deststate,   
			tariffkey.trk_minmiles,   
			tariffkey.trk_minweight,   
			tariffkey.trk_minpieces,   
			tariffkey.trk_minvolume,   
			tariffkey.trk_maxmiles,   
			tariffkey.trk_maxweight,   
			tariffkey.trk_maxpieces,   
			tariffkey.trk_maxvolume,   
			tariffkey.trk_minstops,   
			tariffkey.trk_maxstops,   
			tariffkey.trk_minodmiles,   
			tariffkey.trk_maxodmiles,   
			tariffkey.trk_minvariance,   
			tariffkey.trk_maxvariance,   
			tariffheaderstl.tar_description,   
			city_origin.cty_nmstct,   
			city_dest.cty_nmstct,   
			'OtherTypes1' compute_othertypes1,   
			'OtherTypes2' compute_othertypes2,   
			'RevType1' compute_revtype1,   
			'RevType2' compute_revtype2,   
			'RevType3' compute_revtype3,   
			'RevType4' compute_revtype4,   
			'TrlType1' compute_trltype1,   
			'TrlType2' compute_trltype2,   
			'TrlType3' compute_trltype3,   
			'TrlType4' compute_trltype4,   
			tariffheaderstl.tar_tarriffnumber, 
			tariffkey.trk_orderedby, 
			tariffheaderstl.tar_tariffitem, 
			tariffkey.trk_origincounty,   
			tariffkey.trk_destcounty,   
			tariffkey.trk_minlength,   
			tariffkey.trk_maxlength,   
			tariffkey.trk_minwidth,   
			tariffkey.trk_maxwidth,   
			tariffkey.trk_minheight,   
			tariffkey.trk_maxheight,
	 		tariffkey.trk_number,   
			tariffkey.tar_number,   
			tariffkey.trk_distunit,
			tariffkey.trk_wgtunit,
			tariffkey.trk_countunit,
			tariffkey.trk_volunit,
			tariffkey.trk_odunit,
			tariffkey.mpp_type1,
			tariffkey.mpp_type2,
			tariffkey.mpp_type3,
			tariffkey.mpp_type4,
			tariffkey.trc_type1,
			tariffkey.trc_type2,
			tariffkey.trc_type3,
			tariffkey.trc_type4,
			--tariffkey.cht_itemcode,
			tariffheaderstl.cht_itemcode,
			'DrvType1' compute_drvtype1, 
			'DrvType2' compute_drvtype2,   
			'DrvType3' compute_drvtype3,   
			'DrvType4' compute_drvtype4,   
			'TrcType1' compute_trctype1, 
			'TrcType2' compute_trctype2, 
			'TrcType3' compute_trctype3, 
			'TrcType4' compute_trctype4,
			tariffkey.trk_carrier,
			tariffkey.trk_boardcarrier,
			tariffkey.trk_load,
			tariffkey.trk_team,
			tariffkey.trk_company,
			tariffkey.trk_lghtype1,
			'LghType1' compute_lghtype1,
			0 taa_seq,
			pyt_description  
			 ,origin =  Case IsNull(ocmp.cmp_name,'UNKNOWN') When 'UNKNOWN' then '' Else ocmp.cmp_name end
			 ,originloc = IsNull(ocmp.cmp_geoloc,'')
			 ,destination = Case IsNull(dcmp.cmp_name,'UNKNOWN') When 'UNKNOWN' then '' Else dcmp.cmp_name end
			 ,destinationloc = isnull(dcmp.cmp_geoloc,''),
			tariffkey.trk_thirdparty,
			tariffkey.trk_thirdpartytype,
			tariffheaderstl.tar_rate,
			tariffheaderstl.tar_rate new_rate,
			'PER' adjustment_type,
			4 round_to,
			0.0000 rate_adjustment,
			tariffheaderstl.tar_rowbasis,
			tariffheaderstl.tar_colbasis
 	FROM tariffkey       
 		join city city_origin on tariffkey.trk_origincity = city_origin.cty_code       
 		join city city_dest on tariffkey.trk_destcity = city_dest.cty_code
 		left outer join company ocmp on tariffkey.trk_originpoint = ocmp.cmp_id
 		left outer join company dcmp on tariffkey.trk_destpoint = dcmp.cmp_id
 		join tariffheaderstl on tariffheaderstl.tar_number = tariffkey.tar_number     
 		join paytype on   paytype.pyt_itemcode = tariffheaderstl.cht_itemcode 
						AND @pyt_itemcode IN (tariffheaderstl.cht_itemcode, 'UNK')   
	WHERE 	( tariffkey.trk_primary = @Primary ) AND 
			--PTS 33532 JJF 20070919
			--( tariffkey.trk_startdate >= @Date ) AND 
			--( tariffkey.trk_startdate >= @Date ) AND 
			(@effectivedatesearchtype = 'B' AND (tariffkey.trk_startdate <= @effectiveduringto) and 
			(tariffkey.trk_enddate >= @effectiveduringfrom)  OR
			(@effectivedatesearchtype = 'A' AND 
				tariffkey.trk_startdate BETWEEN @effectivestartingfrom AND @effectivestartingto AND
				tariffkey.trk_enddate BETWEEN @expiredfrom AND @expiredto)) AND
			--END PTS 33532 JJF 20070919
			( @OrderBy in (tariffkey.trk_orderedby, 'UNKNOWN' )) and
			( @BillTo in ( tariffkey.trk_billto , 'UNKNOWN' ) ) AND  
			( @CmpType1 in ( tariffkey.cmp_othertype1 , 'UNK' ) ) AND  
			( @CmpType2 in ( tariffkey.cmp_othertype2 , 'UNK' ) ) AND  
			( @CmdCode in ( tariffkey.cmd_code , 'UNKNOWN' ) ) AND  
			( @CmdClass in ( tariffkey.cmd_class , 'UNKNOWN' ) ) AND  
			( @TrlType1 in ( tariffkey.trl_type1 , 'UNK' ) ) AND  
			( @TrlType2 in ( tariffkey.trl_type2 , 'UNK' ) ) AND  
			( @TrlType3 in ( tariffkey.trl_type3 , 'UNK' ) ) AND  
			( @TrlType4 in ( tariffkey.trl_type4 , 'UNK' ) ) AND  
			( @RevType1 in ( tariffkey.trk_revtype1 , 'UNK' ) ) AND  
			( @RevType2 in ( tariffkey.trk_revtype2 , 'UNK' ) ) AND  
			( @RevType3 in ( tariffkey.trk_revtype3 , 'UNK' ) ) AND  
			( @RevType4 in ( tariffkey.trk_revtype4 , 'UNK' ) ) AND  
			( @OriginPoint in ( tariffkey.trk_originpoint , 'UNKNOWN' ) ) AND  
			( @OriginCity in ( tariffkey.trk_origincity , 0 ) ) AND  
			( @OriginZip in ( tariffkey.trk_originzip , 'UNKNOWN' ) ) AND  
			( @OriginCounty in ( tariffkey.trk_origincounty , 'UNK' ) ) AND  
			( @OriginState in ( tariffkey.trk_originstate , 'XX' ) ) AND  
			( @DestPoint in ( tariffkey.trk_destpoint , 'UNKNOWN' ) ) AND  
			( @DestCity in ( tariffkey.trk_destcity , 0 ) ) AND  
			( @DestZip in ( tariffkey.trk_destzip , 'UNKNOWN' ) ) AND  
			( @DestCounty in ( tariffkey.trk_destcounty , 'UNK' ) ) AND  
			( @DestState in ( tariffkey.trk_deststate , 'XX' ) ) AND  
			( @DrvType1 in ( tariffkey.mpp_type1 , 'UNK' ) )  AND  
			( @DrvType2 in ( tariffkey.mpp_type2 , 'UNK' ) )   AND  
			( @DrvType3 in ( tariffkey.mpp_type3 , 'UNK' ) )   AND  
			( @DrvType4 in ( tariffkey.mpp_type4 , 'UNK' ) )   AND  
			( @TrcType1 in ( tariffkey.trc_type1 , 'UNK' ) )  AND  
			( @TrcType2 in ( tariffkey.trc_type2 , 'UNK' ) )  AND  
			( @TrcType3 in ( tariffkey.trc_type3 , 'UNK' ) )    AND  
			( @TrcType4 in ( tariffkey.trc_type4 , 'UNK' ) )    AND  
			--( @Itemcode in ( tariffkey.cht_itemcode , 'UNK' ) )and
			( @Itemcode in ( tariffheaderstl.cht_itemcode , 'UNK' ) )and
			( @carrier in ( tariffkey.trk_carrier , 'UNKNOWN' ) ) AND  
			( @boardcarrier in ( tariffkey.trk_boardcarrier , 'UNK' ) ) AND  
			( @load in ( tariffkey.trk_load , 'UNK' ) ) AND  
			( @team in ( tariffkey.trk_team , 'UNK' ) ) AND  
			( @company in ( tariffkey.trk_company , 'UNK' ) ) AND  
			( @lghtype1 in ( tariffkey.trk_lghtype1 , 'UNK' ) )AND 
			--PTS 33532 JJF 20070919
			--( tariffkey.trk_enddate <= @enddate )   AND
			--END PTS 33532 JJF 20070919
			(@tar_applyto_asset in (tariffheaderstl.tar_applyto_asset,'UNK')) and
			(@table_rates_only = 'N' OR (@table_rates_only = 'Y' and (tar_rowbasis <> 'NOT' OR tar_colbasis <> 'NOT'))) AND
			( @thirdparty in (tariffkey.trk_thirdparty, 'UNKNOWN')) AND
			( @thirdpartytype in (tariffkey.trk_thirdpartytype, 'UNKNOWN'))
			--PTS 51570 JJF 20100510
			--AND dbo.RowRestrictByUserMultiple(tar_belongsto, '', '', '') = 1
			AND EXISTS (	SELECT	*
							FROM	tariffkey tk 
							WHERE	tk.tar_number = tariffheaderstl.tar_number
									AND dbo.RowRestrictByUser('tariffkey', tk.rowsec_rsrv_id, '', '', '') = 1
						)
			AND (tariffheaderstl.tar_external_flag is null or tariffheaderstl.tar_external_flag <> 'Y')  --42233 pmill exclude external tariffs
GO
GRANT EXECUTE ON  [dbo].[d_tar_viewtariffs_increase_stl_sp] TO [public]
GO
