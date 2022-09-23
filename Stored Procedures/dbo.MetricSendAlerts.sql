SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricSendAlerts]
(
	@AlertBatch int,
	@Debug_Level int
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @crlf CHAR(2)
	DECLARE @idx int, @MsgSubject VARCHAR(255), @Msg VARCHAR(2000), @SendTo VARCHAR(1000)

	SELECT @crlf = CHAR(13) + CHAR(10)
	IF EXISTS(SELECT * FROM MetricAlertHistory WHERE AlertBatch = @AlertBatch AND spid = @@spid)
	BEGIN
		SELECT @idx = ISNULL(MIN(AlertBatchIdx), 0) FROM MetricAlertHistory WHERE AlertBatch = @AlertBatch AND spid = @@spid
		WHILE @idx > 0
		BEGIN
			SELECT @MsgSubject = 'TMW Results Now ALERT: ' + t2.Caption,
					@SendTo = t1.ThresholdAlertEmailAddress,
					@Msg = 'An alert status has been reached in Results Now processing.' + @crlf + @crlf
						+ 'Date: ' + CONVERT(varchar(10), t1.PlainDate, 101) + @crlf
						+ 'Metric: ' + t2.Caption + @crlf
						+ 'MetricCode: ' + t1.MetricCode + @crlf
						+ 'Daily Value: ' + CONVERT(varchar(20), t1.DailyValue) + @crlf
						+ 'Alert Value: ' + CONVERT(varchar(20), t1.ThresholdAlertValue) + @crlf
						+ 'Operator: ' + t1.ThresholdOperator + @crlf
						+ 'Count: ' + CONVERT(varchar(20), t1.DailyCount) + @crlf
						+ 'Total: ' + CONVERT(varchar(20), t1.DailyTotal) + @crlf
			FROM MetricAlertHistory t1, MetricItem t2
			WHERE t1.MetricCode = t2.MetricCode
				AND AlertBatch = @AlertBatch 
				AND AlertBatchIdx = @idx
				AND spid = @@spid

			IF ISNULL(@Debug_Level, 0) > 0
				PRINT 'Subject: ' + @MsgSubject + CHAR(13) + CHAR(10) + 'Recipients: ' + @SendTo + CHAR(13) + CHAR(10) + 'Message: ' + @Msg 

			UPDATE MetricAlertHistory
				SET dtEmailed = GETDATE()			
				WHERE AlertBatch = @AlertBatch 
					AND AlertBatchIdx = @idx
					AND spid = @@spid

			EXEC master..xp_sendmail @recipients = @SendTo, @message = @Msg, @subject = @MsgSubject

			SELECT @idx = ISNULL(MIN(AlertBatchIdx), 0) FROM MetricAlertHistory 
				WHERE AlertBatch = @AlertBatch AND AlertBatchIdx > @idx AND spid = @@spid
		END
	END
GO
GRANT EXECUTE ON  [dbo].[MetricSendAlerts] TO [public]
GO
