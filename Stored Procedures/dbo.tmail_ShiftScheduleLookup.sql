SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[tmail_ShiftScheduleLookup]   @DRV VARCHAR (30), 
											@TRC VARCHAR (15), 
											@LoginDateTime VARCHAR (30), 
											@p_Flags VARCHAR (15), 
											@NumberMinutesToCheckPreviousNextDays VARCHAR (4),
											@NumberMinutesOfPrevNextDayToCheck VARCHAR (4),
											@SSID VARCHAR (30) = NULL OUTPUT, 
											@AlreadyLoggedIn VARCHAR (2) = NULL OUTPUT, 
											@TractorChange VARCHAR (2) = NULL OUTPUT, 
											@DrvOut VARCHAR(30)= null OUTPUT
	
AS

/**
 * 
 * NAME:
 * dbo.tmail_ShiftScheduleLookup
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *	This sp looks for a driver shift with a midnight variance for an early/late log in with in a 24 hour period.  
The sp also looks at if a driver is already logged in for the same shift passign a flag to indicate. Last looks if the TRC
has changed and passes back a flag if a switch has taken place.
 *
 * RETURNS:
 *  @SSID VARCHAR (30),			-- ss_id of schiftschedule row to use.
	@AlreadyLoggedIn INT,		-- Driver has already started this shift once			 (0=not logged in yet, 1=already logged in)
	@TractorChange INT,			- Driver has a schedule, but with a different tractor.  (0=no change, 1=tractor changed)
 *
 * RESULT SETS: 
 *  none
 *
 * PARAMETERS:
 * 001 - @DriverID - varchar(30)
 * 002 - @TRC - varchar(15)
 * 003 - @dtLogDateTime - varchar(30)
 * 004 - @FLAGS - varchar(15)
				1 - NOT USED - Login Shift Strictly based ON LoginDATETIME.  Does not require a shift plan.
				2 - NOT USED - No error ON shift login exists.
				4 - NOT USED - No Error ON mismatch schedule TRC.
				8 - NOT USED - No Error ON mismatch schedule TRL.
				16 - NOT USED - Do Not Logout Previously Logged In Shifts
				32 - NOT USED - No UPDATE of Last Mobile Comm.
				64 - Login Shift Even If it is OFF Duty
				128 - NOT USED - DON't Login - Just UPDATE the Trc,Trl,Trl2
				256 - NOT USED - Switch Assets - Update only Trc,Trl,Trl2 if the Login is already set and new Trc,Trl, or Trl2
				512 - NOT USED - 
				1024 - Look up based on Driver Alt ID
				2048 - Logout shift look up
				4096 - Logout shift lookup - allow multiple login/logout events per shift
				8192 - NOT USED - Adjust trip times
				16384 - Ignore activity/shift status when determining shift date.
					If time specified is within a single shift, then use
					that shift.  Otherwise, if a shift was logged off less
					that 1 hour before the time, use that shift.  Otherwise,
					if a shift starts within 8 hours of the given time, use
					that shift.
 * 005 - @NumberMinutesToCheckPreviousNextDays - varchar(4)
 * 006 - @NumberMinutesOfPrevNextDayToCheck - varchar(4)
 * 007 - @SSID - varchar(30) - OUTPUT
 * 008 - @AlreadyLoggedIn - varchar(2) - OUTPUT
 * 009 - @TractorChange - varchar(2) - OUTPUT
 * 010 - @DrvOut - varchar(30) - OUTPUT
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 10/27/2011.01 -  JC - created for PTS 
 * 09/10/2012.01 - MIZ - PTS64135 - Add 4096 flag, clean up validations and add comments.  
 *									Also fixed the standard logout lookup to find MAX(ss_date) instead of MAX(ss_id) and to limit results to 14 day window.
 * 10/18/2012.01 - JC - PTS61054 -  Set Drvout = null to work with SSlookup View
 * 01/30/2014   HMA, ZB - PTS73685 - when flag 2048 is in use - and shift has been logged out already, we will issue a better error message for the circumstance
 **/
                 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @ShiftDate VARCHAR (30),
		@Debug int,	-- 0=off, 1=on
		@dtLogDateTime datetime,
		@spAlreadyLogIN Int,
		@spTractorChange Int,
		@Flags int
		
