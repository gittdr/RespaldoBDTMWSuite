SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetGeneralSetting] (@SettingName varchar(100) )
AS
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT * FROM MetricGeneralSettings WHERE SettingName = @SettingName)
	BEGIN
		INSERT INTO MetricGeneralSettings (SettingName, SettingValue, Description)
		 SELECT @SettingName, '', @SettingName
	END

	SELECT SettingValue = ISNULL(SettingValue, '')
		,sn
		,SettingName
		,[Description]
	FROM MetricGeneralSettings
	WHERE SettingName = @SettingName
GO
GRANT EXECUTE ON  [dbo].[MetricGetGeneralSetting] TO [public]
GO
