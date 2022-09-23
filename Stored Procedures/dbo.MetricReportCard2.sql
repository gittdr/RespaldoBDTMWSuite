SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--MetricReportCard2 'Tr_RevPerMileBySegment', 'month', 12
CREATE PROCEDURE [dbo].[MetricReportCard2] 
(
	@MetricCode VARCHAR(200), 
	@TimeFrame VARCHAR(7) = 'week', 	-- wd (weekday => This is special), wk (week), m (month), q (quarter), yyyy (year), or day (any day, most likely not used), 	
										-- (year, yy, yyyy), (quarter, qq, q), (Month, mm, m), (Day dd, d), (Week wk, ww),
	@TimeUnits int = 3,			-- Number of time units back.
	@UseGoalHistory int = NULL	-- This overides the database setting.
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON
	-- Example: MetricReportCard2 'revpermile', 'week', 5
	-- Status of Grade= A, B, C, D, and F.  "*" means a goal not provided.  "-" means no data available.
/*
DECLARE	@MetricCode VARCHAR(200), 
	@TimeFrame VARCHAR(7) , 	-- wd (weekday => This is special), wk (week), m (month), q (quarter), yyyy (year), or day (any day, most likely not used), 	
										-- (year, yy, yyyy), (quarter, qq, q), (Month, mm, m), (Day dd, d), (Week wk, ww),
	@TimeUnits int ,			-- Number of time units back.
	@UseGoalHistory int -- This overides the database setting.
*/

	DECLARE @FormatText VARCHAR(12), @Date datetime, @DateCur datetime, @PlusDelta decimal(20, 5), @Goal decimal(20, 5), @ThisAve decimal(20, 5), @Count decimal(20, 5), @Total decimal(20, 5)
	DECLARE @MetricValue decimal(20, 5), @Grade varchar(4), @FirstDate datetime, @LastDateInPeriod datetime
	DECLARE @MetricCodeForGradingScale varchar(200), @GradingScaleCode VARCHAR(200)  -- @MetricCodeForGradingScale will be OBSOLETE, @GradingScaleCaption is temporary, @GradingScaleSN should be used.
	DECLARE @GOAL_NOT_SET_INDICATOR varchar(3), @NO_DATA_INDICATOR varchar(3), @UNKNOWN_GRADE varchar(3)
	DECLARE @RunPreviousDayYN varchar(1)
	DECLARE @MetricGradingScaleDetail TABLE (Grade varchar(4), MinValue decimal(20, 5), FormatText varchar(12))
	DECLARE @Cumulative int, @ExtrapolateGradesForCumulativeFromDaily VARCHAR(1), @ExtrapolateGradesByCountingBusinessDays varchar(1), @NumberOfDaysInTimeFrame int, @FirstDateInPeriod datetime, @MinValue decimal(20, 5), @MaxValue decimal(20, 5), @Range varchar(100)
	DECLARE @WeekAdjust int
	DECLARE @Style varchar(10)

	-- Create table to store values.
	-- Results will be returned in reverse order, so that the oldest is the first on the list.  If no data is availabe, receive a blank or NA grade (not applicable).
	CREATE TABLE #temp (sn int identity, datecur datetime, grade varchar(4), MetricValue decimal(20, 5), goal decimal(20, 5), ThisAve decimal(20, 5), ThisCount decimal(20, 5), ThisTotal decimal(20, 5), 
					MinValue decimal(20, 5), MaxValue decimal(20, 5), Range varchar(100), FirstDate datetime, LastDate datetime )

	SET NOCOUNT ON

	SELECT @Style = CASE WHEN EXISTS(SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'UseAlternateTimeFramesYN' AND SettingValue = 'Y')
						THEN 'Alt01' ELSE '' END

	-- EXEC MetricGetParameterText @RunPreviousDayYN OUTPUT, 'Y', 'Config', 'All', 'Process_And_Show_For_Previous_Day_YN'

	-- Parameters
	SELECT @GOAL_NOT_SET_INDICATOR = '*', @NO_DATA_INDICATOR = '-', @UNKNOWN_GRADE = '?'

	--IF (@Date IS NULL) SELECT @Date = CONVERT(datetime, CONVERT(varchar(100), GETDATE(), 101))
	If (@Date IS NULL) SELECT @Date = Max(Plaindate) from MetricDetail (NOLOCK) where MetricCode = @MetricCode
	If (@Date IS Null) Select @Date = Max(Plaindate) from MetricDetail (Nolock)
	--IF (@RunPreviousDayYN = 'Y') SELECT @date = DATEADD(day, -1, @date)
	SELECT @Date = DATEADD(day, -ISNULL((SELECT cast(SettingValue as int) FROM MetricGeneralSettings WITH (NOLOCK) WHERE SettingName = 'MetricProcessingDaysToOffset'), 0), @Date)
	--select -ISNULL((SELECT cast(SettingValue as int) FROM MetricGeneralSettings WITH (NOLOCK) WHERE SettingName = 'MetricProcessingDaysToOffset'), 0)

	-- Get @TimeFrames to one value.
	IF (@TimeFrame = 'year' OR @TimeFrame = 'yy' OR @TimeFrame = 'yyyy') 
	BEGIN
		SELECT @TimeFrame = 'year'
		IF @Style = ''
		BEGIN
			SELECT @FirstDate = DATEADD(yyyy, -@TimeUnits, @Date)  -- First, go back X years.
			SELECT @FirstDate = CONVERT(varchar(4), DATEPART(year, @FirstDate)) + '0101'  -- Then, take the first date of that time frame.
			SELECT @Date = DATEADD(day, -1, DATEADD(year, @TimeUnits, @FirstDate))
		END
		ELSE
		BEGIN
			SELECT @FirstDate = dbo.fnc_Metric_DateAdd('Alt01', 'yyyy', -@TimeUnits, @Date) -- first, go back X years.
			SELECT @FirstDate = dbo.fnc_Metric_FirstDateOfTimeFrame (@Style, @TimeFrame, @FirstDate) -- get the first data of that time frame.
			SELECT @Date = DATEADD(day, -1, dbo.fnc_Metric_DateAdd(@Style, 'year', @TimeUnits, @FirstDate))  -- Last day of that time frame.
		END
	END
	ELSE IF (@TimeFrame = 'quarter' OR @TimeFrame = 'qq' OR @TimeFrame = 'q')
	BEGIN
		SELECT @TimeFrame = 'quarter'
		IF @Style = ''
		BEGIN
			SELECT @FirstDate = DATEADD(quarter, -@TimeUnits, @Date)
			SELECT @FirstDate = CONVERT(varchar(4), DATEPART(year, @FirstDate)) + RIGHT('0' + CONVERT(varchar(2), 1+3*(DATEPART(quarter, @FirstDate)-1)), 2) + '01'
			SELECT @Date = DATEADD(day, -1, DATEADD(quarter, @TimeUnits, @FirstDate))  -- Last day of that time frame.
		END
		ELSE
		BEGIN
			SELECT @FirstDate = dbo.fnc_Metric_DateAdd(@Style, 'quarter', -@TimeUnits, @Date) -- first, go back X years.
			SELECT @FirstDate = dbo.fnc_Metric_FirstDateOfTimeFrame (@Style, @TimeFrame, @FirstDate) -- get the first data of that time frame.
			SELECT @Date = DATEADD(day, -1, dbo.fnc_Metric_DateAdd(@Style, 'quarter', @TimeUnits, @FirstDate))  -- Last day of that time frame.			
		END			
	END
	ELSE IF (@TimeFrame = 'month' OR @TimeFrame = 'mm' OR @TimeFrame = 'm')
	BEGIN
		SELECT @TimeFrame = 'month'
		IF @Style = ''
		BEGIN
			SELECT @FirstDate = DATEADD(month, -@TimeUnits, @Date)
			SELECT @FirstDate = DATEADD(day, 1-DATEPART(day, @FirstDate), @FirstDate)
			SELECT @Date = DATEADD(day, -1, DATEADD(month, @TimeUnits, @FirstDate))
		END
		ELSE
		BEGIN
			SELECT @FirstDate = dbo.fnc_Metric_DateAdd(@Style, 'month', -@TimeUnits, @Date) -- first, go back X years.
			SELECT @FirstDate = dbo.fnc_Metric_FirstDateOfTimeFrame (@Style, @TimeFrame, @FirstDate) -- get the first data of that time frame.
			SELECT @Date = DATEADD(day, -1, dbo.fnc_Metric_DateAdd(@Style, 'month', @TimeUnits, @FirstDate))  -- Last day of that time frame.			
		END			
	END
	ELSE IF (@TimeFrame = 'week' OR @TimeFrame = 'wk' OR @TimeFrame = 'ww') 
	BEGIN
		SELECT @TimeFrame = 'week', @FirstDate = DATEADD(week, -@TimeUnits, @Date)
		SELECT @FirstDate = DATEADD(day, 1-DATEPART(dw, @FirstDate), @FirstDate)
		SELECT @Date = DATEADD(day, -1, DATEADD(week, @TimeUnits, @FirstDate))
	END
	ELSE IF (@TimeFrame = 'day' OR @TimeFrame = 'dd' OR @TimeFrame = 'd') 
	BEGIN
		SELECT @TimeFrame = 'day', @FirstDate = DATEADD(day, -@TimeUnits, @Date)
		SELECT @FirstDate = DATEADD(day, -1, @FirstDate)
		SELECT @Date = DATEADD(day, @TimeUnits, @FirstDate)
	END
	ELSE IF (@TimeFrame = 'wd') SELECT @FirstDate = DATEADD(day, -(@TimeUnits + 2 * (@TimeUnits/7 + 1)), @Date) -- 2 extra days for every week to account for possible weekend days.

