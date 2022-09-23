SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[LegPTAUpdate_sp_Preprocess] (
	@curLeg AS INT
	,@curTrc AS VARCHAR(8)
	,@ptaDate AS DATETIME
	,@utilCode AS VARCHAR(6)
	,@ptaType AS CHAR(1)
	)
AS
DECLARE @PreCalcTable TABLE (
	curLeg INT
	,ptaType CHAR(1)
	,utilCode VARCHAR(6)
	,newPTA DATETIME
	,calculatedMax DATETIME
	,curTrc VARCHAR(8)
	,today DATETIME
	,approved TINYINT
	,approvedBy VARCHAR(128)
	,approvedOn DATETIME
	,Dodataupdate BIT
	,outStatus VARCHAR(4)
	,existingLegPTA INT
	,messagedesc VARCHAR(500)
	,instructions VARCHAR(500)
	,pta_hard_max datetime
	,requested_date DATETIME
	,requested_user varchar(128)
	)

declare @UNKNOWN varchar(8), @existingUtilCode AS VARCHAR(6)
select @UNKNOWN = 'UNKNOWN'

declare @doDataUpdate bit
select @doDataUpdate = 1

declare @messageDesc varchar(500)
declare @instructions varchar(500)
select @instructions = ''

declare @originalPtaType char(1)
select @originalPtaType = @ptaType

-- Seed precalc table with passed in values and success for doing the data update
insert into @PreCalcTable (curLeg, curTrc, utilCode, ptaType, Dodataupdate) 
values (@curLeg, @curTrc, @utilCode, @ptaType, @doDataUpdate)

-- initialize current tractor to UNKNOWN
IF RTRIM(ISNULL(@curTrc, '')) = ''
	SET @curTrc = @UNKNOWN

-- initialize current leg to 0 if not passed in
IF @curLeg < 1
	OR @curLeg IS NULL
	SET @curLeg = 0

-- check to see if there is enough data to complete check/update
IF @curLeg = 0
	AND @curTrc = @UNKNOWN
BEGIN
	select @doDataUpdate = 0
	select @messageDesc = 'check to see if there is enough data to complete check/update'

	GOTO FinalSelect
END

-- need to wait until the save occurs
IF @curLeg >= 2147400000
BEGIN
	select @doDataUpdate = 0
	select @messageDesc = 'need to wait until the save occurs'

	GOTO FinalSelect
END

-- get the tractor ID from the current leg variable
IF @curTrc = @UNKNOWN
	SELECT @curTrc = isnull(lgh_tractor, @UNKNOWN)
	FROM legheader_active
	WHERE lgh_number = @curLeg

-- If the tractor is unknown, instruct to remove record and recalculate the PTA for the existing tractor for that leg
IF @curTrc = @UNKNOWN
BEGIN
	select @doDataUpdate = 0
	select @messageDesc = 'Deleted Existing legPTARecord'
	select @instructions = @instructions + '|REMOVE_RECORD_AND_RECALCULATE_PTA_FOR_PREVIOUS_TRACTOR|'

	GOTO FinalSelect
END

-- if leg mumber was not provided, get the leg header number to update on the legPTA table via the tractor
IF @curLeg = 0
	OR @curLeg IS NULL
BEGIN
	-- find current started trip
	SELECT @curLeg = MIN(lgh_number)
	FROM legheader_active
	WHERE lgh_tractor = @curTrc
		AND lgh_outstatus = 'STD'

	-- find last complete (should only be 1 complete trip, at most, in legheader_active table)
	IF @curLeg = 0
		OR @curLeg IS NULL
		SELECT @curLeg = MAX(lgh_number)
		FROM legheader_active
		WHERE lgh_tractor = @curTrc
			AND lgh_outstatus = 'CMP'

	IF @curLeg = 0
		OR @curLeg IS NULL
		SELECT @curLeg = MIN(lgh_number)
		FROM legheader_active
		WHERE lgh_tractor = @curTrc
			AND lgh_outstatus = 'DSP'

	IF @curLeg = 0
		OR @curLeg IS NULL
		SELECT @curLeg = MIN(lgh_number)
		FROM legheader_active
		WHERE lgh_tractor = @curTrc
			AND lgh_outstatus = 'PLN'
END

DECLARE @existingLegPTA AS INT
DECLARE @existingPTADate AS DATETIME
DECLARE @existingPtaType AS CHAR(1)
DECLARE @existingApproved AS TINYINT

SET @existingApproved = 0
SET @existingLegPTA = 0

SELECT @existingLegPTA = lpa_id
	,@existingPTADate = pta_date
	,@existingPtaType = pta_type
	,@existingApproved = pta_approved
