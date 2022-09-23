SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetProcedureDefn] (@sProcName varchar(255))
AS
	SET NOCOUNT ON

	SELECT c.text FROM syscomments c INNER JOIN sysobjects o ON c.id = o.id 
	WHERE o.name = @sProcName
	ORDER BY colid
GO
GRANT EXECUTE ON  [dbo].[MetricGetProcedureDefn] TO [public]
GO
