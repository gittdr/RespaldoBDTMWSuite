SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[tmail_Insert_CheckCall]
		@Truck varchar(30),				--1
		@Driver varchar(20),			--2
		@TrailerCheckcall varchar(1),	--3
		@DateAndTime varchar(30),		--4
		@Latitude varchar(20),			--5
		@Longitude varchar(20),			--6
		@Event varchar(3),				--7 -- Either TRL (Trailer) or TRP (truck checkcall)
		@sCty_code varchar(12),			--8 
		@Comment varchar(255),			--9
		@slgh_number varchar(12),		--10
		@VehicleIgnition varchar(1),	--11
		@sMiles varchar(10),			--12
		@Direction varchar(3),			--13
		@CityName varchar(16),			--14
		@State varchar(6),				--15
		@Zip varchar(10),				--16
		@LargeComment varchar(255),		--17
		@DriverHome varchar(1),			--18
		@sMileage varchar(10),			--19
		@sMilesToFinal varchar(10),		--20
		@sApproxMinutes varchar(10),	--21
		@sMinutesToFinal varchar(10),	--22
		@sOdometerReading varchar(20),	--23
		@sTripStatus varchar(5),		--24
		@sodometer2 varchar(20),		--25
		@sSpeed varchar(5),				--26
		@sSpeed2 varchar(5),			--27
		@sHeading varchar(12),			--28
		@sGPSType varchar(5),			--29
		@sGPSMiles varchar(10),			--30
		@sFuelMeter varchar(10),		--31
		@sIdleMeter varchar(10),		--32
		@sAssociatedMsgSN varchar(12),	--33
		@Flags varchar(12)				--34
AS


