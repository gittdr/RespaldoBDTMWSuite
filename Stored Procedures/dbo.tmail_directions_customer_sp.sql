SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_directions_customer_sp] @customer_id varchar(25) --PTS 61189 CMP_ID INCREASE LENGTH TO 25
AS
/* Directions to Customer ********************************************************
** Used for retrieving directions information 
** for a given customer 
** Called from the TotalMail Transaction 
** Server:                   
**                   	Jayesh Sahasi, Feb 28, 1997 **
** Modified:		Dan Klein 11/11/97
** 			Matt Zerefos 12/13/99 - Allow directions > 254 characters
**			Don George 3/12/02 - Added Misc1, Misc2, Misc3, Misc4, and CustomerNotesNoWrap.
**			MZ 08/02/05 - Added Lat/Longs fields
*********************************************************************************/
BEGIN

SET NOCOUNT ON

DECLARE @directions CHAR(228),  -- Closest number to 255 divisble by 38 
		@totallen smallint,
		@totalpos smallint,
		@len smallint,
		@pos smallint,	
		@poscrlf smallint	-- Position of carriage return + line feed

SELECT	cmp_id CustomerID, 
	cmp_name CustomerName, 
	ISNULL ( cmp_address1, '' ) AddressLine1, 
	ISNULL ( cmp_address2, '' ) AddressLine2, 
	cty_name City, 
	cty_state State, 
	ISNULL ( cmp_zip, '' ) Zip, 
	ISNULL ( cmp_primaryphone, '' ) Phone1, 
	ISNULL ( cmp_secondaryphone, '' ) Phone2, 
	ISNULL ( cmp_contact, '' ) Contact,
	RIGHT('00'+CONVERT(varchar(2),cmp_opens_su/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_opens_su%100),2) SundayOpenTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_opens_mo/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_opens_mo%100),2) MondayOpenTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_opens_tu/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_opens_tu%100),2) TuesdayOpenTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_opens_we/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_opens_we%100),2) WednesdayOpenTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_opens_th/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_opens_th%100),2) ThursdayOpenTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_opens_fr/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_opens_fr%100),2) FridayOpenTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_opens_sa/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_opens_sa%100),2) SaturdayOpenTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_closes_su/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_closes_su%100),2) SundayCloseTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_closes_mo/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_closes_mo%100),2) MondayCloseTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_closes_tu/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_closes_tu%100),2) TuesdayCloseTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_closes_we/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_closes_we%100),2) WednesdayCloseTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_closes_th/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_closes_th%100),2) ThursdayCloseTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_closes_fr/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_closes_fr%100),2) FridayCloseTime,
	RIGHT('00'+CONVERT(varchar(2),cmp_closes_sa/100),2) + ':' + RIGHT('00'+CONVERT(varchar(42),cmp_closes_sa%100),2) SaturdayCloseTime,
	cmp_slack_time SlackTime,
	cmp_misc1 Misc1,
	cmp_misc2 Misc2,
	cmp_misc3 Misc3,
	cmp_misc4 Misc4,
	substring(cmp_directions, 1, 2048) CustomerNotesNoWrap,
	cmp_geoloc GeoLocation,
	cmp_country Country,
	city.cty_nmstct CityState,
	cmp_faxphone Fax,
	ISNULL(LEFT(ROUND(cmp_latseconds / 3600.0 ,4), CHARINDEX('.',ROUND(cmp_latseconds / 3600.0 ,4)) + 4), '') Latitude,  -- Round and truncate to 4 decimal places
	ISNULL(LEFT(ROUND(cmp_longseconds / 3600.0 ,4), CHARINDEX('.',ROUND(cmp_longseconds / 3600.0 ,4)) + 4), '') Longitude,
	cmp_latseconds  LatitudeSec, 
	cmp_longseconds LongitudeSec,
 	LTRIM(RTRIM(city.cty_name)) + ', ' + LTRIM(RTRIM(city.cty_state)) + ';' + LTRIM(RTRIM(cmp_Address1)) LocationFullAddress,
 	LTRIM(RTRIM(city.cty_name)) + ', ' + LTRIM(RTRIM(city.cty_state)) LocationCityName,
	ISNULL(cmp_latlongverifications, 0) TimesVerified
INTO 	#temp
FROM	company (NOLOCK), city (NOLOCK) 
WHERE 	city.cty_code = company.cmp_city 
  AND 	cmp_id = @customer_id

-- Get the company directions broken into 38 character chunks
SELECT @totallen = datalength(cmp_directions)
FROM company (NOLOCK)
WHERE cmp_id = @customer_id

CREATE TABLE #t(
	cmp_id char(25),--PTS 61189 INCREASE LENGTH TO 25
	CustomerNotes char(38))

SELECT @totalpos = 1
WHILE @totalpos < @totallen
BEGIN
	SELECT 	@directions = convert (char(255),substring(cmp_directions,@totalpos,228))
	FROM	company (NOLOCK)
	WHERE	cmp_id = @customer_id

	SELECT @len = datalength(RTRIM(@directions))

	SELECT @pos = 1
	WHILE @pos < @len
	BEGIN
		SELECT @poscrlf = CHARINDEX(CHAR(13)+CHAR(10), substring(@directions, @pos, 39))
		IF ISNULL(@poscrlf, 0) > 0
		BEGIN
			INSERT #t
			VALUES (@customer_id, substring (@directions, @pos, @poscrlf - 1))
			SELECT @pos = @pos + @poscrlf + 1
		END
		ELSE
		BEGIN
			INSERT #t 
			VALUES (@customer_id, substring ( @directions, @pos, 38 ))
			
			SELECT @pos = @pos + 38
		END
	END
	
	SELECT @totalpos = @totalpos + 228
END


SELECT * 
FROM #temp
LEFT JOIN #t
ON #temp.CustomerID = #t.cmp_id

DROP TABLE #t
DROP TABLE #temp	

END    /* end of the proc    */

GO
GRANT EXECUTE ON  [dbo].[tmail_directions_customer_sp] TO [public]
GO
