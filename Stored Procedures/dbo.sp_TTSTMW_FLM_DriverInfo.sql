SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE    Procedure [dbo].[sp_TTSTMW_FLM_DriverInfo]
As

--Author: Brent Keeton

--********************************************************************
--Purpose: Show Driver Information in File Maintenance Reports
--********************************************************************

--Revision History: 
--1. Changed the way this report looks at Active Drivers using
--   the termination date V 5.0 LBK
--2. Changed to pull from mpp_lastfirst when pulling Driver LastName
--V 5.0 LBK
--3. Added Branch for Euro Feature Pack Ver 5.4 LBK

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

SELECT mpp_lastfirst AS DriverName, 
       manpowerprofile.mpp_id AS DriverID, 
       manpowerprofile.mpp_address1 AS Address, 
       manpowerprofile.mpp_address2 AS Address2, 
       city.cty_name AS City, 
       city.cty_state AS State, 
       city.cty_zip AS Zip, 
       manpowerprofile.mpp_homephone AS Phone, 
       manpowerprofile.mpp_tractornumber AS TRCNumber, 
       manpowerprofile.mpp_hiredate AS Hired, 
       manpowerprofile.mpp_dateofbirth AS Birth, 
       manpowerprofile.mpp_ssn AS SSN, 
       manpowerprofile.mpp_status AS Status, 
       manpowerprofile.mpp_licensenumber AS License
FROM   manpowerprofile LEFT JOIN city ON manpowerprofile.mpp_city = city.cty_code
WHERE  mpp_terminationdt > GETDATE() 

	--<TTS!*!TMW><Begin><FeaturePack=Other>
       
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--And
	--(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + manpowerprofile.mpp_branch + ',', @onlyBranches) > 0) 
	--)	
	--<TTS!*!TMW><End><FeaturePack=Euro>












GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_FLM_DriverInfo] TO [public]
GO
