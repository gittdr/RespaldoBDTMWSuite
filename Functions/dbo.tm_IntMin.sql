SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[tm_IntMin] (@A INT, @B INT)
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

*/
BEGIN
IF(@A > @B)
	RETURN @B;
RETURN @A;
END

GO
GRANT EXECUTE ON  [dbo].[tm_IntMin] TO [public]
GO
