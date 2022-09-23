SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 
   09/11/02 MZ:  Created   
	11/02/09	VMS	PTS 49699 - Adding new flag
*/

CREATE PROCEDURE [dbo].[tmail_GetLoadAssignmentLeg3]
	@order varchar(12),
	@move varchar(12),
	@tractor varchar(20),
	@driver varchar(12),
	@flags varchar(22),
	@TMStatus varchar(500),
	@lgh varchar(12) OUT,
	@SearchStatuses varchar(20)
AS

/* Flags understood by this routine:
    '*** +8   = MoveOrderOverlaid (used in FILL and XMIT) -> First try order number, and then try the move number sent in (as the order number).
    '*** +64  = Use Driver Lookup (used in FILL and XMIT)
    '*** +256 = Prefer Started legs. If set, will look for STD, DSP, PLN in that order (Default behavior with neither 256/512 set is: DSP, PLN)
    '*** +512 = Allow Started legs. If set, will look for DSP, PLN, STD (Default behavior with neither 256/512 set is: DSP, PLN) 
'				Implied if an order or Move is present!
    '*** +1024 = No Planned.  If set, we will not check for legs with a lgh_outstatus of PLN
    '*** +2048 = Prefer Dispatched.
    '*** +4096 = Return matching legheader as resultset.    
    '*** +524288 = No Completed legs. Ignored if a legheader, move, or order number is provided to the Get Legheader Number view
    '*** +1048576 = Return error messages for otherwise legal queries where no match is found instead of just leaving @lgh blank.
	'*** +2097152 = { Replaced by 134217728. Flag 2097152 use was incorrectly overloaded.
	'*** +134217728 = Return all legheaders as result set

    'bLookUpByDriver truth table
    ' - means ignored
    '   legheader | Flag Set | Tractor | Driver | USE (result)
    '(1)    Yes   |   -      |    -    |   -    |   Lgh
    '(2)    No    |   No     |    Yes  |   -    |   TRC
    '(3)    No    |   No     |    No   |   Yes  |   DRV
    '(4)    No    |   No     |    No   |   No   |   Fail
    '(5)    No    |   Yes    |    -    |   Yes  |   DRV
    '(6)    No    |   Yes    |    Yes  |   No   |   TRC
    '(7)    No    |   Yes    |    No   |   No   |   Fail

    'At this point, however bLookupByDriver is set will determine how we MUST do all lookups.
    '   If that method fails, it is an error.
    '       If it was set for drivers and we have a driver, then it is an error if lookups fail for
    '           the driver.
    '       If it was set for drivers and we don't have a driver, then it is an error if lookups fail
    '           for the truck.
    '       If it was set for trucks and we have a truck, then it is an error if lookups fail for
    '           the truck.
    '       If it was set for trucks and we don't have a truck, then it is an error if lookups fail
    '           for the driver.
    'Thus we can ignore the existence of the other item.
*/

-- exec dbo.tmail_GetLoadAssignmentLeg2 '39971','','322','','8',@a OUT
/****** for testing  
DECLARE @order varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@driver varchar(12),
	@TMStatus varchar(500),
	@flags varchar(11),
	@lgh varchar(12)

SET @order = '39971'
SET @move = ''
SET @tractor = '322'
SET @driver = ''
SET	@TMStatus = ''
SET @flags = '8'
SET @lgh = ''
******************/

SET NOCOUNT ON

DECLARE @iFlags bigint, 
	@MoveOrderOverlaid bigint, 
	@LookUpByDriver int,
	@sDebugMsg varchar(255),
	@sT_1 varchar(200),
	@ReturnResultSet int,
	@DescribeNoMatchFound int,
	@Trailer varchar(20),
	@slghStatus varchar(6),
	@iReturnAllLegs int

SET @sDebugMsg = ''
SET @LookupByDriver = 0
SET @MoveOrderOverlaid = 0
SET @ReturnResultSet = 0
SET @DescribeNoMatchFound = 0
SET @iReturnAllLegs = 0

-- Convert the @Flags to an int so we can do math on it.
SELECT @iFlags = CASE WHEN ISNUMERIC(@Flags) > 0 THEN 
	CONVERT(bigint, ISNULL(@Flags,'0')) 
ELSE 0 END 

IF (@iFlags & 8) <> 0 
	SET @MoveOrderOverlaid = 1 

