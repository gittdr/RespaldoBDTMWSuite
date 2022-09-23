SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TM_GET_CtyCode] @CityName varchar(18)='',@State varchar(6) ='', @cty_check_lat float =0, @cty_check_long float=0, @CityLatLongUOM char = 'S', @trueCity int OUTPUT
AS
DECLARE
	@cty_code int,
	@cty_count int,
	@Lat float,
	@Long float,
	@cty_distance float,
	@cty_check_distance float,
	@cty_check_code int
	-- created for PTS 71501 - HMA  - 11/24/2014
	--this proc is called by updatemove when OLD STYLE checkcalls is enabled	
	-- usage: exec dbo.TM_GET_CtyCode 'BROOKLYN','NY',146687,266178, 'S', @reply out 
	--a latlong for queens is given - we are looking for the right (closest) brooklyn to come back to us!


							-- Get the cty_code for this city/state
						SELECT @cty_code = MIN(cty_code), @cty_count = COUNT(cty_code)
						FROM city (NOLOCK)
						WHERE cty_name = @CityName 
						  AND cty_state = @State

						IF ISNULL(@cty_code,0) = 0
							SET @cty_code = 0

						IF @cty_count > 1
							-- If there is more than one entry in the city table for this city/state
							--  find the closest one to where this checkcall is.
								SET @cty_check_code = @cty_code
								SET @cty_distance = 99999
								set @Lat = @cty_check_lat
								set @Long = @cty_check_long
								WHILE ISNULL(@cty_check_code, 0) > 0
									BEGIN
										SELECT @cty_check_lat = ISNULL(cty_latitude, -5000000), @cty_check_long = ISNULL(cty_longitude, -5000000) 
										FROM city (NOLOCK) 
										WHERE cty_code = @cty_check_code
										
										IF @cty_check_lat > -5000000 and @cty_check_long > -5000000
											BEGIN
												IF (@CityLatLongUOM) = 'S'
													BEGIN
														-- Convert from seconds to degrees
														SET @cty_check_lat = @cty_check_lat / 3600
														SET @cty_check_long = @cty_check_long / 3600
													END

												EXEC dbo.tmail_airdistance @Lat, @Long, @cty_check_lat, @cty_check_long, @cty_check_distance out
												IF @cty_check_distance < @cty_distance
												SELECT @cty_code = @cty_check_code, @cty_distance = @cty_check_distance
											END

										SELECT @cty_check_code = MIN(cty_code)
											FROM city  (NOLOCK)
											WHERE cty_name = @CityName 
												AND cty_state = @State
												AND cty_code > @cty_check_code
									END--wHILE

 SELECT @trueCity = ISNULL(@cty_code,0)


GO
GRANT EXECUTE ON  [dbo].[TM_GET_CtyCode] TO [public]
GO
