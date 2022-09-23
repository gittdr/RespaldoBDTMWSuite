SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/* This proc determines if the city name and state passed (county and country are optional)
   exists in the PowerSuite city table. Some cities in that table are in multiple
   counties and there are records for each county. 

   If an exact match can be found, the return code is = 1.   If a match can be found on city
   name and state but no match on county then the return code is = 2.  For either the
   cty_code (key to the city in the table) and the cty_nmstct (name,state / county) is
   returned - these data are needed for adding a company or an order.  Just remember that 
   with a return of 2 there is a match, but it includes a county and either you did not
   pass one or the one passed did not match.

   Since PowerSuite does not deal with countries at this time, this data is not processed

 RETURN CODES
    1 A match was found on city,state, and county values
    2 Only a city name and state were passed (county was ''). No exact match was found.
      However, there are entries for this city with county values.  What is returned
      is the info for one of those entries.
    3 City name, state and county passed, but there is no exact match.  There is an
      entry for the name and state only (city file county is NULL or blank). Info for
      the no county entry is returned
    
   -1 a match could not be found
   
 ARGUMENTS
  @cityname varchar(18) required

  @state char(2) required (for Canadian cities this is a province code)

  @county char(3) optional.  If passed there must be a match

  @country char(2) match on country given priority over blank country for match, country mis-match not returned

  @@cty_code int OUTPUT If a match or close match is found (return codes 1,2) this is a
        valid PowerSUite city code

  @@cty_nmstct varchar(25) OUTPUT If a match or close match is found (return codes 1,2) this is 
        the nmstct field for this sity

  
  SAMPLE CALL

      exec @ret = does_city_exist
	'CLEVELAND',
	'OH',
	'',
	'',
	@cty_code OUTPUT,
	@cty_nmstct OUTPUT

   Where @ctystate contains the 2 character state abbreviation (for Canadian cities,
   this will be a province code). @ret will contain -1 or 1 or 2. If @ret is > 1 then
   @cty_code will contain the numeric key to the city table and @cty_nmstct will contin
   the name+,state+county concatenation. EG.  CLEVELAND,OH/  or ADAMS,IL/AD or TORONTO,ON/
*/  
CREATE PROCEDURE [dbo].[does_city_exist]
	@cityname varchar(18),
	@state char(2),
	@county char(3),
	@country char(2),
	@cty_code int OUTPUT,
	@cty_nmstct varchar(25) OUTPUT
	
 AS 

  DECLARE @mincitycode int
  DECLARE @allowfuelcity bit
  declare @citycount int
  
  IF (select upper(isnull(gi_string1,'N')) from generalinfo where gi_name = 'EDI204AllowFuelCity') = 'Y'
	set @allowfuelcity = 1
  ELSE
	set @allowfuelcity = 0
	
	
 
  /* If I can exact match on name, state, and county do it  */
IF LEN(RTRIM(@county)) > 0
 BEGIN
   /* is there an exact match */
   IF (SELECT COUNT(1)
      FROM city
      WHERE cty_name = @cityname
      AND   cty_state = @state
	  AND cty_county = @county
	  AND IsNull(cty_country,'') = IsNull(@country,'') 
	  AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)) = 1
     BEGIN 
          SELECT @cty_code = cty_code, @cty_nmstct = cty_nmstct
          FROM city
          WHERE cty_name = @cityname
          AND   cty_state = @state
          AND  cty_county = @county
          AND (IsNull(cty_country,'') = IsNull(@country,'') or IsNull(@country,'') = '') -- country matches or was not specified
		  AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)
          RETURN 1
     END

   IF (SELECT COUNT(1)
      FROM city
      WHERE cty_name = @cityname
      AND   cty_state = @state
	  AND cty_county = @county
	  AND IsNull(cty_country,'') = '' -- country specified but city with blank country found
	  AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)) = 1
     BEGIN 
          SELECT @cty_code = cty_code, @cty_nmstct = cty_nmstct
          FROM city
          WHERE cty_name = @cityname
          AND   cty_state = @state
          AND  cty_county = @county
          AND IsNull(cty_country,'') = '' 
		  AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)
          RETURN 1
     END


   IF(SELECT COUNT(1)
      FROM city
      WHERE cty_name = @cityname
      AND cty_state = @state
      AND (cty_county IS NULL or RTRIM(cty_county) = '')
      AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)) = 1
      BEGIN
        SELECT @cty_code = cty_code, @cty_nmstct = cty_nmstct
        FROM city
        WHERE cty_name = @cityname
          AND   cty_state = @state
          AND (cty_county IS NULL or RTRIM(cty_county) = '')
          AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)
          RETURN 3
       END 
 END
 
 
 
ELSE


  BEGIN
    IF (SELECT COUNT(1)
        FROM city
        WHERE cty_name = @cityname
        AND   cty_state = @state
	AND ( cty_county IS NULL or RTRIM(cty_county) = '')
	AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)) = 1
          BEGIN 
            SELECT @cty_code = cty_code, @cty_nmstct = cty_nmstct
            FROM city
            WHERE cty_name = @cityname
            AND   cty_state = @state
            AND  (cty_county IS NULL or RTRIM(cty_county) = '')
            AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)
            RETURN 1
         END
    /* no exact match found, try to find an entry with a county */
    IF (SELECT COUNT(1)
        FROM city
        WHERE cty_name = @cityname
        AND   cty_state = @state
        AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)) > 0
           BEGIN 
             /* If I can find a closest match, do it but change return */
             SELECT @mincitycode = MIN(cty_code)
  		  	FROM city
			WHERE cty_name = @cityname
			AND cty_state = @state
			AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)
             SELECT @mincitycode = ISNULL(@mincitycode,0)

             IF @mincitycode > 0  
	       BEGIN
	         SELECT @cty_code = cty_code, @cty_nmstct = cty_nmstct
                 FROM city
                 WHERE cty_code = @mincitycode

      	         RETURN 2
	       END
             END
             
 END
  
  
 
  /* no match found */
 RETURN -1

GO
GRANT EXECUTE ON  [dbo].[does_city_exist] TO [public]
GO
