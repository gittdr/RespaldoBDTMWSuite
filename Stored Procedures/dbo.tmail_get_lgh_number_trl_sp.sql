SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tmail_get_lgh_number_trl_sp]
	@order_number varchar(12),
	@move varchar(12),
	@trailer varchar(13),
	@flags varchar(11),
	@TMStatus varchar(500),
	@lgh_num varchar(12) OUT,
	@SearchStatus varchar(20)
AS


/* For testing */
/* DECLARE @order_number varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@flags varchar(11),
	@TMStatus(500),
	@lgh_num varchar(12)
*/
SET NOCOUNT ON 

DECLARE @move_number int,
	@ordhdr int,
	@KillRTPTimeFlag varchar(20),
	@sT_1 varchar(200), 		--Translation string
	@iflags int,
	@AllowStarted int,
	@PreferStarted int,
	@NoPlanned int,
	@PreferDispatched int,
	@NoCompleted int,
	@SeekCmpNotDeparted int,
	@stp_departure_status varchar(6),
	@lgh_number int,
	@SQL varchar(2000),
	@iReturnAllLegs int

CREATE TABLE #tmp1 (lgh_number int,
				    	lgh_outstatus varchar(6),
						lgh_tm_status varchar(6),
				    	lgh_startdate datetime)

-- Convert the @Flags to an int so we can do math on it.
SELECT @iFlags = CASE WHEN ISNUMERIC(@flags) > 0 THEN 
	CONVERT(int, ISNULL(@Flags,'0')) 
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
*/

SET @PreferStarted = 0
SET @AllowStarted = 0
SET @NoPlanned = 0
SET @PreferDispatched = 0
SET @NoCompleted = 0
SET @SeekCmpNotDeparted = 0
SET @iReturnAllLegs = 0

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

-- Initialize variables
IF @order_number = '0' SET @order_number = ''
IF @move = '0' SET @move = ''

-- If no trailer is supplied, raise error and exit
IF ISNULL(@trailer, '') = ''
  BEGIN
	SET @sT_1 = 'TMWERR: {Load Assign2} No Trailer Specified.'
	RAISERROR (@sT_1,16,-1)
	RETURN 1
  END

