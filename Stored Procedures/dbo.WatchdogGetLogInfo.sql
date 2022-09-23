SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogGetLogInfo](@WatchName varchar(255), @NUM_ROWS int)
AS
	SET ROWCOUNT @NUM_ROWS
	
	SELECT * FROM watchdogloginfo WHERE Watchname = @WatchName ORDER BY dateandtime DESC
GO
GRANT EXECUTE ON  [dbo].[WatchdogGetLogInfo] TO [public]
GO
