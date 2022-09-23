SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Clean_Image] @sImage varchar(8000)

AS
DECLARE @TextLen int
DECLARE @sPageDivider varchar(50),@lPossibleBreak int, @lPossibleBreakEnd int, @lLastPossibleBreak int, @lTrueBreak int
DECLARE @sFullPattern varchar(30), @sEndPattern varchar(30)

--Clean page breaks off, since page breaks differ in length we need to do this dynamicly
SELECT @sFullPattern = '%'+CHAR(13)+CHAR(10)+'-%-'+CHAR(13)+CHAR(10)+'%'
SELECT @sEndPattern = '%-'+CHAR(13)+CHAR(10)+'%'
--SELECT @sFullPattern FullPat
--SELECT @sEndPattern EndPat
SELECT @TextLen = DATALENGTH(@sImage)
SELECT @lLastPossibleBreak = 0
WHILE 1=1
	BEGIN
	SELECT @lPossibleBreak = PATINDEX(@sFullPattern, SUBSTRING(@sImage, @lLastPossibleBreak + 1, @TextLen))
--	SELECT 'Break?:' + CONVERT(Varchar(20),@lPossibleBreak)
	IF @lPossibleBreak = 0 
		BREAK
	SELECT @lPossibleBreakEnd = PATINDEX(@sEndPattern,SUBSTRING(@sImage,@lLastPossibleBreak+@lPossibleBreak,@TextLen))
--	SELECT 'BreakEnd?:' + CONVERT(VARCHAR(20), @lPossibleBreakEnd)
	IF @lPossibleBreakEnd = 0
		BEGIN
		RAISERROR ('Huh!!!!!  Should never happen',15,0)
		RETURN
		END
	IF @lPossibleBreakEnd > 3	-- Should be at least 2 dashes (End is the last dash, so 3 would be CR and LF before it and nothing else).
		BEGIN
		SELECT @sPageDivider = CHAR(13) +CHAR(10) + REPLICATE('-',@lPossibleBreakEnd - 2) +CHAR(13)+CHAR(10)
--		SELECT 'TestDivider:' + @sPageDivider + '<'
		SELECT @lTrueBreak = PATINDEX('%' + @sPageDivider +'%',SUBSTRING(@sImage,@lLastPossibleBreak+1,@TextLen))
--		SELECT 'TrueBreak:' + CONVERT(VARCHAR(20), @lTrueBreak)
		IF @lTrueBreak = @lPossibleBreak
			BEGIN
			SELECT @sImage = LEFT(@sImage, @lLastPossibleBreak+@lTrueBreak+1) + SUBSTRING(@sImage,@lLastPossibleBreak+@lTrueBreak+DATALENGTH(@sPageDivider),@TextLen)
			-- Now restart next search from this same spot just in case there were two in a row.
			SELECT @lPossibleBreak = 0
			END
		END
--	SELECT @sImage ImageAtLoop
	SELECT @lLastPossibleBreak = @lLastPossibleBreak + @lPossibleBreak
	END
SELECT @sFullPattern = '%'+CHAR(13)+CHAR(10)+' % '+CHAR(13)+CHAR(10)+'%'
SELECT @sEndPattern = '% '+CHAR(13)+CHAR(10)+'%'
--SELECT @sFullPattern FullPat
--SELECT @sEndPattern EndPat
SELECT @TextLen = DATALENGTH(@sImage)
SELECT @lLastPossibleBreak = 0
WHILE 1=1
	BEGIN
	SELECT @lPossibleBreak = PATINDEX(@sFullPattern, SUBSTRING(@sImage, @lLastPossibleBreak + 1, @TextLen))
--	SELECT 'Break?:' + CONVERT(Varchar(20),@lPossibleBreak)
	IF @lPossibleBreak = 0 
		BREAK
	SELECT @lPossibleBreakEnd = PATINDEX(@sEndPattern,SUBSTRING(@sImage,@lLastPossibleBreak+@lPossibleBreak,@TextLen))
--	SELECT 'BreakEnd?:' + CONVERT(VARCHAR(20), @lPossibleBreakEnd)
	IF @lPossibleBreakEnd = 0
		BEGIN
		RAISERROR ('Huh!!!!!  Should never happen',15,0)
		RETURN
		END
	IF @lPossibleBreakEnd > 3	-- Should be at least 2 dashes (End is the last dash, so 3 would be CR and LF before it and nothing else).
		BEGIN
		SELECT @sPageDivider = CHAR(13) +CHAR(10) + REPLICATE(' ',@lPossibleBreakEnd - 2) +CHAR(13)+CHAR(10)
--		SELECT 'TestDivider:' + @sPageDivider + '<'
		SELECT @lTrueBreak = PATINDEX('%' + @sPageDivider +'%',SUBSTRING(@sImage,@lLastPossibleBreak+1,@TextLen))
--		SELECT 'TrueBreak:' + CONVERT(VARCHAR(20), @lTrueBreak)
		IF @lTrueBreak = @lPossibleBreak
			BEGIN
			SELECT @sImage = LEFT(@sImage, @lLastPossibleBreak+@lTrueBreak+1) + SUBSTRING(@sImage,@lLastPossibleBreak+@lTrueBreak+DATALENGTH(@sPageDivider),@TextLen)
			-- Now restart next search from this same spot just in case there were two in a row.
			SELECT @lPossibleBreak = 0
			END
		END
--	SELECT @sImage ImageAtLoop
	SELECT @lLastPossibleBreak = @lLastPossibleBreak + @lPossibleBreak
	END


--remove blank lines and begin and end blank lines
WHILE CHARINDEX(char(13) + char(10) + char(13) + char(10) , @sImage) > 0
	SELECT @sImage = REPLACE (@sImage, char(13) + char(10) + char(13) + char(10), char(13) + char(10))
WHILE LEFT(@sImage,2) = CHAR(13)+CHAR(10)
	SELECT @sImage = SUBSTRING(@sImage, 3, @TextLen)
WHILE RIGHT(@sImage,2) = CHAR(13)+CHAR(10)
	SELECT @sImage = LEFT(@sImage, LEN(@sImage)-2)
WHILE CHARINDEX(char(32) + char(13) + char(10) , @sImage) > 0
	SELECT @sImage = REPLACE (@sImage, char(32) + char(13) + char(10), char(13) + char(10))

SELECT @sImage

GO
GRANT EXECUTE ON  [dbo].[tm_Clean_Image] TO [public]
GO
