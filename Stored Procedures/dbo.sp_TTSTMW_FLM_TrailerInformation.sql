SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO















CREATE      Procedure [dbo].[sp_TTSTMW_FLM_TrailerInformation]
As

--Author: Brent Keeton
--********************************************************************
--Purpose: Show Trailer Information in File Maintenace Reports
--********************************************************************

--Revision History: 
--1. Added Branch Code Ver 5.4 LBK

Declare @OnlyBranches as varchar(255)

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

SELECT    trailerprofile.trl_number AS TrailerID, 
          Cast(trl_year as varchar(6)) + ' ' + IsNull(trl_make,'') + ' ' + IsNull(trl_model,'') AS YrMkMd, 
          trailerprofile.trl_dateacquired AS Acquired, 
          trailerprofile.trl_company AS Company, 
          trailerprofile.trl_owner AS Owner, 
          trailerprofile.trl_fleet AS Fleet, 
          trailerprofile.trl_division AS Division, 
          trailerprofile.trl_terminal AS Terminal, 
          trailerprofile.trl_type1 AS Type1, 
          trailerprofile.trl_type2 AS Type2, 
          trailerprofile.trl_type3 AS Type3, 
          trailerprofile.trl_type4 AS Type4, 
          trailerprofile.trl_licstate AS LicState, 
          trailerprofile.trl_licnum AS LicNumber, 
          trailerprofile.trl_serial AS SerialNumber, 
          trailerprofile.trl_status AS Status, 
          trailerprofile.trl_startdate AS StartDt
FROM trailerprofile

	  --<TTS!*!TMW><Begin><FeaturePack=Other>
       
	  --<TTS!*!TMW><End><FeaturePack=Other>
	  --<TTS!*!TMW><Begin><FeaturePack=Euro>
	  --Where
	  --(
	  --(@onlyBranches = 'ALL')
	  --Or
	  --(@onlyBranches <> 'ALL' And CHARINDEX(',' + trailerprofile.trl_branch + ',', @onlyBranches) > 0) 
	  --)	
	  --<TTS!*!TMW><End><FeaturePack=Euro>




















GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_FLM_TrailerInformation] TO [public]
GO