/* example
	@NumberMinutesToCheckPreviousNextDays = 125
	@NumberMinutesOfPrevNextDayToCheck = 60

	Driver logs in at 1/1/2011 1:15AM
	
	1:15AM is within 125 minutes of yesterday, so check yesterday for an open schedule
	There is an open schedule for yesterday that starts at 11:15 PM. This is within 125 minutes of midnight, so is a valid schedule.		
*/




DECLARE @Schedules TABLE (ss_id int, 
						  ss_logindate datetime,
						  ss_logoutdate datetime,
						  ss_shiftstatus varchar(6),
						  ss_starttime datetime,
						  ss_date datetime,
						  trc_number varchar(8))
						 
SET @Debug = 0		-- 0=off, 1=on
SET @spAlreadyLogIN = -1
SET @spTractorChange = -1
SET @SSID = '-1'
SET @DrvOut = '-1'
SET @Flags = 0

IF @Debug > 0
	SELECT 'Input Parms' Title, @DRV DRV, @TRC Trc, @LoginDateTime LoginDateTime, @p_Flags Flags, @NumberMinutesToCheckPreviousNextDays NumberMinutesToCheckPreviousNextDays, @NumberMinutesOfPrevNextDayToCheck NumberMinutesOfPrevNextDayToCheck

--Data Validation BEGIN
IF ISNULL(@Drv,'') = ''
	SET @Drv = 'UNKNOWN'

IF ISNUMERIC(@p_Flags) > 0
	SET @Flags = CONVERT(int, @p_Flags)
		
IF (@FLAGS & 1024) = 1024	
  BEGIN
	-- Use mpp_otherid
	IF NOT EXISTS (SELECT NULL FROM manpowerprofile WHERE mpp_otherid = @DRV)
	  BEGIN
		SELECT -1 SSID, -1 LOGGEDIN, -1 TRCCHANGE, -1 DRV
		RETURN
	  END
	ELSE
	  BEGIN
		SELECT @DrvOut = mpp_id FROM manpowerprofile WHERE mpp_otherid = @DRV
		
		IF @Debug > 0
			SELECT 'mpp_id info' Title, @DrvOut DriverID, @DRV AlternateDriverID
	  END	
  END
ELSE
  BEGIN
	SET @DRVOUT = @DRV		

	IF NOT EXISTS (SELECT MPP_ID FROM manpowerprofile WHERE mpp_id = @DrvOut)
	  BEGIN
		SELECT -1 SSID, -1 LOGGEDIN, -1 TRCCHANGE, -1 DRV
		RETURN
	  END
  END

IF ISNULL(@TRC,'')=''
	SET @TRC = 'UNKNOWN'

IF @TRC <> 'UNKNOWN'
	IF NOT EXISTS (SELECT NULL FROM tractorprofile WHERE trc_number = @TRC)
	  BEGIN
		RAISERROR ('INVALID TRACTOR NUMBER: %s.', 16, 1, @TRC)
		RETURN
	  END	
  		
IF ISDATE(@LoginDateTime) = 0
  BEGIN
	RAISERROR ('INVALID LOGIN DATE: %s.', 16, 1, @LoginDateTime)
	RETURN
  END
ELSE 
	SET @dtLogDateTime = CONVERT(datetime, @LoginDateTime)

IF @Debug > 0
  BEGIN
	SELECT 'After Validation' Title, @DrvOut DRV, @TRC TRC, @LoginDATETIME LoginDateTime, @Flags Flags, 
	@NumberMinutesToCheckPreviousNextDays NumberMinutesToCheckPreviousNextDays, @NumberMinutesOfPrevNextDayToCheck NumberMinutesOfPrevNextDayToCheck
  END

