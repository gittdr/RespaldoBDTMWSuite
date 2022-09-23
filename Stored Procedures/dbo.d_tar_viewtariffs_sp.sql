SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[d_tar_viewtariffs_sp]     
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
	@OriginState varchar(6) ,     
	@DestPoint char(8) ,     
	@DestCity int ,     
	@DestZip char(10) ,     
	@DestCounty char(3) ,     
	@DestState varchar(6),     
	@OrderBy char(8),    
	@carrier char(8),    
	@boardcarrier char(6),    
	@load char(6),    
	@team char(6),    
	@enddate datetime,    
	@company char(8),    
	@lghtype1 char(6),    
	@terms    char(6),    
	@mastercompany char(8),    
	@tariffnumber varchar(12),    
	@tariffitem varchar(12),  
	@returnbillto varchar(8),  
	@returnrevtype1 varchar(6) ,
	@carrier_only char(1),
	@table_rates_only char(1),
	@effectiveduringfrom datetime,
	@effectiveduringto datetime,
	@effectivestartingfrom datetime,
	@effectivestartingto datetime,
	@expiredfrom datetime,
	@expiredto datetime,
	@effectivedatesearchtype char(1),  
	@Itemcode varchar(6)					--	LOR	PTS# 44742
    
AS   
/**
 * 
 * NAME:
 * dbo.proc for dw d_tar_viewtariffs
 *
 * TYPE:
 * [StoredProcedure|
 *
 * DESCRIPTION:
 * proc for d_tar_viewtariffs
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
 * DPETE PTS12609 add restriction for Gibson's who returns a bill to and revtype 1 from the tariffkey  
 * JLB PTS 18509 adding new restrictions on types of rates returned (carrier only and tables with rates only  
 * DPETE 40260 Pauls recode 4/19/08 30355 return trk_billto_car_key companyaddress name 
 * PTS46113 pmill added carrier service days
 * 2009.06.03	vjh	PTS47730	handle multiple belongsto 
 *
 **/

--PTS 67487 20130219
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)

INSERT INTO @tbl_restrictedbyuser
SELECT rowsec_rsrv_id FROM  RowRestrictValidAssignments_tariffkey_fn() 
--END PTS 67487 20130219

SELECT  tariffkey.trk_number,       
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
 tariffheader.tar_description,       
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
 tariffheader.tar_tarriffnumber,     
 tariffkey.trk_orderedby,     
 tariffheader.tar_tariffitem,     
 tariffkey.trk_origincounty,       
 tariffkey.trk_destcounty,       
 tariffkey.trk_minlength,       
 tariffkey.trk_maxlength,       
 tariffkey.trk_minwidth,       
 tariffkey.trk_maxwidth,       
 tariffkey.trk_minheight,       
 tariffkey.trk_maxheight ,
 tariffkey.trk_number,       
 tariffkey.tar_number,       
 tariffkey.trk_distunit ,      
 tariffkey.trk_wgtunit ,      
 tariffkey.trk_countunit ,      
 tariffkey.trk_volunit ,      
 tariffkey.trk_odunit,    
 tariffkey.trk_carrier,    
 tariffkey.trk_boardcarrier,    
 tariffkey.trk_load,    
 tariffkey.trk_team,    
 tariffkey.trk_company,    
 tariffkey.trk_lghtype1,    
 'LghType1' compute_lghtype1,    
 tariffkey.trk_terms,    
 tariffkey.cmp_mastercompany,    
 0 taa_seq ,    
 tariffkey.trk_return_billto,    
 tariffkey.trk_return_revtype1,
 cht_description
 ,origin =  Case IsNull(ocmp.cmp_name,'UNKNOWN') When 'UNKNOWN' then '' Else ocmp.cmp_name end
 ,originloc = IsNull(ocmp.cmp_geoloc,'')
 ,destination = Case IsNull(dcmp.cmp_name,'UNKNOWN') When 'UNKNOWN' then '' Else dcmp.cmp_name end
 ,destinationloc = isnull(dcmp.cmp_geoloc,'')
 ,trk_billto_carkeyname = Isnull((select car_name from companyaddress where car_key = Isnull(trk_billto_car_key,0) ),''),
 tariffheader.cht_itemcode,
 tariffkey.trk_mincarriersvcdays,	--46113
 tariffkey.trk_maxcarriersvcdays	--46113 
