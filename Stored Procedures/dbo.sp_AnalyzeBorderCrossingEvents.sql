SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_AnalyzeBorderCrossingEvents]

AS

/**
 * 
 * NAME:
 * dbo.[sp_AnalyzeBorderCrossingEvents]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * iterates through tblMIVDBorderCrossingCalculations,
 * calculates airmiles between checkcall and border coordinate
 * copies record to notification table if distance has increased,
 * otherwise saves calculation to tblMIVDBorderCrossingCalculations
 *
 * RETURNS:
 *	Nothing
 * 
 * Change Log: 
 * 01/24/2014 - PTS63658 - APC - Create proc
 * 05/07/2014 - PTS75915 - APC - analyze checkcalls that come in after the last pickup stop has been actualized (before meat inspection stop)
 * 05/07/2014 - PTS75915 - APC - optimize query that populates temp table, so table only holds records of legheaders that should be considered when analyzing checkcalls
 * 07/29/2014 - PTS80063 - APC - utilize new gi settings (delay, prerequisite stop types)
 **/

DECLARE @gi_BorderCrossingNotificationFlag VARCHAR(60),
		@kount INT,
		@leg INT,
		@seq INT,
		@Status varchar(6),
		@delayInMinutes INT,
		@GI_PrereqEventTypes VARCHAR(60),
		@PrereqEventTypes NVARCHAR(200),
		@sql NVARCHAR(MAX),
		@ParmDefinition NVARCHAR(500)

--Get GI settings
SELECT 
	@gi_BorderCrossingNotificationFlag = gi_string1,
	@GI_PrereqEventTypes = gi_string4,
	@delayInMinutes = gi_integer3	
FROM dbo.generalinfo (NOLOCK)
WHERE gi_name = 'Border_Crossing_Notifications' 

-- exit stored proc if this functionality is not turned on in GI setting
IF @gi_BorderCrossingNotificationFlag <> 'Y'
RETURN 

/****************************************/

DECLARE	@temp TABLE
		(
			sn INT IDENTITY(1,1),
            stp_number INT,
            stopsequence INT,
            leg INT,
            cmp_id VARCHAR(8)
		)

IF ISNULL(@GI_PrereqEventTypes, '-1') = '-1' OR LTRIM(@GI_PrereqEventTypes) = ''
BEGIN
	--RAISERROR ('GeneralInfo Border_Crossing_Notifications has invalid value in gi_string4', 0, 1) WITH NOWAIT
	RETURN
END

EXECUTE tmail_InsertSingleQuotesAroundCsvValues @GI_PrereqEventTypes, ',', @PrereqEventTypes OUT

-- collect stop#, seq# of meat inspection stop, leg# from all active legs with un-actualized meat inspection stops
INSERT into @temp (stp_number, stopsequence, leg, cmp_id)
	SELECT s1.stp_number, s1.stp_mfh_sequence,s1.lgh_number, s1.cmp_id 
	FROM stops s1 (NOLOCK)
	INNER JOIN legheader_active l (NOLOCK) ON s1.lgh_number = l.lgh_number
	WHERE s1.stp_event in ('NBMI', 'SBMI')
		AND s1.stp_status <> 'DNE'

-- loop through temp table and remove legs that do not qualify for meat inspection notifications
SELECT @kount = min(sn) FROM @temp