--------------------------------------------------------------------------------------------------------------------------------
-- Logout shift lookup
IF ((@Flags & 2048 = 2048) OR (@Flags & 4096 = 4096))
  BEGIN
	SET @SSID = '-1'

	IF (@Flags & 2048 = 2048) 
	  BEGIN
		-- Find the latest shift for this driver that has been logged in but not logged out.	
		IF @Debug > 0
			SELECT 'Logout Lookup (flag 2048)' Title, @Flags Flag

		SELECT @SSID = CONVERT(varchar(12),ss_id)
		FROM ShiftSchedules
		WHERE mpp_id = @DrvOut
		AND ss_date = (SELECT MAX(ss_date)
					   FROM ShiftSchedules
					   WHERE mpp_id = @DrvOut
							AND ISNULL(ss_logindate,'01/01/1950 00:00') <> '01/01/1950 00:00'
							AND ss_date >= DATEADD(DAY, -7, CONVERT(varchar(20), @dtLogDateTime, 101))
							AND ss_date < DATEADD(DAY, 7, CONVERT(varchar(20), @dtLogDateTime, 101)) + ' 23:59:59'
							AND ISNULL(ss_logoutdate,'12/31/2049 00:00:00') >= '12/31/2049 00:00:00')
	  END
	ELSE
	  BEGIN
		-- Find the latest shift for this driver that has been logged (don't care if it's already been logged out).	
		IF @Debug > 0
			SELECT 'Logout Lookup (flag 4096)' Title, @Flags Flag
		
		SELECT @SSID = CONVERT(varchar(12),ss_id)
		FROM ShiftSchedules
		WHERE mpp_id = @DrvOut
		AND ss_date = (SELECT MAX(ss_date)
					   FROM ShiftSchedules
					   WHERE mpp_id = @DrvOut
							AND ISNULL(ss_logindate,'01/01/1950 00:00') <> '01/01/1950 00:00'
							AND ss_date >= DATEADD(DAY, -7, CONVERT(varchar(20), @dtLogDateTime, 101))
							AND ss_date < DATEADD(DAY, 7, CONVERT(varchar(20), @dtLogDateTime, 101)) + ' 23:59:59')
	  END

	-- PTS 73685 HMA, ZB 1/30/14
	-- if flag 2048 in use and there was a signout for the date already, issue a better worded message
	  IF ((@Flags & 2048) = 2048) AND (@SSID = -1) 
	    AND EXISTS(SELECT * FROM dbo.ShiftSchedules WHERE mpp_id=@DrvOut
		           AND ss_date = CONVERT(varchar(20), @dtLogDateTime, 101))
		BEGIN
		  RAISERROR ('DATE: %s SHIFT MAY ALREADY BE LOGGED OUT', 16, 1, @LoginDateTime)  
		  RETURN
		END
	-- otherwise issue the message you were gonna issue
	
	IF (@SSID = '-1')
	  BEGIN
		RAISERROR ('COULD NOT FIND SHIFT FOR LOGOUT ON DATE: %s.', 16, 1, @LoginDateTime)
		RETURN
	  END

	SELECT @SSID ssid, @AlreadyLoggedIn a, @TractorChange tc, @DrvOut driver
	RETURN
  END
--------------------------------------------------------------------------------------------------------------------------------

