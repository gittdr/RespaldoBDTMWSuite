SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetMetricInfoForParameterEdit] (@metriccode varchar(200))
AS
	SET NOCOUNT ON

	SELECT t1.ProcedureName, DataSourceSN = ISNULL(t1.DataSourceSN, 0), DataSource=ISNULL(t2.Caption, ''), DataSourceType = ISNULL(t2.DataSourceType, '') 
	FROM MetricItem t1 (NOLOCK) LEFT JOIN rnExternalDataSource t2 (NOLOCK) ON t1.DataSourceSN = t2.sn WHERE t1.MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricGetMetricInfoForParameterEdit] TO [public]
GO
