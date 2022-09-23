SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogUpdateScheduledRun] (@WatchName varchar(255), @ScheduledRun varchar(255) )
AS
	UPDATE WatchDogItem SET ScheduledRun = @ScheduledRun Where WatchName = @Watchname
GO
GRANT EXECUTE ON  [dbo].[WatchdogUpdateScheduledRun] TO [public]
GO
