SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE          View [dbo].[vTTSTMW_CheckCall]

As

SELECT     CheckCall.ckc_number as 'Check Call Number', 
           CheckCall.ckc_status as 'Check Call Status',  
           CheckCall.ckc_asgntype as 'Resource Type', 
           CheckCall.ckc_asgnid as 'Resource ID', 
           CASE CheckCall.ckc_asgntype
      	 	WHEN 'DRV'  THEN IsNull((Select manpowerprofile.mpp_lastfirst from manpowerprofile (NOLOCK) where CheckCall.ckc_asgnid = manpowerprofile.mpp_id),'') 
      	 	WHEN 'TRC'  THEN CheckCall.ckc_asgnid
      	 	WHEN 'TRL'  THEN CheckCall.ckc_asgnid
      	 	WHEN 'CAR'  THEN IsNull((Select carrier.car_name from carrier (NOLOCK) where CheckCall.ckc_asgnid = carrier.car_id),'') 
      	 	WHEN 'CMP'  THEN IsNull((Select company.cmp_name from company (NOLOCK) where CheckCall.ckc_asgnid = company.cmp_id),'') 
       	   END AS 'Resource Name',
	   CASE CheckCall.ckc_asgntype
      	 	WHEN 'DRV'  THEN Case When (Select manpowerprofile.mpp_terminationdt from manpowerprofile (NOLOCK) where CheckCall.ckc_asgnid = manpowerprofile.mpp_id) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'TRC'  THEN Case When (Select tractorprofile.trc_retiredate from tractorprofile (NOLOCK) where CheckCall.ckc_asgnid = tractorprofile.trc_number) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'TRL'  THEN Case When (Select trailerprofile.trl_retiredate from trailerprofile (NOLOCK) where CheckCall.ckc_asgnid = trailerprofile.trl_id) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'CAR'  THEN Case When (Select carrier.car_status from carrier (NOLOCK) where CheckCall.ckc_asgnid = carrier.car_id)= 'ACT' Then 'Y' Else 'N' End  
      	 	WHEN 'CMP'  Then Case When (Select company.cmp_active from company (NOLOCK) where CheckCall.ckc_asgnid = company.cmp_id) = 'Y' Then 'Y' Else 'N' End  
       	   END AS 'Resource ActiveYN',
           CheckCall.ckc_date as 'Check Call Date', 
           CheckCall.ckc_event as 'Event', 
           IsNull((select City.cty_name from city (NOLOCK) where CheckCall.ckc_city = City.cty_code),'') as 'City', 
           IsNull((select City.cty_state from city (NOLOCK) where CheckCall.ckc_city = City.cty_code),'') as 'State', 
	   CheckCall.ckc_comment as 'Comment', 
           CheckCall.ckc_updatedby as 'Updated By', 
           CheckCall.ckc_updatedon as 'Updated On', 
           CheckCall.ckc_latseconds as 'Latitude Seconds',  
           CheckCall.ckc_longseconds as 'Longitude Seconds', 
           CheckCall.ckc_lghnumber as 'LegHeader Number', 
           CheckCall.ckc_tractor as 'Tractor', 
           CheckCall.ckc_extsensoralarm as 'Ext Sense Or Alarm', 
           CheckCall.ckc_vehicleignition as 'Vehicle Ignition', 
           CheckCall.ckc_milesfrom as 'Miles From', 
           CheckCall.ckc_directionfrom as 'Direction From', 
           CheckCall.ckc_validity as 'Validity', 
           CheckCall.ckc_mtavailable as 'MT Available', 
           CheckCall.ckc_minutes as 'Minutes', 
           CheckCall.ckc_mileage as 'Mileage', 
           CheckCall.ckc_home as 'Home',  
           CheckCall.ckc_commentlarge as 'Comment Large', 
           CheckCall.ckc_minutes_to_final as 'Minutes To Final', 
           CheckCall.ckc_miles_to_final as 'Miles To Final', 
           --Deleted as of 5/6/2003 Ver 4.98(Can be readded in 2003 ver)
           --ckc_Odometer as 'Odometer',
           'DrvType1' = IsNull((Select manpowerprofile.mpp_type1 from manpowerprofile (NOLOCK) where CheckCall.ckc_asgntype = 'DRV' and manpowerprofile.mpp_id =  CheckCall.ckc_asgnid),'NA'), 
           'DrvType2' = IsNull((Select manpowerprofile.mpp_type2 from manpowerprofile (NOLOCK) where CheckCall.ckc_asgntype = 'DRV' and manpowerprofile.mpp_id =  CheckCall.ckc_asgnid),'NA'), 
           'DrvType3' = IsNull((Select manpowerprofile.mpp_type3 from manpowerprofile (NOLOCK) where CheckCall.ckc_asgntype = 'DRV' and manpowerprofile.mpp_id =  CheckCall.ckc_asgnid),'NA'), 
           'DrvType4' = IsNull((Select manpowerprofile.mpp_type4 from manpowerprofile (NOLOCK) where CheckCall.ckc_asgntype = 'DRV' and manpowerprofile.mpp_id =  CheckCall.ckc_asgnid),'NA'), 
           'CarType1' = IsNull((Select carrier.car_type1 from carrier (NOLOCK) where CheckCall.ckc_asgntype = 'CAR' and carrier.car_id =  CheckCall.ckc_asgnid),'NA') ,
           'CarType2' = IsNull((Select carrier.car_type2 from carrier (NOLOCK) where CheckCall.ckc_asgntype = 'CAR' and carrier.car_id =  CheckCall.ckc_asgnid),'NA') ,
           'CarType3' = IsNull((Select carrier.car_type3 from carrier (NOLOCK) where CheckCall.ckc_asgntype = 'CAR' and carrier.car_id =  CheckCall.ckc_asgnid),'NA') ,
           'CarType4' = IsNull((Select carrier.car_type4 from carrier (NOLOCK) where CheckCall.ckc_asgntype = 'CAR' and carrier.car_id =  CheckCall.ckc_asgnid),'NA'),
	   CheckCall.ckc_home as Terminal,
	   [Latitude] = ((select cty_latitude from city (NOLOCK) where city.cty_code = ckc_city) + ckc_latseconds), 
	   [Longitude] = ((select cty_longitude from city (NOLOCK) where city.cty_code = ckc_city) + ckc_longseconds) 
            
       
       
       
       
       
       

FROM         dbo.checkcall (NOLOCK)












GO
GRANT SELECT ON  [dbo].[vTTSTMW_CheckCall] TO [public]
GO