-- SELECT @FirstDate AS '@FirstDate', @Date AS '@Date'

	IF @UseGoalHistory IS NULL
		SELECT @UseGoalHistory = CASE WHEN ParmValue = 'Y' THEN 1 ELSE 0 END FROM metricparameter (NOLOCK) WHERE Heading = 'Metric' AND SubHeading = @MetricCode AND ParmName = 'USE_GOAL_HISTORY'
	IF @UseGoalHistory IS NULL
		SELECT @UseGoalHistory = CASE WHEN ParmValue = 'Y' THEN 1 ELSE 0 END FROM metricparameter (NOLOCK) WHERE Heading = 'Metric' AND SubHeading = NULL AND ParmName = 'USE_GOAL_HISTORY'
	IF @UseGoalHistory IS NULL
		SELECT @UseGoalHistory = 0

	-- Get this information from the current, or from history?  This is now an option... OPTION('Metric', NULL, 'USE_GOAL_HISTORY')
	SELECT @FormatText = FormatText, @GradingScaleCode = GradingScaleCode, @Cumulative = Cumulative, 
			@ExtrapolateGradesForCumulativeFromDaily = ISNULL(ExtrapolateGradesForCumulativeFromDaily, ''), -- Blank is DEFAULT TO GENERAL SETTING 
			@ExtrapolateGradesByCountingBusinessDays = ISNULL(ExtrapolateGradesByCountingBusinessDays, '')   -- Blank is DEFAULT TO GENERAL SETTING
		FROM MetricItem (NOLOCK) WHERE metriccode = @MetricCode

	SELECT @PlusDelta = CASE WHEN PlusDeltaIsGood = 0 THEN -1 ELSE 1 END FROM MetricGradingScaleHeader WHERE GradingScaleCode = @GradingScaleCode

	IF @Cumulative = 0
		SET @ExtrapolateGradesForCumulativeFromDaily = 'N'
		-- SET @ExtrapolateGradesByCountingBusinessDays = 'N' -- Irrelevant
	ELSE
	BEGIN
		-- First get MetricItem setting. 
		IF (@ExtrapolateGradesForCumulativeFromDaily = '')
			SELECT @ExtrapolateGradesForCumulativeFromDaily = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE settingname= 'ExtrapolateGradesForCumulativeFromDaily'), 'Y')
		ELSE SET @ExtrapolateGradesForCumulativeFromDaily = @ExtrapolateGradesForCumulativeFromDaily

		IF (@ExtrapolateGradesByCountingBusinessDays = '')
			SELECT @ExtrapolateGradesByCountingBusinessDays = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE settingname= 'ExtrapolateGradesByCountingBusinessDays'), 'Y')
		ELSE 
			SET @ExtrapolateGradesByCountingBusinessDays = @ExtrapolateGradesByCountingBusinessDays
	END

	SET @WeekAdjust = 0
	-- Get the Grading Scale to use.  1) Check GradingScaleSN in MetricItem table,  2) If not, try default scale for that type,  3) Still not, use #DEFAULT.
	IF NOT EXISTS(SELECT * FROM MetricGradingScaleDetail (NOLOCK) WHERE GradingScaleCode = @GradingScaleCode)
		SELECT @GradingScaleCode = MAX(GradingScaleCode) FROM MetricGradingScaleDetail (NOLOCK) WHERE GradingScaleCode = '#DEFAULT_' + @FormatText
	IF NOT EXISTS(SELECT * FROM MetricGradingScaleDetail (NOLOCK) WHERE GradingScaleCode = @GradingScaleCode) SELECT @GradingScaleCode = '#DEFAULT_'

	DECLARE @date_AltMonth01 varchar(2), @date_AltQuarter01 varchar(2), @date_AltYear01 varchar(4)

	SELECT @DateCur = @Date
	WHILE @DateCur > @FirstDate -- DATEADD(week, -@TimeUnits, @Date) 	-- Loop through backwards and insert a value into the table.
	BEGIN
		IF @Style <> ''
		BEGIN
			SELECT @date_AltMonth01 = date_AltMonth01, @date_AltQuarter01 = date_AltQuarter01, @date_AltYear01 = date_AltYear01
			FROM MetricBusinessDays t1 (NOLOCK) WHERE t1.PlainDate = @DateCur
		END	
	
		-- First determine the last period date for this time frame to retrieve the correct average
		IF (@TimeFrame = 'day' OR @TimeFrame = 'wd')
			SELECT @LastDateInPeriod = @DateCur, @FirstDateInPeriod = @DateCur
		ELSE IF @TimeFrame = 'week' 		-- Get the most recent NON-NULL value for the goal in this time frame.
		BEGIN
			SELECT @LastDateInPeriod = DATEADD(day, 6, DATEADD(day, 1-DATEPART(dw, @DateCur), @DateCur)), 
					@FirstDateInPeriod = DATEADD(day, 1-DATEPART(dw, @DateCur), @DateCur)
			IF (@LastDateInPeriod > @DateCur) SET @LastDateInPeriod = @DateCur