FROM legpta
WHERE lgh_number = @curLeg

-- If we've already got a hard PTA for this item, and we're trying to update it 
-- with a soft PTA or one whose date is null, abort
IF @existingPtaType = 'H'
	AND (
		@ptaType = 'S'
		OR @ptaDate IS NULL
		)
BEGIN
	select @doDataUpdate = 0
	select @messageDesc = 'being updated with softupdate or date null'

	GOTO FinalSelect
END

-- retrieve the system wide PTA settings from the general info Soft PTA setting
DECLARE @softPTAOn AS VARCHAR(6)
DECLARE @softPTATime AS INT
DECLARE @ptaMaxDays AS TINYINT
DECLARE @softPTAUtilCode AS VARCHAR(6)
DECLARE @softPTAEvents AS VARCHAR(6) -- values will be ALL or DRP

SELECT @softPTAOn = RTRIM(UPPER(ISNULL(gi_string1, 'N')))
	,@softPTATime = ISNULL(gi_integer1, 240)
	,@softPTAUtilCode = RTRIM(LEFT(ISNULL(gi_string2, 'RE'), 6))
	,@softPTAEvents = RTRIM(LEFT(ISNULL(gi_string3, 'ALL'), 6))
	,@ptaMaxDays = ISNULL(gi_integer2, 4)
FROM generalinfo
WHERE gi_name = 'SoftPTATime'

IF LEN(@softPTAOn) > 1
	SET @softPTAOn = Upper(LEFT(@softPTAOn, 1))

IF ISNULL(@softPTAOn, 'N') <> 'Y'
BEGIN
	select @doDataUpdate = 0
	select @messageDesc =  'SoftPTA not enabled'

	GOTO FinalSelect
END

IF UPPER(@softPTAEvents) = 'DRP'
	OR UPPER(@softPTAEvents) = 'DROP'
	SET @softPTAEvents = 'DRP'
ELSE
	SET @softPTAEvents = 'ALL'

-- set genesis and apocalypse
DECLARE @genesis AS DATETIME
DECLARE @apocalypse AS DATETIME
DECLARE @today AS DATETIME

SET @genesis = CONVERT(DATETIME, '19500101', 112)
SET @apocalypse = CONVERT(DATETIME, '20491231 23:59', 112)
SET @today = GetDate()

-- initialize PTA date to @genesis or '19500101' for later comparison
IF @ptaDate <= @genesis
	OR @ptaDate >= @apocalypse
	OR @ptaDate IS NULL
	SET @ptaDate = @genesis

-- divisional overrides for settings (from tractor division)
DECLARE @division VARCHAR(6)
DECLARE @divisionalMaxDays INT
DECLARE @divisionalUtilCode VARCHAR(6)
DECLARE @divisionalEvents VARCHAR(6)

SELECT @division = 'UNK'
	,@divisionalMaxDays = - 1
	,@divisionalUtilCode = ''
	,@divisionalEvents = ''

-- find the division the tractor is assigned to
IF @curTrc <> @UNKNOWN
	SELECT @division = ISNULL(trc_division, 'UNK')
	FROM tractorprofile
	WHERE trc_number = @curTrc

-- find the divisional overrides that are stored on the labelfile Division label
IF @division <> 'UNK'
	SELECT @divisionalMaxDays = CONVERT(INT, LTRIM(RTRIM(ISNULL(label_extrastring4, '-1'))))
		,@divisionalUtilCode = RTRIM(ISNULL(label_extrastring5, ''))
		,@divisionalEvents = RTRIM(ISNULL(label_extrastring6, ''))
	FROM labelfile
	WHERE labeldefinition = 'Division'
		AND abbr = @division

-- if overrides exist for the division, set the global values with the overrides
IF @divisionalMaxDays > - 1
	SET @ptaMaxDays = @divisionalMaxDays

IF LEN(RTRIM(ISNULL(@divisionalUtilCode, ''))) > 0
	SET @softPTAUtilCode = @divisionalUtilCode

IF LEN(RTRIM(ISNULL(@divisionalEvents, ''))) > 0
BEGIN
	IF UPPER(@divisionalEvents) = 'DRP'
		OR UPPER(@divisionalEvents) = 'DROP'
		SET @divisionalEvents = 'DRP'
	ELSE
		SET @softPTAEvents = 'ALL'

	SET @softPTAEvents = @divisionalEvents
END

DECLARE @approved TINYINT
DECLARE @approvedBy AS VARCHAR(128)
DECLARE @approvedOn AS DATETIME

SET @approved = 0
SET @approvedBy = NULL
SET @approvedOn = NULL

DECLARE @calculatedMax AS DATETIME

SET @calculatedMax = @genesis

