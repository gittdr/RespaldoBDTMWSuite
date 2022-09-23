SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 
 RETURN CODES
    1 A match was found on city,state, and zip values
    2 A match was found on city,state, and county values
   -1 a match could not be found
*/

CREATE PROCEDURE [dbo].[nlm_does_city_exist]
	@cityname varchar(18),
	@state varchar(2),
	@county varchar(3),
	@country varchar(2),
	@zip varchar(10),
	@@cty_code int OUTPUT,
	@@cty_nmstct varchar(25) OUTPUT
	
 AS 

DECLARE @mincitycode int

 
/* If I can exact match on name, state, and zip do it  */
/* is there an exact match */
IF (SELECT COUNT(*)
      FROM city
     WHERE cty_name = @cityname AND
           cty_state = @state AND
	   cty_zip = @zip) = 1
BEGIN 
  SELECT @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
    FROM city
   WHERE cty_name = @cityname AND
         cty_state = @state AND
         cty_zip = @zip
  RETURN 1
END

if (SELECT COUNT(*) 
      FROM cityzip
     WHERE zip = @zip) = 1
BEGIN
   SELECT @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
     FROM cityzip
    WHERE zip = @zip
   RETURN 1
END

IF LEN(RTRIM(@county)) > 0
BEGIN
   IF (SELECT COUNT(*)
         FROM city
        WHERE cty_name = @cityname AND 
              cty_state = @state AND 
              cty_county = @county) = 1
   BEGIN 
      SELECT @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
        FROM city
       WHERE cty_name = @cityname AND
             cty_state = @state AND
             cty_county = @county

      RETURN 2
   END
   IF (SELECT COUNT(*)
         FROM city
        WHERE cty_name = @cityname AND 
              cty_state = @state AND 
             (cty_county IS NULL or RTRIM(cty_county) = '')) = 1
   BEGIN
      SELECT @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
        FROM city
       WHERE cty_name = @cityname AND   
             cty_state = @state AND 
            (cty_county IS NULL or RTRIM(cty_county) = '')
      RETURN 3
   END 
END
ELSE
BEGIN
   IF (SELECT COUNT(*)
         FROM city
        WHERE cty_name = @cityname AND   
              cty_state = @state AND 
             (cty_county IS NULL or RTRIM(cty_county) = '')) = 1
   BEGIN 
      SELECT @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
        FROM city
       WHERE cty_name = @cityname AND   
             cty_state = @state AND  
            (cty_county IS NULL or RTRIM(cty_county) = '')
      RETURN 4
   END
   /* no exact match found, try to find an entry with a county */
   IF (SELECT COUNT(*)
         FROM city
        WHERE cty_name = @cityname AND
              cty_state = @state) > 0
   BEGIN 
      /* If I can find a closest match, do it but change return */
      SELECT @mincitycode = MIN(cty_code)
  	FROM city
       WHERE cty_name = @cityname AND 
             cty_state = @state

      SELECT @mincitycode = ISNULL(@mincitycode,0)

      IF @mincitycode > 0  
      BEGIN
	 SELECT @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
           FROM city
          WHERE cty_code = @mincitycode
         RETURN 5
      END
   END
END
 
/* no match found */
RETURN -1

GO
GRANT EXECUTE ON  [dbo].[nlm_does_city_exist] TO [public]
GO
