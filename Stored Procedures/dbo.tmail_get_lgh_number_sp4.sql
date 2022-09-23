SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_sp4]
	@order_number varchar(12),
	@move varchar(12), 
	@tractor varchar(12),
	@flags varchar(22),
	@TMStatus varchar(500),
	@lgh_num varchar(12) OUT,
	@SearchStatus varchar(20)
AS

/**************************************
* REVISION HISTORY:
* 03/13/2013.01 - PTS67490 - MIZ - Changed FuelMode flag from 268435456 to 536870912 (268435456 was already used in tmail_load_assign5_sp)
* 
***************************************/

SET NOCOUNT ON 

/* For testing */
/* DECLARE @order_number varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@flags varchar(11),
	@TMStatus(500),
	@lgh_num varchar(12)
*/

DECLARE @move_number int,
	@ordhdr int,
	@KillRTPTimeFlag varchar(20),
	@sT_1 varchar(200), 		--Translation string
	@iflags bigint,
	@AllowStarted int,
	@PreferStarted int,
	@NoPlanned int,
	@PreferDispatched int,
	@NoCompleted int,
	@SeekCmpNotDeparted int,
	@stp_departure_status varchar(6),
	@lgh_number int,
	@SQL varchar(2000),
	@iReturnAllLegs int,
	@FuelMode int,
	@FuelDriver varchar(8),
	@FuelDate datetime,
	@FuelShift int,
	@FuelStartDate datetime,
	@FuelEndDate datetime
	
	
--PTS 60624 - JC 4/9/12 - Change temp table to variable table
Declare  @tmp1 TABLE (lgh_number int,
				    	lgh_outstatus varchar(6),
						lgh_tm_status varchar(6),
				    	lgh_startdate datetime, 
				    	eff_outstatus varchar(6))

Declare @candidates TABLE (lgh int PRIMARY KEY CLUSTERED)

-- Convert the @Flags to an int so we can do math on it.
SELECT @iFlags = CASE WHEN ISNUMERIC(@flags) > 0 THEN 
	CONVERT(bigint, ISNULL(@Flags,'0')) 
ELSE 0 END 

/* An asterisk means that the flag's value doesn't matter, as other flags imply what it must mean.

Prefer Allow No   Prefer No 	Prefer
 STD    STD  PLN   DSP   CMP	CMP if not Departd
--------------------------------------------------
0 0 0 0 * *: oldest of DSP or PLN (whichever is older, NO preference for dispatched: this was the default behavior)
0 0 0 1 * *: oldest DSP, oldest PLN
0 0 1 * * *: oldest DSP
0 1 0 0 0 *: oldest of DSP or PLN, STD, latest CMP
0 1 0 0 1 *: oldest of DSP or PLN, STD
0 1 0 1 0 *: oldest DSP, oldest PLN, STD, latest CMP
0 1 0 1 1 *: oldest DSP, oldest PLN, STD
0 1 1 * 0 *: oldest DSP, STD, latest CMP
0 1 1 * 1 *: oldest DSP, STD
1 * 0 0 0 0: STD, oldest of DSP or PLN, latest CMP
1 * 0 0 1 0: STD, oldest of DSP or PLN
1 * 0 1 0 0: STD, oldest DSP, oldest PLN, latest CMP
1 * 0 1 1 0: STD, oldest DSP, oldest PLN
1 * 1 * 0 0: STD, oldest DSP, latest CMP	
1 * 1 * 1 0: STD, oldest DSP 
1 * 0 0 0 1: STD, latest CMP if not departed, oldest of DSP or PLN, latest CMP
1 * 0 0 1 1: STD, latest CMP if not departed, oldest of DSP or PLN
1 * 0 1 0 1: STD, latest CMP if not departed, oldest DSP, oldest PLN, latest CMP
1 * 0 1 1 1: STD, latest CMP if not departed, oldest DSP, oldest PLN
1 * 1 * 0 1: STD, latest CMP if not departed, oldest DSP, latest CMP	
1 * 1 * 1 1: STD, latest CMP if not departed, oldest DSP 

Use SearchStatus string takes a string with the acceptable statuses in the desired order.  The statuses are defined with the following characters:
S: (oldest) STD
C: latest CMP
D: oldest DSP
P: oldest PLN
U: oldest DSP or PLN
V: latest CMP if not departed (active)
I: latest CMP if departed (inactive)

The SearchStatus string overrides the Prefer STD, Allow STD, No PLN, Prefer DSP, No CMP, and Prefer CMP if not Departd flags.  Those flags
are ignored if SearchStatus is not blank.

Fuel Mode makes two modifications: first the last open shift will be found for the driver of
that tractor.  Only legs on that shift are eligible.  Second, when determining the status of
each of those legs, the last stop will be disregarded if it is an EBT or EMT.
*/

