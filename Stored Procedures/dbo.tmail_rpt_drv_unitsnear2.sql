SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_rpt_drv_unitsnear2] @SysTZHrs int,
											 @SysTZMin int,
											 @SysDSTCode int,
											 @UsrTZHrs int,
											 @UsrTZMin int,
											 @UsrDSTCode int

AS

SET NOCOUNT ON 

DECLARE @WorkDriver varchar (8),
		@WorkDate datetime,
		@WorkDir varchar (3),
		@WorkMilesFrom float,
		@WorkIgnition char (1),
		@WorkLat int,
		@WorkLong int,
		@WorkCity varchar (16),
		@WorkState varchar (6),
		@WorkComment varchar (254),
		@Failed int

/***********************************************************
** THIS PROC SHOULD NOT BE SHARED WITH SQL 7.0 SOURCE!!!  **
***********************************************************/

/***** CHANGE LOG
 * 05/05/03 MZ: Created Driver based Units Near Report stored proc. 
 * 08/20/2012 - PTS60626 - APC - checkcall fields char to varchar
************************************************************/

CREATE TABLE #UnitsNear (ckc_driver varchar(8),
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
			@WorkLat = ISNULL(ckc_latseconds, 0),
			@WorkLong = ISNULL(ckc_longseconds, 0),
			@WorkCity = ISNULL(ckc_cityname, ''),
			@WorkState = ISNULL(ckc_state, ''),
			@WorkComment = ISNULL(ckc_commentlarge, '') 
	FROM checkcall (NOLOCK)
	WHERE ckc_asgnid = @WorkDriver
		AND ckc_date = @WorkDate
		AND ckc_asgntype = 'DRV'
		AND ckc_event = 'TRP'

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
					@WorkLat = ISNULL(ckc_latseconds, 0),
					@WorkLong = ISNULL(ckc_longseconds, 0),
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
			SELECT @Failed = 1	
			BREAK
		  END
	  END

	IF @Failed = 0
		INSERT INTO #UnitsNear (ckc_driver,
								ckc_date,
								ckc_milesfrom,
								ckc_directionfrom,
								ckc_vehicleignition,
								ckc_latseconds,
								ckc_longseconds,
								ckc_cityname,
								ckc_state,
								ckc_commentlarge)
		VALUES (@WorkDriver,
				@WorkDate,
				@WorkMilesFrom,
				@WorkDir,
				@WorkIgnition,
				@WorkLat,
				@WorkLong,
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

-- Delete any drivers that are retired if @IncludeRetired = 1
DELETE #UnitsNear
FROM #UnitsNear, manpowerprofile
WHERE #UnitsNear.ckc_driver = manpowerprofile.mpp_id
	AND manpowerprofile.mpp_status = 'OUT'

SELECT  ckc_driver as ckc_tractor,
		CONVERT(VARCHAR(26), dbo.ChangeTZ(ckc_date, @SysTZHrs, @SysDSTCode, @SysTZMin, @UsrTZHrs, @UsrDSTCode, @UsrTZMin)) as ckc_date,
		ckc_milesfrom,
		ckc_directionfrom,
		ckc_cityname,
		ckc_state,
		ckc_latseconds as Lat,
		ckc_longseconds as Long,
		ckc_commentlarge,
		ckc_vehicleignition
FROM #UnitsNear
ORDER BY ckc_driver
GO
GRANT EXECUTE ON  [dbo].[tmail_rpt_drv_unitsnear2] TO [public]
GO
