SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
















CREATE      Procedure [dbo].[sp_TTSTMW_TractorTrailerPermit] (@trailer varchar (10),@tractor varchar (10))
As

--Author: Brent Keeton
--********************************************************************
--Purpose: Show tractor Information in File Maintenace Reports
--********************************************************************

--Revision History: 
--1. March 11, 2003 V 5.0 Fixed Concatenation of Plate Number and State,
--   Separated these into two separate columns
--2. Added Branch Code Ver 5.4 LBK

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

SELECT     tractorprofile.trc_number AS Resource, 
           Cast(trc_year as varchar(6)) + ' ' + IsNull(trc_make,'') AS YrMk, 
           IsNull(trc_model,'') AS Model,
	   tractorprofile.trc_serial AS SerialNumber, 
           IsNull(tractorprofile.trc_licnum,'') AS PlateNumber, 
	   IsNull(tractorprofile.trc_licstate,'') As LicState,
           tractorprofile.trc_tareweight AS Weight,
	   'Tractor: ' as ResourceType
FROM       tractorprofile
Where      tractorprofile.trc_number = @tractor
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

Union

SELECT     trailerprofile.trl_number AS Resource, 
           Cast(trl_year as varchar(6)) + ' ' + IsNull(trl_make,'') AS YrMk, 
           IsNull(trl_model,'') AS Model,
	   trailerprofile.trl_serial AS SerialNumber, 
           IsNull(trailerprofile.trl_licnum,'') AS PlateNumber, 
	   IsNull(trailerprofile.trl_licstate,'') as LicState,
           trailerprofile.trl_tareweight AS Weight,
	   'Trailer: ' as ResourceType
FROM       trailerprofile
Where      trailerprofile.trl_number = @trailer
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
       
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --And
	   --(
	   --(@onlyBranches = 'ALL')
	   --Or
	   --(@onlyBranches <> 'ALL' And CHARINDEX(',' + trailerprofile.trl_branch + ',', @onlyBranches) > 0) 
	   --)	
	   --<TTS!*!TMW><End><FeaturePack=Euro>

















GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_TractorTrailerPermit] TO [public]
GO
