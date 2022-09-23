SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[WatchdogCheckLicenseStatus]
AS
	IF EXISTS(SELECT * FROM WatchdogLogInfo (NOLOCK) WHERE dateandtime > DATEADD(minute, -1, GETDATE()) AND [Event] = 'Invalid license file')
		SELECT [LicenseStatus] = 0
	ELSE
		SELECT [LicenseStatus] = 1
GO
GRANT EXECUTE ON  [dbo].[WatchdogCheckLicenseStatus] TO [public]
GO
