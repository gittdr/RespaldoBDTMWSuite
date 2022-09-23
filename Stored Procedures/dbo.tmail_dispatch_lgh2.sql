SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_dispatch_lgh2]
	@movenumber varchar(12),
	@tractornumber varchar(13),
	@DriverID varchar(8),
	@sLegNum varchar(12),
    @sFlags varchar(22)
AS

SET NOCOUNT ON

DECLARE @lLegNum int, 	
		@lmove int,
  	    @iFlags bigint,
		@bUpdateEquip int,
		@CrLf varchar(2),
		@TractorInTMWSuite varchar(13),
		@DriverInTMWSuite varchar(8),
		@WorkEvent int,
		@UpdateFlag int,
		@UpdateMovPreProcessor varchar(256),
		@UpdateMovPreProcessorSwitch varchar(1),
		@UpdateMovPostProcessor varchar(256),
		@UpdateMovPostProcessorSwitch varchar(1)

-- Convert the @Flags to an int so we can do math on it
--  This is mainly for SQL Server 6.5 users
SET @iFlags = CONVERT(bigint, ISNULL(@sFlags,'0'))

IF (@iFlags & 128) <> 0 
	SET @bUpdateEquip = 1
ELSE
	SET @bUpdateEquip = 0
	
SET @lLegNum = CONVERT(int, ISNULL(@sLegNum, '0'))

IF @bUpdateEquip = 0 AND NOT EXISTS (SELECT * 
										FROM legheader (NOLOCK) 
										WHERE lgh_number = @lLegNum AND lgh_outstatus = 'PLN')
	RETURN

SELECT @UpdateFlag = COUNT(*) 
FROM legheader (NOLOCK)
WHERE lgh_number = @lLegNum 
	AND lgh_outstatus = 'PLN'

-- Change lgh_outstatus to Dispatched
UPDATE legheader
SET lgh_outstatus = 'DSP', lgh_dsp_date = GetDate()
WHERE lgh_number = @lLegNum 
	AND lgh_outstatus = 'PLN'

-- Set the lgh_updatedby fields
EXEC dbo.tmail_lghUpdatedBy @lLegNum

