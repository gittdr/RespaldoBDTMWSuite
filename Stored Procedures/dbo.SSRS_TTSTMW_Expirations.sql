SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create      Procedure [dbo].[SSRS_TTSTMW_Expirations]
			(	
                @ReportType varchar(50),
                @id_types varchar(200),
--                @labeldeflist varchar(200),
                @frmdt datetime,
                @tdt datetime,
                @completedstatus varchar(10),
				@asgnid varchar(50),
				@ActiveOrInactive varchar(50),
				@expirationcodes varchar(255)
			 )
As

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON


--Author: Brent Keeton
--********************************************************************
--Purpose: Expiration Report
--********************************************************************
--Revision History: 
--1. Added filter by Resource ID,Number of Days for expiration to comlete
--   Allows Filtering by All,Active,Or Inactive Resources
Declare @OnlyBranches as varchar(255)
SELECT  @completedstatus = Case @completedstatus when 'All' then 'Y,N' else @completedstatus End
SELECT  @id_types = Case @id_types when 'All' then 'DRV,CAR,TRC,TRL,CMP' else @id_types End
SELECT  @id_types = ',' + LTRIM(RTRIM(ISNULL(@id_types, ''))) + ','
--SELECT  @labeldeflist = ',' + LTRIM(RTRIM(ISNULL(@labeldeflist, ''))) + ','
SELECT  @expirationcodes = ',' + LTRIM(RTRIM(ISNULL(@expirationcodes, ''))) + ','
SELECT  @completedstatus = ',' + LTRIM(RTRIM(ISNULL(@completedstatus, ''))) + ','
SELECT  @asgnid = ',' + LTRIM(RTRIM(ISNULL(@asgnid, ''))) + ','
--<TTS!*!TMW><Begin><FeaturePack=Other>
--<TTS!*!TMW><End><FeaturePack=Other>
--<TTS!*!TMW><Begin><FeaturePack=Euro>
--Set @OnlyBranches = ',' + ISNULL( (Select usr_booking_terminal from ttsusers where usr_userid= user),'UNK') + ','
--If (Select count(*) from ttsusers where usr_userid= user and (usr_supervisor='Y' or usr_sysadmin='Y')) > 0 or user = 'dbo' 
--
--BEGIN
--
--Set @onlyBranches = 'ALL'
--
--END
--<TTS!*!TMW><End><FeaturePack=Euro>
SELECT 
       expiration.exp_key,
       expiration.exp_expirationdate As ExpirationDate,
       expiration.exp_compldate AS CompletionDate, 
       exp_idtype as IDType,     
       exp_id as ReportID,        
       Case When exp_completed = 'Y' Then
	       Cast(DateDiff(day,exp_expirationdate,exp_compldate) as Varchar (20))
       Else
	       Cast('Not Completed' as varchar(20))
       End as NoOfDays,
       CASE exp_idtype
      	 WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile where expiration.exp_id = manpowerprofile.mpp_id),'') 
      	 WHEN 'TRC'  THEN 'NA'
      	 WHEN 'TRL'  THEN 'NA'
      	 WHEN 'CAR'  THEN IsNull((Select car_name from carrier where expiration.exp_id = carrier.car_id),'') 
      	 WHEN 'CMP'  THEN IsNull((Select cmp_name from company where expiration.exp_id = company.cmp_id),'') 
       END AS ReportName,
       
      Case exp_idtype
	 WHEN 'DRV'  THEN IsNull((Select name from labelfile where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='DrvExp'),'') 
      	 WHEN 'TRC'  THEN IsNull((Select name from labelfile where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='TrcExp'),'') 
      	 WHEN 'TRL'  THEN IsNull((Select name from labelfile where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='TrlExp'),'') 
      	 WHEN 'CAR'  Then IsNull((Select name from labelfile where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='CarExp'),'') 
      	 WHEN 'CMP'  THEN IsNull((Select name from labelfile where expiration.exp_code = labelfile.abbr and labelfile.labeldefinition='CmpExp'),'') 
      END AS ExpirationName,
      --Active or Inactive Resource
       CASE exp_idtype
      	 WHEN 'DRV'  THEN Case When (Select mpp_terminationdt from manpowerprofile where expiration.exp_id = manpowerprofile.mpp_id) > GetDate() Then 'Active' Else 'Inactive' End  
      	 WHEN 'TRC'  THEN Case When (Select trc_retiredate from tractorprofile where expiration.exp_id = tractorprofile.trc_number) > GetDate() Then 'Active' Else 'Inactive' End  
      	 WHEN 'TRL'  THEN Case When (Select trl_retiredate from trailerprofile where expiration.exp_id = trailerprofile.trl_id) > GetDate() Then 'Active' Else 'Inactive' End  
      	 WHEN 'CAR'  THEN Case When (Select car_status from carrier where expiration.exp_id = carrier.car_id)= 'ACT' Then 'Active' Else 'Inactive' End  
      	 WHEN 'CMP'  Then Case When (Select cmp_active from company where expiration.exp_id = company.cmp_id) = 'Y' Then 'Active' Else 'Inactive' End  
       END AS ActiveOrInactive,
  'Driver Type1' = IsNull((Select mpp_type1 from manpowerprofile where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
  'Driver Type2' = IsNull((Select mpp_type2 from manpowerprofile where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
  'Driver Type3' = IsNull((Select mpp_type3 from manpowerprofile where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
  'Driver Type4' = IsNull((Select mpp_type4 from manpowerprofile where expiration.exp_idtype = 'DRV' and mpp_id = exp_id),'NA'), 
  'Tractor Type1' = IsNull((Select trc_type1 from tractorprofile where expiration.exp_idtype = 'TRC' and trc_number= exp_id),'NA'), 
  'Tractor Type2' = IsNull((Select trc_type2 from tractorprofile where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
  'Tractor Type3' = IsNull((Select trc_type3 from tractorprofile where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
  'Tractor Type4' = IsNull((Select trc_type4 from tractorprofile where expiration.exp_idtype = 'TRC' and trc_number = exp_id),'NA'), 
  'Trailer Type1' = IsNull((Select  trl_type1 from trailerprofile where expiration.exp_idtype = 'TRL' and trl_id= exp_id),'NA'), 
  'Trailer Type2' = IsNull((Select  trl_type2 from trailerprofile where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
  'Trailer Type3' = IsNull((Select  trl_type3 from trailerprofile where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
  'Trailer Type4' = IsNull((Select  trl_type4 from trailerprofile where expiration.exp_idtype = 'TRL' and trl_id = exp_id),'NA'), 
  'Carrier Type1' = IsNull((Select car_type1 from carrier where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA') ,
  'Carrier Type2' = IsNull((Select car_type2 from carrier where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA') ,
  'Carrier Type3' = IsNull((Select car_type3 from carrier where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA') ,
  'Carrier Type4' = IsNull((Select car_type4 from carrier where expiration.exp_idtype = 'CAR' and car_id = exp_id),'NA'),   
   --<TTS!*!TMW><Begin><FeaturePack=Other>
   ' ' as 'Branch', 
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
       exp_description As ExpirationDescription,
       --labelfile.name As ExpirationName, 
       --labelfile_1.name As PriorityStatus, 
       'PriorityStatus' = IsNull((Select name from labelfile where expiration.exp_priority = abbr And labeldefinition='ExpPriority'),'') 
       --labelfile_1.labeldefinition As PriorityCode
into   #TempExpiration
FROM   expiration 
WHERE  
 
       (@ReportType='Only Next Expirations'  
       And 
       expiration.exp_expirationdate Between @frmdt and @tdt
       And
       expiration.exp_expirationdate =
                                     (Select Min(b.exp_expirationdate) 
                                      from   expiration b 
                                      where 
       b.exp_expirationdate Between @frmdt and @tdt
                                             and
                                             expiration.exp_id = b.exp_id and expiration.exp_idtype = b.exp_idtype
                                             and 
                                             CHARINDEX(',' + b.exp_idtype + ',', @id_types) > 0 
       				             AND 
       				             (@expirationcodes = ',,' OR CHARINDEX(',' + b.exp_code + ',', @expirationcodes) > 0)
								 --(expiration.exp_code in (select * from Split(@expirationcodes,',')) )
					     AND
                                             (@completedstatus = ',,' OR CHARINDEX(',' + b.exp_completed + ',', @completedstatus) > 0)
                                             And
       					     (@asgnid = ',,' OR CHARINDEX(',' + expiration.exp_id + ',', @asgnid) > 0) 	  
                                     )
       AND
       CHARINDEX(',' + expiration.exp_idtype + ',', @id_types) > 0 
       AND 
       (@expirationcodes = ',,' OR CHARINDEX(',' + expiration.exp_code + ',', @expirationcodes) > 0)
	   --(expiration.exp_code in (select * from Split(@expirationcodes,',')) )
       AND
       (@completedstatus = ',,' OR CHARINDEX(',' + expiration.exp_completed + ',', @completedstatus) > 0)  
       And
       (@asgnid = ',,' OR CHARINDEX(',' + expiration.exp_id + ',', @asgnid) > 0) 	
       )       
Or
       (@ReportType='All Expirations'
       And 
       expiration.exp_expirationdate Between @frmdt and @tdt
       AND
       CHARINDEX(',' + expiration.exp_idtype + ',', @id_types) > 0 
       AND 
       (@expirationcodes = ',,' OR CHARINDEX(',' + expiration.exp_code + ',', @expirationcodes) > 0)
		-- (expiration.exp_code in (select * from Split(@expirationcodes,',')) )
       AND
       (@completedstatus = ',,' OR CHARINDEX(',' + expiration.exp_completed + ',', @completedstatus) > 0)   
       And
       (@asgnid = ',,' OR CHARINDEX(',' + expiration.exp_id + ',', @asgnid) > 0) 	
       )
Or 
       
       (@ReportType='All Future Expirations'
       And 
       expiration.exp_expirationdate Between @frmdt and @tdt
       AND
       CHARINDEX(',' + expiration.exp_idtype + ',', @id_types) > 0 
       AND 
       (@expirationcodes = ',,' OR CHARINDEX(',' + expiration.exp_code + ',', @expirationcodes) > 0)
       --  (expiration.exp_code in (select * from Split(@expirationcodes,',')) ) 
       AND
       (@completedstatus = ',,' OR CHARINDEX(',' + expiration.exp_completed + ',', @completedstatus) > 0)
       And
       (@asgnid = ',,' OR CHARINDEX(',' + expiration.exp_id + ',', @asgnid) > 0) 	  
       )       

select *,
		#TempExpiration.ReportId + #TempExpiration.IDType as 'Group'
from #TempExpiration
Where   ((@ActiveOrInactive = 'All')
	Or       
        (@ActiveOrInactive = 'Active' And ActiveOrInactive = 'Active')
	Or
        (@ActiveOrInactive = 'Inactive' And ActiveOrInactive = 'Inactive'))
        --<TTS!*!TMW><Begin><FeaturePack=Other>
       
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --And
       --(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + Branch + ',', @onlyBranches) > 0) 
       --)	
       --<TTS!*!TMW><End><FeaturePack=Euro>
Order by #TempExpiration.IDType,[Group],#TempExpiration.ExpirationDate,#TempExpiration.CompletionDate

	      
Drop Table #TempExpiration



GO
GRANT EXECUTE ON  [dbo].[SSRS_TTSTMW_Expirations] TO [public]
GO
