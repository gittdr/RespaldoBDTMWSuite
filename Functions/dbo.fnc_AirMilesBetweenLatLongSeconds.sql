SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_AirMilesBetweenLatLongSeconds]
	(@LatSeconds1 int,@LatSeconds2 int,@LongSeconds1 int,@LongSeconds2 int )

RETURNS Float
AS
BEGIN

Declare @lat1 float
Declare @lat2 float

Declare @long1 float
Declare @long2 float
Declare @AirMiles float
--If  @CityCode1 is NULL RETURN 0
--If  @CityCode2 is NULL RETURN 0
--If  @CityCode1 = 0 RETURN 0
--If  @CityCode2 = 0 RETURN 0

--Set @lat1= (Select cty_latitude from city where cty_code=@cityCode1)
--Set @lat2= (Select cty_latitude from city where cty_code=@cityCode2)
--Set @long1= (Select cty_longitude from city where cty_code=@cityCode1)
--Set @long2= (Select cty_longitude from city where cty_code=@cityCode2)
If  @latSeconds1 is NULL RETURN 0
If  @latSeconds2 is NULL RETURN 0
If  @longSeconds1 is NULL RETURN 0
If  @longSeconds2 is NULL RETURN 0

Set @lat1 = Convert(float,@LatSeconds1)/3600.0 -- convert Seconds to factional degrees
Set @lat2 = Convert(float,@LatSeconds2)/3600.0 -- convert Seconds to factional degrees
Set @Long1 = Convert(float,@LongSeconds1)/3600.0 -- convert Seconds to factional degrees
Set @Long2 = Convert(float,@LongSeconds2)/3600.0 -- convert Seconds to factional degrees

If  (@lat1<5 or @lat1>85) RETURN 0
If  (@lat2<5 or @lat2>85) RETURN 0
If  (@long1<5 or @long1>175) RETURN 0
If  (@long2<5 or @long2>175) RETURN 0
--if (@CityCode1= @CityCode2) RETURN 0
IF (@LAT1=@LAT2 and @long1=@long2) RETURN 0
IF (ABS(@LAT1-@LAT2)<.02 and ABS(@Long1-@Long2)<.02) RETURN 0


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

return @AirMiles


END

GO
GRANT EXECUTE ON  [dbo].[fnc_AirMilesBetweenLatLongSeconds] TO [public]
GO
