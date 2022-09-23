SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogDelete](@WatchName varchar(255))
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT * FROM WatchDogItem WHERE WatchName = @WatchName)
		DELETE WatchDogItem WHERE WatchName = @WatchName
		
GO
GRANT EXECUTE ON  [dbo].[WatchdogDelete] TO [public]
GO