DECLARE	@Trailer varchar(20),
		@AsgnId varchar(30),		-- Either a driver id or a trailer id.
		@AsgnType varchar(30),		-- Either TRL (trailer) or DRV (driver)
		@Lat float,
		@Long float,
		@cty_code int,
		@lgh_number int,
		@Miles int,
		@Mileage int,
		@MilesToFinal int,
		@ApproxMinutes int,
		@MinutesToFinal int,
		@OdometerReading int,
		@TripStatus int,
		@odometer2 int,
		@Speed int,
		@speed2 int,
		@heading float,
		@gps_type int,
		@gps_miles float,
		@fuel_meter float,
		@idle_meter int,
		@AssociatedMsgSN int,
		@vi_AllowDupCheckcalls int,	-- 0 - No dups (default), 1 - Allow dups
		@Precheck int,				-- Does a checkcall for this tractor at this date/time already exist?
		@SmallTempMileage float,
		@SmallTempMinutes float,
		@ckc_number int,
		@LogDupCheckcallErrors int,
		@ErrorInfo varchar(255),
		@TempDate datetime,
		@EmergencyMode int,
		@NoMiles int,
		@MileDay7FromCheckcall char(1),		-- Turn on or off the floating 7 day mileage sum to ManPowerProfile
		@trl_gps_desc varchar(255)

	SET @Lat = CONVERT(Float, @Latitude)
	SET @Long = CONVERT(Float, @Longitude)
	SET @cty_code = CONVERT(int, @sCty_code)
	SET @lgh_number = CONVERT(int, @slgh_number)
	SET @Miles = CONVERT(int, @sMiles)
	SET @Mileage =  CONVERT(int, @sMileage)
	SET @MilesToFinal = CONVERT(int, @sMilesToFinal)
	SET @ApproxMinutes = CONVERT(int, @sApproxMinutes)
	SET @MinutesToFinal = CONVERT(int, @sMinutesToFinal)
	SET @OdometerReading = CONVERT(int, @sOdometerReading)
	SET @TripStatus = CONVERT(int, @sTripStatus)
	SET @odometer2 = CONVERT(int, @sodometer2)
	SET @Speed = CONVERT(int, @sSpeed)
	SET @speed2 = CONVERT(int, @sSpeed2)
	SET @heading = CONVERT(float, @sHeading)
	SET @gps_type = CONVERT(int, @sGPSType)
	SET @gps_miles = CONVERT(float, @sGPSMiles)
	SET @fuel_meter = CONVERT(float, @sFuelMeter)
	SET @idle_meter = CONVERT(int, @sIdleMeter)
	SET @AssociatedMsgSN = CONVERT(int, @sAssociatedMsgSN)

	SET @Lat = @Lat * 3600
	SET @Long = @Long * 3600

	-- MIZ {33912} - Allow duplicate checkcalls
	SET @vi_AllowDupCheckcalls = 0
	SELECT @vi_AllowDupCheckcalls = ISNULL(gi_integer1,0)
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'AlowDupCkc'

	SET @LogDupCheckcallErrors = 0	-- Default to not logging duplicate checkcalls
	SELECT @LogDupCheckcallErrors = ISNULL(gi_integer1, 0)
	FROM generalinfo (NOLOCK)
	WHERE gi_name =  'LogDupCheckcalls'

	SET @MileDay7FromCheckcall = 'Y'  -- default to calc floating 7 day total
	SELECT @MileDay7FromCheckcall = ISNULL(gi_string1, 'Y')
	FROM generalinfo (NOLOCK)
	WHERE gi_name =  'MileDay7FromCheckcall'

	-- Get the emergency configuration parameters
	SET @EmergencyMode = 0
	SELECT @EmergencyMode = ISNULL(PATINDEX('%EMERGENCY%', gi_string1), 0)
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'TMailCkcFlags'

	SET @NoMiles = 0
	SELECT @NoMiles = ISNULL(PATINDEX('%NOMILESUMM%', gi_string1), 0)
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'TMailCkcFlags'

	SET @ErrorInfo = 'A checkcall for this tractor at this date/time has already been entered into the checkcall table'

	SET @Trailer = @Truck
	if @TrailerCheckcall = 'Y' AND LEFT(@Truck, 4) = 'TRL:'
		SET @Trailer = SUBSTRING(@Truck, 5, DATALENGTH(@Truck)-4)
	
	IF ISNULL(@DriverHome, '') = ''
		SET @DriverHome = NULL

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

			EXECUTE @ckc_number = dbo.getsystemnumberblock 'CKCNUM','',1

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
						ckc_idle_meter,		--40

						ckc_AssociatedMsgSN)	-- PTS 45517 - VMS

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

				@Lat,
				@Long,
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
				@idle_meter,	--40

				@AssociatedMsgSN)		-- PTS 45517 - VMS

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
					AssociatedMsgSN)	-- PTS 45517 - VMS
			VALUES (@Truck,
				GETDATE(),
				@DateAndTime,
				@Lat,
				@Long,			--5

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
				@AssociatedMsgSN)		-- PTS 45517 - VMS

