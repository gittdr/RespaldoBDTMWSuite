SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[tm_get_message_image] @pMsgSN varchar(10), @pStartLine varchar(10), @pEndLine varchar(10)
AS

SET NOCOUNT ON

DECLARE @CR varchar(3), @LF varchar(3), @CRLF varchar(4), @CRX int, @LFX int, @CRLFX int
DECLARE @MsgSN int, @StartLine int, @EndLine int, @CountLine int
DECLARE @LineChars int, @TotalChars int, @FullLen int
DECLARE @TextPtr varbinary(16)

create table #Work (SN int, MsgImage text)
create table #Work2 (SN int, MsgImage text)

SELECT @CR = CHAR(13), @LF = CHAR(10), @CRLF = CHAR(13)+CHAR(10)  -- Prepare 'constants'
SELECT @CR = '%'+@CR+'%',  @LF = '%'+@LF+'%',  @CRLF = '%'+@CRLF+'%'  -- Make appropriate for PATINDEX.

-- Parse Parameters
SELECT @MsgSN = CONVERT(int, @pMsgSN)
SELECT @StartLine = 0
SELECT @EndLine = 0
IF ISNUMERIC(@pStartLine)<>0 SELECT @StartLine = CONVERT(int, @pStartLine)
IF ISNUMERIC(@pEndLine) <> 0 SELECT @EndLine = CONVERT(int, @pEndLine)
IF @EndLine >= @StartLine SELECT @CountLine = @EndLine - @StartLine + 1
IF @EndLine = 0 SELECT @CountLine = 0

-- Get Basic Image
insert into #Work (SN, MsgImage)
(SELECT @MsgSN, MsgImage 
FROM tblmsgsharedata (NOLOCK)
inner join tblmessages (NOLOCK) on tblmsgsharedata.origmsgsn = tblmessages.origmsgsn 
WHERE tblmessages.sn = @MsgSN)

IF (SELECT count(*) FROM #Work) = 1
	BEGIN
	WHILE @StartLine > 1
		BEGIN
		SELECT @CRX=PATINDEX(@CR, MsgImage), @LFX=PATINDEX(@LF, MsgImage), @CRLFX = PATINDEX(@CRLF, MsgImage) FROM #Work
		IF @CRX = 0 AND @LFX = 0
			BEGIN
			UPDATE #Work SET MsgImage = ''
			BREAK
			END
		ELSE IF @CRX = 0
			SELECT @LineChars = @LFX
		ELSE IF @LFX = 0 OR @CRX < @LFX
			BEGIN
			IF @CRX = @CRLFX
				SELECT @LineChars = @CRLFX + 1
			ELSE
				SELECT @LineChars = @CRX
			END
		ELSE
			SELECT @LineChars = @LFX
		
		SELECT @TextPtr = TEXTPTR(msgimage)
		FROM #Work
		UPDATETEXT #Work.MsgImage @TextPtr 0 @LineChars ''

		SELECT @StartLine = @StartLine - 1
		END
	INSERT INTO #Work2(SN, MsgImage)
	SELECT SN, MsgImage FROM #Work
	IF @CountLine > 0
		BEGIN
		SELECT @TotalChars = 0
		WHILE @CountLine > 0
			BEGIN
			SELECT @CRX=PATINDEX(@CR, MsgImage), @LFX=PATINDEX(@LF, MsgImage), @CRLFX = PATINDEX(@CRLF, MsgImage) FROM #Work
			IF @CRX = 0 AND @LFX = 0
				BEGIN
				SELECT @TotalChars = DATALENGTH(MsgImage) FROM #Work2
				BREAK
				END
			ELSE IF @CRX = 0
				SELECT @LineChars = @LFX
			ELSE IF @LFX = 0 OR @CRX < @LFX
				BEGIN
				IF @CRX = @CRLFX
					SELECT @LineChars = @CRLFX + 1
				ELSE
					SELECT @LineChars = @CRX
				END
			ELSE
				SELECT @LineChars = @LFX
			
			SELECT @TotalChars = @TotalChars + @LineChars
			SELECT @TextPtr = TEXTPTR(msgimage)
			FROM #Work
			UPDATETEXT #Work.MsgImage @TextPtr 0 @LineChars ''
	
			SELECT @CountLine = @CountLine - 1
			END
		SELECT @FullLen = DATALENGTH(MsgImage) FROM #Work2
		IF @FullLen > @TotalChars
			BEGIN
			SELECT @FullLen = @FullLen - @TotalChars
			SELECT @TextPtr = TEXTPTR(msgimage)
			FROM #Work2
			UPDATETEXT #Work2.MsgImage @TextPtr @TotalChars @FullLen ''
			END
		END
	END
SELECT SN, MsgImage, DATALENGTH(MsgImage) ImageLen FROM #Work2

GO
GRANT EXECUTE ON  [dbo].[tm_get_message_image] TO [public]
GO