-- select Date = @Date, DateCur = @DateCur, FirstDateInPeriod = @FirstDateInPeriod, LastDateInPeriod = @LastDateInPeriod			
		END
		ELSE IF @TimeFrame = 'month' 		-- Get the most recent NON-NULL value for the goal in this time frame.
		BEGIN
			IF @Style = '' 		
				SELECT @LastDateInPeriod = MAX(PlainDate), @FirstDateInPeriod = MIN(PlainDate) FROM MetricDetail (NOLOCK) 
									WHERE metriccode = @metriccode AND PlainYear = DATEPART(yyyy, @DateCur) AND PlainMonth = DATEPART(month, @DateCur)
			ELSE
			BEGIN
				SELECT @FirstDateInPeriod = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', @DateCur)
				SELECT @LastDateInPeriod = MAX(t1.plaindate)
				FROM MetricDetail t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.PlainDate = t2.PlainDate 
				WHERE t1.metriccode = @metriccode AND t2.date_AltYear01 = @date_AltYear01 AND t2.date_AltMonth01 = @date_AltMonth01			
			END
		END
		ELSE IF @TimeFrame = 'quarter' 		-- Get the most recent NON-NULL value for the goal in this time frame.
			IF @Style = ''
				SELECT @LastDateInPeriod = MAX(PlainDate), @FirstDateInPeriod = MIN(PlainDate)  FROM MetricDetail (NOLOCK) 
									WHERE metriccode = @metriccode AND PlainYear = DATEPART(yyyy, @DateCur) AND PlainQuarter = DATEPART(quarter, @DateCur)
			ELSE
			BEGIN
				SELECT @FirstDateInPeriod = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'quarter', @DateCur)
				SELECT @LastDateInPeriod = MAX(t1.plaindate)
				FROM MetricDetail t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.PlainDate = t2.PlainDate 
				WHERE t1.metriccode = @metriccode AND t2.date_AltYear01 = @date_AltYear01 AND t2.date_AltQuarter01 = @date_AltQuarter01		
			END
		ELSE IF @TimeFrame = 'year' 		-- Get the most recent NON-NULL value for the goal in this time frame.
			IF @Style = ''			
				SELECT @LastDateInPeriod = MAX(PlainDate), @FirstDateInPeriod = MIN(PlainDate)  FROM MetricDetail (NOLOCK) 
									WHERE metriccode = @metriccode AND PlainYear = DATEPART(yyyy, @DateCur)
			ELSE
			BEGIN
				SELECT @FirstDateInPeriod = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'year', @DateCur)
				SELECT @LastDateInPeriod = MAX(t1.plaindate)
				FROM MetricDetail t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.PlainDate = t2.PlainDate 
				WHERE t1.metriccode = @metriccode AND t2.date_AltYear01 = @date_AltYear01		
			END

