SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[MetricProcessing] 
	@MetricCodePassed VARCHAR(200) = NULL, 
	@DateStartPassed varchar(100) = NULL, 
	@DateEndPassed varchar(100) = NULL , 
	@ProcessFlags int = NULL, 			-- Process flags:
										--		+1: CheckMetricSchedules (was ActAsDailyProcessing). 
										--		+2: Disable Alert checking.
										--		+4: Disable automatic metric creation (This is forced to disable when date range is run).
										--		+8: Disable refresh history.
										--		+16: Force RunPreviousDayYN setting to be N.
										--		+32: Ignore Mock Date (simulation date) setting.
										--		+64: Force overwrite of goal history.
										--		+128: Force Daily Briefing for every day in range, as opposed to what appears to be daily updates.
										--		+256: Disable Daily Briefing
										--		+512: Disable Summaries
	@Debug_Level int = NULL,
	@AddOneDayToEnd_YN varchar(1) = NULL
AS
 	SET NOCOUNT ON

 	DECLARE @DateStartPassedConverted datetime
 	DECLARE @DateEndPassedConverted datetime

 	SET @DateStartPassedConverted = CONVERT(datetime, @DateStartPassed)
 	
 	IF ISNULL(@AddOneDayToEnd_YN, 'N') = 'Y'
 	BEGIN
 		IF ISNULL(@DateEndPassed, 'NULL') = 'NULL'
 		BEGIN
 	 		SET @DateEndPassedConverted = NULL
 	 	END
 		ELSE
 		BEGIN
 			SET @DateEndPassedConverted = DATEADD(day, 1, @DateEndPassed)
 		END
 	END
 	ELSE
 	BEGIN
 		SET @DateEndPassedConverted = @DateEndPassed
 	END
 	
 	
 	
	DECLARE @MetricSN int, @MetricCode varchar(200)
	DECLARE @sn int, @TempPlainDate datetime, @TempDateStart datetime, @TempDateEnd datetime, @TempProcessFlags int
	DECLARE @AlreadyHandled int
	DECLARE @tMetricCodes TABLE (sn int identity, MetricCode varchar(200))
	DECLARE @QueueInstances TABLE (sn int, MetricCodePassed varchar(200), DateCreated datetime, PlainDateCreated datetime, DateStartPassed datetime, DateEndPassed datetime, ProcessFlags int)

	IF ISNULL(@MetricCodePassed, '') = ''
	BEGIN
		INSERT INTO @tMetricCodes (MetricCode) 
		SELECT MetricCode FROM MetricItem WHERE Active = 1 order by sort, MetricCode
	
		SELECT @MetricSN = ISNULL(MIN(sn), -1) FROM @tMetricCodes
		SELECT @MetricCode = ISNULL(MetricCode, '') FROM @tMetricCodes WHERE sn = @MetricSN
	END
	ELSE
		SET @MetricCode = @MetricCodePassed
	
	WHILE ISNULL(@MetricCode, '') <> '' -- , then put all the metrics in here.
	BEGIN
		SET @AlreadyHandled = 0

		IF NOT EXISTS(SELECT sn FROM MetricReadyToProcessQueue WHERE metriccodepassed = @MetricCode And ProcessFlags = @ProcessFlags)  -- Adding process flags to make sure it gets all unique instances.  Still different dates go into QueueInstances.
		BEGIN
			INSERT INTO MetricReadyToProcessQueue (DateCreated, PlainDateCreated, MetricCodePassed, DateStartPassed, DateEndPassed, ProcessFlags)
			SELECT GETDATE(), CONVERT(datetime, CONVERT(varchar(10), GETDATE(), 121)), @MetricCode, @DateStartPassedConverted, @DateEndPassedConverted, ISNULL(@ProcessFlags, 0)
		END
		ELSE
		BEGIN
			-- If records exist, then try to eliminate overlap.  
			-- Like if a job is scheduled to run once per hour, there is no sense continuing to process over and over if that hour was missed.
			-- SELECT * INTO #t1 FROM MetricReadyToProcessQueue WHERE MetricCodePassed = @MetricCode
			INSERT INTO @QueueInstances (sn, DateCreated, PlainDateCreated, MetricCodePassed, DateStartPassed, DateEndPassed, ProcessFlags)
				SELECT sn, DateCreated, PlainDateCreated, MetricCodePassed, DateStartPassed, DateEndPassed, ProcessFlags FROM MetricReadyToProcessQueue WHERE MetricCodePassed = @MetricCode

			SELECT @sn = ISNULL(MIN(sn), -1) FROM @QueueInstances
			WHILE @sn > 0
			BEGIN
				SELECT @TempPlainDate = PlainDateCreated, 
						@TempDateStart = DateStartPassed,
						@TempDateEnd = DateEndPassed, 
						@TempProcessFlags = ProcessFlags 
					FROM @QueueInstances WHERE sn = @sn

	/*			SELECT @TempPlainDate , PlainDateCreated, CASE WHEN @TempPlainDate = CONVERT(datetime, CONVERT(varchar(10), GETDATE(), 121)) THEN '=' ELSE '<>' END,
						@TempDateStart , DateStartPassed, CASE WHEN ISNULL(@TempDateStart, '19000101') = ISNULL(@DateStartPassedConverted, '19000101') THEN '=' ELSE '<>' END,
						@TempDateEnd , DateEndPassed, CASE WHEN ISNULL(@TempDateEnd, '19000101') = ISNULL(@DateEndPassedConverted, '19000101') THEN '=' ELSE '<>' END,
						@TempProcessFlags , ProcessFlags, CASE WHEN ISNULL(@TempProcessFlags, 0) = ISNULL(@ProcessFlags, 0) THEN '=' ELSE '<>' END
				FROM #t1 WHERE sn = @sn
	*/

				IF	@TempPlainDate = CONVERT(datetime, CONVERT(varchar(10), GETDATE(), 121)) 
					AND ISNULL(@TempDateStart, '19000101') = ISNULL(@DateStartPassedConverted, '19000101')
					AND ISNULL(@TempDateEnd, '19000101') = ISNULL(@DateEndPassedConverted, '19000101')
					AND ISNULL(@TempProcessFlags, 0) = ISNULL(@ProcessFlags, 0)
				BEGIN -- This entry will already be handled, and don't add to the queue.
					SELECT @sn = -1, @AlreadyHandled = 1
				END
				ELSE
				BEGIN
					SELECT @sn = ISNULL(MIN(sn), -1) FROM @QueueInstances WHERE sn > @sn
				END
			END

			DELETE @QueueInstances

			-- SELECT AlreadyHandled = @AlreadyHandled
			IF @AlreadyHandled = 0
				INSERT INTO MetricReadyToProcessQueue (DateCreated, PlainDateCreated, MetricCodePassed, DateStartPassed, DateEndPassed, ProcessFlags)
				SELECT GETDATE(), CONVERT(datetime, CONVERT(varchar(10), GETDATE(), 121)), @MetricCode, @DateStartPassedConverted, @DateEndPassedConverted, ISNULL(@ProcessFlags, 0)
		END		



		IF ISNULL(@MetricCodePassed, '') <> ''
			SELECT @MetricCode = ''
		ELSE
		BEGIN
			IF EXISTS(SELECT sn FROM @tMetricCodes WHERE sn > @MetricSN)
			BEGIN
				SELECT @MetricSN = ISNULL(MIN(sn), -1) FROM @tMetricCodes WHERE sn > @MetricSN
				SELECT @MetricCode = ISNULL(MetricCode, '') FROM @tMetricCodes WHERE sn = @MetricSN
			END
			ELSE
				SELECT @MetricSN = -1, @MetricCode = ''
			
		END
	END
GO
GRANT EXECUTE ON  [dbo].[MetricProcessing] TO [public]
GO