DECLARE @openMax AS DATETIME
DECLARE @doneMax AS DATETIME

-- find the maximum date for the tractor in the event table where status of event is open
SELECT @openMax = MAX(CASE 
			WHEN evt_latedate <= @genesis
				OR evt_latedate >= @apocalypse
				THEN evt_enddate
			ELSE evt_latedate
			END)
FROM event
INNER JOIN stops ON event.stp_number = stops.stp_number
INNER JOIN legheader_active ON stops.lgh_number = legheader_active.lgh_number
WHERE 1 = 1
	AND evt_status = 'OPN'
	AND evt_sequence = 1
	AND (
		evt_pu_dr = @softPTAEvents
		OR (
			evt_eventcode = 'DLT'
			AND @softPTAEvents = 'DRP'
			)
		OR @softPTAEvents = 'ALL'
		)
	AND legheader_active.lgh_tractor = @curTrc

-- add soft PTA time to the end of the incomplete stop
IF @openMax IS NOT NULL
	SET @openMax = DATEADD(MI, @softPTATime, @openMax)

-- find the maximum date for the tractor in the event table where status of event is done
SELECT @doneMax = MAX(evt_enddate) --case when evt_latedate <= @genesis or evt_latedate >= @apocalypse then evt_enddate else evt_latedate end) 
FROM event
INNER JOIN stops ON event.stp_number = stops.stp_number
INNER JOIN legheader_active ON stops.lgh_number = legheader_active.lgh_number
WHERE 1 = 1
	AND evt_status = 'DNE'
	AND evt_sequence = 1
	AND (
		evt_pu_dr = @softPTAEvents
		OR (
			evt_eventcode = 'DLT'
			AND @softPTAEvents = 'DRP'
			)
		OR @softPTAEvents = 'ALL'
		)
	AND legheader_active.lgh_tractor = @curTrc

-- if there are planned stops for a tractor, then store the max date of planned stops
IF @openMax > @calculatedMax
	SET @calculatedMax = @openMax

-- if the last completed trip is greater than the planned stops, use that date instead
IF @doneMax > @calculatedMax
	SET @calculatedMax = @doneMax

-- soft PTA cannot be more than 4 days after the last planned/completed stop
DECLARE @hardPTAMax DATETIME

SET @hardPTAMax = DATEADD(D, @ptaMaxDays, @calculatedMax)

-- set utilization code from previous save (or to UNK)
IF @existingLegPTA > 0
BEGIN
	IF (
			RTRIM(ISNULL(@utilCode, '')) = ''
			OR @utilCode = 'UNK'
			)
		SELECT @utilCode = util_code
			,@existingLegPTA = lpa_id
		FROM legpta
		WHERE lpa_id = @existingLegPTA

	-- set PTA type from previous save (or to S)
	IF RTRIM(ISNULL(@ptaType, '')) = ''
		SELECT @ptaType = pta_type
			 ,@approved = pta_approved
			,@approvedBy = pta_approved_by
			,@approvedOn = pta_approved_date
			,@existingPtaDate = pta_date
		FROM legpta
		WHERE lpa_id = @existingLegPTA
END
ELSE
BEGIN
	SELECT @existingPtaType = pta_type
		,@existingPtaDate = pta_date
		,@existingUtilCode = util_code
		,@approved = pta_approved
		,@approvedBy = pta_approved_by
		,@approvedOn = pta_approved_date
	FROM legpta
	WHERE lpa_id = (
			SELECT MAX(lpa_id)
			FROM legpta
			WHERE trc_number = @curTrc
				AND pta_cancelled = 0
				AND pta_denied = 0
			)
	if @existingPtaType is not null 
	begin
		if (@existingPtaType='H' and @calculatedMax < @existingPTADate and @ptaDate < @existingPTADate) -- @ptaDate < @existingPTADate) -- 
			select @ptaType = 'H', @ptaDate = @existingPTADate, @utilCode = @existingUtilCode
	end 
END

IF RTRIM(ISNULL(@utilCode, '')) = ''
	OR @utilCode = 'UNK'
	SET @utilCode = @softPTAUtilCode

-- set default PTA type when nothing found or not passed in
IF RTRIM(ISNULL(@ptaType, '')) = ''
	OR @utilCode = 'RE'
	SET @ptaType = 'S'

-- set the newPTA initially to the computed Max or the date passed in (whichever is greater).
DECLARE @newPTA AS DATETIME

IF @ptaType = 'H'
	SET @newPTA = @ptaDate
ELSE	
	SET @newPTA = @calculatedMax

IF @ptaDate > @newPTA
	SET @newPTA = @ptaDate

-- is the user a supervisor, if so it will automatically be approved.
DECLARE @supervisor CHAR(1)

