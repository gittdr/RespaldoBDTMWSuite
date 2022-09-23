SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE View [dbo].[OperationsTrailerView_TDR] AS  
 SELECT  trailerprofile.trl_id,  
  company_a.cmp_id ,  
  company_a.cmp_name,  
  city_a.cty_nmstct,  
  company_a.cmp_state cty_state,  
  company_a.cmp_zip cty_zip,  
  city_a.cty_county cty_county,  
  trailerprofile.trl_avail_date [Avail Date],  
  trailerprofile.trl_status trl_status,  
  trailerprofile.trl_type1 trl_type1,      
  trailerprofile.trl_type2 trl_type2,   
  trailerprofile.trl_type3 trl_type3,   
  trailerprofile.trl_type4 trl_type4,      
  trailerprofile.trl_company trl_company,   
  trailerprofile.trl_fleet trl_fleet,   
  trailerprofile.trl_division trl_division,  
  trailerprofile.trl_terminal trl_terminal,  
  trailerprofile.trl_wash_status [Wash Status],  
  trl_last_cmd [Last Cmd],  
  trl_last_cmd_ord [Last Cmd Ord],  
  trl_last_cmd_date [Last Cmd Date],  
  trl_prior_event [Prior Event],  
  trl_prior_cmp_id [Prior Cmp ID],  
  city_pr.cty_nmstct [Prior City],   
  company_pr.cmp_state [Prior State],   
  trl_prior_region1,   
  trl_prior_region2,   
  trl_prior_region3,   
  trl_prior_region4,   
  company_pr.cmp_name [Prior Company Name],  
  trl_next_event [Next Event],  
  trl_next_cmp_id [Next Cmp ID],  
  city_n.cty_nmstct [Next City],   
  company_n.cmp_state [Next State],   
  trl_next_region1 [Next Region1],   
  trl_next_region2 [Next Region2],   
  trl_next_region3 [Next Region3],   
  trl_next_region4 [Next Region4],   
  company_n.cmp_name [Next Company Name],  
  IsNull(company_a.cmp_geoloc,'') [Location Geoloc],  
  trl_worksheet_comment1 [Comment 1],  
  trl_worksheet_comment2 [Comment 2],  
  trailerprofile.trl_gps_desc [GPS Description],  
  '' ta_quantity,    --Start of remaining required columns.  
  '' ta_type,  
  trl_avail_cmp_id,  
  trl_licnum,  
  trl_licstate,  
  trl_make,  
  trl_misc1,  
  trl_misc2,  
  trl_misc3,  
  trl_misc4,  
  trl_model,  
  trl_owner,  
  trl_serial,  
  trl_year,
  trl_number,
trl_gps_latitude,
trl_gps_longitude,
trailerprofile.trl_accessorylist,


isnull(case when  trl_misc4 like '%Empty%' then 'Vacio'
     when trl_misc4  like '%Loaded%' then 'Cargado'
	 end,'N/A') as LoadEmpt,
case when  trl_misc4  like '%:Untether%' then 'Desenganchado'
     when trl_misc4  like '%:Tether%' then 'Enganchado'
	 end as Enganche,
case when  trl_misc4  like '%Motion:Moving%' then 'Movimiento'
     when trl_misc4  like '%Motion:Start%' then 'Iniciando'
	 when trl_misc4  like '%Motion:Idle%' then 'Ocioso'
	 when trl_misc4  like '%Motion:Stop%' then 'Detenido'
	 end as movimiento,
	 substring(trl_misc4 ,charindex(']AT',trl_misc4 ,2)+3,1000) as Ubicacion,
	 replace(substring(substring(trl_misc4 ,charindex(']AT',trl_misc4 ,2)+3,1000),1,charindex('|',substring(trl_misc4 ,charindex(']AT',trl_misc4 ,2)+3,1000))),'|','') as Yard,

	 trl_gps_date as FechaGPS,



ISNULL(trl_exp1_date,'12/31/49') as trl_exp1_date,
ISNULL(trl_exp2_date,'12/31/49') as trl_exp2_date,
(select count(*) from legheader (nolock) where lgh_primary_trailer = trailerprofile.trl_number) as Planed
  FROM trailerprofile JOIN company AS company_a ON ISNULL(trailerprofile.trl_avail_cmp_id, 'UNKNOWN') = company_a.cmp_id   
                               JOIN city AS city_a ON ISNULL(trailerprofile.trl_avail_city, 0) = city_a.cty_code   
                    LEFT OUTER JOIN company AS company_pr ON trailerprofile.trl_prior_cmp_id = company_pr.cmp_id --(index=pk_id)  
                    LEFT OUTER JOIN city AS city_pr ON trailerprofile.trl_prior_city = city_pr.cty_code --(index=pk_code)  
                    LEFT OUTER JOIN company AS company_n ON trailerprofile.trl_next_cmp_id = company_n.cmp_id --(index=pk_id)  
                    LEFT OUTER JOIN city AS city_n ON trailerprofile.trl_next_city = city_n.cty_code --(index=pk_code)  


				   


   WHERE  trailerprofile.trl_status <> 'OUT'  
   






GO
