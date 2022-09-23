SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricSendBriefing]
(
	@Debug_Level int
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @MetricCode VARCHAR(200)
	DECLARE @BriefingEmailAddress varchar(2000)
	DECLARE @TempEmailAddress varchar(255)
	DECLARE @BriefingMessage varchar(2000) 

	IF EXISTS(SELECT * FROM MetricTempEmailMetrics)
	BEGIN
		SELECT @BriefingEmailAddress = MIN(email) FROM MetricTempEmailMetrics
		WHILE @BriefingEmailAddress IS NOT NULL
		BEGIN
			IF ISNULL(@Debug_Level, 0) = 1 PRINT 'Daily Briefing for ' + @BriefingEmailAddress
			
			SELECT @BriefingMessage = 'Results Now: Daily Briefing' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 
			
			SELECT @MetricCode = NULL
			SELECT @MetricCode = MIN(MetricCode) FROM MetricTempEmailMetrics WHERE email = @BriefingEmailAddress
			
			WHILE @MetricCode IS NOT NULL
			BEGIN
				--IF ISNULL(@Debug_Level, 0) = 1 PRINT @BriefingMessage
				SELECT @BriefingMessage = @BriefingMessage
						+ 'Metric: ' + IsNull(Caption,' ') + CHAR(13) + CHAR(10) 
					 	+ 'Code: ' + isnull(t1.MetricCode,' ') + CHAR(13) + CHAR(10)
						+ 'Date: ' + CONVERT(varchar(10), t1.PlainDate, 121)  + CHAR(13) + CHAR(10)
						+ 'Value: ' + 
							CASE WHEN t2.FormatText = 'USD' THEN '$ ' + CONVERT(varchar(12), ROUND(t1.Result, 2))
								WHEN  t2.FormatText = 'PCT' THEN CONVERT(varchar(12), ROUND(100 * t1.Result, 2)) + ' %'
								ELSE CONVERT(varchar(12), t1.Result)
							END + CHAR(13) + CHAR(10)
						+ 'Count: ' + CONVERT(varchar(12), ISNULL(t1.ThisCount,0))  + CHAR(13) + CHAR(10)
						+ 'Total: ' + CONVERT(varchar(12), t1.ThisTotal)  + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
					FROM MetricTempEmailMetrics t1, MetricItem t2 WITH (NOLOCK)
					WHERE t1.MetricCode = t2.MetricCode AND email = @BriefingEmailAddress AND t1.MetricCode = @MetricCode
				SELECT @MetricCode = MIN(MetricCode) FROM MetricTempEmailMetrics WHERE email = @BriefingEmailAddress AND MetricCode > @MetricCode
			END	
			IF ISNULL(@Debug_Level, 0) = 1 PRINT @BriefingMessage
			EXEC master..xp_sendmail @recipients = @BriefingEmailAddress, @message = @BriefingMessage, @subject = 'Results Now: Daily Briefing'
			SELECT @BriefingEmailAddress = MIN(email) FROM MetricTempEmailMetrics WHERE email > @BriefingEmailAddress 
		END
	END
GO
GRANT EXECUTE ON  [dbo].[MetricSendBriefing] TO [public]
GO
