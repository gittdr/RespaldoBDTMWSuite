SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricSP_sproc_columns] (@ProcedureName varchar(255) )
AS
	SET NOCOUNT ON
	EXEC sp_sproc_columns @ProcedureName
GO
GRANT EXECUTE ON  [dbo].[MetricSP_sproc_columns] TO [public]
GO
