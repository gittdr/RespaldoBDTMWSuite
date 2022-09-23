SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_GetOpenStops2] (	@AsgnID AS VARCHAR(30), 
												@AsgnType AS VARCHAR(20), 
												@Flags AS VARCHAR(255), 
												@LAFlags AS VARCHAR(255), 
												@EarlyToleranceHours AS VARCHAR, 
												@LateToleranceHours AS VARCHAR)

AS
--select 
/*
Flags
	1 - Exclude STD
	2 - Exclude DSP
	4 - Include PLN
	8 - Delete Duplicate Stops Between Legheaders
	16 - Delete First Stop in Open Stops
	32 - Set found leg headers to Dispatched status
*/

SET NOCOUNT ON 

DECLARE @iFlags AS INT
DECLARE @iLAFlags AS INT
DECLARE @ExcludeSTD AS INT
DECLARE @ExcludeDSP AS INT
DECLARE @IncludePLN AS INT
DECLARE @DeleteDup AS INT
DECLARE @StartDate AS DATETIME
DECLARE @StopCount AS INT
DECLARE @CmpLeg AS INT
DECLARE @DeleteFirst as INT
DECLARE @iEarlyToleranceHours AS INT
DECLARE @iLateToleranceHours AS INT
DECLARE @iSetToDispatched AS INT

SELECT @iEarlyToleranceHours = convert(int,@EarlyToleranceHours)
SELECT @iLateToleranceHours = convert(int,@LateToleranceHours)


CREATE TABLE #tmpStops
(
	sn INT IDENTITY,
	StopNumber INT,
	Tractor  VARCHAR(255),
	DriverID VARCHAR(255),
	lgh_number INT,
	StopMoveSeq INT,
	StopCompanyID VARCHAR(30) NULL,
	ToBeDeleted INT
)

CREATE TABLE #tmpLegs
(
	sn INT IDENTITY,
	lgh_number INT,
	seq INT,
	asgn_id VARCHAR(30),
	asgn_type VARCHAR(6),
	asgn_date DATETIME,
	earliest_date DATETIME
)

--Validate Parameters
IF @AsgnType = 'TRC' OR @AsgnType = 'DRV'
BEGIN
	IF @AsgnType = 'TRC'
	BEGIN
		IF NOT EXISTS (SELECT NULL 
						FROM tractorprofile (NOLOCK)
						WHERE trc_number = @AsgnID)
		BEGIN
			RAISERROR ('INVALID TRC:  %s.',16,1, @AsgnID)
			RETURN
		END
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT NULL 
						FROM manpowerprofile (NOLOCK)
						WHERE mpp_id = @AsgnID)
		BEGIN
			RAISERROR ('INVALID DRV:  %s.',16,1, @AsgnID)
			RETURN
		END
	END
END
ELSE
BEGIN
	RAISERROR ('INVALID ASSIGNMENT TYPE:  %s.',16,1, @AsgnType)
	RETURN
END

--Initialize Flags	
SET @ExcludeSTD =0
SET @ExcludeDSP =0
SET @IncludePLN =0
SET @DeleteDup =0
SET @DeleteFirst=0
SET @iSetToDispatched=0

IF ISNULL(@Flags,'')=''
	SET @Flags = '0'

IF ISNULL(@LAFlags,'')=''
	SET @LAFlags = '0'

--Need to send open stops only, but user can adjust LAFlags in addition to flag 8192
IF @LAFlags & 8192 = 0
	SET @LAFlags = @LAFlags + 8192

IF ISNUMERIC(ISNULL(@Flags,0))= 0
BEGIN
	RAISERROR ('INVALID FLAG:  %s.',16,1, @Flags)
	RETURN
END
ELSE
BEGIN
	SET @iFlags = convert(INT, @Flags)
	IF @iFlags & 1 <>0
		SET @ExcludeSTD = 1
	IF @iFlags & 2 <>0
		SET @ExcludeDSP = 1
	IF @iFlags & 4 <>0
		SET @IncludePLN = 1
	IF @iFlags & 8 <>0
		SET @DeleteDup = 1
	IF @iFlags & 16 <>0
		SET @DeleteFirst = 1
	IF @iFlags & 32 <> 0
		SET @iSetToDispatched = 1
