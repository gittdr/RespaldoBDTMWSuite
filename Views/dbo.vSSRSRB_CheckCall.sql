SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/**
 *
 * NAME:
 * dbo.vSSRSRB_CheckCall
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 **/

CREATE          View [dbo].[vSSRSRB_CheckCall]

As

SELECT     CheckCall.ckc_number as 'Check Call Number', 
           CheckCall.ckc_status as 'Check Call Status',  
           CheckCall.ckc_asgntype as 'Resource Type', 
           CheckCall.ckc_asgnid as 'Resource ID', 
           CASE CheckCall.ckc_asgntype
      	 	WHEN 'DRV'  THEN IsNull((Select manpowerprofile.mpp_lastfirst from manpowerprofile WITH (NOLOCK) where CheckCall.ckc_asgnid = manpowerprofile.mpp_id),'') 
      	 	WHEN 'TRC'  THEN CheckCall.ckc_asgnid
      	 	WHEN 'TRL'  THEN CheckCall.ckc_asgnid
      	 	WHEN 'CAR'  THEN IsNull((Select carrier.car_name from carrier WITH (NOLOCK) where CheckCall.ckc_asgnid = carrier.car_id),'') 
      	 	WHEN 'CMP'  THEN IsNull((Select company.cmp_name from company WITH (NOLOCK) where CheckCall.ckc_asgnid = company.cmp_id),'') 
       	   END AS 'Resource Name',
	   CASE CheckCall.ckc_asgntype
      	 	WHEN 'DRV'  THEN Case When (Select manpowerprofile.mpp_terminationdt from manpowerprofile WITH (NOLOCK) where CheckCall.ckc_asgnid = manpowerprofile.mpp_id) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'TRC'  THEN Case When (Select tractorprofile.trc_retiredate from tractorprofile WITH (NOLOCK) where CheckCall.ckc_asgnid = tractorprofile.trc_number) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'TRL'  THEN Case When (Select trailerprofile.trl_retiredate from trailerprofile WITH (NOLOCK) where CheckCall.ckc_asgnid = trailerprofile.trl_id) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'CAR'  THEN Case When (Select carrier.car_status from carrier WITH (NOLOCK) where CheckCall.ckc_asgnid = carrier.car_id)= 'ACT' Then 'Y' Else 'N' End  
      	 	WHEN 'CMP'  Then Case When (Select company.cmp_active from company WITH (NOLOCK) where CheckCall.ckc_asgnid = company.cmp_id) = 'Y' Then 'Y' Else 'N' End  
       	   END AS 'Resource ActiveYN',
           CheckCall.ckc_date as 'Check Call Date', 
           CheckCall.ckc_event as 'Event', 
           IsNull((select City.cty_name from city WITH (NOLOCK) where CheckCall.ckc_city = City.cty_code),'') as 'City', 
           IsNull((select City.cty_state from city WITH (NOLOCK) where CheckCall.ckc_city = City.cty_code),'') as 'State', 
			CheckCall.ckc_comment as 'Comment', 
           CheckCall.ckc_updatedby as 'Updated By', 
           CheckCall.ckc_updatedon as 'Updated On', 
           CheckCall.ckc_latseconds as 'Latitude Seconds',  
           CheckCall.ckc_longseconds as 'Longitude Seconds', 
           CheckCall.ckc_lghnumber as 'Leg Number', 
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
           --CheckCall.ckc_Odometer as 'Odometer', -- depends on the vendor so not made available
           'DrvType1' = IsNull((Select manpowerprofile.mpp_type1 from manpowerprofile WITH (NOLOCK) where CheckCall.ckc_asgntype = 'DRV' and manpowerprofile.mpp_id =  CheckCall.ckc_asgnid),'NA'), 
           'DrvType2' = IsNull((Select manpowerprofile.mpp_type2 from manpowerprofile WITH (NOLOCK) where CheckCall.ckc_asgntype = 'DRV' and manpowerprofile.mpp_id =  CheckCall.ckc_asgnid),'NA'), 
           'DrvType3' = IsNull((Select manpowerprofile.mpp_type3 from manpowerprofile WITH (NOLOCK) where CheckCall.ckc_asgntype = 'DRV' and manpowerprofile.mpp_id =  CheckCall.ckc_asgnid),'NA'), 
           'DrvType4' = IsNull((Select manpowerprofile.mpp_type4 from manpowerprofile WITH (NOLOCK) where CheckCall.ckc_asgntype = 'DRV' and manpowerprofile.mpp_id =  CheckCall.ckc_asgnid),'NA'), 
           'CarType1' = IsNull((Select carrier.car_type1 from carrier WITH (NOLOCK) where CheckCall.ckc_asgntype = 'CAR' and carrier.car_id =  CheckCall.ckc_asgnid),'NA') ,
           'CarType2' = IsNull((Select carrier.car_type2 from carrier WITH (NOLOCK) where CheckCall.ckc_asgntype = 'CAR' and carrier.car_id =  CheckCall.ckc_asgnid),'NA') ,
           'CarType3' = IsNull((Select carrier.car_type3 from carrier WITH (NOLOCK) where CheckCall.ckc_asgntype = 'CAR' and carrier.car_id =  CheckCall.ckc_asgnid),'NA') ,
           'CarType4' = IsNull((Select carrier.car_type4 from carrier WITH (NOLOCK) where CheckCall.ckc_asgntype = 'CAR' and carrier.car_id =  CheckCall.ckc_asgnid),'NA'),
		   CheckCall.ckc_home as Terminal,
		   [Latitude] = ((select cty_latitude from city WITH (NOLOCK) where city.cty_code = ckc_city) + ckc_latseconds), 
		   [Longitude] = ((select cty_longitude from city WITH (NOLOCK) where city.cty_code = ckc_city) + ckc_longseconds)     
       
       

FROM         dbo.checkcall WITH (NOLOCK)


GO
GRANT DELETE ON  [dbo].[vSSRSRB_CheckCall] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_CheckCall] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_CheckCall] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_CheckCall] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_CheckCall] TO [public]
GO