-- select @DateCur, DATEPART(yyyy, @DateCur), DATEPART(week, @DateCur) 
-- select * from metricdetail where plainweek = 33
-- select * from metricdetail where plaindate = '20080817'

		IF @ExtrapolateGradesForCumulativeFromDaily = 'N'
			SET @NumberOfDaysInTimeFrame = 1
		ELSE
		BEGIN
			IF (@TimeFrame = 'day' OR @TimeFrame = 'wd') 		
				SELECT @NumberOfDaysInTimeFrame = 1
			ELSE 
			BEGIN
				IF (@ExtrapolateGradesByCountingBusinessDays = 'N')
					SET @NumberOfDaysInTimeFrame =  1 + DATEDIFF(day, @FirstDateInPeriod, @LastDateInPeriod)
				ELSE
				BEGIN
					SET @NumberOfDaysInTimeFrame =  1 + DATEDIFF(day, @FirstDateInPeriod, @LastDateInPeriod)
					IF (SELECT COUNT(*) FROM MetricBusinessDays (NOLOCK) WHERE PlainDate >= @FirstDateInPeriod AND PlainDate <= @LastDateInPeriod) = @NumberOfDaysInTimeFrame  -- MetricBusinessDays is properly populated.
						SELECT @NumberOfDaysInTimeFrame = COUNT(*) FROM MetricBusinessDays (NOLOCK) WHERE PlainDate >= @FirstDateInPeriod AND PlainDate <= @LastDateInPeriod AND BusinessDay = 1
					-- ELSE Leave it as is.
				END
			END
		END

		INSERT INTO @MetricGradingScaleDetail (Grade, MinValue, FormatText)
		SELECT Grade, MinValue * @NumberOfDaysInTimeFrame, FormatText FROM MetricGradingScaleDetail WHERE GradingScaleCode = @GradingScaleCode

		-- Now determine the GOAL for this time frame specific to @DateCur.
		IF @UseGoalHistory = 1		-- This is if they want to be judged off of goal history.
		BEGIN
			IF (@TimeFrame = 'day' OR @TimeFrame = 'wd') 		-- Get the value for the goal in this time frame.
				SELECT @Goal = GoalDay -- CASE WHEN GoalDay IS NOT NULL THEN GoalDay ELSE (SELECT GoalDay FROM MetricItem (NOLOCK) WHERE metriccode = @MetricCode) END 
				FROM metricdetail (NOLOCK)
				WHERE metriccode = @metriccode AND PlainDate = @DateCur

			ELSE IF @TimeFrame = 'week' 		-- Get the most recent NON-NULL value for the goal in this time frame.
				SELECT TOP 1 @Goal = GoalWeek -- CASE WHEN GoalWeek IS NOT NULL THEN GoalWeek ELSE (SELECT GoalWeek FROM MetricItem (NOLOCK) WHERE metriccode = @MetricCode) END 
				FROM metricdetail (NOLOCK) 
				WHERE metriccode = @metriccode 
					AND PlainDate BETWEEN @FirstDateInPeriod AND @LastDateInPeriod 
					AND GoalWeek IS NOT NULL
			ELSE IF @TimeFrame = 'month' 		-- Get the most recent NON-NULL value for the goal in this time frame.
				IF @Style = ''
				BEGIN
					SELECT @Goal = GoalMonth -- CASE WHEN GoalMonth IS NOT NULL THEN GoalMonth ELSE (SELECT GoalMonth FROM MetricItem (NOLOCK) WHERE metriccode = @MetricCode) END 
					FROM metricdetail (NOLOCK) 
					WHERE metriccode = @metriccode 
						AND PlainDate = (SELECT MAX(PlainDate) FROM MetricDetail (NOLOCK) 
											WHERE metriccode = @metriccode AND PlainYear = DATEPART(yyyy, @DateCur) AND PlainMonth = DATEPART(month, @DateCur)
												AND GoalMonth IS NOT NULL)
				END
				ELSE
				BEGIN
					SELECT @Goal = GoalMonth -- CASE WHEN GoalMonth IS NOT NULL THEN GoalMonth ELSE (SELECT GoalMonth FROM MetricItem (NOLOCK) WHERE metriccode = @MetricCode) END
					FROM metricdetail (NOLOCK)
					WHERE metriccode = @metriccode
						AND PlainDate = (SELECT MAX(t1.PlainDate) FROM MetricDetail t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.PlainDate = t2.plaindate
											WHERE t1.metriccode = @metriccode AND t2.date_AltYear01 = @date_AltYear01 AND t2.date_AltMonth01 = @date_AltMonth01
												AND t1.GoalMonth IS NOT NULL)
				END
			ELSE IF @TimeFrame = 'quarter' 		-- Get the most recent NON-NULL value for the goal in this time frame.
				IF @Style = ''
				BEGIN			
					SELECT @Goal = GoalQuarter -- CASE WHEN GoalQuarter IS NOT NULL THEN GoalQuarter ELSE (SELECT GoalQuarter FROM MetricItem (NOLOCK) WHERE metriccode = @MetricCode) END 
					FROM metricdetail (NOLOCK) 
					WHERE metriccode = @metriccode 
						AND PlainDate = (SELECT MAX(PlainDate) FROM MetricDetail (NOLOCK) 
											WHERE metriccode = @metriccode AND PlainYear = DATEPART(yyyy, @DateCur) AND PlainQuarter = DATEPART(quarter, @DateCur)
												AND GoalQuarter IS NOT NULL)
				END
				ELSE
				BEGIN
					SELECT @Goal = GoalQuarter -- CASE WHEN GoalQuarter IS NOT NULL THEN GoalQuarter ELSE (SELECT GoalQuarter FROM MetricItem (NOLOCK) WHERE metriccode = @MetricCode) END 
					FROM metricdetail (NOLOCK)
					WHERE metriccode = @metriccode
						AND PlainDate = (SELECT MAX(t1.PlainDate) FROM MetricDetail t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.PlainDate = t2.plaindate
											WHERE t1.metriccode = @metriccode AND t2.date_AltYear01 = @date_AltYear01 AND t2.date_AltQuarter01 = @date_AltQuarter01
												AND t1.GoalMonth IS NOT NULL)
				END

			ELSE IF @TimeFrame = 'year' 		-- Get the most recent NON-NULL value for the goal in this time frame.
				IF @Style = ''
				BEGIN				
					SELECT @Goal = GoalYear -- CASE WHEN GoalYear IS NOT NULL THEN GoalYear ELSE (SELECT GoalYear FROM MetricItem (NOLOCK) WHERE metriccode = @MetricCode) END 
					FROM metricdetail (NOLOCK) 
					WHERE metriccode = @metriccode 
						AND PlainDate = (SELECT MAX(PlainDate) FROM MetricDetail (NOLOCK) 
											WHERE metriccode = @metriccode AND PlainYear = DATEPART(yyyy, @DateCur) 
												AND GoalYear IS NOT NULL)
				END
				ELSE
				BEGIN
					SELECT @Goal = GoalYear -- CASE WHEN GoalYear IS NOT NULL THEN GoalYear ELSE (SELECT GoalYear FROM MetricItem (NOLOCK) WHERE metriccode = @MetricCode) END 
					FROM metricdetail (NOLOCK) 
					WHERE metriccode = @metriccode 										
							AND PlainDate = (SELECT MAX(t1.PlainDate) FROM MetricDetail t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.PlainDate = t2.plaindate
												WHERE t1.metriccode = @metriccode AND t2.date_AltYear01 = @date_AltYear01
													AND t1.GoalMonth IS NOT NULL)
				END
		END
		ELSE
		BEGIN
			SELECT @Goal = CASE WHEN @TimeFrame = 'day' THEN GoalDay WHEN @TimeFrame = 'week' THEN GoalWeek WHEN @TimeFrame = 'month' THEN GoalMonth WHEN @TimeFrame = 'quarter' THEN GoalQuarter WHEN @TimeFrame = 'year' THEN GoalYear
							END
					FROM MetricItem (NOLOCK) WHERE MetricCode = @MetricCode
		END


		IF NOT EXISTS(SELECT * FROM MetricDetail (NOLOCK) WHERE metriccode = @metriccode AND PlainDate = @DateCur)
			SELECT @Grade = @NO_DATA_INDICATOR

		-- If Goal is NULL, then return an '*' for this @DateCur.  Handle the way this is displayed in the UI.
		ELSE --IF (@Goal IS NULL)
		BEGIN
			IF (@Goal IS NULL)
				SELECT @Grade = @GOAL_NOT_SET_INDICATOR  -- Means that the GOAL NOT SET.

			IF (@TimeFrame = 'day' OR @TimeFrame = 'wd')
			BEGIN
				--IF @FormatText = 'PCT' 
					SELECT @MetricValue = DailyValue, @ThisAve = DailyValue, @Count = DailyCount, @Total = DailyTotal -- CASE WHEN @Grade = @GOAL_NOT_SET_INDICATOR THEN NULL ELSE DailyValue - @Goal END,
						FROM MetricDetail (NOLOCK) WHERE metriccode = @metriccode AND PlainDate = @DateCur 
				--ELSE
				--	SELECT @MetricValue = DailyValue, @ThisAve = DailyValue, @Count = DailyCount, @Total = DailyTotal -- (ISNULL(DailyValue, 0) - @Goal) / @Goal,
				--		FROM MetricDetail (NOLOCK) WHERE metriccode = @metriccode AND PlainDate = @DateCur 
			END
			ELSE IF @TimeFrame = 'week' 		
			BEGIN
				--IF @FormatText = 'PCT' 
					SELECT @MetricValue = ThisWTD, @ThisAve = ThisWTD		-- WeeklyAve - @Goal, --*** NOTE: We used to calculate the difference.
						FROM MetricDetail (NOLOCK) WHERE metriccode = @metriccode AND PlainDate = @LastDateInPeriod 
				--ELSE
				--	SELECT @MetricValue = WeeklyAve, @ThisAve = WeeklyAve -- (ISNULL(WeeklyAve, 0) - @Goal) / @Goal,
				--		FROM MetricDetail (NOLOCK) WHERE metriccode = @metriccode AND PlainDate = @DateCur 
			END
			ELSE IF @TimeFrame = 'month'
			BEGIN
				IF @Style = ''
					SELECT @MetricValue = ThisMTD, @ThisAve = ThisMTD  --** MonthlyAve - @Goal,
						FROM MetricDetail (NOLOCK) WHERE metriccode = @metriccode AND PlainDate = @LastDateInPeriod 
				ELSE
				BEGIN
					SELECT @MetricValue = dbo.fnc_get_Metric_xTD_Alternate(@metriccode, @LastDateInPeriod, 'AltMonth01')
					SELECT @ThisAve = @MetricValue
				END

			END
			ELSE IF @TimeFrame = 'quarter'
			BEGIN
				IF @Style = ''
					SELECT @MetricValue = ThisQTD, @ThisAve = ThisQTD  --** QuarterlyAve - @Goal,
						FROM MetricDetail (NOLOCK) WHERE metriccode = @metriccode AND PlainDate = @LastDateInPeriod 
				ELSE
				BEGIN
					SELECT @MetricValue = dbo.fnc_get_Metric_xTD_Alternate(@metriccode, @LastDateInPeriod, 'AltQuarter01')
					SELECT @ThisAve = @MetricValue
				END
			END
			ELSE IF @TimeFrame = 'year'
			BEGIN
				IF @Style = ''
					SELECT @MetricValue = ThisYTD, @ThisAve = ThisYTD --** YearlyAve - @Goal,
						FROM MetricDetail (NOLOCK) WHERE metriccode = @metriccode AND PlainDate = @LastDateInPeriod 
				ELSE
				BEGIN
					SELECT @MetricValue = dbo.fnc_get_Metric_xTD_Alternate(@metriccode, @LastDateInPeriod, 'AltYear01')
					SELECT @ThisAve = @MetricValue
				END
			END

