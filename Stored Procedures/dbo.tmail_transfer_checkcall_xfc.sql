SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_transfer_checkcall_xfc]

AS

/*** SQL 2000 VersiON ***/

/* REVISION HISTORY:
 * 06/13/00 MZ: Transfer checkcalls from tblCheckcallXfc to checkcall
 * 	Note: This is only used for clients that have split databases
 *		for PowerSuite and TotalMail
 * 10/24/00 MZ: Added driver home functionality, mileage calculations and duplicate checkcall deletion
 * 12/04/00 MZ: Added TTIS support
 * 02/22/01 MZ: Added cty_code support PTS9902	
 * 03/05/01 MZ: Added error logging 
 * 05/24/01 DAG: Converting for international date format
 * 07/30/01 DWG: Added Event tags  
 * 12/10/01 DWG: Added Odomter to checkcall, manpowerprofile and tractorprofile 
 * ...
 * 08/16/2005.01 – PTS29395 - Tim Adam – Only call AAD if trc_useGeofencing = 'Y'
 * 10/12/05 DWG: {29933} Added At Home Terminal support
 * 10/21/2005.01 - PTS30338 - Tim Adam - Re-sync the SQL2K with SQL7 version; apply PTS 27882.
 * 11/16/2005    - PTS30600 - MIZ - Problem with @Precheck SQL because @Event wasn't initialized correctly.
 * 01/24/2006.01 - PTS30109 - Tim Adam - Add eight new checkcall fields.
 * 03/09/2006.01 - PTS32052 - MZ/TD - Put fix in for calculating driver home manpowerhomelog entries.
 * 04/14/2006.01 - PTS32326 - TA - Support new values for trc_UseGeofencing.
 * 07/31/2006.01 - PTS33912 - MZ - Added setting to allow duplicate checkcalls.
 * 02/11/2009.01 - PTS45517 - VMS - Modify tblCheckcallXfc logic for new AssociatedMsgSN field.
 * 03/18/2009.01 - PTS45807 - MZ - Add support for ExtraData01-20 fields.
 * 10/01/2012	 - PTS64388 - APC - Add support for Driver subsistence qualification calculation
 * 10/12/2012	 - PTS64370 - APC - Add support for Driver Emergency Alerts
 * 07/05/2013	 - PTS70584 - APC - Change conditions for calling driver subsistence and emergency alert suite procs & call .net ops svn procs instead of totalmail procs 
 * 09/05/2013	 - PTS72000 - APC - verify mpp_subsistence_eligible = 'Y' before calling Driver Subsistence Calculation
 * 10/31/2013	 - PTS73013 - APC - modify driver subsistence to process for driver2, if present
 * 11/19/2013	 - PTS73486 - APC - SQL 2005 Compatibility => add 'EXEC ' before the stored proc name in a few places where proc is executed using sp_executesql
 * 04/01/2014	 - PTS56524 - HMA - pasting in Jerry Ritcey's hotfix (3 places) for When a check call is process hours/days after it was taken, 
									TotalMail looks up the legheader for the resource based on the current date and time, not the date and time the checkcall was taken
 * 04/08/2014    - PTS71016 - HMA - now using the ASSETASSIGNMENT table as its primary source for legheader info and if @CheckcallStrict = 'Y' (ie CheckcallStrict from generalinfo) 
 *									it will stop there in its search, even if lgh_number is 0. @CheckcallStrict = 'N' will continue to the LEGHEADER table if the ASSESTASSIGNMENT 
 *                                  table has no entry for the lgh_number we're searching for.
 * 07/22/2014	 - PTS79470 - HMA - limit setting @NbrCheckcalls to 9000 maximum - loop back when necessary - needed due to call on getsystemnumberblock 
 * 08/19/2014	 - PTS81649 - APC - SQL 2005 Compatibility => can not declare and set variables in the same statement
 * 08/19/2014	 - PTS101890 - rwolfe - Make changes suggested by DBA Services.  Use new ident_numbers for insert to work around limitation of 9000, new limit of 5000000
*/

DECLARE 
	@ApproxMinutes int,
	@AsgnId varchar(30),		-- Either a driver id or a trailer id.
	@AsgnType varchar(30),		-- Either TRL (trailer) or DRV (driver)
	@CityName varchar(16),
	@CityLatLongUOM char(1),
	@ckc_number int,	
	@CkcNumber int,				-- The ckc_number of the checkcall to delete if it's a duplicate	
	@Comment varchar(255),
	@CompanyLatLongUOM char(1),
	@Count int,
	@cty_code int,
	@DateAndTime datetime, 
	@DeleteCkc char(1),			-- Should we delete this duplicate checkcall?
	@DeleteDupMiles varchar(10),	-- Number of miles to delete duplicate checkcalls within
	@Direction varchar(3),
	@Driver varchar(8),
	@DriverHome char(1),		-- Y/N, value written to ckc_home
	@DriverLat float,			-- Latitude of drivers home
	@DriverLong float,			-- Longitude of drivers home
	@ErrorInfo varchar(255),
	@Event varchar(3),			-- Either TRL (Trailer) or TRP (truck checkcall)
	@FleetAveMPH int,
	@HomeArriveMiles varchar(10),	-- Number of miles to consider driver arriving home
	@HomeDepartMiles varchar(10),	-- Number of miles to consider driver leaving home
	@HomeMiles float,			-- Distance of driver from his home
	@LargeComment varchar(255),
	@LastCkcNumber int,			-- The ckc_number of this tractor's last checkcall
	@LastCkcHome char(1),		-- The ckc_home of this tractor's last checkcall
	@LastCkcLat int,			-- The ckc_latseconds of this tractor's last checkcall
	@LastCkcLong int,			-- The ckc_longseconds of this tractor's last checkcall
	@LastCkcDate datetime,		-- The ckc_date of this tractor's last checkcall
	@LastCkcLgh int,			-- The ckc_lghnumber of this tractor's last checkcall
	@Lat float,					-- checkcall's latitude	(degrees)
	@LatHold float,
	@Long float,				-- checkcall's longitude (degrees)
	@LongHold float,	
	@ckc_latseconds int,		-- ckc_latseconds
	@ckc_longseconds int,		-- ckc_longseconds
	@lgh_date datetime,
	@lgh_number int,
	@LogDupCheckcallErrors int,
	@Mileage float,				-- Air miles from last checkcall to this one
	@MileDay7FromCheckcall char(1),		-- Turn on or off the floating 7 day mileage sum to ManPowerProfile
	@Miles real,
	@MilesToFinal float,		-- Air miles for all open stops on this leg
	@MinutesToFinal int,
	@NbrCheckcalls int,			-- Number of checkcalls we're processing, used to request block of ckc_numbers
/***	@NextLastCkcNumber int,	-- The ckc_number of this tractor's next to last checkcall
	@NextLastCkcHome char(1),	-- The ckc_home of this tractor's next to last checkcall
	@NextLastCkcLat int,		-- The ckc_latseconds of this tractor's next to last checkcall
	@NextLastCkcLong int,		-- The ckc_longseconds of this tractor's next to last checkcall
	@NextLastCkcDate datetime,	-- The ckc_date of this tractor's next to last checkcall
	@NextLastCkcLgh int,		-- The ckc_lghnumber of this tractor's next to last checkcall	***/
	@Precheck int,				-- Does a checkcall for this tractor at this date/time already exist?
	@SmallTempMileage float,
	@SmallTempMinutes float,
	@SN int,
	@State varchar(6),
	@Temp varchar(10),
	@TempDate datetime,
	@TempDate2 datetime,
	@TempFloat float,
	@TempMiles float,
	@TestDate datetime,
	@TestHome char(1),
	@TestLat float,
	@TestLat1 float,
	@TestLgh int,
	@TestLong float,
	@TestLong1 float,
	@Trailer varchar(15),
	@TrailerCheckcall char(1),	-- Y/N
	@Truck varchar(25),
	@VehicleIgnition char(1),
	@Zip varchar(10),
	@cty_count int,
	@cty_distance float,
	@cty_check_code int,
	@cty_check_lat float,
	@cty_check_long float,
	@cty_check_distance float,
	@OdometerReading int,
	@FlagList varchar(255),
	@NoMiles int,
	@EmergencyMode int,
	@TripStatus int,
	@Delete5Min int,			-- 0 - don't delete, 1 - delete
	@XfcSN int,
	@NextXfcSN int,
	@NextTruck varchar(20),
	@NextVehicleIgnition char(1),
	@NextTripStatus int,
	@NextDateAndTime datetime,
	@sTrcDrvBasis varchar(1),
	@HomeLocationSN int,
	@HomeLowestMiles float,
	@HomeTerminal varchar(8),
	@UseAtHomeTerminals int,
	@odometer2 int,
	@speed int,
	@speed2 int,		
	@heading float, 	
	@gps_type int,			
	@gps_miles float,	
	@fuel_meter float,
	@idle_meter int,
	@vi_AllowDupCheckcalls int,	-- 0 - No dups (default), 1 - Allow dups

	--PTS #35670 Start
	@Chk_Cstmz_SPName varchar(60), -- Variable to hold the name of customize stored procedure.
	@SQLString nvarchar(500),
	@SQLPara nvarchar(500),
	@trl_gps_desc varchar(255),
	--PTS #35670 End

	@AssociatedMsgSN int,		-- PTS 45517-VMS
	@ExtraData01 varchar(255),	-- PTS45807
	@ExtraData02 varchar(255),
	@ExtraData03 varchar(255),
	@ExtraData04 varchar(255),
	@ExtraData05 varchar(255),
	@ExtraData06 varchar(255),
	@ExtraData07 varchar(255),
	@ExtraData08 varchar(255),
	@ExtraData09 varchar(255),
	@ExtraData10 varchar(255),
	@ExtraData11 varchar(255),
	@ExtraData12 varchar(255),
	@ExtraData13 varchar(255),
	@ExtraData14 varchar(255),
	@ExtraData15 varchar(255),
	@ExtraData16 varchar(255),
	@ExtraData17 varchar(255),
	@ExtraData18 varchar(255),
	@ExtraData19 varchar(255),
	@ExtraData20 varchar(255),
	@Driver_ckc_asgnid varchar(13),			-- PTS64388
	@stp_NextStop_Number INT,				-- PTS64370
	@stp_NextStop_City INT,					-- PTS64370
	@stp_arrivaldate DATETIME,				-- PTS64370
	@cmp_id varchar(8),						-- PTS70584
	@mpp_subsistence_eligible CHAR(1),		-- PTS72000
  @CheckcallStrict char(1),                -- pts71016
  @FINALCkcNumber INT       --PTS 101890

