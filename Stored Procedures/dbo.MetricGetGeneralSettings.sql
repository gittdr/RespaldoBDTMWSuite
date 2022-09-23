SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetGeneralSettings]
AS
	SET NOCOUNT ON

	SELECT	SMTPServer = IsNull((select settingvalue from metricgeneralsettings where settingname = 'SmtpServerName'), 'clemail2.tmwsystems.com'), 
			SMTPUser = IsNull((select settingvalue from metricgeneralsettings where settingname = 'SmtpUser'), ''), 
			SMTPSecret = IsNull((select settingvalue from metricgeneralsettings where settingname = 'SmtpSecret'), ''),
			SMTPPort = IsNull((select settingvalue from metricgeneralsettings where settingname = 'SmtpPort'), ''),
			SMTPUseSSL = IsNull((select settingvalue from metricgeneralsettings where settingname = 'SmtpUseSSL'), ''),
			FromEmail = IsNull((select settingvalue from metricgeneralsettings where settingname = 'FromEmailAddress'),'ResultsNow@tmwsystems.com'),
			FromName = IsNull((select settingvalue from metricgeneralsettings where settingname = 'FromEmailName'),'ResultsNow'),
			bBranchLogging = IsNull((select settingvalue from metricgeneralsettings where settingname = 'BranchLogging'),'False'),
			EmailOnlyWeekdaysYN = IsNull((select settingvalue from metricgeneralsettings where settingname = 'EmailOnlyWeekdaysYN'),'Y'),
			EmailEarliestHour = IsNull((select settingvalue from metricgeneralsettings where settingname = 'EmailEarliestHour'),'8'),
			EmailLatestHour = IsNull((select settingvalue from metricgeneralsettings where settingname = 'EmailLatestHour'), '18'),
			MetricProcessingDaysBackToUpdate = ISNULL((SELECT cast(SettingValue as int) FROM dbo.MetricGeneralSettings WITH (NOLOCK) WHERE SettingName = 'MetricProcessingDaysBackToUpdate'), 0),
			MetricProcessingDaysToOffset = ISNULL((SELECT cast(SettingValue as int) FROM MetricGeneralSettings WITH (NOLOCK) WHERE SettingName = 'MetricProcessingDaysToOffset'), 0),
			OvernightBackfillYN = ISNULL((SELECT settingvalue FROM metricgeneralsettings WHERE settingname = 'OvernightBackfillYN'), 'N') 
GO
GRANT EXECUTE ON  [dbo].[MetricGetGeneralSettings] TO [public]
GO
