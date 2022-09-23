SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create FUNCTION [dbo].[fn_SSRS_Urlencode](@string varchar(max))
-- Credit: Daniel Hutmacher his original version of this code.
-- See: http://sqlsunday.com/2013/04/07/url-encoding-function/
/*
example of use
select dbo.[fn_SSRS_Urlencode]('Hello world')
output: 
Hello%20world
select dbo.[fn_SSRS_Urlencode]('Hello&world')
output:
Hello%26world
*/



RETURNS varchar(max)
AS

BEGIN
DECLARE @hex char(2);
DECLARE @dec int;
DECLARE @offset int;
DECLARE @char char(1);

-- Replace % with %25, so we can skip the % while looping over the string.
SET @string = REPLACE(@string, '%', '%25');

-- Loop through the @string variable, using PATINDEX() to look
-- for non-standard characters using a wildcard. When no more
-- are found, PATINDEX() will return 0, and the WHILE loop will end.
SET @offset = PATINDEX('%[^ A-Z0-9.-\%]%', @string);
WHILE (@offset != 0)
BEGIN
SET @char = SUBSTRING(@string, @offset, 1);
SET @dec = ASCII(@char);

SET @hex = SUBSTRING('0123456789ABCDEF', 1 + (@dec - @dec % 16)/16, 1)
+ SUBSTRING('0123456789ABCDEF', 1 + (@dec % 16), 1);

-- Replace the non-standard char with URL encoded equivalent:
SET @string = REPLACE(@string, @char, '%' + @hex);

-- Find the next occurrence, if any:
SET @offset = PATINDEX('%[^ A-Z0-9.-\%]%', @string);
END

SET @string = REPLACE(@string, ' ', '%20');

-- Done.
RETURN @string;
END
GO
