SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogAddColumn](@Watchname varchar(255), @ColumnName varchar(255), @DisplayOrder int)
AS
	INSERT INTO WatchDogColumn (WatchName,ColumnName,DisplayOrder) 
	SELECT @WatchName , @ColumnName, @DisplayOrder
GO
GRANT EXECUTE ON  [dbo].[WatchdogAddColumn] TO [public]
GO