SET @PreferStarted = 0
SET @AllowStarted = 0
SET @NoPlanned = 0
SET @PreferDispatched = 0
SET @NoCompleted = 0
SET @SeekCmpNotDeparted = 0
SET @iReturnAllLegs = 0
SET @FuelMode = 0
SET @FuelDriver = NULL
SET @FuelDate = GETDATE()
SET @FuelShift = NULL
SET @FuelStartDate = CONVERT(DATETIME, '19500101')
SET @FuelEndDate = CONVERT(DateTime, '20491231 23:59:59')

IF (@iFlags & 256) <> 0 
	SET @PreferStarted = 1 	-- Will choose STD over DSP,PLN,CMP

IF (@iFlags & 512) <> 0 
	SET @AllowStarted = 1 	-- Will look for STD, though not first 

IF (@iFlags & 1024) <> 0 	-- Will exclude PLN from any result 
	SET @NoPlanned = 1 	

IF (@iFlags & 2048) <> 0	-- Will choose any DSP over PLN
	SET @PreferDispatched = 1	

IF (@iFlags & 524288) <> 0	-- Will exclude CMP from any result
	SET @NoCompleted = 1	

IF (@iFlags & 8388608) <> 0	
	SET @SeekCmpNotDeparted = 1	
	-- Will choose latest CMP if last stop not departed over DSP,PLN,CMP
	-- Only applies if @PreferStarted = 1.

IF (@iFlags & 134217728) <> 0	
	SET @iReturnAllLegs = 1	

IF (@iFlags & 536870912) <> 0
	SET @FuelMode = 1

-- Initialize variables
IF @order_number = '0' SET @order_number = ''
IF @move = '0' SET @move = ''

-- If no tractor is supplied, raise error and exit
IF ISNULL(@tractor, '') = ''
  BEGIN
	SET @sT_1 = 'TMWERR: {Load Assign2} No Tractor Specified.'
	RAISERROR (@sT_1,16,-1)
	RETURN 1
  END

