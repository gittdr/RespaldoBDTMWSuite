SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogUpdateConsecutiveFailure] (@WatchName varchar(255) )
AS
	UPDATE WatchdogItem SET ConsecutiveFailures 
								= ISNULL(ConsecutiveFailures, 0) + 1, ActiveFlag = CASE WHEN ISNULL(ConsecutiveFailures, 0) + 1 >= ISNULL(ConsecutiveFailuresLimit, 0) THEN 0 ELSE ActiveFlag END 
	WHERE WatchName = @Watchname
GO
GRANT EXECUTE ON  [dbo].[WatchdogUpdateConsecutiveFailure] TO [public]
GO
