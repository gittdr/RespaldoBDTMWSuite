SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogGetAllAlertResultsForAddressRestrict](@LogonEmail varchar(255), @DateTimeOfLastUpdate varchar(50))
AS
	SELECT t1.ID, t1.WatchName, t1.LastUpdate, t1.EmailAddress
	FROM tblWatchdogResults t1 (NOLOCK) INNER JOIN WatchdogItem t2 (NOLOCK) ON t1.WatchName = t2.WatchName
	WHERE LastUpdate > @DateTimeOfLastUpdate
		AND t1.EmailAddress LIKE '%' + @LogonEmail + '%'
	ORDER BY LastUpdate DESC
GO
GRANT EXECUTE ON  [dbo].[WatchdogGetAllAlertResultsForAddressRestrict] TO [public]
GO
