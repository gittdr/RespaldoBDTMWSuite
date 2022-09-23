SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_CheckCall_Calculations]
		@Truck varchar(30),
		@Driver varchar(20),
		@TrailerCheckcall varchar(1),
		@DateAndTime varchar(30),
		@Latitude varchar(20),
		@Longitude varchar(20),
		@Flags varchar(12)
AS

SET NOCOUNT ON 

DECLARE	@Trailer varchar(20),
		@DriverHome char(1),	-- Y/N, value written to ckc_home
		@DriverLat float,		-- Latitude of drivers home
		@DriverLong float,		-- Longitude of drivers home
		@HomeLocationSN int,
		@HomeLowestMiles float,
		@HomeTerminal varchar(25), --PTS 61189 change cmp_id fields to 25 length
		@HomeArriveMiles varchar(10),	-- Number of miles to consider driver arriving home
		@HomeDepartMiles varchar(10),	-- Number of miles to consider driver leaving home
		@HomeMiles float,		-- Distance of driver from his home
		@UseAtHomeTerminals int,
		@Lat float,
		@Long float,
		@LastCkcNumber int,		-- The ckc_number of this tractor's last checkcall
		@LastCkcHome char(1),		-- The ckc_home of this tractor's last checkcall
		@LastCkcLat int,		-- The ckc_latseconds of this tractor's last checkcall
		@LastCkcLong int,		-- The ckc_longseconds of this tractor's last checkcall
		@LastCkcDate datetime,		-- The ckc_date of this tractor's last checkcall
		@LastCkcLgh int,		-- The ckc_lghnumber of this tractor's last checkcall
		@TempDate datetime,
		@TempDate2 datetime,
		@EmergencyMode int,
		@Mileage float,			-- Air miles from last checkcall to this one
		@MileDay7FromCheckcall char(1),		-- Turn on or off the floating 7 day mileage sum to ManPowerProfile
		@MilesToFinal float,		-- Air miles for all open stops on this leg
		@MinutesToFinal int,
		@NbrCheckcalls int,		-- Number of checkcalls we're processing, used to request block of ckc_numbers
	/***	@NextLastCkcNumber int,	-- The ckc_number of this tractor's next to last checkcall
		@NextLastCkcHome char(1),	-- The ckc_home of this tractor's next to last checkcall
		@NextLastCkcLat int,		-- The ckc_latseconds of this tractor's next to last checkcall
		@NextLastCkcLong int,		-- The ckc_longseconds of this tractor's next to last checkcall
		@NextLastCkcDate datetime,	-- The ckc_date of this tractor's next to last checkcall
		@NextLastCkcLgh int,		-- The ckc_lghnumber of this tractor's next to last checkcall	***/
		@ApproxMinutes int,
		@DeleteDupMiles varchar(10),	-- Number of miles to delete duplicate checkcalls within
		@Count int,
		@DeleteCkc char(1),		-- Should we delete this duplicate checkcall?
		@TestDate datetime,
		@TestHome char(1),
		@TestLat float,
		@TestLat1 float,
		@TestLgh int,
		@TestLong float,
		@TestLong1 float,
		@lgh_number int,
		@TempFloat float,
		@CkcNumber int,			-- The ckc_number of the checkcall to delete if it's a duplicate	
		@NoMiles int,
		@FleetAveMPH int,
		@LatHold float,
		@LongHold float,
		@CompanyLatLongUOM char(1),
		@TempMiles float,
		@CityLatLongUOM char(1)

	-- Create temp tables
	DECLARE	@TempTbl table (ckc_number int,
				 ckc_date datetime,
				 ckc_home char(1),
				 ckc_lghnumber int,
				 ckc_latseconds int,
				 ckc_longseconds int)

	--DWG {29933} Second At Home
	DECLARE @HomeLocations table (SN int IDENTITY,
					  HomeLat float,
	  				  HomeLong float)

	DECLARE	@MilesTbl table (stp_mfh_sequence int,
				 cmp_latseconds int,
				 cmp_longseconds int,
				 cty_latitude int,
				 cty_longitude int)

	DECLARE @DeleteTblScan table (SN int IDENTITY,
					  XfcSN int,
	  				  Tractor varchar(12),
					  DateAndTime datetime,
					  Ignition char(1),
					  TripStatus int)

	DECLARE @DeleteTbl table (SN int)

