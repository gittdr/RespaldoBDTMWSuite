SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnc_Metric_FirstDateOfTimeFrame] (@Style varchar(10), @TimeFrame varchar(10), @RefDate datetime) -- @Style: 'Normal' or 'Alt01'
RETURNS datetime
AS
BEGIN

	DECLARE @FirstDateOfTimeFrame datetime
	DECLARE @AltYear01 varchar(4), @AltQuarter01 varchar(2), @AltMonth01 varchar(2)

	SET @RefDate = CONVERT(datetime, CONVERT(varchar(10), @RefDate, 121))
	
	IF (@Style = 'Normal') OR (@Style = '')
	BEGIN 
		IF @TimeFrame IN ('year', 'yyyy', 'yy') 
			SELECT @FirstDateOfTimeFrame = CONVERT(varchar(4),datepart(year, @RefDate)) + '0101'
		ELSE IF @TimeFrame IN ('quarter', 'qq', 'q') 
			SELECT @FirstDateOfTimeFrame = CONVERT(varchar(4),datepart(year, @RefDate)) + 
				CASE WHEN datepart(month, @RefDate) IN (1, 2, 3) THEN '0101'
					WHEN datepart(month, @RefDate) IN (4, 5, 6) THEN '0401'
					WHEN datepart(month, @RefDate) IN (7, 8, 9) THEN '0701'
					WHEN datepart(month, @RefDate) IN (10, 11, 12) THEN '1001'
				END				
		ELSE IF @TimeFrame IN ('month', 'm', 'mm')
			SELECT @FirstDateOfTimeFrame = CONVERT(varchar(4),datepart(year, @RefDate)) + RIGHT('0' + CONVERT(varchar(2),datepart(month, @RefDate)), 2) + '01'
		ELSE IF @TimeFrame IN ('Week', 'wk', 'ww') SELECT @FirstDateOfTimeFrame = DATEADD(day, 1-DATEPART(dw, @RefDate), @RefDate)
/*		ELSE IF @TimeFrame IN ('Dayofyear', 'dy', 'y') SELECT @FirstDateOfTimeFrame = DATEADD(month, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('day', 'dd', 'd') SELECT @FirstDateOfTimeFrame = DATEADD(day, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Weekday', 'dw', 'w') SELECT @FirstDateOfTimeFrame = DATEADD(weekday, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Hour', 'Hh') SELECT @FirstDateOfTimeFrame = DATEADD(Hour, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Minute', 'mi', 'n') SELECT @FirstDateOfTimeFrame = DATEADD(Minute, @Units, @RefDate)		
		ELSE IF @TimeFrame IN ('Second', 'ss', 's') SELECT @FirstDateOfTimeFrame = DATEADD(second, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Millisecond', 'Ms') SELECT @FirstDateOfTimeFrame = DATEADD(Millisecond, @Units, @RefDate)		*/
	END
	ELSE
	BEGIN 
		IF @TimeFrame IN ('year', 'yyyy', 'yy') 
		BEGIN
			SELECT @AltYear01 = date_AltYear01 FROM MetricBusinessDays t1 (NOLOCK) WHERE PlainDate = @RefDate
			SELECT @FirstDateOfTimeFrame = MIN(plaindate) FROM metricbusinessdays (NOLOCK) WHERE date_AltYear01 = @AltYear01
		END
		ELSE IF @TimeFrame IN ('quarter', 'qq', 'q')
		BEGIN
			SELECT @AltYear01 = date_AltYear01, @AltQuarter01 = date_AltQuarter01 FROM MetricBusinessDays t1 (NOLOCK) WHERE PlainDate = @RefDate
			SELECT @FirstDateOfTimeFrame = MIN(plaindate) FROM metricbusinessdays (NOLOCK) WHERE CONVERT(varchar(4), date_AltYear01) + CONVERT(varchar(2), date_AltQuarter01) = @AltYear01 + @AltQuarter01
		END
		ELSE IF @TimeFrame IN ('month', 'm', 'mm')
		BEGIN
			SELECT @AltYear01 = date_AltYear01, @AltMonth01 = RIGHT('0' + date_AltMonth01, 2) FROM MetricBusinessDays t1 (NOLOCK) WHERE PlainDate = @RefDate
			SELECT @FirstDateOfTimeFrame = MIN(plaindate) FROM metricbusinessdays (NOLOCK) WHERE date_AltYear01 + RIGHT('0' + date_AltMonth01, 2) = @AltYear01 + @AltMonth01
		END
		ELSE IF @TimeFrame IN ('Week', 'wk', 'ww') SELECT @FirstDateOfTimeFrame = DATEADD(day, 1-DATEPART(dw, @RefDate), @RefDate)		
		/*
		ELSE IF @TimeFrame IN ('Dayofyear', 'dy', 'y') SELECT @dt = DATEADD(month, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('day', 'dd', 'd') SELECT @dt = DATEADD(day, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Weekday', 'dw', 'w') SELECT @dt = DATEADD(weekday, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Hour', 'Hh') SELECT @dt = DATEADD(Hour, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Minute', 'mi', 'n') SELECT @dt = DATEADD(Minute, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Second', 'ss', 's') SELECT @dt = DATEADD(second, @Units, @RefDate)
		ELSE IF @TimeFrame IN ('Millisecond', 'Ms') SELECT @dt = DATEADD(Millisecond, @Units, @RefDate)
		*/
	END
 
	RETURN @FirstDateOfTimeFrame
END
GO
GRANT EXECUTE ON  [dbo].[fnc_Metric_FirstDateOfTimeFrame] TO [public]
GO
