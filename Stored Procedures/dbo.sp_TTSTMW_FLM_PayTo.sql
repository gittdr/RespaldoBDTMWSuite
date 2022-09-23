SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE    Procedure [dbo].[sp_TTSTMW_FLM_PayTo] 
As

--Author: Brent Keeton
--********************************************************************
--Purpose: Show PayTo Information in File Maintenace Reports
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


SELECT  payto.pto_id AS PayToID, 
        payto.pto_lastfirst AS LastFirstName, 
        payto.pto_address1 AS Address, 
        city.cty_name AS City, 
        city.cty_state AS State, 
        payto.pto_zip AS Zip, 
        payto.pto_phone1 AS Phone, 
        payto.pto_status AS Status
FROM    payto INNER JOIN city ON payto.pto_city = city.cty_code

--<TTS!*!TMW><Begin><FeaturePack=Other>
       
--<TTS!*!TMW><End><FeaturePack=Other>
--<TTS!*!TMW><Begin><FeaturePack=Euro>
--Where
--(
--(@onlyBranches = 'ALL')
--Or
--(@onlyBranches <> 'ALL' And CHARINDEX(',' + bank_branch + ',', @onlyBranches) > 0) 
--)	
--<TTS!*!TMW><End><FeaturePack=Euro>












GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_FLM_PayTo] TO [public]
GO
