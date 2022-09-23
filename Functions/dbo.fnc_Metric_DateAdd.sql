SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnc_Metric_DateAdd](@Style varchar(10), @TimeFrame varchar(10), @Units int, @RefDate datetime) -- @Style: 'Normal' or 'Alt01'
RETURNS datetime
AS
BEGIN
/*
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 0, GETDATE()) -- 3/8 to 3/8
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 1, GETDATE()) -- 3/8 to 4/5
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 2, GETDATE()) -- 3/8 to 5/3
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 3, GETDATE()) -- 3/8 to 5/31
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 4, GETDATE()) -- 3/8 to 6/28
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', -3, '2011-03-02') 
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 5, GETDATE()) -- 3/8 to 7/26
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 6, GETDATE()) -- 3/8 to 8/23
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 7, GETDATE()) -- 3/8 to 9/20
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 8, GETDATE()) -- 3/8 to 10/18
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 9, GETDATE()) -- 3/8 to 11/15
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'MONTH', 10, GETDATE()) -- 3/8 to 12/13

SELECT dbo.fnc_Metric_DateAdd('Alt01', 'QUARTER', -1, GETDATE())
SELECT dbo.fnc_Metric_DateAdd('Alt01', 'Year', -2, GETDATE())

SELECT t1.PlainDate, date_AltMonth01, date_AltQuarter01, date_AltYear01, * FROM MetricBusinessDays t1 WHERE t1.PlainDate between '20110201' and '20111231' ORDER BY t1.plaindate
*/
	-- CREATE TABLE #t1 (sn int identity, date_AltYear01 varchar(4), date_AltQuarter01 varchar(2), date_AltMonth01 varchar(2))
	DECLARE @t1 TABLE (sn int identity, date_AltYear01 varchar(4), date_AltQuarter01 varchar(2), date_AltMonth01 varchar(2))

	DECLARE @dt datetime, @iLoop int, @Step int, @FirstDateOfTimeFrame datetime, @NumberOfDaysIntoTimeFrame int
	DECLARE @AltYear01 varchar(4), @AltQuarter01 varchar(2), @AltMonth01 varchar(2), @TempAltYearMonth varchar(6), @TempAltYearQuarter varchar(6)
	DECLARE @RowCount int, @MinDate datetime, @MaxDate datetime

	SELECT @RefDate = CONVERT(datetime, CONVERT(varchar(10), @RefDate, 121))
			,@RowCount = ABS(@Units) + 1
			,@Step = ABS(@Units)/@Units	

	IF (@Units = 0) RETURN @RefDate

	IF (@Style = 'Normal') OR (@Style = '')
	BEGIN
		IF @TimeFrame IN ('year', 'yyyy', 'yy') SELECT @dt = DATEADD(year, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('quarter', 'qq', 'q') SELECT @dt = DATEADD(quarter, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('month', 'm', 'mm') SELECT @dt = DATEADD(month, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Dayofyear', 'dy', 'y') SELECT @dt = DATEADD(month, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('day', 'dd', 'd') SELECT @dt = DATEADD(day, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Week', 'wk', 'ww') SELECT @dt = DATEADD(week, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Weekday', 'dw', 'w') SELECT @dt = DATEADD(weekday, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Hour', 'Hh') SELECT @dt = DATEADD(Hour, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Minute', 'mi', 'n') SELECT @dt = DATEADD(Minute, @Units, @RefDate)		
		ELSE IF @TimeFrame IN ('Second', 'ss', 's') SELECT @dt = DATEADD(second, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Millisecond', 'Ms') SELECT @dt = DATEADD(Millisecond, @Units, @RefDate)		
	END
	ELSE
	BEGIN
		IF @TimeFrame IN ('year', 'yyyy', 'yy')
		BEGIN
			SELECT @AltYear01 = date_AltYear01 FROM MetricBusinessDays t1 WHERE PlainDate = @RefDate	
			SELECT @FirstDateOfTimeFrame = MIN(plaindate) FROM metricbusinessdays (NOLOCK) WHERE date_AltYear01 = @AltYear01
			SELECT @NumberOfDaysIntoTimeFrame = DATEDIFF(day, @FirstDateOfTimeFrame, @RefDate)
		
			IF @Units > 0
				INSERT INTO @t1 (date_AltYear01)
				SELECT DISTINCT date_AltYear01 FROM MetricBusinessDays WHERE date_AltYear01 IS NOT NULL AND Plaindate >= @RefDate ORDER BY date_AltYear01
			ELSE
				INSERT INTO @t1 (date_AltYear01)
				SELECT DISTINCT date_AltYear01 FROM MetricBusinessDays WHERE date_AltYear01 IS NOT NULL AND Plaindate <= @RefDate ORDER BY date_AltYear01 DESC

			-- Get Year / Quarter where new date will be.
			SELECT  @AltYear01 = date_AltYear01 FROM @t1 WHERE sn = ABS(@Units) + 1
			SELECT  @MinDate = MIN(PlainDate), @MaxDate = MAX(PlainDate) FROM MetricBusinessDays WHERE date_AltYear01 = @AltYear01
			SELECT @dt = DATEADD(day, @NumberOfDaysIntoTimeFrame, @MinDate) FROM metricBusinessDays (NOLOCK)
			IF (@dt > @MaxDate) SELECT @dt = @MaxDate
		END
		ELSE IF @TimeFrame IN ('quarter', 'qq', 'q')
		BEGIN
			SELECT @AltYear01 = date_AltYear01, @AltQuarter01 = RIGHT('0' + date_AltQuarter01, 2) FROM MetricBusinessDays t1 WHERE PlainDate = @RefDate	
			SELECT @FirstDateOfTimeFrame = MIN(plaindate) FROM metricbusinessdays (NOLOCK) WHERE CONVERT(varchar(4), date_AltYear01) + RIGHT('0' + date_AltQuarter01, 2) = CONVERT(varchar(4), @AltYear01) + CONVERT(varchar(2), @AltQuarter01)
			SELECT @NumberOfDaysIntoTimeFrame = DATEDIFF(day, @FirstDateOfTimeFrame, @RefDate)
		
			IF @Units > 0
				INSERT INTO @t1 (date_AltYear01, date_AltQuarter01)
				SELECT DISTINCT date_AltYear01, date_AltQuarter01 FROM MetricBusinessDays WHERE date_AltYear01 IS NOT NULL AND Plaindate >= @RefDate ORDER BY date_AltYear01, date_AltQuarter01
			ELSE
				INSERT INTO @t1 (date_AltYear01, date_AltQuarter01)
				SELECT DISTINCT date_AltYear01, date_AltQuarter01 FROM MetricBusinessDays WHERE date_AltYear01 IS NOT NULL AND Plaindate <= @RefDate ORDER BY date_AltYear01 DESC, date_AltQuarter01 DESC

			-- Get Year / Quarter where new date will be.
			SELECT  @AltYear01 = date_AltYear01, @AltQuarter01 = date_AltQuarter01 FROM @t1 WHERE sn = ABS(@Units) + 1
			SELECT  @MinDate = MIN(PlainDate), @MaxDate = MAX(PlainDate) FROM MetricBusinessDays WHERE date_AltYear01 = @AltYear01 AND date_AltQuarter01 = @AltQuarter01
			SELECT @dt = DATEADD(day, @NumberOfDaysIntoTimeFrame, @MinDate) FROM metricBusinessDays (NOLOCK)
			IF (@dt > @MaxDate) SELECT @dt = @MaxDate

		END
		ELSE IF @TimeFrame IN ('month', 'm', 'mm')
		BEGIN
			SELECT @AltYear01 = date_AltYear01, @AltMonth01 = RIGHT('0' + date_AltMonth01, 2) FROM MetricBusinessDays t1 WHERE PlainDate = @RefDate	
			SELECT @FirstDateOfTimeFrame = MIN(plaindate) FROM metricbusinessdays (NOLOCK) WHERE CONVERT(varchar(4), date_AltYear01) + RIGHT('0' + date_AltMonth01, 2) = CONVERT(varchar(4), @AltYear01) + CONVERT(varchar(2), @AltMonth01)
			SELECT @NumberOfDaysIntoTimeFrame = DATEDIFF(day, @FirstDateOfTimeFrame, @RefDate)
		
			IF @Units > 0
				INSERT INTO @t1 (date_AltYear01, date_AltMonth01)
				SELECT DISTINCT date_AltYear01, RIGHT('0' + date_AltMonth01, 2) FROM MetricBusinessDays WHERE date_AltYear01 IS NOT NULL AND Plaindate >= @RefDate ORDER BY date_AltYear01, RIGHT('0' + date_AltMonth01, 2)
			ELSE
				INSERT INTO @t1 (date_AltYear01, date_AltMonth01)
				SELECT DISTINCT date_AltYear01, RIGHT('0' + date_AltMonth01, 2) FROM MetricBusinessDays WHERE date_AltYear01 IS NOT NULL AND Plaindate <= @RefDate ORDER BY date_AltYear01 DESC, RIGHT('0' + date_AltMonth01, 2) DESC

			-- Get Year / Month where new date will be.
			SELECT  @AltYear01 = date_AltYear01, @AltMonth01 = RIGHT('0' + date_AltMonth01, 2) FROM @t1 WHERE sn = ABS(@Units) + 1
			SELECT  @MinDate = MIN(PlainDate), @MaxDate = MAX(PlainDate) FROM MetricBusinessDays WHERE date_AltYear01 = @AltYear01 AND RIGHT('0' + date_AltMonth01, 2) = @AltMonth01
			SELECT @dt = DATEADD(day, @NumberOfDaysIntoTimeFrame, @MinDate) FROM metricBusinessDays (NOLOCK)
			IF (@dt > @MaxDate) SELECT @dt = @MaxDate
					
		/*
			SELECT @AltYear01 = date_AltYear01, @AltMonth01 = RIGHT('0' + date_AltMonth01, 2) FROM MetricBusinessDays t1 WHERE PlainDate = @RefDate

			SELECT @FirstDateOfTimeFrame = MIN(plaindate) FROM metricbusinessdays (NOLOCK) WHERE date_AltYear01 + RIGHT('0' + date_AltMonth01, 2) = @AltYear01 + @AltMonth01

			SELECT @NumberOfDaysIntoTimeFrame = DATEDIFF(day, @FirstDateOfTimeFrame, @RefDate)

			SET @iLoop = ABS(@Units)
			WHILE @iLoop > 0
			BEGIN
				IF (@Step = 1) -- Get date in the FUTURE.
				BEGIN
					SELECT @TempAltYearMonth = MIN(t2.date_AltYear01 + RIGHT('0' + CONVERT(varchar(2), t2.date_AltMonth01), 2))
					FROM MetricBusinessDays (NOLOCK) t2
					WHERE							t2.date_AltYear01 + RIGHT('0' + CONVERT(varchar(2), t2.date_AltMonth01), 2) > @AltYear01 + @AltMonth01
				END
				ELSE
				BEGIN
					SELECT @TempAltYearMonth = MAX(t2.date_AltYear01 + RIGHT('0' + CONVERT(varchar(2), t2.date_AltMonth01), 2))
					FROM MetricBusinessDays (NOLOCK) t2 
					WHERE							t2.date_AltYear01 + RIGHT('0' + CONVERT(varchar(2), t2.date_AltMonth01), 2) < @AltYear01 + @AltMonth01
				END

				SELECT @dt = DATEADD(day, @NumberOfDaysIntoTimeFrame, MIN(PlainDate)) FROM metricBusinessDays (NOLOCK)
				WHERE @TempAltYearMonth = date_AltYear01 + RIGHT('0' + CONVERT(varchar(2), date_AltMonth01), 2)

				SELECT @AltYear01 = date_AltYear01, @AltMonth01 = RIGHT('0' + date_AltMonth01, 2) FROM MetricBusinessDays t1 WHERE PlainDate = @dt

				SET @iLoop = @iLoop - 1
			END
			*/

		END
		ELSE IF @TimeFrame IN ('Dayofyear', 'dy', 'y') SELECT @dt = DATEADD(month, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('day', 'dd', 'd') SELECT @dt = DATEADD(day, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Week', 'wk', 'ww') SELECT @dt = DATEADD(week, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Weekday', 'dw', 'w') SELECT @dt = DATEADD(weekday, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Hour', 'Hh') SELECT @dt = DATEADD(Hour, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Minute', 'mi', 'n') SELECT @dt = DATEADD(Minute, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Second', 'ss', 's') SELECT @dt = DATEADD(second, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Millisecond', 'Ms') SELECT @dt = DATEADD(Millisecond, @Units, @RefDate)
	END
	
	IF (@RefDate = @dt AND @Units <> 0)
		SET @dt = NULL -- WOULD PREFER TO RAISE ERROR, but cannot do within a function => RAISERROR('MetricBusinessDays table does NOT have sufficient information for ALTERNATE time frames to perform operation.', 16, 1)
		
	RETURN @dt
END
GO
GRANT EXECUTE ON  [dbo].[fnc_Metric_DateAdd] TO [public]
GO
