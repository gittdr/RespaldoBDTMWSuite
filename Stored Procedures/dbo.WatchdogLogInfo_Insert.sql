SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[WatchdogLogInfo_Insert] (@Event varchar(50), @WatchName varchar(75), @Fired_YN varchar(1), @Results_YN varchar(1), @ErrorOnRun_YN varchar(1), 
		@ErrorOnEmail_YN varchar(1), @ErrorDescription varchar(2000), @RunDuration varchar(100), @MoreInfo varchar(100)
)
AS
	INSERT INTO dbo.WatchdogLogInfo ([Event], [MachineName], [WatchName], [Fired_YN], [Results_YN], [ErrorOnRun_YN], [ErrorOnEmail_YN], 		[ErrorDescription], [RunDuration], [MoreInfo]) 
	    SELECT @Event, HOST_NAME(), @WatchName, @Fired_YN, @Results_YN, @ErrorOnRun_YN, @ErrorOnEmail_YN, @ErrorDescription, REPLACE		(@RunDuration, ',', '.'), @MoreInfo
GO
GRANT EXECUTE ON  [dbo].[WatchdogLogInfo_Insert] TO [public]
GO
