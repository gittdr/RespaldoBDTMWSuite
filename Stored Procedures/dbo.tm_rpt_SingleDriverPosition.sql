SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_rpt_SingleDriverPosition] @DriverName varchar(50),
												 @IncludeRetired int

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
*  05/01/03 MZ: TotalMail based Single driver position 
****************************************************************/

-- Create temp table to hold results
CREATE TABLE #Fleet (ckc_driver varchar(50),
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

-- Get the MCT for the current tractor for this driver
SELECT @MctSN = ISNULL(tblTrucks.DefaultCabUnit, 0)
FROM tblTrucks (NOLOCK), tblDrivers (NOLOCK)
WHERE tblDrivers.Name = @DriverName
	AND tblDrivers.CurrentTruck = tblTrucks.SN

-- Get the last position report for this tractor
SELECT @WorkDate = ISNULL(MAX(DateAndTime),'19500101')
FROM dbo.tblLatLongs
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
		FROM dbo.tblLatLongs
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
		INSERT INTO #Fleet (ckc_driver,
							ckc_date,
							ckc_milesfrom,
							ckc_directionfrom,
							ckc_vehicleignition,
							ckc_cityname,
							ckc_state,
							ckc_latseconds,
							ckc_longseconds,
							ckc_commentlarge)
		VALUES (@DriverName,
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
		-- Delete any drivers that are retired if @IncludeRetired = 1
		DELETE dbo.#Fleet
		FROM dbo.#Fleet, dbo.tblDrivers 
		WHERE dbo.#Fleet.ckc_driver = dbo.tblDrivers.Name
			AND dbo.tblDrivers.Retired > 0
  END

-- Pull all the results
SELECT  ckc_driver,
	CONVERT(VARCHAR(26), ckc_date) as ckc_date,
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
GRANT EXECUTE ON  [dbo].[tm_rpt_SingleDriverPosition] TO [public]
GO
