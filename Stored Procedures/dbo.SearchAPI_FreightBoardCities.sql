SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_FreightBoardCities]
@KEYWORDSEARCH VARCHAR(250), @ADVANCEDSEARCH VARCHAR(MAX), @PAGESIZE INT, @PAGEINDEX INT
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides search capabilities for a keyword search and an advanced search

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  05/05/2017   Chase Plante     WE-207451   Created
  10/10/2017   Chase Plante     WE-211090   Modified proc to trim any string data
  01/22/2018   WE-213474		WE-213474   Modified Id to be City since it's the name and removed long/lat.
*******************************************************************************************************************/

--SP PARAMS / TEST DATA
--IF YOU SEARCH FOR A KEYWORD, IT WILL IGNORE ADVANCED SEARCH
--ADDING MULTIPLE CRITERIA IN ADVANCED SEARCH WILL REQUIRE ALL FIELDS ENTERED TO BE SATISFIED
--DECLARE @KEYWORDSEARCH VARCHAR(250), @ADVANCEDSEARCH VARCHAR(MAX), @PAGESIZE INT, @PAGEINDEX INT
--SELECT @KEYWORDSEARCH = 'CLE'
--, @ADVANCEDSEARCH='{     
--     "City": 0,
--     "State": "",
--     "County": "",
--     "Zip": "",
--     "Latitude": 0,
--     "Longitude": 0,
--     "Preferred": "N"
--	  }'
--, @PAGESIZE = 20, @PAGEINDEX = 1

DECLARE @ADV_SRCH_PARAMS TABLE(PropertyName VARCHAR(250), PropertyValue VARCHAR(250))
		
IF LEN(@ADVANCEDSEARCH) > 0
	BEGIN
		INSERT @ADV_SRCH_PARAMS	
		SELECT	NAME, STRINGVALUE
		FROM	parseJSON(@ADVANCEDSEARCH)
	END
--SELECT * FROM @ADV_SRCH_PARAMS


SELECT	*
FROM	(
		SELECT LTRIM(RTRIM(fbic.fbic_city)) 'City', 
		       LTRIM(RTRIM(fbic.fbic_state)) 'State', 
		       LTRIM(RTRIM(fbic.fbic_county)) 'County', 
		       LTRIM(RTRIM(COALESCE(fbic.fbic_zip,''))) 'Zip', 
		       COALESCE(fbic.fbic_latitude,0) 'Latitude', 
		       COALESCE(fbic.fbic_longitude,0) 'Longitude', 
		       COALESCE(fbic.fbic_preferred,'N') 'Preferred', 
			  ROW_NUMBER() OVER (ORDER BY fbic.fbic_city) AS RowNum,
		       Count(*) OVER() 'TotalRows' --Total Results
		FROM	fbi_city fbic
		WHERE	(
				--DYNAMIC FILTERING STARTS HERE
				CASE 
					--SPECIFIC KEYWORD SEARCHES
					WHEN LEN(@KEYWORDSEARCH) > 0 THEN
					CASE 
						--TODO - ANY OTHER FIELDS NEEDED?
						WHEN	LTRIM(fbic.fbic_city) LIKE @KEYWORDSEARCH + '%' OR 
							LTRIM(fbic.fbic_state) LIKE @KEYWORDSEARCH + '%' OR
							LTRIM(fbic.fbic_county) LIKE @KEYWORDSEARCH + '%' OR
							LTRIM(fbic.fbic_zip) LIKE @KEYWORDSEARCH + '%'
						THEN 1 
					END

					--ADVANCED SEARCHES - SPECIFIC FIELDS							 
					WHEN LEN(@ADVANCEDSEARCH) > 0 THEN			
					CASE WHEN 
						--CITY NAME
						CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'City' AND LEN(PropertyValue) > 0) THEN 1 
							 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'City' AND LEN(PropertyValue) > 0) AND 
								  LTRIM(fbic.fbic_city) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'City') + '%') THEN 1	
							 ELSE 0 END = 1 		
						--STATE					
						AND
						CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'State' AND LEN(PropertyValue) > 0) THEN 1 
							 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'State' AND LEN(PropertyValue) > 0) AND
								  LTRIM(fbic.fbic_state) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'State') + '%') THEN 1	
							 ELSE 0 END = 1					
						--COUNTY
						AND						
						CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'County' AND LEN(PropertyValue) > 0) THEN 1 
							 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'County' AND LEN(PropertyValue) > 0) AND
								  LTRIM(fbic.fbic_county) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'County') + '%') THEN 1	
							 ELSE 0 END = 1	
						--ZIP		
						AND						
						CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Zip' AND LEN(PropertyValue) > 0) THEN 1 
							 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Zip' AND LEN(PropertyValue) > 0) AND
								  LTRIM(COALESCE(fbic.fbic_zip,'')) LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Zip') + '%') THEN 1	
							 ELSE 0 END = 1
						--PREFERRED
						AND						
						CASE WHEN NOT EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Preferred' AND LEN(PropertyValue) > 0) THEN 1 
							 WHEN EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Preferred' AND LEN(PropertyValue) > 0) AND
								  COALESCE(fbic.fbic_preferred,'N') LIKE ((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Preferred') + '%') THEN 1
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
GRANT EXECUTE ON  [dbo].[SearchAPI_FreightBoardCities] TO [public]
GO
