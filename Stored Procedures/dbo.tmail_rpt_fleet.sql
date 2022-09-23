SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_rpt_fleet] @dispgroup int

AS

/***** CHANGE LOG
* 05/12/99 MZ: Fleet Report. 
* 07/12/00 MZ: Modified to not pull checkcalls for retired tractors
* 05/24/01 DAG: Converting for international date format
* 08/30/01 DAG: Converting state length to 6 for international 
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
	@sTranslateString varchar(200)

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
	IF (@dispgroup <> -1)	-- Does user want all trucks or only a specific dispatch group?
	  BEGIN
		IF EXISTS (SELECT truckname 
					FROM tbltrucks (NOLOCK)
					WHERE currentdispatcher = @dispgroup AND truckname = @WorkTractor)
		  BEGIN
			-- This tractor is part of the specified dispatch group, so get it's last position
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
				INSERT INTO #Fleet (	ckc_tractor,
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
		  END
	  END
	ELSE  -- Want all fleets, not just a specific dispatch group
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
	  END

		-- Get the next tractor
		SELECT @WorkTractor = ISNULL(MIN(ckc_Tractor), '')
		FROM checkcall (NOLOCK)
		WHERE ckc_tractor > @WorkTractor
END  -- WHILE

-- Translate the report title
SELECT @sTranslateString = 'ALL TRACTORS'' REPORTED POSITIONS'
-- EXEC tm_t_sp @sTranslateString out, 1, ''

-- Pull all the results
SELECT  ckc_tractor,
	CONVERT(VARCHAR(26), ckc_date) as ckc_date,
	ckc_milesfrom,
	ckc_directionfrom,
	ckc_vehicleignition,
	ckc_cityname,
	ckc_state,
	ckc_commentlarge,
	@sTranslateString AS Title 
FROM #Fleet
ORDER BY ckc_tractor
GO
GRANT EXECUTE ON  [dbo].[tmail_rpt_fleet] TO [public]
GO
