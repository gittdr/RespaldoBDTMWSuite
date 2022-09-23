SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetMultiFgtDetailRefNumbersAsText]
		(@StopNumber varchar(12),
		@FrtSeqNum varchar(3),		-- leave blank (or 0) to get ALL freightdetails.
		@Ref01TypeRestrict varchar(6),
		@Ref01CRLF char,		-- Y or blank
		@Ref02TypeRestrict varchar(6),
		@Ref02CRLF char,		-- Y or blank
		@Ref03TypeRestrict varchar(6),
		@Ref03CRLF char,		-- Y or blank
		@Ref04TypeRestrict varchar(6),
		@Ref04CRLF char,		-- Y or blank
		@Ref05TypeRestrict varchar(6),
		@Ref05CRLF char,		-- Y or blank
		@Ref06TypeRestrict varchar(6))

AS

SET NOCOUNT ON 

Declare	@iStopNumber int, 		@iFrtDetSeq int, 		@chrRef01CRLF varchar(2),	
	@chrRef02CRLF varchar(2), 	@chrRef03CRLF varchar(2),	@chrRef04CRLF varchar(2),
	@chrRef05CRLF varchar(2),	@sOutputLine varchar(200),	@sRefNumber varchar(20),	
	@iNumberOfFDs int,		@sFinalOutputLump varchar(8000), @iUpperLimitFDs int,
	@sCRLF varchar(2)

IF ISNUMERIC(@StopNumber) = 0 SET @StopNumber = ''
IF CONVERT(int, @StopNumber) = 0 SET @StopNumber = ''
IF ISNULL(@StopNumber, '') = '' 
  BEGIN
	-- If no stop number, just return an empty recordset.
	SELECT '' AS NumberOfFDs, '' AS OutputText
	RETURN
  END

CREATE TABLE #TempOutputLines (RowNumber int, OutputLine varchar(255))
-- one entry (outputline) will be created for each frt detail.
SET @sCRLF = CHAR(10) + CHAR(13)
SET @iStopNumber = CONVERT(int, @StopNumber)
IF ISNUMERIC(@FrtSeqNum) = 0 SET @FrtSeqNum = ''
IF CONVERT(int, @FrtSeqNum) = 0 SET @FrtSeqNum = ''
IF (ISNULL(@FrtSeqNum,'') = '') SET @iFrtDetSeq = 0 ELSE SET @iFrtDetSeq = CONVERT(int, @FrtSeqNum)
IF @iFrtDetSeq <> 0
	BEGIN
	SET @iNumberOfFDs = 1
	SET @iUpperLimitFDs = @iFrtDetSeq + 1
	END
ELSE
	BEGIN
	SELECT @iNumberOfFDs = COUNT(fgt_number) 
	FROM FreightDetail (NOLOCK)
	WHERE stp_number = @iStopNumber
	IF @iNumberOfFDs < 1 
		BEGIN
		SELECT 0, ''
		RETURN -1
		END
	ELSE
		SET @iUpperLimitFDs = @iNumberOfFDs + 1
		SET @iFrtDetSeq = 1
	END

IF ISNULL(@Ref01CRLF, '') = 'Y' SET @chrRef01CRLF = CHAR(10) + CHAR(13) ELSE SET @chrRef01CRLF = ' '
IF ISNULL(@Ref02CRLF, '') = 'Y' SET @chrRef02CRLF = CHAR(10) + CHAR(13) ELSE SET @chrRef02CRLF = ' '
IF ISNULL(@Ref03CRLF, '') = 'Y' SET @chrRef03CRLF = CHAR(10) + CHAR(13) ELSE SET @chrRef03CRLF = ' '
IF ISNULL(@Ref04CRLF, '') = 'Y' SET @chrRef04CRLF = CHAR(10) + CHAR(13) ELSE SET @chrRef04CRLF = ' '
IF ISNULL(@Ref05CRLF, '') = 'Y' SET @chrRef05CRLF = CHAR(10) + CHAR(13) ELSE SET @chrRef05CRLF = ' '

