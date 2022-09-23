SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateGeneralSettings] (
	@SmtpServerName varchar(100),
	@SmtpUser varchar(100),
	@SmtpSecret varchar(100),
	@FromEmailAddress varchar(100),
	@FromEmailName varchar(100),
	@SmtpPort varchar(4),
	@SmtpUseSSL varchar(5) -- TRUE,FALSE,YES,NO,1,0
)
AS
	SET NOCOUNT ON

	-- SMTP Server Name
	IF NOT EXISTS(SELECT * FROM MetricGeneralSettings WHERE SettingName = 'SmtpServerName')
		INSERT INTO MetricGeneralSettings (SettingName, SettingValue, Description)
		SELECT 'SmtpServerName', @SmtpServerName, 'SMTP server name for outbound email'
	ELSE
		UPDATE MetricGeneralSettings SET SettingValue = @SmtpServerName WHERE SettingName = 'SmtpServerName'

	-- SMTP User
	IF NOT EXISTS(SELECT * FROM MetricGeneralSettings WHERE SettingName = 'SmtpUser')
		INSERT INTO MetricGeneralSettings (SettingName, SettingValue, Description)
		SELECT 'SmtpUser', @SmtpUser, 'SMTP user to use for outbound email'
	ELSE
		UPDATE MetricGeneralSettings SET SettingValue = @SmtpUser WHERE SettingName = 'SmtpUser'

	-- SMTP Secret
	IF NOT EXISTS(SELECT * FROM MetricGeneralSettings WHERE SettingName = 'SmtpSecret')
		INSERT INTO MetricGeneralSettings (SettingName, SettingValue, Description)
		SELECT 'SmtpSecret', @SmtpSecret, 'SMTP secret to use for outbound email'
	ELSE
		UPDATE MetricGeneralSettings SET SettingValue = @SmtpSecret WHERE SettingName = 'SmtpSecret'

	-- FromEmailAddress
	IF NOT EXISTS(SELECT * FROM MetricGeneralSettings WHERE SettingName = 'FromEmailAddress')
		INSERT INTO MetricGeneralSettings (SettingName, SettingValue, Description)
		SELECT 'FromEmailAddress', @FromEmailAddress, 'From Email Address for Alerts and Briefings'
	ELSE
		UPDATE MetricGeneralSettings SET SettingValue = @FromEmailAddress WHERE SettingName = 'FromEmailAddress'

	-- FromEmailName
	IF NOT EXISTS(SELECT * FROM MetricGeneralSettings WHERE SettingName = 'FromEmailName')
		INSERT INTO MetricGeneralSettings (SettingName, SettingValue, Description)
		SELECT 'FromEmailName', @FromEmailName, 'From email name for alerts and briefings'
	ELSE
		UPDATE MetricGeneralSettings SET SettingValue = @FromEmailName WHERE SettingName = 'FromEmailName'

	-- SmtpPort
	IF NOT EXISTS(SELECT * FROM MetricGeneralSettings WHERE SettingName = 'SmtpPort')
		INSERT INTO MetricGeneralSettings (SettingName, SettingValue, Description)
		SELECT 'SmtpPort', @SmtpPort, 'SMTP Port'
	ELSE
		UPDATE MetricGeneralSettings SET SettingValue = @SmtpPort WHERE SettingName = 'SmtpPort'

	-- SmtpUseSSL
	IF NOT EXISTS(SELECT * FROM MetricGeneralSettings WHERE SettingName = 'SmtpUseSSL')
		INSERT INTO MetricGeneralSettings (SettingName, SettingValue, Description)
		SELECT 'SmtpUseSSL', @SmtpUseSSL, 'SMTP Use SSL'
	ELSE
		UPDATE MetricGeneralSettings SET SettingValue = @SmtpUseSSL WHERE SettingName = 'SmtpUseSSL'

GO
GRANT EXECUTE ON  [dbo].[MetricUpdateGeneralSettings] TO [public]
GO