IF (@Flags & 16384 <> 0)
  BEGIN
	DECLARE @MinDate datetime, @MaxDate datetime, @DtTarget datetime

	DECLARE @AllowOff INT
	IF (@Flags & 64 <> 0)
		SET @AllowOff = 1
	ELSE
		SET @AllowOff = 0

	SET @DtTarget =@dtLogDateTime
	SET @MinDate = DATEADD(D, -7, @DtTarget)
	SET @MaxDate = DATEADD(D, 7, @DtTarget)
	IF 1=(SELECT COUNT(*) FROM shiftschedules (NOLOCK) WHERE mpp_id = @Drv AND ss_date > @MinDate AND ss_date < @MaxDate
	  AND (@AllowOff <> 0 OR ss_shiftstatus = 'ON')
	  AND ((ISNULL(ss_logindate, '19500101') >= '19500102' AND ISNULL(ss_logindate, '19500101') < @DtTarget)
	       OR (ISNULL(ss_logindate, '19500101') < '19500102' AND ss_starttime < @DtTarget))
	  AND ((ISNULL(ss_logoutdate, '20491231') < '20491231' AND ISNULL(ss_logoutdate, '20491231') > @DtTarget)
	       OR (ISNULL(ss_logoutdate, '20491231') >= '20491231' AND ss_endtime > @DtTarget)))
		SELECT TOP 1 @SSID = ss_id FROM shiftschedules (NOLOCK) WHERE mpp_id = @Drv AND ss_date > @MinDate AND ss_date < @MaxDate
		  AND (@AllowOff <> 0 OR ss_shiftstatus = 'ON')
		  AND ((ISNULL(ss_logindate, '19500101') >= '19500102' AND ISNULL(ss_logindate, '19500101') < @DtTarget)
		       OR (ISNULL(ss_logindate, '19500101') < '19500102' AND ss_starttime < @DtTarget))
		  AND ((ISNULL(ss_logoutdate, '20491231') < '20491231' AND ISNULL(ss_logoutdate, '20491231') > @DtTarget)
		       OR (ISNULL(ss_logoutdate, '20491231') >= '20491231' AND ss_endtime > @DtTarget))
		ORDER BY ss_id DESC
	ELSE IF (SELECT COUNT(*) FROM shiftschedules (NOLOCK) WHERE mpp_id = @Drv AND ss_date > @MinDate AND ss_date < @MaxDate
	  AND (@AllowOff <> 0 OR ss_shiftstatus = 'ON')
	  AND ss_logoutdate <= @DtTarget AND ss_logoutdate > DATEADD(HH, -1, @DtTarget))=1
		SELECT TOP 1 @SSID = ss_id FROM shiftschedules (NOLOCK) WHERE mpp_id = @Drv AND ss_date > @MinDate AND ss_date < @MaxDate
			AND (@AllowOff <> 0 OR ss_shiftstatus = 'ON')
			AND ss_logoutdate <= @DtTarget AND ss_logoutdate > DATEADD(HH, -1, @DtTarget)
			ORDER BY ss_id DESC
	ELSE IF (SELECT COUNT(*) FROM shiftschedules (NOLOCK) WHERE mpp_id = @Drv AND ss_date > @MinDate AND ss_date < @MaxDate
	  AND (@AllowOff <> 0 OR ss_shiftstatus = 'ON')
	  AND ss_starttime <= DATEADD(HH, 8, @DtTarget) AND ss_starttime >= DATEADD(HH, -8, @DtTarget))=1
		SELECT TOP 1 @SSID = ss_id FROM shiftschedules (NOLOCK) WHERE mpp_id = @Drv AND ss_date > @MinDate AND ss_date < @MaxDate
			AND (@AllowOff <> 0 OR ss_shiftstatus = 'ON')
			AND ss_starttime <= DATEADD(HH, 8, @DtTarget) AND ss_starttime >= DATEADD(HH, -8, @DtTarget)
			ORDER BY ss_id DESC

	IF (@Debug > 0)
		IF @SSID = -1
			SELECT 'No Shift Found for ' + @LoginDateTime  Comment
		ELSE
			SELECT 'Found shift ' + @SSID + ' for ' + @LoginDateTime Title			

	IF (@SSID > 0)
	  BEGIN
	  -- We found a shiftschedule, check if the tractor has changed.
		IF EXISTS (SELECT * FROM shiftschedules (NOLOCK) WHERE ss_id = @SSID AND ISNULL(ss_logindate, '19500101') >= '19500102')
			SET @AlreadyLoggedIn = '1'
		ELSE
			SET @AlreadyLoggedIn = '-1'
			
		IF @AlreadyLoggedIn = '1' AND (SELECT trc_number FROM @Schedules WHERE ss_id = @SSID) <> @TRC AND (SELECT trc_number FROM @Schedules WHERE ss_id = @SSID) <> 'UNKNOWN'
			SET @TractorChange = '1'
		ELSE
			SET @TractorChange = '-1'
	  END
	ELSE
		SELECT @AlreadyLoggedIn = '-1', @TractorChange = '-1'

	IF @Debug > 0
		SELECT 'Final Results' Title, @AlreadyLoggedIn AlreadyLoggedIn, @TractorChange TractorChange, @SSID SSID

	-- Return the results
	SELECT @SSID SSID, @AlreadyLoggedIn LOGGEDIN, @TractorChange TRCCHANGE,@DrvOut Driver
	RETURN
  END

