SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricReportTimeFrame] 
(
	@CategoryCode varchar(30),
	@TimeFrame VARCHAR(7) = 'week', 	-- wd (weekday => This is special), wk (week), m (month), q (quarter), yyyy (year), or day (any day, most likely not used), 	
										-- (year, yy, yyyy), (quarter, qq, q), (Month, mm, m), (Day dd, d), (Week wk, ww),
	@TimeUnits int = 10,
	@LayerCodeFilter varchar(255) = ''
)
AS
	SET NOCOUNT ON 

	DECLARE @DateToUse datetime, @LatestDateToUse datetime, @EarliestDateToUse datetime
	DECLARE @HighestTimeFrameValue int, @RunPreviousDayYN varchar(1)
	DECLARE @LastNewYearsEve datetime
	DECLARE @Suffix varchar(200)
	DECLARE @DateFirst int
	DECLARE @TempWeekDate datetime
	DECLARE @IncludeMostRecentPeriodForVariance varchar(1)
	DECLARE @NumberTimeUnitsUsedForAverage int		--- This is used in the WEB PAGE for "{x} {time frame} Avg", like "4 Quarter Avg" or "6 Week Avg".
									--- Note that IF 'TimeLineGoalVarianceIncludesMostRecentPeriodYN' = 'Y', then that value is 1 more than if NOT.
	DECLARE @DateOrderLeftToRight varchar(20)
	DECLARE @Style varchar(10)
	DECLARE @MonthTitle varchar(100), @QuarterTitle varchar(100), @YearTitle varchar(100)
	DECLARE @RespectCumulativeOnTimeline varchar(1)
	DECLARE @WeightedAveragesForNoncumulative varchar(1)

	CREATE TABLE #tempMetrics (TopLevelMetric varchar(200), 
								sort int, 
								MetricCode varchar(200), 
								Caption varchar(200), 
								CaptionFull varchar(255), 
								TopLevelCaption varchar(255), 
								Active int default(-1),
								x_Summary decimal(20,5),
								BadData int,
								SumNumerator decimal(20, 5),
								SumDenominator decimal(20, 5),
								Cumulative int
							)


	CREATE TABLE #TimeLineResults
		(Goal DECIMAL (20,5),
		Caption VARCHAR(255),
		CategoryCaption VARCHAR(255),
		CategoryCaptionFull VARCHAR(255),
		SortingColumn VARCHAR(255),
		FormatText VARCHAR(12),
		NumDigitsAfterDecimal INT,
		PlusDeltaIsGood INT,
		TimeUnits INT,
		EarliestDateToUse datetime,
		LatestDateToUse datetime,
		TimeFrameMax INT,
		CategoryCode VARCHAR(255),
		MetricCode VARCHAR(255),
		SortingAssist INT,
		TimeFrameAve DECIMAL(20,5),
		x_summary DECIMAL(20,5),
		NumberTimeUnitsUsedForAverage VARCHAR(10),
		sort INT,
		DateToUse datetime,
		Heading VARCHAR(100),
		cumulative INT,
		TopLevelMetric VARCHAR(255),
		Active INT,
		startdate datetime,
		enddate datetime,
		Average DECIMAL(20,5),
		Annualize INT,
		BadData int,
		TimeHeading varchar(20),
		TimeHeadingTitle varchar(50),
		SummaryDone int,
		PeriodGoal decimal(20, 5)
		)

		DECLARE @t1 TABLE (sn int identity
			,PlainDate datetime, PlainYear int, PlainQuarter int, PlainMonth int, PlainYearWeek varchar(6), PlainFiscalYear int
			,date_AltYear01 varchar(4), date_AltQuarter01 varchar(2), date_AltMonth01 varchar(2)
			,StartDate datetime, EndDate datetime
		)

	SET @RespectCumulativeOnTimeline = ISNULL((SELECT SettingValue from MetricGeneralSettings WHERE SettingName = 'RespectCumulativeOnTimeline'), 'Y')
	SET @WeightedAveragesForNoncumulative = ISNULL((SELECT SettingValue from MetricGeneralSettings WHERE SettingName = 'WeightedAveragesForNoncumulative'), 'Y')
	
		
-----------------------------------------------------
--General Settings -- DateFirst
-----------------------------------------------------
    Select @DateFirst = settingvalue from MetricGeneralSettings where settingname = 'DateFirst'
	--EXEC MetricGetParameterInt @DateFirst OUTPUT, 7, 'Config', 'All', 'DateFirst'
	SET DATEFIRST @DateFirst  -- Should be based on global parameter.

	SELECT @IncludeMostRecentPeriodForVariance = settingvalue from metricgeneralsettings (NOLOCK) where settingname = 'TimeLineGoalVarianceIncludesMostRecentPeriodYN'
	
