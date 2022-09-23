SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_rpt_drv_fleet] @IncludeRetired int

AS
/***** CHANGE LOG
 * 08/20/2012 - PTS60626 - APC - checkcall fields char to varchar
 */
SET NOCOUNT ON 

DECLARE @WorkDriver varchar (8),
		@WorkDate datetime,
		@WorkDir varchar (3),
		@WorkMilesFrom float,
		@WorkIgnition char (1),
		@WorkCity varchar (16),
		@WorkState varchar (6),
		@WorkComment varchar (254),
		@Failed int,
		@sTranslateString varchar(200),
	    @TitleDateTime varchar (10),
	    @TitleDriver varchar (7),
	    @TitleMiles varchar (10),
	    @TitleDir varchar (5),
	    @TitleIgnition varchar (5),
	    @TitleCity varchar (5),
	    @TitleState varchar (5),
	    @TitleNearestLarge varchar (20)

-- 05/05/05  MZ: Driver based Fleet Report. 

-- Create temp table to hold results
CREATE TABLE #Fleet (ckc_driver varchar(8),
					 ckc_date datetime,
					 ckc_milesfrom float,
					 ckc_directionfrom varchar(3),
					 ckc_vehicleignition char(1),
					 ckc_cityname varchar(16),
					 ckc_state varchar(6),
					 ckc_commentlarge varchar(254))

SELECT @Failed = 0

-- Get the first driver
SELECT @WorkDriver = ISNULL(MIN(ckc_asgnid), '') 
FROM checkcall (NOLOCK)
WHERE ckc_asgnid > ''
	AND ckc_asgntype = 'DRV'
	AND ckc_event = 'TRP'

WHILE @WorkDriver > ''
  BEGIN
	SELECT @WorkDate = MAX(ckc_date)
	FROM checkcall (NOLOCK)
	WHERE ckc_asgnid = @WorkDriver
		AND ckc_asgntype = 'DRV'
		AND ckc_event = 'TRP'

	SELECT  @WorkDir = ISNULL(ckc_directionfrom, 'Z'),
			@WorkMilesFrom = ISNULL(ckc_milesfrom, 0),
			@WorkIgnition = ISNULL(ckc_vehicleignition, ''),
			@WorkCity = ISNULL(ckc_cityname, ''),
			@WorkState = ISNULL(ckc_state, ''),
			@WorkComment = ISNULL(ckc_commentlarge, '') 
	FROM checkcall (NOLOCK)
	WHERE ckc_asgnid = @WorkDriver
		AND ckc_date = @WorkDate
		AND ckc_asgntype = 'DRV'
		AND ckc_event = 'TRP'		

	-- If the last position was no good, or was a fuel purchase record,
	-- keep trying to find a valid checkcall
	WHILE @WorkDir = 'Z' OR @WorkDir = 'BAD'
	  BEGIN
		SELECT @WorkDate = ISNULL(MAX(ckc_date),'19500101')
		FROM checkcall (NOLOCK)
		WHERE ckc_asgnid = @WorkDriver
			AND ckc_date < @WorkDate
			AND ckc_asgntype = 'DRV'
			AND ckc_event = 'TRP'

		IF @WorkDate <> '19500101'
		  BEGIN
			SELECT  @WorkDir = ISNULL(ckc_directionfrom, 'Z'),
					@WorkMilesFrom = ISNULL(ckc_milesfrom, 0),
					@WorkIgnition = ISNULL(ckc_vehicleignition, ''),
					@WorkCity = ISNULL(ckc_cityname, ''),
					@WorkState = ISNULL(ckc_state, ''),
					@WorkComment = ISNULL(ckc_commentlarge, '')
			FROM checkcall (NOLOCK)
			WHERE ckc_asgnid = @WorkDriver
				AND ckc_date = @WorkDate
				AND ckc_asgntype = 'DRV'
				AND ckc_event = 'TRP'
		  END
		ELSE
		  BEGIN
			-- Couldn't find a valid checkcall, so fail for this tractor
			SELECT @Failed = 1	
			BREAK
		  END
	  END

	IF @Failed = 0
		-- Got a valid checkcall so add it to our temp table
		INSERT INTO #Fleet (ckc_driver,
							ckc_date,
							ckc_milesfrom,
							ckc_directionfrom,
							ckc_vehicleignition,
							ckc_cityname,
							ckc_state,
							ckc_commentlarge)
		VALUES (@WorkDriver,
				@WorkDate,
				@WorkMilesFrom,
				@WorkDir,
				@WorkIgnition,
				@WorkCity,
				@WorkState,
				@WorkComment)
	ELSE
		SELECT @Failed = 0	-- Reset failure flag

	-- Get the next driver
	SELECT @WorkDriver = ISNULL(MIN(ckc_asgnid), '') 
	FROM checkcall (NOLOCK)
	WHERE ckc_asgnid > @WorkDriver
		AND ckc_asgntype = 'DRV'
		AND ckc_event = 'TRP'
  END  -- WHILE

-- Translate report headers/title 
SET @TitleDateTime = 'Date/Time'
--EXEC t_sp @TitleDate out, 1, ''
SET @TitleDriver = 'Driver'
--EXEC t_sp @TitleDriver out, 1, ''
SET @TitleMiles = 'Miles'
--EXEC t_sp @TitleMiles out, 1, ''
SET @TitleDir = 'Dir'
--EXEC t_sp @TitleDir out, 1, ''
SET @TitleIgnition = 'Ign'
--EXEC t_sp @TitleIgnition out, 1, ''
SET @TitleCity = 'City'
--EXEC t_sp @TitleCity out, 1, ''
SET @TitleState = 'St'
--EXEC t_sp @TitleState out, 1, ''
SET @TitleNearestLarge = 'Nearest Large City'
--EXEC t_sp @TitleComment out, 1, ''
SELECT @sTranslateString = 'ALL DRIVERS'' REPORTED POSITIONS'
-- EXEC tm_t_sp @sTranslateString out, 1, ''

IF @IncludeRetired = 0
	-- Delete any drivers that are retired if @IncludeRetired = 1
	DELETE #Fleet
	FROM #Fleet, manpowerprofile
	WHERE #Fleet.ckc_driver = manpowerprofile.mpp_id
		AND manpowerprofile.mpp_status = 'OUT'

-- Pull all the results
SELECT  ckc_driver,
		CONVERT(VARCHAR(26), ckc_date) as ckc_date,
		ckc_milesfrom,
		ckc_directionfrom,
		ckc_vehicleignition,
		ckc_cityname,
		ckc_state,
		ckc_commentlarge,
		@sTranslateString AS Title,
		@TitleDateTime AS TitleDate,
		@TitleDriver AS TitleTruck, 
	    @TitleIgnition AS TitleIgnition, 
		@TitleMiles AS TitleMiles, 
		@TitleDir AS TitleDir,
		@TitleCity as TitleCity, 
		@TitleState as TitleState, 
		@TitleNearestLarge as TitleLarge
FROM #Fleet
ORDER BY ckc_driver
GO
GRANT EXECUTE ON  [dbo].[tmail_rpt_drv_fleet] TO [public]
GO
