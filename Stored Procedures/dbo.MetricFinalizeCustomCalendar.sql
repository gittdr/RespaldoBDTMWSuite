SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricFinalizeCustomCalendar] (@Specified_Calendar_Name varchar(100))
AS
	SET NOCOUNT ON
	
	UPDATE dbo.MetricBusinessDays SET date_AltMonth01 = NULL, date_AltQuarter01 = NULL, date_AltYear01 = NULL
	
	UPDATE dbo.MetricBusinessDays SET
		[date_AltMonth01] = t2.[Period]
		,[date_AltQuarter01] = t2.[Quarter]
		,[date_AltYear01] = t2.[year]
	FROM dbo.MetricBusinessDays t1 INNER JOIN MetricUserDefinedCalendar t2
		ON t1.PlainDate >= t2.Date_Start AND t1.PlainDate <= t2.Date_End
	WHERE t2.Calendar_Name = @Specified_Calendar_Name
			
GO
GRANT EXECUTE ON  [dbo].[MetricFinalizeCustomCalendar] TO [public]
GO
