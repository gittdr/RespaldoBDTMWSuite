SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO















CREATE          Procedure [dbo].[sp_TTSTMWDriverComplaints]  (@datetype as Varchar (50),
                                                   @driverid as Varchar(100),
                                    	           @complaintcode as Varchar (255),
                                    	           @frmdt datetime,
				    	           @tdt datetime
				    	           )
As

--Author: Brent Keeton
--********************************************************************
--Purpose: Driver Complaint Report
--********************************************************************

--Revision History: 
--1.  Tuesday November 12, 2002 Fixed Driver ID Search Capabilites
--mpp_id column in driver complaint table is a fixed char(8) column
--with padded spaces if string length is not 8 characters. 
--Added Right Trim to the column to take out spaces when CharIndex
--is going against the column LBK 4.2
--2. Added Branch Code Ver 5.4 LBK


Declare @OnlyBranches as varchar(255)
 
SELECT @driverid = ',' + LTRIM(RTRIM(ISNULL(@driverid, ''))) + ','
SELECT @complaintcode = ',' + LTRIM(RTRIM(ISNULL(@complaintcode, ''))) + ','


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


SELECT 'Driver' = (Select mpp_lastfirst from manpowerprofile where manpowerprofile.mpp_id = drivercomplaint.mpp_id),
        drivercomplaint.mpp_id,
	drc_dateoccured as OccuredDate,
        drc_datereceived as ReceivedDate,
       'Complaint' = (Select name from labelfile where abbr = drc_code and labeldefinition = 'DrvCmpCd'),
       'Company' = (Select cmp_name from company where cmp_id = drc_company),
	drc_description as Description,
	drc_drivercomments as Comments
FROM    drivercomplaint Inner Join manpowerprofile On manpowerprofile.mpp_id = drivercomplaint.mpp_id
WHERE  ((@DateType='Received Date' and drc_datereceived between @frmdt and @tdt )
	OR
       (@DateType='Occured Date' and  drc_dateoccured between @frmdt and @tdt )) 
       And
       --Fix 11/12/02 added RTrim Function to mpp_id column LBK
       (@driverid= ',,' OR CHARINDEX(',' + RTrim(drivercomplaint.mpp_id) + ',', @driverid) > 0) 
       And
       (@complaintcode = ',,' OR CHARINDEX(',' + drc_code + ',', @complaintcode) > 0) 
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
GRANT EXECUTE ON  [dbo].[sp_TTSTMWDriverComplaints] TO [public]
GO
