SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tmail_ShiftScheduleLogout_Enhanced] (@Drv VARCHAR(30),@ssid VARCHAR(30), @LogoutDateTime VARCHAR(30), @flags VARCHAR(10))

AS

/*

	Purpose:	Updates the driver logout datetime the shift schedule along with 
				validating and/or Setting the approapriate assets for 
				Tractor, Trailer1 AND Trailer2.
			
			Flags:
				1 - Ignore SSID AND Logout Current Logged In Shift.
				2 - Update logout based on logoutdatetime regardless of a missing login.
				4 - No error on shift logout exists.
				8 - If only incomplete activity on shift is final deadhead, auto complete it.
				16- Error if incomplete activity remaining on shift.
				
	History:
		LAB - 07/11/11 - PTS 41960 - Created

*/

SET NOCOUNT ON 

	DECLARE @dtLogoutDateTime DATETIME
	DECLARE @ssidProvided int

	--Validate Date
	IF ISDATE(@LogoutDateTime) = 0
	BEGIN
		RAISERROR ('(tmail_ShiftScheduleLogout) Logout Unsuccessful.  Invalid Logout Date: %s.', 16, 1, @LogoutDateTime)
		RETURN
	END
	ELSE 
	BEGIN
		SET @dtLogoutDateTime = @LogoutDateTime
	END

	IF @ssid = ''
		SET @ssid = -1

	SELECT @ssidProvided = 0
	IF ISNULL(@ssid, -1)<>-1 SELECT @ssidProvided=1

	--Shift provided, so validate
	IF @ssidProvided<>0
	BEGIN
		IF  NOT EXISTS (SELECT NULL From shiftschedules (NOLOCK) WHERE ss_id = @ssid AND mpp_id = @DRV)
		BEGIN
			RAISERROR ('(tmail_ShiftScheduleLogout) Shift Schedule (%s) does not exist for driver (%s).', 16, 1, @ssid, @drv)
			RETURN
		END
		ELSE
		BEGIN
			IF @Flags & 2 = 0 AND NOT EXISTS (SELECT NULL FROM shiftschedules (NOLOCK) WHERE ss_id = @ssid AND mpp_id = @DRV AND ISNULL(ss_logindate,'01/01/1950 00:00')<>'01/01/1950 00:00')
			BEGIN
				RAISERROR ('(tmail_ShiftScheduleLogout) Shift Schedule (%s) not logged in for driver (%s).', 16, 1, @ssid, @drv)
				RETURN
			END
			ELSE
			BEGIN
				IF  @Flags & 4 = 0 AND EXISTS (SELECT NULL FROM shiftschedules (NOLOCK) WHERE ss_id = @ssid AND mpp_id = @DRV AND ISNULL(ss_logoutdate,'12/31/2049 00:00')<'12/31/2049 00:00') 
				BEGIN
					RAISERROR ('(tmail_ShiftScheduleLogout) Shift Schedule (%s) already logged out for driver (%s).', 16, 1, @ssid, @drv)
					RETURN
				END
				ELSE
				BEGIN
					UPDATE shiftschedules
					SET ss_logoutdate = @dtLogoutDateTime
					WHERE ss_id  = @ssid
						AND ss_logindate <= @dtLogoutDateTime 

					SELECT @ssid,''

					RETURN
				END
			END
		END
	END
	ELSE
	BEGIN
		--Shift not provided
		IF ISNULL(@ssid,-1)=-1 AND @Flags & 1 = 0
		BEGIN
			RAISERROR ('(tmail_ShiftScheduleLogout) Logout Unsuccessful.  No Shift Schedule provided For Driver: %s.', 16, 1, @Drv)
			RETURN
		END
		ELSE
		BEGIN
			--Look up the ssid for current logged in shift
			SELECT @ssid = ISNULL(ss_id,-1) 
			FROM shiftschedules (NOLOCK)
			WHERE mpp_id = @DRV
				AND ISNULL(ss_logoutdate, '12/31/2049 00:00') >= '12/31/2049 00:00'
				AND ISNULL(ss_logindate,'01/01/1950 00:00')<>'01/01/1950 00:00'
				AND ss_date = (SELECT max(ss_date) FROM shiftschedules (NOLOCK) WHERE mpp_id = @DRV
				AND ISNULL(ss_logoutdate, '12/31/2049 00:00') >= '12/31/2049 00:00'
				AND ISNULL(ss_logindate,'01/01/1950 00:00')<>'01/01/1950 00:00')
		
			IF @Flags & 2 <> 0 AND ISNULL(@ssid,-1)=-1
			BEGIN
				--Look up the ssid for the current shift regardless of login if we still haven't found it
				SELECT @ssid = ISNULL(ss_id,-1) 
				FROM shiftschedules (NOLOCK)
				WHERE mpp_id = @DRV
					AND ISNULL(ss_logoutdate, '12/31/2049 00:00') >= '12/31/2049 00:00'
					AND DATEPART(YEAR,ss_date) = DATEPART(YEAR, @dtLogoutDateTime)
					AND DATEPART(MONTH, ss_date) = DATEPART(MONTH, @dtLogoutDateTime)
					AND DATEPART(DAY, ss_date) = DATEPART(DAY, @dtLogoutDateTime)
					AND ss_date = (SELECT max(ss_date) 
									FROM shiftschedules (NOLOCK) WHERE mpp_id = @DRV
										AND ISNULL(ss_logoutdate, '12/31/2049 00:00') >= '12/31/2049 00:00'
										AND DATEPART(YEAR,ss_date) = DATEPART(YEAR, @dtLogoutDateTime)
										AND DATEPART(MONTH, ss_date) = DATEPART(MONTH, @dtLogoutDateTime)
										AND DATEPART(DAY, ss_date) = DATEPART(DAY, @dtLogoutDateTime))
			END
		
			--Last attempt to look for the schedule which is already logged out
			IF ISNULL(@ssid,-1)=-1 AND EXISTS(
			SELECT NULL 
			FROM shiftschedules (NOLOCK)
			WHERE mpp_id = @DRV
				AND ISNULL(ss_logoutdate, '12/31/2049 00:00') < '12/31/2049 00:00'
				AND DATEPART(YEAR,ss_date) = DATEPART(YEAR, @dtLogoutDateTime)
				AND DATEPART(MONTH, ss_date) = DATEPART(MONTH, @dtLogoutDateTime)
				AND DATEPART(DAY, ss_date) = DATEPART(DAY, @dtLogoutDateTime)
				AND ss_date = (SELECT max(ss_date) 
								FROM shiftschedules (NOLOCK) WHERE mpp_id = @DRV
									AND ISNULL(ss_logoutdate, '12/31/2049 00:00') < '12/31/2049 00:00'
									AND DATEPART(YEAR,ss_date) = DATEPART(YEAR, @dtLogoutDateTime)
									AND DATEPART(MONTH, ss_date) = DATEPART(MONTH, @dtLogoutDateTime)
									AND DATEPART(DAY, ss_date) = DATEPART(DAY, @dtLogoutDateTime)))
			BEGIN
				IF @Flags & 4 <> 0
				BEGIN
					SELECT @ssid = ISNULL(ss_id,-1) 
					FROM shiftschedules (NOLOCK)
					WHERE mpp_id = @DRV
						AND ISNULL(ss_logoutdate, '12/31/2049 00:00') < '12/31/2049 00:00'
						AND DATEPART(YEAR,ss_date) = DATEPART(YEAR, @dtLogoutDateTime)
						AND DATEPART(MONTH, ss_date) = DATEPART(MONTH, @dtLogoutDateTime)
						AND DATEPART(DAY, ss_date) = DATEPART(DAY, @dtLogoutDateTime)
						AND ss_date = (SELECT max(ss_date) 
										FROM shiftschedules (NOLOCK) WHERE mpp_id = @DRV
											AND ISNULL(ss_logoutdate, '12/31/2049 00:00') < '12/31/2049 00:00'
											AND DATEPART(YEAR,ss_date) = DATEPART(YEAR, @dtLogoutDateTime)
											AND DATEPART(MONTH, ss_date) = DATEPART(MONTH, @dtLogoutDateTime)
											AND DATEPART(DAY, ss_date) = DATEPART(DAY, @dtLogoutDateTime))
					SELECT @ssid,''
					RETURN
				END
				ELSE
				BEGIN
					RAISERROR ('(tmail_ShiftScheduleLogout) Logout Unsuccessful.  Shift Schedule previously logged out for Driver %s.', 16, 1, @Drv)
					RETURN
				END
			END
		END
	END
	IF ISNULL(@ssid,-1)=-1
	BEGIN
		RAISERROR ('Logout Unsuccessful.  No Shift Schedule found or provided for driver: %s.', 16, 1, @Drv)
		RETURN
	END

	DECLARE @ExtraText varchar(80)
	SELECT @ExtraText=''
	IF @Flags & 8 <> 0
		 AND 1=(SELECT COUNT(*) FROM legheader (NOLOCK) WHERE lgh_outstatus = 'STD' and shift_ss_id = @ssid)
		 AND NOT EXISTS (SELECT * FROM legheader (NOLOCK) WHERE lgh_outstatus in ('PLN', 'DSP') and shift_ss_id = @ssid)
	BEGIN
		-- Check if final trip (the STD one) can be completed.
		DECLARE @IncompleteTrip int, @IncompleteStops int, @IncompleteMove int,
			@IncompleteStop int, @IncompleteEvent varchar(6), 
			@LastStopArvTime DateTime, @LastStopDptStt varchar(6), @LastStopDptTime DateTime, @LastStpNum int
		SELECT top 1 @IncompleteTrip = lgh_number, @IncompleteMove = mov_number FROM legheader (NOLOCK)
			WHERE lgh_outstatus = 'STD' and shift_ss_id = @ssid
			ORDER BY mfh_number
		SELECT @IncompleteStops = COUNT(stp_number) FROM stops (NOLOCK)
			WHERE lgh_number = @IncompleteTrip and stp_status='OPN'
		IF @IncompleteStops=1
		BEGIN
			SELECT @IncompleteStop = MIN(stp_number), @IncompleteEvent=MIN(stp_event) FROM stops (NOLOCK)
				WHERE lgh_number = @IncompleteTrip and stp_status='OPN'
			SELECT TOP 1 @LastStopDptStt = stp_departure_status, @LastStpNum =stp_number,
				@LastStopArvTime = stp_arrivaldate, @LastStopDptTime = stp_departuredate 
				FROM stops (NOLOCK) where lgh_number = @IncompleteTrip and stp_status = 'CMP'
				ORDER BY stp_mfh_sequence desc
			IF @IncompleteEvent <> 'EMT' AND @IncompleteEvent <> 'IEMT'
			BEGIN
				SELECT @ExtraText = '  Could not auto-complete stop '+CONVERT(VARCHAR(20), @IncompleteStop)+ ' because it was a '+@IncompleteEvent +' (not EMT).'
			END
			ELSE IF @LastStopArvTime >= @LogoutDateTime
			BEGIN
				SELECT @ExtraText = '  Could not auto-complete stop '+CONVERT(VARCHAR(20), @IncompleteStop)+ ' because the prior stop arrived too late ('+CONVERT(varchar(30), @LastStopArvTime) +'>='+CONVERT(varchar(30), @LogoutDateTime)+')'
			END
			ELSE IF @LastStopDptTime >= @LogoutDateTime AND @LastStopDptStt = 'DNE'
			BEGIN
				SELECT @ExtraText = '  Could not auto-complete stop '+CONVERT(VARCHAR(20), @IncompleteStop)+ ' because the prior stop departed too late ('+CONVERT(varchar(30), @LastStopDptTime) +'>='+CONVERT(varchar(30), @LogoutDateTime)+')'
			END
			ELSE
			BEGIN
				IF @LastStopDptStt <> 'DNE'
					UPDATE stops SET stp_departuredate = DATEADD(mi, -1, @LogoutDateTime), stp_departure_status='DNE'
					WHERE stp_number = @LastStpNum
				UPDATE stops 
					SET stp_arrivaldate = @LogoutDateTime, stp_departuredate = @LogoutDateTime,
					stp_status = 'DNE', stp_departure_status = 'DNE'
					WHERE stp_number = @IncompleteStop
				exec dbo.update_move @IncompleteMove
				exec dbo.update_ord @IncompleteMove, 'CMP', 0
			END
		END
	END
	IF @Flags & 16 <> 0 AND EXISTS (SELECT * FROM legheader (NOLOCK) WHERE lgh_outstatus in ('PLN', 'DSP', 'STD') and shift_ss_id = @ssid)
	BEGIN
		DECLARE @IncompleteCount int
		SELECT @IncompleteCount = COUNT(lgh_number)
			FROM legheader (NOLOCK) WHERE lgh_outstatus in ('PLN', 'DSP', 'STD') and shift_ss_id = @ssid
		RAISERROR ('(tmail_ShiftScheduleLogout) %u incomplete trips still remaining for shift schedule (%s) for driver (%s).%s', 16, 1, @IncompleteCount, @ssid, @drv, @ExtraText)
		RETURN
	END

	if @ssidProvided=0 
	UPDATE shiftschedules
	SET ss_logindate = ss_starttime
	WHERE ss_id = @ssid
		AND ISNULL(ss_logindate,'01/01/1950 00:00')='01/01/1950 00:00'
		AND @Flags & 2 <> 0

	UPDATE shiftschedules
	SET ss_logoutdate = @dtLogoutDateTime
	WHERE ss_id  = @ssid
		AND ss_logindate <= @dtLogoutDateTime 
		
	SELECT @ssid,''
	
GO
GRANT EXECUTE ON  [dbo].[tmail_ShiftScheduleLogout_Enhanced] TO [public]
GO
