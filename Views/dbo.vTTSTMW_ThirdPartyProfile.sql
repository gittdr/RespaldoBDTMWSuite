SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO







CREATE      View [dbo].[vTTSTMW_ThirdPartyProfile] 

As

--Revision History
--1. Added European/Penske specific fields Ver 5.43 LBK

SELECT     tpr_id as 'Third Party ID', 
           tpr_active as 'ActiveYN', 
           tpr_name as 'Third Party Name', 
           tpr_payto as 'Pay To', 
           tpr_address1 as 'Address1', 
           tpr_address2 as 'Address2', 
           (select cty_name from city (NOLOCK) where cty_code = tpr_city) as 'City',
           tpr_cty_nmstct as 'City Name State', 
           tpr_state as 'State', 
           tpr_region1 as 'Region1', 
           tpr_region2 as 'Region2', 
           tpr_region3 as 'Region3', 
           tpr_region4 as 'Region4', 
           tpr_zip as 'Zip Code', 
           tpr_primaryphone as 'Primary Phone Number',  
           tpr_secondaryphone as 'Secondary Phone Number', 
           tpr_faxphone as 'Fax Phone Number', 
           tpr_salesperson1 as 'Sales Person1', 
           tpr_salesperson1_pct as 'Sales Person1 Pct', 
           tpr_salesperson2 as 'Sales Person2', 
           tpr_salesperson2_pct as 'Sales Person2 Pct', 
           tpr_thirdpartytype1 as 'Third Party Type1', 
           tpr_thirdpartytype2 as 'Third Party Type2', 
           tpr_thirdpartytype3 as 'Third Party Type3', 
           tpr_thirdpartytype4 as 'Third Party Type4', 
           tpr_thirdpartytype5 as 'Third Party Type5', 
           tpr_thirdpartytype6 as 'Third Party Type6', 
           tpr_artype as 'Accounts Receivable Type', 
           tpr_invoicetype as 'Invoice Type', 
           tpr_revtype1 as 'RevType1', 
           'RevType1 Name' = IsNull((select name from labelfile (NoLock) where labelfile.abbr = tpr_revtype1 and labeldefinition = 'RevType1'),''),
	   tpr_revtype2 as 'RevType2', 
           'RevType2 Name' = IsNull((select name from labelfile (NoLock) where labelfile.abbr = tpr_revtype2 and labeldefinition = 'RevType2'),''),
	   tpr_revtype3 as 'RevType3', 
            'RevType3 Name' = IsNull((select name from labelfile (NoLock) where labelfile.abbr = tpr_revtype3 and labeldefinition = 'RevType3'),''),
           tpr_revtype4 as 'RevType4', 
	   'RevType4 Name' = IsNull((select name from labelfile (NoLock) where labelfile.abbr = tpr_revtype4 and labeldefinition = 'RevType4'),'') ,          
	   tpr_misc1 as 'Misc1',  
           tpr_misc2 as 'Misc2', 
           tpr_misc3 as 'Misc3', 
           tpr_misc4 as 'Misc4', 
           tpr_createdate as 'Created Date',
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as Branch,
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --tpr_branch as Branch,		
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	   
	   
	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Country], 
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --tpr_country as [Country], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Currency], 
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --tpr_currency as [Currency], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [GP Class], 
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --tpr_gp_class as [GP Class],
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Quick Entry],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --tpr_quickentry as [Quick Entry], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Service Location]
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --tpr_service_location as [Service Location]
	   --<TTS!*!TMW><End><FeaturePack=Euro> 	

from thirdpartyprofile (NOLOCK) 







GO
GRANT SELECT ON  [dbo].[vTTSTMW_ThirdPartyProfile] TO [public]
GO
