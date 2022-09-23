SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogGetAlertsForAddress](@PassedEmail varchar(255))
AS
	SELECT CASE WHEN EXISTS(SELECT sn FROM watchdogitem WHERE emailaddress LIKE '%' + @PassedEmail + '%') THEN 1 ELSE 0 END
GO
GRANT EXECUTE ON  [dbo].[WatchdogGetAlertsForAddress] TO [public]
GO
