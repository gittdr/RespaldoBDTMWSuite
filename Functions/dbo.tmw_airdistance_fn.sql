SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[tmw_airdistance_fn]
	(@lat1	DECIMAL(38,20),
	 @long1	DECIMAL(38,20),
	 @lat2 DECIMAL(38,20),
	 @long2 DECIMAL(38,20)) 
RETURNS DECIMAL(38,20)
AS
BEGIN
	DECLARE @x 			DECIMAL(38,20),
			@distance	DECIMAL(38,20)

	SET @distance = 0.0

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
	RETURN @distance
END
GO
GRANT EXECUTE ON  [dbo].[tmw_airdistance_fn] TO [public]
GO
