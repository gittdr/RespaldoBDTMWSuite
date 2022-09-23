SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*****************************************************************************
6.16.15 EJD
Copy from d_tar_viewtariffs_stl_sp 
Change into stock TMW SSRS report of the scroll

Sample Call:
EXEC dbo.SSRS_RB_TariffSTLScroll '7/2/2015'
**********************************************************************************/

CREATE PROCEDURE [dbo].[SSRS_RB_TariffSTLScroll]

(
@ExpDate DATETIME
)

AS 

BEGIN

	SELECT 	tk.trk_number AS RateNo,       
            tk.tar_number AS RateID,  
			tk.trk_description,   
            tariffheaderstl.tar_description AS RateDescription,   
			tariffheaderstl.tar_tariffitem AS RateItem,   
			tk.trk_billto AS BillTo,    
			tk.trk_originpoint,   
			tk.trk_destpoint,   
			tk.trk_startdate,   
			tk.trk_enddate,   
			tk.cmp_othertype1,   
			tk.cmp_othertype2,   
			tk.cmd_code,   
			tk.cmd_class,   
			tk.trl_type1,   
			tk.trl_type2,   
			tk.trl_type3,   
			tk.trl_type4,   
			tk.trk_revtype1,   
			tk.trk_revtype2,   
			tk.trk_revtype3,   
			tk.trk_revtype4,   
			tk.trk_originzip,   
			tk.trk_originstate,   
			tk.trk_destzip,   
			tk.trk_deststate,   
			tk.trk_minmiles,   
			tk.trk_maxmiles, 
			tk.trk_minweight,   
			tk.trk_minpieces,   
			tk.trk_maxweight,   
			tk.trk_maxpieces,   
			tk.trk_maxvolume,   
			tk.trk_minstops,   
			tk.trk_maxstops,   
			tk.trk_minodmiles,   
			tk.trk_maxodmiles,   
			tk.trk_minvariance,   
			tk.trk_maxvariance,   
	        tk.trk_minlength,   
			tk.trk_maxlength,   
			tk.trk_minwidth,   
			tk.trk_maxwidth,   
			tk.trk_minheight,   
			tk.trk_maxheight, 
			tk.trk_distunit,
			tk.trk_wgtunit,
			tk.trk_countunit,
			tk.trk_volunit,
			tk.trk_odunit,
			city_origin.cty_nmstct AS OriginCtySt,   
			city_dest.cty_nmstct AS DestCitySt,    		
			tariffheaderstl.tar_tarriffnumber, 
			tk.trk_orderedby,  
			tk.trk_origincounty,   
			tk.trk_destcounty,   
			tk.mpp_type1,
			tk.mpp_type2,
			tk.mpp_type3,
			tk.mpp_type4,
			tk.trc_type1,
			tk.trc_type2,
			tk.trc_type3,
			tk.trc_type4,
			--tk.cht_itemcode,
			tariffheaderstl.cht_itemcode,
			tk.trk_carrier,
			tk.trk_boardcarrier,
			tk.trk_load,
			tk.trk_team,
			tk.trk_company,
			tk.trk_lghtype1,
			0 AS taa_seq,
			pyt_description
			,origin =  CASE IsNull(ocmp.cmp_name,'UNKNOWN') WHEN 'UNKNOWN' THEN '' ELSE ocmp.cmp_name END
			,originloc = IsNull(ocmp.cmp_geoloc,'')
			,destination = CASE IsNull(dcmp.cmp_name,'UNKNOWN') WHEN 'UNKNOWN' THEN '' ELSE dcmp.cmp_name END
			,destinationloc = isnull(dcmp.cmp_geoloc,''),
			tk.trk_thirdparty,
			tk.trk_thirdpartytype,
			tk.mpp_terminal,
			tk.trc_terminal,
			tk.trl_terminal

 	FROM tariffkey tk  WITH (NOLOCK)    
 		
		JOIN city city_origin WITH (NOLOCK)
		ON tk.trk_origincity = city_origin.cty_code       
 		
		JOIN city city_dest WITH (NOLOCK) 
		ON tk.trk_destcity = city_dest.cty_code
 		
		LEFT OUTER JOIN company ocmp WITH (NOLOCK) 
		ON tk.trk_originpoint = ocmp.cmp_id
 		
		LEFT OUTER JOIN company dcmp WITH (NOLOCK) 
		ON tk.trk_destpoint = dcmp.cmp_id
 		
		JOIN tariffheaderstl WITH (NOLOCK) 
		ON tariffheaderstl.tar_number = tk.tar_number     
 		
		JOIN paytype WITH (NOLOCK) 
		ON paytype.pyt_itemcode = tariffheaderstl.cht_itemcode     

WHERE  tk.trk_enddate > @ExpDate

END

GRANT EXECUTE ON SSRS_RB_TariffSTLScroll TO PUBLIC 

GO
