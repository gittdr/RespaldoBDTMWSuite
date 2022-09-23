SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_ref_numbers2]
		@PSTable varchar(20),
		@PSTableKey varchar(20),
		@RefNumType varchar(6),
		@SeqNum varchar(10)			-- Used for the fgt_sequence (freightdetail), could be used for other sequence types.
AS

SET NOCOUNT ON 

	Declare @ActualTableKey int, @WorkTableKey varchar(20), @WorkTable varchar(20)
	Declare @RefSeq int, @DupKey int, @OrdHdr int, @fgtseq int 

	IF ISNULL(@PSTableKey, '') = '' 
		BEGIN
			SELECT ref_number, ref_tablekey, ref_type, ref_typedesc, ref_sequence, ord_hdrnumber, ref_table, ref_sid, ref_pickup
				FROM referencenumber (NOLOCK)
				WHERE 1=2
			RETURN 1
		END

	IF @PSTable = 'order'
		-- Order number passed in.  REF_TABLE = orderheader  (Same result if passing in 'orderheader' directly.)
		BEGIN
			SELECT @WorkTableKey = ord_hdrnumber 
			FROM orderheader (NOLOCK)
			WHERE ord_number = @PSTableKey
			
			SELECT @WorkTable = 'orderheader'
			SELECT @OrdHdr = @WorkTableKey
		END

	ELSE IF @PSTable = 'stoporder'
		-- Determines the order number by stop number passed in.  REF_TABLE = orderheader
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
		-- Determines the fgt_number by the stop number passed in.  REF_TABLE = freightdetail.
		BEGIN		
			IF ISNUMERIC(@PSTableKey) = 0
				BEGIN
					RAISERROR ('Invalid Key (%s) for stop', 16, 1, @PSTableKey)
					RETURN 1
				END

			IF (ISNULL(@SeqNum,'') = '')
				SET @SeqNum = '1'

			IF ISNUMERIC(@SeqNum) = 0
				BEGIN
					RAISERROR ('Freight number sequence is invalid (%s)', 16, 1, @SeqNum)
					RETURN 1
				END
			ELSE
				SET @fgtseq = CONVERT(int, @SeqNum)
				
			SELECT @WorkTableKey = fgt_number 
			FROM freightdetail (NOLOCK)
			WHERE stp_number = CONVERT(int, @PSTableKey) AND fgt_sequence = @fgtseq
			
			SELECT @OrdHdr = NULL   -- ******* WARNING: Don't use WHERE ord_hdrnumber = @OrdHdr anywhere.
			SELECT @WorkTable = 'freightdetail'
		END
	ELSE  -- Actual table name could be passed in for @PSTable, but then the key would have to be passed in as well.  
	      --     (i.e. @PSTableKey = 'FreightDetail' and  @PSTableKey = would be a valid fgt_number.) 
	      --     (  or @PSTableKey = 'InvoiceHeader' and  @PSTableKey = would be a valid ivh_hdrnumber.) 
		BEGIN
			IF ISNUMERIC(@PSTableKey)= 0
				BEGIN
				RAISERROR ('Invalid Key (%s) for %s', 16, 1, @PSTableKey, @PSTable)
				RETURN 1
				END

			SELECT @WorkTableKey = CONVERT(int, @PSTableKey)
			SELECT @WorkTable = @PSTable
		END

	IF ISNULL(@RefNumType, '') = '' 
		BEGIN
			SELECT ref_type As RefNumType, ref_number AS RefNum
			FROM referencenumber (NOLOCK)
			WHERE ref_table = @WorkTable 
				  AND ref_tablekey = @WorkTableKey 
			ORDER BY ref_sequence
		END
	ELSE
		BEGIN
			if LEFT(@RefNumType, 1) ='!'
				SELECT ref_type As RefNumType, ref_number AS RefNum
				FROM referencenumber (NOLOCK)
				WHERE ref_table = @WorkTable 
					  AND ref_tablekey = @WorkTableKey 
					  AND ref_type <> SUBSTRING(@RefNumType, 2, 10) 
				ORDER BY ref_sequence
			else
				SELECT ref_type As RefNumType, ref_number AS RefNum
				FROM referencenumber (NOLOCK)
				WHERE ref_table = @WorkTable 
					  AND ref_tablekey = @WorkTableKey 
					  AND ref_type = @RefNumType 
				ORDER BY ref_sequence
		END
GO
GRANT EXECUTE ON  [dbo].[tmail_get_ref_numbers2] TO [public]
GO
