SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_rpt_singletruckposition2]	@TruckName varchar(8),
							@IncludeRetired int,
							@SysTZHrs int,
							@SysTZMin int,
							@SysDSTCode int,
							@UsrTZHrs int,
							@UsrTZMin int,
							@UsrDSTCode int

AS

/***********************************************************
** THIS PROC SHOULD NOT BE SHARED WITH SQL 7.0 SOURCE!!!  **
***********************************************************/


SET NOCOUNT ON 

DECLARE @WorkDate datetime,
	@WorkDir varchar (3),
	@WorkMilesFrom float,
	@WorkIgnition char (1),
	@WorkCity varchar (16),
	@WorkLat int,
	@WorkLong int,
	@WorkState varchar (6),
	@WorkComment varchar (254),
	@Failed int

/****************************************************************
 * 07/27/00 MZ: PowerSuite based Single tractor position 
 * 05/24/01 DAG: Converting for international date format       
 * 08/30/01 DAG: Converting state to length 6 for international       
 * 11/27/01 MZ: Added time zone conversion calls in new version (2)
 * 08/20/2012 - PTS60626 - APC - checkcall fields char to varchar
****************************************************************/

-- Create temp table to hold results
CREATE TABLE dbo.#Fleet (ckc_tractor varchar(8),
			 ckc_date datetime,
			 ckc_milesfrom float,
			 ckc_directionfrom varchar(3),
			 ckc_vehicleignition char(1),
			 ckc_latseconds int,
			 ckc_longseconds int,
			 ckc_cityname varchar(16),
			 ckc_state varchar(6),
			 ckc_commentlarge varchar(254))

SELECT @Failed = 0
	
-- Get the last position report for this tractor
SELECT @WorkDate = ISNULL(MAX(ckc_date), '19500101')
FROM dbo.checkcall (NOLOCK)
WHERE ckc_tractor = @TruckName

IF (@WorkDate <> '19500101')
  BEGIN
	SELECT  @WorkDir = ISNULL(ckc_directionfrom, 'Z'),
		@WorkMilesFrom = ISNULL(ckc_milesfrom, 0),
		@WorkIgnition = ISNULL(ckc_vehicleignition, ''),
		@WorkCity = ISNULL(ckc_cityname, ''),
		@WorkLat = ISNULL(ckc_latseconds, 0),
		@WorkLong = ISNULL(ckc_longseconds, 0),
		@WorkState = ISNULL(ckc_state, ''),
		@WorkComment = ISNULL(ckc_commentlarge, '') 
	FROM dbo.checkcall (NOLOCK)
	WHERE ckc_tractor = @TruckName
		AND ckc_date = @WorkDate

	-- If the last position was no good, or was a fuel purchase record,
	-- keep trying to find a valid checkcall
	WHILE @WorkDir = 'Z' OR @WorkDir = 'BAD'
	  BEGIN
		SELECT @WorkDate = ISNULL(MAX(ckc_date),'19500101')
		FROM dbo.checkcall (NOLOCK)
		WHERE ckc_tractor = @TruckName
			AND ckc_date < @WorkDate

		IF @WorkDate <> '19500101'
		  BEGIN
			SELECT  @WorkDir = ISNULL(ckc_directionfrom, 'Z'),
				@WorkMilesFrom = ISNULL(ckc_milesfrom, 0),
				@WorkIgnition = ISNULL(ckc_vehicleignition, ''),
				@WorkCity = ISNULL(ckc_cityname, ''),
				@WorkLat = ISNULL(ckc_latseconds, 0),
				@WorkLong = ISNULL(ckc_longseconds, 0),
				@WorkState = ISNULL(ckc_state, ''),
				@WorkComment = ISNULL(ckc_commentlarge, '')
			FROM dbo.checkcall (NOLOCK)
			WHERE ckc_tractor = @TruckName
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
		INSERT INTO dbo.#Fleet     (ckc_tractor,
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
	ELSE	
		SELECT @Failed = 0	-- Reset failure flag

	IF @IncludeRetired = 0
		-- Delete any tractors that are retired if @IncludeRetired = 1
		DELETE dbo.#Fleet
		FROM dbo.#Fleet, dbo.tractorprofile
		WHERE dbo.#Fleet.ckc_tractor = dbo.tractorprofile.trc_number
			AND dbo.tractorprofile.trc_status = 'OUT'
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
GRANT EXECUTE ON  [dbo].[tmail_rpt_singletruckposition2] TO [public]
GO
