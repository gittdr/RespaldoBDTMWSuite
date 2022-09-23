SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricGetParameterOptions] (@Step int, @Filter1 varchar(200) = '')
AS
	SET NOCOUNT ON

	DECLARE @ProcedureName varchar(255), @SQL varchar(4000)

	SELECT @ProcedureName = SettingValue FROM dbo.metricGeneralSettings WHERE SettingName = 'GetParameterOptionsProcedure'

	SELECT @SQL = 'EXEC ' + @ProcedureName + ' ' + CONVERT(varchar(10), @Step) + ', ''' + @Filter1 + ''''

	EXEC (@SQL)
GO
GRANT EXECUTE ON  [dbo].[MetricGetParameterOptions] TO [public]
GO
