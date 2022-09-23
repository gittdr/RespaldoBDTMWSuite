SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogResetConsecutiveFailure] (@WatchName varchar(255) )
AS
	UPDATE WatchdogItem SET ConsecutiveFailures = 0 WHERE WatchName = @Watchname
GO
GRANT EXECUTE ON  [dbo].[WatchdogResetConsecutiveFailure] TO [public]
GO