-------------------------------------------
--Needs to be modified for General Settings
-------------------------------------------
--	EXEC MetricGetParameterText @RunPreviousDayYN OUTPUT, 'Y', 'Config', 'All', 'Process_And_Show_For_Previous_Day_YN'
--	IF @RunPreviousDayYN = 'Y' SELECT @DateToUse = DATEADD(day, -1, @DateToUse)

	IF ISNULL(@LayerCodeFilter, '') = '' SELECT @Suffix = '' ELSE SELECT @Suffix = '@' + @LayerCodeFilter
	-- 1) Get metrics in this category - don't use suffix yet.
	INSERT INTO #tempMetrics (TopLevelMetric, sort, Caption, CaptionFull, TopLevelCaption, Cumulative) 
		SELECT t2.metriccode, t2.sort, t1.Caption, t1.CaptionFull, t3.Caption, t3.Cumulative
		FROM MetricCategory t1 WITH (NOLOCK), MetricCategoryItems t2 WITH (NOLOCK), MetricItem t3 WITH (NOLOCK)
		WHERE t1.CategoryCode = t2.CategoryCode
			AND t2.CategoryCode = @CategoryCode
			AND t2.MetricCode = t3.MetricCode
	-- 2) Use suffix to get metrics from metricitem table.

	UPDATE #tempMetrics
		SET MetricCode = t2.MetricCode, Active = t2.Active, BadData = t2.BadData
		FROM #tempMetrics t1, MetricItem t2 WITH (NOLOCK) 
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode

	SELECT @DateToUse = MAX(PlainDate) FROM MetricDetail

	SELECT @Style = CASE WHEN EXISTS(SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'UseAlternateTimeFramesYN' AND SettingValue = 'Y')
						THEN 'Alt01' ELSE '' END

	IF @Style = 'Alt01' AND @TimeFrame IN ('Month', 'Quarter', 'Year')
	BEGIN
		SELECT
			@MonthTitle = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameMonth'), 'Month')
			,@QuarterTitle = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameQuarter'), 'Quarter')
			,@YearTitle = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameYear'), 'Year')
	END
	ELSE
		SELECT @MonthTitle = 'Month', @QuarterTitle = 'Quarter', @YearTitle = 'Year'

	SELECT @LatestDateToUse = @DateToUse
	IF @TimeFrame = 'day'
	BEGIN
		SELECT @EarliestDateToUse = DATEADD(day, -@TimeUnits+1, @DateToUse)
	END
	ELSE
	BEGIN
		SELECT @EarliestDateToUse = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, @TimeFrame, dbo.fnc_Metric_DateAdd(@Style, @TimeFrame, 1-@TimeUnits, @LatestDateToUse))
	END


