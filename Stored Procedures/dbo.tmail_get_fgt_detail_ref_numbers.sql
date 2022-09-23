SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_fgt_detail_ref_numbers]
		@StopNumber varchar(20),
		@FreightNumber varchar(20),
		@RefNumType varchar(6),
		@SeqNum varchar(10)	-- Used for the fgt_sequence (freightdetail) 
					-- when using Stop#.
					-- use -999 to get ALL freightdetails
		-- if both Stop# & fgt_detail# are provided, Stop# takes precedence

AS
	
SET NOCOUNT ON 
	
	Declare @iStopNumber int, @iFgt_Detail int, @RefSeq int, @fgtseq int 

	IF ISNUMERIC(@StopNumber) = 0 SET @StopNumber = ''
	IF ISNUMERIC(@FreightNumber) = 0 SET @FreightNumber = ''
	IF ISNUMERIC(@SeqNum) = 0 SET @SeqNum = ''
	IF (ISNULL(@SeqNum,'') = '') SET @fgtseq = 1 ELSE SET @fgtseq = CONVERT(int, @SeqNum)

	IF ISNULL(@StopNumber, '') = '' 
		BEGIN
		IF ISNULL(@FreightNumber, '') = ''
			BEGIN
			RAISERROR ('No valid Stop# or FreightDetail# provided.', 16, 1)
			RETURN 1
			END
		ELSE -- use fgt_detail#
			BEGIN
			SET @iFgt_Detail = CONVERT(int, @FreightNumber)
			IF ISNULL(@RefNumType, '') = '' -- get ALL ref types for that fgt_detail
				BEGIN
				SELECT ref_type As RefNumType, ref_number AS RefNum
				FROM referencenumber (NOLOCK)
				WHERE ref_table = 'freightdetail'
				  AND ref_tablekey = @iFgt_Detail
				ORDER BY ref_sequence
				END
			ELSE -- get all of the REF TYPE for that fgt_detail
				SELECT ref_type As RefNumType, ref_number AS RefNum
				FROM referencenumber (NOLOCK)
				WHERE ref_table = 'freightdetail'
				  AND ref_tablekey = @iFgt_Detail
				  AND ref_type = @RefNumType 
				ORDER BY ref_sequence
			END
		END

	ELSE -- use Stop# -- if both Stop# & fgt_detail# are set, this is the default
		BEGIN
		SET @iStopNumber = CONVERT(int, @StopNumber)
		IF @fgtseq = -999  -- ALL frt details for that stop
			BEGIN
			IF ISNULL(@RefNumType, '') = '' -- get ALL ref types for that stops fgt_details
				BEGIN
				SELECT ref_type + ' ' + ref_number
				FROM referencenumber r (NOLOCK)
				JOIN freightdetail f (NOLOCK) on r.ref_tablekey = f.fgt_number
				WHERE ref_table = 'freightdetail'
				  AND stp_number = @iStopNumber
				ORDER BY ref_tablekey, ref_sequence
				END
			ELSE -- get all of the REF TYPE for that stops fgt_details
				SELECT ref_type As RefNumType, ref_number AS RefNum
				FROM referencenumber r (NOLOCK)
				JOIN freightdetail f (NOLOCK) on r.ref_tablekey = f.fgt_number
				WHERE ref_table = 'freightdetail'
				  AND stp_number = @iStopNumber
				  AND ref_type = @RefNumType 
				ORDER BY ref_tablekey, ref_sequence
			END
		ELSE -- just get frt detail whose sequence was specified
			IF ISNULL(@RefNumType, '') = '' -- get ALL ref types for that stops fgt_details
				BEGIN
				SELECT ref_type As RefNumType, ref_number AS RefNum
				FROM referencenumber r (NOLOCK)
				JOIN freightdetail f (NOLOCK)on r.ref_tablekey = f.fgt_number
				WHERE ref_table = 'freightdetail'
				  AND stp_number = @iStopNumber
				  AND fgt_sequence = @fgtseq
				ORDER BY ref_tablekey, ref_sequence
				END
			ELSE -- get all of the REF TYPE for that stops fgt_details
				SELECT ref_type As RefNumType, ref_number AS RefNum
				FROM referencenumber r (NOLOCK) 
				JOIN freightdetail f (NOLOCK)on r.ref_tablekey = f.fgt_number
				WHERE ref_table = 'freightdetail'
				  AND stp_number = @iStopNumber
				  AND ref_type = @RefNumType 
				  AND fgt_sequence = @fgtseq
				ORDER BY ref_tablekey, ref_sequence
			END

GO
GRANT EXECUTE ON  [dbo].[tmail_get_fgt_detail_ref_numbers] TO [public]
GO
