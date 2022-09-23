SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 09/28/05 DWG  Created. Current Position View Stored Procedure.
 * 09/08/14 ZAB - MODIFIED. PTS# 82341 - Changed @sDriverID from varchar(6) to varchar(13)
 * 09/21/15 JJN	- MODIFIED. PTS# 89286 - Added optimizations suggested by Mindy Curnutt
*/

/** Flags **/
-- +1	No Addresses On Locations: Location values are not to include Address information (they will only have city, state info).  
--		This setting is meant for sites without PC*Miler Streets.

CREATE PROCEDURE [dbo].[tmail_CurrentPosition] (@sTractorID varchar(13),
												@sDriverID varchar(13),
												@sFlags varchar(10))

AS

SET NOCOUNT ON 

DECLARE @fltResult decimal(7, 4), @lFlags int, @lNoAddressOnLocation int, @dteCompareDate datetime

SET @lFlags = convert(int, @sFlags)

SET @lNoAddressOnLocation = 0
if (@lFlags & 1) <> 0 
	SET @lNoAddressOnLocation = 1

IF ISNULL(@sTractorID, '') = 'UNKNOWN' SELECT @sTractorID = ''
IF ISNULL(@sDriverID, '') = 'UNKNOWN' SELECT @sDriverID = ''

IF ISNULL(@sTractorID, '') = '' AND ISNULL(@sDriverID, '') = ''
	BEGIN
	RAISERROR ('Tractor ID or Driver ID must be specified', 16, 1)
	RETURN
	END

--Get Last Check call information
DECLARE @dteMaxCheckCallDate datetime,
		@lLastLatitude int, 
		@lLastLongitude int, 
		@sLastLocation varchar(500),
		@dteLastGPSDate datetime, 
		@sLastGPSLocation varchar(20),
		@lLastGPSCheckcallNumber int

--PTS 89286 JJN - Implement changes suggested by Mindy Curnutt
IF ISNULL(@sTractorID, '') = ''
	SELECT @dteMaxCheckCallDate = MAX(ckc_date)
	FROM CheckCall (NOLOCK)
	WHERE ckc_asgntype = 'DRV'
	AND ckc_asgnid = @sDriverID
	AND (ISNULL(ckc_latseconds, 0) <> 0 OR ISNULL(ckc_longseconds, 0) <> 0)
ELSE
	SELECT @dteMaxCheckCallDate = MAX(ckc_date)
	FROM CheckCall (NOLOCK)
	WHERE ckc_asgntype = 'DRV'
	AND ckc_Tractor = @sTractorID
	AND (ISNULL(ckc_latseconds, 0) <> 0 OR ISNULL(ckc_longseconds, 0) <> 0)

IF ISNULL(@dteMaxCheckCallDate, '19500101') > '19500101' 
	BEGIN
		SELECT @lLastGPSCheckcallNumber = max(ckc_number)
			FROM CheckCall (NOLOCK)
			WHERE ckc_asgntype = 'DRV'
				AND CASE ISNULL(@sTractorID, '') WHEN '' THEN ckc_asgnid ELSE ckc_Tractor END = 
						CASE ISNULL(@sTractorID, '') WHEN '' THEN @sDriverID ELSE @sTractorID END
				AND ckc_date = @dteMaxCheckCallDate
	
		SELECT  @lLastLatitude = ckc_latseconds, 
				@lLastLongitude = ckc_longseconds, 
				@dteLastGPSDate = ckc_date 
			FROM CheckCall (NOLOCK)
			WHERE ckc_number = @lLastGPSCheckcallNumber 
	END

IF ISNULL(@lLastLatitude, 0) <> 0 OR ISNULL(@lLastLongitude, 0) <>  0
	BEGIN
		SET @fltResult = @lLastLatitude / 3600.
		SET @sLastGPSLocation = RTRIM(LTRIM(CONVERT(varchar(8), @fltResult)))
		if @lLastLatitude < 0 
			SET @sLastGPSLocation = @sLastGPSLocation + 'S'
		else
			SET @sLastGPSLocation = @sLastGPSLocation + 'N'
		SET @fltResult = @lLastLongitude / 3600.
		SET @sLastGPSLocation = @sLastGPSLocation + ',' + RTRIM(LTRIM(CONVERT(varchar(8), @fltResult)))
		if @lLastLongitude < 0 
			SET @sLastGPSLocation = @sLastGPSLocation + 'E'
		else
			SET @sLastGPSLocation = @sLastGPSLocation + 'W'
	END

