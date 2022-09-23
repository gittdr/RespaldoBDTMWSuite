SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricProcessLayers] 
(
	@MetricCode varchar(200), 
	@DateStart datetime = NULL, 
	@DateEnd datetime = NULL, 
	@ProcessFlags int = NULL, 
	@Debug_Level int = NULL 
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @sn int, @SQL varchar(2000)

	SELECT @sn = ISNULL(MIN(sn), 0) FROM metricitem WITH (NOLOCK) WHERE metriccode LIKE @MetricCode + '@%' OR metriccode = @MetricCode
	WHILE @sn > 0
	BEGIN
		SELECT @SQL = 'EXEC MetricProcessing ''' + MetricCode + ''' ' 
				+ CASE WHEN @DateStart IS NOT NULL THEN ', @DateStartPassed = ''' + CONVERT(varchar(100), @DateStart) + '''' ELSE '' END 
				+ CASE WHEN @DateEnd IS NOT NULL THEN ', @DateEndPassed = ''' + CONVERT(varchar(100), @DateEnd) + '''' ELSE '' END 
				+ CASE WHEN @ProcessFlags IS NOT NULL THEN ', @ProcessFlags = ' + CONVERT(varchar(10), @ProcessFlags) ELSE '' END 
				+ CASE WHEN @Debug_Level IS NOT NULL THEN ', @Debug_Level = ' + CONVERT(varchar(10), @Debug_Level) ELSE '' END 
			FROM MetricItem WITH (NOLOCK) WHERE sn = @sn
		EXEC (@SQL)
		SELECT @sn = ISNULL(MIN(sn), 0) FROM metricitem WITH (NOLOCK) WHERE sn > @sn AND (metriccode LIKE @MetricCode + '@%' OR metriccode = @MetricCode)
	END
GO
GRANT EXECUTE ON  [dbo].[MetricProcessLayers] TO [public]
GO
