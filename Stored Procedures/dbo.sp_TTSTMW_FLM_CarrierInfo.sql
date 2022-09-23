SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE       Procedure [dbo].[sp_TTSTMW_FLM_CarrierInfo] (@states varchar(255))
As

--Author: Brent Keeton
--********************************************************************
--Purpose: Carrier Information is intended to be a File Maintenace
--Report on associated carriers within the company
--********************************************************************

--Revision History: 
--1. September 25, 2002 Ver 3.2 Added search carrier by state(s) feature

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

SELECT carrier.car_id AS [CarrierID], 
       carrier.car_name AS [CarrierName], 
       carrier.car_address1 AS [CarrierAddress], 
       city.cty_name AS City, 
       city.cty_state AS State, 
       carrier.car_zip AS Zip, 
       carrier.car_scac AS [SCACCode], 
       carrier.car_contact AS Contact, 
       carrier.car_phone1 AS Phone, 
       carrier.car_status AS [CurrentStatus]
FROM   carrier,city 
Where  carrier.cty_code = city.cty_code
       And
       (@states = ',,' OR CHARINDEX(',' + city.cty_state + ',', @states) > 0) 
       --<TTS!*!TMW><Begin><FeaturePack=Other>
       
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --And
       --(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + carrier.car_branch + ',', @onlyBranches) > 0) 
       --)	
       --<TTS!*!TMW><End><FeaturePack=Euro>
	












GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_FLM_CarrierInfo] TO [public]
GO