-- Update the resources for events on this legheader
IF @bUpdateEquip = 1
  BEGIN
	IF ISNULL(@tractornumber, 'UNKNOWN') <> 'UNKNOWN' AND ISNULL(@tractornumber, '')<> ''
	  BEGIN
			IF ISNULL(@DriverID, 'UNKNOWN') <> 'UNKNOWN' AND ISNULL(@DriverID, '')<> ''
				BEGIN

					--Get correct case for Tractor ID
					SELECT @TractorInTMWSuite = trc_number 
						FROM TractorProfile(NOLOCK)
						WHERE trc_number = @tractornumber
					--Get correct case for Driver ID
					SELECT @DriverInTMWSuite = mpp_id
						FROM ManPowerProfile (NOLOCK)
						WHERE mpp_id = @DriverID
					
					SELECT @WorkEvent = MIN(evt_number) 
					FROM event (NOLOCK)
						WHERE stp_number in 
							(SELECT stp_number FROM stops WHERE lgh_number = @lLegNum)
						AND (evt_tractor <> @TractorInTMWSuite OR evt_driver1 <> @DriverInTMWSuite)

					WHILE ISNULL(@WorkEvent, 0) <> 0
						BEGIN
						SELECT @UpdateFlag = 1
						UPDATE event 
							SET evt_tractor = @TractorInTMWSuite, 
								evt_driver1 = @DriverInTMWSuite
							WHERE evt_number = @WorkEvent

						SELECT @WorkEvent = MIN(evt_number) 
						FROM event (NOLOCK)
							WHERE stp_number in 
								(SELECT stp_number 
									FROM stops (NOLOCK)
									WHERE lgh_number = @lLegNum)
							AND (evt_tractor <> @TractorInTMWSuite OR evt_driver1 <> @DriverInTMWSuite)
							AND evt_number > @WorkEvent
						END

				END
			ELSE
				BEGIN 
					--Get correct case for Tractor ID
					SELECT @TractorInTMWSuite = trc_number 
						FROM TractorProfile (NOLOCK)
						WHERE trc_number = @tractornumber
	
					SELECT @WorkEvent = MIN(evt_number) 
					FROM event (NOLOCK)
						WHERE stp_number in 
							(SELECT stp_number 
							FROM stops(NOLOCK) 
							WHERE lgh_number = @lLegNum)
						AND evt_tractor <> @TractorInTMWSuite 

					WHILE ISNULL(@WorkEvent, 0) <> 0
						BEGIN
						SELECT @UpdateFlag = 1
						UPDATE event 
							SET evt_tractor = @TractorInTMWSuite
							WHERE evt_number = @WorkEvent

						SELECT @WorkEvent = MIN(evt_number) 
						FROM event (NOLOCK)
							WHERE stp_number in 
								(SELECT stp_number 
								FROM stops (NOLOCK) 
								WHERE lgh_number = @lLegNum)
							AND evt_tractor <> @TractorInTMWSuite 
							AND evt_number > @WorkEvent
						END
				END
	  END
	ELSE IF ISNULL(@DriverID, 'UNKNOWN') <> 'UNKNOWN' AND ISNULL(@DriverID, '')<> ''
		BEGIN
			--Get correct case for Driver ID
			SELECT @DriverInTMWSuite = mpp_id
				FROM ManPowerProfile (NOLOCK)
				WHERE mpp_id = @DriverID
					
			SELECT @WorkEvent = MIN(evt_number) 
			FROM event (NOLOCK)
				WHERE stp_number in 
					(SELECT stp_number 
					FROM stops (NOLOCK)
					WHERE lgh_number = @lLegNum)
				AND evt_driver1 <> @DriverInTMWSuite
	
			WHILE ISNULL(@WorkEvent, 0) <> 0
				BEGIN
				SELECT @UpdateFlag = 1
				UPDATE event 
					SET evt_driver1 = @DriverInTMWSuite
					WHERE evt_number = @WorkEvent

				SELECT @WorkEvent = MIN(evt_number) FROM event
					WHERE stp_number in 
						(SELECT stp_number 
						FROM stops (NOLOCK)
						WHERE lgh_number = @lLegNum)
					AND evt_driver1 <> @DriverInTMWSuite
					AND evt_number > @WorkEvent
				END
		END

	-- ELSE If neither driver nor tractor is known, don't bother to update anything, and I am really curious how we got this situation!
	ELSE
	  BEGIN
		SET @CrLf = CHAR(13) + CHAR(10)
		RAISERROR ('Update Equipment on, but no known driver or tractor: lgh_number: %s%sPlease call TMW (Should never happen)', 16, 1, @sLegNum, @CrLf)
		RETURN
	  END
	END

IF @UpdateFlag = 0 RETURN

-- Get the move number if we don't have it
IF ISNULL(@movenumber,'') = '' or RTRIM(LTRIM(@movenumber)) = '0'
  BEGIN
	SET @lmove = 0

	SELECT @lmove = mov_number
	FROM legheader
	WHERE lgh_number = @lLegNum

	SET @movenumber = CONVERT(varchar(12), @lmove)
  END

-- PTS 27180
-- Get the update move pre-processor
SET @UpdateMovPreProcessor = ''
SET @UpdateMovPreProcessorSwitch = ''
SELECT @UpdateMovPreProcessorSwitch = gi_string1, @UpdateMovPreProcessor = gi_string2
FROM generalinfo (NOLOCK)
WHERE gi_name = 'DispatchPreLghProcessing'

-- Get the update move post-processor
SET @UpdateMovPostProcessor = ''
SET @UpdateMovPostProcessorSwitch = ''
SELECT @UpdateMovPostProcessorSwitch = gi_string1, @UpdateMovPostProcessor = gi_string2
FROM generalinfo (NOLOCK)
WHERE gi_name = 'DispatchPostLghProcessing'

-- PTS 14534
EXEC dbo.update_assetassignment @movenumber

-- run the update move pre-processor
if @UpdateMovPreProcessorSwitch = 'Y' AND LTRIM(@UpdateMovPreProcessor) > ''
	EXEC (@UpdateMovPreProcessor + ' ' + @movenumber)

EXEC dbo.update_move_light @movenumber

-- run the update move post-processor
if @UpdateMovPostProcessorSwitch = 'Y' AND LTRIM(@UpdateMovPostProcessor) > ''
	EXEC (@UpdateMovPostProcessor + ' ' + @movenumber)

EXEC dbo.update_ord @movenumber, 'UNK'
GO
GRANT EXECUTE ON  [dbo].[tmail_dispatch_lgh2] TO [public]
GO
