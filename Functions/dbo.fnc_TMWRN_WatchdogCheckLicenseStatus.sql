SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnc_TMWRN_WatchdogCheckLicenseStatus](@RefDate datetime)
RETURNS int
AS
BEGIN
	DECLARE @LicenseStatus int

	IF EXISTS(SELECT * FROM WatchdogLogInfo (NOLOCK) WHERE dateandtime > DATEADD(second, -20, @RefDate) AND [Event] = 'Invalid license file')
		SET @LicenseStatus = 0
	ELSE
		SET @LicenseStatus = 1

	RETURN @LicenseStatus 
END
GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_WatchdogCheckLicenseStatus] TO [public]
GO
