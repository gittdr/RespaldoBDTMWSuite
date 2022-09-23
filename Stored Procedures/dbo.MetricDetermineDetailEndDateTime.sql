SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[MetricDetermineDetailEndDateTime] (@MetricCode varchar(200), @DateToUseEnd datetime)
AS
	SET NOCOUNT ON

	-- 'Tr_BillingLagReport'
	DECLARE @EndDateTime datetime
	DECLARE @MostRecentPlainDate datetime
	DECLARE @OldestUpdDailyBeforeEnd datetime

	-- NOTE: @DateToUseEnd is really one day into the future.

	-- Default to date passed in.
	SET @EndDateTime = @DateToUseEnd

	-- PTS38307 -- Added for Giant Eagle.  Default behavior is to have detail reflect what is in metricdetail. 
	IF NOT ISNULL((SELECT SettingValue FROM metricgeneralsettings WHERE settingname = 'DetailDateEndReflectsSummary'), 'Y') = 'N'
	BEGIN
		-- 1) Get the oldest UpdDaily in MetricDetail < the @DateToUseEnd.
		-- 2) Also store that PlainDate.
		SELECT TOP 1 @OldestUpdDailyBeforeEnd = Upd_Daily
		FROM metricdetail 
		WHERE metriccode = @MetricCode AND Plaindate < @DateToUseEnd -- "Less than" because the page sends one daye into the future.
		ORDER BY Plaindate DESC

		-- If the update for that day (last day) happened before the date passed, then it's not a full day, and stamp the time.
		IF @OldestUpdDailyBeforeEnd < @DateToUseEnd 
				AND @OldestUpdDailyBeforeEnd > DATEADD(day, -1, @DateToUseEnd)  -- Just in case someone ran metric into the future.
			SET @EndDateTime = @OldestUpdDailyBeforeEnd
		ELSE
		BEGIN
			IF NOT EXISTS(SELECT * FROM MetricDetail WHERE metriccode = @MetricCode AND PlainDate = @EndDateTime)
			BEGIN
				SELECT @MostRecentPlainDate = MAX(PlainDate) FROM metricDetail WHERE metriccode = @MetricCode AND PlainDate < @EndDateTime
				SELECT @EndDateTime = CASE WHEN Upd_Daily > DATEADD(day, 1, @MostRecentPlainDate) THEN DATEADD(day, 1, @MostRecentPlainDate)
										ELSE Upd_Daily
										END
					FROM metricdetail WHERE metriccode = @MetricCode AND PlainDate = @MostRecentPlainDate
			END
		END
	END

	SELECT dbo.MetricCvtDateToText(@EndDateTime), OldestUpdDailyBeforeEnd = dbo.MetricCvtDateToText(@OldestUpdDailyBeforeEnd), dbo.MetricCvtDateToText(@DateToUseEnd)
GO
GRANT EXECUTE ON  [dbo].[MetricDetermineDetailEndDateTime] TO [public]
GO
