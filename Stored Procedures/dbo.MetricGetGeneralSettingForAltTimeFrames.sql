SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetGeneralSettingForAltTimeFrames] 
AS
	SET NOCOUNT ON
	DECLARE @SettingValue varchar(100)
	
	SELECT @SettingValue = ISNULL(SettingValue, '')	FROM MetricGeneralSettings WHERE SettingName = 'UseAlternateTimeFramesYN'
	IF @SettingValue = 'Y'
	BEGIN
		SELECT UseAlternateTimeFramesYN = 'Y'
			,AltTimeFrameMonth = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameMonth'), '')
			,AltTimeFrameQuarter = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameQuarter'), '')
			,AltTimeFrameYear = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameYear'), '')
	END
	ELSE 
		SELECT UseAlternateTimeFramesYN = 'N'
			,AltTimeFrameMonth = 'Month'
			,AltTimeFrameQuarter = 'Quarter'
			,AltTimeFrameYear = 'Year'
GO
GRANT EXECUTE ON  [dbo].[MetricGetGeneralSettingForAltTimeFrames] TO [public]
GO
