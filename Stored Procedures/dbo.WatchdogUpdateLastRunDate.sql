SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogUpdateLastRunDate] (@WatchName varchar(255) )
AS
	UPDATE WatchDogItem SET LastRunDate = GETDATE() Where WatchName = @Watchname
GO
GRANT EXECUTE ON  [dbo].[WatchdogUpdateLastRunDate] TO [public]
GO
