SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_load_zipcity_picklist] (@postcode VARCHAR(10), @city int)
AS
-- should call this routine with a partial postal code or full postal code (@city = 0) 
-- and it will return the exact match or a list of possible postal codes
-- or call it with a city (@postalcode = '') and it will return an exact match or a list of possible postal code.

DECLARE @matches INT

CREATE TABLE #entries 
(cty_code INT NOT NULL, 
 cty_nmstct VARCHAR(30) NOT NULL, 
 cty_state VARCHAR(6) NULL, 
 cty_country VARCHAR(6) NULL, 
 cty_zip VARCHAR(10) NULL, 
 cty_name VARCHAR(18) NULL, 
 cty_region1 VARCHAR(6) NULL, 
 cty_region2 VARCHAR(6) NULL, 
 cty_region3 VARCHAR(6) NULL, 
 cty_region4 VARCHAR(6) NULL)

-- check to see if there is an exact match for the postal code
IF LEN(RTRIM(@postcode)) > 0
BEGIN
   -- check to see if there is an entry in the cityzip table that matches the postalcode
   INSERT INTO #entries (cty_code, cty_nmstct, cty_state, cty_country, cty_zip,  
                         cty_name, cty_region1, cty_region2, cty_region3, cty_region4)
   SELECT city.cty_code, 
          city.cty_nmstct, 
          ISNULL(city.cty_state, ''), 
          ISNULL(city.cty_country, ''), 
          ISNULL(cityzip.zip, ''), 
          ISNULL(city.cty_name, ''), 
          ISNULL(city.cty_region1, ''), 
          ISNULL(city.cty_region2, ''), 
          ISNULL(city.cty_region3, ''), 
          ISNULL(city.cty_region4, '') 
     FROM cityzip, city 
    WHERE zip = @postcode AND 
          cityzip.cty_code = city.cty_code 
   
   SELECT @matches = COUNT(*) 
     FROM #entries
   
   -- if there were no matches in the city zip table, then check for a match in city table
   IF @matches = 0 OR @matches IS NULL
   INSERT INTO #entries (cty_code, cty_nmstct, cty_state, cty_country, cty_zip, 
                         cty_name, cty_region1, cty_region2, cty_region3, cty_region4)
   SELECT city.cty_code, 
          city.cty_nmstct, 
          ISNULL(city.cty_state, ''), 
          ISNULL(city.cty_country, ''), 
          ISNULL(city.cty_zip, ''), 
          ISNULL(city.cty_name, ''), 
          ISNULL(city.cty_region1, ''), 
          ISNULL(city.cty_region2, ''), 
          ISNULL(city.cty_region3, ''), 
          ISNULL(city.cty_region4, '') 
     FROM city 
    WHERE city.cty_zip = @postcode
   
   SELECT @matches = COUNT(*) 
     FROM #entries
   
   -- if there were no exact matches in the city zip or city file, then check for partial matches in the city zip file
   IF @matches = 0 OR @matches IS NULL
   INSERT INTO #entries (cty_code, cty_nmstct, cty_state, cty_country, cty_zip, 
                         cty_name, cty_region1, cty_region2, cty_region3, cty_region4)
   SELECT city.cty_code, 
          city.cty_nmstct, 
          ISNULL(city.cty_state, ''), 
          ISNULL(city.cty_country, ''), 
          ISNULL(cityzip.zip, ''), 
          ISNULL(city.cty_name, ''), 
          ISNULL(city.cty_region1, ''), 
          ISNULL(city.cty_region2, ''), 
          ISNULL(city.cty_region3, ''), 
          ISNULL(city.cty_region4, '') 
     FROM cityzip, city 
    WHERE zip LIKE @postcode + '%' AND 
          cityzip.cty_code = city.cty_code 

   SELECT @matches = COUNT(*) 
     FROM #entries
   
   -- if there were no partial matches in the city zip, then check for partial matches in the city file
   IF @matches = 0 OR @matches IS NULL
   INSERT INTO #entries (cty_code, cty_nmstct, cty_state, cty_country, cty_zip, 
                         cty_name, cty_region1, cty_region2, cty_region3, cty_region4)
   SELECT city.cty_code, 
          city.cty_nmstct, 
          ISNULL(city.cty_state, ''), 
          ISNULL(city.cty_country, ''), 
          ISNULL(city.cty_zip, ''), 
          ISNULL(city.cty_name, ''), 
          ISNULL(city.cty_region1, ''), 
          ISNULL(city.cty_region2, ''), 
          ISNULL(city.cty_region3, ''), 
          ISNULL(city.cty_region4, '') 
     FROM city 
    WHERE city.cty_zip LIKE @postcode + '%'
END

-- check to see if there are postal code records in the city zip table for the matching city.
IF @city > 0
BEGIN
   -- check to see if there are entries in the cityzip table that match the city code
   INSERT INTO #entries (cty_code, cty_nmstct, cty_state, cty_country, cty_zip, 
                         cty_name, cty_region1, cty_region2, cty_region3, cty_region4)
   SELECT city.cty_code, 
          city.cty_nmstct, 
          ISNULL(city.cty_state, ''), 
          ISNULL(city.cty_country, ''), 
          ISNULL(cityzip.zip, ''), 
          ISNULL(city.cty_name, ''), 
          ISNULL(city.cty_region1, ''), 
          ISNULL(city.cty_region2, ''), 
          ISNULL(city.cty_region3, ''), 
          ISNULL(city.cty_region4, '') 
     FROM cityzip, city 
    WHERE cityzip.cty_code = @city AND 
          cityzip.cty_code = city.cty_code 

   SELECT @matches = COUNT(*) 
     FROM #entries
   
   -- if there were no partial matches in the city zip, then check for partial matches in the city file
   IF @matches = 0 OR @matches IS NULL
   INSERT INTO #entries (cty_code, cty_nmstct, cty_state, cty_country, cty_zip, 
                         cty_name, cty_region1, cty_region2, cty_region3, cty_region4)
   SELECT city.cty_code, 
          city.cty_nmstct, 
          ISNULL(city.cty_state, ''), 
          ISNULL(city.cty_country, ''), 
          ISNULL(city.cty_zip, ''), 
          ISNULL(city.cty_name, ''), 
          ISNULL(city.cty_region1, ''), 
          ISNULL(city.cty_region2, ''), 
          ISNULL(city.cty_region3, ''), 
          ISNULL(city.cty_region4, '') 
     FROM city 
    WHERE cty_code = @city
END

SET ROWCOUNT 50

SELECT DISTINCT cty_code, cty_nmstct, cty_state, cty_country, cty_zip, 
                cty_name, cty_region1, cty_region2, cty_region3, cty_region4 
  FROM #entries 
 ORDER BY cty_zip

DROP TABLE #entries

SET ROWCOUNT 0

GO
GRANT EXECUTE ON  [dbo].[d_load_zipcity_picklist] TO [public]
GO
