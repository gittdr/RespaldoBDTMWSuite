SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[transf_parseListToTable](@sData varchar(8000), @sDelim Char(1)) 
RETURNS @tList TABLE (value Sql_Variant)
AS
BEGIN
	DECLARE @sTemp Varchar(1000)
		,@nPos Int
		,@nPos2 Int

	IF Len(RTrim(LTrim(@sData))) = 0
		RETURN

	SET @nPos = CharIndex(@sDelim, @sData, 1)

	IF @nPos = 0
	BEGIN
		SET @sTemp = SubString(@sData, 1, Len(@sData))
		INSERT INTO @tList VALUES(ltrim(rtrim(@sTemp)))
		RETURN
	END

	IF @nPos = Len(@sData)
	BEGIN
		SET @sTemp = SubString(@sData, 1, Len(@sData) - 1)
		INSERT INTO @tList VALUES(ltrim(rtrim(@sTemp)))
		RETURN
	END

	SET @sTemp = SubString(@sData, 1, @nPos - 1)
		INSERT INTO @tList VALUES(ltrim(rtrim(@sTemp)))

	WHILE @nPos > 0
	BEGIN
		SET @nPos2 = CharIndex(@sDelim, @sData, @nPos + 1)
		IF @nPos2 = 0 
		SET @sTemp = SubString(@sData, @nPos + 1, Len(@sData))
		ELSE
		SET @sTemp = SubString(@sData, @nPos + 1, ABS(@nPos2 - @nPos - 1)) 

		INSERT INTO @tList VALUES(ltrim(rtrim(@sTemp)))

		SET @nPos = CharIndex(@sDelim, @sData, @nPos + 1)
	END
	RETURN
END
GO
