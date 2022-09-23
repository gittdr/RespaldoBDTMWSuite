SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpsertCustomCalendar] (@Calendar_Name varchar(100), @DateStart datetime, @DateEnd datetime, @Period varchar(2), @Quarter varchar(2), @Year varchar(4) )
AS
	SET NOCOUNT ON
	
	IF EXISTS(SELECT * FROM dbo.MetricUserDefinedCalendar WHERE 
				Calendar_Name = @Calendar_Name 
				AND Date_Start = @DateStart 
				AND Date_End = @DateEnd)
	BEGIN
		UPDATE dbo.MetricUserDefinedCalendar SET 
				[Period] = @Period
				,[Quarter] = @Quarter
				,[Year] = @Year
		WHERE Calendar_Name = @Calendar_Name 
				AND Date_Start = @DateStart 
				AND Date_End = @DateEnd
	END
	ELSE
	BEGIN
		INSERT INTO dbo.MetricUserDefinedCalendar(Calendar_Name, Date_Start, Date_End, Period, [Quarter], [Year]) 
		SELECT @Calendar_Name, @DateStart, @DateEnd, @Period, @Quarter, @Year
	END
GO
GRANT EXECUTE ON  [dbo].[MetricUpsertCustomCalendar] TO [public]
GO
