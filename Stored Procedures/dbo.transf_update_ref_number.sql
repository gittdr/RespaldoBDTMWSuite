SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_update_ref_number]	
                    @PSTable varchar(20),
					@PSTableKey varchar(20),
					@RefNumType varchar(6),
					@Flags varchar(5),
					@NewValue varchar(20)
AS
	-- Flags is expected to be either blank or numeric.  If it is numeric, then it will
	-- be interpreted as a series of bit flags as follows:
	--	+1: If set, then always add the value as a new reference number regardless of
	-- 		whether another value for this reference type already exists.
	--	+2: If set, then reset only the 1st instance of the specified reference type
	--		instead of all instances.  (If none exists, one will be added).
	--		Ignored if +1 also present.
	--	+4: If set, then verify that the given reference number/type is unique against
	--		the specified table.
	--	+8: If set, then will only overwrite if the current value is blank or missing.
	--		Ignored if +1 also present.  If +2 is also present, then only the
	--		1st blank instance will be reset.  If there are no blanks, then 
	--		another will be added.
    	-- 	+16: If set then suppresses the resultset echoing the parameters that is usually
	--      	returned.  Useful when calling from within another stored proc.
	--	+32: If set, disable reference number updates on orders where ord_order_source = 'EDI'. 
	--		Only additional Numbers can be added.  Regardless of Reference Type. PTS 17357
	--	+64: If set, then move the first instance of this ref type on this order/stop to the 
	--		first ref number position and shuffle all others before it down.  If none of 
	--		this ref type exist on the order/stop, then insert into the first position.
