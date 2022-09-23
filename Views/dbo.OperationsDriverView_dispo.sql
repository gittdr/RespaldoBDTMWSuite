SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--select * from OperationsDriverView_dispo


CREATE VIEW [dbo].[OperationsDriverView_dispo] AS  
 SELECT  
 manpowerprofile.mpp_id   mpp_idref, 
 mpp_id =  mpp_id + '                |  ' + (select mpp_firstname+' '+mpp_lastname + '   |    Movil:' + isnull(mpp_currentphone,'')+ ' / Casa: '+
  isnull(mpp_homephone,'') from manpowerprofile  man(nolock) where manpowerprofile.mpp_id = man.mpp_id),
  
   company_a.cmp_id                        company_cmp_id,  
   company_a.cmp_name                      company_cmp_name,  
   city_a.cty_nmstct                       city_cty_nmstct,  
   manpowerprofile.mpp_teamleader   mpp_teamleader,  
   manpowerprofile.mpp_avl_date            mpp_avl_date, 
   			   manpowerprofile.mpp_status          mpp_status,  
   manpowerprofile.mpp_last_home           mpp_last_home,  
   manpowerprofile.mpp_want_home           mpp_want_home,  
   --manpowerprofile.mpp_fleet          mpp_fleet, 
   mpp_fleet = (select name from labelfile (nolock) where labeldefinition = 'fleet' and abbr =  manpowerprofile.mpp_fleet  ),
   manpowerprofile.mpp_division            mpp_division,  
   manpowerprofile.mpp_domicile            mpp_domicile,  
   manpowerprofile.mpp_company             mpp_company,  
   manpowerprofile.mpp_terminal            mpp_terminal,  
   manpowerprofile.mpp_type1    mpp_type1,  
   manpowerprofile.mpp_type2    mpp_type2,  

   case when manpowerprofile.mpp_type3 = 'BAJ ' and (select cty_region1 from city  where cty_code = mpp_avl_city) = 'GD' then 'BGDA'
        when manpowerprofile.mpp_type3 = 'BAJ ' and (select cty_region1 from city  where cty_code = mpp_avl_city) = 'MX' then 'BMEX'
        when manpowerprofile.mpp_type3 = 'BAJ ' and (select cty_region1 from city  where cty_code = mpp_avl_city) = 'MT' then 'BMTY'
		when manpowerprofile.mpp_type3 = 'BAJ ' and (select cty_region1 from city  where cty_code = mpp_avl_city) = 'NV' then 'BNVL'
		when manpowerprofile.mpp_type3 = 'BAJ ' and (select cty_region1 from city  where cty_code = mpp_avl_city) = 'QR' then 'BQRO'
		else    manpowerprofile.mpp_type3 end as mpp_type3,
    
   manpowerprofile.mpp_type4    mpp_type4,  
   manpowerprofile.mpp_hiredate Hired,  
   manpowerprofile.mpp_lastfirst mpp_lastfirst,  
   (select trc_gps_desc from tractorprofile (nolock) where trc_number = mpp_tractornumber) [Last GPS],  
  (select trc_gps_date from tractorprofile (nolock) where trc_number = mpp_tractornumber) [GPS Date],  
   mpp_travel_minutes [Travel Minutes],  
   mpp_mile_day7 [7 Day Mileage],  
   mpp_last_log_date [Log Date],  
   mpp_hours1 [Day 1],  
   mpp_hours2 [Day 2],  
   mpp_hours3 [Day 3],  
   convert(datetime, null) [Home Date],  
  mpp_prior_event [Prior Event],  
  mpp_prior_cmp_id [Prior Cmp ID],  
  city_pr.cty_nmstct [Prior City Name],   
  company_pr.cmp_state [Prior State],   
  mpp_prior_region1 [Prior Region 1],   
  mpp_prior_region2 [Prior Region 2],   
  mpp_prior_region3 [Prior Region 3],   
  mpp_prior_region4 [Prior Region 4],   
  company_pr.cmp_name [Prior Company Name],  
  mpp_next_event [Next Event],  
  mpp_next_cmp_id [Next Cmp ID],  
  city_n.cty_nmstct [Next City name],   
  company_n.cmp_state [Next State],   
  mpp_next_region1 [Next Region 1],   
  mpp_next_region2 [Next Region 2],   
  mpp_next_region3 [Next Region 3],   
  mpp_next_region4 [Next Region 4],  
  company_n.cmp_name [Next Company Name],  
  IsNUll(company_a.cmp_geoloc,'') [Location GeoLoc],  
  mpp_bid_next_starttime [Next Starttime],  
  mpp_senioritydate [Seniority Date],  
   manpowerprofile.mpp_hours1_week [Hrs Wk],  
  manpowerprofile.mpp_pta_date [PTA Date], --DPH PTS 32698  
   mpp_comment1 [Comment],  
   mpp_firstname,  
   mpp_lastname,  
   mpp_middlename,  
   mpp_misc1,  
   mpp_misc2,  
   mpp_misc3,  
   mpp_misc4,  
   mpp_otherid,  
   mpp_qualificationlist,  
   mpp_tractornumber,  
   mpp_zip,
   isnull(manpowerprofile.mpp_exp1_date, '12/31/49') 'mpp_exp1_date',
   isnull(manpowerprofile.mpp_exp2_date, '12/31/49') 'mpp_exp2_date',
   city_a.cty_county,
   city_a.cty_nmstct,
   city_a.cty_state,
   mpp_gps_latitude,
   mpp_gps_longitude,
   mpp_prior_region1,
   mpp_prior_region2,
   mpp_prior_region3,
   mpp_prior_region4,
  
   -------------------------------------------------------------------------------------------------------------------

      mpp_avl_date_dt = substring(convert(varchar(24),(mpp_avl_date),1),0,6)  +' '  +  substring(convert(varchar(24),(mpp_avl_date) ,114),1,5),
	  mpp_gps_date_dt = 

	     
	  (select  (case when datediff(dd,(select trc_gps_date from tractorprofile (nolock) where trc_number = mpp_tractornumber) ,getdate()) = 0  
 then  substring(convert(varchar(24),(select trc_gps_date from tractorprofile (nolock) where trc_number = mpp_tractornumber) ,114),1,5)
 else +'.'+substring(convert(varchar(24),(select trc_gps_date from tractorprofile (nolock) where trc_number = mpp_tractornumber) ,1),0,6)  +' ' 
  +  substring(convert(varchar(24),(select trc_gps_date from tractorprofile (nolock) where trc_number = mpp_tractornumber) ,114),1,5)
 end
 ))
 ,mpp_avl_city = (select cty_nmstct from city  where cty_code = mpp_avl_city) 
 ,mpp_avl_cmp_id
 ,mpp_avl_region = (select cty_region1 from city  where cty_code = mpp_avl_city) 
 





   --,(select max(ord_Hdrnumber) from orderheader (nolock) where mpp_id = ord_driver1)


    FROM manpowerprofile JOIN company AS company_a ON manpowerprofile.mpp_avl_cmp_id = company_a.cmp_id  
       JOIN city AS city_a ON manpowerprofile.mpp_avl_city = city_a.cty_code   
     LEFT OUTER JOIN company AS company_pr ON manpowerprofile.mpp_prior_cmp_id = company_pr.cmp_id --(index=pk_id)   
     LEFT OUTER JOIN city AS city_pr ON manpowerprofile.mpp_prior_city = city_pr.cty_code --(index=pk_code)   
     LEFT OUTER JOIN company AS company_n ON manpowerprofile.mpp_next_cmp_id = company_n.cmp_id --(index=pk_id)   
     LEFT OUTER JOIN city AS city_n ON manpowerprofile.mpp_next_city = city_n.cty_code --(index=pk_code)   
   WHERE manpowerprofile.mpp_id <> 'UNKNOWN'   
   AND manpowerprofile.mpp_status <> 'OUT'  




GO
GRANT SELECT ON  [dbo].[OperationsDriverView_dispo] TO [public]
GO
