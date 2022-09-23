SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[import_zipcodedownload]
AS

/**
 * 
 * NAME:
 * import_zipcodedownload
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Import Zip Codes from an External File
 *
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * zippo
 *
 * PARAMETERS:
 *	NONE
 *
 * REFERENCES:
 * 001 - Commercial Table. Created from a DTS job that takes and external file and copies the data
 *	into the commercial table.
 * 
 * REVISION HISTORY:
 * 10/04/2005 - DJM - PTS 28912 - Stop using the cty_timezone. Remove any references, since it is to be dropped from the database.
 *
 **/


SET NoCount ON

DECLARE
	  @ctycode int
	, @ctynmstct varchar(64)
	, @counter int
	, @zipcode varchar(10)
	, @zipcodetype char(1)
	, @city varchar(18)
	, @citytype char(1)
	, @county varchar(18)
	, @countyfips int
	, @statecode char(2)
	, @statefips int
	, @msa int
	, @areacode char(3)
	, @timezone varchar(24)
	, @GMTOffset float
	, @DST char(1)
	, @Latitude decimal(8,4)
	, @Longitude decimal(8,4)
	, @MatchCount int
	, @MatchCountALK int
	, @msg varchar(255)
	, @batch int
	, @batchdate datetime
	, @country varchar(6)
	, @zipforcounty varchar(3)
	, @cityzipcnt	int

EXECUTE @batch = getsystemnumber 'BATCHQ', ''
SET @batchdate = GetDate()

update commercial set gmtoffset = -3.5 where timezone = 'Newfoundland' and gmtoffset is null
update commercial set gmtoffset = -4 where timezone = 'Atlantic' and gmtoffset is null
update commercial set gmtoffset = -5 where timezone = 'Eastern' and gmtoffset is null
update commercial set gmtoffset = -6 where timezone = 'Central' and gmtoffset is null
update commercial set gmtoffset = -7 where timezone = 'Mountain' and gmtoffset is null
update commercial set gmtoffset = -8 where timezone = 'Pacific' and gmtoffset is null

UPDATE city
SET cty_zip = ''
	, cty_latitude = 0
	, cty_longitude = 0
	, cty_areacode = ''
WHERE cty_zip <> ''
  or cty_latitude <> 0
  or cty_longitude <> 0
  or cty_areacode <> ''

--TRUNCATE TABLE cityzip
-- PTS 20289 - DJM - modidified app to NOT truncate, but update, insert or delete.
/*DELETE cityzip
FROM city
WHERE cityzip.cty_code = city.cty_code
AND cty_country in ('USA','CAN')	*/

	
DECLARE imported_zips CURSOR 
FOR 
SELECT 
	  zipcode
	, zipcodetype
	, LEFT(city, 18)
	, citytype
	, county
	, CAST(countyfips AS INT)
	, statecode
	, CAST(statefips AS INT)
	, msa
	, areacode
	, timezone
	, GMTOffset
	, DST
	, CAST(Latitude AS DECIMAL (8, 4))
	, CAST(Longitude AS DECIMAL (8, 4))
FROM commercial

SELECT   @ctynmstct = '', @ctycode = 0, @counter = 0
OPEN imported_zips
FETCH imported_zips 
INTO	  @zipcode
	, @zipcodetype
	, @city
	, @citytype
	, @county
	, @countyfips
	, @statecode
	, @statefips
	, @msa
	, @areacode
	, @timezone
	, @GMTOffset
	, @DST
	, @Latitude
	, @Longitude
		
WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @counter= @counter + 1
		SELECT @ctycode = 0

		IF @county IS NULL
			SELECT @country = 'CAN'
			, @zipforcounty = ''
		ELSE
			SELECT @country = 'USA'
			, @zipforcounty = LEFT(ISNULL(@zipcode, ''), 3)

		IF @country = 'USA' /* may be duplicate city+state combinations */
		BEGIN
			/* First see if already have a city with matching zip code in the county column */
			SELECT @ctycode = cty_code FROM city WHERE cty_name = @city AND cty_state = @statecode AND cty_county = LEFT(@zipcode, 3)
			/* Failing that, next find city that has been used on a company with same zip (3-digit) */
			IF @ctycode = 0 
				SELECT @ctycode = MIN(cty_code) 
				FROM city, company
				WHERE city.cty_code = company.cmp_city
				  AND city.cty_name = @city 
				  AND city.cty_state = @statecode
				  AND LEFT(company.cmp_zip, 3) = LEFT(@zipcode, 3)
			/* Failing that, next find city that matches on left 2 chars of county */
			IF @ctycode = 0
				SELECT @ctycode = MIN(cty_code) FROM city WHERE cty_name = @city AND cty_state = @statecode AND LEFT(cty_county , 2) = LEFT(@county, 2) --ISNUMERIC(cty_county) = 0
		END
		ELSE /*canadian*/
		BEGIN
			SELECT @ctycode = cty_code FROM city WHERE cty_name = @city AND cty_state = @statecode
		END

		SELECT @msg = 'COUNTER=' + CAST(@counter AS CHAR(6)) + ' ctycode=' + cast(@ctycode as char(6)) + ' city=' + @city + ' state=' + @statecode + ' county=' + UPPER(LEFT(ISNULL(@county, ''), 2))
		PRINT @msg

		IF @ctycode > 0
			BEGIN
			UPDATE 	city
			SET	  cty_zip = @zipcode
				, county_name = @county
				--, cty_county = UPPER(LEFT(ISNULL(@county, ''), 2))
				, cty_countyfips = @countyfips
				, cty_statefips = @statefips
				, cty_msa = @msa
				, cty_areacode = @areacode
				--, cty_timezone = @timezone
				, cty_GMTDelta = -@GMTOffset
				, cty_DSTApplies = @DST
				, cty_latitude = @latitude
				, cty_longitude = -@longitude
				, cty_country = @country
			WHERE cty_code = @ctycode
		
			-- PTS 20289 - DJM - Verify that the CityZip does not exist before Insert
			if not exists (select * from cityzip where cty_code = @ctycode and zip = @zipcode)
				INSERT INTO cityzip (
					  zip
					, cty_code
					, cty_nmstct
					, cz_latitude
					, cz_longitude
					, cz_county
					, cz_countyfips
					, cz_zipcodetype )
				VALUES (
					  @zipcode
					, @ctycode
					, LEFT(@city, 18) + ',' + @statecode + '/' + @zipforcounty
					, @Latitude
					, -@Longitude
					, @county
					, @countyfips
					, @zipcodetype )				
			ELSE
				UPDATE cityzip
				SET	  cz_latitude = @Latitude
						, cz_longitude = -@Longitude
						, cz_county = @county
						, cz_countyfips = @countyfips
						, cz_zipcodetype = @zipcodetype
				WHERE cty_code = @ctycode and zip = @zipcode
			END	
		ELSE
			BEGIN
			EXECUTE @ctycode = getsystemnumber 'CTYNUM', ''
			INSERT INTO CITY (
				  cty_code
				, cty_name
				, cty_state
				, cty_zip
				, cty_areacode
				, cty_county				
				, cty_latitude
				, cty_longitude
				, cty_region1
				, cty_region2
				, cty_region3
				, cty_region4
				, cty_updatedby
				, cty_updateddate
				, cty_createdate
				, cty_GMTDelta
				, cty_DSTApplies
				, county_name
				, cty_countyfips
				, cty_statefips
				, cty_msa
				--, cty_timezone 
				, cty_country)
			VALUES (
				  @ctycode
				, @city
				, @statecode
				, @zipcode
				, @areacode
--				, ISNULL(LEFT(@zipcode, 3), '')
				, @zipforcounty
				, @latitude
				, -@longitude
				, 'UNK'
				, 'UNK'
				, 'UNK'
				, 'UNK'
				, 'ZIPCODEDOWNLOAD'
				, @BatchDate
				, @BatchDate
				, -@GMTOffset
				, @dst
				, ISNULL(@county,'')
				, @countyfips
				, @statefips
				, @msa
				--, @timezone 
				, @country)

			if not exists (select * from cityzip where zip = @zipcode and cty_code = @ctycode) 
				Begin
					INSERT INTO cityzip (
						  zip
						, cty_code
						, cty_nmstct
						, cz_latitude
						, cz_longitude
						, cz_county
						, cz_countyfips
						, cz_zipcodetype )
					VALUES (
						  @zipcode
						, @ctycode
						, LEFT(@city, 18) + ',' + @statecode + '/' + @zipforcounty
						, @Latitude
						, -@Longitude
						, @county
						, @countyfips
						, @zipcodetype )
		
					SET @msg = 'Insert new city: ' + @city + ', ' + @statecode + ' ' + ISNULL(@county, '') + ' Zip Code: ' + @zipcode + ' City Code: ' + CAST(@ctycode AS VARCHAR(8))
					INSERT INTO tts_errorlog (
						  err_batch
						, err_user_id
						, err_message
						, err_date
						, err_number
						, err_title )
					VALUES (
						  @batch
						, 'ZIPCODEDL'
						, @msg
						, @BatchDate
						, 51001
						, 'Zip Code Download: Inserting new CityZip record.' )
					
				End
			Else
				Begin
					SET @msg = 'Unable to Insert new city/Zip. Record already exists: ' + @city + ', ' + @statecode + ' ' + ISNULL(@county, '') + ' Zip Code: ' + @zipcode + ' City Code: ' + CAST(@ctycode AS VARCHAR(8))
	
					UPDATE cityzip
					SET	  cz_latitude = @Latitude
							, cz_longitude = -@Longitude
							, cz_county = @county
							, cz_countyfips = @countyfips
							, cz_zipcodetype = @zipcodetype
					WHERE cty_code = @ctycode and zip = @zipcode
					
	
	
		
				End
			End
		IF @country = 'USA'
			UPDATE city
			SET cty_county = LEFT(@zipcode, 3)
			WHERE cty_code = @ctycode
			AND ISNUMERIC(cty_county) = 0
		ELSE
		IF @country = 'CAN'
			UPDATE city
			SET cty_county = ''
			WHERE cty_code = @ctycode
			AND cty_county <> ''
	
		FETCH imported_zips 
		INTO  @zipcode
			, @zipcodetype
			, @city
			, @citytype
			, @county
			, @countyfips
			, @statecode
			, @statefips
			, @msa
			, @areacode
			, @timezone
			, @GMTOffset
			, @DST
			, @Latitude
			, @Longitude
	END

