SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[cmp_airdistance] (@ocmp_id varchar (8), @ocmp_city integer, @dcmp_id varchar (8), @dcmp_city integer)
RETURNS DECIMAL (38,20)
AS
BEGIN
	DECLARE @distance 		DECIMAL(38,20), 
			@olat			DECIMAL(38,20), 
			@olong			DECIMAL(38,20), 
			@dlat			DECIMAL(38,20), 
			@dlong			DECIMAL(38,20), 
			@cmp_real_city	INTEGER 
	
	SELECT @olat = CAST (cmp_latseconds AS DECIMAL(38,20)) / 3600.00, 
	 	   @olong = CAST (cmp_longseconds AS DECIMAL(38,20)) / 3600.00, 
	 	   @cmp_real_city = cmp_city
	FROM company
	WHERE cmp_id = @ocmp_id
	
	IF @olat IS NULL OR @olong IS NULL OR @ocmp_id = 'UNKNOWN'
	BEGIN
		IF @ocmp_city IS NULL
			SELECT @ocmp_city = @cmp_real_city
		SELECT @olat = cty_latitude, 
			   @olong = cty_longitude
		FROM city
		WHERE cty_code = @ocmp_city
	END

	SELECT @dlat = CAST (cmp_latseconds AS DECIMAL(38,20)) / 3600.00, 
	 	   @dlong = CAST (cmp_longseconds AS DECIMAL(38,20)) / 3600.00, 
	 	   @cmp_real_city = cmp_city
	FROM company
	WHERE cmp_id = @dcmp_id
	
	IF @dlat IS NULL OR @dlong IS NULL OR @dcmp_id = 'UNKNOWN'
	BEGIN
		IF @dcmp_city IS NULL
			SELECT @dcmp_city = @cmp_real_city
		SELECT @dlat = cty_latitude, 
			   @dlong = cty_longitude
		FROM city
		WHERE cty_code = @dcmp_city
	END

	SET @distance = dbo.tmw_airdistance_fn (@olat, @olong, @dlat, @dlong)
	RETURN @distance
END

GO
GRANT EXECUTE ON  [dbo].[cmp_airdistance] TO [public]
GO