-- PTS32238 - Check TMStatus for quotes
IF (ISNULL(@TMStatus,'') <> '')
	BEGIN
		-- if statuses are not surrounded by quotes add them cuz they are strings
		if CHARINDEX('''', @TMStatus) = 0 
		BEGIN
			SET @TMStatus = '''' + replace(@TMStatus, ',', ''',''') + ''''		-- Add quotes
			SET @TMStatus = replace(@TMStatus, ' ', '') 						-- Remove any spaces
		END
	END

IF ISNULL(@move, '') > ''
  BEGIN
	-- A move number was supplied, so add all legheaders to the temp table
	INSERT #tmp1 SELECT lgh_number, lgh_outstatus, lgh_tm_status, lgh_startdate
			 	 FROM legheader (NOLOCK)
				 WHERE mov_number = CONVERT(int,@move)
				   AND lgh_primary_trailer = @trailer
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
		INSERT #tmp1 SELECT DISTINCT l.lgh_number, l.lgh_outstatus, l.lgh_tm_status, l.lgh_startdate
					 FROM legheader l (NOLOCK) , stops s (NOLOCK)
					 WHERE l.mov_Number = s.mov_Number
					   AND s.ord_hdrnumber = @ordhdr
					   AND l.lgh_primary_trailer = @trailer
	  END
	ELSE
	  BEGIN	-- No order number
		-- Get earliest or all STD
		IF (@iReturnAllLegs = 0) OR (@AllowStarted <> 0 AND @iReturnAllLegs <> 0)
			INSERT INTO #tmp1 EXECUTE dbo.tmail_get_lgh_number_sp_Help4_trl @Trailer, 'STD', @TMStatus, @Flags

		-- Get earliest DSP
		INSERT INTO #tmp1 EXECUTE dbo.tmail_get_lgh_number_sp_Help4_trl @Trailer, 'DSP', @TMStatus, @Flags

		-- Get earliest or all PLN
		IF (@iReturnAllLegs = 0) OR (@NoPlanned = 0 AND @iReturnAllLegs <> 0)
			INSERT INTO #tmp1 EXECUTE dbo.tmail_get_lgh_number_sp_Help4_trl @Trailer, 'PLN', @TMStatus, @Flags

		-- Get latest or all CMP
		IF (@iReturnAllLegs = 0) OR (@NoCompleted = 0 AND @iReturnAllLegs <> 0)
			INSERT INTO #tmp1 EXECUTE dbo.tmail_get_lgh_number_sp_Help4_trl @Trailer, 'CMP', @TMStatus, @Flags
	  END

-- PTS32238 - remove all legs from temp table that dont fit the filter
IF (ISNULL(@TMStatus,'') <> '')
	BEGIN
		SET @SQL = 'DELETE FROM #tmp1 WHERE lgh_tm_status NOT IN (' + @TMStatus + ')'
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
			FROM #tmp1
			WHERE lgh_outstatus = 'STD'
			ORDER BY lgh_startdate
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'C' -- latest CMP
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM #tmp1
			WHERE lgh_outstatus = 'CMP'
			ORDER BY lgh_startdate desc
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'D' -- oldest DSP
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM #tmp1
			WHERE lgh_outstatus = 'DSP'
			ORDER BY lgh_startdate
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'P' -- oldest PLN
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM #tmp1
			WHERE lgh_outstatus = 'PLN'
			ORDER BY lgh_startdate
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'U' -- oldest DSP or PLN
		  BEGIN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM #tmp1
			WHERE lgh_OutStatus IN ('DSP','PLN')
			ORDER BY lgh_startdate 
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'V' -- latest CMP. if not departed (active)
		  BEGIN
			SELECT @lgh_number = 0
			SELECT @lgh_number = lgh_number
				FROM #tmp1
				WHERE lgh_outstatus = 'CMP'		
				ORDER BY lgh_startdate desc

			IF ISNULL(@lgh_number, 0) <> 0
			  BEGIN
				SELECT @stp_departure_status = stp_departure_status 
					FROM stops (NOLOCK)
					WHERE lgh_number = @lgh_number AND stp_mfh_Sequence =
						(SELECT MAX(stp_mfh_Sequence) 
							from stops (NOLOCK)
							WHERE lgh_number = @lgh_number)
				IF ISNULL(@stp_departure_status,'') = 'OPN'
					SET @lgh_num = CONVERT(varchar(12),@lgh_number)
			  END
		  END
		ELSE IF LEFT(@SearchStatus, 1) = 'I' -- latest CMP if departed (inactive)
		  BEGIN
			SELECT @lgh_number = 0
			SELECT @lgh_number = lgh_number
				FROM #tmp1
				WHERE lgh_outstatus = 'CMP'	
				ORDER BY lgh_startdate desc

			IF ISNULL(@lgh_number, 0) <> 0
			  BEGIN
				SELECT @stp_departure_status = stp_departure_status FROM stops (NOLOCK)
					WHERE lgh_number = @lgh_number AND stp_mfh_Sequence =
						(SELECT MAX(stp_mfh_Sequence) from stops (NOLOCK) WHERE lgh_number = @lgh_number)
				IF ISNULL(@stp_departure_status,'') <> 'OPN'
					SET @lgh_num = CONVERT(varchar(12),@lgh_number)
			  END
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
		FROM #tmp1
		WHERE lgh_outstatus = 'STD'
		ORDER BY lgh_startdate
	
		IF (ISNULL(@lgh_num, '') = '')
			IF @SeekCmpNotDeparted = 1
			  BEGIN
				SELECT @lgh_number = lgh_number
					FROM #tmp1
					WHERE lgh_outstatus = 'CMP'		
					ORDER BY lgh_startdate desc

				IF ISNULL(@lgh_number, 0) <> 0
				  BEGIN
					SELECT @stp_departure_status = stp_departure_status 
					FROM stops (NOLOCK)
					WHERE lgh_number = @lgh_number AND stp_mfh_Sequence =
							(SELECT MAX(stp_mfh_Sequence) 
							from stops (NOLOCK)
							WHERE lgh_number = @lgh_number)
					IF ISNULL(@stp_departure_status,'') = 'OPN'
						SET @lgh_num = CONVERT(varchar(12),@lgh_number)
				  END
			  END
		IF (ISNULL(@lgh_num, '') = '')
			-- Either pull the oldest of either DSP/PLN, 
			--	or oldest DSP, then oldest PLN
			IF (@NoPlanned = 0 AND @PreferDispatched = 0)
				-- Find oldest of DSP or PLN
				SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
				FROM #tmp1
				WHERE lgh_outstatus IN ('DSP','PLN')
				ORDER BY lgh_startdate 
			ELSE
			  BEGIN
				-- Look for earliest dispatched leg
				SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
				FROM #tmp1
				WHERE lgh_outstatus = 'DSP'
				ORDER BY lgh_startdate
	
				IF (ISNULL(@lgh_num, '') = '' AND @NoPlanned = 0)
					-- Look for earliest planned leg
					SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
					FROM #tmp1
					WHERE lgh_outstatus = 'PLN'
					ORDER BY lgh_startdate
			  END

		-- Always check for latest CMP if all else fails in this path
		IF ISNULL(@lgh_num, '') = ''
			IF @NoCompleted = 0
				-- Look for latest completed leg
				SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
				FROM #tmp1
				WHERE lgh_outstatus = 'CMP'
				ORDER BY lgh_startdate desc
	  END
	ELSE	-- @PreferStarted = 0
	  BEGIN
		IF (@NoPlanned = 0 AND @PreferDispatched = 0)
			-- Find oldest of DSP or PLN
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM #tmp1
			WHERE lgh_outstatus IN ('DSP','PLN')
			ORDER BY lgh_startdate 		
		ELSE
		  BEGIN
			-- Look for earliest dispatched leg
			SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
			FROM #tmp1
			WHERE lgh_outstatus = 'DSP'
			ORDER BY lgh_startdate
	
			IF (ISNULL(@lgh_num, '') = '' AND @NoPlanned = 0)
				-- Look for earliest planned leg
				SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
				FROM #tmp1
				WHERE lgh_outstatus = 'PLN'
				ORDER BY lgh_startdate
		  END

		IF (@AllowStarted = 1)
		  BEGIN
			IF (ISNULL(@lgh_num, '') = '')
				-- Look for earliest started leg
				SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
				FROM #tmp1
				WHERE lgh_outstatus = 'STD'
				ORDER BY lgh_startdate

			IF (ISNULL(@lgh_num, '') = '')
				IF @NoCompleted = 0
					-- Look for latest completed leg
					SELECT @lgh_num = CONVERT(varchar(12),lgh_number)
					FROM #tmp1
					WHERE lgh_outstatus = 'CMP'	
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
		FROM #tmp1

END

GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_trl_sp] TO [public]
GO
