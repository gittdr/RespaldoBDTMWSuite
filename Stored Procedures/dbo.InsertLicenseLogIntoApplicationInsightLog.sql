SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[InsertLicenseLogIntoApplicationInsightLog]
AS
BEGIN
	INSERT INTO applicationInsightLog (logType, logDate) VALUES('License Information', GETDATE())
END
GO
GRANT EXECUTE ON  [dbo].[InsertLicenseLogIntoApplicationInsightLog] TO [public]
GO
