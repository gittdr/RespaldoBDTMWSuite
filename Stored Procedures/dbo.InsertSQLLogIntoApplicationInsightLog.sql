SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[InsertSQLLogIntoApplicationInsightLog]
AS
BEGIN
	INSERT INTO applicationInsightLog (logType, logDate) VALUES('SQL Information', GETDATE())
END
GO
GRANT EXECUTE ON  [dbo].[InsertSQLLogIntoApplicationInsightLog] TO [public]
GO