-- Pull shiftschedules for yesterday, today and tomorrow, regardless of status, login time etc.
INSERT INTO @Schedules (ss_id, ss_logindate, ss_logoutdate, ss_shiftstatus, ss_starttime, ss_date, trc_number)
SELECT ss_id, ss_logindate, ss_logoutdate, ss_shiftstatus, ss_starttime, ss_date, trc_number
FROM ShiftSchedules
WHERE mpp_id = @DrvOut
	AND ss_date >= DATEADD(DAY, -1, CONVERT(varchar(20), @dtLogDateTime, 101))
	AND ss_date < DATEADD(DAY, 1, CONVERT(varchar(20), @dtLogDateTime, 101)) + ' 23:59:59'			

IF (@Debug > 0)
	SELECT '@SHIFTS TABLE' Title,* FROM @Schedules ORDER BY ss_starttime

-- Check tomorrow if necessary
IF DATEDIFF(MINUTE,@dtLogDateTime,CONVERT(VARCHAR(20),DATEADD(DAY,1,@dtLogDateTime),101)) < @NumberMinutesToCheckPreviousNextDays   -- The number of minutes until midnight of the login day
  BEGIN
	IF (@Debug > 0)
		SELECT 'Checking Tomorrow' Title
		
	--Early For Tomorrow Shift
	SET @ShiftDate = CONVERT(VARCHAR(20), DATEADD(DAY, 1, @dtLogDateTime), 101)                           

	-- Lookup the shift id for tomorrows shift
	SELECT @SSID = ISNULL(ss_id,-1) 
	FROM @Schedules
	WHERE ss_date = CONVERT(varchar(20), @ShiftDate, 101)																	-- tomorrow
		AND ISNULL(ss_logindate, '01/01/1950 00:00') = '01/01/1950 00:00'													-- not logged in yet
		AND DATEDIFF(MINUTE, CONVERT(varchar(20), @ShiftDate, 101), ss_starttime) <= @NumberMinutesOfPrevNextDayToCheck		-- Pull tomorrows shift if it starts within @NumberMinutesOfPrevNextDayToCheck after midnight
		AND ss_shiftstatus = CASE WHEN @Flags & 64 <> 0 THEN ss_shiftstatus ELSE 'ON' END									-- ss_shiftstatus = ON unless flag = 64 is set.

	IF (@SSID < 0)					  
	  BEGIN
		-- No shift starting @NumberMinutesOfPrevNextDayToCheck after midnight, that has not been logged in.  
		--  Check if the driver already logged in tomorrow
		SELECT @SSID = ISNULL(ss_id,-1) 
		FROM @Schedules
		WHERE ss_date = CONVERT(varchar(20), @ShiftDate, 101) 
			AND ISNULL(ss_logindate, '1/1/1950 00:00') > '1/1/1950 00:00' 
			AND DATEDIFF(MINUTE, CONVERT(varchar(20), @ShiftDate, 101), ss_starttime) <= @NumberMinutesOfPrevNextDayToCheck
			AND ss_shiftstatus = CASE WHEN @Flags & 64 <> 0 THEN ss_shiftstatus ELSE 'ON' END

		IF (@SSID > 0)
			SET @spAlreadyLogIN = 1
			
		IF (@Debug > 0)
			IF @SSID = -1
				SELECT 'No Shift Found for Tomorrow' Title
			ELSE
				SELECT 'Found shift ' + @SSID + ' for tomorrow' Title
	  END								
  END
