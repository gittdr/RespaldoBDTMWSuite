SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricAlertsForCurrentValue] 
( 
	@AlertBatchNumber int, 
	@MetricCode varchar(200), 
	@MetricValue decimal(20, 5), 
	@Debug_Level int = 0, 
	@BatchGUID varchar(36) = NULL,
	@PlainDate varchar(10) = NULL,
	@ThisCount decimal(20, 5) = NULL,
	@ThisTotal decimal(20, 5) = NULL
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	-- EXAMPLE CALL: MetricProcessAlerts 'RevPerTrc', 50
	DECLARE @AlertSn int
	DECLARE @ThresholdAlertEmailAddress varchar(2000)
	DECLARE @ThresholdAlertValue decimal(20, 5) -- NULL means "Do Not Use"
	DECLARE @ThresholdOperator varchar(2)		-- Could be "<", ">", "=", ">=", "<=", or "<>".
	DECLARE @SQL varchar(2000), @sMessage varchar(2000), @MetricCaption varchar(80), @sSubject varchar(255)
	DECLARE @PlainDate_DT datetime 

	SELECT @AlertSn = -1, @PlainDate_DT = @PlainDate

	DELETE MetricTempAlerts

	--***** Get the current settings from the MetricItem table.
	SELECT @ThresholdAlertEmailAddress = ThresholdAlertEmailAddress,
			@ThresholdAlertValue = ThresholdAlertValue,
			@ThresholdOperator = ThresholdOperator,
			@MetricCaption = Caption
	FROM MetricItem WITH (NOLOCK) WHERE MetricCode = @MetricCode

	--***** Check for the valid presence of Threshold parameters.
	IF (ISNULL(@ThresholdAlertEmailAddress, '') = ''	-- For the address, blank is the same as NULL. 
		OR @ThresholdAlertValue IS NULL					-- For the alert value, do NOT do ISNULL. NULL means "not defined".
		OR ISNULL(@ThresholdOperator, '') = '')			-- For the operator, blank is the same as NULL.
	BEGIN
		IF (@Debug_Level > 0) PRINT 'NO ALERTS defined for this MetricCode, or one of the THRESHOLD values is NULL.'
		RETURN
	END
	ELSE
	BEGIN
		IF (@Debug_Level > 0) PRINT 'There are alerts defined for this MetricCode'
		SELECT @SQL = 'IF (' + CONVERT(VARCHAR(20), @MetricValue) + ' ' + @ThresholdOperator + ' ' + CONVERT(varchar(20), @ThresholdAlertValue) + ') ' + CHAR(13) + CHAR(10)
					+ '     SELECT 1 ' + CHAR(13) + CHAR(10)
					+ 'ELSE ' + CHAR(13) + CHAR(10)
					+ '     SELECT 0 '

		INSERT INTO MetricTempAlerts
			EXEC (@SQL)

		IF (SELECT result FROM MetricTempAlerts) = 1
		BEGIN
			INSERT INTO MetricAlertHistory (AlertBatch, MetricCode, DailyValue, ThresholdAlertValue, ThresholdOperator, ThresholdAlertEmailAddress, spid, BatchGUID, PlainDate, DailyCount, DailyTotal)
				VALUES (@AlertBatchNumber, @MetricCode, @MetricValue, @ThresholdAlertValue, @ThresholdOperator, @ThresholdAlertEmailAddress, @@spid, @BatchGUID, @PlainDate_DT, @ThisCount, @ThisTotal)

			SELECT @AlertSn = @@IDENTITY
		END
	END
	
	SELECT AlertSn = @AlertSn
GO
GRANT EXECUTE ON  [dbo].[MetricAlertsForCurrentValue] TO [public]
GO
