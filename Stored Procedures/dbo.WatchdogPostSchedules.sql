SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogPostSchedules](@ScheduleID varchar(255), @ScheduledRun varchar(50), @Watchname varchar(255))
AS
	UPDATE WatchDogItem SET ScheduleID = @ScheduleID
		,ScheduledRun = @ScheduledRun
	WHERE WatchName = @WatchName
GO
GRANT EXECUTE ON  [dbo].[WatchdogPostSchedules] TO [public]
GO
