SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[CheckForLicenseLogInApplicationInsightLog]
AS
BEGIN
	SELECT count(*) logs from applicationInsightLog Where logDate > DATEADD(day, -30, GETDATE()) AND logType = 'License Information'
END
GO
GRANT EXECUTE ON  [dbo].[CheckForLicenseLogInApplicationInsightLog] TO [public]
GO
