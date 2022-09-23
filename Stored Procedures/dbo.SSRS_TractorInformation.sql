SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE      Procedure [dbo].[SSRS_TractorInformation]  
  
As  
  
  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET NOCOUNT ON  
  
--Author: Brent Keeton  
--********************************************************************  
--Purpose: Show tractor Information in File Maintenace Reports  
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
  
  
SELECT     tractorprofile.trc_number AS TractorID,   
           Cast(trc_year as varchar(6)) + ' ' + IsNull(trc_make,'') + ' ' + IsNull(trc_model,'') AS YrMkMd,   
           tractorprofile.trc_owner AS Owner,   
           tractorprofile.trc_driver AS Drv1,   
           tractorprofile.trc_driver2 AS Drv2,   
           tractorprofile.trc_startdate AS StartDt,   
           tractorprofile.trc_commethod AS CommType,   
           tractorprofile.trc_company AS Company,   
           tractorprofile.trc_division AS Division,   
           tractorprofile.trc_fleet AS Fleet,   
           tractorprofile.trc_terminal AS Terminal,   
           tractorprofile.trc_type1 AS Type1,   
           tractorprofile.trc_type2 AS Type2,   
           tractorprofile.trc_type3 AS Type3,   
           tractorprofile.trc_type4 AS Type4,   
           tractorprofile.trc_serial AS SerialNumber,   
           tractorprofile.trc_licstate AS LicState,   
           tractorprofile.trc_licnum AS LicNumber,   
           tractorprofile.trc_status AS Status  
FROM       tractorprofile  
WHERE      tractorprofile.trc_status<>'OUT'  
  
    --<TTS!*!TMW><Begin><FeaturePack=Other>  
         
    --<TTS!*!TMW><End><FeaturePack=Other>  
    --<TTS!*!TMW><Begin><FeaturePack=Euro>  
    --And  
    --(  
    --(@onlyBranches = 'ALL')  
    --Or  
    --(@onlyBranches <> 'ALL' And CHARINDEX(',' + trc_branch + ',', @onlyBranches) > 0)   
    --)   
    --<TTS!*!TMW><End><FeaturePack=Euro>  
  
  
GO
GRANT EXECUTE ON  [dbo].[SSRS_TractorInformation] TO [public]
GO
