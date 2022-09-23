SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnc_get_Metric_xTD_Alternate](@metriccode varchar(200), @RefDate datetime, @TimeFrame varchar(20) ) -- Week, Day, Month, Quarter, Year, FiscalYear, AltMonth01, AltQuarter01, AltYear01
RETURNS decimal(20, 5)
AS
BEGIN
/*
CREATE CLUSTERED INDEX idx_metricdetail_metriccode_plaindate ON metricdetail (metriccode, plaindate)
CREATE INDEX idx_metricBusinessDays_date_AltYear01_date_AltQuarter01 ON dbo.metricBusinessDays (date_AltYear01, date_AltQuarter01)
CREATE INDEX idx_metricBusinessDays_date_AltYear01_date_AltMonth01 ON dbo.metricBusinessDays (date_AltYear01, date_AltMonth01)

select dbo.fnc_get_Metric_xTD_Alternate(MetricCode, Plaindate), ThisMTD, * from metricdetail 
WHERE dbo.fnc_get_Metric_xTD_Alternate(MetricCode, Plaindate) <> ThisMTD
ORDER BY MetricCode, PlainDate DESC
*/

	--*************************************************************************************
	-- Do MONTH.
	--*************************************************************************************
	DECLARE @DateLow datetime, @DateHigh datetime, @DistinctItems int
	DECLARE @ThisTotal decimal(20, 5), @ThisCount decimal(20, 5), @Result decimal(20, 5)
	DECLARE @Cumulative int, @DoNotIncludeTotalForNonBusinessDayYN varchar(1), @FormatText varchar(12)
	DECLARE @AltQuarter01 int, @AltYear01 int

	SELECT @RefDate = CONVERT(varchar(10), @RefDate, 121)
	
	SELECT @Cumulative = Cumulative, @DoNotIncludeTotalForNonBusinessDayYN = DoNotIncludeTotalForNonBusinessDayYN, @FormatText = FormatText FROM metricitem (NOLOCK) WHERE metriccode = @MetricCode

	-- Go back to the first day of the Time Frame Quarter (or QUARTER PERIOD)
	IF @TimeFrame = 'Week'
		SELECT @DateLow = (SELECT MIN(t2.PlainDate) FROM metricBusinessDays t2 WHERE date_YearWeek = t1.date_YearWeek)
				,@DateHigh = @RefDate  -- So the date range is between the beginning of the week AND @DateHigh
		FROM MetricBusinessDays t1 (NOLOCK) WHERE t1.PlainDate = @RefDate	
	ELSE IF @TimeFrame = 'Month'
		SELECT @DateLow = (SELECT MIN(t2.PlainDate) FROM metricBusinessDays t2 WHERE DATEPART(year, t2.Plaindate) = DATEPART(year, t1.PlainDate) AND DATEPART(month, t2.Plaindate) = DATEPART(month, t1.Plaindate))
				,@DateHigh = @RefDate  -- So the date range is between the beginning of the week AND @DateHigh
		FROM MetricBusinessDays t1 (NOLOCK) WHERE t1.PlainDate = @RefDate
	ELSE IF @TimeFrame = 'Quarter'
		SELECT @DateLow = (SELECT MIN(t2.PlainDate) FROM metricBusinessDays t2 WHERE DATEPART(year, t2.Plaindate) = DATEPART(year, t1.PlainDate) AND DATEPART(quarter, t2.Plaindate) = DATEPART(quarter, t1.Plaindate))
				,@DateHigh = @RefDate  -- So the date range is between the beginning of the week AND @DateHigh
		FROM MetricBusinessDays t1 (NOLOCK) WHERE t1.PlainDate = @RefDate
	ELSE IF @TimeFrame = 'Year'
		SELECT @DateLow = (SELECT MIN(t2.PlainDate) FROM metricBusinessDays t2 WHERE DATEPART(year, t2.PlainDate) = DATEPART(year, t1.PlainDate))
				,@DateHigh = @RefDate  -- So the date range is between the beginning of the week AND @DateHigh
		FROM MetricBusinessDays t1 (NOLOCK) WHERE t1.PlainDate = @RefDate	

	ELSE IF @TimeFrame = 'AltMonth01'
		SELECT @DateLow = (SELECT MIN(t2.PlainDate) FROM metricBusinessDays t2 WHERE t2.date_AltYear01 = t1.date_AltYear01 AND t2.date_AltMonth01 = t1.date_AltMonth01)
				,@DateHigh = @RefDate  -- So the date range is between the beginning of the week AND @DateHigh
		FROM MetricBusinessDays t1 (NOLOCK) WHERE t1.PlainDate = @RefDate
	ELSE IF @TimeFrame = 'AltQuarter01'
		SELECT @DateLow = (SELECT MIN(t2.PlainDate) FROM metricBusinessDays t2 WHERE t2.date_AltYear01 = t1.date_AltYear01 AND t2.date_AltQuarter01 = t1.date_AltQuarter01)
				,@DateHigh = @RefDate  -- So the date range is between the beginning of the week AND @DateHigh
		FROM MetricBusinessDays t1 (NOLOCK) WHERE t1.PlainDate = @RefDate
	ELSE IF @TimeFrame = 'AltYear01'
		SELECT @DateLow = (SELECT MIN(t2.PlainDate) FROM metricBusinessDays t2 WHERE t2.date_AltYear01 = t1.date_AltYear01)
				,@DateHigh = @RefDate  -- So the date range is between the beginning of the week AND @DateHigh
		FROM MetricBusinessDays t1 (NOLOCK) WHERE t1.PlainDate = @RefDate	

	SELECT @ThisCount = SUM(ISNULL(t1.DailyCount, 0)), @ThisTotal = SUM(ISNULL(t1.DailyTotal, 0)) 
	FROM MetricDetail t1 (NOLOCK)
	WHERE t1.MetricCode = @MetricCode AND t1.PlainDate BETWEEN @DateLow AND @DateHigh AND t1.Upd_Daily IS NOT NULL

	SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo (NOLOCK) WHERE MetricCode = @MetricCode AND PlainDate Between @DateLow AND @DateHigh),0)
	IF (@DistinctItems > 0) SET @ThisTotal = @DistinctItems 

	-- The standard way to calculate this is to SUM(Count) / SUM(Total) ==>> like Rev/Mile is just SUM(Rev)/Sum(Miles)
	IF (@Cumulative = 0) 
	BEGIN
		IF @DoNotIncludeTotalForNonBusinessDayYN = 'Y'  -- Total here refers to denominator.
		BEGIN
			-- Need to change @ThisTotal.
			SELECT @ThisTotal = SUM(ISNULL(t1.DailyTotal, 0)) 
			FROM MetricDetail t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
			WHERE t1.MetricCode = @MetricCode AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
				AND t2.BusinessDay = 1
				AND t1.Upd_Daily IS NOT NULL

			SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT t1.MetricItem) 
											FROM MetricDetailInfo t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.PlainDate = t2.PlainDate 
											WHERE t1.MetricCode = @MetricCode AND t1.PlainDate Between @DateLow AND @DateHigh AND t2.BusinessDay = 1
												),0)
			IF (@DistinctItems > 0) SET @ThisTotal = @DistinctItems 

			IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
				BEGIN
					SELECT @ThisTotal = SUM(ISNULL(DailyTotal, 0))
					FROM MetricDetail (NOLOCK)
					WHERE MetricCode = @MetricCode AND PlainDate BETWEEN @DateLow AND @DateHigh
						AND Upd_Daily IS NOT NULL

					SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo t1 (NOLOCK) 
															WHERE t1.MetricCode = @MetricCode AND t1.PlainDate Between @DateLow AND @DateHigh 
															),0)
					IF (@DistinctItems > 0) SET @ThisTotal = @DistinctItems 
				END
			IF @FormatText = 'PCT'	-- 5/21/2004: DAG
			BEGIN
				SELECT @ThisCount = SUM(ISNULL(t1.DailyCount, 0)) 
				FROM MetricDetail t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
				WHERE t1.MetricCode = @MetricCode AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
					AND t2.BusinessDay = 1
					AND t1.Upd_Daily IS NOT NULL  -- Do NOT count this day if MetricProcessing has not run against it.

				IF ISNULL(@ThisCount, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
					SELECT @ThisCount = SUM(ISNULL(DailyCount, 0))
					FROM MetricDetail (NOLOCK)
					WHERE MetricCode = @MetricCode AND PlainDate BETWEEN @DateLow AND @DateHigh
						AND Upd_Daily IS NOT NULL

			END
		END
	END
	ELSE
	BEGIN
		-- ASSUMPTION::: If businessday table has any entries, then the relevant entries ARE present.
		-- SUGGESTION:: Change logic to use an OUTER join.  If NULL or zero indicates no business day.
		IF @DoNotIncludeTotalForNonBusinessDayYN = 'N'  -- Total here refers to denominator.
		BEGIN
			SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0))
			FROM MetricDetail (NOLOCK)
			WHERE MetricCode = @MetricCode AND PlainDate BETWEEN @DateLow AND @DateHigh
				AND Upd_Daily IS NOT NULL
		END
		ELSE
		BEGIN
			-- SELECT @DaysForApprox = COUNT(*) FROM MetricBusinessDays WITH (NOLOCK) WHERE PlainDate BETWEEN @DateLow AND @DateHigh AND BusinessDay = 1
			-- IF @DaysForApprox = 0 SELECT @DaysForApprox = 1  -- Self-correcting for Sunday for example.  On Monday, things should be all better.
			SELECT @ThisTotal = AVG(ISNULL(t1.DailyTotal, 0)) 
			FROM MetricDetail t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
			WHERE t1.MetricCode = @MetricCode AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
				AND t2.BusinessDay = 1
				AND t1.Upd_Daily IS NOT NULL

			IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
					SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0))
					FROM MetricDetail (NOLOCK) 
					WHERE MetricCode = @MetricCode AND PlainDate BETWEEN @DateLow AND @DateHigh
						AND Upd_Daily IS NOT NULL
		END
	END
	SET @Result	= CASE WHEN @ThisTotal = 0 THEN 0 ELSE @ThisCount / @ThisTotal END

	RETURN @Result
END
GO
GRANT EXECUTE ON  [dbo].[fnc_get_Metric_xTD_Alternate] TO [public]
GO
