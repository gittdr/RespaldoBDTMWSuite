SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetGoals] (@MetricCode varchar(200)) 
AS
	SET NOCOUNT ON

	SELECT	CASE WHEN ISNULL(GoalDay, 0) = 0 THEN 0 Else GoalDay End As GoalDay, 
			ISNULL(GoalMonth, -999999) As GoalMonth, 
			GoalWeek, 
			GoalQuarter, 
			CASE WHEN ISNULL(GoalYear, 0) = 0 THEN 0 ELSE GoalYear END AS GoalYear, 
		Caption, FormatText, Cumulative, NumDigitsAfterDecimal 
	FROM metricitem WHERE metriccode = @MetricCode 
GO
GRANT EXECUTE ON  [dbo].[MetricGetGoals] TO [public]
GO