WHILE @iFrtDetSeq < @iUpperLimitFDs
	BEGIN
	SET @sOutputLine = ''
	IF ISNULL(@Ref01TypeRestrict, '') <> '' 
		BEGIN
		SET @sRefNumber = ''
		SELECT @sRefNumber = ref_number
			FROM referencenumber r (NOLOCK)
			JOIN freightdetail f (NOLOCK) on r.ref_tablekey = f.fgt_number 
			WHERE ref_table = 'freightdetail' 
			  AND stp_number = @iStopNumber 
			  AND ref_type = @Ref01TypeRestrict			
			  AND fgt_sequence = @iFrtDetSeq
		
		SET @sOutputLine = @sOutputLine + RTRIM(@Ref01TypeRestrict) 
					+ ' ' + RTRIM(@sRefNumber) + @chrRef01CRLF
		END

	IF ISNULL(@Ref02TypeRestrict, '') <> '' 
		BEGIN
		SET @sRefNumber = ''
		SELECT @sRefNumber = ref_number
		FROM referencenumber r (NOLOCK)
		JOIN freightdetail f (NOLOCK) on r.ref_tablekey = f.fgt_number
		WHERE ref_table = 'freightdetail'
		  AND stp_number = @iStopNumber
		  AND ref_type = @Ref02TypeRestrict
		  AND fgt_sequence = @iFrtDetSeq

		SET @sOutputLine = @sOutputLine + RTRIM(@Ref02TypeRestrict) 
					+ ' ' + RTRIM(@sRefNumber) + @chrRef02CRLF
		END

	IF ISNULL(@Ref03TypeRestrict, '') <> '' 
		BEGIN
		SET @sRefNumber = ''		
		SELECT @sRefNumber = ref_number
		FROM referencenumber r (NOLOCK)
		JOIN freightdetail f (NOLOCK) on r.ref_tablekey = f.fgt_number
		WHERE ref_table = 'freightdetail'
		  AND stp_number = @iStopNumber
		  AND ref_type = @Ref03TypeRestrict
		  AND fgt_sequence = @iFrtDetSeq

		SET @sOutputLine = @sOutputLine + RTRIM(@Ref03TypeRestrict) 
					+ ' ' + RTRIM(@sRefNumber) + @chrRef03CRLF
		END

	IF ISNULL(@Ref04TypeRestrict, '') <> '' 
		BEGIN
		SET @sRefNumber = ''
		SELECT @sRefNumber = ref_number
		FROM referencenumber r (NOLOCK)
		JOIN freightdetail f (NOLOCK) on r.ref_tablekey = f.fgt_number
		WHERE ref_table = 'freightdetail'
		  AND stp_number = @iStopNumber
		  AND ref_type = @Ref04TypeRestrict
		  AND fgt_sequence = @iFrtDetSeq

		SET @sOutputLine = @sOutputLine + RTRIM(@Ref04TypeRestrict) 
					+ ' ' + RTRIM(@sRefNumber) + @chrRef04CRLF
		END
	
	IF ISNULL(@Ref05TypeRestrict, '') <> '' 
		BEGIN
		SET @sRefNumber = ''
		SELECT @sRefNumber = ref_number
		FROM referencenumber r (NOLOCK)
		JOIN freightdetail f (NOLOCK) on r.ref_tablekey = f.fgt_number
		WHERE ref_table = 'freightdetail'
		  AND stp_number = @iStopNumber
		  AND ref_type = @Ref05TypeRestrict
		  AND fgt_sequence = @iFrtDetSeq

		SET @sOutputLine = @sOutputLine + RTRIM(@Ref05TypeRestrict) 
					+ ' ' + RTRIM(@sRefNumber) + @chrRef05CRLF
		END

	IF ISNULL(@Ref06TypeRestrict, '') <> '' 
		BEGIN
		SET @sRefNumber = ''
		SELECT @sRefNumber = ref_number
		FROM referencenumber r (NOLOCK) 
		JOIN freightdetail f (NOLOCK) on r.ref_tablekey = f.fgt_number
		WHERE ref_table = 'freightdetail'
		  AND stp_number = @iStopNumber
		  AND ref_type = @Ref06TypeRestrict
		  AND fgt_sequence = @iFrtDetSeq

		SET @sOutputLine = @sOutputLine + RTRIM(@Ref06TypeRestrict) 
					+ ' ' + RTRIM(@sRefNumber) + CHAR(10) + CHAR(13)
		END



	INSERT INTO #TempOutputLines (RowNumber, OutputLine)
		VALUES (@iFrtDetSeq, @sOutputLine)

	SET @iFrtDetSeq = @iFrtDetSeq + 1
	END -- end while

SET @iFrtDetSeq = 1
SET @sOutputLine = ''
SET @sFinalOutputLump = ''
WHILE @iFrtDetSeq < @iUpperLimitFDs
	BEGIN
	SELECT @sOutputLine = OutputLine 
	FROM #TempOutputLines 
	WHERE RowNumber = @iFrtDetSeq
	SET @sFinalOutputLump = @sFinalOutputLump + @sOutputLine + @sCRLF
	-- ALL OutputLines will be returned in one lump.
	SET @iFrtDetSeq = @iFrtDetSeq + 1
	END

DROP TABLE #TempOutputLines

SELECT CONVERT(varchar(3),@iNumberOfFDs) AS NumberOfFDs, @sFinalOutputLump AS OutputText

GO
GRANT EXECUTE ON  [dbo].[tmail_GetMultiFgtDetailRefNumbersAsText] TO [public]
GO
