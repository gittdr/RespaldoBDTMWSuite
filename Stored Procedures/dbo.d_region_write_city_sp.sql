SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[d_region_write_city_sp] @code int 
AS 

DECLARE @count int , @maxcode int 

SELECT @count = 0 
SELECT @maxcode = @code 

while ( @count < 100 ) begin 
SELECT @count = @count + 1 
SELECT @maxcode = min ( cty_code ) FROM city WHERE cty_code > @maxcode 
end 
if @maxcode IS null SELECT @maxcode = max ( cty_code ) FROM city 

SELECT city.cty_code, city.cty_region1, city.cty_region2, city.cty_region3, city.cty_region4 
FROM city 
WHERE city.cty_code > @code AND city.cty_code <= @maxcode 
ORDER BY city.cty_code ASC 



GO
GRANT EXECUTE ON  [dbo].[d_region_write_city_sp] TO [public]
GO
