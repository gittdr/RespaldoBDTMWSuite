SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* This proc determines if the city name and state passed exists in the PowerSuite city table.
   If it does, the proc returns a -1.

   If it does not the proc adds the city and returns a 1.  The OUTPUT arguments will
   contain the city code assigned to the new city, and the nmstct concatenation used
   in amny PowerSuite tables in addition to the city code

   Call might look like:
     DECLARE @citycode varchar(8),@ret int, @cityname varchar(18), @state char(2)
     DECLARE @citynmstct varchar(25)
     DECLARE @zip varchar(10),@citycode int

     SELECT @cityname = 'Benton Harbor'
     SELECT @state = 'MI'
     SELECT @zip = '50032'
     EXEC  @ret = dx_add_city
	@citynam,
	@state ,
        @zip,
	'',	
	'USA',
	@citycode OUTPUT,
	@citynmstct  OUTPUT
     The @citycode is the key or ID for a city used in many PS tables (orderheader, stop, etc)
     The @ctynmstct is a concatenation of city name + state + county used for many displays
     and is included in some tables. 
*/  
CREATE  PROCEDURE [dbo].[dx_add_city]
	@cityname varchar(18),
	@state char(2),
	@zip varchar(10),
	@county char(3),
	@country char(4),
	@@cty_code int OUTPUT,
	@@cty_nmstct varchar(25) OUTPUT
	
 AS 
  
   SELECT @cityname = UPPER(@cityname)
   SELECT @state = UPPER(@state)
   SELECT @county = UPPER(ISNULL(@county,'   '))
   SELECT @country = UPPER(ISNULL(@country,'    '))

   DECLARE @citycount INT, 
		   @allowfuelcity int


   SELECT @citycount = 0
   
   IF (select upper(isnull(gi_string1,'N')) from generalinfo where gi_name = 'EDI204AllowFuelCity') = 'Y'

	set @allowfuelcity = 1
  ELSE
	set @allowfuelcity = 0
	
	

   /* If I can match on name and state and zip, no need to add  */ 
   SELECT top (1) @citycount = COUNT(1), @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
     FROM city
    WHERE cty_name = @cityname
      AND cty_state = @state
	  AND cty_zip = @zip
	  AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)
	  group by cty_code, cty_nmstct, cty_fuelcreate
	  order by (isnull (cty_fuelcreate, 0) )
	  
      IF @citycount = 1
      begin 
		RETURN -1
      end
      
   
      
    /* If I can match on name and state and county and country and fuel create, no need to add  */   
   SELECT top (1) @citycount = COUNT(1), @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
     FROM city
    WHERE cty_name = @cityname
      AND cty_state = @state
      AND   ISNULL(cty_county,'   ') = @county
      AND   (ISNULL(cty_country,'') = ISNULL(@country,'') or ISNULL(@country,'') = '')
	  AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)
      group by cty_code, cty_nmstct, cty_fuelcreate
	  order by (isnull (cty_fuelcreate, 0) )
	  
	  IF @citycount = 1
      begin 
		RETURN -1
      end
     /* If I can match on name and state no need to add  */   
      IF @citycount > 1
      begin 
		select @@cty_nmstct = cty_nmstct
		FROM city
		where @@cty_code = cty_code
		return -1
      end
      
   SELECT top (1) @citycount = COUNT(1), @@cty_code = cty_code, @@cty_nmstct = cty_nmstct
     FROM city
    WHERE cty_name = @cityname
      AND cty_state = @state
       AND (ISNULL(cty_fuelcreate,0) = 0 or @allowfuelcity = 1)
      group by cty_code, cty_nmstct, cty_fuelcreate
	  order by (isnull (cty_fuelcreate, 0) )
      
     IF @citycount = 1
      begin 
		RETURN -1
      end

 IF @citycount < 1
 begin
  /* If I cant find the city, add it */
  /*          get a new city code */
  exec @@cty_code = dbo.getsystemnumber 'CTYNUM',NULL
  SELECT @@cty_nmstct = @cityname+','+@state+'/'
  SELECT @county = ISNULL(@county,'')
  IF @county > ''
     SELECT @@cty_nmstct = @@cty_nmstct+@county


  INSERT INTO city (cty_code,cty_name,cty_state,cty_zip,cty_county,cty_country, cty_nmstct,cty_updatedby,cty_updateddate,cty_createdate,
					cty_region1,cty_region2,cty_region3,cty_region4)
  VALUES (@@cty_code,@cityname,@state,@zip,@county,@country,@@cty_nmstct,'dbo.dx_add_city',getdate(),getdate(),
			'UNK','UNK','UNK','UNK')

  RETURN 1
end 
GO
GRANT EXECUTE ON  [dbo].[dx_add_city] TO [public]
GO
