SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_update_ref_number] 
	                @PSTable varchar(20),
			@PSTableKey varchar(20),
			@RefNumType varchar(6),
			@Flags varchar(20),
			@NewValue varchar(30)
AS
-- Flags is expected to be either blank or numeric.  If it is numeric, then it will
-- be interpreted as a series of bit flags as follows:

--	0:  Default behavior: 
--		If no records for that reftype, insert; 
--		otherwise update ALL records with that reftype.

--	+1: Enable repeated reftype
--		Insert new record, unless 8 is also on and there are blanks,
--		in which case, see 8 for functionality.

--	+2: Effect no more than one record
--		If multiople records would otherwise be updated, only update first.
--		No effect on inserts

--	+4: Disallow dupes (table unique) - raise error
--		If set, then verify that the given reference number/type is unique against
--		the specified table.

--	+8: Blanks are special
--		Never update non-blank values.
--		Modifies +1 to update blanks instead of inserting, if blanks exist.

-- 	+16: Don't return resultset
--		If set then suppresses the resultset echoing the parameters that is usually
--      	returned.  Useful when calling from within another stored proc.

--	+32: Disallow EDI Order updates - raise error
--		If set, disable reference number updates on orders where ord_order_source = 'EDI'. 
--		Only additional Numbers can be added.  Regardless of Reference Type. PTS 17357

--	+64: Place on top
--		If set, then move the first instance of this ref type on this order/stop to the 
--		first ref number position and shuffle all others before it down.  If none of 
--		this ref type exist on the order/stop, then insert into the first position.

-- 05/31/2006  PTS33129  CSH  new flag
-- +128: tablekey unique
--    If set, then verify that the given reference number/type is unique for
--    the specified table and tablekey.
--    Useful with flag 1 to do insert if not there, nothing if already there.

SET NOCOUNT ON 

Declare @ActualTableKey int, @WorkTableKey varchar(20), @WorkTable varchar(20)
Declare @RefSeq int, @WorkFlags int, @DupKey int, @OrdHdr int
Declare @NoEDIRefUpdate int, @Insert int	-- SR 17357
DECLARE @SN int, @tmp int, @Action int, @RecurseFlags varchar(20)
-- @Action values: 
-- 	1 = Insert
--  2 = Update ALL, 3 = Update 1st, 4 = Update all blanks,
--	5 = Update first blank

-- PTS# 35658
SELECT @PSTable=LOWER(@PSTable)
-- PTS# 35658 

CREATE TABLE #WorkTableKeys (SN int IDENTITY, KeyValue int)

IF ISNUMERIC(@Flags) <> 0
	SELECT @WorkFlags = CONVERT(int, @Flags)
ELSE
	SELECT @WorkFlags = 0

IF ISNULL(@NewValue, '') = ''
	BEGIN
		IF (@WorkFlags & 16) = 0 SELECT @PSTable PSTable, @PSTableKey PSTableKey, @RefNumType RefNumType, @Flags Flags, @NewValue Value
		RETURN
	END

IF @PSTable = 'order'
	BEGIN
		SELECT @WorkTableKey = ord_hdrnumber 
		FROM orderheader (NOLOCK)
		WHERE ord_number = @PSTableKey
		
		SELECT @WorkTable = 'orderheader'
		SELECT @OrdHdr = @WorkTableKey
	END
ELSE IF @PSTable = 'stoporder'
	BEGIN
		IF ISNUMERIC(@PSTableKey) = 0
			BEGIN
			RAISERROR ('Invalid Key (%s) for stop', 16, 1, @PSTableKey)
			RETURN 1
			END

		SELECT @WorkTableKey = ord_hdrnumber 
		FROM stops (NOLOCK)
		WHERE stp_number = CONVERT(int, @PSTableKey)
		
		SELECT @OrdHdr = @WorkTableKey
		SELECT @WorkTable = 'orderheader'
	END
ELSE IF @PSTable = 'stopfreight'   -- First freightdetail for the specified stop.
	BEGIN
		IF ISNUMERIC(@PSTableKey) = 0
			BEGIN
			RAISERROR ('Invalid Key (%s) for stop', 16, 1, @PSTableKey)
			RETURN 1
			END

		SELECT @WorkTableKey = fgt_number 
		FROM freightdetail (NOLOCK)
		WHERE stp_number = CONVERT(int, @PSTableKey) AND fgt_sequence = 1
		
		SELECT @OrdHdr = ord_hdrnumber 
		FROM stops (NOLOCK)
		where stp_number = CONVERT(int, @PSTableKey)
		SELECT @WorkTable = 'freightdetail'
	END
