SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*****************************************************************************
6.16.15 EJD
Copy from d_tar_viewtariffs_sp - Change into stock TMW SSRS report of the scroll

Sample Call:
EXEC dbo.SSRS_RB_TariffScroll '7/2/2015'
**********************************************************************************/


CREATE PROCEDURE [dbo].[SSRS_RB_TariffScroll]
(
@ExpDate DATETIME
)


AS 

BEGIN

SELECT  
 tk.trk_number AS RateNo,       
 tk.tar_number AS RateID,       
 tk.trk_description,    
 th.tar_description AS RateDescription,       
 tk.trk_billto AS BillTo,   
 th.tar_tariffitem AS RateItem,       
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
 tk.trk_minweight,       
 tk.trk_minpieces,       
 tk.trk_minvolume,       
 tk.trk_maxmiles,       
 tk.trk_maxweight,       
 tk.trk_maxpieces,       
 tk.trk_maxvolume,       
 tk.trk_minstops,       
 tk.trk_maxstops,       
 tk.trk_minodmiles,       
 tk.trk_maxodmiles,       
 tk.trk_minvariance,       
 tk.trk_maxvariance,          
 city_origin.cty_nmstct AS OriginCtySt,       
 city_dest.cty_nmstct AS DestCitySt,       
 th.tar_tarriffnumber,     
 tk.trk_orderedby,       
 tk.trk_origincounty,       
 tk.trk_destcounty,       
 tk.trk_minlength,       
 tk.trk_maxlength,       
 tk.trk_minwidth,       
 tk.trk_maxwidth,       
 tk.trk_minheight,       
 tk.trk_maxheight ,     
 tk.trk_distunit ,      
 tk.trk_wgtunit ,      
 tk.trk_countunit ,    
 tk.trk_volunit ,      
 tk.trk_odunit,    
 tk.trk_carrier,    
 tk.trk_boardcarrier,    
 tk.trk_load,    
 tk.trk_team,    
 tk.trk_company,    
 tk.trk_lghtype1,   
 'LghType1' AS compute_lghtype1,    
 tk.trk_terms,    
 tk.cmp_mastercompany,    
 0 AS taa_seq ,    
 tk.trk_return_billto,    
 tk.trk_return_revtype1,
 ct.cht_description
 ,origin =  Case IsNull(ocmp.cmp_name,'UNKNOWN') When 'UNKNOWN' then '' Else ocmp.cmp_name end
 ,originloc = IsNull(ocmp.cmp_geoloc,'')
 ,destination = Case IsNull(dcmp.cmp_name,'UNKNOWN') When 'UNKNOWN' then '' Else dcmp.cmp_name end
 ,destinationloc = isnull(dcmp.cmp_geoloc,'')
 ,trk_billto_carkeyname = Isnull((select car_name from companyaddress where car_key = Isnull(trk_billto_car_key,0) ),''),
 th.cht_itemcode,
 tk.trk_mincarriersvcdays,	--46113
 tk.trk_maxcarriersvcdays,	--46113 
 ct.cht_primary,
 CASE WHEN ct.cht_primary = 'Y' THEN 'Primary Rate'
      WHEN ct.cht_primary = 'N' THEN 'Accessorial Rate'
	  ELSE ct.cht_primary 
 END AS TariffRateType

FROM tariffkey  tk WITH (NOLOCK)     
 
 JOIN city city_origin  WITH (NOLOCK)     
 ON tk.trk_origincity = city_origin.cty_code       
 
 JOIN city city_dest WITH (NOLOCK)
 ON tk.trk_destcity = city_dest.cty_code

 LEFT OUTER JOIN company ocmp  WITH (NOLOCK)     
 ON tk.trk_originpoint = ocmp.cmp_id

 LEFT OUTER JOIN company dcmp  WITH (NOLOCK)     
 ON tk.trk_destpoint = dcmp.cmp_id

 JOIN tariffheader th WITH (NOLOCK)
 ON th.tar_number = tk.tar_number   
   
 JOIN chargetype ct WITH (NOLOCK)
 ON  ct.cht_itemcode = th.cht_itemcode    

 WHERE  tk.trk_enddate > @ExpDate


 END


GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_TariffScroll] TO [public]
GO