-- **** AFTER THIS.... 
			
			-- Give it a grade.
			SELECT @Grade = NULL, @MinValue = NULL, @MaxValue = NULL
			IF (@PlusDelta = -1)
			BEGIN
				SELECT @Grade = Grade, @MinValue = MinValue
					FROM @metricgradingscaledetail 
					WHERE -- GradingScaleCode = @GradingScaleCode 
						MinValue = (SELECT MIN(minvalue) FROM @metricgradingscaledetail WHERE MinValue >= @MetricValue AND MinValue IS NOT NULL) -- GradingScaleCode = @GradingScaleCode AND 
				SELECT @MaxValue = (SELECT MAX(minvalue) FROM @metricgradingscaledetail WHERE MinValue < @MinValue AND MinValue IS NOT NULL) -- GradingScaleCode = @GradingScaleCode AND 

				IF (@MaxValue IS NULL AND @MinValue IS NOT NULL) SELECT @Range = 'less than ' + CONVERT(varchar(100), @MinValue) 
				ELSE IF (@MaxValue IS NULL AND @MinValue IS NULL) SELECT @Range = 'greater than ' + CONVERT(varchar(100), (SELECT MAX(MinValue) FROM @metricgradingscaledetail WHERE MinValue IS NOT NULL) )  -- FAILING!
				ELSE SELECT @Range = 'between ' + CONVERT(varchar(100), @MaxValue) + ' and ' + CONVERT(varchar(100), @MinValue) 

			END
			ELSE
			BEGIN
				SELECT @Grade = Grade, @MinValue = MinValue
					FROM @metricgradingscaledetail 
					WHERE -- GradingScaleCode = @GradingScaleCode AND 
						MinValue = (SELECT MAX(minvalue) FROM @metricgradingscaledetail WHERE MinValue <= @MetricValue AND MinValue IS NOT NULL) -- GradingScaleCode = @GradingScaleCode AND 					
				SELECT @MaxValue = (SELECT MIN(minvalue) FROM @metricgradingscaledetail WHERE MinValue > @MinValue AND MinValue IS NOT NULL) -- GradingScaleCode = @GradingScaleCode AND	

				IF (@MaxValue IS NULL AND @MinValue IS NOT NULL) SELECT @Range = 'greater than ' + CONVERT(varchar(100), @MinValue) 
				ELSE IF (@MaxValue IS NULL AND @MinValue IS NULL) SELECT @Range = 'less than ' + CONVERT(varchar(100), (SELECT MIN(MinValue) FROM @metricgradingscaledetail WHERE MinValue IS NOT NULL) )  -- FAILING!
				ELSE SELECT @Range = 'between ' + CONVERT(varchar(100), @MinValue) + ' and ' + CONVERT(varchar(100), @MaxValue) 
			END

			IF (@Grade IS NULL) SELECT @Grade = Grade FROM @metricgradingscaledetail WHERE MinValue IS NULL -- GradingScaleCode = @GradingScaleCode AND 
			IF (@Grade IS NULL) SELECT @Grade = @UNKNOWN_GRADE

			-- If MetricValue = NULL, 
			IF (@MetricValue IS NULL AND @Grade <> @GOAL_NOT_SET_INDICATOR) SELECT @Grade = @NO_DATA_INDICATOR

		END

		-- Place into table
