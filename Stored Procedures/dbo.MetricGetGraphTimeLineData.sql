SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetGraphTimeLineData] (@MetricCode varchar(200), @TimeType varchar(7), @DateStart datetime, @DateEnd datetime, @OrderDirection varchar(4) )
AS
	SET NOCOUNT ON

	DECLARE @DateFirstSetting varchar(255), @DateFirstInt int
	DECLARE @Style varchar(10)
	DECLARE @t1 TABLE (sn int identity
		,PlainDate datetime, PlainYear int, PlainQuarter int, PlainMonth int, PlainYearWeek varchar(6), PlainFiscalYear int
		,date_AltYear01 varchar(4), date_AltQuarter01 varchar(2), date_AltMonth01 varchar(2)
		,StartDate datetime, EndDate datetime
	)
	
	SELECT @Style = CASE WHEN EXISTS(SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'UseAlternateTimeFramesYN' AND SettingValue = 'Y')
						THEN 'Alt01' ELSE '' END

	-- First get all the data for the relevant time range.
	SELECT * INTO #metricdetail from metricdetail (NOLOCK) WHERE metriccode = @MetricCode AND PlainDate <= @DateEnd AND PlainDate >= @DateStart

	IF @TimeType = 'WEEK'
	BEGIN
		SELECT @DateFirstSetting = CASE WHEN isnull(settingvalue,7)=0 then 7 else settingvalue end from metricgeneralsettings where settingname = 'DateFirst'
		
		IF ISNUMERIC(@DateFirstSetting) = 1 -- @DateFirstSetting IS NOT NULL
		BEGIN
			INSERT INTO @t1 (PlainYearWeek, StartDate, EndDate)
			SELECT date_YearWeek, MIN(PlainDate), MAX(PlainDate) FROM MetricBusinessDays WHERE PlainDate BETWEEN @DateStart AND @DateEnd
			GROUP BY date_YearWeek

			IF @OrderDirection = 'DESC'
			BEGIN
				SELECT DISTINCT MetricCode = @MetricCode, left(dateadd(d, -datepart(dw, t1.StartDate)+7, t1.StartDate),6) as PlainWeek, EndDate as WeekEnding, PlainYearWeek
					,ISNULL(dbo.fnc_get_Metric_xTD_Alternate(@metriccode, t1.EndDate, 'week'), 0) AS WeeklyAve
				FROM @t1 t1
				ORDER BY PlainYearWeek DESC
			END
			ELSE
			BEGIN
				SELECT DISTINCT MetricCode = @MetricCode, left(dateadd(d, -datepart(dw, t1.StartDate)+7, t1.StartDate),6) as PlainWeek, EndDate as WeekEnding, PlainYearWeek
					,ISNULL(dbo.fnc_get_Metric_xTD_Alternate(@metriccode, t1.EndDate, 'week'), 0) AS WeeklyAve
				FROM @t1 t1
				ORDER BY PlainYearWeek 
			END		