ELSE IF @PSTable = 'stoporders'	     -- Apply ref number to all consolidated orders for this stop.
	BEGIN
		IF ISNUMERIC(@PSTableKey) = 0
			BEGIN
			RAISERROR ('Invalid Key (%s) for stop', 16, 1, @PSTableKey)
			RETURN 1
			END

		SELECT @WorkTable = 'orderheader'			

		-- Get all orders on this move
		INSERT INTO #WorkTableKeys (KeyValue) 
		SELECT ord_hdrnumber 
		FROM orderheader (NOLOCK)
		WHERE mov_number = (SELECT mov_number 
							FROM stops (NOLOCK)
							WHERE stp_number = CONVERT(int, @PSTableKey))

		-- Loop through all orders 
		-- We won't recurse the first one, but let it run through the rest of the code, so put the values in variables
		SELECT @SN = ISNULL(MIN(SN),0) FROM #WorkTableKeys	-- Get the first record
		SELECT @WorkTableKey = KeyValue 
		FROM #WorkTableKeys
		WHERE SN = @SN

        -- PTS 37598 HMA 
		--SELECT @RecurseFlags = CONVERT(varchar(20), (@WorkFlags | 16))
        SELECT @RecurseFlags = CONVERT(varchar(20), @WorkFlags)
        -- end pts 37598
        
		-- Get the second record 
		SELECT @SN = ISNULL(MIN(SN),0) FROM #WorkTableKeys WHERE SN > @SN	
		WHILE @SN > 0
		  BEGIN
			SELECT @tmp = KeyValue 
			FROM #WorkTableKeys
			WHERE SN = @SN

			EXEC dbo.tmail_update_ref_number 'orderheader', @tmp, @RefNumType, @RecurseFlags, @NewValue
			
			SELECT @SN = ISNULL(MIN(SN),0) FROM #WorkTableKeys WHERE SN > @SN
		  END
		RETURN 1
	END
ELSE  -- Actual table name could be passed in for @PSTable, but then the key would have to be passed in as well.  
      --     (i.e. @PSTable = 'FreightDetail' and  @PSTableKey = would be a valid fgt_number.) 
	BEGIN
		IF ISNUMERIC(@PSTableKey)= 0
			BEGIN
			RAISERROR ('Invalid Key (%s) for %s', 16, 1, @PSTableKey, @PSTable)
			RETURN 1
			END

		SELECT @WorkTableKey = CONVERT(int, @PSTableKey)
		SELECT @WorkTable = @PSTable
		SELECT @OrdHdr = NULL
	END

IF (@OrdHdr IS NULL) 
	BEGIN
	IF @WorkTable = 'orderheader'
		SELECT @OrdHdr = @WorkTableKey
	IF @WorkTable = 'stops'
		SELECT @OrdHdr = ord_hdrnumber 
		FROM stops (NOLOCK)
		where stp_number = @WorkTableKey
	IF @WorkTable = 'freightdetail'
		SELECT @OrdHdr = ord_hdrnumber 
		FROM stops (NOLOCK)
		INNER JOIN freightdetail (NOLOCK) ON stops.stp_number = freightdetail.stp_number 
		where fgt_number = @WorkTableKey
	END
	
-- SR 17357
SELECT @NoEDIRefUpdate = 0								
IF ((@WorkFlags & 32) <> 0)
	BEGIN
	IF @WorkTable = 'orderheader'
		IF (SELECT ord_order_source 
			from OrderHeader (NOLOCK)
			WHERE ord_hdrnumber = @WorkTableKey) = 'EDI'
			SELECT @NoEDIRefUpdate = 1

	IF @WorkTable = 'stops'
		IF (SELECT ord_order_source 
			from orderheader (NOLOCK)
			inner join stops (NOLOCK) on orderheader.ord_hdrnumber = stops.ord_hdrnumber
			WHERE stops.stp_number = @WorkTableKey) = 'EDI'
			SELECT @NoEDIRefUpdate = 1

	IF @WorkTable = 'freightdetail'
		IF (SELECT ord_order_source 
			from orderheader (NOLOCK) 
			inner join stops (NOLOCK) on orderheader.ord_hdrnumber = stops.ord_hdrnumber 
			inner join freightdetail (NOLOCK) on freightdetail.stp_number = stops.stp_number
			WHERE freightdetail.fgt_number = @WorkTableKey) = 'EDI'
			SELECT @NoEDIRefUpdate = 1
	END  -- setup NoEDIRefUpdate for flag 32
-- SR 17357

-- 06/02/2006  CSH  PTS 33129  flag 128 check if reference already exists for specified tablekey
IF (@WorkFlags & 128) <> 0
  IF (SELECT COUNT(*) 
		FROM referencenumber (NOLOCK)
        WHERE ref_number = @NewValue
          AND ref_type = @RefNumType
          AND ref_table = @WorkTable
          AND ref_tablekey = @WorkTableKey) > 0
    BEGIN
      IF (@WorkFlags & 16) = 0
	      -- Suppress returning the resultset echoing the input parameters
	      SELECT @PSTable PSTable, @PSTableKey PSTableKey, @RefNumType RefNumType, @Flags Flags, @NewValue Value
      
      RETURN 0  -- we don't want to do anything if it already exists
    END

