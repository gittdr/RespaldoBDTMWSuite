SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogGetLastRunDate] (@WatchName varchar(255) )
AS
	SELECT ScheduledRun, 
		ScheduledRunText = CONVERT(varchar(16), ISNULL(ScheduledRun, '20491231'), 121)
	FROM WatchDogItem (NOLOCK) WHERE WatchName = @WatchName
GO
GRANT EXECUTE ON  [dbo].[WatchdogGetLastRunDate] TO [public]
GO
