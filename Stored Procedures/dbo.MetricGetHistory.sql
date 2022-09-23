SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetHistory] (@MetricCode varchar(200), @YearFilter int = NULL) -- @YearFilter = 0 for ALL, NULL for most recent year.
AS
	SET NOCOUNT ON
	DECLARE @MinDate datetime, @MaxDate datetime, @MinYearReturned int, @MaxYearReturned int
	DECLARE @Style varchar(10), @AltTimeFrameMonth varchar(100), @AltTimeFrameQuarter varchar(100), @AltTimeFrameYear varchar(100)
	
	SELECT @Style = CASE WHEN EXISTS(SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'UseAlternateTimeFramesYN' AND SettingValue = 'Y')
						THEN 'Alt01' ELSE '' END
		
	IF @Style = 'Alt01'
		SELECT 
			@AltTimeFrameMonth = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameMonth'), 'Month')
			,@AltTimeFrameQuarter = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameQuarter'), 'Quarter')
			,@AltTimeFrameYear = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameYear'), 'Year')
	ELSE
		SELECT @AltTimeFrameMonth = 'm', @AltTimeFrameQuarter = 'q', @AltTimeFrameYear = 'year'
		
	SELECT t1.MetricCode, t1.PlainDate, t1.Upd_Daily, t1.Upd_Summary, t1.RunDurationLast, t1.RunDurationMax, t1.RunDurationMin, t1.DailyCount, t1.DailyTotal, t1.DailyValue, 
			t1.ThisYTD, t1.ThisQTD, t1.ThisMTD, t1.ThisWTD, t1.GoalDay, t1.GoalWeek, t1.GoalMonth, t1.GoalQuarter, t1.GoalYear, 
			t1.PlainYear, t1.PlainQuarter, t1.PlainMonth, t1.PlainWeek, t1.PlainDayOfWeek, t1.PlainYearWeek, 
			t1.FiscalYearlyAve, t1.ThisFiscalYTD, t1.GoalFiscalYear, t1.PlainFiscalYear, t1.Upd_SummaryFiscal, t2.date_AltYear01, t2.date_AltQuarter01, t2.date_AltMonth01,
			t1.sqlscriptrun
	INTO #md 
	FROM metricdetail t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.PlainDate = t2.PlainDate
	WHERE t1.metriccode = @Metriccode AND t1.PlainDate <= CONVERT(datetime, CONVERT(varchar(10), GETDATE(), 121))
