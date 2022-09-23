SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[nlm_add_city]
	@cityname varchar(18),
	@state char(2),
	@zip varchar(10),
	@county char(3),
	@country char(2),
	@@cty_code int OUTPUT,
	@@cty_nmstct varchar(25) OUTPUT
	
 AS 
  
   SELECT @cityname = UPPER(@cityname)
   SELECT @state = UPPER(@state)
   SELECT @county = UPPER(@county)

  /* If I can exact match on name and state, no need to add  */ 
 /*IF (SELECT COUNT(*)
      FROM city
      WHERE cty_name = @cityname
      AND   cty_state = @state) = 1
         BEGIN 
          SELECT @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
          FROM city
          WHERE cty_name = @cityname
          AND   cty_state = @state

          RETURN -1
         END
  /* if I can exact match on name, state and county, no need to add */
  IF (SELECT COUNT(*)
      FROM city
      WHERE cty_name = @cityname
      AND   cty_state = @state
      AND   cty_county = @county) = 1 
        BEGIN
	 SELECT @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
         FROM city
         WHERE cty_name = @cityname
         AND   cty_state = @state
	 AND  cty_county = @county

      	 RETURN -1
        END
   /* if I can exact match on name, state and country, do it */
  IF (SELECT COUNT(*)
      FROM city
      WHERE cty_name = @cityname
      AND   cty_state = @state
      AND   cty_country = @country) = 1 
	BEGIN
	 SELECT @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
         FROM city
         WHERE cty_name = @cityname
         AND   cty_state = @state
	 AND  cty_country = @country

      	 RETURN -1
	END*/
  /* If I can find the city, add it */
  /*          get a new city code */
  exec @@cty_code = dbo.getsystemnumber 'CTYNUM',NULL
  SELECT @@cty_nmstct = @cityname+','+@state+'/'
  SELECT @county = ISNULL(@county,'')
  IF @county > ''
     SELECT @@cty_nmstct = @@cty_nmstct+@county


  INSERT INTO city (cty_code,cty_name,cty_state,cty_zip,cty_county,cty_nmstct,cty_updatedby,cty_updateddate,cty_createdate)
  VALUES (@@cty_code,@cityname,@state,@zip,@county,@@cty_nmstct,'dbo.nlm_add_city',getdate(),getdate())

  RETURN 1
  

  /* create nmstct  */
  
GO
GRANT EXECUTE ON  [dbo].[nlm_add_city] TO [public]
GO