ELSE
	-- Check yesterday if necessary
	IF DATEDIFF(MINUTE, CONVERT(VARCHAR(20),@dtLogDateTime,101), @dtLogDateTime) < @NumberMinutesToCheckPreviousNextDays		-- Check if we're within @NumberMinutesToCheckPreviousNextDays minutes of 00:01 this morning.
	  BEGIN	
		IF (@Debug > 0)
			SELECT 'Checking yesterday' Title

		SET @ShiftDate =CONVERT(VARCHAR(20),DATEADD(DAY,-1,@dtLogDateTime),101)		-- The date of yesterday (ex. @dtLogDateTime = 8/12/12 8:11AM, result = 8/11/2012)
          
		SELECT @SSID = ISNULL(ss_id,-1) 
		FROM @Schedules 
		WHERE ss_date = CONVERT(varchar(20), @ShiftDate, 101)																		-- yesterday
			AND ISNULL(ss_logindate, '1/1/1950 00:00') = '1/1/1950 00:00'															-- not logged in yet
			AND DATEDIFF(MINUTE, ss_starttime, CONVERT(varchar(20), @dtLogDateTime, 101)) <= @NumberMinutesOfPrevNextDayToCheck		-- Pull yesterdays shift if it starts within @NumberMinutesOfPrevNextDayToCheck before 00:01 this morning
			AND ss_shiftstatus = CASE WHEN @Flags & 64 <> 0 THEN ss_shiftstatus ELSE 'ON' END										-- ss_shiftstatus = ON unless flag = 64 is set.

		IF (@SSID < 0)
		  BEGIN
			-- No shift starting @NumberMinutesOfPrevNextDayToCheck before 00:01 this morning that has not been logged in.  
			--  Check if the driver already logged in yesterday.
			SELECT @SSID = ISNULL(ss_id,-1) 
			FROM @Schedules
			WHERE ss_date = CONVERT(varchar(20), @ShiftDate, 101) 
				AND ISNULL(ss_logindate, '1/1/1950 00:00') > '1/1/1950 00:00'															-- logged in
				AND DATEDIFF(MINUTE, ss_starttime, CONVERT(varchar(20), @dtLogDateTime, 101)) <= @NumberMinutesOfPrevNextDayToCheck
				AND ss_shiftstatus = CASE WHEN @Flags & 64 <> 0 THEN ss_shiftstatus ELSE 'ON' END

			IF (@SSID > 0)
				SET @spAlreadyLogIN = 1

			IF (@Debug > 0)
				IF @SSID = -1
					SELECT 'No Shift Found for Yesterday' Title
				ELSE
					SELECT 'Found shift ' + @SSID + ' for yesterday' Title			
		  END											
	  END

IF (@SSID < 0)
  BEGIN
	IF (@Debug > 0)
		SELECT 'Checking today' Comment		

	--Today
	SELECT @SSID = ISNULL(ss_id,-1) 
	FROM @Schedules
	WHERE ss_date = CONVERT(varchar(20), @dtLogDateTime, 101)									-- today					
		AND ISNULL(ss_logindate, '1/1/1950 00:00') = '1/1/1950 00:00'							-- Not logged in yet
		AND ss_shiftstatus = (CASE WHEN @Flags & 64 <> 0 THEN ss_shiftstatus ELSE 'ON' END)		-- ss_shiftstatus = ON unless flag = 64 is set.		
			
	IF (@SSID < 0)
	  BEGIN
		-- No shift for today that has not been logged in.  
		--  Check if the driver has a shift today that he already logged in.
		SELECT @SSID = ISNULL(ss_id,-1) 
		FROM @Schedules
		WHERE ss_date = CONVERT(varchar(20), @dtLogDateTime, 101)                               -- today
			AND ISNULL(ss_logindate, '1/1/1950 00:00') > '1/1/1950 00:00'						-- logged in
			AND ss_shiftstatus = CASE WHEN @Flags & 64 <> 0 THEN ss_shiftstatus ELSE 'ON' END	-- ss_shiftstatus = ON unless flag = 64 is set.		
				
		IF (@SSID > 0)
			SET @spAlreadyLogIN = 1			

		IF (@Debug > 0)
			IF @SSID = -1
				SELECT 'No Shift Found Today' Comment
			ELSE
				SELECT 'Found shift ' + @SSID + ' for today' Title			
	  END
  END					

IF (@SSID > 0)
  BEGIN
  -- We found a shiftschedule, check if the tractor has changed.
	IF (SELECT trc_number FROM @Schedules WHERE ss_id = @SSID) <> @TRC AND (SELECT trc_number FROM @Schedules WHERE ss_id = @SSID) <> 'UNKNOWN'
	  BEGIN
		IF (@spAlreadyLogIN > 0) 
			SET @spTractorChange = 1	
	  END
  END

SET @AlreadyLoggedIn = @spAlreadyLogIN
SET @TractorChange =  @spTractorChange
	
IF @Debug > 0
	SELECT 'Final Results' Title, @AlreadyLoggedIn AlreadyLoggedIn, @TractorChange TractorChange, @SSID SSID

-- Return the results
SELECT @SSID SSID, @AlreadyLoggedIn LOGGEDIN, @TractorChange TRCCHANGE,@DrvOut Driver
GO
GRANT EXECUTE ON  [dbo].[tmail_ShiftScheduleLookup] TO [public]
GO