-- Create temp tables
DECLARE	@TempTbl table (ckc_number int,
			 ckc_date datetime,
			 ckc_home char(1),
			 ckc_lghnumber int,
			 ckc_latseconds int,
			 ckc_longseconds int)

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

--DWG {29933} Second At Home
DECLARE @HomeLocations table (SN int IDENTITY,
			      HomeLat float,
	  		      HomeLong float)
	
SET NOCOUNT ON


-- Create work table for Aad just in case it is needed (this routine never uses it, but recreating it for each checkcall
--	was causing the Aad routines to recompile excessively.
CREATE TABLE #stops_ckc_AadMain (
	stp_number int,
	stp_mfh_sequence int,
	stp_event char(6), 
	stp_arv_status varchar(6), 
	stp_dep_status varchar(6),
	stp_arv_time datetime,     
	stp_dep_Time datetime,   
	cmp_id varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
	stp_city int,
  	stp_gfc_arv_radiusMiles decimal(7,2),        
	stp_gfc_dep_radiusMiles decimal(7,2),        
	stp_gfc_lat decimal(12, 4),
	stp_gfc_long decimal(12, 4),
	stp_aad_arvTime datetime,
	stp_aad_arvConfidence int,
	stp_aad_depTime datetime,
	stp_aad_depConfidence int,
	stp_aad_lastckc_lat decimal(12, 4),         
	stp_aad_lastckc_long decimal(12, 4),           
	stp_aad_lastckc_time datetime,          
	stp_aad_lastckc_tripStatus int,
	stp_aad_laststartckc_lat decimal(12, 4),    
	stp_aad_laststartckc_long decimal(12, 4),      
	stp_aad_laststartckc_time datetime,     
	stp_aad_laststartckc_tripStatus int,
	stp_aad_arvckc_lat decimal(12, 4),
	stp_aad_arvckc_long decimal(12, 4),            
	stp_aad_arvckc_time datetime,           
	stp_aad_arvckc_tripStatus int,      
	stp_aad_depckc_lat decimal(12, 4),
	stp_aad_depckc_long decimal(12, 4),
	stp_aad_depckc_time datetime,           
	stp_aad_depckc_tripStatus int,
	tmpstp_ckc_airmiles decimal(12,4),
	stp_tz_hours int,
	stp_tz_mins int,
	stp_tz_dstCode int,
	stp_gfc_arv_flags int,
	stp_gfc_dep_flags int,
	tmpstp_updateStop int,
	tmpstp_issueArrive int,
	tmpstp_issueDepart int,
    tmpstp_matchstop int)

-- Get the emergency configuration parameters
SET @EmergencyMode = 0
SELECT @EmergencyMode = ISNULL(PATINDEX('%EMERGENCY%', gi_string1), 0)
FROM generalinfo (NOLOCK)
WHERE gi_name = 'TMailCkcFlags'

SET @NoMiles = 0
SELECT @NoMiles = ISNULL(PATINDEX('%NOMILESUMM%', gi_string1), 0)
FROM generalinfo (NOLOCK)
WHERE gi_name = 'TMailCkcFlags'

-- Get the configuration parameters for arrive/depart home etc
SET @HomeArriveMiles = ''
SELECT @HomeArriveMiles = gi_string1 
FROM generalinfo (NOLOCK)
WHERE gi_name = 'HomeArriveMiles'

SET @HomeDepartMiles = ''
SELECT @HomeDepartMiles = gi_string1 
FROM generalinfo (NOLOCK)
WHERE gi_name = 'HomeDepartMiles'

SET @DeleteDupMiles = ''
SELECT @DeleteDupMiles = gi_string1 
FROM generalinfo  (NOLOCK)
WHERE gi_name = 'CheckcallDupDeleteMiles'

SET @LogDupCheckcallErrors = 0	-- Default to not logging duplicate checkcalls
SELECT @LogDupCheckcallErrors = ISNULL(gi_integer1, 0)
FROM generalinfo (NOLOCK)
WHERE gi_name =  'LogDupCheckcalls'

SET @FleetAveMPH = 50
SELECT @FleetAveMPH = ISNULL(gi_integer1, 50)
FROM generalinfo (NOLOCK)
WHERE gi_name =  'FleetAvgMilesPerHour'

SET @CityLatLongUOM = 'S'
SELECT @CityLatLongUOM = ISNULL(gi_string1, 'S')
FROM generalinfo (NOLOCK)
WHERE gi_name =  'CityLatLongUnits'

SET @CompanyLatLongUOM = 'S'
SELECT @CompanyLatLongUOM = ISNULL(gi_string1, 'S')
FROM generalinfo (NOLOCK)
WHERE gi_name =  'CompanyLatLongUnits'

SET @MileDay7FromCheckcall = 'Y'  -- default to calc floating 7 day total
SELECT @MileDay7FromCheckcall = ISNULL(gi_string1, 'Y')
FROM generalinfo (NOLOCK)
WHERE gi_name =  'MileDay7FromCheckcall'

SET @Delete5Min = 0
SELECT @Delete5Min = ISNULL(gi_integer1, 0)
FROM generalinfo (NOLOCK)
WHERE gi_name =  'CheckcallDeleteIn5Minutes'

SET @sTrcDrvBasis = 'A'
SELECT @sTrcDrvBasis = LEFT(ISNULL(gi_string1, 'A'), 1), @Chk_Cstmz_SPName = ISNULL(gi_string2, '')
FROM generalinfo (NOLOCK)
WHERE gi_name =  'TMailTrcDrvBasis'

--DWG {29933} - At Home Terminals
SET @UseAtHomeTerminals = 0	-- Default to not using At Home Terminals
SELECT @UseAtHomeTerminals = ISNULL(gi_integer1, 0)
FROM generalinfo (NOLOCK)
WHERE gi_name =  'UseAtHomeTerminals'

-- MIZ {33912} - Allow duplicate checkcalls
SET @vi_AllowDupCheckcalls = 0
SELECT @vi_AllowDupCheckcalls = ISNULL(gi_integer1,0)
FROM generalinfo (NOLOCK)
WHERE gi_name = 'AlowDupCkc'
	
-- HMA(71016) - CheckcallStrict setting
SET @CheckcallStrict = 'Y'	-- Default to STRICT in processing new checkcalls
SELECT @CheckcallStrict = ISNULL(gi_integer1, '1')
FROM generalinfo (NOLOCK)
WHERE gi_name =  'CheckcallStrict'

IF @CheckcallStrict <> '1' --for NOW (4/2014) @CheckcallStrict is binary (Y/N) but future use may use integer for levels of strict
	SET @CheckcallStrict = 'N'
ELSE
	SET @CheckcallStrict = 'Y'
-- end 71016 settings
	
SET @ErrorInfo = 'A checkcall for this tractor at this date/time has already been entered into the checkcall table'

-- Pre-scan to delete checkcalls that occur within 5 minutes of each other for 
--  the same tractor, ignition status and TripStatus
-- We'll scan in DESC DateAndTime order so that we keep the latest checkcall for each tractor.
IF @Delete5Min > 0
	BEGIN

		-- Get all records from tblCheckcallXfc into a temp table to scan
		INSERT INTO @DeleteTblScan (XfcSN, Tractor, DateAndTime, Ignition, TripStatus)
		SELECT SN, Tractor, DateAndTime, VehicleIgnition, TripStatus 
			FROM tblCheckcallXfc 
			ORDER BY Tractor, DateAndTime DESC

		SET @XfcSN = 0
		SET @Truck = ''
		SET @DateAndTime = '19500101'
		SET @VehicleIgnition = ''
		SET @TripStatus = 0
		
		-- Get the first record
		SELECT @SN = ISNULL(MIN(SN), -1)
		FROM @DeleteTblScan

		-- and put it into variables
		SELECT @XfcSN = XfcSN,
			   @Truck = Tractor,
			   @VehicleIgnition = Ignition,
			   @TripStatus = TripStatus,
			   @DateAndTime = DateAndTime
		FROM @DeleteTblScan
		WHERE SN = @SN

		-- Get the next
		SELECT @SN = ISNULL(MIN(SN), -1)
		FROM @DeleteTblScan
		WHERE SN > @SN

		WHILE @SN <> -1
			BEGIN
				SELECT @NextXfcSN = XfcSN,
					   @NextTruck = Tractor,
					   @NextVehicleIgnition = Ignition,
					   @NextTripStatus = TripStatus,
					   @NextDateAndTime = DateAndTime
				FROM @DeleteTblScan
				WHERE SN = @SN

				-- If same truck, ignition status, TripStatus and if within 5 minutes of each other
				IF (@Truck = @NextTruck AND @VehicleIgnition = @NextVehicleIgnition AND @TripStatus = @NextTripStatus AND (DATEDIFF(mi, @NextDateAndTime, @DateAndTime) < 5))
					-- Enter the tblCheckcallXfc SN so we can bulk delete later.
					INSERT INTO @DeleteTbl (SN)
					VALUES (@NextXfcSN)
				ELSE
					BEGIN
						SET @XfcSN = @NextXfcSN
						SET @Truck = @NextTruck
						SET @VehicleIgnition = @NextVehicleIgnition
						SET @TripStatus = @NextTripStatus
						SET @DateAndTime = @NextDateAndTime
					END

				-- Get the next
				SELECT @SN = ISNULL(MIN(SN), -1)
					FROM @DeleteTblScan
					WHERE SN > @SN
			END	-- WHILE @SN <> -1

			-- Now actually delete those checkcalls from tblCheckcallXfc
			DELETE tblCheckcallXfc
				FROM @DeleteTbl a
				WHERE a.SN = tblCheckcallXfc.SN
	END  -- IF @Delete5Min > 0

