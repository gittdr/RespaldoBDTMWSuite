SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetMonthlyGraphInfo] (@MetricCode varchar(200), @CategoryCode varchar(30) = '', @DateOrderLeftToRight varchar(15) = 'ASC' ) 
AS
-- select MetricCode  = @MetricCode , CategoryCode = @CategoryCode , DateOrderLeftToRight = @DateOrderLeftToRight into txv
-- select * from txv
	CREATE TABLE #t1 (PlainYear varchar(4), PlainMonth varchar(2), [MonthName] varchar(50), PlainDate datetime, MonthlyAve decimal(20, 5), GoalMonth decimal(20, 5) )
	SET NOCOUNT ON 
	DECLARE @MaxDate datetime
	DECLARE @LabelMonth varchar(100)
	
	SELECT @MaxDate = (Select Max(Plaindate) from metricdetail (nolock) where metriccode = @MetricCode)  

	IF ISNULL(@CategoryCode, '') = ''
	BEGIN
		SET @DateOrderLeftToRight = @DateOrderLeftToRight  -- i.e. The old default was always ASC order, but this should always have a categorycode passed in with a new ASP page.
	END
	ELSE
	BEGIN
		SELECT @DateOrderLeftToRight = ISNULL(DateOrderLeftToRight, '') FROM metriccategory (NOLOCK) WHERE CategoryCode = @CategoryCode
	END

	-- Had problem with DEFAULT value being BLANK or NOT existing.  So BLANK and NULL should drop to second part of the IF statement.
	IF ISNULL((SELECT SettingValue FROM MetricGeneralSettings (NOLOCK) WHERE SettingName = 'UseAlternateTimeFramesYN'), 'N') = 'Y'
	BEGIN
		SELECT @LabelMonth = SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameMonth'

		INSERT INTO #t1 (PlainYear, PlainMonth, [MonthName], PlainDate, MonthlyAve, GoalMonth)		
		SELECT	t1.date_altYear01
				,RIGHT('0' + CONVERT(varchar(2), t1.date_AltMonth01), 2)
				,[MonthName] = @LabelMonth + ' ' + RIGHT('0' + CONVERT(varchar(2), t1.date_AltMonth01), 2)
 				,plaindate = max(t1.plaindate)

				,MonthlyAve = dbo.fnc_get_Metric_xTD_Alternate (@metriccode, MAX(t1.PlainDate), 'AltMonth01')
				,GoalMonth = ISNULL(avg(GoalMonth),-999999)
		FROM metricbusinessdays t1 (NOLOCK) INNER JOIN MetricDetail t2 (NOLOCK) ON t1.plaindate = t2.plaindate
		WHERE t1.plaindate > DateAdd(month, -14, @MaxDate)
			 and t1.plaindate <= @MaxDate AND t2.metriccode = @metriccode
		GROUP BY t1.date_altYear01
				,t1.date_AltMonth01
				-- ,@LabelMonth + CONVERT(varchar(2), t1.date_AltMonth01)
	END
	ELSE
	BEGIN
		INSERT INTO #t1 (PlainYear, PlainMonth, [MonthName], PlainDate, MonthlyAve, GoalMonth)
		SELECT	plainyear,
				RIGHT('0' + CONVERT(varchar(2), plainmonth), 2),
				[MonthName] = DATENAME(month, PlainDate),
				plaindate = max(plaindate),
				MonthlyAve =
					(Select m.ThisMTD from metricdetail  m (nolock) where t1.MetricCode = m.MetricCode and m.Plaindate =
						(Select max(plaindate) from metricdetail  m1 (nolock) where t1.plainyear = m1.plainyear and t1.plainmonth = m1.plainmonth AND t1.MetricCode = m1.MetricCode)),
				GoalMonth = ISNULL(avg(GoalMonth),-999999)
		FROM metricdetail t1 (NOLOCK) 
		WHERE metriccode = @MetricCode
			 and plaindate > DateAdd(month, -13, @MaxDate)  
			 and plaindate <= @MaxDate
		GROUP BY plainyear, plainmonth, DATENAME(month, PlainDate), t1.MetricCode  	
	END

	-- Be careful... Remember that the chart.asp REVERSES the order, so this needs to reverse ALSO. DEFAULT was ASCENDING order for procedure resulting in DESCENDING on screen.
	IF @DateOrderLeftToRight = 'CURRENTPRIOR' OR @DateOrderLeftToRight = 'DESC' OR @DateOrderLeftToRight = ''
	BEGIN
		SELECT *, LabelMonth = 'MONTH' FROM #t1 ORDER BY plainyear DESC, plainmonth DESC
	END
	ELSE  -- @DateOrderLeftToRight = '' was the old default.  Also ASC will fall into this.
	BEGIN
		SELECT *, LabelMonth = @LabelMonth FROM #t1 ORDER BY plainyear, plainmonth 
	END
GO
GRANT EXECUTE ON  [dbo].[MetricGetMonthlyGraphInfo] TO [public]
GO