IF (@WorkFlags & 4) <> 0
	-- Want to verify that the reference number/type is unique against the specified table.
	BEGIN
		SELECT @DupKey = 0
		IF (@WorkFlags & 1) <> 0
			-- Always add the value as a new reference number regardless of 
			--  whether another value for this reference type already exists.
			SELECT @DupKey = MIN(ref_tablekey) 
			FROM referencenumber (NOLOCK) 
			WHERE ref_table = @WorkTable AND 
				ref_type = @RefNumType AND
				ref_number = @NewValue	-- Doesn't care which Key it's assigned to
		ELSE
			SELECT @DupKey = MIN(ref_tablekey) 
			FROM referencenumber (NOLOCK)
			WHERE
				ref_table = @WorkTable AND 
				ref_tablekey <> @WorkTableKey AND 
				ref_type = @RefNumType AND
				ref_number = @NewValue

		IF @DupKey <> 0
			BEGIN
				RAISERROR ('Duplicate %s reference number %s found on %s %d', 16, 1, @RefNumType, @NewValue, @WorkTable, @DupKey)
				RETURN 1
			END
		SELECT @WorkFlags = @WorkFlags | 2
	END  -- verify unique for flag 4

SELECT @RefSeq = 0
SELECT @RefSeq = ISNULL(MIN(ref_sequence),0) 
FROM referencenumber (NOLOCK)
WHERE		ref_table = @WorkTable AND 
			ref_tablekey = @WorkTableKey AND 
			ref_type = @RefNumType

IF @RefSeq = 0
	-- no matches found, set to Insert mode
	SET @Action = 1
ELSE
	-- at least one match found
	BEGIN
	IF (@WorkFlags & 8) <> 0
		-- flag 8 is set, don't update existing unless blank
		BEGIN
		SELECT @RefSeq = ISNULL(MIN(ref_sequence),0) 
		FROM referencenumber (NOLOCK) 
		WHERE		ref_table = @WorkTable AND 
					ref_tablekey = @WorkTableKey AND 
					ref_type = @RefNumType AND
					ISNULL(ref_number,'') = ''			
	
		IF (@RefSeq > 0) OR ((@WorkFlags & 1) = 0)
			SET @Action = 4 -- Update ALL blank
		ELSE
			SET @Action = 1 -- Insert
		END
	ELSE
		BEGIN
		-- flag 8 is not set
		IF (@WorkFlags & 1) <> 0
			-- flag 1 is set
			SET @Action = 1 -- Insert
		ELSE
			-- flag 1 is not set
			SET @Action = 2 -- Update ALL
		END

	IF @Action > 1
		-- Update
		IF (@WorkFlags & 2) <> 0
			-- flag 2 is set
			SET @Action = @Action + 1 -- Update first or Update first blank

	END  -- at least one match found

IF @Action = 1
	-- Insert mode
	BEGIN
	IF (@WorkFlags & 64) <> 0   -- Make this ref number the first one
	   BEGIN
		IF EXISTS (SELECT * 
					FROM referencenumber (NOLOCK) 
					WHERE ref_table = @WorkTable AND 
					ref_tablekey = @WorkTableKey AND ref_sequence = 1)
			-- Shuffle any existing ref numbers up 1.
			UPDATE referencenumber
			SET ref_sequence = ref_sequence + 1
			WHERE ref_table = @WorkTable 
				AND ref_tablekey = @WorkTableKey
		
		SET @RefSeq = 1	-- We know this is going to be the first ref number
	   END -- use seq 1 for flag 64
	ELSE -- default, get next ref seq # for insert
	   SELECT @RefSeq = ISNULL(MAX(ref_sequence), 0) + 1 
	   FROM referencenumber (NOLOCK)
	   WHERE ref_table = @WorkTable AND 
			 ref_tablekey = @WorkTableKey

	INSERT INTO referencenumber 
		(ref_tablekey,	--1
		ref_type, 	--2
		ref_number, 	--3
		ref_typedesc, 	--4
		ref_sequence, 	--5
		ord_hdrnumber, 	--6
		ref_table, 	--7
		ref_sid, 	--8
		ref_pickup)	--9
	VALUES
		(@WorkTableKey,	--1
		@RefNumType,	--2
		@NewValue,	--3
		NULL,		--4
		@RefSeq,	--5
		@OrdHdr, 	--6
		@WorkTable,	--7
		NULL,		--8
		NULL)		--9
	END