FROM tariffkey       
 join city city_origin on tariffkey.trk_origincity = city_origin.cty_code       
 join city city_dest on tariffkey.trk_destcity = city_dest.cty_code
 left outer join company ocmp on tariffkey.trk_originpoint = ocmp.cmp_id
 left outer join company dcmp on tariffkey.trk_destpoint = dcmp.cmp_id
 join tariffheader on tariffheader.tar_number = tariffkey.tar_number     
 join chargetype on   chargetype.cht_itemcode = tariffheader.cht_itemcode    
WHERE               
 ( tariffkey.trk_primary = @Primary ) AND     
 --PTS 33532 JJF 20070919
 --( tariffkey.trk_startdate >= @Date ) AND   
((@effectivedatesearchtype = 'B' AND ( tariffkey.trk_startdate <= @effectiveduringto) and 
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
 ( @DestState in ( tariffkey.trk_deststate , 'XX' ) )  and    
 ( @carrier in ( tariffkey.trk_carrier , 'UNKNOWN' ) ) AND      
 ( @boardcarrier in ( tariffkey.trk_boardcarrier , 'UNK' ) ) AND      
 ( @load in ( tariffkey.trk_load , 'UNK' ) ) AND      
 ( @team in ( tariffkey.trk_team , 'UNK' ) ) AND      
 ( @company in ( tariffkey.trk_company , 'UNK' ) ) AND      
 ( @lghtype1 in ( tariffkey.trk_lghtype1 , 'UNK' ) )AND     
 --PTS 33532 JJF 20070919
 --( tariffkey.trk_enddate <= @enddate )  and    
  --END PTS 33532 JJF 20070919
 ( @terms in ( tariffkey.trk_terms , 'UNK' ) ) and    
 @mastercompany in (tariffkey.cmp_mastercompany, 'UNKNOWN')and    
 @tariffnumber in (tariffheader.tar_tarriffnumber, ' ')and    
 @tariffitem in (tariffheader.tar_tariffitem, ' ') and  
 @returnbillto in (IsNull(tariffkey.trk_return_billto,'UNKNOWN'),'UNKNOWN') and  
 @returnrevtype1 in (IsNull(tariffkey.trk_return_revtype1,'UNK'),'UNK')    and
 (@carrier_only = 'N' OR (@carrier_only = 'Y' and trk_carrier <> 'UNKNOWN')) and
 (@table_rates_only = 'N' OR (@table_rates_only = 'Y' and (tar_rowbasis <> 'NOT' OR tar_colbasis <> 'NOT')))
	
	--PTS 51570 JJF 20100510
	--AND dbo.RowRestrictByUserMultiple(tar_belongsto, '', '', '') = 1 AND  
	AND EXISTS (	SELECT	*
					FROM	tariffkey tk 
							--PTS 67487 20130219
							INNER JOIN @tbl_restrictedbyuser rsva on (tk.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							--END PTS 67487 20130219
					WHERE	tk.tar_number = tariffheader.tar_number
							--PTS 67487 20130219
							--AND dbo.RowRestrictByUser('tariffkey', tk.rowsec_rsrv_id, '', '', '') = 1
							--END PTS 67487 20130219
				)
	
	AND ( @Itemcode in ( tariffheader.cht_itemcode , 'UNK' ) )		--	LOr	PTS# 44742
  
GO
GRANT EXECUTE ON  [dbo].[d_tar_viewtariffs_sp] TO [public]
GO
