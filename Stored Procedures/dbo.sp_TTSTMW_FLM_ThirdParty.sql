SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO













CREATE    Procedure [dbo].[sp_TTSTMW_FLM_ThirdParty] (@states varchar(255))
As

--Author: Brent Keeton
--********************************************************************
--Purpose: Show Third Party Information in File Maintenace Reports
--********************************************************************

--Revision History: 
--1. September 25, 2002 Ver 3.2 Added search thirdparty agents,brokers by state
--   state(s) feature
--2. Added Branch code Ver 5.4 LBK

Declare @OnlyBranches as varchar(255)

SELECT  @states = ',' + LTRIM(RTRIM(ISNULL(@states, ''))) + ','

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

SELECT    thirdpartyprofile.tpr_name AS ThirdPartyName, 
          thirdpartyprofile.tpr_id AS ThirdPartyID, 
          thirdpartyprofile.tpr_address1 AS Address, 
          thirdpartyprofile.tpr_cty_nmstct AS CSZ, 
          thirdpartyprofile.tpr_primaryphone AS Phone, 
          thirdpartyprofile.tpr_payto AS PayTo, 
          thirdpartyprofile.tpr_salesperson1 AS PTSales,
          Cast(thirdpartyprofile.tpr_salesperson1_pct as float) AS PTSalesPercent, 
          thirdpartyprofile.tpr_salesperson2 AS PTSales2, 
          Cast(thirdpartyprofile.tpr_salesperson2_pct as float) AS PTSales2Percent, 
          thirdpartyprofile.tpr_thirdpartytype1 AS Finder, 
          thirdpartyprofile.tpr_thirdpartytype2 AS Agent, 
          thirdpartyprofile.tpr_thirdpartytype3 AS Salesman, 
          thirdpartyprofile.tpr_thirdpartytype4 AS Salesman2, 
          thirdpartyprofile.tpr_thirdpartytype5 AS Salesman3, 
          thirdpartyprofile.tpr_thirdpartytype6 AS Salesman4, 
	  Case tpr_actg_type 
            When 'A' Then
	    	'Accts Pay'
            When 'P' Then
	    	'Payroll'
            Else
            	'None'
	  End as AcctType,        
          thirdpartyprofile.tpr_active AS Active
FROM      thirdpartyprofile
Where     (@states = ',,' OR CHARINDEX(',' + tpr_state + ',', @states) > 0) 
	  --<TTS!*!TMW><Begin><FeaturePack=Other>
       
	  --<TTS!*!TMW><End><FeaturePack=Other>
	  --<TTS!*!TMW><Begin><FeaturePack=Euro>
	  --And
	  --(
	  --(@onlyBranches = 'ALL')
	  --Or
	  --(@onlyBranches <> 'ALL' And CHARINDEX(',' + thirdpartyprofile.tpr_branch + ',', @onlyBranches) > 0) 
	  --)	
	  --<TTS!*!TMW><End><FeaturePack=Euro>


ORDER BY  thirdpartyprofile.tpr_id

















GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_FLM_ThirdParty] TO [public]
GO
