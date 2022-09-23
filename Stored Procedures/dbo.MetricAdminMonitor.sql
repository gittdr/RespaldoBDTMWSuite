SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricAdminMonitor] (@nav VARCHAR(15), @snHigh varchar(20), @snLow varchar(20), @Mode varchar(15) )
AS
	SET NOCOUNT ON

	DECLARE @sql varchar(MAX)
	DECLARE @Where varchar(255)
	DECLARE @Sort varchar(20)

	SET @sql = ''

	IF @Nav = ''
		SET @Nav = 'LATEST'

	IF @Nav = 'LATEST'
		SELECT @Where = '', @Sort = 'DESC'
	ELSE IF @Nav = 'PREVIOUS'
		SELECT @Sort = '', @Where = ' AND sn > ' + CONVERT(varchar(20), @snHigh) + ' '
	ELSE IF @Nav = 'NEXT'
		SELECT @Sort = 'DESC', @Where = ' AND sn < ' + CONVERT(varchar(20), @snLow) + ' '
	ELSE
      SELECT @Sort = '', @Where = ''

	IF @Mode = ''
      SELECT @Mode = 'RTPQ'
	
	IF @Mode = 'RTPQ'
		SELECT @sql = 'SELECT TOP 15 sn, DateCreated, MetricCode = MetricCodePassed, DateStart = DateStartPassed, DateEnd = DateEndPassed, ProcessFlags
				        FROM MetricReadyToProcessQueue WITH (NOLOCK) 
				        '
	ELSE IF @Mode = 'MPSORT'
		SELECT @sql = 'SELECT TOP 15 *
						FROM MetricProcessingSort WITH (NOLOCK)
						'
	ELSE
		SELECT @sql = 'SELECT TOP 15 sn, [Time stamp] = dateandtime, Source, [Log Message] = CONVERT(varchar(4000), longdesc) 
						FROM ResNowLog WITH (NOLOCK)
						'


	SELECT @Sql = @Sql + ' WHERE 1=1 ' + @Where + ' ' + ' ORDER BY sn ' + @Sort

	EXEC(@sql)

GO
GRANT EXECUTE ON  [dbo].[MetricAdminMonitor] TO [public]
GO