-- REMOVED FROM HERE.
	IF @TimeFrame = 'day'
	BEGIN
		SET ROWCOUNT @TimeUnits
		INSERT INTO @t1 (PlainDate, StartDate, EndDate )
		SELECT DISTINCT t1.PlainDate, t1.PlainDate, t1.PlainDate FROM MetricBusinessDays t1 (NOLOCK)
		WHERE t1.Plaindate <= @LatestDateToUse ORDER BY t1.PlainDate DESC
		SET ROWCOUNT 0

		INSERT INTO #TimeLineResults  (Goal, PeriodGoal, Caption, CategoryCaption, CategoryCaptionFull, SortingColumn, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood
							,TimeUnits, EarliestDateToUse, LatestDateToUse, TimeFrameMax, CategoryCode, MetricCode, SortingAssist
							,TimeFrameAve, x_summary, NumberTimeUnitsUsedForAverage, sort
							,DateToUse, Heading, cumulative, TopLevelMetric, Active, startdate, enddate, Average, Annualize, BadData, TimeHeading, TimeHeadingTitle)
		SELECT Goal = t3.GoalDay
			,PeriodGoal = t3.GoalDay
			,t2.TopLevelCaption AS Caption -- t2
			,t2.Caption AS CategoryCaption -- t2  
			,t2.CaptionFull AS CategoryCaptionFull -- t2
			,right('0000000000' + ltrim(CONVERT(varchar(10), t2.sort)), 10) + t2.TopLevelMetric AS SortingColumn  -- t2
			,FormatText  
			,ISNULL(NumDigitsAfterDecimal, 0) AS NumDigitsAfterDecimal
			,t3.PlusDeltaIsGood 
			,@TimeUnits AS TimeUnits
			,@EarliestDateToUse AS EarliestDateToUse
			,@LatestDateToUse AS LatestDateToUse
			,@HighestTimeFrameValue AS TimeFrameMax
			,@CategoryCode
			,t2.MetricCode  -- t2
			,Day(t1.PlainDate) AS SortingAssist -- t1
			,TimeFrameAve = CONVERT(decimal(20, 5), 0)
			,t2.x_summary  -- t2
			,@NumberTimeUnitsUsedForAverage as NumberTimeUnitsUsedForAverage
			,t2.sort   -- t2
			,@DateToUse AS DateToUse
			,t1.PlainYearWeek as Heading  -- t1
			,t3.cumulative
			,t2.TopLevelMetric -- t2
			,t2.Active -- t2
			,t1.StartDate -- t1
			,t1.EndDate -- t1
			,0 as Average
			,t3.Annualize
			,BadData = t2.BadData, --t2
			CONVERT(VARCHAR(2), DATEPART(Month, t1.PlainDate)) + '/' + CONVERT(VARCHAR(2), DATEPART(day, t1.PlainDate))
			+ '<br/>' +  LEFT(DATENAME(dw, t1.PlainDate), 3),
			'Day'
		FROM @t1 t1, #tempMetrics t2 INNER JOIN metricitem t3 WITH (NOLOCK) ON t2.MetricCode = t3.MetricCode
							
		UPDATE #TimeLineResults SET TimeFrameAve = 
			CASE WHEN t1.Annualize = 1 THEN t2.DailyValue * 365.25 ELSE t2.DailyValue END
		FROM #TimeLineResults t1 INNER JOIN MetricDetail t2 (NOLOCK) ON t1.startdate = t2.PlainDate AND t1.MetricCode = t2.metriccode
		
	END
	ELSE IF @TimeFrame = 'week'
	BEGIN
		SET ROWCOUNT @TimeUnits
		INSERT INTO @t1 (PlainYearWeek)
		SELECT DISTINCT date_YearWeek FROM MetricBusinessDays (NOLOCK)
		WHERE Plaindate <= @LatestDateToUse ORDER BY date_YearWeek DESC
		SET ROWCOUNT 0
		
		UPDATE @t1 SET StartDate = (SELECT MIN(PlainDate) FROM MetricBusinessDays t2 (NOLOCK) WHERE t1.PlainYearWeek = t2.date_YearWeek)
					,EndDate = (SELECT MAX(PlainDate) FROM MetricBusinessDays t3 (NOLOCK) WHERE t3.PlainDate <= @LatestDateToUse AND t1.PlainYearWeek = t3.date_YearWeek)
		FROM @t1 t1		

		INSERT INTO #TimeLineResults  (Goal, PeriodGoal, Caption, CategoryCaption, CategoryCaptionFull, SortingColumn, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood
							, TimeUnits, EarliestDateToUse, LatestDateToUse, TimeFrameMax, CategoryCode, MetricCode, SortingAssist
							, TimeFrameAve, x_summary, NumberTimeUnitsUsedForAverage, sort
							, DateToUse, Heading, cumulative, TopLevelMetric, Active, startdate, enddate, Average, Annualize, BadData, TimeHeading, TimeHeadingTitle)
			SELECT Goal = t3.GoalWeek
				,PeriodGoal = t3.GoalWeek
				,t2.TopLevelCaption AS Caption -- t2
				,t2.Caption AS CategoryCaption -- t2  
				,t2.CaptionFull AS CategoryCaptionFull -- t2
				,right('0000000000' + ltrim(CONVERT(varchar(10), t2.sort)), 10) + t2.TopLevelMetric AS SortingColumn  -- t2
				,FormatText  
				,ISNULL(NumDigitsAfterDecimal, 0) AS NumDigitsAfterDecimal
				,t3.PlusDeltaIsGood 
				,@TimeUnits AS TimeUnits
				,@EarliestDateToUse AS EarliestDateToUse
				,@LatestDateToUse AS LatestDateToUse
				,@HighestTimeFrameValue AS TimeFrameMax
				,@CategoryCode
				,t2.MetricCode  -- t2
				,t1.PlainYearWeek AS SortingAssist -- t1
				,TimeFrameAve = CONVERT(decimal(20, 5), 0)
				,t2.x_summary  -- t2
				,@NumberTimeUnitsUsedForAverage as NumberTimeUnitsUsedForAverage
				,t2.sort   -- t2
				,@DateToUse AS DateToUse
				,t1.PlainYearWeek as Heading  -- t1
				,t3.cumulative
				,t2.TopLevelMetric -- t2
				,t2.Active -- t2
				,t1.StartDate -- t1
				,t1.EndDate -- t1
				,0 as Average
				,t3.Annualize
				,BadData = t2.BadData, --t2
				'',
				'Last day of data'
			FROM @t1 t1, #tempMetrics t2 INNER JOIN metricitem t3 WITH (NOLOCK) ON t2.MetricCode = t3.MetricCode

			UPDATE #TimeLineResults SET TimeHeading = CONVERT(VARCHAR(2), DATEPART(Month, EndDate)) + '/' + CONVERT(VARCHAR(2), DATEPART(day, EndDate))


			Update #TimeLineResults	SET TimeFrameAve = t2.ThisWtd
			FROM #TimeLineResults t1 INNER JOIN MetricDetail t2 (NOLOCK) ON t1.enddate = t2.PlainDate AND t1.MetricCode = t2.Metriccode
				
			Update #TimeLineResults	SET TimeFrameAve = TimeFrameAve * 52 WHERE Annualize = 1		
	END
	ELSE IF @TimeFrame = 'month'
	BEGIN
		IF @Style IN ('', 'Normal')
		BEGIN
			SET ROWCOUNT @TimeUnits
			INSERT INTO @t1 (PlainYear, PlainMonth)
			SELECT DISTINCT DATEPART(year, PlainDate), RIGHT('0' + CONVERT(varchar(2), DATEPART(month, PlainDate)), 2) FROM MetricBusinessDays (NOLOCK)
			WHERE Plaindate <= @LatestDateToUse ORDER BY DATEPART(year, PlainDate) DESC, RIGHT('0' + CONVERT(varchar(2), DATEPART(month, PlainDate)), 2) DESC
			SET ROWCOUNT 0

			UPDATE @t1 SET StartDate = (SELECT MIN(PlainDate) FROM MetricBusinessDays t2 
											WHERE t1.PlainYear = DATEPART(year, t2.PlainDate) AND t1.PlainMonth = RIGHT('0' + CONVERT(varchar(2), DATEPART(month, t2.PlainDate)), 2))
						,EndDate = (SELECT MAX(PlainDate) FROM MetricBusinessDays t3 
											WHERE t3.PlainDate <= @LatestDateToUse AND t1.PlainYear = DATEPART(year, t3.PlainDate) AND t1.PlainMonth = RIGHT('0' + CONVERT(varchar(2), DATEPART(month, t3.PlainDate)), 2) )
			FROM @t1 t1

			INSERT INTO #TimeLineResults  (Goal, PeriodGoal, Caption, CategoryCaption, CategoryCaptionFull, SortingColumn, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood
							, TimeUnits, EarliestDateToUse, LatestDateToUse, TimeFrameMax, CategoryCode, MetricCode, SortingAssist
							, TimeFrameAve, x_summary, NumberTimeUnitsUsedForAverage, sort
							, DateToUse, Heading, cumulative, TopLevelMetric, Active, startdate, enddate, Average, Annualize, BadData, TimeHeadingTitle)
			SELECT Goal = t3.GoalMonth
				,PeriodGoal = t3.GoalMonth
				,t2.TopLevelCaption AS Caption -- t2
				,t2.Caption AS CategoryCaption -- t2  
				,t2.CaptionFull AS CategoryCaptionFull -- t2
				,right('0000000000' + ltrim(CONVERT(varchar(10), t2.sort)), 10) + t2.TopLevelMetric AS SortingColumn  -- t2
				,FormatText  
				,ISNULL(NumDigitsAfterDecimal, 0) AS NumDigitsAfterDecimal
				,t3.PlusDeltaIsGood 
				,@TimeUnits AS TimeUnits
				,@EarliestDateToUse AS EarliestDateToUse
				,@LatestDateToUse AS LatestDateToUse
				,@HighestTimeFrameValue AS TimeFrameMax
				,@CategoryCode
				,t2.MetricCode  -- t2
				,t1.PlainMonth AS SortingAssist -- t1
				,TimeFrameAve = CONVERT(decimal(20, 5), 0)
				,t2.x_summary  -- t2
				,@NumberTimeUnitsUsedForAverage as NumberTimeUnitsUsedForAverage
				,t2.sort   -- t2
				,@DateToUse AS DateToUse
				,t1.PlainYear as Heading  -- t1
				,t3.cumulative
				,t2.TopLevelMetric -- t2
				,t2.Active -- t2
				,t1.StartDate -- t1
				,t1.EndDate -- t1
				,0 as Average
				,t3.Annualize
				,BadData = t2.BadData  --t2
				,TimeHeadingTitle = @MonthTitle
			FROM @t1 t1, #tempMetrics t2 INNER JOIN metricitem t3 WITH (NOLOCK) ON t2.MetricCode = t3.MetricCode

			Update #TimeLineResults	SET TimeHeading = LEFT(DATENAME(month, DATEADD(day, -1, EndDate)), 3) + ' ' + RIGHT(CONVERT(varchar(4), DATEPART(year, DATEADD(day, -1, EndDate))), 2)

			Update #TimeLineResults	SET TimeFrameAve = t2.ThisMtd
			FROM #TimeLineResults t1 INNER JOIN MetricDetail t2 (NOLOCK) ON t1.enddate = t2.PlainDate AND t1.MetricCode = t2.Metriccode

			Update #TimeLineResults	SET TimeFrameAve = TimeFrameAve * 12 WHERE Annualize = 1
		END
		ELSE
		BEGIN
			SET ROWCOUNT @TimeUnits
			INSERT INTO @t1 (date_AltYear01, date_AltMonth01)
			SELECT DISTINCT date_AltYear01, RIGHT('0' + date_AltMonth01, 2) FROM MetricBusinessDays WHERE date_AltYear01 IS NOT NULL 
					AND Plaindate <= @LatestDateToUse ORDER BY date_AltYear01 DESC, RIGHT('0' + date_AltMonth01, 2) DESC
			SET ROWCOUNT 0

			UPDATE @t1 SET StartDate = (SELECT MIN(PlainDate) FROM MetricBusinessDays t2 WHERE t1.date_AltYear01 = t2.date_AltYear01 AND CONVERT(int, t1.date_AltMonth01) = CONVERT(int, t2.date_AltMonth01))
						,EndDate = (SELECT MAX(PlainDate) FROM MetricBusinessDays t3 WHERE  t3.PlainDate <= @LatestDateToUse AND t1.date_AltYear01 = t3.date_AltYear01 AND CONVERT(int, t1.date_AltMonth01) = CONVERT(int, t3.date_AltMonth01))		
			FROM @t1 t1

			INSERT INTO #TimeLineResults  (Goal, PeriodGoal, Caption, CategoryCaption, CategoryCaptionFull, SortingColumn, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood
								, TimeUnits, EarliestDateToUse, LatestDateToUse, TimeFrameMax, CategoryCode, MetricCode, SortingAssist
								, TimeFrameAve, x_summary, NumberTimeUnitsUsedForAverage, sort
								, DateToUse, Heading, cumulative, TopLevelMetric, Active, startdate, enddate, Average, Annualize, BadData, TimeHeading, TimeHeadingTitle)
			SELECT
					t3.GoalMonth AS Goal,
					PeriodGoal = t3.GoalMonth,
					t2.TopLevelCaption AS Caption,
					t2.Caption AS CategoryCaption,
					t2.CaptionFull AS CategoryCaptionFull,
					right('0000000000'+ ltrim(CONVERT(varchar(10), t2.sort)), 10) + t2.TopLevelMetric AS SortingColumn,
					FormatText,
					ISNULL(NumDigitsAfterDecimal, 0) AS NumDigitsAfterDecimal,
					t3.PlusDeltaIsGood,
					@TimeUnits AS TimeUnits,
					@EarliestDateToUse AS EarliestDateToUse,
					@LatestDateToUse AS LatestDateToUse,
					@HighestTimeFrameValue AS TimeFrameMax,
					@CategoryCode as CategoryCode,
					t2.MetricCode, -- Was t1.MetricCode before 3/14/2011
					SortingAssist = t5.date_AltMonth01, -- t1.PlainMonth as SortingAssist, -- SortingAssist = t5.date_AltMonth01, -- select date_AltMonth01 from MetricBusinessDays
					TimeFrameAve = dbo.fnc_get_Metric_xTD_Alternate(t2.metriccode, t5.EndDate, 'AltMonth01'),
					t2.x_summary,
					@NumberTimeUnitsUsedForAverage as NumberTimeUnitsUsedForAverage,
					t2.sort,
					@DateToUse AS DateToUse,
					t5.date_AltYear01  as Heading, -- t1.PlainYear as Heading,
					t3.cumulative,
					t2.TopLevelMetric,
					t2.Active,
					t5.StartDate,		--				StartDate =  dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', t1.PlainDate),
					t5.EndDate,			--				EndDate =  dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', dbo.fnc_Metric_DateAdd(@Style, 'month', 1, t1.PlainDate)),
					0 as Average,
					t3.Annualize,
					BadData = t2.BadData,
					TimeHeading = LEFT(DATENAME(month, t5.EndDate), 3) + ' ' + CONVERT(varchar(10), DATEPART(day, t5.EndDate)),
					TimeHeadingTitle = @MonthTitle + ' ending'
			FROM @t1 t5, #tempMetrics t2 LEFT OUTER JOIN metricitem t3 WITH (NOLOCK) ON t2.MetricCode = t3.MetricCode

			Update #TimeLineResults	SET TimeFrameAve = TimeFrameAve * 13 WHERE Annualize = 1
		END

	END
	ELSE IF @TimeFrame = 'quarter'
	BEGIN
		IF @Style IN ('', 'Normal')
		BEGIN
			SET ROWCOUNT @TimeUnits
			INSERT INTO @t1 (PlainYear, PlainQuarter)
			SELECT DISTINCT DATEPART(year, PlainDate), CONVERT(varchar(1), DATEPART(quarter, PlainDate)) FROM MetricBusinessDays 
			WHERE Plaindate <= @LatestDateToUse ORDER BY DATEPART(year, PlainDate) DESC, CONVERT(varchar(1), DATEPART(quarter, PlainDate)) DESC
			SET ROWCOUNT 0

			UPDATE @t1 SET StartDate = (SELECT MIN(PlainDate) FROM MetricBusinessDays t2
											WHERE t1.PlainYear = DATEPART(year, t2.PlainDate) AND t1.PlainQuarter = DATEPART(quarter, t2.PlainDate))
						,EndDate = (SELECT MAX(PlainDate) FROM MetricBusinessDays t3
											WHERE t3.PlainDate <= @LatestDateToUse AND t1.PlainYear = DATEPART(year, t3.PlainDate) AND t1.PlainQuarter = DATEPART(quarter, t3.PlainDate))
			FROM @t1 t1

			INSERT INTO #TimeLineResults  (Goal, PeriodGoal, Caption, CategoryCaption, CategoryCaptionFull, SortingColumn, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood
								, TimeUnits, EarliestDateToUse, LatestDateToUse, TimeFrameMax, CategoryCode, MetricCode, SortingAssist
								, TimeFrameAve, x_summary, NumberTimeUnitsUsedForAverage, sort
								, DateToUse, Heading, cumulative, TopLevelMetric, Active, startdate, enddate, Average, Annualize, BadData, TimeHeading, TimeHeadingTitle)		
			SELECT Goal = t3.GoalQuarter
				,PeriodGoal = t3.GoalQuarter			
				,t2.TopLevelCaption AS Caption 
				,t2.Caption AS CategoryCaption
				,t2.CaptionFull AS CategoryCaptionFull
				,right('0000000000'+ ltrim(CONVERT(varchar(10), t2.sort)), 10) + t2.TopLevelMetric AS SortingColumn
				,FormatText
				,ISNULL(NumDigitsAfterDecimal, 0) AS NumDigitsAfterDecimal
				,t3.PlusDeltaIsGood
				,@TimeUnits AS TimeUnits
				,@EarliestDateToUse AS EarliestDateToUse
				,@LatestDateToUse AS LatestDateToUse
				,@HighestTimeFrameValue AS TimeFrameMax
				,@CategoryCode
				,t2.MetricCode
				,t1.PlainQuarter AS SortingAssist
				,TimeFrameAve = CONVERT(decimal(20, 5), 0)
				,t2.x_summary
				,@NumberTimeUnitsUsedForAverage as NumberTimeUnitsUsedForAverage
				,t2.sort
				,@DateToUse AS DateToUse
				,t1.PlainYear as Heading
				,t3.cumulative
				,t2.TopLevelMetric
				,t2.Active
				,t1.StartDate
				,t1.EndDate
				,0 as Average
				,t3.Annualize
				,BadData = t2.BadData
				,TimeHeading = 'Q' + CONVERT(varchar(2), t1.PlainQuarter) + '-' + RIGHT(CONVERT(varchar(4), t1.PlainYear), 2)
				,'Quarter'
			FROM @t1 t1, #tempMetrics t2 LEFT OUTER JOIN metricitem t3 WITH (NOLOCK) ON t2.MetricCode = t3.MetricCode

			UPDATE #TimeLineResults SET TimeFrameAve = CASE WHEN Annualize = 1 THEN TimeFrameAve * 4
															ELSE ISNULL(dbo.fnc_get_Metric_xTD_Alternate(metriccode, EndDate, 'Quarter'), 0)
														END

		END
		ELSE
		BEGIN
			-- QUARTER
			SET ROWCOUNT @TimeUnits		
			INSERT INTO @t1 (date_AltYear01, date_AltQuarter01)
			SELECT DISTINCT date_AltYear01, RIGHT('0' + date_AltQuarter01, 2) FROM MetricBusinessDays WHERE date_AltYear01 IS NOT NULL 
				AND Plaindate <= @LatestDateToUse ORDER BY date_AltYear01 DESC, RIGHT('0' + date_AltQuarter01, 2) DESC
			SET ROWCOUNT 0

			UPDATE @t1 SET StartDate = (SELECT MIN(PlainDate) FROM MetricBusinessDays t2 WHERE t1.date_AltYear01 = t2.date_AltYear01 AND CONVERT(int, t1.date_AltQuarter01) = CONVERT(int, t2.date_AltQuarter01))
						,EndDate = (SELECT MAX(PlainDate) FROM MetricBusinessDays t3 WHERE t3.PlainDate <= @LatestDateToUse AND t1.date_AltYear01 = t3.date_AltYear01 AND CONVERT(int, t1.date_AltQuarter01) = CONVERT(int, t3.date_AltQuarter01))
			FROM @t1 t1		

			INSERT INTO #TimeLineResults  (Goal, PeriodGoal, Caption, CategoryCaption, CategoryCaptionFull, SortingColumn, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood
								, TimeUnits, EarliestDateToUse, LatestDateToUse, TimeFrameMax, CategoryCode, MetricCode, SortingAssist
								, TimeFrameAve, x_summary, NumberTimeUnitsUsedForAverage, sort
								, DateToUse, Heading, cumulative, TopLevelMetric, Active, startdate, enddate, Average, Annualize, BadData, TimeHeading, TimeHeadingTitle)
			SELECT
					t3.GoalQuarter AS Goal,
					PeriodGoal = t3.GoalQuarter,
					t2.TopLevelCaption AS Caption,
					t2.Caption AS CategoryCaption,
					t2.CaptionFull AS CategoryCaptionFull,
					right('0000000000'+ ltrim(CONVERT(varchar(10), t2.sort)), 10) + t2.TopLevelMetric AS SortingColumn,
					FormatText,
					ISNULL(NumDigitsAfterDecimal, 0) AS NumDigitsAfterDecimal,
					t3.PlusDeltaIsGood,
					@TimeUnits AS TimeUnits,
					@EarliestDateToUse AS EarliestDateToUse,
					@LatestDateToUse AS LatestDateToUse,
					@HighestTimeFrameValue AS TimeFrameMax,
					@CategoryCode as CategoryCode,
					t2.MetricCode, -- Was t1.MetricCode before 3/14/2011
					SortingAssist = t5.date_AltQuarter01, 
					TimeFrameAve = dbo.fnc_get_Metric_xTD_Alternate(t2.metriccode, t5.EndDate, 'AltQuarter01'),
					t2.x_summary,
					@NumberTimeUnitsUsedForAverage as NumberTimeUnitsUsedForAverage,
					t2.sort,
					@DateToUse AS DateToUse,
					t5.date_AltYear01  as Heading, -- t1.PlainYear as Heading,
					t3.cumulative,
					t2.TopLevelMetric,
					t2.Active,
					t5.StartDate,
					t5.EndDate,
					0 as Average,
					t3.Annualize,
					BadData = t2.BadData,
					TimeHeading = LEFT(DATENAME(month, t5.EndDate), 3) + ' ' + CONVERT(varchar(10), DATEPART(day, t5.EndDate)),
					TimeHeadingTitle = @QuarterTitle + ' ending (' + CONVERT(varchar(10), t5.EndDate, 10) + ')'
			FROM @t1 t5, #tempMetrics t2 LEFT OUTER JOIN metricitem t3 WITH (NOLOCK) ON t2.MetricCode = t3.MetricCode 

			Update #TimeLineResults	SET TimeFrameAve = TimeFrameAve * 4 WHERE Annualize = 1	
			UPDATE #TimeLineResults SET TimeHeading = 'Q' + CONVERT(varchar(4), DATEPART(quarter, StartDate)) + '-' + RIGHT(CONVERT(varchar(4), DATEPART(yy, StartDate)), 2)
		END
	END
    ELSE IF @TimeFrame = 'year'
	BEGIN
		IF @Style IN ('', 'Normal')
		BEGIN	
			SET ROWCOUNT @TimeUnits
			INSERT INTO @t1 (PlainYear)
			SELECT DISTINCT DATEPART(year, PlainDate) FROM MetricBusinessDays WHERE Plaindate <= @LatestDateToUse ORDER BY DATEPART(year, PlainDate) DESC
			SET ROWCOUNT 0

			UPDATE @t1 SET StartDate = (SELECT MIN(PlainDate) FROM MetricBusinessDays t2
											WHERE t1.PlainYear = DATEPART(year, t2.PlainDate))
						,EndDate = (SELECT MAX(PlainDate) FROM MetricBusinessDays t3
											WHERE t3.PlainDate <= @LatestDateToUse AND t1.PlainYear = DATEPART(year, t3.PlainDate))
			FROM @t1 t1

			INSERT INTO #TimeLineResults (Goal, PeriodGoal, Caption, CategoryCaption, CategoryCaptionFull, SortingColumn, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood
								, TimeUnits, EarliestDateToUse, LatestDateToUse, TimeFrameMax, CategoryCode, MetricCode, SortingAssist
								, TimeFrameAve, x_summary, NumberTimeUnitsUsedForAverage, sort
								, DateToUse, Heading, cumulative, TopLevelMetric, Active, startdate, enddate, Average, Annualize, BadData, TimeHeading, TimeHeadingTitle)
			SELECT t3.GoalYear AS Goal
				,PeriodGoal = t3.GoalYear
				,t2.TopLevelCaption AS Caption 
				,t2.Caption AS CategoryCaption
				,t2.CaptionFull AS CategoryCaptionFull
				,right('0000000000'+ ltrim(CONVERT(varchar(10), t2.sort)), 10) + t2.TopLevelMetric AS SortingColumn
				,FormatText
				,ISNULL(NumDigitsAfterDecimal, 0) AS NumDigitsAfterDecimal
				,t3.PlusDeltaIsGood
				,@TimeUnits AS TimeUnits
				,@EarliestDateToUse AS EarliestDateToUse
				,@LatestDateToUse AS LatestDateToUse
				,@HighestTimeFrameValue AS TimeFrameMax
				,@CategoryCode
				,t2.MetricCode
				,t1.PlainYear AS SortingAssist
				,TimeFrameAve = CONVERT(decimal(20, 5), 0)
				,t2.x_summary
				,@NumberTimeUnitsUsedForAverage as NumberTimeUnitsUsedForAverage
				,t2.sort
				,@DateToUse AS DateToUse
				,t1.PlainYear as Heading
				,t3.cumulative
				,t2.TopLevelMetric
				,t2.Active
				,t1.StartDate
				,t1.EndDate
				,0 as Average
				,t3.Annualize
				,BadData = t2.BadData
				,TimeHeading = CONVERT(varchar(4), t1.PlainYear)
				,'Year'
			FROM @t1 t1, #tempMetrics t2 LEFT OUTER JOIN metricitem t3 WITH (NOLOCK) ON t2.MetricCode = t3.MetricCode							

			Update #TimeLineResults	SET TimeFrameAve = t2.ThisYtd
			FROM #TimeLineResults t1 INNER JOIN MetricDetail t2 (NOLOCK) ON t1.enddate = t2.PlainDate AND t1.MetricCode = t2.Metriccode
		END
		ELSE
		BEGIN
			SET ROWCOUNT @TimeUnits
			INSERT INTO @t1 (date_AltYear01)
			SELECT DISTINCT date_AltYear01 FROM MetricBusinessDays WHERE Plaindate <= @LatestDateToUse ORDER BY date_AltYear01 DESC
			SET ROWCOUNT 0

			UPDATE @t1 SET StartDate = (SELECT MIN(PlainDate) FROM MetricBusinessDays t2 WHERE t1.date_AltYear01 = t2.date_AltYear01)
						,EndDate = (SELECT MAX(PlainDate) FROM MetricBusinessDays t3 WHERE t3.PlainDate <= @LatestDateToUse AND t1.date_AltYear01 = t3.date_AltYear01)
			FROM @t1 t1

			INSERT INTO #TimeLineResults (Goal, PeriodGoal, Caption, CategoryCaption, CategoryCaptionFull, SortingColumn, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood
								, TimeUnits, EarliestDateToUse, LatestDateToUse, TimeFrameMax, CategoryCode, MetricCode, SortingAssist
								, TimeFrameAve, x_summary, NumberTimeUnitsUsedForAverage, sort
								, DateToUse, Heading, cumulative, TopLevelMetric, Active, startdate, enddate, Average, Annualize, BadData, TimeHeading, TimeHeadingTitle)
			SELECT Goal = t3.GoalYear
				,PeriodGoal = t3.GoalYear
				,t2.TopLevelCaption AS Caption 
				,t2.Caption AS CategoryCaption
				,t2.CaptionFull AS CategoryCaptionFull
				,right('0000000000'+ ltrim(CONVERT(varchar(10), t2.sort)), 10) + t2.TopLevelMetric AS SortingColumn
				,FormatText
				,ISNULL(NumDigitsAfterDecimal, 0) AS NumDigitsAfterDecimal
				,t3.PlusDeltaIsGood
				,@TimeUnits AS TimeUnits
				,@EarliestDateToUse AS EarliestDateToUse
				,@LatestDateToUse AS LatestDateToUse
				,@HighestTimeFrameValue AS TimeFrameMax
				,@CategoryCode
				,t2.MetricCode
				,t1.date_AltYear01 AS SortingAssist
				,TimeFrameAve = dbo.fnc_get_Metric_xTD_Alternate(t2.metriccode, t1.EndDate, 'AltYear01')
				,t2.x_summary
				,@NumberTimeUnitsUsedForAverage as NumberTimeUnitsUsedForAverage
				,t2.sort
				,@DateToUse AS DateToUse
				,t1.date_AltYear01 as Heading
				,t3.cumulative
				,t2.TopLevelMetric
				,t2.Active
				,t1.StartDate
				,t1.EndDate
				,0 as Average
				,t3.Annualize
				,BadData = t2.BadData
				,TimeHeading = CONVERT(varchar(4), t1.date_AltYear01)
				,'Year'
			FROM @t1 t1, #tempMetrics t2 LEFT OUTER JOIN metricitem t3 WITH (NOLOCK) ON t2.MetricCode = t3.MetricCode							
		
		END
	END

	-- Account for when data doesn't exist.
