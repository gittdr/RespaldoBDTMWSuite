SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogDeleteParameters](@WatchName varchar(255))
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT * FROM WatchDogParameter WHERE Heading = 'WatchDogStoredProc' AND SubHeading = @WatchName)
		DELETE WatchDogParameter WHERE Heading = 'WatchDogStoredProc' AND SubHeading = @WatchName
		
GO
GRANT EXECUTE ON  [dbo].[WatchdogDeleteParameters] TO [public]
GO
