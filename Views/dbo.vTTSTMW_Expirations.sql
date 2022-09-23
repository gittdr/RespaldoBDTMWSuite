SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE             View [dbo].[vTTSTMW_Expirations]

As

--Revision History
--1. Joined to trl_id instead of trl_number 
     --also added min to avoid subquery error
     --Ver 5.1 LBK

--2. Added Hard-Coded Field Driver,Tractor,Trailer Types (Such as mpp_terminal,trc_terminal)
     --Ver 5.4 LBK

--3. Changed datdiff to use day param instead of 'd'
--4. Added Branch Field For Euro Feature Packs V5.4

SELECT     exp_idtype as 'Resource Type', 
           exp_id as 'Resource ID', 
           
	   CASE exp_idtype
      	 	WHEN 'DRV'  THEN Case When (Select mpp_terminationdt from manpowerprofile (NOLOCK) where expiration.exp_id = manpowerprofile.mpp_id) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'TRC'  THEN Case When (Select trc_retiredate from tractorprofile (NOLOCK) where expiration.exp_id = tractorprofile.trc_number) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'TRL'  THEN Case When (Select trl_retiredate from trailerprofile (NOLOCK) where expiration.exp_id = trailerprofile.trl_id) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'CAR'  THEN Case When (Select car_status from carrier (NOLOCK) where expiration.exp_id = carrier.car_id)= 'ACT' Then 'Y' Else 'N' End  
      	 	WHEN 'CMP'  Then Case When (Select cmp_active from company (NOLOCK) where expiration.exp_id = company.cmp_id) = 'Y' Then 'Y' Else 'N' End  
       	   END AS 'Resource ActiveYN',

	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as 'Branch',
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --CASE exp_idtype
      	 	--WHEN 'DRV'  THEN (Select mpp_branch from manpowerprofile (NOLOCK) where expiration.exp_id = manpowerprofile.mpp_id) 
      	 	--WHEN 'TRC'  THEN (Select trc_branch from tractorprofile (NOLOCK) where expiration.exp_id = tractorprofile.trc_number) 
      	 	--WHEN 'TRL'  THEN (Select trl_branch from trailerprofile (NOLOCK) where expiration.exp_id = trailerprofile.trl_id) 
      	 	--WHEN 'CAR'  THEN (Select car_branch from carrier (NOLOCK) where expiration.exp_id = carrier.car_id) 
      	 	--WHEN 'CMP'  Then '' 
       	   --END AS 'Branch',	
	   --<TTS!*!TMW><End><FeaturePack=Euro>

           CASE exp_idtype
      	 	WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile (NOLOCK) where expiration.exp_id = manpowerprofile.mpp_id),'') 
      	 	WHEN 'TRC'  THEN exp_id
      	 	WHEN 'TRL'  THEN exp_id
      	 	WHEN 'CAR'  THEN IsNull((Select car_name from carrier (NOLOCK) where expiration.exp_id = carrier.car_id),'') 
      	 	WHEN 'CMP'  THEN IsNull((Select cmp_name from company (NOLOCK) where expiration.exp_id = company.cmp_id),'') 
       	   END AS 'Resource Name',
           
          exp_code as 'Expiration Code',
           
           Case exp_idtype
	 	WHEN 'DRV'  THEN IsNull((Select name from labelfile (NOLOCK) where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='DrvExp'),'') 
      	 	WHEN 'TRC'  THEN IsNull((Select name from labelfile (NOLOCK) where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='TrcExp'),'') 
      	 	WHEN 'TRL'  THEN IsNull((Select name from labelfile (NOLOCK) where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='TrlExp'),'') 
      	 	WHEN 'CAR'  Then IsNull((Select name from labelfile (NOLOCK) where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='CarExp'),'') 
      	 	WHEN 'CMP'  THEN IsNull((Select name from labelfile (NOLOCK) where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='CmpExp'),'') 
      	   END AS 'Expiration Name', 
           
	   Case exp_idtype
		When 'DRV' Then IsNull((select mpp_teamleader from manpowerprofile (NOLOCK) where expiration.exp_id = manpowerprofile.mpp_id),'')
		WHEN 'TRC' Then ''
		WHEN 'TRL'  THEN ''
		WHEN 'CAR' Then ''
		WHEN 'CMP' Then ''
	   End as 'Team Leader ID',

	   DateDiff(day,exp_expirationdate,exp_compldate) as 'Number of Days',
       	 
           exp_lastdate as 'Last Date', 
           exp_expirationdate as 'Expiration Date', 
           exp_routeto as 'Route To', 
           exp_completed as 'CompletedYN', 
           'Priority Status' = IsNull((Select name from labelfile (NOLOCK) where expiration.exp_priority = abbr And labeldefinition='ExpPriority'),''), 
           exp_compldate as 'Completed Date', 
           exp_updateby as 'Updated By', 
           exp_creatdate as 'Created Date', 
           exp_updateon as 'Updated On', 
           exp_description as 'Expiration Description', 
           exp_milestoexp as 'Miles To Expiration', 
           exp_key as 'Key', 
           (select cty_name from city (NOLOCK) where cty_code = exp_city) as 'City',    
	   'DrvType1' = IsNull((Select mpp_type1 from manpowerprofile (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
           'DrvType2' = IsNull((Select mpp_type2 from manpowerprofile (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
           'DrvType3' = IsNull((Select mpp_type3 from manpowerprofile (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
           'DrvType4' = IsNull((Select mpp_type4 from manpowerprofile (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
           'Driver Division' =  IsNull((Select mpp_division from manpowerprofile (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'),
	   'Driver Terminal' =  IsNull((Select mpp_terminal from manpowerprofile (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'),  
	   'Driver Fleet' =  IsNull((Select mpp_fleet from manpowerprofile (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
           'Driver Domicile' =  IsNull((Select mpp_domicile from manpowerprofile (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
	   'Driver Company' =  IsNull((Select mpp_company from manpowerprofile (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
           'TrcType1' = IsNull((Select trc_type1 from tractorprofile (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number= exp_id),'NA'), 
  	   'TrcType2' = IsNull((Select trc_type2 from tractorprofile (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
  	   'TrcType3' = IsNull((Select trc_type3 from tractorprofile (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
  	   'TrcType4' = IsNull((Select trc_type4 from tractorprofile (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
           'Tractor Company' = IsNull((Select trc_company from tractorprofile (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
	   'Tractor Division' = IsNull((Select trc_division from tractorprofile (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'),
	   'Tractor Fleet' = IsNull((Select trc_fleet from tractorprofile (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
           'Tractor Terminal' = IsNull((Select trc_terminal from tractorprofile (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'),  
	   'TrlType1' = IsNull((Select  min(trl_type1) from trailerprofile (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
           'TrlType2' = IsNull((Select  min(trl_type2) from trailerprofile (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
           'TrlType3' = IsNull((Select  min(trl_type3) from trailerprofile (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
           'TrlType4' = IsNull((Select  min(trl_type4) from trailerprofile (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
           'Trailer Company' = IsNull((Select  min(trl_company) from trailerprofile (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'),
	   'Trailer Fleet' = IsNull((Select  min(trl_fleet) from trailerprofile (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
	   'Trailer Division' = IsNull((Select  min(trl_division) from trailerprofile (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
	   'Trailer Terminal' = IsNull((Select  min(trl_terminal) from trailerprofile (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'),  
	   'CarType1' = IsNull((Select car_type1 from carrier (NOLOCK) where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA') ,
           'CarType2' = IsNull((Select car_type2 from carrier (NOLOCK) where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA') ,
           'CarType3' = IsNull((Select car_type3 from carrier (NOLOCK) where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA') ,
           'CarType4' = IsNull((Select car_type4 from carrier (NOLOCK) where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA')  
        
FROM         dbo.expiration (NOLOCK)













GO
GRANT SELECT ON  [dbo].[vTTSTMW_Expirations] TO [public]
GO
