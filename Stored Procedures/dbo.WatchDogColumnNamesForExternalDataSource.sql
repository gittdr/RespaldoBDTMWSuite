SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchDogColumnNamesForExternalDataSource](@WatchName varchar(255))
AS
	SET NOCOUNT ON

	SELECT * FROM watchdogcolumn WHERE watchname = @Watchname ORDER BY DisplayOrder
GO
GRANT EXECUTE ON  [dbo].[WatchDogColumnNamesForExternalDataSource] TO [public]
GO
