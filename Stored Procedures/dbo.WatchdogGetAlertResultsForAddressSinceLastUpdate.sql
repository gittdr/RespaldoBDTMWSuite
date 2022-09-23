SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogGetAlertResultsForAddressSinceLastUpdate](@LogonEmail varchar(255))
AS
	SELECT MaxLastUpdate = ISNULL(CONVERT(varchar(30), GETDATE(), 121), MAX(t1.LastUpdate)), CurDate = CONVERT(varchar(30), GETDATE(), 121) 
	FROM tblWatchdogResults t1 (NOLOCK) INNER JOIN WatchdogItem t2 (NOLOCK) ON t1.WatchName = t2.WatchName
	WHERE LastUpdate > CONVERT(datetime, CONVERT(varchar(10), GETDATE(), 121)) 
		AND t1.EmailAddress LIKE '%' + @LogonEmail + '%'
		
GO
GRANT EXECUTE ON  [dbo].[WatchdogGetAlertResultsForAddressSinceLastUpdate] TO [public]
GO