-- See how many checkcalls we have to transfer
--  so we can request a block of system numbers
SELECT @NbrCheckcalls = dbo.tmail_IntMin(COUNT(*), 5000000)  from tblCheckcallXfc

IF (@NbrCheckcalls > 0)
	BEGIN

    --EXECUTE @ckc_number = dbo.getsystemnumberblock 'CKCNUM','',@NbrCheckcalls --Removed due to 9000 Limit

		-- Request a block of system numbers 
		-- (returns the nbr of the first of the block, -1 on failure)
    INSERT INTO dbo.ident_ckcnum --PTS 101890, Replace getSystemNumberblock with version that supports larger limits
    WITH (TABLOCK) (id)
    SELECT n
    FROM dbo.ident_numbers
    WHERE n <= @NbrCheckcalls;

    SET @FINALCkcNumber = SCOPE_IDENTITY()

    SET @ckc_number = @FINALCkcNumber - @NbrCheckcalls + 1;

		IF(@ckc_number <> -1) AND @ckc_number <= @FINALCkcNumber
			BEGIN
				-- Get the first checkcall to transfer
				SELECT @SN = ISNULL(MIN(SN), -1)
				FROM tblCheckcallXfc

				WHILE @SN <> -1
					BEGIN
						SET @TrailerCheckcall = 'N'
						SET @Trailer = ''

						-- Pull info for this record into variables
						SELECT  @DateAndTime = ISNULL(DateAndTime,'19500101'), 
							@Truck = Tractor,
							@Lat = ISNULL(Lat,0),
							@Long = ISNULL(Long,0),
							@Miles = ISNULL(Miles,0),
							@Direction = ISNULL(Direction,''),
							@Zip = ISNULL(Zip,''),
							@CityName = ISNULL(CityName,''),
							@State = ISNULL(State,''),
							@Comment = ISNULL(Comments,''),
							@LargeComment = ISNULL(LargeComments,''),
							@VehicleIgnition = VehicleIgnition,
							@OdometerReading = ISNULL(Odometer, 0),
							@TripStatus = ISNULL(TripStatus, 0),
							@odometer2 = odometer2,
							@speed = speed,
							@speed2 = speed2,		
							@heading = heading, 	
							@gps_type = gps_type,			
							@gps_miles = gps_miles,	
							@fuel_meter = fuel_meter,
							@idle_meter = idle_meter,
							@AssociatedMsgSN = AssociatedMsgSN,		-- PTS 45517 - VMS
							@ExtraData01 = CASE ckc_ExtraData01 WHEN '' THEN NULL ELSE ckc_ExtraData01 END,
							@ExtraData02 = CASE ckc_ExtraData02 WHEN '' THEN NULL ELSE ckc_ExtraData02 END,
							@ExtraData03 = CASE ckc_ExtraData03 WHEN '' THEN NULL ELSE ckc_ExtraData03 END,
							@ExtraData04 = CASE ckc_ExtraData04 WHEN '' THEN NULL ELSE ckc_ExtraData04 END,
							@ExtraData05 = CASE ckc_ExtraData05 WHEN '' THEN NULL ELSE ckc_ExtraData05 END,
							@ExtraData06 = CASE ckc_ExtraData06 WHEN '' THEN NULL ELSE ckc_ExtraData06 END,
							@ExtraData07 = CASE ckc_ExtraData07 WHEN '' THEN NULL ELSE ckc_ExtraData07 END,
							@ExtraData08 = CASE ckc_ExtraData08 WHEN '' THEN NULL ELSE ckc_ExtraData08 END,
							@ExtraData09 = CASE ckc_ExtraData09 WHEN '' THEN NULL ELSE ckc_ExtraData09 END,
							@ExtraData10 = CASE ckc_ExtraData10 WHEN '' THEN NULL ELSE ckc_ExtraData10 END,
							@ExtraData11 = CASE ckc_ExtraData11 WHEN '' THEN NULL ELSE ckc_ExtraData11 END,
							@ExtraData12 = CASE ckc_ExtraData12 WHEN '' THEN NULL ELSE ckc_ExtraData12 END,
							@ExtraData13 = CASE ckc_ExtraData13 WHEN '' THEN NULL ELSE ckc_ExtraData13 END,
							@ExtraData14 = CASE ckc_ExtraData14 WHEN '' THEN NULL ELSE ckc_ExtraData14 END,
							@ExtraData15 = CASE ckc_ExtraData15 WHEN '' THEN NULL ELSE ckc_ExtraData15 END,
							@ExtraData16 = CASE ckc_ExtraData16 WHEN '' THEN NULL ELSE ckc_ExtraData16 END,
							@ExtraData17 = CASE ckc_ExtraData17 WHEN '' THEN NULL ELSE ckc_ExtraData17 END,
							@ExtraData18 = CASE ckc_ExtraData18 WHEN '' THEN NULL ELSE ckc_ExtraData18 END,
							@ExtraData19 = CASE ckc_ExtraData19 WHEN '' THEN NULL ELSE ckc_ExtraData19 END,
							@ExtraData20 = CASE ckc_ExtraData20 WHEN '' THEN NULL ELSE ckc_ExtraData20 END
						FROM tblCheckcallXfc  (NOLOCK)
						WHERE SN = @SN

						-- Get the cty_code for this city/state
						SELECT @cty_code = MIN(cty_code), @cty_count = COUNT(cty_code)
						FROM city (NOLOCK)
						WHERE cty_name = @CityName 
						  AND cty_state = @State

						IF ISNULL(@cty_code,0) = 0
							SET @cty_code = 0

						IF @cty_count > 1
							-- If there is more than one entry in the city table for this city/state
							--  find the closest one to where this checkcall is.
							BEGIN
								SET @cty_check_code = @cty_code
								SET @cty_distance = 99999
								WHILE ISNULL(@cty_check_code, 0) > 0
									BEGIN
										SELECT @cty_check_lat = ISNULL(cty_latitude, -5000000), @cty_check_long = ISNULL(cty_longitude, -5000000) 
										FROM city (NOLOCK) 
										WHERE cty_code = @cty_check_code
										
										IF @cty_check_lat > -5000000 and @cty_check_long > -5000000
											BEGIN
												IF (@CityLatLongUOM) = 'S'
													BEGIN
														-- Convert from seconds to degrees
														SET @cty_check_lat = @cty_check_lat / 3600
														SET @cty_check_long = @cty_check_long / 3600
													END

												EXEC dbo.tmail_airdistance @Lat, @Long, @cty_check_lat, @cty_check_long, @cty_check_distance out
												IF @cty_check_distance < @cty_distance
												SELECT @cty_code = @cty_check_code, @cty_distance = @cty_check_distance
											END

										SELECT @cty_check_code = MIN(cty_code)
											FROM city  (NOLOCK)
											WHERE cty_name = @CityName 
												AND cty_state = @State
												AND cty_code > @cty_check_code
									END--wHILE
							END 

						IF @sTrcDrvBasis =  'S' and len(@Chk_Cstmz_SPName) > 0  --S =TWMSuite Stored Procedure
							BEGIN --PTS #35670 Start
								set @SQLPara = N'@pSp_Truck Varchar(256), @pSp_Trailercheckcall Varchar(10) Output, @pSp_lgh_number int OutPut, 
										   @pSp_Driver Varchar(256) OutPut, @pSp_Trailer Varchar(256) OutPut, @pSp_TruckO Varchar(256) OutPut, 
										   @pSp_Event Varchar(20) OutPut'   

								set @SQLString = N'Exec '  + @Chk_Cstmz_SPName + ' @pSp_Truck, @pSp_Trailercheckcall Output, @pSp_lgh_number OutPut,
											@pSp_Driver OutPut, @pSp_Trailer Output, @pSp_TruckO Output, @pSp_Event Output'   
								EXECUTE sp_executesql  @SQLString, @SQLPara, @pSp_Truck = @Truck,  @pSp_Trailercheckcall = @TrailerCheckcall output,
											@pSp_lgh_number = @lgh_number output, @pSp_Driver = @Driver output, 
											@pSp_Trailer =	 @Trailer output, @pSp_TruckO = @Truck output, @pSp_Event = @Event output

							END --PTS #35670 End


						ELSE IF SUBSTRING(@Truck,1,4) = 'DRV:'
							BEGIN
								SET @Event = 'TRP'
								SELECT @Driver = SUBSTRING(@Truck,5,99)
								--1st PTS 71016 method to find legheader number
								SET @Truck = 'UNKNOWN'
							IF @CheckcallStrict = 'N'
								BEGIN --rule 1. aka old behavior
									IF ISNULL(@lgh_number, 0) = 0 
									--2nd PTS 56524 method - Related Hotfix JR@TMW
										set @lgh_number=(select top 1 lgh_number
										from legheader where lgh_driver1=@Driver and lgh_outstatus in ('STD','CMP')
										and @DateAndTime between lgh_startdate and lgh_enddate order by lgh_startdate)
									-- PTS 56524 


									IF ISNULL(@lgh_number, 0) > 0
										BEGIN
											SELECT @lgh_date = ISNULL(lgh_startdate, '19500101'), @Truck = lgh_tractor
												FROM legheader (NOLOCK)
												WHERE lgh_number = @lgh_number
										END
										
								END --@CheckcallStrict
							ELSE
								BEGIN -- new assignment process via pts 71016
								DECLARE @wereDONE char(1) -- PTS81649
								SET @wereDONE = 'N' --a Y when we complete rule 2.b.i or ii successfuly
								SET @AsgnType = 'DRV' 
								
								SET @lgh_number=(SELECT TOP 1 lgh_number from assetassignment
								where asgn_type = 'DRV' and asgn_status = 'CMP'
								and asgn_id = @Driver
								and @DateAndTime between asgn_date and asgn_enddate
								ORDER BY asgn_date desc)
									
								IF (ISNULL(@lgh_number, 0) <> 0 )
									Begin -- rule 2.b.i
									--@driver & @AsgnType already set							
									select @Truck = lgh_tractor from legheader
										where lgh_number=@lgh_number
									SET @wereDONE='Y'
									end
								else
									begin
									SET @lgh_number=(SELECT TOP 1 lgh_number from assetassignment
									where asgn_type = 'DRV' and asgn_status = 'STD'
									and asgn_id = @Driver
									and @DateAndTime > asgn_date
									ORDER BY asgn_date desc)
									IF (ISNULL(@lgh_number, 0) <> 0 )
										Begin -- rule 2.b.ii
										--@driver & @AsgnType already set							
										select @Truck = lgh_tractor from legheader
											where lgh_number=@lgh_number
										SET @wereDONE='Y'
										end								
									end

								IF @wereDONE='N'
									BEGIN -- rule 2.b.iii - very complex
										DECLARE @prev_drv_leg int, @next_drv_leg int
										-- look for prev and next legs of driver
										select @prev_drv_leg = (select top 1 lgh_number  from assetassignment
												where asgn_type = 'DRV' and asgn_status ='CMP'
												and asgn_id = @Driver
												and @DateAndTime > asgn_enddate 
												ORDER BY asgn_enddate desc)		--WHAT about apocalyps dates!?

										select @next_drv_leg =(select top 1 lgh_number  from assetassignment
												where asgn_type = 'DRV' and asgn_status in ('CMP','STD')
												and asgn_id = @Driver
												and @DateAndTime < asgn_date 
												ORDER BY asgn_date )
												
										IF (isnull(@prev_drv_leg,0) <> 0) and  (isnull(@next_drv_leg,0 ) <>0)
											BEGIN -- rule 2.b.iii.1
											
											DECLARE @TrcID varchar(25), @TRCNextStartTime datetime, @TRCprevEndTime datetime
											DECLARE @TrcID2 varchar(25)
											DECLARE @DRVNextStartTime datetime, @DRVprevEndTime datetime
											
											--Next look up TRC for these two lgh's
											select @TrcID=asgn_id,@TRCprevEndTime =asgn_enddate from assetassignment
												where lgh_number= @prev_drv_leg
												and asgn_type = 'TRC'
												
											select @TrcID2=asgn_id,@TRCNextStartTime= asgn_date from assetassignment
												where lgh_number= @next_drv_leg
												and asgn_type = 'TRC'
												
											select @DRVprevEndTime =asgn_enddate from assetassignment
												where lgh_number= @prev_drv_leg 
												and asgn_id = @Driver --we KNOW the driver
												and asgn_type = 'DRV'
												
											select @DRVNextStartTime =asgn_date  from assetassignment
												where lgh_number= @next_drv_leg 
												and asgn_id = @Driver --we KNOW the driver
												and asgn_type = 'DRV'
											-- then if the TRC is the same, 
											-- check that DRV and the TRC's prev segment have exact matching enddates
											-- AND the next segments have exact matching DRV and TRC's asgn_dates
												if ( (@TRCNextStartTime = @DRVNextStartTime) and (@TRCprevEndTime = @DRVprevEndTime) 
												and  (@TrcID = @TrcID2) )
												begin -- rule 2.b.iii.1.a
													SET @AsgnType = 'DRV'
													--@driver already set
													SET @lgh_number=0
													SET @Truck =@TrcID
													
												end
												ELSE
												begin -- rule 2.b.iii.1.b
													SET @AsgnType = 'DRV'
													--@driver already set
													SET @lgh_number=0
													SET @Truck = 'UNKNOWN'
													
												end
											END--prev and next legs non zero.
										ELSE 
											IF (isnull(@prev_drv_leg,0) <> 0)
											-- aka we failed "isnull(@next_drv_leg,0 ) <>0"
											-- aka failed rule 2.b.iii.1 test 
											-- rule 2.b.iii.2
											BEGIN
												select @Truck = lgh_tractor from legheader where lgh_number = @prev_drv_leg
												if @Truck='UNKNOWN'
												begin -- rule 2.b.iii.2.b
													SET @AsgnType = 'DRV'
													--@driver already set
													SET @lgh_number=0
													SET @Truck = 'UNKNOWN'
													
												end
												else
												begin --continue rule 2.b.iii.2 check
													DECLARE @prev_trc_leg int, @next_trc_leg int
													
													select top 1 @prev_trc_leg = lgh_number,@TRCprevEndTime =asgn_enddate from assetassignment
														where asgn_type = 'TRC' and asgn_status in ('CMP','STD')
														and asgn_id = @Truck
														and @DateAndTime > asgn_enddate 
														ORDER BY asgn_enddate desc

													select @next_trc_leg =(select top 1 lgh_number  from assetassignment
														where asgn_type = 'TRC' and asgn_status in ('CMP','STD')
														and asgn_id = @Truck
														and @DateAndTime < asgn_date 
														ORDER BY asgn_date )
													
													if @next_trc_leg <> 0 or (@TRCprevEndTime <> @DRVprevEndTime)
													begin -- rule 2.b.iii.2.b
														SET @AsgnType = 'DRV'
														--@driver already set
														SET @lgh_number=0
														SET @Truck = 'UNKNOWN'
														
													end
													
												end  --end rule 2.b.iii.2 check
											END -- of rule 2.b.iii.2
											ELSE
											-- rule 2.b.iii.3
											BEGIN
												SET @AsgnType = 'DRV'
												--@driver already set
												SET @lgh_number=0
												SET @Truck = 'UNKNOWN'
											END -- rule 2.b.iii.3

									END -- lgh_number is 0'
								END -- else strict aka pts 71016

							-- this overwrites the @Truck assignment, strict or not strict - tractor profile trumphs all!
							IF @sTrcDrvBasis = 'P'
								BEGIN
									SELECT @Truck = ISNULL(MIN(trc_number), 'UNKNOWN') 
									FROM tractorprofile (NOLOCK) 
									WHERE trc_driver = @Driver
								END
						END -- substring 'DRV:'
						ELSE IF (SUBSTRING(@Truck,1,4) <> 'TRL:')
							BEGIN		
								SET @Event = 'TRP'

								-- Already looked for 'DRV' (ELSE IF) and  we use <>'TRL:' above so this IS a 'TRC'
							IF @CheckcallStrict = 'N'
								BEGIN --rule 1. aka old behavior
								-- Find Driver for this truck													
								
								-- PTS 56524 Related Hotfix JR@TMW
								set @lgh_number=(select top 1 lgh_number
								from legheader where lgh_tractor=@Truck and lgh_outstatus in ('STD','CMP')
								and @DateAndTime between lgh_startdate and lgh_enddate order by lgh_startdate)
								-- PTS 56524 EXEC dbo.tmail_get_lgh_number_sp2 NULL, NULL, @Truck, 8392448, @lgh_number OUT  -- ORDERNUMBER and MOVENUMBER are NULL, FLAGS = 256 + 512 + 1024 + 2048 + 8388608
								IF ISNULL(@lgh_number, 0) > 0
									BEGIN
										SELECT @lgh_date = ISNULL(lgh_startdate, '19500101'), @Driver = lgh_driver1
										FROM legheader  (NOLOCK)
										WHERE lgh_number = @lgh_number
									END
								ELSE
									BEGIN
										-- We could not find the legheader for this checkcall
										SET @lgh_number = 0
										SET @Driver = 'UNKNOWN'
									END										
								END --@CheckcallStrict
							ELSE
								BEGIN -- new assignment process via pts 71016
								SET @wereDONE = 'N' --a Y when we complete rule 2.a.i or ii successfuly
								SET @AsgnType = 'DRV' 
								
								SET @lgh_number=(SELECT TOP 1 lgh_number from assetassignment
								where asgn_type = 'TRC' and asgn_status = 'CMP'
								and asgn_id = @Truck
								and @DateAndTime between asgn_date and asgn_enddate
								ORDER BY asgn_date desc)
									
								IF (ISNULL(@lgh_number, 0) <> 0 )
									Begin -- rule 2.a.i
									--@truck & @AsgnType already set							
									select @Driver = lgh_driver1 from legheader
										where lgh_number=@lgh_number
									SET @wereDONE='Y'
									end
								else
									begin
									SET @lgh_number=(SELECT TOP 1 lgh_number from assetassignment
									where asgn_type = 'TRC' and asgn_status = 'STD'
									and asgn_id = @Truck
									and @DateAndTime > asgn_date
									ORDER BY asgn_date desc)
									IF (ISNULL(@lgh_number, 0) <> 0 )
										Begin -- rule 2.a.ii
										--@truck @AsgnType already set							
										select @Driver = lgh_driver1 from legheader
											where lgh_number=@lgh_number
										SET @wereDONE='Y'
										end								
									end

								IF @wereDONE='N'
									BEGIN -- rule 2.a.iii - very complex
										
										-- look for prev and next legs of driver
										select @prev_trc_leg = (select top 1 lgh_number  from assetassignment
												where asgn_type = 'TRC' and asgn_status ='CMP'
												and asgn_id = @Truck
												and @DateAndTime > asgn_enddate 
												ORDER BY asgn_enddate desc)		--WHAT about apocalyps dates!?

										select @next_trc_leg =(select top 1 lgh_number  from assetassignment
												where asgn_type = 'TRC' and asgn_status in ('CMP','STD')
												and asgn_id = @Truck
												and @DateAndTime < asgn_date 
												ORDER BY asgn_date )
												
										IF (isnull(@prev_trc_leg,0) <> 0) and  (isnull(@next_trc_leg,0 ) <>0)
											BEGIN -- rule 2.a.iii.1
											
											DECLARE @DrvID varchar(25)
											DECLARE @DrvID2 varchar(25)
											
											--Next look up drv for these two lgh's
											select @DrvID=asgn_id,@DRVprevEndTime =asgn_enddate from assetassignment
												where lgh_number= @prev_trc_leg
												and asgn_type = 'DRV'
												
											select @DrvID2=asgn_id,@DRVNextStartTime= asgn_date from assetassignment
												where lgh_number= @next_trc_leg
												and asgn_type = 'DRV'
												
											select @TRCprevEndTime =asgn_enddate from assetassignment
												where lgh_number= @prev_trc_leg 
												and asgn_id = @Truck --we KNOW the truck
												and asgn_type = 'TRC'
												
											select @TRCNextStartTime =asgn_date  from assetassignment
												where lgh_number= @next_trc_leg 
												and asgn_id = @Truck --we KNOW the truck
												and asgn_type = 'TRC'
											-- then if the DRV is the same, 
											-- check that DRV and the TRC's prev segment have exact matching enddates
											-- AND the next segments have exact matching DRV and TRC's asgn_dates
												if ( (@TRCNextStartTime = @DRVNextStartTime) and (@TRCprevEndTime = @DRVprevEndTime) 
												and  (@DrvID = @DrvID2) )
												begin -- rule 2.a.iii.1.a
													SET @AsgnType = 'DRV'
													--@truck already set
													SET @lgh_number=0
													SET @Driver =@DrvID
													
												end
												ELSE
												begin -- rule 2.a.iii.1.b
													SET @AsgnType = 'DRV'
													--@truck already set
													SET @lgh_number=0
													SET @Driver = 'UNKNOWN'
													
												end
											END--prev and next legs non zero.
										ELSE 
											IF (isnull(@prev_trc_leg,0) <> 0)
											-- aka we failed "isnull(@next_trc_leg,0 ) <>0"
											-- aka failed rule 2.a.iii.1 test 
											-- rule 2.a.iii.2
											BEGIN
												select @Driver = lgh_driver1 from legheader where lgh_number = @prev_trc_leg
												if @Driver='UNKNOWN'
												begin -- rule 2.a.iii.2.b
													SET @AsgnType = 'DRV'
													--@Truck & driver already set
													SET @lgh_number=0
													
												end
												else
												begin --continue rule 2.a.iii.2 check - driver is known
													
													select top 1 @prev_drv_leg = lgh_number,@DRVprevEndTime =asgn_enddate from assetassignment
														where asgn_type = 'DRV' and asgn_status in ('CMP','STD')
														and asgn_id = @Driver
														and @DateAndTime > asgn_enddate 
														ORDER BY asgn_enddate desc

													select @next_drv_leg =(select top 1 lgh_number  from assetassignment
														where asgn_type = 'DRV' and asgn_status in ('CMP','STD')
														and asgn_id = @Driver
														and @DateAndTime < asgn_date 
														ORDER BY asgn_date )
													
													if @next_drv_leg <> 0 or (@TRCprevEndTime <> @DRVprevEndTime)
													begin -- rule 2.a.iii.2.b
														SET @AsgnType = 'DRV'
														--@truck already set
														SET @lgh_number=0
														SET @Driver = 'UNKNOWN'
														
													end
													
												end  --end rule 2.a.iii.2 check
											END -- of rule 2.a.iii.2
											ELSE
											-- rule 2.a.iii.3
											BEGIN
												SET @AsgnType = 'DRV'
												--@truck already set
												SET @lgh_number=0
												SET @Driver = 'UNKNOWN'
											END -- rule 2.a.iii.3

									END -- lgh_number is 0'
								END -- else strict aka pts 71016


								if @sTrcDrvBasis = 'P'  --{28524} Override Driver with Tractor Profile Driver
									BEGIN
										SELECT @Driver = ISNULL(trc_driver, 'UNKNOWN')
											FROM tractorprofile (NOLOCK)
											WHERE trc_number = @truck
									END
							END
						ELSE
							BEGIN		-- This is a trailer checkcall

								SET @Event = 'TRL'
								SET @TrailerCheckcall = 'Y'
								SET @Driver = 'UNKNOWN'
								SET @Trailer = SUBSTRING(@Truck,CHARINDEX(':',@Truck,1) + 1,LEN(@Truck))
								SET @Truck = 'UNKNOWN'
									
								IF @CheckcallStrict = 'N'
									BEGIN
									IF ISNULL(@lgh_number, 0) = 0 -- we failed in the AssetAssignment methods
									--2nd PTS 56524 method - Related Hotfix JR@TMW
										set @lgh_number=(select top 1 lgh_number
										from legheader where lgh_primary_trailer=@Trailer and lgh_outstatus in ('STD','CMP')
										and @DateAndTime between lgh_startdate and lgh_enddate order by lgh_startdate)
									
								-- Find Driver for this trailer	
									IF ISNULL(@lgh_number, 0) > 0
										BEGIN
											SELECT	@lgh_date = ISNULL(lgh_startdate, '19500101'), 
													@Driver = lgh_driver1
													--@Truck = lgh_tractor
											FROM legheader (NOLOCK)
											WHERE lgh_number = @lgh_number
										END
									ELSE
										BEGIN
											-- We could not find the legheader for this checkcall
											SET @lgh_number = 0
										END
									END -- strict=NO
							ELSE
