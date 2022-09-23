SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateTMStatus]
						@lLegNum int, 
						@lTourNum int,
						@sOrderNum varchar(12), 
						@lMoveNum int, 
						@sTractor varchar(13), 
						@lStopNum int,
						@sFlags varchar(22),
						@sNewStatus varchar(6),
						@lNoOverride int
AS

/** 
 * 
 * NAME: 
 * dbo.tmail_UpdateTMStatus
 * 
 * TYPE: 
 * StoredProcedure
 * 
 * DESCRIPTION: 
 * Updates the legheader.lgh_tm_status field.
 * 
 * RETURNS: 
 * none
 *
 * RESULT SETS: 
 * none
 * 
 * PARAMETERS: 	
 * 001 - @lLegNum, int, input
 * 002 - @lTourNum, int, input
 * 003 - @sOrderNum, varchar(12), input
 * 004 - @lMoveNum, int, input
 * 005 - @sTractor, varchar(13), input
 * 006 - @lStopNum, int, input
 * 007 - @sFlags, varchar(12), input
 *          1 = Set TMStatus on all Stops
 * 008 - @sNewStatus, varchar(6), input
 * 009 - @lNoOverride, int, input
 *
 * REFERENCES:
 * dbo.tmail_get_lgh_number_sp
 * dbo.tmail_lghUpdatedBy
 * dbo.tmail_createstop214pending
 * 
 * REVISION HISTORY: 
 * 03/16/2006 - PTS22342 - MIZ - Added support for READY status
 * 04/28/2006 - PTS32829 - CSH - Better handling of NULLS, so can ignore ANSI_NULLS setting
 * 07/05/2006 -            CSH - fix merged code error, undocumented code change by Tim was missed in PTS32829 work
 *
 **/ 

/****************** NewStatus values *****************************************
  NOSENT - You can always reset to NOSENT.
  SENT   - We can only update to SENT if not (ACCEPTED or Higher) 
  REJECT - We can only update to REJECT if not (ACCEPTED or Higher) 
  ACCEPT - We can only update to ACCEPT if NOSENT, SENT, REJECT 
  LATE   - Load Late form has come in (Can always change to LATE)
  ACCDNT - Accident form has come in (Can always change to ACCDNT)
  BRKDWN - Breakdown form has come in (Can always change to BRKDWN)
  OK     - We can only update to OK if NOT LATE 
  ARVG   - We can only update to ARVG if NOT LATE 
  ARVD   - We can only update to ARVD if NOT LATE   
  DEPD   - We can only update to DEPD if NOT LATE 
  LTARVG - We can only update to LTARVG if NOT LATE 
  LTARVD - We can only update to LTARVD if NOT LATE 
  LTDEPD - We can only update to LTDEPD if NOT LATE     
  TRPBEG - We can only update to TRPBEG if NOT LATE     
  TRPEND - We can only update to TRPEND if NOT LATE     
  ERROR  - We can only update to ERROR if NOT LATE 
  VERBAL - We can only update to VERBAL if SENT 
  READ   - We can only update to READ if SENT.		jgf 9/27/04 {23021}
  READY  - We can only update to READY if NOSENT
            This status means that the planners are done and it's released for dispatchers to send out.
            Can only be set through VDisp UI, not TotalMail (this proc will err if @sNewStatus = 'READY' . 
******************************************************************************/

/*************** NoOverride values **************
	+1	Don't overwrite LATE status.  NOTE that this will also prevent stop level updates in 
		this case.  Without an SR: this will be FAJ.
*************************************************/

SET NOCOUNT ON 

DECLARE @sCurrentStatus varchar(6),
	@sLegNum varchar(12),
	@sMoveNum varchar(12),
	@arrivaldate datetime,
	@departuredate datetime,
	@edidate datetime,
	@ediactivitycode varchar(6),
	@NeedUpd int,
	@lFlags bigint

-- Do we have a status to update
IF ISNULL(@sNewStatus, '') = ''
	RETURN

SET @lFlags = CONVERT(bigint, @sFlags)

--get Leg Header Number if not passed in
if ISNULL(@lLegNum, 0) = 0 AND ISNULL(@lTourNum, 0) = 0 
	BEGIN
	IF ISNULL(@lStopNum, 0) > 0
		-- Stop Number was supplied, look up leg using it.
		SELECT @lLegNum = lgh_number 
		FROM stops (NOLOCK) 
		WHERE stp_number = @lStopNum
	ELSE
		BEGIN
		IF ISNULL(@lMoveNum, 0) = 0
			SELECT @sMoveNum = ''
		ELSE
			SELECT @sMoveNum = CONVERT(VARCHAR(12), @lMoveNum)
	
		EXEC dbo.tmail_get_lgh_number_sp @sOrderNum, @sMoveNum, @sTractor, @sLegNum OUT
		if ISNULL(@sLegNum, '') > ''
			SELECT @lLegNum = CONVERT(int, @sLegNum)
		END
	END