-- select @MetricValue, @LastDateInPeriod
		INSERT INTO #temp (	datecur, grade, metricvalue, goal, ThisAve, MinValue, MaxValue, Range, FirstDate, LastDate ) 
		VALUES (@DateCur, @Grade, CONVERT(decimal(20, 5), @MetricValue), @Goal, @ThisAve, @MinValue, @MaxValue, @Range, @FirstDateInPeriod, @LastDateInPeriod )

		-- Reset the average in case no data is found.
		SELECT @MetricValue = NULL, @Goal = NULL

		-- Go to the previous time frame...
		IF (@TimeFrame = 'wd')
		BEGIN
			SELECT @DateCur = DATEADD(d, -1, @DateCur) -- datepart(dw, getdate()) -- 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday
			IF (DATEPART(dw, @DateCur) = 1 OR DATEPART(dw, @DateCur) = 7 ) SELECT @DateCur = DATEADD(d, -1, @DateCur) -- It could be a weekend, so go back another day.
			IF (DATEPART(dw, @DateCur) = 1 OR DATEPART(dw, @DateCur) = 7 ) SELECT @DateCur = DATEADD(d, -1, @DateCur) -- It could still be a weekend.
		END
		ELSE
		BEGIN
			IF (@TimeFrame = 'year') SELECT @DateCur = CASE WHEN @Style='' THEN DATEADD(yyyy, -1, @DateCur) ELSE dbo.fnc_Metric_DateAdd('Alt01', 'yyyy', -1, @DateCur) END
			ELSE IF (@TimeFrame = 'quarter') SELECT @DateCur = CASE WHEN @Style='' THEN DATEADD(q, -1, @DateCur) ELSE dbo.fnc_Metric_DateAdd('Alt01', 'q', -1, @DateCur) END
			ELSE IF (@TimeFrame = 'month') SELECT @DateCur = CASE WHEN @Style = '' THEN DATEADD(m, -1, @DateCur) ELSE dbo.fnc_Metric_DateAdd('Alt01', 'm', -1, @DateCur) END
			ELSE IF (@TimeFrame = 'week') SELECT @DateCur = DATEADD(wk, -1, @DateCur)
			ELSE IF (@TimeFrame = 'day') SELECT @DateCur = DATEADD(d, -1, @DateCur)
		END

		DELETE @MetricGradingScaleDetail 
	END

	SELECT *, @GOAL_NOT_SET_INDICATOR AS GOAL_NOT_SET_INDICATOR, @NO_DATA_INDICATOR AS NO_DATA_INDICATOR, @UNKNOWN_GRADE AS UNKNOWN_GRADE
		FROM #temp 
		ORDER BY datecur desc
	SET NOCOUNT OFF