set nocount on

	Declare @ActualTableKey int, @WorkTableKey varchar(20), @WorkTable varchar(20)
	Declare @RefSeq int, @WorkFlags int, @DupKey int, @OrdHdr int
	Declare @NoEDIRefUpdate int, @Insert int	-- SR 17357
	
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
			SELECT @WorkTableKey = ord_hdrnumber FROM orderheader WHERE ord_number = @PSTableKey
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

			SELECT @WorkTableKey = ord_hdrnumber FROM stops WHERE stp_number = CONVERT(int, @PSTableKey)
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

			SELECT @WorkTableKey = fgt_number FROM freightdetail WHERE stp_number = CONVERT(int, @PSTableKey) AND fgt_sequence = 1
			SELECT @OrdHdr = NULL   -- ******* WARNING: Don't use WHERE ord_hdrnumber = @OrdHdr anywhere.
			SELECT @WorkTable = 'freightdetail'
		END
	ELSE  -- Actual table name could be passed in for @PSTable, but then the key would have to be passed in as well.  
	      --     (i.e. @PSTableKey = 'FreightDetail' and  @PSTableKey = would be a valid fgt_number.) 
		BEGIN
			IF ISNUMERIC(@PSTableKey)= 0
				BEGIN
				RAISERROR ('Invalid Key (%s) for %s', 16, 1, @PSTableKey, @PSTable)
				RETURN 1
				END

			SELECT @WorkTableKey = CONVERT(int, @PSTableKey)
			SELECT @WorkTable = @PSTable
		END

	-- SR 17357
	SELECT @NoEDIRefUpdate = 0								
	IF ((@WorkFlags & 32) <> 0)
		BEGIN
		IF @WorkTable = 'orderheader'
			IF (SELECT ord_order_source from OrderHeader
				WHERE ord_hdrnumber = @WorkTableKey) = 'EDI'
				SELECT @NoEDIRefUpdate = 1

		IF @WorkTable = 'stops'
			IF (SELECT ord_order_source from orderheader
				inner join stops on orderheader.ord_hdrnumber = stops.ord_hdrnumber
				WHERE stops.stp_number = @WorkTableKey) = 'EDI'
				SELECT @NoEDIRefUpdate = 1

		IF @WorkTable = 'freightdetail'
			IF (SELECT ord_order_source from orderheader 
				inner join stops on orderheader.ord_hdrnumber = stops.ord_hdrnumber 
				inner join freightdetail on freightdetail.stp_number = stops.stp_number
				WHERE freightdetail.fgt_number = @WorkTableKey) = 'EDI'
				SELECT @NoEDIRefUpdate = 1
		END
	-- SR 17357

	IF (@WorkFlags & 4) <> 0
		-- Want to verify that the reference number/type is unique against the specified table.
		BEGIN
			SELECT @DupKey = 0
			IF (@WorkFlags & 1) <> 0
				-- Always add the value as a new reference number regardless of 
				--  whether another value for this reference type already exists.
				SELECT @DupKey = MIN(ref_tablekey) FROM referencenumber WHERE
					ref_table = @WorkTable AND 
					ref_type = @RefNumType AND
					ref_number = @NewValue	-- Doesn't care which Key it's assigned to
			ELSE
				SELECT @DupKey = MIN(ref_tablekey) FROM referencenumber WHERE
					ref_table = @WorkTable AND 
					ref_tablekey <> @WorkTableKey AND 
					ref_type = @RefNumType AND
					ref_number = @NewValue
	
			IF @DupKey <> 0
				BEGIN
					RAISERROR ('Duplicate %s reference number %s found on %s %d', 16, 1, @RefNumType, @NewValue, @WorkTable, @DupKey)
					RETURN 1
				END
		END
		
	SELECT @RefSeq = 0
	IF (@WorkFlags & 1) = 0
		-- 1 is not set, so see if there is already one to update, if not, we'll add one.
		IF (@WorkFlags & 8) <> 0
			-- It is only eligible for update if it is blank.
			SELECT @RefSeq = ISNULL(MIN(ref_sequence),0) FROM referencenumber WHERE 
				ref_table = @WorkTable AND 
				ref_tablekey = @WorkTableKey AND 
				ref_type = @RefNumType AND
				ISNULL(ref_number, '') = ''
		ELSE
			SELECT @RefSeq = ISNULL(MIN(ref_sequence),0) FROM referencenumber WHERE 
				ref_table = @WorkTable AND 
				ref_tablekey = @WorkTableKey AND 
				ref_type = @RefNumType

	IF @RefSeq > 0 
	  BEGIN
		SET @Insert = 0	-- SR 17357
		IF @NoEDIRefUpdate = 0	-- SR 17357
		  BEGIN
			IF (@WorkFlags & 2) <> 0  
				-- Reset the first ref number of this type, whether it's blank or not
				UPDATE referencenumber SET ref_number = @NewValue WHERE
					ref_table = @WorkTable AND 
					ref_tablekey = @WorkTableKey AND 
					ref_type = @RefNumType AND
					ref_sequence = @RefSeq
			ELSE
				-- Reset all instances, not just the first.
				IF @WorkFlags & 8 <> 0
					-- Reset only blank ref numbers of this type
					UPDATE referencenumber SET ref_number = @NewValue WHERE
						ref_table = @WorkTable AND 
						ref_tablekey = @WorkTableKey AND 
						ref_type = @RefNumType AND
						ISNULL(ref_number, '') = ''
				ELSE
					-- Reset all ref numbers of this type
					UPDATE referencenumber SET ref_number = @NewValue WHERE
						ref_table = @WorkTable AND 
						ref_tablekey = @WorkTableKey AND 
						ref_type = @RefNumType

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
				SET @Insert = 1   -- Changing first position ref number, so update the base table
			  END
		  END
		ELSE 	-- @NoEDIRefUpdate = 1	-- SR 17357
		  BEGIN
			RAISERROR ('No update allowed to EDI reference %s: %s', 16, 1, @RefNumType, @NewValue)
			RETURN 1
		  END
	  END
	ELSE
	  BEGIN
		-- Either this is the first ref number on this order/stop, or the +1 flag was also set
		SET @Insert = 1	-- SR 17357

		IF (@WorkFlags & 64) <> 0   -- Make this ref number the first one
		  BEGIN
			IF EXISTS (SELECT * FROM referencenumber WHERE ref_table = @WorkTable AND ref_tablekey = @WorkTableKey AND ref_sequence = 1)
				-- Shuffle any existing ref numbers up 1.
				UPDATE referencenumber
				SET ref_sequence = ref_sequence + 1
				WHERE ref_table = @WorkTable 
					AND ref_tablekey = @WorkTableKey
			
			SET @RefSeq = 1	-- We know this is going to be the first ref number
		  END
		ELSE
			SELECT @RefSeq = ISNULL(MAX(ref_sequence), 0) + 1 FROM referencenumber WHERE 
				ref_table = @WorkTable AND 
				ref_tablekey = @WorkTableKey


		-- Now we can insert the new ref number
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

	IF @RefSeq = 1
		IF ((@NoEDIRefUpdate = 0) or (@Insert = 1))	-- SR 17357
		  BEGIN
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
		  END

	-- Suppress returning the resultset echoing the input parameters
	IF (@WorkFlags & 16) = 0 SELECT @PSTable PSTable, @PSTableKey PSTableKey, @RefNumType RefNumType, @Flags Flags, @NewValue Value

set nocount off
GO
GRANT EXECUTE ON  [dbo].[transf_update_ref_number] TO [public]
GO