--Get Last Stop information
DECLARE @sAsgnType varchar(6), @sAsgnID varchar(20)
DECLARE @dtAsgnDate datetime, @lLastStopNum int,
		@dteMaxArrivalDate datetime,
		@lLastStopLgh int,
		@sLastStopLocation varchar(500),
		@sLastStopAddress varchar(40),
		@sLastStopCmpID varchar(25), --PTS 61189 change cmp_id fields to 25 length
		@sLastStopCity varchar(18),
		@sLastStopState varchar(6),
		@sLastStopZip varchar(10),
		@dteLastStopEventDate datetime

if ISNULL(@sTractorID, '')='' 
	SELECT @sAsgnID = @sDriverID, @sAsgnType = 'DRV'
ELSE
	SELECT @sAsgnID = @sTractorID, @sAsgnType = 'TRC'

SELECT @dtAsgnDate = MAX(asgn_date)
	FROM assetassignment a (NOLOCK) 
	WHERE a.asgn_id = @sAsgnID and a.asgn_type = @sAsgnType
	AND (a.asgn_status = 'STD' or a.asgn_status = 'CMP')

IF ISNULL(@dtAsgnDate, '19500101')>'19500101'
	SELECT @lLastStopLgh = MAX(lgh_number)
		FROM assetassignment a (NOLOCK)
		WHERE a.asgn_id = @sAsgnID and a.asgn_type = @sAsgnType and a.asgn_date = @dtAsgnDate
		AND (a.asgn_status = 'STD' or a.asgn_status = 'CMP')

IF ISNULL(@lLastStopLgh, 0)>0
	SELECT @dteMaxArrivalDate = MAX(stp_arrivaldate)
		FROM stops s (NOLOCK)
		WHERE s.lgh_number = @lLastStopLgh 
		AND stp_Status = 'DNE'

IF ISNULL(@dteMaxArrivalDate, '19500101')>'19500101'
	SELECT @lLastStopNum = MAX(stp_Number)
		FROM stops s (NOLOCK)
		WHERE s.lgh_number = @lLastStopLgh 
		AND stp_Status = 'DNE' AND stp_arrivaldate = @dteMaxArrivalDate 

IF ISNULL(@lLastStopNum, 0)<>0
	SELECT  @sLastStopAddress = stp_Address,
			@sLastStopCity = cty_name,
			@sLastStopState = stp_state,
			@sLastStopCmpID = cmp_id,
			@sLastStopZip = stp_zipcode,
			@dteLastStopEventDate = CASE stp_departure_status WHEN 'DNE' THEN stp_departuredate ELSE stp_ArrivalDate END
		FROM stops s  (NOLOCK)
		LEFT OUTER JOIN city c (NOLOCK) ON s.stp_city = c.cty_code
		WHERE s.stp_number = @lLastStopNum

IF ISNULL(@sLastStopAddress, '') = '' and ISNULL(@sLastStopCmpID, '')<>'' and ISNULL(@sLastStopCmpID, '')<>'UNKNOWN'
	SELECT 	@sLastStopAddress = p.cmp_address1,
			@sLastStopCity = c.cty_name,
			@sLastStopState = c.cty_state,
			@sLastStopZip = p.cmp_zip
	FROM company p
	INNER JOIN city c on p.cmp_city = c.cty_code
	WHERE p.cmp_id = @sLastStopCmpID

if ISNULL(@sLastStopCity, '') > '' AND ISNULL(@sLastStopState, '') > ''
	BEGIN
	SET @sLastStopLocation = RTRIM(LTRIM(@sLastStopCity)) + ', ' + RTRIM(LTRIM(@sLastStopState))
	if ISNULL(@sLastStopAddress, '') > '' AND @lNoAddressOnLocation <> 1
		SET @sLastStopLocation = @sLastStopLocation + ';' + RTRIM(LTRIM(@sLastStopAddress))
	END

--Get Last recongnized Checkcall information
DECLARE @sLastRecognizedLocation varchar(500), 
		@sLastRecognizedGPSLocation varchar(20),
		@lLastRecognizedLatitude int, 
		@lLastRecognizedLongitude int, 
		@sLastRecognizedCity varchar(18), 
		@sLastRecognizedState varchar(6), 
		@dteLastRecognitionDate datetime

--PTS 89286 JJN - Implement changes suggested by Mindy Curnutt
IF ISNULL(@sTractorID, '') = ''
	SELECT @dteMaxCheckCallDate = MAX(ckc_date)
	FROM CheckCall (NOLOCK)
	WHERE ckc_asgntype = 'DRV'
	AND ckc_asgnid = @sDriverID
	AND ISNULL(ckc_latseconds, 0) <> 0
	AND ISNULL(ckc_longseconds, 0) <> 0 
	AND ckc_city > 0
