SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchDogAppendMostRecentResults] (@strWatchName varchar(255), @HTML text, @WatchDogSN int, @EmailAddress varchar(255) = '')
AS
	SET NOCOUNT ON
	/*
	IF EXISTS(SELECT id FROM dbo.sysobjects WHERE id = object_id(N'[tblWatchDogResults]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) 
		DELETE tblwatchdogresults WHERE ID = @WatchDogSN
		
	INSERT INTO tblwatchdogresults (ID,WatchName,LastUpdate,HTML) 
	SELECT @WatchDogSN, @strWatchName, GETDATE(), @HTML
	*/

	BEGIN TRAN
		IF EXISTS(SELECT * FROM tblwatchdogresults WHERE WatchName = @strWatchName AND EmailAddress = @EmailAddress)
		BEGIN
			UPDATE tblwatchdogresults SET LastUpdate = GETDATE(), HTML = @HTML WHERE WatchName = @strWatchName AND EmailAddress = @EmailAddress
		END
		ELSE
		BEGIN
			INSERT INTO tblwatchdogresults (ID, WatchName, LastUpdate, HTML, EmailAddress) 
			SELECT @WatchDogSN, @strWatchName, GETDATE(), @HTML, @EmailAddress
		END
	COMMIT
GO
GRANT EXECUTE ON  [dbo].[WatchDogAppendMostRecentResults] TO [public]
GO
