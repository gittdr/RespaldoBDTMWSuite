SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_rpt_unitsnear2]

AS

SET NOCOUNT ON 


DECLARE @WorkTractor varchar (8),
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

/************************************************************
 * 05/12/99 MZ: Created Units Near Report stored proc. 
 * 07/13/00 MZ: Modified to not return retired tractors.
 * 05/24/01 DAG: Converting for international date format
 * 08/30/01 DAG: Converting state to length 6 for international 
 * 08/20/2012 - PTS60626 - APC - checkcall fields char to varchar
************************************************************/

CREATE TABLE #UnitsNear (ckc_tractor varchar(8),
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
		@WorkLat = ISNULL(ckc_latseconds, 0),
		@WorkLong = ISNULL(ckc_longseconds, 0),
		@WorkCity = ISNULL(ckc_cityname, ''),
		@WorkState = ISNULL(ckc_state, ''),
		@WorkComment = ISNULL(ckc_commentlarge, '') 
	FROM checkcall (NOLOCK)
	WHERE ckc_tractor = @WorkTractor
		AND ckc_date = @WorkDate

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
				@WorkLat = ISNULL(ckc_latseconds, 0),
				@WorkLong = ISNULL(ckc_longseconds, 0),
				@WorkCity = ISNULL(ckc_cityname, ''),
				@WorkState = ISNULL(ckc_state, ''),
				@WorkComment = ISNULL(ckc_commentlarge, '')
			FROM checkcall (NOLOCK)
			WHERE ckc_tractor = @WorkTractor
				AND ckc_date = @WorkDate
		  END
		ELSE
		  BEGIN
			SELECT @Failed = 1	
			BREAK
		  END
	  END

	IF @Failed = 0
		INSERT INTO #UnitsNear (ckc_tractor,
					ckc_date,
					ckc_milesfrom,
					ckc_directionfrom,
					ckc_vehicleignition,
					ckc_latseconds,
					ckc_longseconds,
					ckc_cityname,
					ckc_state,
					ckc_commentlarge)
		VALUES (@WorkTractor,
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

	SELECT @WorkTractor = ISNULL(MIN(ckc_Tractor), '')
	FROM checkcall (NOLOCK)
	WHERE ckc_tractor > @WorkTractor
END  -- WHILE

-- Delete any retired tractors
DELETE #UnitsNear
FROM #UnitsNear, tractorprofile
WHERE #UnitsNear.ckc_tractor = tractorprofile.trc_number
	AND tractorprofile.trc_status = 'OUT'

SELECT  ckc_tractor,
	CONVERT(VARCHAR(26), ckc_date) as ckc_date,
	ckc_milesfrom,
	ckc_directionfrom,
	ckc_cityname,
	ckc_state,
	ckc_latseconds as Lat,
	ckc_longseconds as Long,
	ckc_commentlarge,
	ckc_vehicleignition
FROM #UnitsNear
GO
GRANT EXECUTE ON  [dbo].[tmail_rpt_unitsnear2] TO [public]
GO