/*
			SET @DateFirstInt = CONVERT(int, @DateFirstSetting)
			SET DATEFIRST @DateFirstInt

			IF @OrderDirection = 'DESC'
			BEGIN
				SELECT DISTINCT t1.MetricCode, left(dateadd(d, -datepart(dw, t1.plaindate)+7, t1.plaindate),6) as PlainWeek, 
					  dateadd(d, -datepart(dw, t1.plaindate)+7, t1.plaindate) as WeekEnding, 
				ISNULL((Select m.ThisWTD from #metricdetail  m (nolock) where m.Plaindate = (Select max(plaindate) from #metricdetail m1 (nolock) where t1.plainyearweek = m1.plainyearweek )), 0) AS WeeklyAve 
				FROM #metricdetail t1 
				ORDER BY t1.MetricCode, WeekEnding DESC
			END

			ELSE
			BEGIN
				SELECT DISTINCT t1.MetricCode, left(dateadd(d, -datepart(dw, t1.plaindate)+7, t1.plaindate),6) as PlainWeek, 
				  dateadd(d, -datepart(dw, t1.plaindate)+7, t1.plaindate) as WeekEnding, 
				ISNULL((Select m.ThisWTD from #metricdetail  m (nolock) where m.Plaindate = (Select max(plaindate) from #metricdetail m1 (nolock) where t1.plainyearweek = m1.plainyearweek)), 0) AS WeeklyAve 
				FROM #metricdetail t1 
				ORDER BY t1.MetricCode, WeekEnding 
			END
*/
		END

		ELSE
		BEGIN
			IF @OrderDirection = 'DESC'
			BEGIN
				SELECT DISTINCT t1.MetricCode, left(dateadd(d, -datepart(dw, t1.plaindate)+7, t1.plaindate),6) as PlainWeek, 
					  dateadd(d, -datepart(dw, t1.plaindate)+7, t1.plaindate) as WeekEnding, 
				ISNULL((Select m.ThisWTD from #metricdetail  m (nolock) where m.Plaindate = (Select max(plaindate) from #metricdetail m1 (nolock) where t1.plainyearweek = m1.plainyearweek )), 0) AS WeeklyAve 
				FROM #metricdetail t1 
				ORDER BY t1.MetricCode, WeekEnding DESC
			END
			ELSE
			BEGIN
				SELECT DISTINCT t1.MetricCode, left(dateadd(d, -datepart(dw, t1.plaindate)+7, t1.plaindate),6) as PlainWeek, 
					  dateadd(d, -datepart(dw, t1.plaindate)+7, t1.plaindate) as WeekEnding, 
				ISNULL((Select m.ThisWTD from #metricdetail  m (nolock) where m.Plaindate = (Select max(plaindate) from #metricdetail m1 (nolock) where t1.plainyearweek = m1.plainyearweek )), 0) AS WeeklyAve 
				FROM #metricdetail t1 
				ORDER BY t1.MetricCode, WeekEnding 
			END

		END

	END

	IF (@TimeType = 'MONTH')
	BEGIN
		IF @Style = ''
		BEGIN
			IF @OrderDirection = 'DESC'
			BEGIN
				SELECT DISTINCT t1.MetricCode, t1.PlainYear, t1.PlainMonth, DATENAME(month, t1.PlainDate) AS MonthName, 
					ISNULL((SELECT m.ThisMTD from #metricdetail  m (nolock) 
								WHERE m.Plaindate = (Select max(plaindate) from #metricdetail m1 (nolock) 
																						where t1.plainmonth = m1.plainmonth and t1.plainyear = m1.plainyear)), 0) AS MonthlyAve, 
					ISNULL(t1.GoalMonth,0) as GoalMonth  
				FROM #metricdetail t1 
				WHERE DatePart(dd, t1.PlainDate) = 1 
				ORDER BY t1.MetricCode, t1.PlainYear DESC , t1.PlainMonth DESC
			END

			ELSE
			BEGIN
				SELECT DISTINCT t1.MetricCode, t1.PlainYear, t1.PlainMonth, DATENAME(month, t1.PlainDate) AS MonthName, 
					ISNULL((SELECT m.ThisMTD from #metricdetail  m (nolock) 
								WHERE m.Plaindate = (Select max(plaindate) from #metricdetail m1 (nolock) 
																						where t1.plainmonth = m1.plainmonth and t1.plainyear = m1.plainyear )), 0) AS MonthlyAve, 
					ISNULL(t1.GoalMonth,0) as GoalMonth  
				FROM #metricdetail t1 
				WHERE DatePart(dd, t1.PlainDate) = 1 
				ORDER BY t1.MetricCode, t1.PlainYear , t1.PlainMonth 
			END
		END
		ELSE
		BEGIN
			INSERT INTO @t1 (date_AltYear01, date_AltMonth01, StartDate, EndDate)
			SELECT date_AltYear01, RIGHT('0' + date_AltMonth01, 2), MIN(PlainDate), MAX(PlainDate) FROM MetricBusinessDays WHERE PlainDate BETWEEN @DateStart AND @DateEnd
				AND date_AltYear01 IS NOT NULL
			GROUP BY date_AltYear01, RIGHT('0' + date_AltMonth01, 2)
			ORDER BY date_AltYear01 DESC, RIGHT('0' + date_AltMonth01, 2) DESC

			UPDATE @t1 SET StartDate = (SELECT MIN(PlainDate) FROM MetricBusinessDays t2 WHERE t1.date_AltYear01 = t2.date_AltYear01 AND CONVERT(int, t1.date_AltMonth01) = CONVERT(int, t2.date_AltMonth01))
						,EndDate = (SELECT MAX(PlainDate) FROM MetricBusinessDays t3 WHERE  t3.PlainDate <= @DateEnd AND t1.date_AltYear01 = t3.date_AltYear01 AND CONVERT(int, t1.date_AltMonth01) = CONVERT(int, t3.date_AltMonth01))		
			FROM @t1 t1

			IF @OrderDirection = 'DESC'
			BEGIN
				SELECT DISTINCT MetricCode = @MetricCode, PlainYear = t1.date_AltYear01, PlainMonth = t1.date_AltMonth01, 'Period ' + CONVERT(varchar(2), t1.date_AltMonth01) AS MonthName, 
					ISNULL(dbo.fnc_get_Metric_xTD_Alternate(@metriccode, t1.EndDate, 'AltMonth01'), 0) AS MonthlyAve
				FROM @t1 t1
				ORDER BY t1.date_AltYear01 DESC , t1.date_AltMonth01 DESC
			END

			ELSE
			BEGIN
				SELECT DISTINCT MetricCode = @MetricCode, PlainYear = t1.date_AltYear01, PlainMonth = t1.date_AltMonth01, 'Period ' + CONVERT(varchar(2), t1.date_AltMonth01) AS MonthName, 
					ISNULL(dbo.fnc_get_Metric_xTD_Alternate(@metriccode, t1.EndDate, 'AltMonth01'), 0) AS MonthlyAve
				FROM @t1 t1
				ORDER BY t1.date_AltYear01, t1.date_AltMonth01 
			END
		END
	END
	
	ELSE IF @TimeType = 'QUARTER'
	BEGIN
		IF @Style = ''
		BEGIN		
			IF @OrderDirection = 'DESC'
				SELECT DISTINCT t1.MetricCode, t1.PlainYear, t1.PlainQuarter, 
					ISNULL((Select m.ThisQTD from #metricdetail  m (nolock) where m.Plaindate = (Select max(plaindate) from #metricdetail m1 (nolock) where t1.plainyear = m1.plainyear and t1.plainquarter = m1.plainquarter )), 0) AS QuarterlyAve 
				FROM #metricdetail t1  
				ORDER BY t1.MetricCode, t1.PlainYear DESC, t1.PlainQuarter DESC
			ELSE
				SELECT DISTINCT t1.MetricCode, t1.PlainYear, t1.PlainQuarter, 
					ISNULL((Select m.ThisQTD from #metricdetail  m (nolock) where m.Plaindate = (Select max(plaindate) from #metricdetail m1 (nolock) where t1.plainyear = m1.plainyear and t1.plainquarter = m1.plainquarter )), 0) AS QuarterlyAve 
				FROM #metricdetail t1  
				ORDER BY t1.MetricCode, t1.PlainYear, t1.PlainQuarter 
		END
		ELSE
		BEGIN
			INSERT INTO @t1 (date_AltYear01, date_AltQuarter01, StartDate, EndDate)
			SELECT date_AltYear01, date_AltQuarter01, MIN(PlainDate), MAX(PlainDate) FROM MetricBusinessDays WHERE PlainDate BETWEEN @DateStart AND @DateEnd
				AND date_AltYear01 IS NOT NULL
			GROUP BY date_AltYear01, date_AltQuarter01

			UPDATE @t1 SET StartDate = (SELECT MIN(PlainDate) FROM MetricBusinessDays t2 WHERE t1.date_AltYear01 = t2.date_AltYear01 AND t1.date_AltQuarter01 = t2.date_AltQuarter01)
						,EndDate = (SELECT MAX(PlainDate) FROM MetricBusinessDays t3 WHERE  t3.PlainDate <= @DateEnd AND t1.date_AltYear01 = t3.date_AltYear01 AND t1.date_AltQuarter01 = t3.date_AltQuarter01)
			FROM @t1 t1

			IF @OrderDirection = 'DESC'
			BEGIN
				SELECT DISTINCT MetricCode = @MetricCode, PlainYear = t1.date_AltYear01, PlainQuarter = t1.date_AltQuarter01
					,ISNULL(dbo.fnc_get_Metric_xTD_Alternate(@metriccode, t1.EndDate, 'AltQuarter01'), 0) AS QuarterlyAve
				FROM @t1 t1
				ORDER BY t1.date_AltYear01 DESC , t1.date_AltQuarter01 DESC
			END

			ELSE
			BEGIN
				SELECT DISTINCT MetricCode = @MetricCode, PlainYear = t1.date_AltYear01, PlainQuarter = t1.date_AltQuarter01
					,ISNULL(dbo.fnc_get_Metric_xTD_Alternate(@metriccode, t1.EndDate, 'AltQuarter01'), 0) AS QuarterlyAve
				FROM @t1 t1
				ORDER BY t1.date_AltYear01, t1.date_AltQuarter01
			END		
		END
	END
	
	ELSE IF @TimeType = 'YEAR' 
	BEGIN
		IF @Style = ''
		BEGIN	
			IF @OrderDirection = 'DESC'
			BEGIN
				SELECT DISTINCT t1.MetricCode, t1.PlainYear, 
					ISNULL((Select m.ThisYTD from #metricdetail  m (nolock) where m.Plaindate = (Select max(plaindate) from #metricdetail m1 (nolock) where t1.plainyear = m1.plainyear )), 0) AS YearlyAve 
				FROM #metricdetail t1 
				ORDER BY t1.MetricCode, t1.PlainYear DESC
			END

			ELSE
			BEGIN
				SELECT DISTINCT t1.MetricCode, t1.PlainYear, 
					ISNULL((Select m.ThisYTD from #metricdetail  m (nolock) where m.Plaindate = (Select max(plaindate) from #metricdetail m1 (nolock) where t1.plainyear = m1.plainyear )), 0) AS YearlyAve 
				FROM #metricdetail t1 
				ORDER BY t1.MetricCode, t1.PlainYear
			END
		END
		ELSE
		BEGIN
			INSERT INTO @t1 (date_AltYear01, StartDate, EndDate)
			SELECT date_AltYear01, MIN(PlainDate), MAX(PlainDate) FROM MetricBusinessDays WHERE PlainDate BETWEEN @DateStart AND @DateEnd
				AND date_AltYear01 IS NOT NULL
			GROUP BY date_AltYear01

			UPDATE @t1 SET StartDate = (SELECT MIN(PlainDate) FROM MetricBusinessDays t2 WHERE t1.date_AltYear01 = t2.date_AltYear01 )
						,EndDate = (SELECT MAX(PlainDate) FROM MetricBusinessDays t3 WHERE  t3.PlainDate <= @DateEnd AND t1.date_AltYear01 = t3.date_AltYear01)
			FROM @t1 t1

			IF @OrderDirection = 'DESC'
			BEGIN
				SELECT DISTINCT MetricCode = @MetricCode, PlainYear = t1.date_AltYear01
					,ISNULL(dbo.fnc_get_Metric_xTD_Alternate(@metriccode, t1.EndDate, 'AltYear01'), 0) AS YearlyAve
				FROM @t1 t1
				ORDER BY t1.date_AltYear01 DESC
			END

			ELSE
			BEGIN
				SELECT DISTINCT MetricCode = @MetricCode, PlainYear = t1.date_AltYear01
					,ISNULL(dbo.fnc_get_Metric_xTD_Alternate(@metriccode, t1.EndDate, 'AltYear01'), 0) AS YearlyAve
				FROM @t1 t1
				ORDER BY t1.date_AltYear01
			END			
		END
	END

	ELSE IF @TimeType = 'DAY'
	BEGIN
		IF @OrderDirection = 'DESC'
		BEGIN
			SELECT DISTINCT t1.MetricCode, t1.PlainDate, ISNULL(DailyValue, 0) AS DailyAve, LEFT(t1.plaindate,6) as Heading 
			FROM #metricdetail t1
			ORDER BY t1.MetricCode, t1.PlainDate DESC
		END

		ELSE
		BEGIN
			SELECT DISTINCT t1.MetricCode, t1.PlainDate, ISNULL(DailyValue, 0) AS DailyAve, LEFT(t1.plaindate,6) as Heading 
			FROM #metricdetail t1 
			ORDER BY t1.MetricCode, t1.PlainDate
		END
	END
GO
GRANT EXECUTE ON  [dbo].[MetricGetGraphTimeLineData] TO [public]
GO
