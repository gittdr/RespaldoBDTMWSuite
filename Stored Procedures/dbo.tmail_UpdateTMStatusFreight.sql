SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateTMStatusFreight]
						@lLegNum int, 
						@lTourNum int,
						@sOrderNum varchar(12), 
						@lMoveNum int, 
						@sTractor varchar(13), 
						@lStopNum int,
						@lFreightDetailNum int,
						@sDummy varchar(6), -- was @sOutStatus, but parm never did anything.
						@sNewStatus varchar(6),
						@lNoOverride int
AS

/****************** NewStatus values *****************************************
  NOSENT - 
  SENT   - We can only update to SENT if not (ACCEPTED or Higher) 
  REJECT - We can only update to REJECT if not (ACCEPTED or Higher) 
  ACCEPT - We can only update to ACCEPT if NOSENT, SENT, REJECT 
  LATE   - Load Late form has come in (Can always change to LATE)
  OK     - We can only update to OK if NOT LATE 
  ERROR  - We can only update to ERROR if NOT LATE 
******************************************************************************/

/*************** NoOverride values **************
	+1	Don't overwrite LATE status.  NOTE that this will also prevent stop level updates in 
		this case.  Without an SR: this will be FAJ.
*************************************************/

SET NOCOUNT ON 

DECLARE @sCurrentStatus varchar(6),
	@sLegNum varchar(12),
	@sMoveNum varchar(12)

-- Do we have a status to update
IF ISNULL(@sNewStatus, '') = ''
	RETURN

--get Leg Header Number if not passed in
if ISNULL(@lLegNum, 0) = 0 AND ISNULL(@lTourNum, 0) = 0 
	BEGIN
	IF ISNULL(@lStopNum, 0) > 0
		-- Stop Number was supplied, look up leg using it.
		SELECT @lLegNum = lgh_number FROM stops (NOLOCK) WHERE stp_number = @lStopNum
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
ELSE IF ISNULL(@lFreightDetailNum, 0) > 0
	-- Freight Detail Number was supplied as well, make sure it is on this leg.
	IF NOT EXISTS (SELECT * FROM FreightDetail (NOLOCK)
		INNER JOIN stops (NOLOCK) ON FreightDetail.stp_number = stops.stp_number
		INNER JOIN legheader (NOLOCK) ON stops.lgh_number = legheader.lgh_number
	WHERE (((legheader.lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((legheader.lgh_tour_number = @lTourNum) AND (@lTourNum > 0)))
	AND FreightDetail.fgt_number = @lFreightDetailNum)
		BEGIN
		RAISERROR ('FreightDetail (%d) and legheader (%d) or tour (%d) conflict.', 15, 1, @lStopNum, @lLegNum, @lTourNum)
		RETURN
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
IF @lFreightDetailNum = 0 SELECT @lFreightDetailNum = NULL -- Cleaner for backward compat to store NULL if unused rather than 0

-- Make sure we have an upper case to compare
SET @sNewStatus = UPPER(@sNewStatus)

-- Get the current lgh_tm_status
SET @sCurrentStatus = ''
SELECT @sCurrentStatus = ISNULL(lgh_tm_status,'')
FROM legheader (NOLOCK)
WHERE ((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0))

-- See if the LATE NoOverride flag is set
IF (@lNoOverride & 1) > 0 AND @sCurrentStatus = 'LATE'
	RETURN	-- Flag +1 is set, and status is LATE, so leave

-- We can always update on LATE, ACCDNT, or BRKDWN
IF @sNewStatus IN ('LATE', 'ACCDNT', 'BRKDWN')
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
		WHERE ((lgh_number = @lLegNum) AND (@lLegNum > 0))
			AND ISNULL(lgh_tm_status,'NOSENT') NOT IN ('ACCEPT', 'OK', 'ARVG', 'ARVD', 'DEPD', 'LTARVG', 'LTARVD', 'LTDEPD', 'ERROR', 'LATE')

		-- Set the lgh_updatedby fields
		EXEC dbo.tmail_lghUpdatedBy @lLegNum
	  END
	ELSE
		UPDATE legheader 
		SET lgh_tm_status = 'SENT', lgh_tmstatusstopnumber = @lStopNum
		WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0)))
			AND ISNULL(lgh_tm_status,'NOSENT') NOT IN ('ACCEPT', 'OK', 'ARVG', 'ARVD', 'DEPD', 'LTARVG', 'LTARVD', 'LTDEPD', 'ERROR', 'LATE')
			
-- We can only update to REJECT or ACCEPT if NOSENT, SENT, ACCEPT, REJECT 
ELSE IF @sNewStatus IN ('REJECT', 'ACCEPT')
	IF @lTourNum = 0
	  BEGIN
		UPDATE legheader 
		SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
		WHERE ((lgh_number = @lLegNum) AND (@lLegNum > 0))
		AND ISNULL(lgh_tm_status,'NOSENT') IN ('NOSENT', 'SENT', 'ACCEPT', 'REJECT')

		-- Set the lgh_updatedby fields
		EXEC dbo.tmail_lghUpdatedBy @lLegNum
	  END
	ELSE
		UPDATE legheader 
		SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
		WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0)))
			AND ISNULL(lgh_tm_status,'NOSENT') IN ('NOSENT', 'SENT', 'ACCEPT', 'REJECT')

-- We can only update to trip status types if NOT LATE 
ELSE IF @sNewStatus IN ('OK', 'ERROR', 'ARVG', 'ARVD', 'DEPD', 'LTARVG', 'LTARVD', 'LTDEPD')
	IF @lTourNum = 0
	  BEGIN
		UPDATE legheader 
		SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
		WHERE ((lgh_number = @lLegNum) AND (@lLegNum > 0))
			AND ISNULL(lgh_tm_status,'NOSENT') <> 'LATE'

		-- Set the lgh_updatedby fields
		EXEC dbo.tmail_lghUpdatedBy @lLegNum
	  END
	ELSE
		UPDATE legheader 
		SET lgh_tm_status = @sNewStatus, lgh_tmstatusstopnumber = @lStopNum
		WHERE (((lgh_number = @lLegNum) AND (@lLegNum > 0)) OR ((lgh_tour_number = @lTourNum) AND (@lTourNum > 0)))
			AND ISNULL(lgh_tm_status,'NOSENT') <> 'LATE'

ELSE	-- Unrecognized status.
	BEGIN
	RAISERROR ('Unrecognized TMStatus: %s.', 15, 0, @sNewStatus)
	RETURN
	END

-- If no stop number, skip updating the stop.
IF ISNULL(@lStopNum, 0) <= 0
	RETURN

-- Update stop and Freight detail status, if lgh_tm_status update was successful
If ISNULL(@lFreightDetailNum, 0) = 0 AND ISNULL(@lStopNum, 0) > 0
	-- Update all Freight Detail statuses for the stop, if lgh_tm_status update was successful
	UPDATE FreightDetail
		SET fgt_tmstatus = @sNewStatus
		WHERE stp_number = @lStopNum
else
	BEGIN
		UPDATE stops
			SET stp_tmstatus = @sNewStatus
			WHERE stp_number = @lStopNum
		
		-- Update Freight Detail status, if lgh_tm_status update was successful
		UPDATE FreightDetail
			SET fgt_tmstatus = @sNewStatus
			WHERE fgt_number = @lFreightDetailNum
	END
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateTMStatusFreight] TO [public]
GO
