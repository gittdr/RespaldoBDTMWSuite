SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[MetricXMetricYValue] ( 
	@CategoryCode VARCHAR(200), 
	@TimeFrame varchar(10) = 'LT',	-- 'LT'=Lifetime.  'DR'=Date Range Specified, 'TD'=ThisDay, 'LD'=LastDay (yesterday), 'TW'=ThisWeek, 'LW'=LastWeek, 'TM'=ThisMonth, 'LM'=LastMonth, 
									-- 'TQ'=ThisQuarter, 'LQ'=LastQuarter, 'TY'=ThisYear, 'LY'=LastYear, 'TF'=ThisFiscalYear, 'LF'=LastFiscalYear
	@DateStart datetime = NULL,		-- OPTIONAL: Only use if @TimeFrame = 'DS'
	@DateEnd datetime = NULL,		-- OPTIONAL: Only use if @TimeFrame = 'DS'
	@LikeFilter VARCHAR(100) = '%')	-- Really, only for debug.  Leave as DEFAULT.
AS
	SET NOCOUNT ON

	DECLARE @DateFirst int

	SELECT @DateFirst = settingvalue FROM metricgeneralsettings WHERE settingname = 'DateFirst'

	SET DATEFIRST @DateFirst

	-- MetricXMetricYValue 'Red', 'LW', NULL, NULL

	DECLARE @ThisDay datetime
	DECLARE @FirstMonth varchar(2)
	DECLARE @LastWeekStart datetime
	DECLARE @FirstDayOfMonth datetime
	DECLARE @FirstDayOfLastMonth datetime, @LastDayOfLastMonth datetime
	DECLARE @FirstDayOfYear datetime, @LastDayOfYear datetime
	DECLARE @FirstDayOfLastYear datetime

	DECLARE @Style varchar(10) -- @Style: 'Normal' or 'Alt01'
	DECLARE @AltTimeFrameMonth varchar(100), @AltTimeFrameQuarter varchar(100), @AltTimeFrameYear varchar(100)

	SELECT @Style = CASE WHEN EXISTS(SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'UseAlternateTimeFramesYN' AND SettingValue = 'Y')
						THEN 'Alt01' ELSE '' END
	IF @Style = 'Alt01'
		SELECT 
			@AltTimeFrameMonth = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameMonth'), 'Month')
			,@AltTimeFrameQuarter = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameQuarter'), 'Quarter')
			,@AltTimeFrameYear = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameYear'), 'Year')
	ELSE
		SELECT @AltTimeFrameMonth = 'Month', @AltTimeFrameQuarter = 'Quarter', @AltTimeFrameYear = 'Year'


	SELECT @ThisDay = MAX(t1.Plaindate) FROM metricdetail t1 (NOLOCK) INNER JOIN metriccategoryitems t2 (NOLOCK) ON t1.metriccode = t2.metriccode 
					WHERE t2.CategoryCode = @CategoryCode 
						AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')

	IF @TimeFrame = 'LT' -- Lifetime
	BEGIN
		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = 
				CASE WHEN ISNULL(t0.Cumulative, 0) = 0 THEN 
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END
				ELSE
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/AVG(ISNULL(DailyTotal, 0)) ELSE 0 END						
				END
				, 
			Goal = ISNULL(t0.GoalYear, 0), GoalDescription='Goal Year', t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
			LEFT JOIN MetricBusinessDays t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
		WHERE t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
			AND ISNULL(t3.BusinessDay, 0) = CASE WHEN DoNotIncludeTotalForNonBusinessDayYN = 'Y' THEN 1 ELSE ISNULL(t3.BusinessDay, 0) END
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalYear, t0.FormatText, t0.NumDigitsAfterDecimal, t0.Cumulative
		ORDER BY t2.sort, t1.metriccode
	END

	ELSE IF @TimeFrame = 'DR' -- Date Range.
	BEGIN
		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = 
				CASE WHEN ISNULL(t0.Cumulative, 0) = 0 THEN 
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END
				ELSE
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/AVG(ISNULL(DailyTotal, 0)) ELSE 0 END						
				END
				, 
			Goal = ISNULL(t0.GoalYear, 0), GoalDescription='Goal Year', t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
			LEFT JOIN MetricBusinessDays t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
		WHERE t1.PlainDate BETWEEN @DateStart AND @DateEnd 
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
			AND ISNULL(t3.BusinessDay, 0) = CASE WHEN DoNotIncludeTotalForNonBusinessDayYN = 'Y' THEN 1 ELSE ISNULL(t3.BusinessDay, 0) END
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalYear, t0.FormatText, t0.NumDigitsAfterDecimal, t0.Cumulative
		ORDER BY t2.sort, t1.metriccode
	END

	ELSE IF @TimeFrame = 'TD' -- This Day (most recent day)
	BEGIN
		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END, 
			Goal = ISNULL(t0.GoalDay, 0), GoalDescription='Goal Day', t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
		WHERE t1.PlainDate = @ThisDay
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalDay, t0.FormatText, t0.NumDigitsAfterDecimal
		ORDER BY t2.sort, t1.metriccode
	END
	ELSE IF @TimeFrame = 'LD' -- Yesterday
	BEGIN
		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END, 
			Goal = ISNULL(t0.GoalDay, 0), GoalDescription='Goal Day', t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
		WHERE t1.PlainDate = DATEADD(day, -1, @ThisDay)
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalDay, t0.FormatText, t0.NumDigitsAfterDecimal
		ORDER BY t2.sort, t1.metriccode
	END
	ELSE IF @TimeFrame = 'TW' -- This Week
	BEGIN
		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = 
				CASE WHEN ISNULL(t0.Cumulative, 0) = 0 THEN 
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END
				ELSE
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/AVG(ISNULL(DailyTotal, 0)) ELSE 0 END						
				END
				, 
			Goal = ISNULL(t0.GoalWeek, 0), GoalDescription='Goal Week', t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
			LEFT JOIN MetricBusinessDays t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
		WHERE t1.PlainDate BETWEEN DATEADD(day, 1-DATEPART(dw, @ThisDay), @ThisDay) AND @ThisDay
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
			AND ISNULL(t3.BusinessDay, 0) = CASE WHEN DoNotIncludeTotalForNonBusinessDayYN = 'Y' THEN 1 ELSE ISNULL(t3.BusinessDay, 0) END
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalWeek, t0.FormatText, t0.NumDigitsAfterDecimal, t0.Cumulative
		ORDER BY t2.sort, t1.metriccode
	END
	ELSE IF @TimeFrame = 'LW' -- Last Week
	BEGIN
		SELECT @LastWeekStart = DATEADD(week, -1, DATEADD(day, 1-DATEPART(dw, @ThisDay), @ThisDay))

		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = 
				CASE WHEN ISNULL(t0.Cumulative, 0) = 0 THEN 
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END
				ELSE
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/AVG(ISNULL(DailyTotal, 0)) ELSE 0 END						
				END
				, 
			Goal = ISNULL(t0.GoalWeek, 0), GoalDescription='Goal Week', t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
			LEFT JOIN MetricBusinessDays t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
		WHERE t1.PlainDate BETWEEN @LastWeekStart AND DATEADD(day, -1, DATEADD(week, 1, @LastWeekStart))
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
			AND ISNULL(t3.BusinessDay, 0) = CASE WHEN DoNotIncludeTotalForNonBusinessDayYN = 'Y' THEN 1 ELSE ISNULL(t3.BusinessDay, 0) END
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalWeek, t0.FormatText, t0.NumDigitsAfterDecimal, t0.Cumulative
		ORDER BY t2.sort, t1.metriccode
	END
	ELSE IF @TimeFrame = 'TM' -- This Month
	BEGIN
		IF @Style IN ('', 'Normal')
		BEGIN
			SELECT @FirstDayOfMonth = DATEADD(day, 1-DATEPART(day, @ThisDay), @ThisDay)
		END
		ELSE -- Get FIRST DAY OF PERIOD.
		BEGIN
			SELECT @FirstDayOfMonth = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', @ThisDay)
		END

		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = 
				CASE WHEN ISNULL(t0.Cumulative, 0) = 0 THEN 
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END
				ELSE
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/AVG(ISNULL(DailyTotal, 0)) ELSE 0 END						
				END
				, 
			Goal = ISNULL(t0.GoalMonth, 0), GoalDescription='Goal ' + @AltTimeFrameMonth, t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
			LEFT JOIN MetricBusinessDays t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
		WHERE t1.PlainDate BETWEEN @FirstDayOfMonth AND @ThisDay
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
			AND ISNULL(t3.BusinessDay, 0) = CASE WHEN DoNotIncludeTotalForNonBusinessDayYN = 'Y' THEN 1 ELSE ISNULL(t3.BusinessDay, 0) END
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalMonth, t0.FormatText, t0.NumDigitsAfterDecimal, t0.Cumulative
		ORDER BY t2.sort, t1.metriccode
	END
	ELSE IF @TimeFrame = 'LM' -- Last Month
	BEGIN	
		IF @Style IN ('', 'Normal')
		BEGIN	
			SELECT @FirstDayOfLastMonth = DATEADD(month, -1, DATEADD(day, 1-DATEPART(day, @ThisDay), @ThisDay))
					,@LastDayOfLastMonth = DATEADD(day, -1, DATEADD(month, 1, @FirstDayOfLastMonth))
		END
		ELSE -- Get FIRST DAY OF PERIOD.
		BEGIN
			SELECT @FirstDayOfMonth = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', dbo.fnc_Metric_DateAdd(@Style, 'month', -1, @ThisDay))
					,@LastDayOfLastMonth = DATEADD(day, -1, dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', @ThisDay))
		END

		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = 
				CASE WHEN ISNULL(t0.Cumulative, 0) = 0 THEN 
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END
				ELSE
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/AVG(ISNULL(DailyTotal, 0)) ELSE 0 END						
				END
				, 
			Goal = ISNULL(t0.GoalMonth, 0), GoalDescription='Goal ' + @AltTimeFrameMonth, t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
			LEFT JOIN MetricBusinessDays t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
		WHERE t1.PlainDate BETWEEN @FirstDayOfLastMonth AND @LastDayOfLastMonth
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
			AND ISNULL(t3.BusinessDay, 0) = CASE WHEN DoNotIncludeTotalForNonBusinessDayYN = 'Y' THEN 1 ELSE ISNULL(t3.BusinessDay, 0) END
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalMonth, t0.FormatText, t0.NumDigitsAfterDecimal, t0.Cumulative
		ORDER BY t2.sort, t1.metriccode
	END
	ELSE IF @TimeFrame = 'TQ' -- This Quarter
	BEGIN
		IF @Style IN ('', 'Normal')
		BEGIN	
			SELECT @FirstMonth =
				CASE WHEN DATEPART(month, @ThisDay) IN (1, 2, 3) THEN '01'
					WHEN DATEPART(month, @ThisDay) IN (4, 5, 6) THEN '04'
					WHEN DATEPART(month, @ThisDay) IN (7, 8, 9) THEN '07'
					WHEN DATEPART(month, @ThisDay) IN (10, 11, 12) THEN '10'
				END
			SELECT @DateStart = CONVERT(varchar(4), DATEPART(year, @ThisDay)) + @FirstMonth + '01'
					,@DateEnd = @ThisDay -- OLD WAS WRONG... DATEADD(day, -1, DATEADD(month, 3, @DateStart))
		END
		ELSE -- Get FIRST DAY OF PERIOD.
		BEGIN
			SELECT @DateStart = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'quarter', @ThisDay)
					,@DateEnd = @ThisDay
		END

		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = 
				CASE WHEN ISNULL(t0.Cumulative, 0) = 0 THEN 
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END
				ELSE
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/AVG(ISNULL(DailyTotal, 0)) ELSE 0 END						
				END
				, 
			Goal = ISNULL(t0.GoalQuarter, 0), GoalDescription='Goal ' + @AltTimeFrameQuarter, t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
			LEFT JOIN MetricBusinessDays t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
		WHERE t1.PlainDate BETWEEN  @DateStart AND @DateEnd
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
			AND ISNULL(t3.BusinessDay, 0) = CASE WHEN DoNotIncludeTotalForNonBusinessDayYN = 'Y' THEN 1 ELSE ISNULL(t3.BusinessDay, 0) END
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalQuarter, t0.FormatText, t0.NumDigitsAfterDecimal, t0.Cumulative
		ORDER BY t2.sort, t1.metriccode
	END
	ELSE IF @TimeFrame = 'LQ' -- Last Quarter
	BEGIN
		IF @Style IN ('', 'Normal')
		BEGIN	
			SELECT @FirstMonth =
				CASE WHEN DATEPART(month, @ThisDay) IN (1, 2, 3) THEN '01'
					WHEN DATEPART(month, @ThisDay) IN (4, 5, 6) THEN '04'
					WHEN DATEPART(month, @ThisDay) IN (7, 8, 9) THEN '07'
					WHEN DATEPART(month, @ThisDay) IN (10, 11, 12) THEN '10'
				END
			SELECT @DateStart = DATEADD(month, -3, CONVERT(varchar(4), DATEPART(year, @ThisDay)) + @FirstMonth + '01')
			SELECT @DateEnd = DATEADD(day, -1, DATEADD(month, 3, @DateStart))
		END
		ELSE -- Get FIRST DAY OF ALT Quarter.
		BEGIN
			SELECT @DateStart = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'quarter', dbo.fnc_Metric_DateAdd(@Style, 'quarter', -1, @ThisDay))
					,@DateEnd = DATEADD(day, -1, dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'quarter', @ThisDay))
		END	

		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = 
				CASE WHEN ISNULL(t0.Cumulative, 0) = 0 THEN 
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END
				ELSE
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/AVG(ISNULL(DailyTotal, 0)) ELSE 0 END						
				END
				, 
			Goal = ISNULL(t0.GoalQuarter, 0), GoalDescription='Goal ' + @AltTimeFrameQuarter, t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
			LEFT JOIN MetricBusinessDays t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
		WHERE t1.PlainDate BETWEEN @DateStart AND @DateEnd
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
			AND ISNULL(t3.BusinessDay, 0) = CASE WHEN DoNotIncludeTotalForNonBusinessDayYN = 'Y' THEN 1 ELSE ISNULL(t3.BusinessDay, 0) END
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalQuarter, t0.FormatText, t0.NumDigitsAfterDecimal, t0.Cumulative
		ORDER BY t2.sort, t1.metriccode
	END
	ELSE IF @TimeFrame = 'TY' -- This Year
	BEGIN
		IF @Style IN ('', 'Normal')
			SELECT @FirstDayOfYear = CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ThisDay)) + '0101')
		ELSE -- Get FIRST DAY OF YEAR.
			SELECT @FirstDayOfYear = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'year', @ThisDay)

		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = 
				CASE WHEN ISNULL(t0.Cumulative, 0) = 0 THEN 
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END
				ELSE
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/AVG(ISNULL(DailyTotal, 0)) ELSE 0 END						
				END
				, 
			Goal = ISNULL(t0.GoalYear, 0), GoalDescription='Goal Year', t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
			LEFT JOIN MetricBusinessDays t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
		WHERE t1.PlainDate BETWEEN @FirstDayOfYear AND @ThisDay -- OLD WAY WAS WRONG => DATEADD(day, -1, DATEADD(year, 1, @FirstDayOfYear))
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
			AND ISNULL(t3.BusinessDay, 0) = CASE WHEN DoNotIncludeTotalForNonBusinessDayYN = 'Y' THEN 1 ELSE ISNULL(t3.BusinessDay, 0) END
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalYear, t0.FormatText, t0.NumDigitsAfterDecimal, t0.Cumulative
		ORDER BY t2.sort, t1.metriccode
	END
	ELSE IF @TimeFrame = 'LY' -- This Year
	BEGIN
		IF @Style IN ('', 'Normal')
		BEGIN	
			SELECT @FirstDayOfLastYear = DATEADD(year, -1, CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ThisDay)) + '0101'))
			SELECT @DateEnd = DATEADD(day, -1, DATEADD(year, 1, @FirstDayOfLastYear))
		END
		ELSE -- Get FIRST DAY OF ALT Quarter.
		BEGIN
			SELECT @FirstDayOfLastYear = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'year', dbo.fnc_Metric_DateAdd(@Style, 'year', -1, @ThisDay))
					,@DateEnd = DATEADD(day, -1, dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'year', @ThisDay))
		END	
	
		SELECT t1.metriccode, MetricCaption = t0.Caption, t2.sort, t0.FormatText,
			MetricValue = 
				CASE WHEN ISNULL(t0.Cumulative, 0) = 0 THEN 
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/SUM(ISNULL(DailyTotal, 0)) ELSE 0 END
				ELSE
					CASE WHEN SUM(ISNULL(DailyTotal, 0)) <> 0 THEN SUM(ISNULL(DailyCount, 0))/AVG(ISNULL(DailyTotal, 0)) ELSE 0 END						
				END
				, 
			Goal = ISNULL(t0.GoalYear, 0), GoalDescription='Goal Year', t0.NumDigitsAfterDecimal
		FROM metricitem t0 INNER JOIN metricdetail t1 ON t0.metriccode = t1.metriccode INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode 
			LEFT JOIN MetricBusinessDays t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
		WHERE t1.PlainDate BETWEEN @FirstDayOfLastYear AND @DateEnd
			AND t2.CategoryCode = @CategoryCode 
			AND t2.metriccode LIKE ISNULL(@LikeFilter, '%')
			AND ISNULL(t3.BusinessDay, 0) = CASE WHEN DoNotIncludeTotalForNonBusinessDayYN = 'Y' THEN 1 ELSE ISNULL(t3.BusinessDay, 0) END
		GROUP BY t2.sort, t1.metriccode, t0.Caption, t0.GoalYear, t0.FormatText, t0.NumDigitsAfterDecimal, t0.Cumulative
		ORDER BY t2.sort, t1.metriccode
	END
GO
GRANT EXECUTE ON  [dbo].[MetricXMetricYValue] TO [public]
GO
