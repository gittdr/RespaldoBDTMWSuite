SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Takes a passed in string @String and at every @FixedSize, inserts @DelimiterToAdd
	Set @SurroundResultWithDelimiter to Y to return in form of @DelimiterToAdd + Result + @DelimiterToAdd
	ie: ,AL,MI,NY,
 */

CREATE FUNCTION [dbo].[fn_StringToDelimitedString] (@String varchar(8000), @FixedSize int, @DelimiterToAdd varchar(10), @SurroundResultWithDelimiter varchar(1)) 
RETURNS varchar(8000)
AS
	BEGIN
			DECLARE @Return 	varchar(8000)
			DECLARE @CharPtr	int
			DECLARE @Delimiter	varchar(10)
			DECLARE @StringLen	int
		
			IF isnull(@FixedSize, 0) < 1 BEGIN
				RETURN @String
			END
			SET @Return = ''
			SET @CharPtr = 1
			IF @SurroundResultWithDelimiter = 'Y' BEGIN
				SET @Delimiter = @DelimiterToAdd
			END
			ELSE BEGIN
				SET @Delimiter = ''
			END
			SET @StringLen = len(@String)
			
			WHILE (@CharPtr <= @StringLen) BEGIN
				SET @Return = @Return + @Delimiter + SUBSTRING(@String, @CharPtr, @FixedSize) 
				SET @Delimiter = @DelimiterToAdd
				SET @CharPtr = @CharPtr + @FixedSize
	        END
			IF @SurroundResultWithDelimiter = 'Y' and len(@Return) > 0 BEGIN
				SET @Return = @Return + @Delimiter
			END

			RETURN @Return
	END
GO
GRANT EXECUTE ON  [dbo].[fn_StringToDelimitedString] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fn_StringToDelimitedString] TO [public]
GO
