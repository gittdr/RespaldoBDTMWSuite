SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_Cities] @KEYWORDSEARCH  VARCHAR(250),
                                    @ADVANCEDSEARCH VARCHAR(MAX),
                                    @PAGESIZE       INT,
                                    @PAGEINDEX      INT
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides search capabilities for a keyword search and an advanced search

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  02/22/2017   Chip Ciminero    WE-?????   Created
  10/10/2017   Chase Plante     WE-211090   Modified proc to trim any string data
*******************************************************************************************************************/

     --SP PARAMS / TEST DATA
     --IF YOU SEARCH FOR A KEYWORD, IT WILL IGNORE ADVANCED SEARCH
     --ADDING MULTIPLE CRITERIA IN ADVANCED SEARCH WILL REQUIRE ALL FIELDS ENTERED TO BE SATISFIED
     --DECLARE @KEYWORDSEARCH VARCHAR(250), @ADVANCEDSEARCH VARCHAR(MAX), @PAGESIZE INT, @PAGEINDEX INT
     --SELECT @KEYWORDSEARCH = 'CLE'
     --, @ADVANCEDSEARCH='{     
     --     "Code": 0,
     --     "Name": "",
     --     "AltId": "",
     --     "State": "",
     --     "Zip": "",
     --     "AreaCode": "",
     --     "SPLC": 0,
     --     "County": "",
     --     "Latitude": 0,
     --     "Longitude": 0,
     --     "Region1": "",
     --     "Region2": "",
     --     "Region3": "",
     --     "Region4": "",
     --     "NameStateCountyDisplay": "",
     --     "Country": "",
     --     "RandCity": "",
     --     "RandState": "",
     --     "RandCounty": "",
     --     "ALKCity": "",
     --     "ALKState": "",
     --     "ALKCounty": "",
     --     "FuelCreatedFlag": 0,
     --     "CountyName": "",
     --     "RandCountyName": "",
     --     "ALKCountyName": "",
     --     "TimeZoneDelta": 0,
     --     "DaylightSavings": ""
     --	  }'
     --, @PAGESIZE = 20, @PAGEINDEX = 1

     DECLARE @ADV_SRCH_PARAMS TABLE
     (PropertyName  VARCHAR(250),
      PropertyValue VARCHAR(250)
     );
     IF LEN(@ADVANCEDSEARCH) > 0
         BEGIN
             INSERT INTO @ADV_SRCH_PARAMS
                    SELECT NAME,
                           STRINGVALUE
                    FROM parseJSON(@ADVANCEDSEARCH);
         END;
     --SELECT * FROM @ADV_SRCH_PARAMS


     SELECT *
     FROM
     (
         SELECT C.cty_code 'Code',
                LTRIM(C.cty_name) 'Name',
                LTRIM(RTRIM(COALESCE(C.cty_state, ''))) 'State',
                LTRIM(RTRIM(COALESCE(C.cty_zip, ''))) 'Zip',
                LTRIM(RTRIM(COALESCE(C.cty_areacode, ''))) 'AreaCode',
                COALESCE(C.cty_splc, 0) 'SPLC',
                LTRIM(COALESCE(C.cty_county, '')) 'County',
                COALESCE(C.cty_latitude, 0) 'Latitude',
                COALESCE(C.cty_longitude, 0) 'Longitude',
                LTRIM(COALESCE(C.cty_region1, '')) 'Region1',
                LTRIM(COALESCE(C.cty_region2, '')) 'Region2',
                LTRIM(COALESCE(C.cty_region3, '')) 'Region3',
			 LTRIM(COALESCE(C.cty_region4, '')) 'Region4',
                LTRIM(RTRIM(COALESCE(C.cty_nmstct, ''))) 'NameStateCountyDisplay',
                LTRIM(RTRIM(COALESCE(C.cty_country, ''))) 'Country',
                LTRIM(RTRIM(COALESCE(C.rand_city, ''))) 'RandCity',
                LTRIM(RTRIM(COALESCE(C.rand_state, ''))) 'RandState',
                LTRIM(RTRIM(COALESCE(C.rand_county, ''))) 'RandCounty',
                LTRIM(RTRIM(COALESCE(C.alk_city, ''))) 'ALKCity',
                LTRIM(RTRIM(COALESCE(C.alk_state, ''))) 'ALKState',
                LTRIM(RTRIM(COALESCE(C.alk_county, ''))) 'ALKCounty',
                COALESCE(C.cty_fuelcreate, 0) 'FuelCreatedFlag',
                LTRIM(RTRIM(COALESCE(C.county_name, ''))) 'CountyName',
                LTRIM(RTRIM(COALESCE(C.rand_county_name, ''))) 'RandCountyName',
                LTRIM(RTRIM(COALESCE(C.alk_county_name, ''))) 'ALKCountyName',
                COALESCE(c.cty_GMTDelta, 0) 'TimeZoneDelta',
                COALESCE(C.cty_DSTApplies, 'N') 'DaylightSavings',
                ROW_NUMBER() OVER(ORDER BY C.cty_name) AS RowNum,
                TotalRows = COUNT(*) OVER() --Total Results
         FROM	city C
	    WHERE	(
	    		--DYNAMIC FILTERING STARTS HERE
	    		CASE 
	    			--SPECIFIC KEYWORD SEARCHES
	    			WHEN LEN(@KEYWORDSEARCH) > 0 THEN
	    			CASE 
	    				--TODO - ANY OTHER FIELDS NEEDED?
	    				WHEN	C.cty_code LIKE @KEYWORDSEARCH + '%' OR 
	    					LTRIM(C.cty_name) LIKE @KEYWORDSEARCH + '%'  OR
	    					LTRIM(C.cty_state) LIKE @KEYWORDSEARCH + '%' OR
	    					LTRIM(C.cty_country) LIKE @KEYWORDSEARCH + '%' OR
	    					LTRIM(C.cty_nmstct) LIKE @KEYWORDSEARCH + '%'
	    				THEN 1 
	    			END			
	    
	    			--ADVANCED SEARCHES - SPECIFIC FIELDS							 
	    			WHEN LEN(@ADVANCEDSEARCH) > 0 THEN			
	    			CASE WHEN 
	    				--CITY CODE
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Code' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Code' AND LEN(PropertyValue) > 0) AND 
	    						  C.cty_code LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Code') + '%') THEN 1	
	    					 ELSE 0 END = 1 				 
	    				--CITY NAME					
	    				AND
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Name' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Name' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_name,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Name') + '%') THEN 1	
	    					 ELSE 0 END = 1
	    				--STATE					
	    				AND
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'State' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'State' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_state,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'State') + '%') THEN 1	
	    					 ELSE 0 END = 1				
	    				--ZIP		
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Zip' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Zip' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_zip,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Zip') + '%') THEN 1	
	    					 ELSE 0 END = 1								
	    				--AREA CODE		
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'AreaCode' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'AreaCode' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_areacode,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'AreaCode') + '%') THEN 1	
	    					 ELSE 0 END = 1	
	    				--SPLC	
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'SPLC' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'SPLC' AND LEN(PropertyValue) > 0) AND
	    						  COALESCE(C.cty_splc,'') LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'SPLC') + '%') THEN 1	
	    					 ELSE 0 END = 1							
	    				--COUNTY
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'County' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'County' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_county,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'County') + '%') THEN 1	
	    					 ELSE 0 END = 1						
	    				--LATITUDE
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Latitude' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Latitude' AND LEN(PropertyValue) > 0) AND
	    						  COALESCE(C.cty_latitude,'') LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Latitude') + '%') THEN 1	
	    					 ELSE 0 END = 1					
	    				--LONGITUDE
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Longitude' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Longitude' AND LEN(PropertyValue) > 0) AND
	    						  COALESCE(C.cty_longitude,'') LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Longitude') + '%') THEN 1	
	    					 ELSE 0 END = 1			
	    				--REGION1
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region1' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region1' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_region1,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region1') + '%') THEN 1	
	    					 ELSE 0 END = 1		
	    				--REGION2
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region2' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region2' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_region2,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region2') + '%') THEN 1	
	    					 ELSE 0 END = 1		
	    				--REGION3
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region3' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region3' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_region3,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region3') + '%') THEN 1	
	    					 ELSE 0 END = 1		
	    				--REGION4
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region4' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region4' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_region4,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Region4') + '%') THEN 1	
	    					 ELSE 0 END = 1		
	    				--NAMESTATECOUNTYDISPLAY
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'NameStateCountyDisplay' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'NameStateCountyDisplay' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_nmstct,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'NameStateCountyDisplay') + '%') THEN 1	
	    					 ELSE 0 END = 1	
	    				--NAMESTATECOUNTYDISPLAY
	    				AND						
	    				CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Country' AND LEN(PropertyValue) > 0) THEN 1 
	    					 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Country' AND LEN(PropertyValue) > 0) AND
	    						  LTRIM(COALESCE(C.cty_country,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Country') + '%') THEN 1	
	    					 ELSE 0 END = 1	
	    			THEN 1 ELSE 0 END	
	    		ELSE
	    			1
	    		END
	    		) = 1
	    ) Data
WHERE	Data.RowNum > @PAGESIZE * (@PAGEINDEX - 1)
		AND Data.RowNum <= @PAGESIZE * @PAGEINDEX
ORDER BY Data.RowNum
GO
GRANT EXECUTE ON  [dbo].[SearchAPI_Cities] TO [public]
GO
