SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertIntoMetricDetail] (
	@MetricCode varchar(200), @DateCur varchar(100), @EndDateToUseForCurrent varchar(100), @DailyCount decimal(20, 5), @DailyTotal decimal(20, 5), @DailyValue decimal(20, 5), 
	@ProcRunDuration decimal(9, 3), @SQLScriptRun varchar(1000)
)
AS
	DECLARE @DateCur_DT datetime, @EndDateToUseForCurrent_DT datetime
	SELECT @DateCur_DT = @DateCur, @EndDateToUseForCurrent_DT = @EndDateToUseForCurrent
	
	INSERT INTO MetricDetail (
			MetricCode, PlainDate, Upd_Daily, DailyCount, DailyTotal, DailyValue, RunDurationLast, RunDurationMin, RunDurationMax, 
			PlainDayOfWeek, PlainWeek, PlainMonth, PlainQuarter, PlainYear, GoalDay, GoalWeek, GoalMonth, GoalQuarter, GoalYear, SQLScriptRun
		) 
        SELECT @MetricCode, @DateCur, @EndDateToUseForCurrent, @DailyCount, @DailyTotal, @DailyValue, 
				@ProcRunDuration, @ProcRunDuration, @ProcRunDuration, 
				DATEPART(dw, @DateCur), DATEPART(wk, @DateCur), DATEPART(m, @DateCur), DATEPART(q, @DateCur), DATEPART(yyyy, @DateCur), 
				GoalDay, GoalWeek, GoalMonth, GoalQuarter, GoalYear, @SQLScriptRun
		FROM MetricItem WITH (NOLOCK) 
		WHERE MetricCode = @MetricCode

	UPDATE MetricItem SET LastRunDate = GETDATE() WHERE MetricCode = @MetricCode

GO
GRANT EXECUTE ON  [dbo].[MetricInsertIntoMetricDetail] TO [public]
GO
