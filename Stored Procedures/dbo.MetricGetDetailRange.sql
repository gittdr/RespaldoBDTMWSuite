SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetDetailRange]
(
	@TimeFrame varchar(12), 
	@ReferenceDate datetime
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS 
	SET NOCOUNT ON

	DECLARE @DateFirst int, @DateStart datetime, @DateEnd datetime
	
    Select @DateFirst = settingvalue from MetricGeneralSettings where settingname = 'DateFirst'
    --EXEC MetricGetParameterInt @DateFirst OUTPUT, 7, 'Config', 'All', 'DateFirst' 
	SET DATEFIRST @DateFirst  -- Should be based on global parameter.
	
	SELECT @DateStart = @ReferenceDate, @DateEnd = @ReferenceDate

	IF @TimeFrame = 'ThisWeek'
		SELECT @DateStart = DATEADD(day, 1-DATEPART(dw, @ReferenceDate), @ReferenceDate)

	ELSE IF @TimeFrame = 'LastWeek'
	BEGIN
		SELECT @ReferenceDate = DATEADD(week, -1, @ReferenceDate)
		SELECT @DateStart = DATEADD(day, 1-DATEPART(dw, @ReferenceDate), @ReferenceDate)
		SELECT @DateEnd = DATEADD(day, 7, @DateStart)
	END

	ELSE IF @TimeFrame = 'ThisMonth'
		SELECT @DateStart = DATEADD(day, 1-DATEPART(day, @ReferenceDate), @ReferenceDate)

	ELSE IF @TimeFrame = 'LastMonth'
	BEGIN
		SELECT @ReferenceDate = DATEADD(month, -1, @ReferenceDate)
		SELECT @DateStart = DATEADD(day, 1-DATEPART(day, @ReferenceDate), @ReferenceDate)
		SELECT @DateEnd = DATEADD(month, 1, @DateStart)
	END
	
	ELSE IF @TimeFrame = 'ThisQuarter'
		SELECT @DateStart = CASE DATEPART(quarter, @ReferenceDate) 
								WHEN 1 THEN CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ReferenceDate)) + '0101')
								WHEN 2 THEN CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ReferenceDate)) + '0401')
								WHEN 3 THEN CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ReferenceDate)) + '0701')
								WHEN 4 THEN CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ReferenceDate)) + '01001')
							END

	ELSE IF @TimeFrame = 'LastQuarter'
	BEGIN
		SELECT @ReferenceDate = DATEADD(quarter, -1, @ReferenceDate)
		SELECT @DateStart = CASE DATEPART(quarter, @ReferenceDate) 
								WHEN 1 THEN CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ReferenceDate)) + '0101')
								WHEN 2 THEN CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ReferenceDate)) + '0401')
								WHEN 3 THEN CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ReferenceDate)) + '0701')
								WHEN 4 THEN CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ReferenceDate)) + '1001')
							END
		SELECT @DateEnd = DATEADD(quarter, 1, @DateStart)
	END

	ELSE IF @TimeFrame = 'ThisYear'
		SELECT @DateStart = CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ReferenceDate)) + '0101')

	ELSE IF @TimeFrame = 'LastYear'
	BEGIN
		SELECT @DateStart = DATEADD(year, -1, CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @ReferenceDate)) + '0101'))
		SELECT @DateEnd = DATEADD(year, 1, @DateStart)
	END
	
	
	SELECT @DateStart AS DateStart, @DateEnd AS DateEnd
GO
GRANT EXECUTE ON  [dbo].[MetricGetDetailRange] TO [public]
GO