-- SELECT * FROM #TimeLineResults -- WHERE EarliestDateToUse IS NULL OR LatestDateToUse IS NULL
-- RETURN
--	IF EXISTS(SELECT * FROM #TimeLineResults WHERE EarliestDateToUse IS NULL OR LatestDateToUse IS NULL)
--	BEGIN
		DELETE #TimeLineResults WHERE SortingAssist IS NULL
		UPDATE #TimeLineResults SET EarliestDateToUse = ISNULL(EarliestDateToUse, (SELECT MIN(startdate) FROM #TimeLineResults))
						,LatestDateToUse = ISNULL(LatestDateToUse, (SELECT MAX(enddate) FROM #TimeLineResults))
						,TimeUnits = (SELECT TOP 1 COUNT(*) FROM #TimeLineResults GROUP BY MetricCode)

--	END


	--******************************************************************************************************************
	--******************************************************************************************************************
	-- @HighestTimeFrameValue is used in the web page (TimeFrameMax).
	-- The statement below is valid for all time frames.
	SELECT @LastNewYearsEve = CONVERT(datetime, CONVERT(char(4), DATEPART(year, @LatestDateToUse)-1) + '1231')
	IF @TimeFrame = 'day'
		SELECT @HighestTimeFrameValue = DATEPART(dy, @LatestDateToUse)
	ELSE IF @TimeFrame = 'week'
		SELECT @HighestTimeFrameValue =  
			CASE WHEN DATEPART(wk, CONVERT(datetime, CONVERT(char(4), DATEPART(year, @LatestDateToUse)) + '0107')) = 1
				THEN DATEPART(wk, @LatestDateToUse)
				ELSE 
					CASE WHEN DATEPART(week, @LatestDateToUse) = 1
						THEN DATEPART(week, @LastNewYearsEve) 
						-	CASE WHEN DATEPART(wk, CONVERT(datetime, CONVERT(char(4), DATEPART(year, @LastNewYearsEve)) + '0107')) = 1
								THEN 0 
							ELSE 1
							END
						ELSE DATEPART(week, @LatestDateToUse) - 1 
					END
			END
	ELSE IF @TimeFrame = 'month'
		SELECT @HighestTimeFrameValue = DATEPART(month, @LatestDateToUse)
	ELSE IF @TimeFrame = 'quarter'
		SELECT @HighestTimeFrameValue = DATEPART(quarter, @LatestDateToUse)
	ELSE IF @TimeFrame = 'year'
		SELECT @HighestTimeFrameValue = DATEPART(year, @LatestDateToUse)

	IF @WeightedAveragesForNoncumulative = 'Y'  -- Need to calculate the SumNumerator and SumDenominator for both to be used in the summary.  They will not have been populated, yet.
	BEGIN
		/* This code handles NON-Cumulative with WEIGHTED option on. */
		DECLARE @LastDateToUseForWeighted datetime
		IF @IncludeMostRecentPeriodForVariance <> 'Y'
		BEGIN
			SELECT @LastDateToUseForWeighted = MAX(enddate) FROM #TimeLineResults WHERE enddate <> @LatestDateToUse
		END
		ELSE
		BEGIN
			SELECT @LastDateToUseForWeighted = MAX(enddate) FROM #TimeLineResults
		END

		UPDATE #tempMetrics SET 
			SumNumerator = (SELECT SUM(ISNULL(DailyCount, 0)) FROM MetricDetail t1 WITH (NOLOCK) WHERE PlainDate >= @EarliestDateToUse AND t1.PlainDate <= @LastDateToUseForWeighted AND t1.MetricCode = #tempMetrics.MetricCode)
			,SumDenominator = (SELECT SUM(ISNULL(DailyTotal, 0)) FROM MetricDetail t2 WITH (NOLOCK) WHERE PlainDate >= @EarliestDateToUse AND t2.PlainDate <= @LastDateToUseForWeighted AND t2.MetricCode = #tempMetrics.MetricCode)
		WHERE Cumulative = 0
		
		UPDATE #TimeLineResults set NumberTimeUnitsUsedForAverage = CASE WHEN @IncludeMostRecentPeriodForVariance <> 'Y' THEN TimeUnits - 1 ELSE TimeUnits END
			,SummaryDone = 1
			,TimeFrameMax = @HighestTimeFrameValue
			,Goal =  	Goal 
			,average = 	CASE WHEN SumDenominator = 0 THEN 0 ELSE SumNumerator / SumDenominator END
		FROM #TimeLineResults INNER JOIN #tempMetrics ON #TimeLineResults.MetricCode = #tempMetrics.MetricCode		
		WHERE #TimeLineResults.Cumulative = 0
	END

	IF @RespectCumulativeOnTimeline = 'Y'
	BEGIN
		-- **** CUMULATIVE and "Respect Cumulative for Summary" ****
		UPDATE #TimeLineResults set NumberTimeUnitsUsedForAverage = CASE WHEN @IncludeMostRecentPeriodForVariance <> 'Y' THEN TimeUnits - 1 ELSE TimeUnits END
			,SummaryDone = 2
			,TimeFrameMax = @HighestTimeFrameValue
			,Goal =  	Goal * CASE WHEN @IncludeMostRecentPeriodForVariance <> 'Y' THEN (TimeUnits - 1) ELSE TimeUnits END 
			,average = 	(	select sum(t.timeframeave)
									from #TimeLineResults t
									where t.metriccode = #TimeLineResults.metriccode
										and t.enddate <> CASE WHEN @IncludeMostRecentPeriodForVariance <> 'Y' THEN @LatestDateToUse ELSE '19000101' END
								)							
		FROM #TimeLineResults INNER JOIN #tempMetrics ON #TimeLineResults.MetricCode = #tempMetrics.MetricCode
		WHERE #TimeLineResults.cumulative = 1
	END

	UPDATE #TimeLineResults set NumberTimeUnitsUsedForAverage = TimeUnits - CASE WHEN @IncludeMostRecentPeriodForVariance <> 'Y' THEN 1 ELSE 0 END
		,SummaryDone = 3
		,TimeFrameMax = @HighestTimeFrameValue
		,Goal =  	Goal 
		,average = 	(	select sum(t.timeframeave)/count(t.timeframeave) 
							from #TimeLineResults t
							where t.metriccode = #TimeLineResults.metriccode
								and enddate <> CASE WHEN @IncludeMostRecentPeriodForVariance <> 'Y' THEN @LatestDateToUse ELSE '19000101' END
						)
	WHERE ISNULL(#TimeLineResults.SummaryDone, 0) = 0

		
	SELECT @DateOrderLeftToRight = IsNull(DateOrderLeftToRight,'CurrentPrior') from metriccategory where categorycode = @CategoryCode
	--PTS 36393 !!!! This was incorrect. Code uncommented to correct.  Support for DESC added for completeness.
	IF @DateOrderLeftToRight <> 'CurrentPrior' 
		AND @DateOrderLeftToRight <> 'DESC' 
	BEGIN
		SELECT t1.*, t2.CaptionFull, DataSourceSN = ISNULL(t2.DataSourceSN, 0),
			t1.BadData -- = (SELECT CASE WHEN EXISTS(SELECT sn FROM #metricdetail (NOLOCK) WHERE metricCode = t1.metriccode AND DailyValue IS NULL) THEN 'x' ELSE '' END)
		FROM #TimeLineResults t1 INNER JOIN MetricItem t2 ON t1.metriccode = t2.metriccode 
		WHERE t1.Active = 1
		ORDER BY t1.sortingcolumn, t1.startdate ASC
	END
	ELSE
	BEGIN
		select SummaryDone
			,t1.Goal, t1.Caption, t1.CategoryCaption, t1.CategoryCaptionFull, t1.SortingColumn, t1.FormatText, t1.NumDigitsAfterDecimal, 
			t1.PlusDeltaIsGood,	t1.TimeUnits, t1.EarliestDateToUse, t1.LatestDateToUse
			, t1.TimeFrameMax
			, t1.CategoryCode
			,MetricCode = t1.Metriccode -- ISNULL(t1.MetricCode, 'Metriccode cannot be determined because of missing data'), 
			,t1.SortingAssist, t1.TimeFrameAve, t1.x_summary, t1.NumberTimeUnitsUsedForAverage, t1.sort
			, t1.DateToUse, t1.Heading, 
			t1.cumulative, t1.TopLevelMetric, t1.Active, t1.startdate 
			,enddate -- = CASE WHEN t2.LastRunDate BETWEEN t1.startdate AND DATEADD(day, 1, t1.enddate) AND t2.LastRunDate > t1.startdate THEN t2.LastRunDate ELSE DATEADD(day, 1, t1.enddate) END
			, t1.Average, t1.Annualize, 
			t2.CaptionFull, DataSourceSN = ISNULL(t2.DataSourceSN, 0),
			t1.BadData, 
			t1.TimeHeading, t1.TimeHeadingTitle
			,t1.PeriodGoal
		 from #TimeLineResults t1 LEFT JOIN MetricItem t2 ON t1.TopLevelMetric = t2.metriccode 
			-- Added LEFT JOIN above to make sure that metric is displayed on page.  Also changed the join to be on TopLevelMetric.
		WHERE t1.Active = 1
		order by t1.sortingcolumn, t1.startdate desc
	END
GO
GRANT EXECUTE ON  [dbo].[MetricReportTimeFrame] TO [public]
GO
