SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetGoalVarianceToRecentPeriod]
AS
	SET NOCOUNT ON

	SELECT 
		DailyGoalVarianceToMostRecentPeriod = (SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'DailyGoalVarianceToMostRecentPeriod'),
		WeeklyGoalVarianceToMostRecentPeriod = (SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'WeeklyGoalVarianceToMostRecentPeriod'),
		MonthlyGoalVarianceToMostRecentPeriod = (SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'MonthlyGoalVarianceToMostRecentPeriod'),
		QuarterlyGoalVarianceToMostRecentPeriod = (SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'QuarterlyGoalVarianceToMostRecentPeriod'), 
		YearlyGoalVarianceToMostRecentPeriod = (SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'YearlyGoalVarianceToMostRecentPeriod'),
		FiscalYearlyGoalVarianceToMostRecentPeriod = (SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'FiscalYearlyGoalVarianceToMostRecentPeriod')

GO
GRANT EXECUTE ON  [dbo].[MetricGetGoalVarianceToRecentPeriod] TO [public]
GO
