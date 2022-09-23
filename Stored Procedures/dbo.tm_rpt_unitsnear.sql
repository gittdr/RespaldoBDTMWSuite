SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_rpt_unitsnear]

AS

/*****************************************************************
*   07/20/00 MZ: Created TotalMail based Units Near Report. 
*   05/25/01 DAG: Converting for international date format
*   08/27/01 DAG: Change state lengths to 6 for International.
*****************************************************************/

SET NOCOUNT ON

DECLARE @WorkTractor char(8),
	@WorkMCTSN int,
	@WorkDate datetime,
	@WorkDir varchar(3),
	@WorkMilesFrom float,
	@WorkIgnition char(1),
	@WorkCity varchar(16),
	@WorkState varchar(6),
	@LargeDirection varchar(3),
	@LargeMiles float,
	@LargeCityName varchar(16),
	@LargeState varchar(6),
	@WorkComment varchar (254),
	@WorkLat int,
	@WorkLong int,
	@Failed int,
	@sTranslateString varchar(200),	--Translation Strings
	@sT_1 varchar(200),	
	@sT_2 varchar(20),
	@sT_dir varchar(10)

-- Create temp table to hold results
CREATE TABLE dbo.#UnitsNear (ckc_tractor char(8),
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
	
-- Get the first MCT in tblLatLongs
SELECT @WorkMCTSN = ISNULL(MIN(Unit),0)
FROM dbo.tblLatLongs (NOLOCK)
WHERE ISNULL(Unit,0) > 0

WHILE @WorkMCTSN > 0
  BEGIN
	SET @WorkTractor = ''

	-- Get the tractor for this MCT
	SELECT @WorkTractor = ISNULL(TruckName,'')
	FROM dbo.tblTrucks (NOLOCK)
	WHERE DefaultCabUnit = @WorkMCTSN 

	IF (@WorkTractor > '')  -- We have a tractor, so we can continue
 	  BEGIN
		-- Get the last checkcall for this tractor
		SELECT @WorkDate = ISNULL(MAX(DateAndTime),'19500101')
		FROM dbo.tblLatLongs (NOLOCK)
		WHERE Unit = @WorkMCTSN

		IF (@WorkDate > '19500101')
		  BEGIN
			SELECT  @WorkDir = ISNULL(Direction, 'Z'),
				@WorkMilesFrom = ISNULL(Miles, 0),
				@WorkIgnition = ISNULL(VehicleIgnition, ''),
				@WorkCity = ISNULL(CityName, ''),
				@WorkState = ISNULL(State, ''),
				@LargeDirection = ISNULL(NearestLargeCityDirection, ''),
				@WorkLat = 3600 * ISNULL(Lat,0),
				@WorkLong = 3600 * ISNULL(Long,0),
				@LargeCityName = ISNULL(NearestLargeCityName,''),
				@LargeState = ISNULL(NearestLargeCityState,''),
				@LargeMiles = ISNULL(NearestLargeCityMiles,0)
			FROM dbo.tblLatLongs
			WHERE Unit = @WorkMCTSN
				AND DateAndTime = @WorkDate

			-- If the last position was no good, or was a fuel purchase record,
			-- keep trying to find a valid checkcall
			WHILE @WorkDir = 'Z' OR @WorkDir = 'BAD'
			  BEGIN
				SELECT @WorkDate = ISNULL(MAX(DateAndTime),'19500101')
				FROM dbo.tblLatLongs
				WHERE Unit  = @WorkMCTSN
					AND DateAndTime < @WorkDate

				IF @WorkDate <> '19500101'
				  BEGIN
					SELECT  @WorkDir = ISNULL(Direction, 'Z'),
						@WorkMilesFrom = ISNULL(Miles, 0),
						@WorkIgnition = ISNULL(VehicleIgnition, ''),
						@WorkCity = ISNULL(CityName, ''),
						@WorkState = ISNULL(State, ''),
						@LargeDirection = ISNULL(NearestLargeCityDirection, ''),
						@WorkLat = 3600 * ISNULL(Lat,0),
						@WorkLong = 3600 * ISNULL(Long,0),
						@LargeCityName = ISNULL(NearestLargeCityName,''),
						@LargeState = ISNULL(NearestLargeCityState,''),
						@LargeMiles = ISNULL(NearestLargeCityMiles,0)
					FROM dbo.tblLatLongs
					WHERE Unit = @WorkMCTSN
						AND DateAndTime = @WorkDate
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
				-- Construct the Nearest Large City String
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
				INSERT INTO dbo.#UnitsNear (ckc_tractor,
							ckc_date,
							ckc_milesfrom,
							ckc_directionfrom,
							ckc_latseconds,
							ckc_longseconds,
							ckc_vehicleignition,
							ckc_cityname,
							ckc_state,
							ckc_commentlarge)
				VALUES (@WorkTractor,
					@WorkDate,
					@WorkMilesFrom,
					@WorkDir,
					@WorkLat,
					@WorkLong,
					@WorkIgnition,
					@WorkCity,
					@WorkState,
					@WorkComment)
			  END
			ELSE
				SELECT @Failed = 0	-- Reset failure flag
	  	END  -- If @WorkDate > 19500101	
	  END  -- If @WorkMCTSN > 0

	-- Get the next MCT
	SELECT @WorkMCTSN = ISNULL(MIN(Unit),0)
	FROM dbo.tblLatLongs (NOLOCK)
	WHERE Unit > @WorkMCTSN 
  END  -- WHILE

-- Translate the report title
SELECT @sTranslateString = 'ALL TRACTORS'' REPORTED POSITIONS'
EXEC dbo.tm_t_sp @sTranslateString out, 1, ''

-- Always delete any tractors that are retired 
DELETE dbo.#UnitsNear
FROM dbo.#UnitsNear, dbo.tblTrucks
WHERE dbo.#UnitsNear.ckc_tractor = dbo.tblTrucks.TruckName
	AND tblTrucks.Retired = 1

-- Pull all the results
SELECT  ckc_tractor,
	CONVERT(VARCHAR(26), ckc_date) as ckc_date,
	ckc_milesfrom,
	ckc_directionfrom,
	ckc_vehicleignition,
	ckc_cityname,
	ckc_state,
	ckc_latseconds as Lat,
	ckc_longseconds as Long,
	ckc_commentlarge,
	@sTranslateString AS Title 
FROM dbo.#UnitsNear
GO
GRANT EXECUTE ON  [dbo].[tm_rpt_unitsnear] TO [public]
GO
