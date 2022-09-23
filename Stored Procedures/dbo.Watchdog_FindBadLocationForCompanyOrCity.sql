SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Watchdog_FindBadLocationForCompanyOrCity]
		@MinThreshold FLOAT = 14,
		@MinsBack INT = -44640, -- 31 days
		@TempTableName VARCHAR(255) = '##WatchDogGlobalFindBadLocationForCompanyOrCity',
		@WatchName VARCHAR(255)='WatchFindBadLocationForCompanyOrCity',
		@ThresholdFieldName VARCHAR(255) = null,
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@CompanyOrCityMode varchar(10) = 'COMPANY', -- 'COMPANY', 'CITY', 'BOTH'
		@RegionMode varchar(12) = 'US',  -- USA=Continental USA, CANADA, MEXICO, LOOP
		@CompanyLatLongUnitsOveride char(1) = '',
		@CityLatLongUnitsOveride char(1) = '',
		@LimitToOpenLegsYN char(1) = 'Y'

AS
	SET NOCOUNT ON

	--Reserved/Mandatory WatchDog Variables
	DECLARE @SQL VARCHAR(8000)
	DECLARE @COLSQL VARCHAR(4000)
	--Reserved/Mandatory WatchDog Variables	

	DECLARE @STATELIST VARCHAR(500) 

	DECLARE @curRegion varchar(100), @idxRegion int, @idxComma int, @idxStateList int, @idxStateListEnd int, @idxComma2 int
	DECLARE @LIMITS varchar(4000)

	DECLARE @LatitudeMax decimal(20,8), @LatitudeMin decimal(20,8), @LongitudeMax decimal(20,8), @LongitudeMin decimal(20,8)
	DECLARE @stemp varchar(3000)

	CREATE TABLE #tempResults (
		RegionMode varchar(10),
		CompanyOrCity varchar(10),
		Lookup varchar(100),
		Latitude decimal(20, 4),
		Longitude decimal(20, 4),
		LatitudeMin varchar(30), -- decimal(20, 4),
		LatitudeMax varchar(30), -- decimal(20, 4), 
		LongitudeMin varchar(30), -- decimal(20, 4),
		LongitudeMax varchar(30), -- decimal(20, 4)
		cty_code int,
		cmp_id varchar(8)
	)		
	/* OUTPUT FIELDS
		[CompanyOrCity], 
		[Lookup] either CLESPW01 / Fullname or Cleveland, OH/cuyahoga, 
		Latitude,
		Logitude,
		LatitudeMin, LatitudeMax, LongitudeMin, LongitudeMax
	*/


	-- Region=[Region name],STATELIST=[List of valid states]/STATELIST,[LatMax],[LatMin],[LongMax],[LongMin],
	SET @LIMITS = 
		'Region=US,STATELIST=AL,AR,AZ,CA,CO,CT,DC,DE,FL,GA,IA,ID,IL,IN,KS,KY,LA,MA,MD,ME,MI,MN,MO,MS,MT,NC,ND,NE,NH,NJ,NM,'
			+ 'NV,NY,OH,OK,OR,PA,RI,SC,SD,TN,TX,UT,VA,VT,WA,WI,WV,WY/STATELIST,50,24.5,125,66,'
	  + 'Region=AL,STATELIST=AL/STATELIST, 35.05, 30.2, 88.5, 84.89, '
	  + 'Region=AR,STATELIST=AR/STATELIST, 36.53, 33, 94.65, 89.63, '
	  + 'Region=AZ,STATELIST=AZ/STATELIST, 37.03, 31.34, 114.95, 109.05, '
	  + 'Region=CA,STATELIST=CA/STATELIST, 42.02, 32.47, 124.45, 114.05, '
	  + 'Region=CO,STATELIST=CO/STATELIST, 41.05, 36.98, 109.1, 102, '
	  + 'Region=CT,STATELIST=CT/STATELIST, 42.08, 41.00, 74, 71.77, '
	  + 'Region=IL,STATELIST=IL/STATELIST, 42.53, 37, 91.56, 87.45, '
	  + 'Region=MA,STATELIST=MA/STATELIST, 42.9, 41.24, 73.51, 69.92, '
	  + 'Region=ME,STATELIST=ME/STATELIST, 47.5, 43.05, 71.1, 66.9, '
	  + 'Region=MS,STATELIST=MS/STATELIST, 35.05, 30.1, 91.7, 88.07, '
	  + 'Region=NH,STATELIST=NH/STATELIST, 45.32, 42.68, 72.589, 70.686, '
	  + 'Region=NY,STATELIST=NY/STATELIST, 45.04, 40.5, 79.8, 71.85, '
      + 'Region=OH,STATELIST=OH/STATELIST, 42.03, 38.4, 85, 80.5, '
      + 'Region=PA,STATELIST=PA/STATELIST, 42.3, 39.71, 80.58, 73.9, '  
	  + 'Region=VT,STATELIST=VT/STATELIST, 45.05, 42.74, 73.46, 71.55, '
	DECLARE @ProtectionLimitForUserChangingStateDefs int
	SET @ProtectionLimitForUserChangingStateDefs = 1
	SET @idxRegion = 0

	IF ISNULL(@RegionMode, '') <> '' AND ISNULL(@RegionMode, '') <> 'LOOP'
		SET @idxRegion = CHARINDEX('Region=' + @RegionMode, @LIMITS, @idxRegion)	-- Find the region definition code.
	ELSE
		SET @idxRegion = CHARINDEX('Region=', @LIMITS, @idxRegion)	-- Find the region definition code.

	WHILE @idxRegion > 0
	BEGIN

		SET @idxComma = CHARINDEX(',', @LIMITS, @idxRegion + 1) 		-- Find the comma at the end of the region definition.
		SET @curRegion = SUBSTRING(@LIMITS, @idxRegion + LEN('Region='), @idxComma - @idxRegion - LEN('Region='))
		SET @idxStateList = CHARINDEX('STATELIST=', @LIMITS, @idxComma + 1)
		SET @idxComma = CHARINDEX(',', @LIMITS, @idxStateList + 1)
		SET @idxStateListEnd = CHARINDEX('/STATELIST', @LIMITS, @idxStateList + 1)
		SET @StateList = ',' + SUBSTRING(@LIMITS, @idxStateList + LEN('STATELIST='), @idxStateListEnd - @idxStateList - LEN('/STATELIST') ) + ','

		-- Get LatitudeMax
		SET @idxComma = CHARINDEX(',', @LIMITS, @idxStateListEnd + LEN('/STATELIST')) -- Get the comma after the '/STATELIST'.
		SET @idxComma2 = CHARINDEX(',', @LIMITS, @idxComma + 1) -- Get the comma after first comma
		SET @sTemp = SUBSTRING(@LIMITS, @idxComma + 1, @idxComma2 - @idxComma - 1) 	
		SET @LatitudeMax = CONVERT(decimal(20, 4), @sTemp) 	-- Most northern point for this region 

		-- Get LatitudeMin
		SET @idxComma = CHARINDEX(',', @LIMITS, @idxComma2) -- Get next comma 
		SET @idxComma2 = CHARINDEX(',', @LIMITS, @idxComma + 1) -- Get the comma after first comma
		SET @sTemp = SUBSTRING(@LIMITS, @idxComma + 1, @idxComma2 - @idxComma - 1) 	
		SET @LatitudeMin = CONVERT(decimal(20, 4), @sTemp) 	-- Most sorthern point for this region 

		-- Get LongitudeMax
		SET @idxComma = CHARINDEX(',', @LIMITS, @idxComma2) -- Get next comma 
		SET @idxComma2 = CHARINDEX(',', @LIMITS, @idxComma + 1) -- Get the comma after first comma
		SET @sTemp = SUBSTRING(@LIMITS, @idxComma + 1, @idxComma2 - @idxComma - 1) 	
		SET @LongitudeMax = CONVERT(decimal(20, 4), @sTemp) 	-- Most western point for this region 

		-- Get LongitudeMin
		SET @idxComma = CHARINDEX(',', @LIMITS, @idxComma2) -- Get next comma 
		SET @idxComma2 = CHARINDEX(',', @LIMITS, @idxComma + 1) -- Get the comma after first comma
		SET @sTemp = SUBSTRING(@LIMITS, @idxComma + 1, @idxComma2 - @idxComma - 1) 	
		SET @LongitudeMin = CONVERT(decimal(20, 4), @sTemp) 	-- Most eastern point for this region 

		SET @idxRegion = CHARINDEX('Region=', @LIMITS, @idxRegion + 1)

		IF @CompanyOrCityMode = 'COMPANY' OR @CompanyOrCityMode = 'BOTH'
		BEGIN
			-- Get the General Info settings.
			DECLARE @gi_CompanyLatLongUnits varchar(30)
			IF ISNULL(@CompanyLatLongUnitsOveride, '') = '' 
				SELECT @gi_CompanyLatLongUnits = gi_string1 FROM generalinfo (NOLOCK) WHERE gi_name = 'CompanyLatLongUnits'
			ELSE
				SELECT @gi_CompanyLatLongUnits = @CompanyLatLongUnitsOveride
	
			DECLARE @COMPANY_SECONDS_MULTIPLIER int
			IF @gi_CompanyLatLongUnits = 's' 
				SELECT @COMPANY_SECONDS_MULTIPLIER = 3600
			ELSE 
				SELECT @COMPANY_SECONDS_MULTIPLIER = 1
	
			DECLARE @LatitudeMaxCmp decimal(20,8), @LatitudeMinCmp decimal(20,8), @LongitudeMaxCmp decimal(20,8), @LongitudeMinCmp decimal(20,8)
			SELECT @LatitudeMaxCmp = @LatitudeMax * @COMPANY_SECONDS_MULTIPLIER  
			SELECT @LatitudeMinCmp = @LatitudeMin * @COMPANY_SECONDS_MULTIPLIER  
			SELECT @LongitudeMaxCmp = @LongitudeMax * @COMPANY_SECONDS_MULTIPLIER
			SELECT @LongitudeMinCmp = @LongitudeMin * @COMPANY_SECONDS_MULTIPLIER 
			
			INSERT INTO #tempResults (RegionMode, CompanyOrCity, Lookup, Latitude, Longitude, LatitudeMin, LatitudeMax, LongitudeMin, LongitudeMax, cty_code, cmp_id)
			SELECT @curRegion, 'Company',  cmp_id + ' / ' + ISNULL(cmp_name, '') + ' (' + ISNULL(cmp_state, '') + ')', 
				cmp_latseconds, cmp_longseconds ,
				CONVERT(varchar(30), CONVERT(decimal(12, 2), @LatitudeMinCmp)) + CASE WHEN ISNULL(cmp_latseconds, 0) < @LatitudeMinCmp THEN '-XXX' ELSE '' END AS 'LatitudeMin', 
				CONVERT(varchar(30), CONVERT(decimal(12, 2), @LatitudeMaxCmp)) + CASE WHEN ISNULL(cmp_latseconds, 0) > @LatitudeMaxCmp THEN '-XXX' ELSE '' END AS 'LatitudeMax', 
				CONVERT(varchar(30), CONVERT(decimal(12, 2), @LongitudeMinCmp)) + CASE WHEN ISNULL(cmp_longseconds, 0) < @LongitudeMinCmp THEN '-XXX' ELSE '' END AS 'LongitudeMin', 
				CONVERT(varchar(30), CONVERT(decimal(12, 2), @LongitudeMaxCmp)) + CASE WHEN ISNULL(cmp_longseconds, 0) > @LongitudeMaxCmp THEN '-XXX' ELSE '' END AS 'LongitudeMax',
				-1, cmp_id
			FROM company (NOLOCK) 
			WHERE 
				CHARINDEX(',' + ISNULL(cmp_state, 'UNKNOWN') + ',', @STATELIST) > 0
				AND 
				(cmp_latseconds is not null OR cmp_longseconds is not null)
				AND (	ISNULL(cmp_latseconds, 0) < @LatitudeMinCmp 
					OR 	ISNULL(cmp_latseconds, 0) > @LatitudeMaxCmp
					OR	ISNULL(cmp_longseconds, 0) < @LongitudeMinCmp 
					OR 	ISNULL(cmp_longseconds, 0) > @LongitudeMaxCmp
					)
		END	

		IF @CompanyOrCityMode = 'CITY' OR @CompanyOrCityMode = 'BOTH'
		BEGIN
			DECLARE @gi_CityLatLongUnits varchar(30)
			IF ISNULL(@CityLatLongUnitsOveride, '') = '' 
				SELECT @gi_CityLatLongUnits = gi_string1 FROM generalinfo (NOLOCK) WHERE gi_name = 'CityLatLongUnits' 
			ELSE
				SELECT @gi_CityLatLongUnits = @CityLatLongUnitsOveride 
	
			DECLARE @CITY_SECONDS_MULTIPLIER int
			IF @gi_CityLatLongUnits = 's' 
				SELECT @CITY_SECONDS_MULTIPLIER = 3600
			ELSE 
				SELECT @CITY_SECONDS_MULTIPLIER = 1
		
			DECLARE @LatitudeMaxCty decimal(20,8), @LatitudeMinCty decimal(20,8), @LongitudeMaxCty decimal(20,8), @LongitudeMinCty decimal(20,8)

			SELECT @LatitudeMaxCty = @LatitudeMax * @CITY_SECONDS_MULTIPLIER  
			SELECT @LatitudeMincty = @LatitudeMin * @CITY_SECONDS_MULTIPLIER  
			SELECT @LongitudeMaxCty = @LongitudeMax * @CITY_SECONDS_MULTIPLIER
			SELECT @LongitudeMinCty = @LongitudeMin * @CITY_SECONDS_MULTIPLIER 
	
			INSERT INTO #tempResults (RegionMode, CompanyOrCity, Lookup, Latitude, Longitude, LatitudeMin, LatitudeMax, LongitudeMin, LongitudeMax, cty_code, cmp_id)
			SELECT @curRegion, 'City', ISNULL(cty_name, '') + ', ' + ISNULL(cty_state, '') + '/' + ISNULL(cty_county, '') + ' (' + CONVERT(varchar(12), cty_code) + ')', 
				cty_latitude, cty_longitude ,
				CONVERT(varchar(30), CONVERT(decimal(12, 2), @LatitudeMinCty)) + CASE WHEN ISNULL(cty_latitude, 0) < @LatitudeMinCty THEN '-XXX' ELSE '' END AS 'LatitudeMin', 
				CONVERT(varchar(30), CONVERT(decimal(12, 2), @LatitudeMaxCty)) + CASE WHEN ISNULL(cty_latitude, 0) > @LatitudeMaxCty THEN '-XXX' ELSE '' END AS 'LatitudeMax', 
				CONVERT(varchar(30), CONVERT(decimal(12, 2), @LongitudeMinCty)) + CASE WHEN ISNULL(cty_longitude, 0) < @LongitudeMinCty THEN '-XXX' ELSE '' END AS 'LongitudeMin', 
				CONVERT(varchar(30), CONVERT(decimal(12, 2), @LongitudeMaxCty)) + CASE WHEN ISNULL(cty_longitude, 0) > @LongitudeMaxCty THEN '-XXX' ELSE '' END AS 'LongitudeMax',
				cty_code, ''
			FROM city (NOLOCK) 
			WHERE 
				CHARINDEX(',' + ISNULL(cty_state, 'UNKNOWN') + ',', @STATELIST) > 0
				AND 
				(cty_latitude is not null OR cty_longitude is not null)
				AND (	ISNULL(cty_latitude, 0) < @LatitudeMinCty 
					OR 	ISNULL(cty_latitude, 0) > @LatitudeMaxCty
					OR	ISNULL(cty_longitude, 0) < @LongitudeMinCty
					OR 	ISNULL(cty_longitude, 0) > @LongitudeMaxCty
					)
		END

		IF ISNULL(@RegionMode, '') <> '' AND ISNULL(@RegionMode, '') <> 'Loop' SET @idxRegion = -2

		-- End of loop. Put protection here in case someone changes definition files incorrectly.
		SET @ProtectionLimitForUserChangingStateDefs = @ProtectionLimitForUserChangingStateDefs + 1
		IF @ProtectionLimitForUserChangingStateDefs > 1000 SELECT @idxRegion = -1
	END
	IF @idxRegion = -1 RAISERROR('May be a problem in boundary definitions.', 16, 1)

	IF @LimitToOpenLegsYN = 'Y'
	BEGIN
		DELETE #TempResults
		WHERE CompanyOrCity = 'Company'
			AND NOT EXISTS(SELECT *
				FROM legheader_active t1 (NOLOCK), stops t2 (NOLOCK)
				WHERE t1.lgh_number = t2.lgh_number
					AND lgh_outstatus IN ('STD', 'AVL', 'DSP', 'PLN')
					AND t2.cmp_id = #tempResults.cmp_id)

		DELETE #TempResults
		WHERE CompanyOrCity = 'City'
			AND NOT EXISTS(SELECT *
				FROM legheader_active t1 (NOLOCK), stops t2 (NOLOCK)
				WHERE t1.lgh_number = t2.lgh_number
					AND lgh_outstatus IN ('STD', 'AVL', 'DSP', 'PLN')
					AND t2.stp_city = #tempResults.cty_code)
	END

	--Commits the results to be used in the wrapper
	IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
	BEGIN
		SET @SQL = 'SELECT * FROM #TempResults ORDER BY CompanyOrCity, RegionMode'
	END
	ELSE
	BEGIN
		SET @COLSQL = ''
		EXEC WatchDogColumnNames @WatchName=@WatchName, @ColumnMode=@ColumnMode, @SQLForWatchDog=1, @SELECTCOLSQL = @COLSQL OUTPUT
		SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
	END
	
	EXEC (@SQL)

	SET NOCOUNT OFF
GO
