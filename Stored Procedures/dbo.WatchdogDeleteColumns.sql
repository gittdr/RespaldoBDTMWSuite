SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogDeleteColumns](@WatchName varchar(255))
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT * FROM WatchdogColumn WHERE WatchName = @WatchName)
		DELETE WatchdogColumn WHERE WatchName = @WatchName
		
GO
GRANT EXECUTE ON  [dbo].[WatchdogDeleteColumns] TO [public]
GO