IF @EmergencyMode > 0 
	SELECT	@DriverHome = NULL,
		@Mileage = 0,
		@MilesToFinal = -1,
		@ApproxMinutes = 0,
		@MinutesToFinal = 0
ELSE
	BEGIN

		SET @EmergencyMode = 0
		SELECT @EmergencyMode = ISNULL(PATINDEX('%EMERGENCY%', gi_string1), 0)
		FROM generalinfo (NOLOCK)
		WHERE gi_name = 'TMailCkcFlags'

		SET @NoMiles = 0
		SELECT @NoMiles = ISNULL(PATINDEX('%NOMILESUMM%', gi_string1), 0)
		FROM generalinfo (NOLOCK)
		WHERE gi_name = 'TMailCkcFlags'

		SET @HomeArriveMiles = ''
		SELECT @HomeArriveMiles = gi_string1 
		FROM generalinfo (NOLOCK)
		WHERE gi_name = 'HomeArriveMiles'

		SET @HomeDepartMiles = ''
		SELECT @HomeDepartMiles = gi_string1 
		FROM generalinfo (NOLOCK)
		WHERE gi_name = 'HomeDepartMiles'

		--DWG {29933} - At Home Terminals
		SET @UseAtHomeTerminals = 0	-- Default to not using At Home Terminals
		SELECT @UseAtHomeTerminals = ISNULL(gi_integer1, 0)
		FROM generalinfo (NOLOCK)
		WHERE gi_name =  'UseAtHomeTerminals'

		SET @MileDay7FromCheckcall = 'Y'  -- default to calc floating 7 day total
		SELECT @MileDay7FromCheckcall = ISNULL(gi_string1, 'Y')
		FROM generalinfo
		WHERE gi_name =  'MileDay7FromCheckcall'

		SET @DeleteDupMiles = ''
		SELECT @DeleteDupMiles = gi_string1 
		FROM generalinfo (NOLOCK)
		WHERE gi_name = 'CheckcallDupDeleteMiles'

		SET @FleetAveMPH = 50
		SELECT @FleetAveMPH = ISNULL(gi_integer1, 50)
		FROM generalinfo (NOLOCK)
		WHERE gi_name =  'FleetAvgMilesPerHour'

		SET @CompanyLatLongUOM = 'S'
		SELECT @CompanyLatLongUOM = ISNULL(gi_string1, 'S')
		FROM generalinfo (NOLOCK)
		WHERE gi_name =  'CompanyLatLongUnits'

		SET @CityLatLongUOM = 'S'
		SELECT @CityLatLongUOM = ISNULL(gi_string1, 'S')
		FROM generalinfo (NOLOCK)
		WHERE gi_name =  'CityLatLongUnits'

		SET @Lat = CONVERT(Float, @Latitude)
		SET @Long = CONVERT(Float, @Longitude)

		SET @Trailer = @Truck
		if @TrailerCheckcall = 'Y' AND LEFT(@Truck, 4) = 'TRL:'
			SET @Trailer = SUBSTRING(@Truck, 5, DATALENGTH(@Truck)-5)

		/************** Get last two checkcalls into variables for use in proc *******************/
		SET @LastCkcNumber = -1
		SET @LastCkcDate = '19500101'
		SET @LastCkcLat = -1
		SET @LastCkcLong = -1
		SET @LastCkcHome = ''
		SET @LastCkcLgh = -1

		DELETE @TempTbl	-- Empty the temporary table for this time thru the loop

		-- Get the last two checkcalls for this tractor
		IF (@TrailerCheckcall = 'N')
			INSERT INTO @TempTbl (ckc_number, ckc_date, ckc_home, ckc_lghnumber, ckc_latseconds, ckc_longseconds)
			SELECT TOP 2 ckc_number, ckc_date, ckc_home, ckc_lghnumber, ckc_latseconds, ckc_longseconds
			FROM checkcall (NOLOCK)
			WHERE ckc_tractor = @Truck
				AND ckc_date < @DateAndTime
			ORDER BY ckc_date DESC
		ELSE
			INSERT INTO @TempTbl (ckc_number, ckc_date, ckc_home, ckc_lghnumber, ckc_latseconds, ckc_longseconds)
			SELECT TOP 2 ckc_number, ckc_date, ckc_home, ckc_lghnumber, ckc_latseconds, ckc_longseconds
			FROM checkcall (NOLOCK)
			WHERE ckc_asgnid = @Trailer
				AND ckc_date < @DateAndTime
				AND ckc_event = 'TRP'
			ORDER BY ckc_date DESC

		-- Put the last checkcall into variables
		SET @TempDate = '19490101'
		SELECT @TempDate = ISNULL(MAX(ckc_date), '19490101')
		FROM @TempTbl

		IF (@TempDate <> '19490101')
			SELECT  @LastCkcNumber = ckc_number,
				@LastCkcDate = ckc_date,
				@LastCkcLat = ISNULL(ckc_latseconds,-1),
				@LastCkcLong = ISNULL(ckc_longseconds,-1),
				@LastCkcHome = ISNULL(ckc_home,''),			
				@LastCkcLgh = ISNULL(ckc_lghnumber, -1)
			FROM @TempTbl
			WHERE ckc_date = @TempDate