IF (@iFlags & 64) <> 0 
	SET @LookUpByDriver = 1 

IF (@iFlags & 4096) <> 0 
	SET @ReturnResultSet = 1 

IF (@iFlags & 1048576) <> 0 
	SET @DescribeNoMatchFound = 1 

IF (@iFlags & 134217728) <> 0			-- PTS 49699
	BEGIN

	SET @iReturnAllLegs = 1 

	IF ISNULL(object_id('#AllLegs'), 0) > 0
		DROP TABLE #AllLegs

	CREATE TABLE #AllLegs (	lgh_number bigint,
							lgh_outstatus varchar(6),
							lgh_tm_status varchar(6),
							lgh_startdate datetime)

	END

IF @LookUpByDriver = 0 AND ISNULL(@tractor, '') = '' AND ISNULL(@driver, '') <> ''
	SELECT @LookupByDriver = 1
IF @LookUpByDriver = 1 AND ISNULL(@driver, '') = '' AND ISNULL(@tractor, '') <> ''
	SELECT @LookupByDriver = 0

-- Preparse possible 0's
IF ISNUMERIC(@order)<>0
	IF CONVERT(bigint, @order) = 0 
		SELECT @order = ''
IF ISNUMERIC(@move)<>0
	IF CONVERT(bigint, @move) = 0 
		SELECT @move = ''
IF ISNUMERIC(@lgh)<>0
	IF CONVERT(bigint, @lgh) = 0 
		SELECT @lgh = ''

IF @order <> '' or @move <> ''
	BEGIN
	SELECT @iFlags = (@iFlags | 512)	-- Allow Started if a Move/Order is specified.
	SELECT @iFlags = (@iFlags & (~ 524288) )	-- Allow completed if a Move/Order is specified.
	SELECT @Flags = CONVERT(varchar(22), @iFlags)
	END

-- Validate a legheader if available.  
-- If an attempt is made to resolve by legheader (i.e. lgh > ''), the
-- procedure returns to the caller regardless of whether the legheader is valid.  
-- No more resolving is attempted.  Might want to validate
-- other info (tractor/driver) as well.
IF ISNULL(@lgh, '') > ''
  BEGIN
	IF NOT EXISTS(SELECT lgh_number 
	FROM legheader (NOLOCK) 
	WHERE lgh_number = @lgh)
		SET @sDebugMsg = '(0) Lgh not found. ' + @sDebugMsg + ' (lgh:' + ISNULL(@lgh, '') + ')'
  END