ELSE
	SELECT @dteMaxCheckCallDate = MAX(ckc_date)
	FROM CheckCall (NOLOCK)
	WHERE ckc_asgntype = 'DRV'
	AND ckc_Tractor = @sTractorID
	AND ISNULL(ckc_latseconds, 0) <> 0
	AND ISNULL(ckc_longseconds, 0) <> 0 
	AND ckc_city > 0

IF ISNULL(@dteMaxCheckCallDate, '') > '' 
	SELECT  @sLastRecognizedCity = cty_name, 
			@sLastRecognizedState = cty_state,
			@dteLastRecognitionDate = ckc_date,
		    @lLastRecognizedLatitude = ckc_latseconds, 
			@lLastRecognizedLongitude = ckc_longseconds
		FROM CheckCall (NOLOCK)
		INNER JOIN city (NOLOCK) ON ckc_city = cty_code
		WHERE ckc_asgntype = 'DRV'
			AND CASE ISNULL(@sTractorID, '') WHEN '' THEN ckc_asgnid ELSE ckc_Tractor END = 
					CASE ISNULL(@sTractorID, '') WHEN '' THEN @sDriverID ELSE @sTractorID END
			AND ckc_date = @dteMaxCheckCallDate

IF ISNULL(@lLastRecognizedLatitude, 0) > 0 AND ISNULL(@lLastRecognizedLongitude, 0) >  0
	BEGIN
		SET @fltResult = @lLastRecognizedLatitude / 3600.
		SET @sLastRecognizedGPSLocation = RTRIM(LTRIM(CONVERT(varchar(8), @fltResult)))
		if @lLastRecognizedLatitude < 0 
			SET @sLastRecognizedGPSLocation = @sLastRecognizedGPSLocation + 'S'
		else
			SET @sLastRecognizedGPSLocation = @sLastRecognizedGPSLocation + 'N'
		SET @fltResult = @lLastRecognizedLongitude / 3600.
		SET @sLastRecognizedGPSLocation = @sLastRecognizedGPSLocation + ',' + RTRIM(LTRIM(CONVERT(varchar(8), @fltResult)))
		if @lLastRecognizedLongitude < 0 
			SET @sLastRecognizedGPSLocation = @sLastRecognizedGPSLocation + 'W'
		else
			SET @sLastRecognizedGPSLocation = @sLastRecognizedGPSLocation + 'E'
	END

	if ISNULL(@sLastRecognizedCity, '') > '' AND ISNULL(@sLastRecognizedState, '') > ''
		SET @sLastRecognizedLocation = RTRIM(LTRIM(@sLastRecognizedCity)) + ', ' + RTRIM(LTRIM(@sLastRecognizedState))

--Return the location that is the newest
SELECT @dteCompareDate = @dteLastGPSDate, @sLastLocation = ISNULL(@sLastGPSLocation, '')

if @dteLastStopEventDate > @dteCompareDate AND ISNULL(@sLastStopLocation, '') > ''
	SELECT @sLastLocation = @sLastStopLocation, @dteCompareDate = @dteLastStopEventDate

if @dteLastRecognitionDate > @dteCompareDate AND ISNULL(@sLastRecognizedLocation, '') > ''
	SET @sLastLocation = @sLastRecognizedLocation

--Return the view fields
SELECT
		@sLastLocation LastLocation,
 		CONVERT(decimal(7, 4), @lLastLatitude/3600.) LastLatitude, 
		CONVERT(decimal(7, 4), @lLastLongitude/3600.) LastLongitude, 
		@sLastGPSLocation LastGPSLocation,
		@dteLastGPSDate LastGPSDate, 
		@sLastStopAddress LastStopAddress,
		@sLastStopCity LastStopCity,
		@sLastStopState LastStopState,
		@sLastStopZip LastStopZip,
		@sLastStopLocation LastStopLocation,
		@dteLastStopEventDate LastStopEventDate,
		@sLastRecognizedCity LastRecognizedCity, 
		@sLastRecognizedState LastRecognizedState, 
		@sLastRecognizedLocation LastRecognizedLocation, 
		@dteLastRecognitionDate LastRecognitionDate,
		@sLastRecognizedGPSLocation LastRecognizedGPSLocation

GO
GRANT EXECUTE ON  [dbo].[tmail_CurrentPosition] TO [public]
GO
