SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateDetailHelper] (@MetricCode varchar(200), @DateCur varchar(100), 
						@ThisCount DECIMAL(20, 5), @ThisTotal DECIMAL(20, 5), @Result DECIMAL(20, 5), @ProcRunDuration DECIMAL(9, 3), @ParmListToRecord VARCHAR(1000), 
						@ForceOverwriteOfGoalHistory int,
						@BatchGUID varchar(36),
						@UpdateDaily varchar(100)
)
AS
	SET NOCOUNT ON

	DECLARE @DateCur_DT datetime
	DECLARE @UpdateDaily_DT datetime
	
	SELECT @DateCur_DT = @DateCur, @UpdateDaily_DT = @UpdateDaily

	UPDATE MetricDetail 
		SET DailyCount = ISNULL(@ThisCount, 0), DailyTotal = ISNULL(@ThisTotal, 0), DailyValue = ISNULL(@Result, 0), Upd_Daily = @UpdateDaily_DT,
			-- NOTE: We do not update the Goal if we are updating the record.  
			-- 		We may allow this to be updated, but this should be done from somewhere else.  Example, after an initial install, customer may want to go back and set the goals.
			RunDurationLast = @ProcRunDuration, 
			RunDurationMin = CASE WHEN @ProcRunDuration < ISNULL(RunDurationMin, 0) OR ISNULL(RunDurationMin, 0) = 0 THEN ISNULL(@ProcRunDuration, 0) ELSE ISNULL(RunDurationMin, 0) END,
			RunDurationMax = CASE WHEN @ProcRunDuration > ISNULL(RunDurationMax, 0) THEN ISNULL(@ProcRunDuration, 0) ELSE ISNULL(RunDurationMax, 0) END,
			PlainDayOfWeek = DATEPART(dw, @DateCur_DT), 
			PlainWeek = DATEPART(wk, @DateCur_DT), 
			PlainMonth = DATEPART(m, @DateCur_DT),
			PlainQuarter = DATEPART(q, @DateCur_DT),
			PlainYear = DATEPART(yyyy, @DateCur_DT),
			SQLScriptRun = @ParmListToRecord,
			GoalDay = CASE WHEN @ForceOverwriteOfGoalHistory = 0 THEN ISNULL(MetricDetail.GoalDay, MetricItem.GoalDay) ELSE MetricItem.GoalDay END,
			GoalWeek = CASE WHEN @ForceOverwriteOfGoalHistory = 0 THEN ISNULL(MetricDetail.GoalWeek, MetricItem.GoalWeek) ELSE MetricItem.GoalWeek END,
			GoalMonth = CASE WHEN @ForceOverwriteOfGoalHistory = 0 THEN ISNULL(MetricDetail.GoalMonth, MetricItem.GoalMonth) ELSE MetricItem.GoalMonth END,
			GoalQuarter = CASE WHEN @ForceOverwriteOfGoalHistory = 0 THEN ISNULL(MetricDetail.GoalQuarter, MetricItem.GoalQuarter) ELSE MetricItem.GoalQuarter END,
			GoalYear = CASE WHEN @ForceOverwriteOfGoalHistory = 0 THEN ISNULL(MetricDetail.GoalYear, MetricItem.GoalYear) ELSE MetricItem.GoalYear END
		FROM MetricDetail WITH (NOLOCK), MetricItem WITH (NOLOCK)
		WHERE MetricDetail.metriccode = Metricitem.MetricCode 
			AND MetricItem.MetricCode = @MetricCode 
			AND MetricDetail.PlainDate = @DateCur_DT 


GO
GRANT EXECUTE ON  [dbo].[MetricUpdateDetailHelper] TO [public]
GO
