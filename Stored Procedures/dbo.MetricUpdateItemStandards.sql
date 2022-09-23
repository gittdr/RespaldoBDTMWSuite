SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateItemStandards] 
(
	@MetricCode varchar(200),
	@GoalDay varchar(100),
	@GoalWeek varchar(100),
	@GoalMonth varchar(100),
	@GoalQuarter varchar(100),
	@GoalYear varchar(100),
	@GoalFiscalYear varchar(100),
	@PlusDeltaIsGood int,
	@GoalNumDigitsAfterDecimal int,
	@AlertEmailAddress varchar(255),
	@AlertValue  varchar(100),
	@AlertOperator varchar(2),
	@IncludeOnReportCardYN varchar(1),
	@GradingScaleCode varchar(30),
	@ExtrapolateGradesForCumulativeFromDaily varchar(1),
	@ExtrapolateGradesByCountingBusinessDays varchar(1)
)
AS
	SET NOCOUNT ON

	UPDATE MetricItem SET
		GoalDay = CASE WHEN @GoalDay = 'NULL' THEN NULL ELSE @GoalDay END,
		GoalWeek = CASE WHEN @GoalWeek = 'NULL' THEN NULL ELSE @GoalWeek END,
		GoalMonth = CASE WHEN @GoalMonth = 'NULL' THEN NULL ELSE @GoalMonth END,
		GoalQuarter = CASE WHEN @GoalQuarter = 'NULL' THEN NULL ELSE @GoalQuarter END,
		GoalYear =		CASE WHEN @GoalYear = 'NULL' THEN NULL ELSE @GoalYear END,
		GoalFiscalYear = CASE WHEN @GoalFiscalYear = 'NULL' THEN NULL ELSE @GoalFiscalYear END,
		PlusDeltaIsGood = @PlusDeltaIsGood,
		GoalNumDigitsAfterDecimal = @GoalNumDigitsAfterDecimal,
		ThresholdAlertEmailAddress = @AlertEmailAddress,
		ThresholdAlertValue = CASE WHEN @AlertValue = 'NULL' THEN NULL ELSE @AlertValue END,
		ThresholdOperator = @AlertOperator,
		IncludeOnReportCardYN = @IncludeOnReportCardYN,
		GradingScaleCode = @GradingScaleCode,
		ExtrapolateGradesForCumulativeFromDaily = @ExtrapolateGradesForCumulativeFromDaily,
		ExtrapolateGradesByCountingBusinessDays = @ExtrapolateGradesByCountingBusinessDays
	WHERE MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateItemStandards] TO [public]
GO
