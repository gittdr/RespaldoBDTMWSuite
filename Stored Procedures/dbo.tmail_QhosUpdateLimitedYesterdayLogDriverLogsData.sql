SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[tmail_QhosUpdateLimitedYesterdayLogDriverLogsData]	
		@mpp_id					VARCHAR(8),		--
		@log_date				DATETIME,		--
		@off_duty_hrs			FLOAT,			--
		@sleeper_berth_hrs		FLOAT,			--
		@driving_hrs			FLOAT,			--
		@on_duty_hrs			FLOAT,			--
		@skip_trigger			BIT = 0			--
AS

-- =============================================================================
-- Stored Proc: tmail_QhosUpdateLimitedYesterdayLogDriverLogsData
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.04.25
-- Description:
--      This procedure will update a record in the log_driverlogs table using 
--      data received from Omnitracs Hours of Service web interface.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      None										--
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		@mpp_id					VARCHAR(8),		--
--		@log_date				DATETIME,		--
--		@off_duty_hrs			FLOAT,			--
--		@sleeper_berth_hrs		FLOAT,			--
--		@driving_hrs			FLOAT,			--
--		@on_duty_hrs			FLOAT,			--
--		@skip_trigger			BIT = 0			--
--
-- =============================================================================
--
-- Revisions:
-- 09/29/2015 - Abdullah Binghunaiem - PTS 94581: Added a skip-trigger flag
-- 10/13/2015 - Abdullah Binghunaiem - PTS 95651: Added an execute statement to update the
--				manpowerprofile.
-- Check for nulls
IF 
	@mpp_id = NULL 
BEGIN
	RAISERROR (N'mpp_id cannot be NULL.',10, 1)
END

IF
	@log_date = NULL
BEGIN
	RAISERROR (N'log_date cannot be NULL.',10, 1)
END

IF
	@off_duty_hrs = NULL
BEGIN
	RAISERROR (N'off_duty_hrs cannot be NULL.',10, 1)
END

IF
	@sleeper_berth_hrs = NULL
BEGIN
	RAISERROR (N'sleeper_berth_hrs cannot be NULL.',10, 1)
END

IF
	@driving_hrs = NULL
BEGIN
	RAISERROR (N'driving_hrs cannot be NULL.',10, 1)
END

IF
	@on_duty_hrs = NULL
BEGIN
	RAISERROR (N'on_duty_hrs cannot be NULL.',10, 1)
END

BEGIN	
	--------------------------------------------------------------------------------
	UPDATE dbo.log_driverlogs SET
		off_duty_hrs = @off_duty_hrs,
		sleeper_berth_hrs = @sleeper_berth_hrs,
		driving_hrs = @driving_hrs,
		on_duty_hrs = @on_duty_hrs,
		skip_trigger = @skip_trigger
	WHERE 
		mpp_id = @mpp_id
		AND
		CAST(log_date AS DATE) = CAST(@log_date AS DATE)
END	

-- PTS 95651 10.13.15 AB Starts
EXEC update_loghours @mpp_id
-- PTS 95651 10.13.15 AB Ends
GO
GRANT EXECUTE ON  [dbo].[tmail_QhosUpdateLimitedYesterdayLogDriverLogsData] TO [public]
GO