--***** GOTTA FIX IT FROM HERE DOWN							
								BEGIN -- new assignment process via pts 71016
								SET @wereDONE = 'N' --a Y when we complete rule 2.c.i or ii successfuly
								SET @AsgnType = 'TRL' 
								
								SET @lgh_number=(SELECT TOP 1 lgh_number from assetassignment
								where asgn_type = 'TRL' and asgn_status = 'CMP'
								and asgn_id = @Trailer
								and @DateAndTime between asgn_date and asgn_enddate
								ORDER BY asgn_date desc)
									
								IF (ISNULL(@lgh_number, 0) <> 0 )
									Begin -- rule 2.c.i
									--@trailer & @AsgnType already set							
									select @Truck = lgh_tractor from legheader
										where lgh_number=@lgh_number
									SET @wereDONE='Y'
									end
								else
									begin
									SET @lgh_number=(SELECT TOP 1 lgh_number from assetassignment
									where asgn_type = 'TRL' and asgn_status = 'STD'
									and asgn_id = @Trailer
									and @DateAndTime > asgn_date
									ORDER BY asgn_date desc)
									IF (ISNULL(@lgh_number, 0) <> 0 )
										Begin -- rule 2.c.ii
										--@trailer & @AsgnType already set							
										select @Truck = lgh_tractor from legheader
											where lgh_number=@lgh_number
										SET @wereDONE='Y'
										end								
									end

								IF @wereDONE='N'
									BEGIN -- rule 2.c.iii - very complex
										DECLARE @prev_trl_leg int, @next_trl_leg int
										-- look for prev and next legs of driver
										select @prev_trl_leg = (select top 1 lgh_number  from assetassignment
												where asgn_type = 'TRL' and asgn_status ='CMP'
												and asgn_id = @Trailer
												and @DateAndTime > asgn_enddate 
												ORDER BY asgn_enddate desc)		--WHAT about apocalyps dates!?

										select @next_trl_leg =(select top 1 lgh_number  from assetassignment
												where asgn_type = 'TRL' and asgn_status in ('CMP','STD')
												and asgn_id = @Trailer
												and @DateAndTime < asgn_date 
												ORDER BY asgn_date )
												
										IF (isnull(@prev_trl_leg,0) <> 0) and  (isnull(@next_trl_leg,0 ) <>0)
											BEGIN -- rule 2.c.iii.1
											
											DECLARE @TRLNextStartTime datetime, @TRLprevEndTime datetime
											
											--Next look up TRC for these two lgh's
											select @TrcID=asgn_id,@TRCprevEndTime =asgn_enddate from assetassignment
												where lgh_number= @prev_trl_leg
												and asgn_type = 'TRC'
												
											select @TrcID2=asgn_id,@TRCNextStartTime= asgn_date from assetassignment
												where lgh_number= @next_trl_leg
												and asgn_type = 'TRC'
												
											select @TRLprevEndTime =asgn_enddate from assetassignment
												where lgh_number= @prev_trl_leg 
												and asgn_id = @Driver --we KNOW the driver
												and asgn_type = 'DRV'
												
											select @TRLNextStartTime =asgn_date  from assetassignment
												where lgh_number= @next_trl_leg 
												and asgn_id = @Driver --we KNOW the driver
												and asgn_type = 'DRV'
											-- then if the TRC is the same, 
											-- check that DRV and the TRC's prev segment have exact matching enddates
											-- AND the next segments have exact matching DRV and TRC's asgn_dates
												if ( (@TRCNextStartTime = @TRLNextStartTime) and (@TRCprevEndTime = @TRLprevEndTime) 
												and  (@TrcID = @TrcID2) )
												begin -- rule 2.c.iii.1.a
													SET @AsgnType = 'DRV'
													--@driver already set
													SET @lgh_number=0
													SET @Truck =@TrcID
													
												end
												ELSE
												begin -- rule 2.c.iii.1.b
													SET @AsgnType = 'DRV'
													--@driver already set
													SET @lgh_number=0
													SET @Truck = 'UNKNOWN'
													
												end
											END--prev and next legs non zero.
										ELSE 
											IF (isnull(@prev_trl_leg,0) <> 0)
											-- aka we failed "isnull(@next_trl_leg,0 ) <>0"
											-- aka failed rule 2.c.iii.1 test 
											-- rule 2.c.iii.2
											BEGIN
												select @Truck = lgh_tractor from legheader where lgh_number = @prev_trl_leg
												if @Truck='UNKNOWN'
												begin -- rule 2.c.iii.2.b
													SET @AsgnType = 'TRL'
													--@@trailer already set
													SET @lgh_number=0
													SET @Truck = 'UNKNOWN'
													
												end
												else
												begin --continue rule 2.c.iii.2 check --truck known
													
													select top 1 @prev_trc_leg = lgh_number,@TRCprevEndTime =asgn_enddate from assetassignment
														where asgn_type = 'TRC' and asgn_status in ('CMP','STD')
														and asgn_id = @Truck
														and @DateAndTime > asgn_enddate 
														ORDER BY asgn_enddate desc

													select @next_trc_leg =(select top 1 lgh_number  from assetassignment
														where asgn_type = 'TRC' and asgn_status in ('CMP','STD')
														and asgn_id = @Truck
														and @DateAndTime < asgn_date 
														ORDER BY asgn_date )
													
													if @next_trc_leg <> 0 or (@TRCprevEndTime <> @TRLprevEndTime)
													begin -- rule 2.c.iii.2.b
														SET @AsgnType = 'TRL'
														--@trailer already set
														SET @lgh_number=0
														SET @Truck = 'UNKNOWN'
														
													end
													
												end  --end rule 2.c.iii.2 check
											END -- of rule 2.c.iii.2
											ELSE
											-- rule 2.c.iii.3
											BEGIN
												SET @AsgnType = 'TRL'
												--@trailer already set
												SET @lgh_number=0
												SET @Truck = 'UNKNOWN'
											END -- rule 2.c.iii.3

									END -- lgh_number is 0'
								END -- else strict aka pts 71016

									
								END

		/************ Get Event code from LatLong Remark field ********************/
						--DWG, check for Event on LatLong Remark
						IF @Comment > '' 
							BEGIN	
								IF LEFT(@comment, 1) = '['
									IF CHARINDEX (']', @Comment) > 0 AND CHARINDEX (']', @Comment) < 9 --the ABBR is only 6 char, so if we are more than 8, with [], it is not it
										BEGIN
											SET @Event = SUBSTRING (@Comment , 2, CHARINDEX (']', @Comment) - 2 )
											SET @Comment = SUBSTRING(@Comment, CHARINDEX (']', @Comment) + 1, LEN(@Comment))
										END
							END
			
						IF @EmergencyMode > 0 
							SELECT	@DriverHome = NULL,
								@Mileage = 0,
								@MilesToFinal = -1,
								@ApproxMinutes = 0,
								@MinutesToFinal = 0
						ELSE
							BEGIN
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
											
														IF (@LastCkcHome = 'Y') -- Was the ckc_home of the last checkcall 'Y'?
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
																		SELECT @TempDate = ISNULL(MAX(mhl_end), @TempDate2) FROM manpowerhomelog (NOLOCK) WHERE mhl_start = @TempDate2
																		IF @TempDate < @TempDate2
																		-- It's a damaged record.  Ignore all checkcalls related to that home period.
																		SELECT @TempDate= @TempDate2
																	END
															
																-- Find first time driver was home after his prior home record.
																SELECT @TempDate2 = MIN(ckc_date) FROM checkcall (NOLOCK)
																	WHERE ckc_asgnid = @Driver
																		AND ckc_asgntype = 'DRV'
																		AND ckc_event = 'TRP'
																		AND ckc_home = 'Y'
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
										LEFT JOIN city (NOLOCK)
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

		/************ Insert into checkcall table if it's a new checkcall *******************/
						-- Change lat/long to seconds
						SET @ckc_latseconds = @Lat * 3600
						SET @ckc_longseconds = @Long * 3600
				
						-- Pre Check if this checkcall exists already
						IF (@vi_AllowDupCheckcalls > 0)
							SET @Precheck = -1
						ELSE
							BEGIN
								IF (@TrailerCheckcall = 'N')	-- Tractor checkcall
									SELECT @Precheck = ISNULL(MIN(ISNULL(ckc_number,0)), -1)
										FROM dbo.checkcall (NOLOCK)
										WHERE ckc_date = @DateAndTime
										  AND ((ckc_asgntype = 'DRV' AND ckc_asgnid = @Driver) OR ckc_tractor = @Truck)
										  AND ckc_event = @Event
								ELSE	
									SELECT @Precheck = ISNULL(MIN(ISNULL(ckc_number,0)), -1)
									FROM dbo.checkcall (NOLOCK)
									WHERE ckc_date = @DateAndTime
									  AND (ckc_asgntype = 'TRL' AND ckc_asgnid = @Trailer)
									  AND ckc_event = @Event
							END

						IF @Precheck = -1
							BEGIN
								IF (@TrailerCheckcall = 'N')
									BEGIN		-- Assign values for inserting a tractor checkcall
										SET @AsgnId = @Driver
										SET @AsgnType = 'DRV'
									END
								ELSE
									BEGIN		-- Assign values for inserting a trailer checkcall
								  		SET @AsgnId = @Trailer
										SET @AsgnType = 'TRL'
									END

								IF ISNULL(@Event, '') = ''
									SET @Event = 'TRP'

								INSERT INTO checkcall  (ckc_number,
											ckc_status,
											ckc_asgntype,
											ckc_asgnid,
											ckc_date,			--5

											ckc_event,
											ckc_city,
											ckc_comment,
											ckc_updatedby,
											ckc_updatedon,			--10
					
											ckc_latseconds,
											ckc_longseconds,
											ckc_lghnumber,
											ckc_tractor,
											ckc_extsensoralarm,		--15

											ckc_vehicleignition,
											ckc_milesfrom,
											ckc_directionfrom,
											ckc_validity,
											ckc_mtavailable,		--20

											ckc_cityname,
											ckc_state,
											ckc_zip,
											ckc_commentlarge,
											ckc_home, 			--25
									
											ckc_mileage,
											ckc_miles_to_final,
											ckc_minutes,
											ckc_minutes_to_final, 	
											ckc_Odometer,		--30

											TripStatus,
											ckc_odometer2,
											ckc_speed,
											ckc_speed2,		
											ckc_heading, 		--35

											ckc_gps_type,			
											ckc_gps_miles,	
											ckc_fuel_meter,
											ckc_idle_meter,		
											ckc_AssociatedMsgSN,	-- 40 - PTS 45517 - VMS

											ckc_ExtraData01,
											ckc_ExtraData02,
											ckc_ExtraData03,
											ckc_ExtraData04,
											ckc_ExtraData05,	--45

											ckc_ExtraData06,
											ckc_ExtraData07,
											ckc_ExtraData08,
											ckc_ExtraData09,
											ckc_ExtraData10,	--50

											ckc_ExtraData11,
											ckc_ExtraData12,
											ckc_ExtraData13,
											ckc_ExtraData14,
											ckc_ExtraData15,	--55

											ckc_ExtraData16,
											ckc_ExtraData17,
											ckc_ExtraData18,
											ckc_ExtraData19,
											ckc_ExtraData20)	--60
								VALUES (@ckc_number,
									'HIST',
									@AsgnType,
									@AsgnID,
									@DateAndTime,			--5
					
									@Event,
									@cty_code,
									@Comment,
									'TMAIL',
									GetDate(),			--10

									@ckc_latseconds,
									@ckc_longseconds,
									@lgh_number,
									@Truck,
									'',				--15

									@VehicleIgnition,
									@Miles,
									@Direction,
									'',
									'',				--20

									@CityName,
									@State,
									@Zip,
									@LargeComment,
									@DriverHome,			--25

									ROUND(@Mileage,0),	
									ROUND(@MilesToFinal,0),
									@ApproxMinutes,
									@MinutesToFinal,	
									@OdometerReading,	--30

									@TripStatus,
									@odometer2,
									@speed,
									@speed2,		
									@heading, 		--35

									@gps_type,			
									@gps_miles,	
									@fuel_meter,
									@idle_meter,	
									@AssociatedMsgSN,	--40 - PTS 45517 - VMS

									@ExtraData01,
									@ExtraData02,
									@ExtraData03,
									@ExtraData04,
									@ExtraData05,	--45

									@ExtraData06,
									@ExtraData07,
									@ExtraData08,
									@ExtraData09,
									@ExtraData10,	--50

									@ExtraData11,
									@ExtraData12,
									@ExtraData13,
									@ExtraData14,
									@ExtraData15,	--55

									@ExtraData16,
									@ExtraData17,
									@ExtraData18,
									@ExtraData19,
									@ExtraData20)	--60

								IF EXISTS(SELECT * FROM generalinfo (NOLOCK) WHERE gi_name = 'TMailCkcAAD' and gi_string1 = 'Y')
									if isnull(@TripStatus,-1) >= 0
										IF @TrailerCheckcall = 'N'
											BEGIN
												if (SELECT isnull(trc_useGeofencing,'Y') 
															FROM tractorprofile (NOLOCK) 
															WHERE trc_number = @truck) in ('Y','T')
													exec dbo.tm_ckc_AadMain @ckc_number  -- auto arrive and depart macros based ON geofence.											
											END
										ELSE
											BEGIN
												IF @TrailerCheckcall = 'Y'
												BEGIN
												if (SELECT isnull(trl_useGeofencing,'Y') 
													FROM trailerprofile (NOLOCK) 
													WHERE trl_number = @trailer) in ('Y','T')
													exec dbo.tm_ckc_AadMain @ckc_number  -- auto arrive and depart macros based ON geofence.												
												END
												
											END 
							
								-- update airmiles on current and subsequent checkcall if current checkcall was received out of order
								exec dbo.TM_CKC_UpdateMileage @ckc_number 
							END	-- Precheck
						ELSE
							-- Checkcall already exists, so log error if so configured
							IF (@LogDupCheckcallErrors = 1)
								INSERT INTO dbo.tblPSCheckCallError (
										Tractor,
										DateInserted,					
										DateAndTime,
										Lat,
										Long,			--5

										Miles,
										Direction,
										CityName,
										State,
										Zip,			--10

										Comments,
										LargeComments,
										VehicleIgnition,
										ErrorNote,
										odometer,		--15

										odometer2,
										speed,
										speed2,		
										heading, 		
										gps_type,		--20

										gps_miles,		
										fuel_meter,
										idle_meter,
										AssociatedMsgSN,	-- PTS 45517 - VMS
										ckc_ExtraData01,	--25

										ckc_ExtraData02,
										ckc_ExtraData03,
										ckc_ExtraData04,
										ckc_ExtraData05,
										ckc_ExtraData06,	--30

										ckc_ExtraData07,
										ckc_ExtraData08,
										ckc_ExtraData09,
										ckc_ExtraData10,
										ckc_ExtraData11,	--35

										ckc_ExtraData12,
										ckc_ExtraData13,
										ckc_ExtraData14,
										ckc_ExtraData15,
										ckc_ExtraData16,	--40

										ckc_ExtraData17,	
										ckc_ExtraData18,
										ckc_ExtraData19,
										ckc_ExtraData20)	--44
								VALUES (@Truck,
									GETDATE(),
									@DateAndTime,
									@ckc_latseconds,
									@ckc_longseconds,			--5

									@Miles,
									@Direction,
									@CityName,			
									@State,
									@Zip,			--10

									@Comment,
									@LargeComment,
									@VehicleIgnition,
									@ErrorInfo,
									@OdometerReading,	--15

									@odometer2,
									@speed,
									@speed2,		
									@heading, 		
									@gps_type,		--20

									@gps_miles,	
									@fuel_meter,
									@idle_meter,
									@AssociatedMsgSN,		-- PTS 45517 - VMS
									@ExtraData01,	--25

									@ExtraData02,
									@ExtraData03,
									@ExtraData04,
									@ExtraData05,	
									@ExtraData06,	--30

									@ExtraData07,
									@ExtraData08,
									@ExtraData09,
									@ExtraData10,	
									@ExtraData11,	--35

									@ExtraData12,
									@ExtraData13,
									@ExtraData14,
									@ExtraData15,	
									@ExtraData16,	--40

									@ExtraData17,
									@ExtraData18,
									@ExtraData19,
									@ExtraData20)	--44