/************ Update manpowerprofile if necessary *******************/
		IF (@Driver <> '' AND @TrailerCheckcall = 'N' AND @Driver <> 'UNKNOWN')
			BEGIN
				SELECT @TempDate = ISNULL(mpp_gps_date, '19500101')
					FROM manpowerprofile (NOLOCK)
					WHERE mpp_id = @Driver
				
				IF (@TempDate < @DateAndTime)
					BEGIN
						-- Strip the checkcall's timestamp to just its date portion.
						SET @TempDate = CONVERT(datetime, CONVERT(varchar(30), @DateAndTime, 120)) 
					
						SET @SmallTempMileage = 0
						SET @SmallTempMinutes = 0

						IF @NoMiles = 0 AND @EmergencyMode = 0
							BEGIN
								SELECT @SmallTempMinutes = SUM(ckc_minutes)
									FROM checkcall (NOLOCK)
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
									mpp_gps_latitude = @Lat,
									mpp_gps_longitude = @Long,
									mpp_travel_minutes = @SmallTempMinutes,
									mpp_mile_day7 = @SmallTempMileage,
									mpp_gps_odometer = CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN mpp_gps_odometer ELSE @OdometerReading END
								WHERE mpp_id = @Driver AND
									(
									ISNULL(mpp_gps_desc, '') <> ISNULL(@Comment + ' [IGN:' + @VehicleIgnition + ']', '')
									OR ISNULL(mpp_gps_date, '20491231 23:59') <> ISNULL(@DateAndTime, '20491231 23:59')
									OR ISNULL(mpp_gps_latitude, -9999999) <> ISNULL(@Lat, -9999999)
									OR ISNULL(mpp_gps_longitude, -9999999) <> ISNULL(@Long, -9999999)
									OR ISNULL(mpp_travel_minutes, -9999999) <> ISNULL(@SmallTempMinutes, -9999999)
									OR ISNULL(mpp_mile_day7, -9999999) <> ISNULL(@SmallTempMileage, -9999999)
									OR ISNULL(mpp_gps_odometer, -9999999) <> ISNULL(CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN mpp_gps_odometer ELSE @OdometerReading END, -9999999)
									)
						ELSE
							UPDATE manpowerprofile
								SET mpp_gps_desc = @Comment + ' [IGN:' + @VehicleIgnition + ']',
									mpp_gps_date = @DateAndTime,
									mpp_gps_latitude = @Lat,
									mpp_gps_longitude = @Long,
									mpp_travel_minutes = @SmallTempMinutes,
									--mpp_mile_day7 = @SmallTempMileage, don't update mile_day7 if GI setting @MileDay7FromCheckcall is off
									mpp_gps_odometer = CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN mpp_gps_odometer ELSE @OdometerReading END
								WHERE mpp_id = @Driver AND
									(
									ISNULL(mpp_gps_desc, '') <> ISNULL(@Comment + ' [IGN:' + @VehicleIgnition + ']', '')
									OR ISNULL(mpp_gps_date, '20491231 23:59') <> ISNULL(@DateAndTime, '20491231 23:59')
									OR ISNULL(mpp_gps_latitude, -9999999) <> ISNULL(@Lat, -9999999)
									OR ISNULL(mpp_gps_longitude, -9999999) <> ISNULL(@Long, -9999999)
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
							trc_gps_latitude = @Lat,
							trc_gps_longitude = @Long,
							trc_gps_odometer = CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN trc_gps_odometer ELSE @OdometerReading END
						WHERE trc_number = @Truck AND
							(
							ISNULL(trc_gps_desc, '') <> ISNULL(@Comment + ' [IGN:' + @VehicleIgnition + ']', '')
							OR ISNULL(trc_gps_date, '20491231 23:59') <> ISNULL(@DateAndTime, '20491231 23:59')
							OR ISNULL(trc_gps_latitude, -9999999) <> ISNULL(@Lat, -9999999)
							OR ISNULL(trc_gps_longitude, -9999999) <> ISNULL(@Long, -9999999)
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
								trl_gps_latitude = @Lat,
								trl_gps_longitude = @Long,
								trl_gps_Odometer = CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN trl_gps_Odometer ELSE @OdometerReading END
							WHERE trl_id = @Trailer AND
								(
								ISNULL(trl_gps_desc, '') <> ISNULL(@Comment + ' [IGN:' + @VehicleIgnition + ']', '')
								OR ISNULL(trl_gps_date, '20491231 23:59') <> ISNULL(@DateAndTime, '20491231 23:59')
								OR ISNULL(trl_gps_latitude, -9999999) <> ISNULL(@Lat, -9999999)
								OR ISNULL(trl_gps_longitude, -9999999) <> ISNULL(@Long, -9999999)
								OR ISNULL(trl_gps_Odometer, -9999999) <> ISNULL(CASE WHEN ISNULL(@OdometerReading, 0) = 0 THEN trl_gps_Odometer ELSE @OdometerReading END, -9999999)
								)
					END
			END


	SELECT	@Ckc_Number CheckCallNumber, 
			@Precheck DuplicateCheckCallNumber, 
			@EmergencyMode EmergencyMode,
			@NoMiles NoMiles,
			@AsgnId AsgnId,
			@AsgnType AsgnType
GO
GRANT EXECUTE ON  [dbo].[tmail_Insert_CheckCall] TO [public]
GO