SELECT @supervisor = ISNULL(usr_supervisor, 'N')
FROM ttsusers
WHERE usr_userid = SUSER_NAME()
	OR usr_windows_userid = SUSER_NAME()

-- soft PTA cannot be more than 4 days after the last planned/completed stop
IF @newPTA > @hardPTAMax
BEGIN
	-- fix Max at user's approved automatic max amount of days
	IF ISNULL(@supervisor, 'N') <> 'Y'
		SET @newPTA = (CASE WHEN  @existingPTADate > @hardPTAMax THEN @existingPTADate ELSE @hardPTAMax END)
END

-- if existing PTA was found and the date is > then use the existing PTA date
IF @newPTA < @existingPTADate
	AND @newPTA <> @ptaDate
	AND @approved = 1
	SET @newPTA = @existingPTADate

IF @ptaType = 'H' 
	AND @originalPtaType = 'S'
	AND (
		@approved = 1
		OR @existingApproved = 1
		)
	AND @hardPTAMax <= @existingPTADate
	-- hard PTA was already approved, allow update
	SET @newPTA = @existingPTADate

-- entered PTA is greater than the previously approved PTA
IF @approved = 1
	AND @existingPTADate < @ptaDate
BEGIN
	SET @approved = 0
	SET @approvedBy = NULL
	SET @approvedOn = NULL
	SET @ptaType = 'H'
	SET @newPTA = @existingPTADate
END

-- need to set the approved flags and information if the user is an supervisor
IF @supervisor = 'Y'
	AND @approved = 0
BEGIN
	SET @approved = 1
	SET @approvedBy = SUSER_NAME()
	SET @approvedOn = @today
END

-- set to soft PTA if it is default code and pta < max possible, it should be a soft PTA
IF @newPTA < @hardPTAMax
	AND @utilCode = @softPTAUtilCode
	SET @ptaType = 'S'

-- if requested date is passed in, and it is greater than the calculated PTA, then replace the calculated date with the requested value
IF @ptaDate > @genesis
	AND @ptaDate > @calculatedMax
	SET @calculatedMax = @ptaDate

DECLARE @outStatus VARCHAR(4)

SELECT @outStatus = lgh_outstatus
FROM legheader
WHERE lgh_number = @curLeg

--Requested Info for emails
DECLARE @requested_date DATETIME,
		@requested_user VARCHAR(128)

IF ISNULL(@supervisor, 'N') <> 'Y'
	SELECT	@requested_date = @today,
			@requested_user = SUSER_NAME()

FinalSelect:

declare @log char (1)
select @log = Left(Isnull (gi_string1, 'N'),1) from dbo.generalinfo where gi_name = 'SoftPTATimeCalcLog'
if @log='Y'
	insert into dbo.legpta_calclog 
	(curLeg, 	ptaType, 	utilCode,
	newPTA, calculatedMax, curTrc,
	today, approved, approvedBy, approvedOn,
	Dodataupdate, outStatus, existingLegPTA, 
	messagedesc, instructions, pta_hard_max, requested_date, requested_user)
	VALUES 
	(@curLeg, @ptaType, @utilCode,
	@newPTA, @calculatedMax, @curTrc,
	@today, @approved, @approvedby, @approvedOn, 
	@doDataUpdate, @outStatus, @existingLegPTA, 
	ISNULL(@messageDesc, 'data update will happen'), @instructions, @hardPtaMax, @requested_date, @requested_user)
	
update @PreCalcTable
set
	curLeg = @curLeg
	,ptaType = @ptaType
	,utilCode = @utilCode
	,newPTA = @newPTA
	,calculatedMax = @calculatedMax
	,curTrc = @curTrc
	,today = @today
	,approved = @approved
	,approvedBy = @approvedby
	,approvedOn = @approvedOn
	,Dodataupdate = @doDataUpdate
	,outStatus = @outStatus
	,existingLegPTA = @existingLegPTA
	,messagedesc = ISNULL(@messageDesc, 'data update will happen')
	,instructions = @instructions
	,pta_hard_max = @hardPTAMax
	,requested_date = @requested_date
	,requested_user = @requested_user
SELECT curLeg
	,ptaType
	,utilCode
	,newPTA
	,calculatedMax
	,curTrc
	,today
	,approved
	,approvedBy
	,approvedOn
	,Dodataupdate
	,outStatus
	,existingLegPTA
	,messagedesc
	,instructions
	,pta_hard_max
	,requested_date
	,requested_user
FROM @PreCalcTable
GO
GRANT EXECUTE ON  [dbo].[LegPTAUpdate_sp_Preprocess] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LegPTAUpdate_sp_Preprocess] TO [public]
GO