-- PTS32238 - Check TMStatus for quotes
IF (ISNULL(@TMStatus,'') <> '') AND (ISNULL(@TMStatus,'') <> '''''')
	BEGIN
		-- if statuses are not surrounded by quotes add them cuz they are strings
		if CHARINDEX('''', @TMStatus) = 0 
		BEGIN
			SET @TMStatus = '''' + replace(@TMStatus, ',', ''',''') + ''''		-- Add quotes
			SET @TMStatus = replace(@TMStatus, ' ', '') 						-- Remove any spaces
		END
	END
ELSE
	SELECT @TMStatus = NULL

IF (@FuelMode = 1)
  BEGIN
    SELECT @FuelDate = GETDATE()
    SELECT @FuelDriver = trc_driver FROM tractorprofile (NOLOCK) WHERE trc_number = @tractor
    IF ISNULL(@FuelDriver, 'UNKNOWN') = 'UNKNOWN'
      BEGIN
	    SET @sT_1 = 'TMWERR: {Load Assign3} No Active Driver for Tractor %s.'
	    RAISERROR (@sT_1,16,-1, @tractor)
	    RETURN 1
      END
    SELECT @FuelShift = dbo.tmail_get_current_shift_for_date(@FuelDriver, @FuelDate)
    IF ISNULL(@FuelShift, 0) = 0
      BEGIN
		DECLARE @FuelDateText varchar(30)
	    SET @sT_1 = 'TMWERR: {Load Assign4} No logged in shift found for Driver %s on %s.'
		SET @FuelDateText = CONVERT(varchar(30), @FuelDate)
	    RAISERROR (@sT_1,16,-1, @FuelDriver, @FuelDateText)
	    RETURN 1
      END
    SELECT @FuelStartDate = ss_starttime, @FuelEndDate = ss_endtime FROM ShiftSchedules (NOLOCK) WHERE ss_id = @FuelShift    
    SELECT @FuelStartDate = ss_logindate FROM ShiftSchedules (NOLOCK) WHERE ss_id = @FuelShift AND ss_logindate >= '19500102' AND ss_logindate < @FuelStartDate
    SELECT @FuelEndDate = ss_logoutdate FROM ShiftSchedules (NOLOCK) WHERE ss_id = @FuelShift AND ss_logoutdate < '20491231' AND ss_logoutdate > @FuelEndDate
    SELECT TOP 1 @FuelStartDate = lgh_startdate FROM legheader (NOLOCK) where shift_ss_id = @FuelShift AND lgh_startdate < @FuelStartDate ORDER BY lgh_startdate
    SELECT TOP 1 @FuelEndDate = lgh_enddate FROM legheader (NOLOCK) where shift_ss_id = @FuelShift AND lgh_enddate > @FuelEndDate ORDER BY lgh_enddate DESC
  END
  
IF ISNULL(@move, '') > ''
  BEGIN
	-- A move number was supplied, so add all legheaders to the temp table
	INSERT @tmp1 SELECT lgh_number, lgh_outstatus, lgh_tm_status, lgh_startdate, dbo.tmail_get_eff_outstatus(lgh_number, @FuelMode)
			 	 FROM legheader (NOLOCK)
				 WHERE mov_number = CONVERT(int,@move)
				   AND lgh_tractor = @tractor
				   AND lgh_enddate > @FuelStartDate
				   AND lgh_startdate < @FuelEndDate
	SELECT @NoCompleted = 0, @AllowStarted = 1
  END
ELSE
	-- No move number, so check for order number
	IF ISNULL(@order_number, '') > ''
  	  BEGIN
		-- An order number was supplied, so get the ord_hdrnumber
		SET @ordhdr = null

		SELECT @ordhdr = ord_hdrnumber 
		FROM orderheader (NOLOCK)
		WHERE ord_number = @order_number

		IF ISNULL(@ordhdr, 0) = 0 
			RETURN 1			-- No ord_hdrnumber, so exit			

		SELECT @NoCompleted = 0, @AllowStarted = 1

		-- Insert all legs for this tractor and ord_hdrnumber into the temp table
		INSERT @tmp1 SELECT DISTINCT l.lgh_number, l.lgh_outstatus, l.lgh_tm_status, l.lgh_startdate, dbo.tmail_get_eff_outstatus(l.lgh_number, @FuelMode)
					 FROM legheader l (NOLOCK), stops s (NOLOCK)
					 WHERE l.mov_Number = s.mov_Number
					   AND s.ord_hdrnumber = @ordhdr
					   AND l.lgh_tractor = @tractor
					   AND l.lgh_enddate > @FuelStartDate
					   AND l.lgh_startdate < @FuelEndDate
	  END
	ELSE
	  BEGIN	-- No order number
		INSERT INTO @Candidates (lgh) 
			SELECT TOP 1 lgh_number 
			from Assetassignment 
			WHERE asgn_type = 'TRC' and asgn_id = @tractor and asgn_status = 'STD'
				   AND asgn_enddate > @FuelStartDate
				   AND asgn_date < @FuelEndDate
			ORDER BY asgn_date desc
		INSERT INTO @Candidates (lgh) 
			SELECT TOP 2 lgh_number 
			from Assetassignment 
			WHERE asgn_type = 'TRC' and asgn_id = @tractor and asgn_status = 'CMP'
				   AND asgn_enddate > @FuelStartDate
				   AND asgn_date < @FuelEndDate
			ORDER BY asgn_date desc

		-- Get latest or all STD (should be only 1!)
		IF (@iReturnAllLegs = 0) OR (@AllowStarted <> 0 AND @iReturnAllLegs <> 0)
			  INSERT @tmp1 
					SELECT TOP 1 lgh_number, lgh_outstatus, lgh_tm_status, lgh_startdate, 'STD' eff_Status
					FROM legheader (NOLOCK) INNER JOIN @Candidates c ON lgh_number = lgh
					WHERE lgh_tractor = @tractor AND dbo.tmail_get_eff_outstatus(lgh_number, @FuelMode)  = 'STD' and 
					  ISNULL(@TMStatus, ''''+ISNULL(lgh_tm_status, '')+'''') LIKE '%'''+ISNULL(lgh_tm_status, '')+'''%'
					   AND lgh_enddate > @FuelStartDate
					   AND lgh_startdate < @FuelEndDate
					  ORDER BY lgh_startdate desc

		-- Get earliest DSP
		INSERT @tmp1 
			  SELECT TOP 1 lgh_number, lgh_outstatus, lgh_tm_status, lgh_startdate, 'DSP' eff_Status
			  FROM legheader (NOLOCK)
			  WHERE lgh_tractor = @tractor AND lgh_outstatus = 'DSP' and 
				ISNULL(@TMStatus, ''''+ISNULL(lgh_tm_status, '')+'''') LIKE '%'''+ISNULL(lgh_tm_status, '')+'''%'
					   AND lgh_enddate > @FuelStartDate
					   AND lgh_startdate < @FuelEndDate
				ORDER BY lgh_startdate

		-- Get earliest or all PLN
		IF (@iReturnAllLegs = 0) OR (@NoPlanned = 0 AND @iReturnAllLegs <> 0)
			  INSERT @tmp1 
					SELECT TOP 1 lgh_number, lgh_outstatus, lgh_tm_status, lgh_startdate, 'PLN' eff_Status
					FROM legheader (NOLOCK)
					WHERE lgh_tractor = @tractor AND lgh_outstatus = 'PLN' and 
					  ISNULL(@TMStatus, ''''+ISNULL(lgh_tm_status, '')+'''') LIKE '%'''+ISNULL(lgh_tm_status, '')+'''%'
					   AND lgh_enddate > @FuelStartDate
					   AND lgh_startdate < @FuelEndDate
					  ORDER BY lgh_startdate

		-- Get latest or all CMP
		IF (@iReturnAllLegs = 0) OR (@NoCompleted = 0 AND @iReturnAllLegs <> 0)
			INSERT @tmp1 
				SELECT TOP 1 lgh_number, lgh_outstatus, lgh_tm_status, lgh_startdate, dbo.tmail_get_eff_outstatus(lgh_number, @FuelMode) eff_Status
				FROM legheader (NOLOCK) INNER JOIN @Candidates c ON lgh_number = lgh
				WHERE lgh_tractor = @tractor AND dbo.tmail_get_eff_outstatus(lgh_number, @FuelMode)  like 'CMP%' and 
				  ISNULL(@TMStatus, ''''+ISNULL(lgh_tm_status, '')+'''') LIKE '%'''+ISNULL(lgh_tm_status, '')+'''%'
				   AND lgh_enddate > @FuelStartDate
				   AND lgh_startdate < @FuelEndDate
				  ORDER BY lgh_startdate desc
	  END

-- PTS32238 - remove all legs from temp table that dont fit the filter
IF (ISNULL(@TMStatus,'') <> '')
	BEGIN
		SET @SQL = 'DELETE FROM @tmp1 WHERE lgh_tm_status NOT IN (' + @TMStatus + ')'
		EXEC (@SQL)
	END

SET @lgh_num = ''
SET ROWCOUNT 1

IF isnull(@SearchStatus, '') <> ''
  BEGIN
	WHILE @SearchStatus <> '' AND ISNULL(@lgh_num, '') = ''
	  BEGIN
		IF LEFT(@SearchStatus, 1) = 'S'	-- (oldest) STD
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM @tmp1
			WHERE eff_outstatus = 'STD'
			ORDER BY lgh_startdate
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'C' -- latest CMP
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM @tmp1
			WHERE eff_outstatus LIKE 'CMP%'
			ORDER BY lgh_startdate desc
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'D' -- oldest DSP
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM @tmp1
			WHERE eff_outstatus = 'DSP'
			ORDER BY lgh_startdate
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'P' -- oldest PLN
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM @tmp1
			WHERE eff_outstatus = 'PLN'
			ORDER BY lgh_startdate
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'U' -- oldest DSP or PLN
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM @tmp1
			WHERE eff_OutStatus IN ('DSP','PLN')
			ORDER BY lgh_startdate 
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'V' -- latest CMP. if not departed (active)
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM @tmp1
			WHERE eff_outstatus = 'CMP-'
			ORDER BY lgh_startdate
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'I' -- latest CMP if departed (inactive)
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM @tmp1
			WHERE eff_outstatus = 'CMP'
			ORDER BY lgh_startdate
		  END
		SELECT @SearchStatus = SUBSTRING(@SearchStatus, 2, 99)
	  END
  END
ELSE
  BEGIN
	IF (@PreferStarted = 1)
	  BEGIN
		-- Always check for the earliest STD first
		SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
		FROM @tmp1
		WHERE eff_outstatus = 'STD'
		ORDER BY lgh_startdate
	
		IF (ISNULL(@lgh_num, '') = '')
			IF @SeekCmpNotDeparted = 1
			  BEGIN
				SELECT @lgh_number = lgh_number
					FROM @tmp1
					WHERE eff_outstatus = 'CMP-'		
					ORDER BY lgh_startdate desc
			  END
		IF (ISNULL(@lgh_num, '') = '')
			-- Either pull the oldest of either DSP/PLN, 
			--	or oldest DSP, then oldest PLN
			IF (@NoPlanned = 0 AND @PreferDispatched = 0)
				-- Find oldest of DSP or PLN
				SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
				FROM @tmp1
				WHERE eff_outstatus IN ('DSP','PLN')
				ORDER BY lgh_startdate 
			ELSE
			  BEGIN
				-- Look for earliest dispatched leg
				SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
				FROM @tmp1
				WHERE eff_outstatus = 'DSP'
				ORDER BY lgh_startdate
	
				IF (ISNULL(@lgh_num, '') = '' AND @NoPlanned = 0)
					-- Look for earliest planned leg
					SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
					FROM @tmp1
					WHERE eff_outstatus = 'PLN'
					ORDER BY lgh_startdate
			  END

		-- Always check for latest CMP if all else fails in this path
		IF ISNULL(@lgh_num, '') = ''
			IF @NoCompleted = 0
				-- Look for latest completed leg
				SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
				FROM @tmp1
				WHERE eff_outstatus LIKE 'CMP%'
				ORDER BY lgh_startdate desc
	  END
	ELSE	-- @PreferStarted = 0
	  BEGIN
		IF (@NoPlanned = 0 AND @PreferDispatched = 0)
			-- Find oldest of DSP or PLN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM @tmp1
			WHERE eff_outstatus IN ('DSP','PLN')
			ORDER BY lgh_startdate 		
		ELSE
		  BEGIN
			-- Look for earliest dispatched leg
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM @tmp1
			WHERE eff_outstatus = 'DSP'
			ORDER BY lgh_startdate
	
			IF (ISNULL(@lgh_num, '') = '' AND @NoPlanned = 0)
				-- Look for earliest planned leg
				SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
				FROM @tmp1
				WHERE eff_outstatus = 'PLN'
				ORDER BY lgh_startdate
		  END

		IF (@AllowStarted = 1)
		  BEGIN
			IF (ISNULL(@lgh_num, '') = '')
				-- Look for earliest started leg
				SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
				FROM @tmp1
				WHERE eff_outstatus = 'STD'
				ORDER BY lgh_startdate

			IF (ISNULL(@lgh_num, '') = '')
				IF @NoCompleted = 0
					-- Look for latest completed leg
					SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
					FROM @tmp1
					WHERE eff_outstatus LIKE 'CMP%'	
					ORDER BY lgh_startdate desc
		  END
	  END
  END

SET ROWCOUNT 0 

IF @iReturnAllLegs <> 0
BEGIN
	INSERT INTO #AllLegs 
		SELECT	lgh_number, 
				lgh_outstatus, 
				lgh_tm_status, 
				lgh_startdate 
		FROM @tmp1

END

GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_sp4] TO [public]
GO