ELSE
	-- Update mode
	BEGIN

	IF @NoEDIRefUpdate = 1	-- SR 17357
	   BEGIN
		RAISERROR ('No update allowed to EDI reference %s: %s', 16, 1, @RefNumType, @NewValue)
		RETURN 1
	   END

	BEGIN TRAN
	IF (@WorkFlags & 64) <> 0  -- Shuffle this ref number to be in the first position.
	   BEGIN
		-- Temporarily move ref number to seq -1
		UPDATE referencenumber SET ref_sequence = -1 WHERE 
			ref_table = @WorkTable AND 
			ref_tablekey = @WorkTableKey AND 
			ref_sequence = @RefSeq

		-- Move the correct ones up 1
		UPDATE referencenumber SET ref_sequence = ref_sequence + 1 WHERE 
			ref_table = @WorkTable AND 
			ref_tablekey = @WorkTableKey AND 
			ref_sequence >0 and ref_sequence < @RefSeq

		-- Put our target ref number into position 1
		UPDATE referencenumber SET ref_sequence = 1 WHERE 
			ref_table = @WorkTable AND 
			ref_tablekey = @WorkTableKey AND 
			ref_sequence = -1

		SET @RefSeq = 1	  -- We know this is going to be the first ref number
	   END -- make this ref seq 1 for flag 64

	IF @Action = 2  
		-- Update ALL
		UPDATE referencenumber SET ref_number = @NewValue WHERE
			ref_table = @WorkTable AND 
			ref_tablekey = @WorkTableKey AND 
			ref_type = @RefNumType

	IF @Action = 3
		-- Update first
		UPDATE referencenumber SET ref_number = @NewValue WHERE
			ref_table = @WorkTable AND 
			ref_tablekey = @WorkTableKey AND 
			ref_type = @RefNumType AND
			ref_sequence = @RefSeq

	IF @Action = 4
		-- Update all blank
		UPDATE referencenumber SET ref_number = @NewValue WHERE
			ref_table = @WorkTable AND 
			ref_tablekey = @WorkTableKey AND 
			ref_type = @RefNumType AND
			ISNULL(ref_number,'') = ''

	IF @Action = 5
		-- Update first blank
		UPDATE referencenumber SET ref_number = @NewValue WHERE
			ref_table = @WorkTable AND 
			ref_tablekey = @WorkTableKey AND 
			ref_type = @RefNumType AND 
			ref_sequence = @RefSeq AND 
			ISNULL(ref_number, '') = ''

	COMMIT TRAN
	END  -- Update mode

IF @RefSeq = 1
	-- update header record to reflect changed value of ref seq 1
	IF @WorkTable = 'orderheader'
		UPDATE orderheader 
			SET ord_refnum = ref_number, ord_reftype = ref_type 
			FROM orderheader INNER JOIN referencenumber 
				ON orderheader.ord_hdrnumber = referencenumber.ref_tablekey 
				AND referencenumber.ref_table = 'orderheader' 
			WHERE orderheader.ord_hdrnumber = @WorkTableKey 
				AND referencenumber.ref_sequence = 1
	ELSE IF @WorkTable = 'stops'
		UPDATE stops 
			SET stp_refnum = ref_number, stp_reftype = ref_type 
			FROM stops INNER JOIN referencenumber 
				ON stops.stp_number = referencenumber.ref_tablekey 
				AND referencenumber.ref_table = 'stops' 
			WHERE stops.stp_number = @WorkTableKey 
				AND referencenumber.ref_sequence = 1
	ELSE IF @WorkTable = 'freightdetail'
		UPDATE freightdetail 
			SET fgt_refnum = ref_number, fgt_reftype = ref_type 
			FROM freightdetail INNER JOIN referencenumber 
				ON freightdetail.fgt_number = referencenumber.ref_tablekey 
				AND referencenumber.ref_table = 'freightdetail' 
			WHERE freightdetail.fgt_number = @WorkTableKey  
				AND referencenumber.ref_sequence = 1
	ELSE IF @WorkTable = 'invoiceheader'
		UPDATE invoiceheader 
			SET ivh_ref_number = ref_number, ivh_reftype = ref_type 
			FROM invoiceheader INNER JOIN referencenumber 
				ON invoiceheader.ivh_hdrnumber = referencenumber.ref_tablekey 
				AND referencenumber.ref_table = 'invoiceheader' 
			WHERE invoiceheader.ivh_hdrnumber = @WorkTableKey 
				AND referencenumber.ref_sequence = 1

-- Return input parms unless flag 16 is set
IF (@WorkFlags & 16) = 0
	-- Suppress returning the resultset echoing the input parameters
	SELECT @PSTable PSTable, @PSTableKey PSTableKey, @RefNumType RefNumType, @Flags Flags, @NewValue Value
GO
GRANT EXECUTE ON  [dbo].[tmail_update_ref_number] TO [public]
GO
