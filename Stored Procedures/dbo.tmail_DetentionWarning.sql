SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[tmail_DetentionWarning] @sstp_number varchar(20),
											@cmp_id varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
											@ord_number varchar(20)

AS

/**************************************************************************
* 01/19/04 MZ: Created
* Returns Detention information for a stop.
* 
***************************************************************************/

SET NOCOUNT ON 

DECLARE @mov_number int,
		@ord_hdrnumber int,
		@stp_number int,
		@DetMinsNow float,
		@DetMinsMax float,
		@To varchar(1000),
		@tmpdate datetime,
		@SysTZ int,
		@SysTZMins int,
		@MakeTZAdjusts char(1),
		@SysDSTCode int,
		@DestTZ int,
		@DestTZMins int,
		@DestDSTFlag char(1),
		@DestDSTCode int

SET @MakeTZAdjusts = 'N'
SET @SysTZ = -15
SET @SysTZMins = 0
SET @SysDSTCode = 0
SET @DestTZ = -15
SET @DestTZMins = 0

SET @DetMinsNow = 0
SET @DetMinsMax = 0
SET @To = ''

IF ISNUMERIC(@sstp_number) <> 0
	SET @stp_number = CONVERT(int, @sstp_number)
ELSE
	SET @stp_number = 0

IF @stp_number = 0
  BEGIN		-- No stop number, so determine stop from order number & company id
	SET @cmp_id = RTRIM(LTRIM(@cmp_id))
	SET @ord_number = RTRIM(LTRIM(@ord_number))

	IF (@cmp_id = '' OR @ord_number = '')
	  BEGIN
		RAISERROR ('Insufficient data to retrieve detention information. Company ID: (%s), Order Number: (%s), Stop Number (%s).', 16, 1, @cmp_id, @ord_number, @sstp_number)
		RETURN 1	
	  END

	-- Get the orderheader number
	SELECT @ord_hdrnumber = ISNULL(MIN(ord_hdrnumber),0)
	FROM orderheader (NOLOCK)  
	WHERE ord_number = @ord_number

	IF ((SELECT count(*)  -- If there is only 1 stop on the given ord_number for this company id, use it
			FROM stops (NOLOCK)
			WHERE stops.cmp_id = @cmp_id
			AND ord_hdrnumber = @ord_hdrnumber
			AND ord_hdrnumber <> 0) = 1)
	  BEGIN
		SELECT @stp_number = ISNULL(stp_number,0)
		FROM stops (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND ord_hdrnumber = @ord_hdrnumber			
			AND ord_hdrnumber <> 0
	  END
	ELSE IF ((SELECT count(*)	-- See if there is only 1 stop for this cmp_id on the Min(ord_number) for this move.
 			  FROM stops (NOLOCK)
			  WHERE cmp_id = @cmp_id
				AND mov_number = (SELECT ISNULL(MIN(mov_number),0)
							  	  FROM orderheader	
								  WHERE ord_number = @ord_number)) = 1)
	  BEGIN
		-- Only one stop on this move with that company id, so get the stop number
		SELECT @stp_number = ISNULL(stp_number,0)
		FROM stops (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND mov_number = (SELECT ISNULL(MIN(mov_number),0)
								FROM orderheader	
								WHERE ord_number = @ord_number)
	  END

	IF @stp_number = 0
	  BEGIN
		RAISERROR ('Unable to detemine stop to gather detention info on. Stop Number: (%s), Company ID: (%s), Order Number: (%s)',16,1,@sstp_number,@cmp_id,@ord_number)
		RETURN 1	
	  END
  END
ELSE
  BEGIN
	-- We were given a stop number, validate.
	IF NOT EXISTS (SELECT stp_number 
					FROM stops (NOLOCK)
					WHERE stp_number = @stp_number)
	  BEGIN
		RAISERROR ('Invalid stop number (%s) supplied.',16,1,@sstp_number)
		RETURN 1	
	  END

	-- Only return the ord_hdrnumber if the user supplied the stp_number.
	SELECT @ord_hdrnumber = ord_hdrnumber
	FROM stops (NOLOCK)
	WHERE stp_number = @stp_number

	-- Only return the ord_number if the user supplied the stp_number.
	SELECT @ord_number = ord_number
	FROM orderheader (NOLOCK)
	WHERE ord_hdrnumber = @ord_hdrnumber
  END

IF ISNULL(@cmp_id, '') = ''
	SELECT @cmp_id = ISNULL(cmp_id, '')
	FROM stops (NOLOCK)
	WHERE stp_number = @stp_number

-- Multi-timezone handling
-- Check if we should use multi-timezone processing
SELECT @MakeTZAdjusts = UPPER(ISNULL(gi_string1, 'N'))
FROM generalinfo 
WHERE gi_name = 'MakeTZAdjustments'

IF @MakeTZAdjusts = 'Y'
  BEGIN
	SELECT @SysTZ =	ISNULL(CONVERT(int, gi_string1), -15)
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'SysTZ'

	SELECT @SysTZMins = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to no additional minutes
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'SysTZMins'

	SELECT @SysDSTCode = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to no DST
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'SysDSTCode'
  END

-- Do we have enough valid info to do multi-timezone processing?
IF @MakeTZAdjusts = 'Y' AND (@SysTZ < -12 OR @SysTZ > 8)
	SET @MakeTZAdjusts = 'N'	

-- PTS36099 : Dinesh Patel on 08/03/2007
-- If stp_alloweddet is set for the stop, return that value.  Otherwise, return
-- cmp_PUPTimeAllowance in case of PickUp ELSE return cmp_DRPTimeAllowance  from the company table.
SELECT  @tmpdate = stops.stp_arrivaldate,
		@cmp_id = stops.cmp_id,
		@DetMinsMax = case stp_type
			when 'PUP' then
			ISNULL(
				ISNULL(
					stops.stp_alloweddet, 
					ISNULL(
						(SELECT MIN(cmp_PUPTimeAllowance) 
							FROM company  (NOLOCK)
							INNER JOIN orderheader (NOLOCK) ON orderheader.ord_billto = company.cmp_id 
							WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
						(SELECT cmp_PUPTimeAllowance 
							FROM company (NOLOCK)
							WHERE company.cmp_id = stops.cmp_id)
						)
					),
				0
				)
			ELSE
				ISNULL(
				ISNULL(
					stops.stp_alloweddet, 
					ISNULL(
						(SELECT MIN(cmp_DRPTimeAllowance) 
							FROM company (NOLOCK)
							INNER JOIN orderheader (NOLOCK) ON orderheader.ord_billto = company.cmp_id 
							WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
						(SELECT cmp_DRPTimeAllowance 
							FROM company (NOLOCK)
							WHERE company.cmp_id = stops.cmp_id)
						)
					),
				0
				)

			end,
-- Get the To email information
		@To = 
			ISNULL(
				ISNULL(
					(SELECT MIN(cmp_detcontacts) 
						FROM company (NOLOCK)
						INNER JOIN orderheader (NOLOCK) ON orderheader.ord_billto = company.cmp_id 
						WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
					(SELECT cmp_detcontacts 
						FROM company (NOLOCK)
						WHERE company.cmp_id = stops.cmp_id)
					),
				''
				)
FROM stops(NOLOCK)
WHERE stp_number = @stp_number

-- End PTS36099

IF (@MakeTZAdjusts = 'Y')
  BEGIN
	-- Get the timezone info for this city
	SELECT  @DestTZ = ISNULL(city.cty_GMTDelta, -15),
			@DestDSTFlag = ISNULL(city.cty_DSTApplies, 'N'),
			@DestTZMins = ISNULL(city.cty_TZMins, 0)
	FROM city (NOLOCK), company (NOLOCK)
	WHERE company.cmp_id = @cmp_id
		AND company.cmp_city = city.cty_code

	-- TODD - How do we handle this?
	IF @DestDSTFlag = 'Y'
		SET @DestDSTCode = 0
	ELSE 
		SET @DestDSTCode = -1

	-- Check if we have enough info for this company to use multi-timezone processing
	IF (@DestTZ > -13 AND @DestTZ < 9)
		SELECT @tmpdate = dbo.ChangeTZ (@tmpdate, @DestTZ, @DestDSTCode, @DestTZMins, @SysTZ, @SysDSTCode, @SysTZMins)
  END

-- Add the number of allowable detention minutes to the datetime	
SET @DetMinsNow = DATEDIFF(mi, @tmpdate, GETDATE())	

-- Now return the data
SELECT  @To "To", 
		@DetMinsNow DetMinsNow, 
		@DetMinsMax DetMinsMax, 
		@ord_hdrnumber OrderHdrNumber,
		@cmp_id CompanyId,
		@ord_number OrderNumber,
		@stp_number StopNumber
GO
