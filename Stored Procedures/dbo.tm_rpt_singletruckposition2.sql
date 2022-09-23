SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_rpt_singletruckposition2] @TruckName varchar(15),
						@IncludeRetired int,
						@SysTZHrs int,
						@SysTZMin int,
						@SysDSTCode int,
						@UsrTZHrs int,
						@UsrTZMin int,
						@UsrDSTCode int

AS

SET NOCOUNT ON 

DECLARE @WorkDate datetime,
	@WorkDir char (3),
	@WorkMilesFrom float,
	@WorkIgnition char (1),
	@WorkCity char (16),
	@WorkState varchar (6),
	@WorkLat int,
	@WorkLong int,
	@WorkComment varchar (254),
	@Failed int,
	@MctSN int,
	@LargeDirection varchar(3),
	@LargeMiles float,
	@LargeCityName varchar(16),
	@LargeState varchar(6),
	@sT_1 varchar(200),	
	@sT_2 varchar(20),
	@sT_dir varchar(10)

/****************************************************************
* 07/27/00 MZ: TotalMail based Single tractor position 
* 05/25/01 DAG: Converting for international date format
* 08/27/01 DAG: Change state lengths to 6 for International.
* 11/27/01 MZ: Added TZ conversion calls in new version (2)
****************************************************************/

-- Create temp table to hold results
CREATE TABLE #Fleet 	(ckc_tractor char(15),
			 ckc_date datetime,
			 ckc_milesfrom float,
			 ckc_directionfrom char(3),
			 ckc_vehicleignition char(1),
			 ckc_latseconds int,
			 ckc_longseconds int,
			 ckc_cityname char(16),
			 ckc_state varchar(6),
			 ckc_commentlarge varchar(254))

SELECT @Failed = 0
	
-- Get the MCT for this tractor
SELECT @MctSN = ISNULL(DefaultCabUnit,0)
FROM tblTrucks (NOLOCK)
WHERE dbo.tblTrucks.Truckname = @TruckName

-- Get the last position report for this tractor
SELECT @WorkDate = ISNULL(MAX(DateAndTime),'19500101')
FROM dbo.tblLatLongs (NOLOCK)
WHERE dbo.tblLatLongs.Unit = @MctSN

IF (@WorkDate <> '19500101')
  BEGIN
	SELECT  @WorkDir = ISNULL(Direction, 'Z'),
		@WorkMilesFrom = ISNULL(Miles, 0),
		@WorkIgnition = ISNULL(VehicleIgnition, ''),
		@WorkCity = ISNULL(CityName, ''),
		@WorkState = ISNULL(State, ''),
		@WorkLat = 3600 * ISNULL(Lat,0),
		@WorkLong = 3600 * ISNULL(Long,0),
		@LargeDirection = ISNULL(NearestLargeCityDirection, ''),
		@LargeCityName = ISNULL(NearestLargeCityName,''),
		@LargeState = ISNULL(NearestLargeCityState,''),
		@LargeMiles = ISNULL(NearestLargeCityMiles,0)
	FROM dbo.tblLatLongs (NOLOCK)
	WHERE dbo.tblLatLongs.Unit = @MctSN
		AND dbo.tblLatLongs.DateAndTime = @WorkDate

	-- If the last position was no good, or was a fuel purchase record,
	-- keep trying to find a valid checkcall
	WHILE @WorkDir = 'Z' OR @WorkDir = 'BAD'
	  BEGIN
		SELECT @WorkDate = ISNULL(MAX(DateAndTime),'19500101')
		FROM dbo.tblLatLongs (NOLOCK)
		WHERE dbo.tblLatLongs.Unit = @MctSN
			AND dbo.tblLatLongs.DateAndTime < @WorkDate

		IF @WorkDate <> '19500101'
		  BEGIN
			SELECT  @WorkDir = ISNULL(Direction, 'Z'),
				@WorkMilesFrom = ISNULL(Miles, 0),
				@WorkIgnition = ISNULL(VehicleIgnition, ''),
				@WorkCity = ISNULL(CityName, ''),
				@WorkState = ISNULL(State, ''),
				@WorkLat = 3600 * ISNULL(Lat,0),
				@WorkLong = 3600 * ISNULL(Long,0),
				@LargeDirection = ISNULL(NearestLargeCityDirection, ''),
				@LargeCityName = ISNULL(NearestLargeCityName,''),
				@LargeState = ISNULL(NearestLargeCityState,''),
				@LargeMiles = ISNULL(NearestLargeCityMiles,0)
			FROM dbo.tblLatLongs (NOLOCK)
			WHERE dbo.tblLatLongs.Unit = @MctSN
				AND dbo.tblLatLongs.DateAndTime = @WorkDate
		  END
		ELSE
		  BEGIN
			-- Couldn't find a valid checkcall, so fail for this tractor
			SELECT @Failed = 1	
			BREAK
		  END
	  END

	IF @Failed = 0
	  BEGIN
		-- Construct the Nearest Large City string
		IF @LargeCityName = ''
			SELECT @WorkComment = ''
		ELSE
			IF @LargeMiles = 0
				SELECT @WorkComment = '@ ' + @LargeCityName + ', ' + @LargeState
			ELSE
			  BEGIN
				SELECT @sT_1 = '~1 miles ~2 of ~3, ~4'	-- Translate this string as is
				EXEC dbo.tm_t_sp @sT_1 out, 1, ''
	
				SELECT @sT_dir = @LargeDirection	-- Translate the direction
				EXEC dbo.tm_t_sp @sT_dir out, 1, ''

				SELECT @sT_2 = CONVERT(varchar(8), @LargeMiles)	-- Convert the miles to a string
		
				EXEC dbo.tm_sprint @sT_1 out, @sT_2, @sT_dir, @LargeCityName, @LargeState, '', '', '', '', '', ''
				SELECT @WorkComment = @sT_1				
			  END

		-- Got a valid checkcall so add it to our temp table
		INSERT INTO #Fleet     (ckc_tractor,
					ckc_date,
					ckc_milesfrom,
					ckc_directionfrom,
					ckc_vehicleignition,
					ckc_cityname,
					ckc_state,
					ckc_latseconds,
					ckc_longseconds,
					ckc_commentlarge)
		VALUES (@TruckName,
			@WorkDate,
			@WorkMilesFrom,
			@WorkDir,
			@WorkIgnition,
			@WorkCity,
			@WorkState,
			@WorkLat,
			@WorkLong,
			@WorkComment)
	  END
	ELSE	
		SELECT @Failed = 0	-- Reset failure flag

	IF @IncludeRetired = 0
		-- Delete any tractors that are retired if @IncludeRetired = 1
		DELETE dbo.#Fleet
		FROM dbo.#Fleet, dbo.tblTrucks
		WHERE dbo.#Fleet.ckc_tractor = dbo.tblTrucks.TruckName
			AND dbo.tblTrucks.Retired > 0
  END

-- Pull all the results
SELECT  ckc_tractor,
	CONVERT(VARCHAR(26), dbo.ChangeTZ(ckc_date, @SysTZHrs, @SysDSTCode, @SysTZMin, @UsrTZHrs, @UsrDSTCode, @UsrTZMin)) as ckc_date,
	ckc_milesfrom,
	ckc_directionfrom,
	ckc_vehicleignition,
	ckc_cityname,
	ckc_state,
	ckc_commentlarge,
	ckc_latseconds,
	ckc_longseconds
FROM dbo.#Fleet
GO
GRANT EXECUTE ON  [dbo].[tm_rpt_singletruckposition2] TO [public]
GO
