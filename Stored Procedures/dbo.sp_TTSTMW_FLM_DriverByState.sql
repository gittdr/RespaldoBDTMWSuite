SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO














CREATE     Procedure [dbo].[sp_TTSTMW_FLM_DriverByState] (@state as varchar(255))
As

--Author: Brent Keeton
--********************************************************************
--Purpose: Show Driver By state Information in File Maintenace Reports
--********************************************************************

--Revision History: 
--1. Fixed the way driver names are being pulled using DriverLastName V 5.0
--2. Pulls active drivers Ver 5.0     
--3. Added Branch for Euro Feature Pack Ver 5.4

Declare @OnlyBranches varchar(255)

SELECT  @state = ',' + LTRIM(RTRIM(ISNULL(@state, ''))) + ',' 

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


SELECT  mpp_lastfirst AS DriverName, 
        manpowerprofile.mpp_id AS DriverID, 
        manpowerprofile.mpp_address1 AS Address, 
        manpowerprofile.mpp_address2 AS Address2,
        city.cty_name AS City, 
        city.cty_state AS State, 
        manpowerprofile.mpp_zip AS Zip, 
        manpowerprofile.mpp_homephone AS Phone, 
        manpowerprofile.mpp_tractornumber AS TRCNumber, 
        manpowerprofile.mpp_hiredate AS Hired, 
        manpowerprofile.mpp_dateofbirth AS Birth, 
        manpowerprofile.mpp_ssn AS SSN, 
        manpowerprofile.mpp_status AS Status
FROM    manpowerprofile LEFT JOIN city ON manpowerprofile.mpp_city = city.cty_code
WHERE   (@state = ',,' OR CHARINDEX(',' + city.cty_state + ',', @state) > 0)
        and
        mpp_terminationdt > GETDATE()  
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
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_FLM_DriverByState] TO [public]
GO
