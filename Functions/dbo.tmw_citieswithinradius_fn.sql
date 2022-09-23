SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[tmw_citieswithinradius_fn] (@cty_lat decimal(38,20), @cty_long decimal(38,20), @radius int)
RETURNS @citylist TABLE (cty_code int, cty_nmstct varchar(30))
AS
BEGIN
declare @LatDelta decimal(38,20), 
		@LongDelta decimal(38,20),
		@MinLat decimal(38,20), 
		@MaxLat decimal(38,20), 
		@MinLong decimal(38,20), 
		@MaxLong decimal(38,20)

select @LatDelta = dbo.TMW_PossibleLatSpan(@radius), @LongDelta = dbo.TMW_PossibleLongSpan(@cty_lat, @radius)
select @MinLat = @cty_lat - @LatDelta, @MaxLat = @cty_lat + @LatDelta, @MinLong = @cty_long - @LongDelta, @MaxLong = @cty_long + @LongDelta

insert @citylist
select cty_code, cty_nmstct 
from   city 
where  cty_latitude between @MinLat and @MaxLat and cty_longitude between @MinLong and @MaxLong and dbo.tmw_airdistance_fn(cty_latitude,cty_longitude, @cty_lat, @cty_long) <= @radius
order by 2 

return
END
GO
GRANT REFERENCES ON  [dbo].[tmw_citieswithinradius_fn] TO [public]
GO
GRANT SELECT ON  [dbo].[tmw_citieswithinradius_fn] TO [public]
GO
