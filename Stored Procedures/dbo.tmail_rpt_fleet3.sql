SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_rpt_fleet3] @IncludeRetired int,
					@SysTZHrs int,
					@SysTZMin int,
					@SysDSTCode int,
					@UsrTZHrs int,
					@UsrTZMin int,
					@UsrDSTCode int

AS

/**********************************************************
** THIS PROC SHOULD NOT BE SHARED WITH SQL 7.0 SOURCE!!! **
**********************************************************/
/***** CHANGE LOG
 * 11/26/01 MZ: Created this new version
 * 08/20/2012 - PTS60626 - APC - checkcall fields char to varchar
 */

SET NOCOUNT ON 

DECLARE @WorkTractor varchar (8),
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
	@TitleTruck varchar (7),
	@TitleMiles varchar (10),
	@TitleDir varchar (5),
	@TitleIgnition varchar (5),
	@TitleCity varchar (5),
	@TitleState varchar (5),
	@TitleNearestLarge varchar (20)

-- Create temp table to hold results
CREATE TABLE #Fleet 	(ckc_tractor varchar(8),
			 ckc_date datetime,
			 ckc_milesfrom float,
			 ckc_directionfrom varchar(3),
			 ckc_vehicleignition char(1),
			 ckc_cityname varchar(16),
			 ckc_state varchar(6),
			 ckc_commentlarge varchar(254))

SELECT @Failed = 0
	
-- Get the first tractor
SELECT @WorkTractor = ISNULL(MIN(ckc_Tractor), '') 
FROM checkcall (NOLOCK)
WHERE ckc_tractor > ''

WHILE @WorkTractor > ''
  BEGIN
	SELECT @WorkDate = MAX(ckc_date)
	FROM checkcall (NOLOCK)
	WHERE ckc_tractor = @WorkTractor

	SELECT  @WorkDir = ISNULL(ckc_directionfrom, 'Z'),
		@WorkMilesFrom = ISNULL(ckc_milesfrom, 0),
		@WorkIgnition = ISNULL(ckc_vehicleignition, ''),
		@WorkCity = ISNULL(ckc_cityname, ''),
		@WorkState = ISNULL(ckc_state, ''),
		@WorkComment = ISNULL(ckc_commentlarge, '') 
	FROM checkcall (NOLOCK)
	WHERE ckc_tractor = @WorkTractor
		AND ckc_date = @WorkDate

	-- If the last position was no good, or was a fuel purchase record,
	-- keep trying to find a valid checkcall
	WHILE @WorkDir = 'Z' OR @WorkDir = 'BAD'
	  BEGIN
		SELECT @WorkDate = ISNULL(MAX(ckc_date),'19500101')
		FROM checkcall (NOLOCK)
		WHERE ckc_tractor = @WorkTractor
			AND ckc_date < @WorkDate

		IF @WorkDate <> '19500101'
		  BEGIN
			SELECT  @WorkDir = ISNULL(ckc_directionfrom, 'Z'),
				@WorkMilesFrom = ISNULL(ckc_milesfrom, 0),
				@WorkIgnition = ISNULL(ckc_vehicleignition, ''),
				@WorkCity = ISNULL(ckc_cityname, ''),
				@WorkState = ISNULL(ckc_state, ''),
				@WorkComment = ISNULL(ckc_commentlarge, '')
			FROM checkcall (NOLOCK)
			WHERE ckc_tractor = @WorkTractor
				AND ckc_date = @WorkDate
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
		INSERT INTO #Fleet     (ckc_tractor,
					ckc_date,
					ckc_milesfrom,
					ckc_directionfrom,
					ckc_vehicleignition,
					ckc_cityname,
					ckc_state,
					ckc_commentlarge)
		VALUES (@WorkTractor,
			@WorkDate,
			@WorkMilesFrom,
			@WorkDir,
			@WorkIgnition,
			@WorkCity,
			@WorkState,
			@WorkComment)
	ELSE
		SELECT @Failed = 0	-- Reset failure flag

	-- Get the next tractor
	SELECT @WorkTractor = ISNULL(MIN(ckc_Tractor), '')
	FROM checkcall (NOLOCK)
	WHERE ckc_tractor > @WorkTractor
  END  -- WHILE

-- Translate report headers/title 
SET @TitleDateTime = 'Date/Time'
--EXEC t_sp @TitleDate out, 1, ''
SET @TitleTruck = 'Truck'
--EXEC t_sp @TitleTruck out, 1, ''
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
SELECT @sTranslateString = 'ALL TRACTORS'' REPORTED POSITIONS'
-- EXEC tm_t_sp @sTranslateString out, 1, ''

IF @IncludeRetired = 0
	-- Delete any tractors that are retired if @IncludeRetired = 1
	DELETE #Fleet
	FROM #Fleet, tractorprofile
	WHERE #Fleet.ckc_tractor = tractorprofile.trc_number
	AND tractorprofile.trc_status = 'OUT'

-- Pull all the results
SELECT  ckc_tractor,
	CONVERT(VARCHAR(26), dbo.ChangeTZ(ckc_date, @SysTZHrs, @SysDSTCode, @SysTZMin, @UsrTZHrs, @UsrDSTCode, @UsrTZMin)) as ckc_date,
	ckc_milesfrom,
	ckc_directionfrom,
	ckc_vehicleignition,
	ckc_cityname,
	ckc_state,
	ckc_commentlarge,
	@sTranslateString AS Title,
	@TitleDateTime AS TitleDate,
	@TitleTruck AS TitleTruck, 
	@TitleIgnition AS TitleIgnition, 
	@TitleMiles AS TitleMiles, 
	@TitleDir AS TitleDir,
	@TitleCity as TitleCity, 
	@TitleState as TitleState, 
	@TitleNearestLarge as TitleLarge
FROM #Fleet
ORDER BY ckc_tractor
GO
GRANT EXECUTE ON  [dbo].[tmail_rpt_fleet3] TO [public]
GO
