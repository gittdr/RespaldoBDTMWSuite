SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create Procedure [dbo].[tm_LatLongInALKFormat] @InLat varchar(20), @InLong varchar(20)

AS

SET NOCOUNT ON

Declare @sLat varchar(9),	@sLong varchar(9),	@sLatDir char(1),
        @sLongDir char(1),	@fLat float,		@fLong float

SET @fLat = convert(float, @InLat)
SET @fLong = convert(float, @InLong)

SET @sLatDir = CASE WHEN @fLat < 0 THEN 'S' ELSE 'N' END
SET @sLongDir = CASE WHEN @fLong < 0 THEN 'E' ELSE 'W' END

SET @fLong = ABS(@fLong)
SET @sLat = LTRIM(STR(@fLat,7,4))
SET @sLong = LTRIM(STR(@fLong,8,4))


SELECT @sLat + @sLatDir + ',' + @sLong + @sLongDir

GO
GRANT EXECUTE ON  [dbo].[tm_LatLongInALKFormat] TO [public]
GO
