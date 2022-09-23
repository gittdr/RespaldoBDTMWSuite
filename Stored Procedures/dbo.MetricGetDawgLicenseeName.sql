SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetDawgLicenseeName]
AS
	SET NOCOUNT ON

	DECLARE @LicenseeName varchar(255)

	DECLARE @t1 TABLE(LicenseeName varchar(255))

    IF EXISTS(SELECT id FROM sysobjects WHERE type = 'u' AND name = 'watchdogparameter')
	BEGIN
		SELECT @LicenseeName = ParameterValue FROM watchdogparameter 
				WHERE Heading = 'System' AND SubHeading = 'System' AND ParameterName = 'LicenseeName'

		IF ISNULL(@LicenseeName, '') = ''
		BEGIN
			SELECT @LicenseeName = ParameterValue FROM watchdogparameter 
			WHERE Heading = 'System' AND SubHeading = 'emailsend' AND ParameterName = 'LicenseeName'

		END

		IF ISNULL(@LicenseeName, '') = ''
			SELECT @LicenseeName = NULL
	END

	SELECT @LicenseeName AS ParameterValue
GO
GRANT EXECUTE ON  [dbo].[MetricGetDawgLicenseeName] TO [public]
GO
