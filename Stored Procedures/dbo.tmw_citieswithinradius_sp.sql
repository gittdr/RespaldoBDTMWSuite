SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmw_citieswithinradius_sp] (@cty_lat decimal(38,20), @cty_long decimal(38,20), @radius int)
AS
--MTC 2013.06.25 broke airdistance <= apart instead of calculating twice
BEGIN
declare @LatDelta decimal(38,20),   
  @LongDelta decimal(38,20),  
  @MinLat decimal(38,20),   
  @MaxLat decimal(38,20),   
  @MinLong decimal(38,20),   
  @MaxLong decimal(38,20)  
  
select @LatDelta = dbo.TMW_PossibleLatSpan(@radius), @LongDelta = dbo.TMW_PossibleLongSpan(@cty_lat, @radius)  
select @MinLat = @cty_lat - @LatDelta, @MaxLat = @cty_lat + @LatDelta, @MinLong = @cty_long - @LongDelta, @MaxLong = @cty_long + @LongDelta  

select AirDistance, cty_code, cty_nmstct, cty_zip from (
select cty_latitude,cty_longitude, 
dbo.tmw_airdistance_fn(cty_latitude,cty_longitude, @cty_lat, @cty_long) as 'AirDistance', 
cty_code, cty_nmstct, cty_zip   
from   city   
where  cty_latitude between @MinLat and @MaxLat and cty_longitude between @MinLong and @MaxLong ) a
where AirDistance <= @radius
and cty_code is not null order by cty_code

END
GO
GRANT EXECUTE ON  [dbo].[tmw_citieswithinradius_sp] TO [public]
GO
