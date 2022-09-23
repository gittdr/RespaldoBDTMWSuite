SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricUpdateGeneralSetting] (@SettingName varchar(100), @SettingValue varchar(100))
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT * FROM MetricGeneralSettings WHERE settingname = @SettingName)
	BEGIN
		UPDATE MetricGeneralSettings SET SettingValue = @SettingValue
		WHERE settingname = @SettingName
	END
	ELSE
	BEGIN
		INSERT INTO MetricGeneralSettings (settingname, SettingValue) VALUES (@SettingName, @SettingValue)
	END
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateGeneralSetting] TO [public]
GO
