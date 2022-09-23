SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_AirMilesBetweenLatLongSeconds]
					@sLatSeconds1 varchar(12),
					@sLatSeconds2 varchar(12),
					@sLongSeconds1 varchar(12),
					@sLongSeconds2 varchar(12),
					@sFlags varchar(12)
					
AS

BEGIN

	DECLARE @LatSeconds1 float,
			@LatSeconds2 float,
			@LongSeconds1 float,
			@LongSeconds2 float,
			@lat1 float,
			@lat2 float,
			@long1 float,
			@long2 float,
			@AirMiles float

	SET @LatSeconds1 = CONVERT(float, @sLatSeconds1)
	SET @LatSeconds2 = CONVERT(float, @sLatSeconds2)
	SET @LongSeconds1 = CONVERT(float, @sLongSeconds1)
	SET @LongSeconds2 = CONVERT(float, @sLongSeconds2)

	If  ISNULL(@latSeconds1, 0) = 0 OR ISNULL(@latSeconds2, 0) = 0 OR ISNULL(@longSeconds1, 0) = 0 OR ISNULL(@longSeconds2, 0) = 0
		BEGIN
			SELECT -1 AirMiles
			RETURN 
		END

	Set @lat1 = Convert(float,@LatSeconds1)/3600.0 -- convert Seconds to factional degrees
	Set @lat2 = Convert(float,@LatSeconds2)/3600.0 -- convert Seconds to factional degrees
	Set @Long1 = Convert(float,@LongSeconds1)/3600.0 -- convert Seconds to factional degrees
	Set @Long2 = Convert(float,@LongSeconds2)/3600.0 -- convert Seconds to factional degrees

	If  (@lat1<5 or @lat1>85) 
		BEGIN
			SELECT -1 AirMiles
			RETURN 
		END
	If  (@lat2<5 or @lat2>85)
		BEGIN
			SELECT -1 AirMiles
			RETURN 
		END
	If  (@long1<5 or @long1>175)
		BEGIN
			SELECT -1 AirMiles
			RETURN 
		END
	If  (@long2<5 or @long2>175)
		BEGIN
			SELECT -1 AirMiles
			RETURN 
		END

	IF (@LAT1=@LAT2 and @long1=@long2)
		BEGIN
			SELECT 0 AirMiles
			RETURN 
		END


	Set	@AirMiles=
	 ISNULL(	
				/* -- Convert values from degrees to radians */
		(
		Select 
		Acos(
			
			cos(	(@lat1 * 3.14159265358979 / 180.0)  )  *
			cos(	(@Lat2 * 3.14159265358979 / 180.0)  )  *
			
					cos (  
				(@long1 * 3.14159265358979 / 180.0) - 
				(@long2 * 3.14159265358979 / 180.0)
				)	+
			Sin (	(@lat1 * 3.14159265358979 / 180.0) ) *
			Sin (	(@Lat2 * 3.14159265358979 / 180.0) ) 	
			) * 3956.5
		)
	,-1)

	SELECT @AirMiles AirMiles

END

GO
GRANT EXECUTE ON  [dbo].[tm_AirMilesBetweenLatLongSeconds] TO [public]
GO
