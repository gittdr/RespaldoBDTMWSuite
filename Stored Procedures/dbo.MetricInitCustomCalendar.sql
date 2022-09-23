SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInitCustomCalendar] (@Specified_Calendar_Name varchar(100))
AS
	SET NOCOUNT ON
	
	DELETE dbo.MetricUserDefinedCalendar WHERE Calendar_Name = @Specified_Calendar_Name

GO
GRANT EXECUTE ON  [dbo].[MetricInitCustomCalendar] TO [public]
GO
