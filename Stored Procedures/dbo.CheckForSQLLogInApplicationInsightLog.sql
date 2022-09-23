SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[CheckForSQLLogInApplicationInsightLog]
AS
BEGIN
	SELECT COUNT(*) SQLLogCount FROM applicationInsightLog Where logDate > DATEADD(day, -30, GETDATE()) AND logType = 'SQL Information'
END
GO
GRANT EXECUTE ON  [dbo].[CheckForSQLLogInApplicationInsightLog] TO [public]
GO