/************ Update manpowerprofile if necessary *******************/
						IF (@Driver <> '' AND @TrailerCheckcall = 'N' AND @Driver <> 'UNKNOWN')
							BEGIN
								-- START PTS64388
								IF @Precheck = -1		--is a new checkcall 
									BEGIN
										SET @Driver_ckc_asgnid = CASE WHEN UPPER(ISNULL(@asgnid, 'UNKNOWN')) = 'UNKNOWN' THEN @Driver ELSE @asgnid END -- if ckc_asgnid is null or 'unknown', use @Driver

										SELECT TOP 1 @mpp_subsistence_eligible = UPPER(ISNULL(mpp_subsistence_eligible, 'N')) FROM dbo.manpowerprofile (NOLOCK) WHERE mpp_id = @Driver_ckc_asgnid;		--PTS72000
										IF @asgntype = 'DRV' AND @mpp_subsistence_eligible = 'Y' BEGIN																									--PTS72000		
											IF OBJECT_ID('driversubsistence', 'u') IS NOT NULL AND (select count(*) from sys.objects o inner join sys.parameters p on p.object_id = o.object_id where o.name = 'sp_checkcall_subsistence_calculation' ) = 6	BEGIN	-- PTS70584
												-- insert/update table dbo.driversubsistence		-- PTS70584, PTS71408
												exec sp_executesql N'EXEC sp_checkcall_subsistence_calculation @Driver_ckc_asgnid, @ckc_number, @Lat, @Long, @DateAndTime, @asgntype',
													N'@Driver_ckc_asgnid varchar(13), @ckc_number INT, @Lat float, @Long float, @DateAndTime datetime, @asgntype varchar(30)',
													@Driver_ckc_asgnid = @Driver_ckc_asgnid, @ckc_number = @ckc_number, @Lat = @Lat, @Long = @Long, @DateAndTime = @DateAndTime, @asgntype = @asgntype
											END
										END
										-- START PTS73013 - if driver 2 exists, insert/update driver subsistence for him too
										SELECT @Driver_ckc_asgnid = CASE WHEN ISNULL(lgh_driver2,'UNKNOWN') = 'UNKNOWN' THEN '' ELSE lgh_driver2 END FROM legheader (NOLOCK) WHERE lgh_number = @lgh_number
										set @mpp_subsistence_eligible = 'N'
										SELECT TOP 1 @mpp_subsistence_eligible = UPPER(ISNULL(mpp_subsistence_eligible, 'N')) FROM dbo.manpowerprofile (NOLOCK) WHERE mpp_id = @Driver_ckc_asgnid;
										IF @mpp_subsistence_eligible = 'Y' BEGIN
											exec sp_executesql N'EXEC sp_checkcall_subsistence_calculation @Driver_ckc_asgnid, @ckc_number, @Lat, @Long, @DateAndTime, @asgntype',
												N'@Driver_ckc_asgnid varchar(13), @ckc_number INT, @Lat float, @Long float, @DateAndTime datetime, @asgntype varchar(30)',
												@Driver_ckc_asgnid = @Driver_ckc_asgnid, @ckc_number = @ckc_number, @Lat = @Lat, @Long = @Long, @DateAndTime = @DateAndTime, @asgntype = @asgntype
										END	
										-- END PTS73013									
										-- START PTS64370
										IF OBJECT_ID('DriverEmergencyAlerts', 'u') IS NOT NULL AND OBJECT_ID('sp_checkcall_DriverEmergencyAlerts', 'p') IS NOT NULL					-- PTS70584
										BEGIN
											SELECT  TOP 1 
												@stp_NextStop_Number = stops.stp_number ,
												@stp_NextStop_City = stops.stp_city,
												@stp_arrivaldate = stp_arrivaldate,
												@cmp_id = stops.cmp_id					-- PTS70584
											FROM stops (NOLOCK)
											LEFT JOIN company (NOLOCK)
												ON stops.cmp_id = company.cmp_id
											LEFT JOIN city (NOLOCK)
												ON stops.stp_city = city.cty_code
											WHERE lgh_number = @lgh_number
												AND stops.stp_status = 'OPN'
											ORDER BY stp_mfh_sequence;
											-- START PTS70584
											IF (select count(*) from sys.objects o inner join sys.parameters p on p.object_id = o.object_id where o.name = 'sp_checkcall_DriverEmergencyAlerts' ) = 10 										
												exec sp_executesql N'EXEC sp_checkcall_DriverEmergencyAlerts @Driver_ckc_asgnid, @lgh_number, @Lat, @Long, 0, 0, @stp_NextStop_Number, @stp_NextStop_City, @stp_arrivaldate, @cmp_id',
													N'@Driver_ckc_asgnid VARCHAR(13), @lgh_number INT, @Lat DECIMAL(12, 4), @Long DECIMAL(12, 4), @LatSec INT, @LongSec INT, @stp_NextStop_Number INT, @stp_NextStop_City INT, @stp_arrivaldate DATETIME, @cmp_id VARCHAR(8)',
													@Driver_ckc_asgnid = @Driver_ckc_asgnid, @lgh_number = @lgh_number, @Lat = @Lat, @Long = @Long, @LatSec = 0, @LongSec = 0, @stp_NextStop_Number = @stp_NextStop_Number, @stp_NextStop_City = @stp_NextStop_City, @stp_arrivaldate = @stp_arrivaldate, @cmp_id = @cmp_id
											
											IF (select count(*) from sys.objects o inner join sys.parameters p on p.object_id = o.object_id where o.name = 'sp_checkcall_DriverEmergencyAlerts' ) = 9 										
												exec sp_executesql N'EXEC sp_checkcall_DriverEmergencyAlerts @Driver_ckc_asgnid, @lgh_number, @Lat, @Long, 0, 0, @stp_NextStop_Number, @stp_NextStop_City, @stp_arrivaldate',
													N'@Driver_ckc_asgnid VARCHAR(13), @lgh_number INT, @Lat DECIMAL(12, 4), @Long DECIMAL(12, 4), @LatSec INT, @LongSec INT, @stp_NextStop_Number INT, @stp_NextStop_City INT, @stp_arrivaldate DATETIME',
													@Driver_ckc_asgnid = @Driver_ckc_asgnid, @lgh_number = @lgh_number, @Lat = @Lat, @Long = @Long, @LatSec = 0, @LongSec = 0, @stp_NextStop_Number = @stp_NextStop_Number, @stp_NextStop_City = @stp_NextStop_City, @stp_arrivaldate = @stp_arrivaldate												
										END
										-- END PTS64370, PTS70584
									END
								-- END PTS64388

								SELECT @TempDate = ISNULL(mpp_gps_date, '19500101')
									FROM manpowerprofile (NOLOCK)
									WHERE mpp_id = @Driver
								
								IF (@TempDate < @DateAndTime)
									BEGIN
										-- Strip the checkcall's timestamp to just its date portion.
										SET @TempDate = CONVERT(datetime, CONVERT(varchar(10), @DateAndTime, 120)) 
									
										SET @SmallTempMileage = 0
										SET @SmallTempMinutes = 0

										IF @NoMiles = 0 AND @EmergencyMode = 0
											BEGIN
												SELECT @SmallTempMinutes = SUM(ckc_minutes)
													FROM checkcall(NOLOCK)
													WHERE ckc_date >= @TempDate
													  AND ckc_asgntype = 'DRV'
													  AND ckc_asgnid = @Driver

												IF @MileDay7FromCheckcall = 'Y'
													SELECT @SmallTempMileage = SUM(ckc_mileage)
														FROM checkcall (NOLOCK)
														WHERE ckc_date >= DATEADD(day, -6, @TempDate)
														  AND ckc_asgntype = 'DRV'
														  AND ckc_asgnid = @Driver
											END

										IF @SmallTempMinutes > 30000
											SET @SmallTempMinutes = 30000
							
										IF @SmallTempMileage > 30000
											SET @SmallTempMileage = 30000

										IF @MileDay7FromCheckcall = 'Y'
											UPDATE manpowerprofile
												SET mpp_gps_desc = LEFT(@Comment + ' [IGN:' + @VehicleIgnition + ']', 45),
													mpp_gps_date = @DateAndTime,
													mpp_gps_latitude = @ckc_latseconds,
													mpp_gps_longitude = @ckc_longseconds,
													mpp_travel_minutes = @SmallTempMinutes,
													mpp_mile_day7 = @SmallTempMileage,
													mpp_gps_odometer = CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN mpp_gps_odometer ELSE @OdometerReading END
												WHERE mpp_id = @Driver AND
													(
													ISNULL(mpp_gps_desc, '') <> ISNULL(@Comment + ' [IGN:' + @VehicleIgnition + ']', '')
													OR ISNULL(mpp_gps_date, '20491231 23:59') <> ISNULL(@DateAndTime, '20491231 23:59')
													OR ISNULL(mpp_gps_latitude, -9999999) <> ISNULL(@ckc_latseconds, -9999999)
													OR ISNULL(mpp_gps_longitude, -9999999) <> ISNULL(@ckc_longseconds, -9999999)
													OR ISNULL(mpp_travel_minutes, -9999999) <> ISNULL(@SmallTempMinutes, -9999999)
													OR ISNULL(mpp_mile_day7, -9999999) <> ISNULL(@SmallTempMileage, -9999999)
													OR ISNULL(mpp_gps_odometer, -9999999) <> ISNULL(CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN mpp_gps_odometer ELSE @OdometerReading END, -9999999)
													)
										ELSE
											UPDATE manpowerprofile
												SET mpp_gps_desc = @Comment + ' [IGN:' + @VehicleIgnition + ']',
													mpp_gps_date = @DateAndTime,
													mpp_gps_latitude = @ckc_latseconds,
													mpp_gps_longitude = @ckc_longseconds,
													mpp_travel_minutes = @SmallTempMinutes,
													--mpp_mile_day7 = @SmallTempMileage, don't update mile_day7 if GI setting @MileDay7FromCheckcall is off
													mpp_gps_odometer = CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN mpp_gps_odometer ELSE @OdometerReading END
												WHERE mpp_id = @Driver AND
													(
													ISNULL(mpp_gps_desc, '') <> ISNULL(@Comment + ' [IGN:' + @VehicleIgnition + ']', '')
													OR ISNULL(mpp_gps_date, '20491231 23:59') <> ISNULL(@DateAndTime, '20491231 23:59')
													OR ISNULL(mpp_gps_latitude, -9999999) <> ISNULL(@ckc_latseconds, -9999999)
													OR ISNULL(mpp_gps_longitude, -9999999) <> ISNULL(@ckc_longseconds, -9999999)
													OR ISNULL(mpp_travel_minutes, -9999999) <> ISNULL(@SmallTempMinutes, -9999999)
													OR ISNULL(mpp_mile_day7, -9999999) <> ISNULL(@SmallTempMileage, -9999999)
													OR ISNULL(mpp_gps_odometer, -9999999) <> ISNULL(CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN mpp_gps_odometer ELSE @OdometerReading END, -9999999)
													)


									END
							END

				/************ Update tractorprofile if a tractor checkcall *******************/
						IF (@TrailerCheckcall = 'N')
							BEGIN
								SELECT @TempDate = ISNULL(trc_gps_date, '19500101')
									FROM tractorprofile (NOLOCK)
									WHERE trc_number = @truck
								IF (@TempDate < @DateAndTime)
									UPDATE tractorprofile
										SET     trc_gps_desc = @Comment + ' [IGN:' + @VehicleIgnition + ']', 
											trc_gps_date = @DateAndTime,
											trc_gps_latitude = @ckc_latseconds,
											trc_gps_longitude = @ckc_longseconds,
											trc_gps_odometer = CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN trc_gps_odometer ELSE @OdometerReading END
										WHERE trc_number = @Truck AND
											(
											ISNULL(trc_gps_desc, '') <> ISNULL(@Comment + ' [IGN:' + @VehicleIgnition + ']', '')
											OR ISNULL(trc_gps_date, '20491231 23:59') <> ISNULL(@DateAndTime, '20491231 23:59')
											OR ISNULL(trc_gps_latitude, -9999999) <> ISNULL(@ckc_latseconds, -9999999)
											OR ISNULL(trc_gps_longitude, -9999999) <> ISNULL(@ckc_longseconds, -9999999)
											OR ISNULL(trc_gps_odometer, -9999999) <> ISNULL(CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN trc_gps_odometer ELSE @OdometerReading END, -9999999)
											)
							END
						ELSE
							BEGIN
								SELECT @TempDate = ISNULL(trl_gps_date, '19500101')
									FROM trailerprofile (NOLOCK)
									WHERE trl_id = @trailer
								IF (@TempDate < @DateAndTime)
									BEGIN
										set @trl_gps_desc = LEFT(@Comment, 247) + ' [IGN:' + @VehicleIgnition + ']'
										UPDATE trailerprofile
											SET     trl_gps_desc = @trl_gps_desc,
												trl_gps_date = @DateAndTime,
												trl_gps_latitude = @ckc_latseconds,
												trl_gps_longitude = @ckc_longseconds,
												trl_gps_Odometer = CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN trl_gps_Odometer ELSE @OdometerReading END
											WHERE trl_id = @Trailer AND
												(
												ISNULL(trl_gps_desc, '') <> ISNULL(@Comment + ' [IGN:' + @VehicleIgnition + ']', '')
												OR ISNULL(trl_gps_date, '20491231 23:59') <> ISNULL(@DateAndTime, '20491231 23:59')
												OR ISNULL(trl_gps_latitude, -9999999) <> ISNULL(@ckc_latseconds, -9999999)
												OR ISNULL(trl_gps_longitude, -9999999) <> ISNULL(@ckc_longseconds, -9999999)
												OR ISNULL(trl_gps_Odometer, -9999999) <> ISNULL(CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN trl_gps_Odometer ELSE @OdometerReading END, -9999999)
												)
									END
							END

						-- Delete the position report from tblLatLongs
						DELETE tblCheckcallXfc
							WHERE SN = @SN   

						-- Get next position report
						SELECT @SN = ISNULL(MIN(SN), -1) 
							FROM tblCheckcallXfc (NOLOCK)
							WHERE SN > @SN

						-- Get the next ckc_number
						SET @ckc_number = @ckc_number + 1
					END  -- While
			END --@ckc_number <> -1)
	END --(@NbrCheckcalls > 0)


GO
GRANT EXECUTE ON  [dbo].[tmail_transfer_checkcall_xfc] TO [public]
GO