/****** NOTE: The next to last checkcall variables are not needed yet, if they are needed in the future
just uncomment the following lines, the initialization lines and the declaration lines to set the variables

-- Put the next to last checkcall into variables
SET @TempDate = '19490101'
SELECT @TempDate = ckc_date
FROM @TempTbl
WHERE ckc_date < @LastCkcDate

IF (@TempDate <> '19490101')
	SELECT  @NextLastCkcNumber = ckc_number,
		@NextLastCkcDate = ckc_date,
		@NextLastCkcLat = ISNULL(ckc_latseconds,-1),
		@NextLastCkcLong = ISNULL(ckc_longseconds,-1),
		@NextLastCkcHome = ISNULL(ckc_home,''),
		@NextLastCkcLgh = ISNULL(ckc_lghnumber, -1)
	FROM @TempTbl
	WHERE ckc_date = @TempDate	*****/

/************ Driver Home Calculations *******************/
		SET @DriverHome = ''
		DELETE FROM @HomeLocations

		-- Driver Home calculations (if configured and a driver was located for this checkcall			
		IF (@HomeArriveMiles <> '' AND @HomeDepartMiles <> '' AND @Driver <> '' AND @TrailerCheckcall = 'N') 
			BEGIN
				-- Look up the lat/long of the drivers home
				SELECT  @DriverLat = ISNULL(mpp_home_latitude, -1), 
					@DriverLong = ISNULL(mpp_home_longitude,-1)
				FROM manpowerprofile (NOLOCK)
				WHERE mpp_id = @Driver

				IF @DriverLat <> -1 AND @DriverLong <> -1
					INSERT INTO @HomeLocations (HomeLat, HomeLong)
						SELECT @DriverLat / 3600, @DriverLong / 3600

				IF (@UseAtHomeTerminals = 1)
					BEGIN
						SELECT @HomeTerminal = ISNULL(mpp_athome_terminal, '')
							FROM manpowerprofile (NOLOCK)
							WHERE mpp_id = @Driver

						IF @HomeTerminal > '' AND @HomeTerminal <> 'UNKNOWN'
							BEGIN
								SELECT  @DriverLat = ISNULL(cmp_latseconds, -1), 
										@DriverLong = ISNULL(cmp_longseconds,-1)
								FROM company (NOLOCK)
								WHERE cmp_id = @HomeTerminal

								IF @DriverLat <> -1 AND @DriverLong <> -1
									INSERT INTO @HomeLocations (HomeLat, HomeLong)
										SELECT @DriverLat / 3600, @DriverLong / 3600
							END --@HomeTerminal > '' AND @HomeTerminal <> 'UNKNOWN'

					END --EXISTS (SELECT a.* FROM syscolumns a, sysobjects b

				--FUTURE: if TMWSuite creates a At Home table just put all the At Home entries for the driver into the @HomeLocations table here.

				-- Get the first record
				SELECT @HomeLocationSN = ISNULL(MIN(SN), -1)
				FROM @HomeLocations

				WHILE @HomeLocationSN <> -1
					BEGIN
						-- Get the distance from the drivers home to this checkcall
						SELECT @DriverLat = HomeLat, @DriverLong = HomeLong 
							FROM @HomeLocations
							WHERE SN = @HomeLocationSN
		
						EXEC dbo.tmail_airdistance @Lat, @Long, @DriverLat, @DriverLong, @HomeMiles OUT
						IF (@HomeMiles <= @HomeArriveMiles)
							BEGIN
								-- Driver is home
								SET @DriverHome = 'Y'
								break
							END --(@HomeMiles <= @HomeArriveMiles)

						if ISNULL(@HomeLowestMiles, 0) = 0 SET @HomeLowestMiles = @HomeMiles
						if @HomeMiles < @HomeLowestMiles SET @HomeLowestMiles = @HomeMiles

						-- Get the next
						SELECT @HomeLocationSN = ISNULL(MIN(SN), -1)
							FROM @HomeLocations
							WHERE SN > @HomeLocationSN

					END --WHILE @SN <> -1
								
				if @DriverHome <> 'Y'
					BEGIN
						IF (@HomeLowestMiles >= @HomeDepartMiles)
							BEGIN
								-- Driver is not home, check to see if he just left home
								SET @DriverHome = 'N'
					
								IF (@LastCkcHome = 'Y' OR @LastCkcHome = 'T') -- 2012-04-02 DWG - PTS 60967 - Was the ckc_home of the last checkcall 'Y' or 'T'?
									BEGIN
										-- Find the last time the driver was home
										SELECT @TempDate = ISNULL(MAX(mhl_end), '19500101')
											FROM manpowerhomelog (NOLOCK)
											WHERE mpp_id = @Driver
												AND mhl_end < @DateAndTime
						
										-- Check for any weird situations
										SELECT @TempDate2 = ISNULL(MAX(mhl_start), '19500101')
											FROM manpowerhomelog (NOLOCK)
											WHERE mpp_id = @Driver
												AND mhl_start < @DateAndTime

										IF @TempDate < @TempDate2	-- Should never happen, but we have seen this somehow, so work around it.
											BEGIN	-- Two ways this can happen, a non-home checkcall during a home period, or a damaged
													-- record.  Regardless we don't want to pay any attention to anything during that
													-- home period.
												SELECT @TempDate = ISNULL(MAX(mhl_end), @TempDate2) 
												FROM manpowerhomelog (NOLOCK)
												WHERE mhl_start = @TempDate2
												IF @TempDate < @TempDate2
												-- It's a damaged record.  Ignore all checkcalls related to that home period.
												SELECT @TempDate= @TempDate2
											END
									
										-- Find first time driver was home after his prior home record.
										SELECT @TempDate2 = MIN(ckc_date) 
										FROM checkcall (NOLOCK)
											WHERE ckc_asgnid = @Driver
												AND ckc_asgntype = 'DRV'
												AND ckc_event = 'TRP'
												AND ckc_home = 'T' --2012-04-02 DWG - PTS 60967
												AND ckc_date > @TempDate 
												AND ckc_date < @DateAndTime
									
										IF NOT (@TempDate2 IS NULL)
											BEGIN
												-- Driver was home, but has now left, so make an entry into 
												--  the manpowerhomelog table.  But first make sure there
												--  is not already an entry for this time frame.
												IF NOT EXISTS (SELECT * 
																FROM manpowerhomelog (NOLOCK)
																WHERE mpp_id = @Driver AND mhl_start = @TempDate2)
													INSERT INTO manpowerhomelog (mpp_id, mhl_start, mhl_end, mhl_tractor)
													VALUES (@Driver, @TempDate2, @DateAndTime, @Truck)
											END
									END --(@LastCkcHome = 'Y')
							END --(@HomeMiles >= @HomeDepartMiles)
						ELSE 
							IF (@HomeLowestMiles > @HomeArriveMiles AND @HomeLowestMiles < @HomeDepartMiles)
								-- Driver is between the arrive/depart config values,
								-- so use value from last checkcall							
								SET @DriverHome = @LastCkcHome

					END -- @DriverHome <> 'Y'

			END -- Configured to calc driver home and @Driver <> ''?

		IF @DriverHome = ''	-- If no DriverHome value was found, enter null in the datebase
			SET @DriverHome = NULL

/************ Delete Duplicate Checkcalls *******************/
		IF (@DeleteDupMiles <> '')
			BEGIN
				-- Get the last two checkcalls for this tractor to see if we need to 
				--  delete the middle one.
				-- Only check for dups if we have 2 checkcalls to work with
				SELECT @Count = COUNT(*) FROM @TempTbl
				IF (@Count = 2)
					BEGIN
						-- Check if both records have same ckc_home, ckc_date, ckc_lghnumber and distance is within @DeleteDupMiles
						-- Note: it doesn't matter what order we check these two records in
						SELECT @Count = ISNULL(MIN(ckc_number), -1)
						FROM @TempTbl
			
						SET @DeleteCkc = 'T'
						WHILE @Count <> -1
							BEGIN
								SELECT  @TestDate = ckc_date,
									@TestHome = ckc_home,
									@TestLgh = ISNULL(ckc_lghnumber, 0),
									@TestLat = ckc_latseconds,
									@TestLong = ckc_longseconds
								FROM @TempTbl
								WHERE ckc_number = @Count

								-- Convert from seconds to degrees
								SET @TestLat = @TestLat / 3600
								SET @TestLong = @TestLong / 3600

								IF (ISNULL(@TestHome,'Z') = ISNULL(@DriverHome,'Z'))
									IF (@TestLgh = @lgh_number)
										IF (CONVERT(varchar(10),@TestDate,101) = CONVERT(varchar(10),@DateAndTime,101))
											BEGIN
												-- Check if checkcalls are within configured distance
												EXEC dbo.tmail_airdistance @Lat, @Long, @TestLat, @TestLong, @TempFloat OUT
												
												IF (@TempFloat > @DeleteDupMiles)
													BEGIN
														SET @DeleteCkc = 'F'
														BREAK
													END
											END
										ELSE
											BEGIN
												SET @DeleteCkc = 'F'
												BREAK
											END
									ELSE
										BEGIN
											SET @DeleteCkc = 'F'
											BREAK
										END
								ELSE
									BEGIN
										SET @DeleteCkc = 'F'
										BREAK
									END

								-- Get the next record
								SELECT @Count = ISNULL(MIN(ckc_number), -1)
									FROM @TempTbl
									WHERE ckc_number > @Count
							END  -- While

						IF (@DeleteCkc = 'T')  --Event may be filled in above from tblLatLong Remark
							BEGIN
								-- Get the ckc_number of the middle checkcall
								SELECT @CkcNumber = ckc_number
								FROM @TempTbl
								ORDER BY ckc_date 
		
								-- Delete the checkcall
								DELETE checkcall
								WHERE ckc_number = @CkcNumber
							END
					END	-- If 2 checkcalls
			END  -- If @DeleteDupMiles <> ''

/************ Checkcall Calculations *******************/
		
		-- Calculate miles from the last checkcall to this one
		SET @Mileage = 0
		SET @ApproxMinutes = 0
		SET @MinutesToFinal = 0
		IF (@LastCkcLat <> -1 AND @LastCkcLong <> -1 AND @NoMiles = 0)
			BEGIN
				SET @TestLat = CONVERT(float,@LastCkcLat) / 3600
				SET @TestLong = CONVERT(float,@LastCkcLong) / 3600

				-- Calculate the miles from the last checkcall to this one
				EXEC dbo.tmail_airdistance @Lat, @Long, @TestLat, @TestLong, @Mileage OUT

				-- Calculate ckc_minutes
				IF @Mileage > 0 AND @FleetAveMPH > 0
					SET @ApproxMinutes = @Mileage * 60 / @FleetAveMPH
			END

		-- Only do open miles calculation for tractor checkcalls
		IF (@TrailerCheckcall = 'N' AND @NoMiles = 0)
			BEGIN
				-- Calculate miles on all open stops on this leg
				DELETE @MilesTbl 	-- Delete any records that may already be in the temp table

				-- Get the lat/longs for all companies & cities on open stops
				--  on this leg in stp_mfh_sequence order
				INSERT INTO @MilesTbl (stp_mfh_sequence, cmp_latseconds, cmp_longseconds, cty_latitude, cty_longitude)
				SELECT  stops.stp_mfh_sequence,
					ISNULL(cmp_latseconds, -1) cmp_latseconds,
					ISNULL(cmp_longseconds,-1) cmp_longseconds,
					ISNULL(cty_latitude, -1) cty_latitude,
					ISNULL(cty_longitude, -1) cty_longitude
				FROM stops (NOLOCK)
				LEFT JOIN company (NOLOCK)
				ON stops.cmp_id = company.cmp_id 
				LEFT JOIN city
				ON stops.stp_city = city.cty_code
				WHERE lgh_number = @lgh_number
					AND stops.stp_status = 'OPN'
				ORDER BY stp_mfh_sequence

				SET @LatHold = @Lat
				SET @LongHold = @Long
				SET @MilesToFinal = 0

				SELECT @Count = ISNULL(MIN(stp_mfh_sequence), -1)
					FROM @MilesTbl
				
				WHILE @Count <> -1
					BEGIN
						SELECT  @TestLat = cmp_latseconds,
							@TestLong = cmp_longseconds,	
							@TestLat1 = cty_latitude,
							@TestLong1 = cty_longitude
						FROM @MilesTbl
						WHERE stp_mfh_sequence = @Count

						IF (@TestLat <> -1 AND @TestLong <> -1)  -- First try company lat/longs
							BEGIN
								IF (@CompanyLatLongUOM = 'S') 
									BEGIN
										-- Convert from seconds to degrees
										SET @TestLat = @TestLat / 3600
										SET @TestLong = @TestLong / 3600
									END

								EXEC dbo.tmail_airdistance @LatHold, @LongHold, @TestLat, @TestLong, @TempMiles OUT
								SET @MilesToFinal = @MilesToFinal + @TempMiles

								-- Set starting point for air distance from this stop to the next
								SET @LatHold = @TestLat
								SET @LongHold = @TestLong
							END
						ELSE
							IF (@TestLat1 <> -1 AND @TestLong1 <> -1)  -- Try city lat/longs if company don't exist
								BEGIN
									IF @CityLatLongUOM = 'S'
										BEGIN
											-- Convert from seconds to degrees
											SET @TestLat1 = @TestLat1 / 3600
											SET @TestLong1 = @TestLong1 / 3600
										END

									EXEC dbo.tmail_airdistance @LatHold, @LongHold, @TestLat1, @TestLong1, @TempMiles OUT
									SET @MilesToFinal = @MilesToFinal + @TempMiles

									-- Set starting point for air distance from this stop to the next
									SET @LatHold = @TestLat1
									SET @LongHold = @TestLong1
								END
							ELSE
								BEGIN
									SET @MilesToFinal = -1
									BREAK
								END

							-- Get the next record
							SELECT @Count = ISNULL(MIN(stp_mfh_sequence), -1)
								FROM @MilesTbl
								WHERE stp_mfh_sequence > @Count
					END	-- While

				-- Calculate the MinutesToFinal
				IF @MilesToFinal > 0 AND @FleetAveMPH > 0
					SET @MinutesToFinal = @MilesToFinal * 60 / @FleetAveMPH
			END	-- IF @TrailerCheckcall = 'N'	

	END	-- End block skipped in Emergency mode

	SELECT	@DriverHome IsDriverHome, 
			@Mileage Mileage, 
			@MilesToFinal MilesToFinal, 
			@ApproxMinutes ApproxMinutes,
			@MinutesToFinal MinutesToFinal,
			CASE WHEN ISNULL(@DeleteCkc, 'F') = 'T' THEN 1 ELSE 0 END CheckCallDeleted

GO
GRANT EXECUTE ON  [dbo].[tmail_CheckCall_Calculations] TO [public]
GO