CLOSE imported_zips
DEALLOCATE imported_zips

/* PTS 20289 - DJM - Delete from the CityZip table any CityZip combinations that are not
	in the Temp table									*/
Delete from cityzip
where not exists (select 1 from commercial c, city cty
		where cityzip.cty_code = cty.cty_code
			and cty.cty_name = left(c.city, 18)
			and cty.cty_state = c.statecode
			and cityzip.zip = c.zipcode
			AND cty_state <> 'MX')

UPDATE city SET cty_nmstct = cty_name + ',' + cty_state + '/' + cty_county
WHERE cty_county IS NOT NULL

UPDATE city SET cty_fuelcreate = 1
WHERE NOT EXISTS (SELECT 1 FROM commercial WHERE LEFT(city, 18) = cty_name AND statecode = cty_state)
AND (cty_fuelcreate IS NULL or cty_fuelcreate <> 1)
AND cty_state <> 'MX'

INSERT INTO tts_errorlog(
	  err_batch
	, err_user_id
	, err_message
	, err_date
	, err_number
	, err_title )
SELECT @batch
	, 'ZIPCODEDL'
	, 'ID: ' + cmp_id + ' Name: ' + cmp_name + ' City: ' + company.cty_nmstct + ' Zip: ' + company.cmp_zip + ' City Code: ' + CAST(company.cmp_city AS VARCHAR(8))
	, @BatchDate
	, 51002
	, 'Zip Code Download: Company with invalid or missing zip code.'
FROM company
WHERE cmp_id <> 'UNKNOWN'
  AND NOT EXISTS (SELECT * FROM cityzip WHERE company.cmp_city = cityzip.cty_code)

SELECT err_title
	, err_message
FROM tts_errorlog
WHERE err_batch = @batch
ORDER BY err_number, err_message

SET NoCount OFF

GO
GRANT EXECUTE ON  [dbo].[import_zipcodedownload] TO [public]
GO
