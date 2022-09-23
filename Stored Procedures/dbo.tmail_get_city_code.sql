SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_city_code]	
						@sCityName varchar(20),
						@sState varchar(10),
						@sLatitude varchar(20),
						@sLongitude varchar(20),
						@sFlags varchar(12)
AS

SET NOCOUNT ON 

	DECLARE @icty_code int, 
			@icty_count int,
			@icty_check_code int,
			@fcty_distance float,
			@fcty_check_distance float,
			@fcty_check_lat float,
			@fcty_check_long float,
			@fLatitude float,
			@fLongitude float,
			@CityLatLongUOM char(1),
			@iFlags int

	if ISNULL(@sCityName, '') = ''
		BEGIN
		RAISERROR ('tmail_get_city_code:City Name must be passed in.', 16, 1)
		RETURN
		END

	if ISNULL(@sState, '') = ''
		BEGIN
		RAISERROR ('tmail_get_city_code:State must be passed in.', 16, 1)
		RETURN
		END
	
	SET @fLatitude = CONVERT(float, @sLatitude)
	SET @fLongitude = CONVERT(float, @sLongitude)

	SET @CityLatLongUOM = 'S'
	SELECT @CityLatLongUOM = ISNULL(gi_string1, 'S')
	FROM generalinfo (NOLOCK)
	WHERE gi_name =  'CityLatLongUnits'

	-- Get the cty_code for this city/state
	SELECT @icty_code = MIN(cty_code), @icty_count = COUNT(cty_code)
	FROM city (NOLOCK)
	WHERE cty_name = @sCityName 
	  AND cty_state = @sState

	IF ISNULL(@icty_code,0) = 0
		SET @icty_code = 0

	IF @icty_count > 1
		-- If there is more than one entry in the city table for this city/state
		--  find the closest one to where this checkcall is.
		BEGIN
			SET @icty_check_code = @icty_code
			SET @fcty_distance = 99999
			WHILE ISNULL(@icty_check_code, 0) > 0
				BEGIN
					SELECT @fcty_check_lat = ISNULL(cty_latitude, -5000000), @fcty_check_long = ISNULL(cty_longitude, -5000000) FROM city where cty_code = @icty_check_code
					IF @fcty_check_lat > -5000000 and @fcty_check_long > -5000000
						BEGIN
							IF (@CityLatLongUOM) = 'S'
								BEGIN
									-- Convert from seconds to degrees
									SET @fcty_check_lat = @fcty_check_lat / 3600
									SET @fcty_check_long = @fcty_check_long / 3600
								END

							EXEC dbo.tmail_airdistance @fLatitude, @fLongitude, @fcty_check_lat, @fcty_check_long, @fcty_check_distance out
							IF @fcty_check_distance < @fcty_distance
							SELECT @icty_code = @icty_check_code, @fcty_distance = @fcty_check_distance
						END

					SELECT @icty_check_code = MIN(cty_code)
						FROM city (NOLOCK)
						WHERE cty_name = @sCityName 
							AND cty_state = @sState
							AND cty_code > @icty_check_code
				END--wHILE
		END 
		
		SELECT @icty_code CityCode
GO
GRANT EXECUTE ON  [dbo].[tmail_get_city_code] TO [public]
GO