/* 
	DECLARE @GradingScaleCode varchar(200), @sn int, @PlusDeltaIsGood int, @Out varchar(1000)
	DECLARE @Grade varchar(100), @MinValue decimal(20, 5)
	DECLARE @icheck int
	SET @icheck = 0
	SET @GradingScaleCode = 'TESTCASE01'
	SET @PlusDeltaIsGood = 1
	SELECT @sn = ISNULL(sn, -1) FROM metricgradingscaledetail (NOLOCK) WHERE MinValue = (SELECT Max(MinValue) FROM metricgradingscaledetail (NOLOCK) WHERE GradingScaleCode = @GradingScaleCode )
	WHILE ISNULL(@sn, -1) > -1
	BEGIN
	SET @icheck = @icheck + 1
		SELECT @Grade = Grade, @MinValue = MinValue FROM metricgradingscaledetail (NOLOCK) WHERE GradingScaleCode = @GradingScaleCode 
		SELECT @Grade, @MinValue
		SELECT @sn = ISNULL(sn, -1) FROM metricgradingscaledetail (NOLOCK) WHERE MinValue = (SELECT Max(MinValue) FROM metricgradingscaledetail (NOLOCK) WHERE GradingScaleCode = @GradingScaleCode AND MinValue > @MinValue)
	END
*/
GO
GRANT EXECUTE ON  [dbo].[MetricReportCard2] TO [public]
GO