ELSE IF ISNULL(@lStopNum, 0) > 0
	-- Stop Number was supplied as well, make sure it is on this leg.
	IF NOT EXISTS (SELECT * 
					FROM stops (NOLOCK)
					INNER JOIN legheader (NOLOCK) ON stops.lgh_number = legheader.lgh_number
					WHERE (((legheader.lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((legheader.lgh_tour_number = @lTourNum) AND (@lTourNum > 0)))
					AND stops.stp_number = @lStopNum)
		BEGIN
		RAISERROR ('Stop (%d) and legheader (%d) or tour (%d) conflict.', 15, 1, @lStopNum, @lLegNum, @lTourNum)
		RETURN
		END

--no legheader number found and no tour number, goodbye
SELECT @lLegNum = ISNULL(@lLegNum, 0), @lTourNum = ISNULL(@lTourNum, 0)
if @lLegNum <= 0 AND @lTourNum <= 0
	RETURN

IF @lStopNum = 0 SELECT @lStopNum = NULL -- Cleaner for backward compat to store NULL if unused rather than 0

-- Make sure we have an upper case to compare
SET @sNewStatus = UPPER(@sNewStatus)

-- Get the current lgh_tm_status
SET @sCurrentStatus = ''
IF @lTourNum = 0
	SELECT @sCurrentStatus = ISNULL(lgh_tm_status,'')
	FROM legheader (NOLOCK)
	WHERE ((lgh_number = @lLegNum) AND (@lLegNum > 0)) 
ELSE
	SELECT @sCurrentStatus = ISNULL(lgh_tm_status,'')
	FROM legheader (NOLOCK)
	WHERE ((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0))

-- See if the LATE NoOverride flag is set
IF (@lNoOverride & 1) > 0 AND @sCurrentStatus = 'LATE'
	RETURN	-- Flag +1 is set, and status is LATE, so leave

SET @NeedUpd = 0
IF @lTourNum = 0
  BEGIN
        -- 04/28/2006 CSH  handle NULLS better
	IF EXISTS (SELECT *
			FROM legheader (NOLOCK) 
			WHERE ((lgh_number = @lLegNum) AND (@lLegNum > 0)) AND
			(ISNULL(lgh_tm_status,'') <> @sNewStatus or lgh_tmstatusstopnumber <> @lStopNum))
		SET @NeedUpd = 1
  END
ELSE
  BEGIN
        -- 04/28/2006 CSH  handle NULLS better
	IF EXISTS (SELECT * 
			FROM legheader (NOLOCK) 
			WHERE ((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0)) AND
			(ISNULL(lgh_tm_status,'') <> @sNewStatus or lgh_tmstatusstopnumber <> @lStopNum))
		SET @NeedUpd = 1
  END

IF @NeedUpd <> 0
  BEGIN
	-- We can always update on LATE, ACCDNT, BRKDWN or NOSENT
	IF @sNewStatus IN ('LATE', 'ACCDNT', 'BRKDWN', 'NOSENT')
		IF @lTourNum = 0
		  BEGIN
			UPDATE legheader 
			SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
			WHERE ((lgh_number = @lLegNum) AND (@lLegNum > 0))
	
			-- Set the lgh_updatedby fields
			EXEC dbo.tmail_lghUpdatedBy @lLegNum
		  END
		ELSE
			UPDATE legheader 
			SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
			WHERE ((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0))
	
	-- We can only update to SENT if not (ACCEPTED or Higher) 
	ELSE IF @sNewStatus = 'SENT' 
		IF @lTourNum = 0
		  BEGIN
			UPDATE legheader 
			SET lgh_tm_status = 'SENT', lgh_tmstatusstopnumber = @lStopNum
			WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)))
				AND ISNULL(lgh_tm_status,'NOSENT') NOT IN ('ACCEPT', 'OK', 'ARVG', 'ARVD', 'DEPD', 'LTARVG', 'LTARVD', 'LTDEPD', 'TRPBEG', 'TRPEND', 'ERROR', 'LATE', 'READ') --jgf 9/27/04 add READ for Schneider {23021}
	
			-- Set the lgh_updatedby fields
			EXEC dbo.tmail_lghUpdatedBy @lLegNum
		  END
		ELSE
			UPDATE legheader 
			SET lgh_tm_status = 'SENT', lgh_tmstatusstopnumber = @lStopNum
			WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0)))
				AND ISNULL(lgh_tm_status,'NOSENT') NOT IN ('ACCEPT', 'OK', 'ARVG', 'ARVD', 'DEPD', 'LTARVG', 'LTARVD', 'LTDEPD', 'TRPBEG', 'TRPEND', 'ERROR', 'LATE', 'READ') --jgf 9/27/04 add READ for Schneider {23021}
	
	-- We can only update to REJECT or ACCEPT if NOSENT, SENT, ACCEPT, REJECT, READ or READY 
	ELSE IF @sNewStatus IN ('REJECT', 'ACCEPT')
		IF @lTourNum = 0
		  BEGIN
			UPDATE legheader 
			SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
			WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)))
				AND ISNULL(lgh_tm_status,'NOSENT') IN ('NOSENT', 'SENT', 'ACCEPT', 'REJECT', 'READ', 'READY') --jgf 9/27/04 add READ for Schneider {23021}
	
			-- Set the lgh_updatedby fields
			EXEC dbo.tmail_lghUpdatedBy @lLegNum
		  END
		ELSE
			UPDATE legheader 
			SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
			WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0)))
				AND ISNULL(lgh_tm_status,'NOSENT') IN ('NOSENT', 'SENT', 'ACCEPT', 'REJECT', 'READ', 'READY') --jgf 9/27/04 add READ for Schneider {23021}
	
	-- We can only update to trip status types if NOT LATE 
	ELSE IF @sNewStatus IN ('OK', 'ERROR', 'ARVG', 'ARVD', 'DEPD', 'LTARVG', 'LTARVD', 'LTDEPD', 'TRPBEG', 'TRPEND')
		IF @lTourNum = 0
		  BEGIN
			UPDATE legheader 
			SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
			WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)))
				AND ISNULL(lgh_tm_status,'NOSENT') <> 'LATE'
	
			-- Set the lgh_updatedby fields
			EXEC dbo.tmail_lghUpdatedBy @lLegNum
		  END
		ELSE
			UPDATE legheader 
			SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
			WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0)))
				AND ISNULL(lgh_tm_status,'NOSENT') <> 'LATE'
	
	-- We can only update to trip status types if SENT or READY
	ELSE IF @sNewStatus IN ('VERBAL', 'READ')  --jgf 9/27/04 add READ for Schneider {23021}
		IF @lTourNum = 0
		  BEGIN
			UPDATE legheader 
			SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
			WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)))
				AND ISNULL(lgh_tm_status,'NOSENT') IN ('SENT', 'READY')
	
			-- Set the lgh_updatedby fields
			EXEC dbo.tmail_lghUpdatedBy @lLegNum
		  END
		ELSE
			UPDATE legheader 
			SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
			WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0)))
				AND ISNULL(lgh_tm_status,'NOSENT') IN ('SENT', 'READY')
	
	ELSE	-- Unrecognized status.
	  BEGIN
		RAISERROR ('Unrecognized TMStatus: %s.', 15, 1, @sNewStatus)
		RETURN
	  END
  END -- @NeedUpd <> 0

