SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricSetGoals] 
(
	@MetricCode varchar(200),
	@Month int = NULL, --
	@Year int = NULL, -- DATEPART(year, GETDATE()),
	@DailyGoal decimal(20, 5) = NULL,
	@WeeklyGoal decimal(20, 5) = NULL,
	@MonthlyGoal decimal(20, 5) = NULL,
	@QuarterlyGoal decimal(20, 5) = NULL,
	@YearlyGoal decimal(20, 5) = NULL
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @SQL varchar(4000)
	DECLARE @MostRecentDateInHistory datetime

	-- MetricSetGoals 'DHPCT', @Month = 1, @DailyGoal = 130, @WeeklyGoal =120,  @MonthlyGoal = 140, @QuarterlylyGoal, @YearlyGoal = 

	SELECT @month = ISNULL(@month, DATEPART(month, GETDATE()))
	SELECT @year = ISNULL(@year, DATEPART(year, GETDATE()))
	SELECT @SQL = 'UPDATE MetricDetail SET PlainYear = PlainYear '
	IF @DailyGoal IS NOT NULL SELECT @SQL = @SQL + ', GoalDay = ' + CONVERT(varchar(30), @DailyGoal)
	IF @WeeklyGoal IS NOT NULL SELECT @SQL = @SQL + ', GoalWeek = ' + CONVERT(varchar(30), @WeeklyGoal)
	IF @MonthlyGoal IS NOT NULL SELECT @SQL = @SQL + ', GoalMonth = ' + CONVERT(varchar(30), @MonthlyGoal)
	IF @QuarterlyGoal IS NOT NULL SELECT @SQL = @SQL + ', GoalQuarter = ' + CONVERT(varchar(30), @QuarterlyGoal)
	IF @YearlyGoal IS NOT NULL SELECT @SQL = @SQL + ', GoalYear = ' + CONVERT(varchar(30), @YearlyGoal)
	SELECT @SQL = @SQL + 'WHERE MetricCode = ''' + @MetricCode + ''''
	SELECT @SQL = @SQL + '   AND PlainYear = ' + CONVERT(varchar(4), @Year)
	SELECT @SQL = @SQL + '   AND PlainMonth = ' + CONVERT(varchar(4), @Month)

	EXEC (@SQL)

	--SELECT @MostRecentDateInHistory = MAX(PlainDate) FROM MetricDetail WHERE metriccode = @MetricCode
	--IF @MostRecentDateInHistory IS NOT NULL 
	IF @year = DATEPART(year, GETDATE()) AND @month = DATEPART(month, GETDATE())
	BEGIN
		--select @year , DATEPART(year, GETDATE()) , @month , DATEPART(month, GETDATE())
		UPDATE MetricItem SET 
			GoalDay = @DailyGoal, 
			GoalWeek = @WeeklyGoal,
			GoalMonth = @MonthlyGoal, 
			GoalQuarter = @QuarterlyGoal, 
			GoalYear = @YearlyGoal
		FROM MetricItem  
		WHERE metriccode = @MetricCode 
		--EXEC (@SQL)
	END	
GO
GRANT EXECUTE ON  [dbo].[MetricSetGoals] TO [public]
GO
