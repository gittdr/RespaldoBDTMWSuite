SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricParseList] 
(
	@sList varchar(1000), 
	@Delimiter varchar(10) = ','
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @i int, @j int
	CREATE TABLE #List (sn int identity, ListValue varchar(100))

	SELECT @sList = @Delimiter + @sList + @Delimiter
	IF @sList = @Delimiter + @Delimiter
	BEGIN
		SELECT ListValue FROM #List
		RETURN
	END

	SELECT @j = 0, @i = CHARINDEX(@Delimiter, @sList)
	WHILE @i > 0
	BEGIN
		--SELECT SUBSTRING(@sList, @j+1, @i-@i+1)
		INSERT INTO #List (ListValue) SELECT SUBSTRING(@sList, @j+1, @i-@j-1)
		SELECT @j = @i
		SELECT @i = CHARINDEX(@Delimiter, @sList, @i+1)
	END
	INSERT INTO #List (ListValue) SELECT SUBSTRING(@sList, @j+1, @j-@i-1)
	SELECT LTRIM(RTRIM(ListValue)) FROM #List WHERE ListValue <> '' ORDER BY sn
GO
GRANT EXECUTE ON  [dbo].[MetricParseList] TO [public]
GO
