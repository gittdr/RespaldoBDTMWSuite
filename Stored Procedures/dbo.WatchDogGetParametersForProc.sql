SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  Procedure [dbo].[WatchDogGetParametersForProc](@WatchDogName varchar(255) = '')

As
	SET NOCOUNT ON

	Exec sp_sproc_columns @WatchDogName	


GO
GRANT EXECUTE ON  [dbo].[WatchDogGetParametersForProc] TO [public]
GO