--update all stops to new status if flag 1 is on
IF (@lFlags & 1) = 1
	UPDATE stops
	SET stp_tmstatus = @sNewStatus
	WHERE lgh_number = @lLegNum
		AND ISNULL(stp_tmstatus,'') <> @sNewStatus 

-- If no stop number , skip updating the stop.
IF ISNULL(@lStopNum, 0) <= 0 
	RETURN

-- Update stop status, if lgh_tm_status update was successful
-- 07/05/2006  CSH  fix merged code error, missing ISNULL
IF EXISTS (SELECT * 
			FROM STOPS (NOLOCK)
			WHERE  ISNULL(stp_tmstatus,'') <> @sNewStatus AND stp_number = @lStopNum)
	UPDATE stops
	SET stp_tmstatus = @sNewStatus
	WHERE stp_number = @lStopNum

SELECT @ediactivitycode = (SELECT ISNULL(MIN(gi_string1), '') 
							FROM generalinfo (NOLOCK)
							WHERE gi_name = 'TMStatEDICode_' + @sNewStatus)
IF @ediactivitycode <> ''
	BEGIN
	-- There is an EDI equivalent 214 defined for this TotalMail status, so let's cut the record
	SELECT @ArrivalDate = stp_arrivaldate, @DepartureDate = stp_departuredate FROM stops WHERE stp_number = @lStopNum
	SELECT @EDIDate = CASE @sNewStatus
		WHEN 'ARVD' THEN @ArrivalDate
		WHEN 'DEPD' THEN @DepartureDate
		ELSE GETDATE()
		END
	exec dbo.tmail_createstop214pending @lStopNum, @ediactivitycode, NULL
	END
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateTMStatus] TO [public]
GO
