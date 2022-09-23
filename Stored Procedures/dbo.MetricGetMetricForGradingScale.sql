SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetMetricForGradingScale] (@GradingScaleCode varchar(30) )
AS
	SET NOCOUNT ON

	SELECT MetricCode, Caption from metricitem WHERE GradingScaleCode = @GradingScaleCode ORDER BY Caption
GO
GRANT EXECUTE ON  [dbo].[MetricGetMetricForGradingScale] TO [public]
GO