/*
    CREATE INDEX tempidx_md_plainyear ON #md (PlainYear)
	CREATE INDEX tempidx_md_plainyearweek ON #md (PlainYearWeek)
    CREATE INDEX tempidx_md_plainyear_plainmonth ON #md (PlainYear, plainmonth)
	CREATE INDEX tempidx_md_plainyear_plainquarter ON #md (PlainYear, plainquarter)
*/
	SELECT @MinDate = MIN(PlainDate), @MaxDate = MAX(Plaindate) FROM #md 
	SELECT * INTO #mbd FROM metricbusinessdays (NOLOCK) WHERE Plaindate BETWEEN @MinDate AND @MaxDate	

	IF @Style = ''
	BEGIN
		SELECT @MinYearReturned = DATEPART(year, @MinDate), @MaxYearReturned = DATEPART(year, @MaxDate)	
		
		IF (ISNULL(@YearFilter, -1) = -1) SET @YearFilter = DATEPART(year, @MaxDate)	
			
		SELECT t1.PlainDate
				,[year] = t1.PlainYear
				,[q] = t1.PlainQuarter
				,[m] = t1.PlainMonth
				,t1.PlainWeek AS 'wk'
				,t1.DailyValue AS 'Daily Value', t1.DailyCount AS 'Daily Count', t1.DailyTotal AS 'Daily Total', t1.GoalDay As 'Goal Day'
				,t1.ThisWTD As 'Week to date'
				,'Week Value' = (Select m.ThisWTD from #md  m (nolock) where m.Plaindate = 
									(Select max(plaindate) from #md  m1 (nolock) where t1.plainyearweek = m1.plainyearweek )
								)
				,t1.GoalWeek As 'Goal Week'
				,t1.ThisMTD AS 'Month to date'
				,'Month Value' = (Select m.ThisMTD from #md  m (nolock) where m.Plaindate = 
									(Select max(plaindate) from #md  m1 (nolock) where t1.plainyear = m1.plainyear and t1.plainmonth = m1.plainmonth)  
								)
				,t1.GoalMonth AS 'Goal Month'
				,t1.ThisQTD AS 'Quarter to date'
				,'Quarter Value' = (Select m.ThisQTD from #md  m (nolock) where m.Plaindate = 
									(Select max(plaindate) from #md  m1 (nolock) where t1.plainyear = m1.plainyear and t1.plainquarter = m1.plainquarter)
								)
				,t1.GoalQuarter AS 'Goal Quarter'
				,t1.ThisYTD AS 'Year to date'
				,'Year Value' = (Select m.ThisYTD from #md  m (nolock) where m.Plaindate = 
									(Select max(plaindate) from #md  m1 (nolock) where t1.plainyear = m1.plainyear)
								)
				,t1.GoalYear AS 'Goal Year'
				,t1.ThisFiscalYTD AS 'Fiscal Year to date'
				,t1.FiscalYearlyAve AS 'Fiscal Year Value'
				,t1.GoalFiscalYear AS 'Goal Fiscal Year'
				,LEFT(convert(varchar(20), t1.Upd_Daily, 20), 16) AS 'Daily Job', LEFT(convert(varchar(20), t1.Upd_Summary, 20), 16) As 'Summary Refresh',  
				 t1.RunDurationLast AS 'Proc Time Last', t1.RunDurationMax AS 'Proc Time Hi', t1.RunDurationMin AS 'Proc Time Lo', 
				 BusinessDay = t3.BusinessDay,
				PlainDateYYYYMMDD = CONVERT(varchar(10), t1.PlainDate, 121),
				MinDateReturned = @MinDate,
				MaxDateReturned = @MaxDate,
				MinYearReturned = DATEPART(year, @MinDate),
				MaxYearReturned = DATEPART(year, @MaxDate)
				,MonthHeading = @AltTimeFrameMonth
				,QuarterHeading = @AltTimeFrameQuarter
				,YearHeading = @AltTimeFrameYear
				,SQLScriptRun -- = CONVERT(varchar(MAX), SQLScriptRun)
				 FROM #md t1  INNER JOIN #mbd t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
			WHERE t1.PlainYear = CASE WHEN @YearFilter = 0 THEN PlainYear ELSE @YearFilter END
				 ORDER BY t1.PlainDate desc
	END
	ELSE
	BEGIN
		SELECT @MinYearReturned = (SELECT date_AltYear01 FROM MetricBusinessDays (NOLOCK) WHERE PlainDate = @MinDate)
				,@MaxYearReturned = (SELECT date_AltYear01 FROM MetricBusinessDays (NOLOCK) WHERE PlainDate = @MaxDate)

		IF (ISNULL(@YearFilter, -1) = -1) SET @YearFilter = @MaxYearReturned
				
		SELECT t1.PlainDate
				,[year] = t3.date_AltYear01
				,[q] = t3.date_AltQuarter01
				,[m] = t3.date_AltMonth01
				,t1.PlainWeek AS 'wk'
				,t1.DailyValue AS 'Daily Value', t1.DailyCount AS 'Daily Count', t1.DailyTotal AS 'Daily Total', t1.GoalDay As 'Goal Day'
				,t1.ThisWTD As 'Week to date'
				,'Week Value' = (Select m.ThisWTD from #md  m (nolock) where m.Plaindate = 
									(Select max(plaindate) from #md  m1 (nolock) where t1.plainyearweek = m1.plainyearweek )
								)
				,t1.GoalWeek As 'Goal Week'			
				,'Month to date' = dbo.fnc_get_Metric_xTD_Alternate(@MetricCode, t1.PlainDate, 'AltMonth01')
				-- Need to get value for the LAST day in the time frame.
				,'Month Value' = dbo.fnc_get_Metric_xTD_Alternate(@MetricCode, 
										(SELECT max(plaindate) from #md  m1 (nolock) where t1.date_altYear01 = m1.date_altYear01 AND t1.date_altMonth01 = m1.date_altMonth01)
									, 'AltMonth01')
				,t1.GoalMonth AS 'Goal Month'
				,'Quarter to date' = dbo.fnc_get_Metric_xTD_Alternate(@MetricCode, t1.PlainDate, 'AltQuarter01')
				,'Quarter Value' = dbo.fnc_get_Metric_xTD_Alternate(@MetricCode, 
										(SELECT max(plaindate) from #md  m1 (nolock) where t1.date_altYear01 = m1.date_altYear01 AND t1.date_altQuarter01 = m1.date_altQuarter01)
									, 'AltQuarter01')
				,t1.GoalQuarter AS 'Goal Quarter'
				,'Year to date' = dbo.fnc_get_Metric_xTD_Alternate(@MetricCode, t1.PlainDate, 'AltYear01')
				,'Year Value' = dbo.fnc_get_Metric_xTD_Alternate(@MetricCode, 
										(SELECT max(plaindate) from #md  m1 (nolock) where t1.date_altYear01 = m1.date_altYear01)
									, 'AltYear01')
				,t1.GoalYear AS 'Goal Year', 
				t1.ThisFiscalYTD AS 'Fiscal Year to date', 
				t1.FiscalYearlyAve AS 'Fiscal Year Value', 
				t1.GoalFiscalYear AS 'Goal Fiscal Year', 
				 LEFT(convert(varchar(20), t1.Upd_Daily, 20), 16) AS 'Daily Job', LEFT(convert(varchar(20), t1.Upd_Summary, 20), 16) As 'Summary Refresh',  
				 t1.RunDurationLast AS 'Proc Time Last', t1.RunDurationMax AS 'Proc Time Hi', t1.RunDurationMin AS 'Proc Time Lo', 
				 BusinessDay = t3.BusinessDay,
				PlainDateYYYYMMDD = CONVERT(varchar(10), t1.PlainDate, 121),
				MinDateReturned = @MinDate,
				MaxDateReturned = @MaxDate,
				MinYearReturned = DATEPART(year, @MinDate),
				MaxYearReturned = DATEPART(year, @MaxDate)
				,MonthHeading = @AltTimeFrameMonth
				,QuarterHeading = @AltTimeFrameQuarter
				,YearHeading = @AltTimeFrameYear
				,SQLScriptRun
			FROM #md t1  INNER JOIN #mbd t3 WITH (NOLOCK) ON t1.PlainDate = t3.PlainDate 
			WHERE t1.date_AltYear01 = CASE WHEN @YearFilter = 0 THEN t3.date_AltYear01 ELSE @YearFilter END
				 ORDER BY t1.PlainDate desc	
	END				 
 
GO
GRANT EXECUTE ON  [dbo].[MetricGetHistory] TO [public]
GO
