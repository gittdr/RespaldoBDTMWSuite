SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogShowHTMLResults](@LoggedId int, @LogonEmail varchar(255))
AS
	SELECT Html FROM tblWatchdogResults WHERE id = @LoggedId AND emailaddress = @LogonEmail
GO
GRANT EXECUTE ON  [dbo].[WatchdogShowHTMLResults] TO [public]
GO