END

--Get all the legs for the asset order by STD, DSP, PLN and then by assignment date	
INSERT INTO #tmpLegs
SELECT assetassignment.lgh_number, CASE asgn_status WHEN 'STD' THEN 1 WHEN 'DSP' THEN 2 WHEN 'PLN' THEN 3 END AS [seq],asgn_id, asgn_type, asgn_date, lgh_schdtearliest
FROM assetassignment (NOLOCK), legheader (NOLOCK)
WHERE asgn_type = @AsgnType
	AND asgn_id = @AsgnID
	AND assetassignment.lgh_number = legheader.lgh_number
	AND ((@ExcludeSTD = 1 AND asgn_status <> 'STD') OR @ExcludeSTD = 0)
	AND ((@ExcludeDSP = 1 AND asgn_status <> 'DSP') OR @ExcludeDSP = 0)
	AND ((@IncludePLN = 0 AND asgn_status <> 'PLN') OR @IncludePLN = 1)
	AND asgn_status <> 'CMP'
	AND lgh_startdate >= CASE WHEN ISNULL(@iEarlyToleranceHours, -1) <= 0 THEN  lgh_startdate ELSE DATEADD(hh, - @iEarlyToleranceHours, getdate() ) END
	AND lgh_startdate <= CASE WHEN ISNULL(@iLateToleranceHours, -1) <= 0 THEN  lgh_startdate ELSE DATEADD(hh, @iLateToleranceHours, getdate()) END
ORDER BY [seq],asgn_date, assetassignment.lgh_number

DECLARE @i INT
DECLARE @leg INT

SELECT @StartDate = ISNULL(lgh_startdate,'01/01/1950 00:00')
FROM legheader 
	JOIN #tmpLegs ON legheader.lgh_number = #tmpLegs.lgh_number
WHERE #tmpLegs.sn = 1

WHILE EXISTS (SELECT NULL FROM #tmpLegs)
BEGIN
	SELECT @i = MIN(sn) FROM #tmpLegs
	
	SELECT @leg = lgh_number FROM #tmpLegs WHERE sn = @i

	--Use standard load assignment stored proc to get the stops for the legs
	INSERT INTO #tmpStops
		EXEC tmail_load_assign5_sp '','',@leg,@LAFlags,'','','','','StopNumber,Tractor,DriverID,lgh_number,StopMoveSeq,StopCompanyID,0'

	IF @iSetToDispatched <> 0
		BEGIN
		IF @AsgnType = 'DRV'
			BEGIN
				EXEC tmail_dispatch_lgh2 '', '', @AsgnID, @leg, @LAFlags
			END
		ELSE IF @AsgnType = 'TRC'
			BEGIN
				EXEC tmail_dispatch_lgh2 '', @AsgnID, '', @leg, @LAFlags
			END
		END

	DELETE FROM #tmpLegs WHERE sn = @i

END

IF @DeleteDup = 1
BEGIN
	UPDATE #tmpStops
	SET ToBeDeleted = 5	-- Use a different value here to indicate suppressed stops, not just a stop that needs deleted.
	FROM #tmpStops
	inner join #tmpStops b ON b.sn = #tmpStops.sn - 1
	WHERE #tmpStops.sn <> 1
		AND #tmpStops.StopCompanyId = b.StopCompanyId

	DELETE FROM #tmpStops where ToBeDeleted = 5

END

IF @DeleteFirst = 1
BEGIN
	UPDATE #tmpStops
	SET ToBeDeleted = 5
	WHERE sn=1
	
	
	DELETE FROM #tmpStops where ToBeDeleted = 5
END

SELECT @StopCount = COUNT(*) FROM #tmpStops

SELECT	@StartDate as StartDate,
		@StopCount as StopCount,
		StopNumber, 
		Tractor,
		DriverID,
		lgh_number
FROM #tmpStops


GO
GRANT EXECUTE ON  [dbo].[tmail_GetOpenStops2] TO [public]
GO
