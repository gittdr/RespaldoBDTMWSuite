SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vSSRSRB_Expirations]
As

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_Expirations]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View bASed on the old vttstmw_Expirations
 
 *
**************************************************************************

Sample call


SELECT * FROM [vSSRSRB_Expirations]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 * 12/03/2014 -- added TRC Owner / TRL Owner - MREED
 ***********************************************************/

SELECT exp_idtype as 'Resource Type', 
       exp_id as 'Resource ID', 
	   CASE exp_idtype
      	 	WHEN 'DRV'  THEN Case When (Select mpp_terminationdt from manpowerprofile WITH (NOLOCK) where expiration.exp_id = manpowerprofile.mpp_id) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'TRC'  THEN Case When (Select trc_retiredate from tractorprofile WITH (NOLOCK) where expiration.exp_id = tractorprofile.trc_number) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'TRL'  THEN Case When (Select trl_retiredate from trailerprofile WITH (NOLOCK) where expiration.exp_id = trailerprofile.trl_id) > GetDate() Then 'Y' Else 'N' End  
      	 	WHEN 'CAR'  THEN Case When (Select car_status from carrier WITH (NOLOCK) where expiration.exp_id = carrier.car_id)= 'ACT' Then 'Y' Else 'N' End  
      	 	WHEN 'CMP'  Then Case When (Select cmp_active from company WITH (NOLOCK) where expiration.exp_id = company.cmp_id) = 'Y' Then 'Y' Else 'N' End  
 		    END AS 'Resource ActiveYN',
       CASE exp_idtype
      	 	WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile WITH (NOLOCK) where expiration.exp_id = manpowerprofile.mpp_id),'') 
      	 	WHEN 'TRC'  THEN exp_id
      	 	WHEN 'TRL'  THEN exp_id
      	 	WHEN 'CAR'  THEN IsNull((Select car_name from carrier WITH (NOLOCK) where expiration.exp_id = carrier.car_id),'') 
      	 	WHEN 'CMP'  THEN IsNull((Select cmp_name from company WITH (NOLOCK) where expiration.exp_id = company.cmp_id),'') 
	   	    END AS 'Resource Name',
       exp_code as 'Expiration Code',
       Case exp_idtype
	 		WHEN 'DRV'  THEN IsNull((Select name from labelfile WITH (NOLOCK) where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='DrvExp'),'') 
      	 	WHEN 'TRC'  THEN IsNull((Select name from labelfile WITH (NOLOCK) where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='TrcExp'),'') 
      	 	WHEN 'TRL'  THEN IsNull((Select name from labelfile WITH (NOLOCK) where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='TrlExp'),'') 
      	 	WHEN 'CAR'  Then IsNull((Select name from labelfile WITH (NOLOCK) where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='CarExp'),'') 
      	 	WHEN 'CMP'  THEN IsNull((Select name from labelfile WITH (NOLOCK) where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='CmpExp'),'') 
      	    END AS 'Expiration Name', 
	   Case exp_idtype
			When 'DRV' Then IsNull((select mpp_teamleader from manpowerprofile WITH (NOLOCK) where expiration.exp_id = manpowerprofile.mpp_id),'')
			WHEN 'TRC' Then ''
			WHEN 'TRL'  THEN ''
			WHEN 'CAR' Then ''
			WHEN 'CMP' Then ''
			End as 'Team Leader ID',
		Case exp_idtype
			When 'DRV' Then ''
			WHEN 'TRC' Then IsNull((select trc_owner from tractorprofile WITH (NOLOCK) where expiration.exp_id = tractorprofile.trc_number),'')
			WHEN 'TRL'  THEN ''
			WHEN 'CAR' Then ''
			WHEN 'CMP' Then ''
			End as 'TRC Owner',
		Case exp_idtype
			When 'DRV' Then ''
			WHEN 'TRC' Then ''
			WHEN 'TRL'  THEN IsNull((select trl_owner from trailerprofile WITH (NOLOCK) where expiration.exp_id = trailerprofile.trL_number),'')
			WHEN 'CAR' Then ''
			WHEN 'CMP' Then ''
			End as 'TRL Owner',
	   DateDiff(day,exp_expirationdate,exp_compldate) as 'Number of Days',
       exp_lastdate as 'Last Date', 
       (Cast(Floor(Cast(exp_lastdate as float))as smalldatetime)) AS 'Last Date Only',
       exp_expirationdate as 'Expiration Date', 
       (Cast(Floor(Cast(exp_expirationdate as float))as smalldatetime)) AS 'Expiration Date Only',
       exp_routeto as 'Route To', 
       exp_completed as 'CompletedYN', 
       'Priority Status' = IsNull((Select name from labelfile WITH (NOLOCK) where expiration.exp_priority = abbr And labeldefinition='ExpPriority'),''), 
       exp_compldate as 'Completed Date', 
       (Cast(Floor(Cast(exp_compldate as float))as smalldatetime)) AS 'Completed Date Only',
       exp_updateby as 'Updated By', 
       exp_creatdate as 'Created Date', 
       (Cast(Floor(Cast(exp_creatdate as float))as smalldatetime)) AS 'Created Date Only',
       exp_updateon as 'Updated On', 
       (Cast(Floor(Cast(exp_updateon as float))as smalldatetime)) AS 'Updated Date Only',
       exp_description as 'Expiration Description', 
       exp_milestoexp as 'Miles To Expiration', 
       exp_key as 'Key', 
       (select cty_name from city WITH (NOLOCK) where cty_code = exp_city) as 'City',    
	   'DrvType1' = IsNull((Select mpp_type1 from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
       'DrvType2' = IsNull((Select mpp_type2 from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
       'DrvType3' = IsNull((Select mpp_type3 from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
       'DrvType4' = IsNull((Select mpp_type4 from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
       'Driver Division' =  IsNull((Select mpp_division from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'),
	   'Driver Terminal' =  IsNull((Select mpp_terminal from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'),  
	   'Driver Fleet' =  IsNull((Select mpp_fleet from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
       'Driver Domicile' =  IsNull((Select mpp_domicile from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
	   'Driver Company' =  IsNull((Select mpp_company from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
       'TrcType1' = IsNull((Select trc_type1 from tractorprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number= exp_id),'NA'), 
  	   'TrcType2' = IsNull((Select trc_type2 from tractorprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
  	   'TrcType3' = IsNull((Select trc_type3 from tractorprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
  	   'TrcType4' = IsNull((Select trc_type4 from tractorprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
       'Tractor Company' = IsNull((Select trc_company from tractorprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
	   'Tractor Division' = IsNull((Select trc_division from tractorprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'),
	   'Tractor Fleet' = IsNull((Select trc_fleet from tractorprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
       'Tractor Terminal' = IsNull((Select trc_terminal from tractorprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'),  
	   'TrlType1' = IsNull((Select  min(trl_type1) from trailerprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
       'TrlType2' = IsNull((Select  min(trl_type2) from trailerprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
       'TrlType3' = IsNull((Select  min(trl_type3) from trailerprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
       'TrlType4' = IsNull((Select  min(trl_type4) from trailerprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
       'Trailer Company' = IsNull((Select  min(trl_company) from trailerprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'),
	   'Trailer Fleet' = IsNull((Select  min(trl_fleet) from trailerprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
	   'Trailer Division' = IsNull((Select  min(trl_division) from trailerprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
	   'Trailer Terminal' = IsNull((Select  min(trl_terminal) from trailerprofile WITH (NOLOCK) where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'),  
	   'CarType1' = IsNull((Select car_type1 from carrier WITH (NOLOCK) where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA') ,
       'CarType2' = IsNull((Select car_type2 from carrier WITH (NOLOCK) where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA') ,
       'CarType3' = IsNull((Select car_type3 from carrier WITH (NOLOCK) where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA') ,
       'CarType4' = IsNull((Select car_type4 from carrier WITH (NOLOCK) where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA'),
	   'Driver Hire Date' = (Select Top 1 mpp_hiredate from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id), 
	   'Driver Hire Date Only' = (Select Top 1 (Cast(Floor(Cast(mpp_hiredate as float))as smalldatetime)) from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id), 
	   'Driver Seniority Date' =  (Select Top 1 (Cast(Floor(Cast(mpp_senioritydate as float))as smalldatetime)) from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),
	   'Driver Seniority Date Only' =  (Select Top 1 mpp_senioritydate from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),
	   'Driver Name' = (Select Top 1 mpp_lastfirst from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),
       'Driver Tractor' =  (Select Top 1 mpp_tractornumber from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),
       'Driver Date Of Birth' = (Select Top 1 mpp_dateofbirth from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),
       'Driver License State' = (Select Top 1 mpp_licensestate from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),
       'Driver License Number' = (Select Top 1 mpp_licensenumber from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),
       'Driver License Class' = (Select Top 1 mpp_licenseclass from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),
	   'Driver SSN' = (Select Top 1 mpp_ssn from manpowerprofile WITH (NOLOCK) where expiration.exp_idtype = 'DRV' and mpp_id = exp_id)
FROM dbo.expiration WITH (NOLOCK)

GO
GRANT DELETE ON  [dbo].[vSSRSRB_Expirations] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_Expirations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_Expirations] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_Expirations] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_Expirations] TO [public]
GO
