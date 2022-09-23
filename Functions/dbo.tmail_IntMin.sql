SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[tmail_IntMin] (@A INT, @B INT)
RETURNS  Int
AS 
/*
Name: tm_IntMin

Type:
scalar function

Descritption:
Returns the minimum val int from a set given

Returns:
minimum val int

Parameters:
2 ints

Change Log:
rwolfe init 10-20-2014
rwolfe PTS 101890 - make copy in Suite
*/
BEGIN
IF(@A > @B)
	RETURN @B;
RETURN @A;
END

GO
GRANT EXECUTE ON  [dbo].[tmail_IntMin] TO [public]
GO