ELSE
  BEGIN
	IF (ISNULL(@order,'') = '' AND ISNULL(@move,'') = '')    -- At this point @lgh = ''.
	  BEGIN
		-- No specific information, let's look up next for the equipment.
		-- Try to find the legheader with this driver/tractor.  
		IF @LookUpByDriver = 1   
		  BEGIN
			IF (ISNULL(@driver,'') = '')
				SET @sDebugMsg = @sDebugMsg + 'Function expects driver, but driver is blank.'
			ELSE
			  BEGIN
				EXEC dbo.tmail_get_lgh_number_DRV_sp4 @order, @move, @driver, @flags, @TMStatus, @lgh OUT, @SearchStatuses			-- PTS32238

				IF (ISNULL(@lgh,'') = '') AND (@DescribeNoMatchFound <> 0)
				  -- Couldn't find leg, and MoveOrderOverlaid is not set
					SET @sDebugMsg = '(5) Lgh not found. ' + @sDebugMsg + ' (ord:' + ISNULL(@order, '') + ', 
					mov:' + ISNULL(@move,'') + ', trc:' + ISNULL(@tractor, '') + ', drv:' + ISNULL(@driver, '') + ', flags:' + ISNULL(@flags, '') + ')'
			  END
		  END
		ELSE
		  BEGIN
			-- Try to find the legheader (that is oldest based on asgn_date)
			-- with this tractor.  Search for leg in priority order of status a follows:
			--- STD, DSP, PLN.
			IF ISNULL(@tractor,'') = ''
				SET @sDebugMsg = @sDebugMsg + 'Function expects tractor, but tractor is blank.'
			ELSE
			  BEGIN
				IF (SUBSTRING(@tractor,1,4) = 'TRL:')
					BEGIN
						SET @Trailer = SUBSTRING(@tractor, 5, DATALENGTH(@tractor)-4)
						EXEC dbo.tmail_get_lgh_number_trl_sp @order, @move, @Trailer, @flags, @TMStatus, @lgh OUT, @SearchStatuses

						IF (ISNULL(@lgh,'') = '') AND (@DescribeNoMatchFound <> 0) 
							-- Couldn't find leg, and MoveOrderOverlaid is not set
							SET @sDebugMsg = '(7) Lgh not found. ' + @sDebugMsg + ' (ord:' + ISNULL(@order, '') + ', mov:' + ISNULL(@move,'') + ', TRL:' + ISNULL(@Trailer, '') + ', drv:' + ISNULL(@driver, '') + ', flags:' + ISNULL(@flags, '') + ')'
					END
				ELSE
					BEGIN
						EXEC dbo.tmail_get_lgh_number_sp4 @order, @move, @tractor, @flags, @TMStatus, @lgh OUT, @SearchStatuses

						IF (ISNULL(@lgh,'') = '') AND (@DescribeNoMatchFound <> 0) 
						-- Couldn't find leg, and MoveOrderOverlaid is not set
							SET @sDebugMsg = '(6) Lgh not found. ' + @sDebugMsg + ' (ord:' + ISNULL(@order, '') + ', mov:' + ISNULL(@move,'') + ', trc:' + ISNULL(@tractor, '') + ', drv:' + ISNULL(@driver, '') + ', flags:' + ISNULL(@flags, '') + ')'
					END
			  END
		  END
	  END  -- If @move = 0 and @order = 0
	ELSE
	  BEGIN
		-- Move and/or Order is not blank
		IF @LookUpByDriver = 1		
		  BEGIN
			IF (ISNULL(@driver,'') = '')
				SET @sDebugMsg = @sDebugMsg + 'Function expects driver, but driver is blank.'
			ELSE
			  BEGIN
				-- Driver based route
				EXEC dbo.tmail_get_lgh_number_DRV_sp4 @order, @move, @driver, @flags, @TMStatus, @lgh OUT, @SearchStatuses
	
				IF (ISNULL(@lgh,'') = '' AND @MoveOrderOverlaid = 1)
				  BEGIN
					IF @move <> ''
						BEGIN
							-- Couldn't find a matching legheader, but @move may have interfered (it may be an overlaid copy of the order id), so try searching by order only.
							EXEC dbo.tmail_get_lgh_number_DRV_sp4 @order, '', @driver, @flags, @TMStatus, @lgh OUT, @SearchStatuses
						END
					IF (ISNULL(@lgh,'') = '')
						BEGIN 
							-- Couldn't find a matching legheader even without any possible @move interference.  Last resort: See if the order field contains a move number.
							EXEC dbo.tmail_get_lgh_number_DRV_sp4 '', @order, @driver, @flags, @TMStatus, @lgh OUT, @SearchStatuses
						END

					IF (ISNULL(@lgh,'') = '') AND (@DescribeNoMatchFound <> 0)
						-- Still couldn't find info, so raise error and exit
						SET @sDebugMsg = '(1) Lgh not found. ' + @sDebugMsg + ' (ord:' + ISNULL(@order, '') + ', mov:' + ISNULL(@move,'') + ', trc:' + ISNULL(@tractor, '') + ', drv:' + ISNULL(@driver, '') + ', flags:' + ISNULL(@flags, '') + ')'
				  END
				ELSE IF (ISNULL(@lgh,'') = '') AND (@DescribeNoMatchFound <> 0) 
				  -- Couldn't find leg, and MoveOrderOverlaid is not set
					SET @sDebugMsg = '(2) Lgh not found. ' + @sDebugMsg + ' (ord:' + ISNULL(@order, '') + ', mov:' + ISNULL(@move,'') + ', trc:' + ISNULL(@tractor, '') + ', drv:' + ISNULL(@driver, '') + ', flags:' + ISNULL(@flags, '') + ')'
			  END
		  END
		ELSE
		  BEGIN
			IF (ISNULL(@tractor,'') = '')
				SET @sDebugMsg = @sDebugMsg + 'Function expects tractor, but tractor is blank.'
			ELSE
			  BEGIN
				IF (SUBSTRING(@tractor,1,4) = 'TRL:')
					BEGIN
						-- Trailer based route
						SET @Trailer = SUBSTRING(@tractor, 5, DATALENGTH(@tractor)-5)
						EXEC dbo.tmail_get_lgh_number_trl_sp @order, @move, @Trailer, @flags, @TMStatus, @lgh OUT, @SearchStatuses
					END
				ELSE
					BEGIN
						-- Tractor based route
						EXEC dbo.tmail_get_lgh_number_sp4 @order, @move, @tractor, @flags, @TMStatus, @lgh OUT, @SearchStatuses
					END
					
				IF (ISNULL(@lgh,'') = '' AND @MoveOrderOverlaid = 1)
				  BEGIN
					IF (SUBSTRING(@tractor,1,4) = 'TRL:')
						BEGIN
							SET @Trailer = SUBSTRING(@tractor, 5, DATALENGTH(@tractor)-5)
							IF @move <> ''
								BEGIN
									-- Couldn't find a matching legheader, but @move may have interfered (it may be an overlaid copy of the order id), so try searching by order only.
									EXEC dbo.tmail_get_lgh_number_trl_sp @order, '', @Trailer, @flags, @TMStatus, @lgh OUT, @SearchStatuses
								END

							IF (ISNULL(@lgh,'') = '')
								BEGIN
									-- Couldn't find a matching legheader even without any possible @move interference.  Last resort: See if the order field contains a move number.
									EXEC dbo.tmail_get_lgh_number_trl_sp '', @order, @Trailer, @flags, @TMStatus, @lgh OUT, @SearchStatuses
								END
						END
					ELSE
						BEGIN
							IF @move <> ''
								BEGIN
									-- Couldn't find a matching legheader, but @move may have interfered (it may be an overlaid copy of the order id), so try searching by order only.
									EXEC dbo.tmail_get_lgh_number_sp4 @order, '', @tractor, @flags, @TMStatus, @lgh OUT, @SearchStatuses
								END
			
							IF (ISNULL(@lgh,'') = '')
								BEGIN
									-- Couldn't find a matching legheader even without any possible @move interference.  Last resort: See if the order field contains a move number.
									EXEC dbo.tmail_get_lgh_number_sp4 '', @order, @tractor, @flags, @TMStatus, @lgh OUT, @SearchStatuses
								END
						END
							
					IF (ISNULL(@lgh,'') = '') AND (@DescribeNoMatchFound <> 0)
						-- Still couldn't find info, so raise error and exit
						SET @sDebugMsg = '(3) Lgh not found. ' + @sDebugMsg + ' (ord:' + ISNULL(@order, '') + ', mov:' + ISNULL(@move,'') + ', trc:' + ISNULL(@tractor, '') + ', drv:' + ISNULL(@driver, '') + ', flags:' + ISNULL(@flags, '') + ')'
				  END
				ELSE IF (ISNULL(@lgh,'') = '') AND (@DescribeNoMatchFound <> 0) 
				  -- Couldn't find leg, and MoveOrderOverlaid is not set
					SET @sDebugMsg = '(4) Lgh not found. ' + @sDebugMsg + ' (ord:' + ISNULL(@order, '') + ', mov:' + ISNULL(@move,'') + ', trc:' + ISNULL(@tractor, '') + ', drv:' + ISNULL(@driver, '') + ', flags:' + ISNULL(@flags, '') + ')'
			  END
		  END
	  END
  END  -- Is lgh > 0

IF @sDebugMsg <> ''
  BEGIN
	SET @lgh = ''
	RAISERROR (@sDebugMsg, 16, 1)
	RETURN
  END

IF @iReturnAllLegs <> 0
	BEGIN
		SELECT @slghStatus = lgh_outstatus 
		FROM legheader (NOLOCK)
		WHERE lgh_number = @lgh
		
		SELECT	lgh_number, 
				lgh_outstatus, 
				lgh_tm_status, 
				lgh_startdate,
				@lgh AS LegNumber,
				@slghStatus as DispatchStatus 
		FROM #AllLegs
	END
ELSE
	BEGIN
		IF @ReturnResultSet <> 0 
			BEGIN
				SELECT @slghStatus = lgh_outstatus 
				FROM legheader (NOLOCK)
				WHERE lgh_number = @lgh
				
				SELECT @lgh AS LegNumber, @slghStatus as DispatchStatus
			END
	END
GO
GRANT EXECUTE ON  [dbo].[tmail_GetLoadAssignmentLeg3] TO [public]
GO
