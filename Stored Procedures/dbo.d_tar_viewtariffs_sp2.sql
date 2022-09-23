SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[d_tar_viewtariffs_sp2]
@BillTo char(8) 
AS   


SELECT  tariffkey.trk_number,       
 tariffkey.tar_number,       
 tariffkey.trk_description,       
 tariffkey.trk_billto,       
 tariffkey.trk_originpoint,       
 tariffkey.trk_destpoint,       
 tariffkey.trk_startdate,       
 tariffkey.trk_enddate, case when tariffkey.trk_enddate >=GETDATE() then 'Activo' else 'Inactivo' end as Estatus    ,   
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
 ( tariffkey.trk_primary = 'Y' ) AND     
 --PTS 33532 JJF 20070919
 --( tariffkey.trk_startdate >= '1950-01-01 00:00:00.000' ) AND   
(('A' = 'B' AND ( tariffkey.trk_startdate <= '2049-12-31 23:59:00.000') and 
(tariffkey.trk_enddate >= '1950-01-01 00:00:00.000'))  OR
('A' = 'A' AND 
	tariffkey.trk_startdate BETWEEN '1950-01-01 00:00:00.000' AND '2049-12-31 23:59:00.000' AND
	tariffkey.trk_enddate BETWEEN '1950-01-01 00:00:00.000' AND '2049-12-31 23:59:00.000')) AND
  --END PTS 33532 JJF 20070919
 ( 'UNKNOWN' in (tariffkey.trk_orderedby, 'UNKNOWN' )) and    
 ( @BillTo in ( tariffkey.trk_billto , 'UNKNOWN' ) ) AND        
 ( 'UNK' in ( tariffkey.cmp_othertype1 , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.cmp_othertype2 , 'UNK' ) ) AND      
 ( 'UNKNOWN' in ( tariffkey.cmd_code , 'UNKNOWN' ) ) AND      
 ( 'UNKNOWN' in ( tariffkey.cmd_class , 'UNKNOWN' ) ) AND      
 ( 'UNK' in ( tariffkey.trl_type1 , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trl_type2 , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trl_type3 , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trl_type4 , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_revtype1 , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_revtype2 , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_revtype3 , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_revtype4 , 'UNK' ) ) AND      
 ( 'UNKNOWN'  in ( tariffkey.trk_originpoint , 'UNKNOWN' ) ) AND      
 ( 0 in ( tariffkey.trk_origincity , 0 ) ) AND      
 ( 'UNKNOWN' in ( tariffkey.trk_originzip , 'UNKNOWN' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_origincounty , 'UNK' ) ) AND      
 ( 'XX' in ( tariffkey.trk_originstate , 'XX' ) ) AND      
 ( 'UNKNOWN' in ( tariffkey.trk_destpoint , 'UNKNOWN' ) ) AND      
 ( 0 in ( tariffkey.trk_destcity , 0 ) ) AND      
 ( 'UNKNOWN' in ( tariffkey.trk_destzip , 'UNKNOWN' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_destcounty , 'UNK' ) ) AND      
 ( 'XX' in ( tariffkey.trk_deststate , 'XX' ) )  and    
 ( 'UNKNOWN' in ( tariffkey.trk_carrier , 'UNKNOWN' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_boardcarrier , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_load , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_team , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_company , 'UNK' ) ) AND      
 ( 'UNK' in ( tariffkey.trk_lghtype1 , 'UNK' ) )AND     
 --PTS 33532 JJF 20070919
 --( tariffkey.trk_enddate <= '2049-12-31 23:59:00.000' )  and    
  --END PTS 33532 JJF 20070919
 ( 'UNK' in ( tariffkey.trk_terms , 'UNK' ) ) and    
 'UNKNOWN' in (tariffkey.cmp_mastercompany, 'UNKNOWN')and    
 '' in (tariffheader.tar_tarriffnumber, ' ')and    
 '' in (tariffheader.tar_tariffitem, ' ') and  
 'UNKNOWN' in (IsNull(tariffkey.trk_return_billto,'UNKNOWN'),'UNKNOWN') and  
 'UNK' in (IsNull(tariffkey.trk_return_revtype1,'UNK'),'UNK')    and
 ('N' = 'N' OR ('N' = 'Y' and trk_carrier <> 'UNKNOWN')) and
 ('N' = 'N' OR ('N' = 'Y' and (tar_rowbasis <> 'NOT' OR tar_colbasis <> 'NOT')))
	
	--PTS 51570 JJF 20100510
	--AND dbo.RowRestrictByUserMultiple(tar_belongsto, '', '', '') = 1 AND  
	AND EXISTS (	SELECT	*
					FROM	tariffkey tk 
							--PTS 67487 20130219
							INNER JOIN (SELECT rowsec_rsrv_id FROM  RowRestrictValidAssignments_tariffkey_fn()) rsva on (tk.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							--END PTS 67487 20130219
					WHERE	tk.tar_number = tariffheader.tar_number
							--PTS 67487 20130219
							--AND dbo.RowRestrictByUser('tariffkey', tk.rowsec_rsrv_id, '', '', '') = 1
							--END PTS 67487 20130219
				)
	
	AND ( 'UNK' in ( tariffheader.cht_itemcode , 'UNK' ) )		--	LOr	PTS# 44742
  

GO