WHILE ISNULL(@kount,0) >0
BEGIN
	SELECT @leg=leg, @seq= stopsequence FROM @temp WHERE sn = @kount

	-- get status of the last preReqEventType stop that has a sequence# (occurs)  before the meat inspection stop
	SET @sql = 
		N'SELECT @Status = ISNULL(stp_status, ''' + N'DNE' + ''')
		FROM stops (NOLOCK) 
		WHERE  lgh_number = @leg
			AND stp_mfh_sequence =
			(
			SELECT MAX(stp_mfh_sequence) 
			FROM stops (NOLOCK) 
			WHERE lgh_number = @leg
				AND stp_event in (Select Value from tmail_CSVCodeStringToVarcharTable(@PrereqEventTypes))
				AND stp_mfh_sequence < @seq 
			)'
			
	SET @ParmDefinition = N'@leg int, @PrereqEventTypes NVarchar(200), @seq int, @Status varchar(6) OUT'
	EXEC sp_executesql @sql, @ParmDefinition, @leg = @leg, @PrereqEventTypes = @PrereqEventTypes, @seq = @seq, @status = @status OUT;
	
	-- if this last prereqEventType stop is not completed (status = DNE),
	-- ... this leg does not qualify to be added to the Calculations table,
	-- ... delete it from the temp table
	if @status <> 'DNE' BEGIN
		DELETE FROM @temp WHERE sn=@kount;	
	END
	
	-- set counter to next sn for next iteration of loop
	SELECT @kount = min(sn) FROM @temp WHERE sn>@kount
END

/****************************************/
-- call sp_UpdateMIVDBorderCrossingCalculationsDelay
-- which loops through tblMIVDBorderCrossingCalculations 
-- and sets field CompletedDelayAfterActualizedLastStop_BeforeMeatInspection = 'Y'
-- if delay has passed.
EXEC sp_UpdateMIVDBorderCrossingCalculationsDelay @delayInMinutes

-- Get recent checkcall and related order info and
-- Update tblMIVDBorderCrossingCalculations

UPDATE tblMIVDBorderCrossingCalculations 
SET 
	ckc_number = ch.ckc_number, 
	ckc_latseconds = ch.ckc_latseconds, 
	ckc_longseconds = ch.ckc_longseconds, 
	ckc_updatedon = ch.ckc_updatedon,
	updatedon = CURRENT_TIMESTAMP
FROM checkcall ch (NOLOCK) 
INNER JOIN dbo.tblMIVDBorderCrossingCalculations m (NOLOCK)
	ON ch.ckc_number <> m.ckc_number AND ch.ckc_lghnumber = m.lgh_number
WHERE ch.ckc_number IN 
(
	SELECT DISTINCT c.ckc_number 
	FROM checkcall c
	INNER JOIN @temp p ON c.ckc_lghnumber = p.leg
	INNER JOIN tblMIVDBorderCrossingCalculations t (NOLOCK) ON t.lgh_number = c.ckc_lghnumber	
	WHERE
	c.ckc_asgntype = 'DRV'
	AND c.ckc_updatedon > DATEADD(mi, -3, CURRENT_TIMESTAMP)
	AND ISNULL(t.CompletedDelayAfterActualizedLastStop_BeforeMeatInspection,'N') = 'Y'	
	AND c.ckc_updatedon IN
	(
		SELECT MAX(ch.ckc_updatedon) 
		FROM checkcall ch (NOLOCK) 
		WHERE ch.ckc_lghnumber = c.ckc_lghnumber
	)
)

-- Insert new recs into tblMIVDBorderCrossingCalculations

INSERT INTO tblMIVDBorderCrossingCalculations 
(
	lgh_Number,
	DriverID ,
	ckc_number ,
	ckc_latseconds ,
	ckc_longseconds,
	border_stop_latseconds,
	border_stop_longseconds,
	ckc_updatedon,
	updatedon,
	CompletedDelayAfterActualizedLastStop_BeforeMeatInspection
) 
SELECT c.ckc_lghnumber, c.ckc_asgnid AS DriverID,
	c.ckc_number, c.ckc_latseconds, c.ckc_longseconds, 
	cmp.cmp_latseconds, cmp.cmp_longseconds, ckc_updatedon, CURRENT_TIMESTAMP, 'N' 
FROM checkcall c (NOLOCK)
	INNER JOIN @temp p ON c.ckc_lghnumber = p.leg	
	INNER JOIN dbo.company cmp (NOLOCK) ON p.cmp_id = cmp.cmp_id
WHERE 
	ckc_asgntype = 'DRV'
	AND ckc_updatedon > DATEADD(mi, -3, CURRENT_TIMESTAMP)
	AND p.cmp_id IS NOT NULL
	AND p.leg NOT IN 
	(
		SELECT m.lgh_Number
		FROM dbo.tblMIVDBorderCrossingCalculations m (NOLOCK)
		UNION
		SELECT n.lgh_Number From dbo.tblMIVDNotifications n (NOLOCK)
		UNION
		SELECT DISTINCT h.lgh_Number From dbo.tblMIVDNotifications_History h (NOLOCK)		
	)
	AND ckc_updatedon IN
	(
		SELECT MAX(ch.ckc_updatedon) 
		FROM checkcall ch (NOLOCK) 
		WHERE ch.ckc_lghnumber = c.ckc_lghnumber
	)

-- delete from tblMIVDBorderCrossingCalculations 
-- where border crossing stop has been actualized

DELETE FROM dbo.tblMIVDBorderCrossingCalculations
WHERE lgh_number NOT IN
(
	SELECT leg 
	FROM @temp
)

-- calculate and evaluate airmiles 
-- for each record in tblMIVDBorderCrossingCalculations
EXEC sp_EvaluateBorderCrossingAirMiles

GO
GRANT EXECUTE ON  [dbo].[sp_AnalyzeBorderCrossingEvents] TO [public]
GO
