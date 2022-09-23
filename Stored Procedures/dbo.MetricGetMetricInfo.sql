SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetMetricInfo] (@metriccode varchar(200))
AS
	SET NOCOUNT ON

	SELECT sn, MetricCode, Active, Sort, Caption, CaptionFull, ProcedureName, DetailFilename,
			GoalDay = CASE WHEN ISNULL(GoalDay, 0) = 0 THEN 0 Else GoalDay End,
			GoalWeek = CASE WHEN ISNULL(GoalWeek, 0) = 0 THEN 0 Else GoalWeek End,
			GoalMonth = CASE WHEN ISNULL(GoalMonth, 0) = 0 THEN 0 Else GoalMonth End,
			GoalQuarter = CASE WHEN ISNULL(GoalQuarter, 0) = 0 THEN 0 Else GoalQuarter End,
			GoalYear = CASE WHEN ISNULL(GoalYear, 0) = 0 THEN 0 ELSE GoalYear END,
			GoalFiscalYear = CASE WHEN ISNULL(GoalFiscalYear, 0) = 0 THEN 0 ELSE GoalFiscalYear END,
            FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, Annualize,
            ThresholdAlertEmailAddress, ThresholdAlertValue, ThresholdOperator, CachedDetailYN, CacheRefreshAgeMaxMinutes,
            RefreshHistoryYN = ISNULL(RefreshHistoryYN, ''), ShowDetailByDefaultYN, GradingScaleCode, StartDate, BriefingEmailAddress, DoNotIncludeTotalForNonBusinessDayYN, IncludeOnReportCardYN,
			LastRunDate, ScheduleMetric, TimeValue, TimeType, GoalNumDigitsAfterDecimal,
			RNIDefaultCurrency = ISNULL(RNIDefaultCurrency, ''),
			RNICurrencyDateType = ISNULL(RNICurrencyDateType, ''),
			RNICurrencySymbol = ISNULL(RNICurrencySymbol, ''),
			RNIDateFormat = ISNULL(RNIDateFormat, ''),
			RNILocaleID = ISNULL(RNILocaleID, 0),
			RNIActiveLanguage = ISNULL(RNIActiveLanguage, ''),
			RNINumericFormat = ISNULL(RNINumericFormat, ''),
			LocaleName = ISNULL(LocaleName, ''),
	        ExtrapolateGradesForCumulativeFromDaily = ISNULL(ExtrapolateGradesForCumulativeFromDaily, ''),
	        ExtrapolateGradesByCountingBusinessDays = ISNULL(ExtrapolateGradesByCountingBusinessDays, ''),
	        DataSourceSN = ISNULL(DataSourceSN, 0),
			DataSourceCaption = CASE WHEN ISNULL(DataSourceSN, 0) = 0 THEN 'ResultsNow Database' ELSE (SELECT Caption FROM rnExternalDataSource WHERE sn = DataSourceSN) END,
	        Annualize
          FROM MetricItem  Left Join MetricLocale On MetricItem.RNILocaleID=MetricLocale.LocaleID
          WHERE MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricGetMetricInfo] TO [public]
GO
