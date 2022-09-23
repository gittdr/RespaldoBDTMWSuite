SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetMetricInfoForSummaryFormula] (@metriccode varchar(200))
AS
	SET NOCOUNT ON

	SELECT Cumulative, FormatText,
			DoNotIncludeTotalForNonBusinessDayYN = CASE WHEN ISNULL(DoNotIncludeTotalForNonBusinessDayYN, 'N') NOT IN ('N', 'Y')
														THEN 'N'
													ELSE ISNULL(DoNotIncludeTotalForNonBusinessDayYN, 'N')
													END,
		UsesDistinctItems = CASE WHEN EXISTS(SELECT distinct t0.metriccode, t1.name
												FROM Metricitem t0 INNER JOIN sysobjects t1 ON t0.procedurename = t1.name
													INNER JOIN syscomments t2 ON t1.id = t2.id
												WHERE t0.metriccode = tOuter.MetricCode and t1.type = 'p' and t2.text like '%MetricTempIds%'
											)
									THEN 'Y' ELSE 'N' END,
		HasDistinctItems = CASE WHEN EXISTS(SELECT * FROM MetricDetailInfo t20 (NOLOCK) WHERE t20.MetricCode = @metriccode) THEN 'Y' ELSE 'N' END
	FROM metricitem tOuter
	WHERE MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricGetMetricInfoForSummaryFormula] TO [public]
GO
