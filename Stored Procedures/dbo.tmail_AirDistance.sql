SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 10/19/00 MZ: */
CREATE PROCEDURE [dbo].[tmail_AirDistance]  @lat1 float,
					@long1 float,
					@lat2 float,
					@long2 float,
					@distance float out
AS

DECLARE @x float

SET NOCOUNT ON 

SELECT @distance = 0

--  If lats/longs are exactly the same, the following will return a division by zero
--   error.  So just assign the 0 miles and exit.
IF NOT (@lat1 = @lat2 And @long1 = @long2)
  BEGIN
	-- Convert values from degrees to radians
	SELECT @lat1 = @lat1 * 3.14159265358979 / 180
	SELECT @lat2 = @lat2 * 3.14159265358979 / 180
	SELECT @long1 = @long1 * 3.14159265358979 / 180
	SELECT @long2 = @long2 * 3.14159265358979 / 180

	-- Now do the air distance calculation
	SELECT @x = Cos(@lat1) * Cos(@lat2) * Cos(@long1 - @long2) + Sin(@lat1) * Sin(@lat2)

	IF (@x > 1)		-- This can occur due to rounding error
		SET @x = 1

	SELECT @distance = 3958.7558657440547204326731885787 * acos(@x)
  END
GO
GRANT EXECUTE ON  [dbo].[tmail_AirDistance] TO [public]
GO
