SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetProcedureColumns] (@metriccode varchar(200))
AS
	SET NOCOUNT ON

	SELECT Caption, ProcedureName FROM MetricItem WHERE MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricGetProcedureColumns] TO [public]
GO
