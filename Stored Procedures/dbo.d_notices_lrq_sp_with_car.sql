SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_notices_lrq_sp_with_car] 
	@drv1		VARCHAR(8), 
	@drv2		VARCHAR(8), 
	@trc		VARCHAR(8), 
	@trl1		VARCHAR(13), 
	@trl2		VARCHAR(13), 
	@car		VARCHAR(8), 
	@trip_startdate	DATETIME,
	@trip_enddate	DATETIME,
	@reldate	DATETIME,
	@trl1_startdate DATETIME,
	@trl1_enddate	DATETIME,
	@trl2_startdate DATETIME,
	@trl2_enddate	DATETIME,
	@lghnumber	INTEGER, 
	@movnumber	INTEGER,
	@chassis		VARCHAR(13), 
	@chassis_startdate DATETIME,
	@chassis_enddate	DATETIME,	
	@chassis2		VARCHAR(13), 
	@chassis2_startdate DATETIME,
	@chassis2_enddate	DATETIME,	
	@dolly		VARCHAR(13), 
	@dolly_startdate DATETIME,
	@dolly_enddate	DATETIME,	
	@dolly2		VARCHAR(13), 
	@dolly2_startdate DATETIME,
	@dolly2_enddate	DATETIME,	
	@trailer3		VARCHAR(13), 
	@trailer3_startdate DATETIME,
	@trailer3_enddate	DATETIME,	
	@trailer4		VARCHAR(13), 
	@trailer4_startdate DATETIME,
	@trailer4_enddate	DATETIME	
AS
--PTS 62031 NLOKE changes from Mindy to enhance performance
Set nocount on
set transaction isolation level read uncommitted
--end 62031

DECLARE	@car_pri1soon INTEGER,	@car_pri2soon INTEGER,	@car_pri1now INTEGER, 
		@car_pri2now INTEGER,	@drv1_pri1soon INTEGER,	@drv1_pri2soon INTEGER,
		@drv1_pri1now INTEGER,	@drv1_pri2now INTEGER,	@drv2_pri1soon INTEGER, 
		@drv2_pri2soon INTEGER,	@drv2_pri1now INTEGER,	@drv2_pri2now INTEGER,
		@trc_pri1soon INTEGER,	@trc_pri2soon INTEGER,	@trc_pri1now INTEGER,  
		@trc_pri2now INTEGER,	@trl1_pri1soon INTEGER,	@trl1_pri2soon INTEGER, 
		@trl1_pri1now INTEGER,	@trl1_pri2now INTEGER,	@trl2_pri1soon INTEGER, 
		@trl2_pri2soon INTEGER,	@trl2_pri1now INTEGER,	@trl2_pri2now INTEGER,
		@chassis_pri1soon INTEGER,	@chassis_pri2soon INTEGER,	@chassis_pri1now INTEGER, @chassis_pri2now INTEGER,
		@chassis2_pri1soon INTEGER,	@chassis2_pri2soon INTEGER,	@chassis2_pri1now INTEGER, @chassis2_pri2now INTEGER,
		@dolly_pri1soon INTEGER,	@dolly_pri2soon INTEGER,	@dolly_pri1now INTEGER, @dolly_pri2now INTEGER,
		@dolly2_pri1soon INTEGER,	@dolly2_pri2soon INTEGER,	@dolly2_pri1now INTEGER, @dolly2_pri2now INTEGER,
		@trailer3_pri1soon INTEGER,	@trailer3_pri2soon INTEGER,	@trailer3_pri1now INTEGER, @trailer3_pri2now INTEGER,
		@trailer4_pri1soon INTEGER,	@trailer4_pri2soon INTEGER,	@trailer4_pri1now INTEGER, @trailer4_pri2now INTEGER,
		@lgh_startdate datetime, @lgh_enddate datetime,
		@exp_enddate	DATETIME,
		@expirationuseenddate	CHAR(1),
		@IgnoreCarrierLoadRequirements varchar(1), 
		@lgh_last_stp_mfh integer, @lookback char (1)

SELECT @lookback = ISNull (left(gi_string1, 1), 'N')
	FROM generalinfo 
	WHERE gi_name = 'LoadRequirementsSearchBack'
SELECT @lookback = ISNUll (@lookback, 'N')

select @IgnoreCarrierLoadRequirements = isnull(upper(left(gi_string1, 1)), 'Y')
from generalinfo
where gi_name = 'IgnoreCarrierLoadRequirements'
-- PTS 24247 -- BL (end)

SELECT @lghnumber = ISNULL(@lghnumber, 0)
SELECT @expirationuseenddate = gi_string1 FROM generalinfo WHERE gi_name = 'ExpirationUseEndDate'

IF @drv1 <> 'UNKNOWN' AND @drv1 <> ''
BEGIN
	SELECT	@drv1_pri1soon = CASE WHEN mpp_exp1_date <= @reldate and mpp_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@drv1_pri2soon = CASE WHEN mpp_exp2_date <= @reldate and mpp_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@drv1_pri1now = CASE WHEN @trip_startdate < mpp_exp1_date THEN (CASE WHEN @trip_enddate > mpp_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trip_startdate < mpp_exp1_enddate THEN 1 ELSE 0 END) END,
		@drv1_pri2now = CASE WHEN @trip_startdate < mpp_exp2_date THEN (CASE WHEN @trip_enddate > mpp_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trip_startdate < mpp_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = mpp_exp1_enddate
	FROM	manpowerprofile
	WHERE	mpp_id = @drv1
	IF (@expirationuseenddate = 'Y' and @trip_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'DRV', @drv1, @trip_startdate, @trip_enddate, @drv1_pri1now OUTPUT, @drv1_pri2now OUTPUT
END

IF @drv2 <> 'UNKNOWN' AND @drv2 <> ''
BEGIN
	SELECT	@drv2_pri1soon = CASE WHEN mpp_exp1_date <= @reldate and mpp_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@drv2_pri2soon = CASE WHEN mpp_exp2_date <= @reldate and mpp_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@drv2_pri1now = CASE WHEN @trip_startdate < mpp_exp1_date THEN (CASE WHEN @trip_enddate > mpp_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trip_startdate < mpp_exp1_enddate THEN 1 ELSE 0 END) END,
		@drv2_pri2now = CASE WHEN @trip_startdate < mpp_exp2_date THEN (CASE WHEN @trip_enddate > mpp_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trip_startdate < mpp_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = mpp_exp1_enddate
	FROM	manpowerprofile
	WHERE	mpp_id = @drv2
	IF (@expirationuseenddate = 'Y' and @trip_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'DRV', @drv2, @trip_startdate, @trip_enddate, @drv2_pri1now OUTPUT, @drv2_pri2now OUTPUT
END

IF @trc <> 'UNKNOWN' AND @trc <> ''
BEGIN
	SELECT	@trc_pri1soon = CASE WHEN trc_exp1_date <= @reldate and trc_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@trc_pri2soon = CASE WHEN trc_exp2_date <= @reldate and trc_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@trc_pri1now = CASE WHEN @trip_startdate < trc_exp1_date THEN (CASE WHEN @trip_enddate > trc_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trip_startdate <= trc_exp1_enddate THEN 1 ELSE 0 END) END,
		@trc_pri2now = CASE WHEN @trip_startdate < trc_exp2_date THEN (CASE WHEN @trip_enddate > trc_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trip_startdate <= trc_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = trc_exp1_enddate
	FROM	tractorprofile
	WHERE	trc_number = @trc
	IF (@expirationuseenddate = 'Y' and @trip_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'TRC', @trc, @trip_startdate, @trip_enddate, @trc_pri1now OUTPUT, @trc_pri2now OUTPUT
END

IF @trl1 <> 'UNKNOWN' AND @trl1 <> ''
BEGIN
	SELECT	@trl1_pri1soon = CASE WHEN trl_exp1_date <= @reldate and trl_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@trl1_pri2soon = CASE WHEN trl_exp2_date <= @reldate and trl_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@trl1_pri1now = CASE WHEN @trl1_startdate < trl_exp1_date THEN (CASE WHEN @trl1_enddate > trl_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trl1_startdate <= trl_exp1_enddate THEN 1 ELSE 0 END) END,
		@trl1_pri2now = CASE WHEN @trl1_startdate < trl_exp2_date THEN (CASE WHEN @trl1_enddate > trl_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trl1_startdate <= trl_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = trl_exp1_enddate
	FROM	trailerprofile
	WHERE	trl_id = @trl1
	IF (@expirationuseenddate = 'Y' and @trl1_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'TRL', @trl1, @trl1_startdate, @trl1_enddate, @trl1_pri1now OUTPUT, @trl1_pri2now OUTPUT
END

IF @trl2 <> 'UNKNOWN' AND @trl2 <> ''
BEGIN
	SELECT	@trl2_pri1soon = CASE WHEN trl_exp1_date <= @reldate and trl_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@trl2_pri2soon = CASE WHEN trl_exp2_date <= @reldate and trl_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@trl2_pri1now = CASE WHEN @trl2_startdate < trl_exp1_date THEN (CASE WHEN @trl2_enddate > trl_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trl2_startdate <= trl_exp1_enddate THEN 1 ELSE 0 END) END,
		@trl2_pri2now = CASE WHEN @trl2_startdate < trl_exp2_date THEN (CASE WHEN @trl2_enddate > trl_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trl2_startdate <= trl_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = trl_exp1_enddate
	FROM	trailerprofile
	WHERE	trl_id = @trl2
	IF (@expirationuseenddate = 'Y' and @trl2_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'TRL', @trl2, @trl2_startdate, @trl2_enddate, @trl2_pri1now OUTPUT, @trl2_pri2now OUTPUT
END

--JLB PTS 49323
IF @chassis <> 'UNKNOWN' AND @chassis <> ''
BEGIN
	SELECT	@chassis_pri1soon = CASE WHEN trl_exp1_date <= @reldate and trl_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@chassis_pri2soon = CASE WHEN trl_exp2_date <= @reldate and trl_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@chassis_pri1now = CASE WHEN @chassis_startdate < trl_exp1_date THEN (CASE WHEN @chassis_enddate > trl_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @chassis_startdate <= trl_exp1_enddate THEN 1 ELSE 0 END) END,
		@chassis_pri2now = CASE WHEN @chassis_startdate < trl_exp2_date THEN (CASE WHEN @chassis_enddate > trl_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @chassis_startdate <= trl_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = trl_exp1_enddate
	FROM	trailerprofile
	WHERE	trl_id = @chassis
	IF (@expirationuseenddate = 'Y' and @chassis_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'TRL', @chassis, @chassis_startdate, @chassis_enddate, @chassis_pri1now OUTPUT, @chassis_pri2now OUTPUT
END

IF @chassis2 <> 'UNKNOWN' AND @chassis2 <> ''
BEGIN
	SELECT	@chassis2_pri1soon = CASE WHEN trl_exp1_date <= @reldate and trl_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@chassis2_pri2soon = CASE WHEN trl_exp2_date <= @reldate and trl_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@chassis2_pri1now = CASE WHEN @chassis2_startdate < trl_exp1_date THEN (CASE WHEN @chassis2_enddate > trl_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @chassis2_startdate <= trl_exp1_enddate THEN 1 ELSE 0 END) END,
		@chassis2_pri2now = CASE WHEN @chassis2_startdate < trl_exp2_date THEN (CASE WHEN @chassis2_enddate > trl_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @chassis2_startdate <= trl_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = trl_exp1_enddate
	FROM	trailerprofile
	WHERE	trl_id = @chassis2
	IF (@expirationuseenddate = 'Y' and @chassis2_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'TRL', @chassis2, @chassis2_startdate, @chassis2_enddate, @chassis2_pri1now OUTPUT, @chassis2_pri2now OUTPUT
END

IF @dolly <> 'UNKNOWN' AND @dolly <> ''
BEGIN
	SELECT	@dolly_pri1soon = CASE WHEN trl_exp1_date <= @reldate and trl_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@dolly_pri2soon = CASE WHEN trl_exp2_date <= @reldate and trl_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@dolly_pri1now = CASE WHEN @dolly_startdate < trl_exp1_date THEN (CASE WHEN @dolly_enddate > trl_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @dolly_startdate <= trl_exp1_enddate THEN 1 ELSE 0 END) END,
		@dolly_pri2now = CASE WHEN @dolly_startdate < trl_exp2_date THEN (CASE WHEN @dolly_enddate > trl_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @dolly_startdate <= trl_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = trl_exp1_enddate
	FROM	trailerprofile
	WHERE	trl_id = @dolly
	IF (@expirationuseenddate = 'Y' and @dolly_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'TRL', @dolly, @dolly_startdate, @dolly_enddate, @dolly_pri1now OUTPUT, @dolly_pri2now OUTPUT
END

IF @dolly2 <> 'UNKNOWN' AND @dolly2 <> ''
BEGIN
	SELECT	@dolly2_pri1soon = CASE WHEN trl_exp1_date <= @reldate and trl_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@dolly2_pri2soon = CASE WHEN trl_exp2_date <= @reldate and trl_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@dolly2_pri1now = CASE WHEN @dolly2_startdate < trl_exp1_date THEN (CASE WHEN @dolly2_enddate > trl_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @dolly2_startdate <= trl_exp1_enddate THEN 1 ELSE 0 END) END,
		@dolly2_pri2now = CASE WHEN @dolly2_startdate < trl_exp2_date THEN (CASE WHEN @dolly2_enddate > trl_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @dolly2_startdate <= trl_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = trl_exp1_enddate
	FROM	trailerprofile
	WHERE	trl_id = @dolly2
	IF (@expirationuseenddate = 'Y' and @dolly2_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'TRL', @dolly2, @dolly2_startdate, @dolly2_enddate, @dolly2_pri1now OUTPUT, @dolly2_pri2now OUTPUT
END

IF @trailer3 <> 'UNKNOWN' AND @trailer3 <> ''
BEGIN
	SELECT	@trailer3_pri1soon = CASE WHEN trl_exp1_date <= @reldate and trl_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@trailer3_pri2soon = CASE WHEN trl_exp2_date <= @reldate and trl_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@trailer3_pri1now = CASE WHEN @trailer3_startdate < trl_exp1_date THEN (CASE WHEN @trailer3_enddate > trl_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trailer3_startdate <= trl_exp1_enddate THEN 1 ELSE 0 END) END,
		@trailer3_pri2now = CASE WHEN @trailer3_startdate < trl_exp2_date THEN (CASE WHEN @trailer3_enddate > trl_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trailer3_startdate <= trl_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = trl_exp1_enddate
	FROM	trailerprofile
	WHERE	trl_id = @trailer3
	IF (@expirationuseenddate = 'Y' and @trailer3_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'TRL', @trailer3, @trailer3_startdate, @trailer3_enddate, @trailer3_pri1now OUTPUT, @trailer3_pri2now OUTPUT
END

IF @trailer4 <> 'UNKNOWN' AND @trailer4 <> ''
BEGIN
	SELECT	@trailer4_pri1soon = CASE WHEN trl_exp1_date <= @reldate and trl_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@trailer4_pri2soon = CASE WHEN trl_exp2_date <= @reldate and trl_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@trailer4_pri1now = CASE WHEN @trailer4_startdate < trl_exp1_date THEN (CASE WHEN @trailer4_enddate > trl_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trailer4_startdate <= trl_exp1_enddate THEN 1 ELSE 0 END) END,
		@trailer4_pri2now = CASE WHEN @trailer4_startdate < trl_exp2_date THEN (CASE WHEN @trailer4_enddate > trl_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trailer4_startdate <= trl_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = trl_exp1_enddate
	FROM	trailerprofile
	WHERE	trl_id = @trailer4
	IF (@expirationuseenddate = 'Y' and @trailer4_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'TRL', @trailer4, @trailer4_startdate, @trailer4_enddate, @trailer4_pri1now OUTPUT, @trailer4_pri2now OUTPUT
END
--end 49323

IF @car <> 'UNKNOWN' AND @car <> ''
BEGIN
	SELECT	@car_pri1soon = CASE WHEN car_exp1_date <= @reldate and car_exp1_enddate > @reldate THEN 1 ELSE 0 END,
		@car_pri2soon = CASE WHEN car_exp2_date <= @reldate and car_exp2_enddate > @reldate THEN 1 ELSE 0 END,
		@car_pri1now = CASE WHEN @trip_startdate < car_exp1_date THEN (CASE WHEN @trip_enddate > car_exp1_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trip_startdate <= car_exp1_enddate THEN 1 ELSE 0 END) END,
		@car_pri2now = CASE WHEN @trip_startdate < car_exp2_date THEN (CASE WHEN @trip_enddate > car_exp2_date THEN 1 ELSE 0 END)
				ELSE (CASE WHEN @trip_startdate <= car_exp2_enddate THEN 1 ELSE 0 END) END,
		@exp_enddate = car_exp1_enddate
	FROM	carrier
	WHERE	car_id = @car
	IF (@expirationuseenddate = 'Y' and @trip_startdate > @exp_enddate)
		EXECUTE check_expirations_sp 'CAR', @car, @trip_startdate, @trip_enddate, @car_pri1now OUTPUT, @car_pri2now OUTPUT
END

-- PTS 18488 -- BL (start)
--    Get the start and end dates for the LEG
SELECT 	@lgh_startdate = lgh_startdate,
	@lgh_enddate = lgh_enddate
FROM legheader
WHERE lgh_number = @lghnumber
-- PTS 18488 -- BL (end)
	
--PTS 30462 JJF 12/5/05 Master orders may not have leg defined, hence undefined leg startdate
IF @lgh_startdate IS NULL
	SELECT @lgh_startdate = @trip_startdate
IF @lgh_enddate IS NULL
	SELECT @lgh_enddate = @trip_enddate

DECLARE @lrq TABLE (
	requirement			VARCHAR(80)	NULL,
	lrq_equip_type		VARCHAR(6)	NULL,
	lrq_not				CHAR(1)		NULL,
	lrq_type 			VARCHAR(6)	NULL,
	lrq_manditory		CHAR(1)		NULL,
	asgn_id				VARCHAR(13)	NULL,
	lrq_quantity		INT		NULL,
	def_id_type			VARCHAR(6)	NULL,
	equip_type_str		VARCHAR(20)	NULL,
	not_str				VARCHAR(12)	NULL,
	type_str			VARCHAR(20)	NULL,
	manditory_str		VARCHAR(7)	NULL,
	id_type_str			VARCHAR(13)	NULL,
	lrq_availqty		INTEGER		NULL,
	lrq_inventory_item	CHAR(1)		NULL,
	-- PTS 18488 -- BL (start)
	lrq_expire_date		datetime	NULL)
	-- PTS 18488 -- BL (end)

/* 05/15/2014 MDH PTS 65232: Get the highest mfh_sequence for the leg or move 
   that is loaded -- we will search for all load requirements back from this one */
IF @lookback = 'Y'
BEGIN
	SELECT @lgh_last_stp_mfh = max (stp_mfh_sequence)
		FROM stops 
		WHERE mov_number = @movnumber 
		AND (lgh_number = @lghnumber OR @lghnumber = 0) 
		AND stp_loadstatus = 'LD'
		/* 05/15/2014 MDH PTS 65232: Note: At this point, @lgh_last_stp_mfh can be NULL (indicating empty leg) */	
END 

IF @lookback = 'Y' AND @lgh_last_stp_mfh IS NOT NULL 
BEGIN
	INSERT INTO @lrq
		SELECT	'',
				lrq_equip_type,
				lrq_not,
				lrq_type,
				lrq_manditory,
				CASE
					WHEN lrq_equip_type = 'DRV' AND @drv1 <> 'UNKNOWN' THEN @drv1
					WHEN lrq_equip_type = 'TRC' AND @trc <> 'UNKNOWN' THEN @trc
					WHEN lrq_equip_type = 'TRL' AND @trl1 <> 'UNKNOWN' THEN @trl1
					WHEN lrq_equip_type = 'CAR' AND @CAR <> 'UNKNOWN' THEN @car
					ELSE 'UNKNOWN'
				END,
				ISNULL(lrq_quantity, 0),
				def_id_type,
				ISNULL(lf1.name, ''),
				CASE 
					WHEN lrq_not = 'N' THEN ' not have/be' 
					ELSE ' have/be' 
				END,
				ISNULL(lf2.name, ''),
				CASE 
					WHEN lrq_manditory = 'Y' THEN ' must' 
					ELSE ' should' 
				END,
				CASE 
					WHEN def_id_type = 'PUP' THEN 'Pickup ' 
					WHEN def_id_type = 'DRP' THEN 'Drop ' 
					ELSE 'Both ' 
				END,
				0,
				'N',
				lr.lrq_expire_date
		  FROM	loadrequirement lr,
				labelfile lf1,
				labelfile lf2,
				stops s,
				freightdetail f
		 WHERE	lr.mov_number = @movnumber AND
				ISNULL(lr.lrq_default, 'N') <> 'X' AND
				lr.lrq_equip_type = lf1.abbr AND
				lf1.labeldefinition = 'AssType' AND
				lr.lrq_type = lf2.abbr AND
				lf2.labeldefinition IN ('TrlAcc', 'TrcAcc', 'DrvAcc', 'CarQual') AND	-- PTS 36742 BDH added CarQual.
				s.stp_number = f.stp_number AND
				s.mov_number = @movnumber AND
				/* (s.lgh_number = @lghnumber OR @lghnumber = 0) AND */
				(s.stp_mfh_sequence <= @lgh_last_stp_mfh) AND
				(s.cmp_id = lr.cmp_id OR lr.cmp_id = 'UNKNOWN') AND
				(f.cmd_code = lr.cmd_code OR lr.cmd_code = 'UNKNOWN') AND
				( (s.stp_type = lr.def_id_type AND s.ord_hdrnumber>0) OR lr.def_id_type = 'BOTH') --vjh 20516
				AND ISNULL(lr.lrq_expire_date,'20491231 23:59:59') >= @lgh_startdate
	
	/* 
	*	PTS 41178 - DJM - 4/07/08 - Capture Load Requirements for Bill To companies.
	*/
	INSERT INTO @lrq
		SELECT	'',
				lrq_equip_type,
				lrq_not,
				lrq_type,
				lrq_manditory,
				CASE
					WHEN lrq_equip_type = 'DRV' AND @drv1 <> 'UNKNOWN' THEN @drv1
					WHEN lrq_equip_type = 'TRC' AND @trc <> 'UNKNOWN' THEN @trc
					WHEN lrq_equip_type = 'TRL' AND @trl1 <> 'UNKNOWN' THEN @trl1
					WHEN lrq_equip_type = 'CAR' AND @CAR <> 'UNKNOWN' THEN @car
					ELSE 'UNKNOWN'
				END,
				ISNULL(lrq_quantity, 0),
				def_id_type,
				ISNULL(lf1.name, ''),
				CASE 
					WHEN lrq_not = 'N' THEN ' not have/be' 
					ELSE ' have/be' 
				END,
				ISNULL(lf2.name, ''),
				CASE 
					WHEN lrq_manditory = 'Y' THEN ' must' 
					ELSE ' should' 
				END,
				CASE 
					WHEN def_id_type = 'PUP' THEN 'Pickup ' 
					WHEN def_id_type = 'DRP' THEN 'Drop ' 
					ELSE 'Both ' 
				END,
				0,
				'N',
				lr.lrq_expire_date
		  FROM	loadrequirement lr join labelfile lf1 on lr.lrq_equip_type = lf1.abbr AND lf1.labeldefinition = 'AssType'
				join labelfile lf2 on lr.lrq_type = lf2.abbr AND lf2.labeldefinition IN ('TrlAcc', 'TrcAcc', 'DrvAcc', 'CarQual'),	-- PTS 36742 BDH added CarQual.
				stops s join freightdetail f on s.stp_number = f.stp_number
		 WHERE	lr.mov_number = @movnumber 
				AND ISNULL(lr.lrq_default, 'N') <> 'X' 
				AND s.mov_number = @movnumber
				and (f.cmd_code = lr.cmd_code OR lr.cmd_code = 'UNKNOWN')
				/* AND (s.lgh_number = @lghnumber OR @lghnumber = 0) */
				AND (s.stp_mfh_sequence <= @lgh_last_stp_mfh) 
				AND s.ord_hdrnumber = (select ord_hdrnumber from orderheader o where o.ord_hdrnumber = s.ord_hdrnumber and o.ord_billto = lr.cmp_id)
				and ( (s.stp_type = lr.def_id_type AND s.ord_hdrnumber>0) OR lr.def_id_type = 'BOTH') --vjh 20516
				AND ISNULL(lr.lrq_expire_date,'20491231 23:59:59') >= @trip_startdate
END
ELSE
BEGIN
	INSERT INTO @lrq
		SELECT	'',
				lrq_equip_type,
				lrq_not,
				lrq_type,
				lrq_manditory,
				CASE
					WHEN lrq_equip_type = 'DRV' AND @drv1 <> 'UNKNOWN' THEN @drv1
					WHEN lrq_equip_type = 'TRC' AND @trc <> 'UNKNOWN' THEN @trc
					WHEN lrq_equip_type = 'TRL' AND @trl1 <> 'UNKNOWN' THEN @trl1
					WHEN lrq_equip_type = 'CAR' AND @CAR <> 'UNKNOWN' THEN @car
					ELSE 'UNKNOWN'
				END,
				ISNULL(lrq_quantity, 0),
				def_id_type,
				ISNULL(lf1.name, ''),
				CASE 
					WHEN lrq_not = 'N' THEN ' not have/be' 
					ELSE ' have/be' 
				END,
				ISNULL(lf2.name, ''),
				CASE 
					WHEN lrq_manditory = 'Y' THEN ' must' 
					ELSE ' should' 
				END,
				CASE 
					WHEN def_id_type = 'PUP' THEN 'Pickup ' 
					WHEN def_id_type = 'DRP' THEN 'Drop ' 
					ELSE 'Both ' 
				END,
				0,
				'N',
				lr.lrq_expire_date
		  FROM	loadrequirement lr,
				labelfile lf1,
				labelfile lf2,
				stops s,
				freightdetail f
		 WHERE	lr.mov_number = @movnumber AND
				ISNULL(lr.lrq_default, 'N') <> 'X' AND
				lr.lrq_equip_type = lf1.abbr AND
				lf1.labeldefinition = 'AssType' AND
				lr.lrq_type = lf2.abbr AND
				lf2.labeldefinition IN ('TrlAcc', 'TrcAcc', 'DrvAcc', 'CarQual') AND	-- PTS 36742 BDH added CarQual.
				s.stp_number = f.stp_number AND
				s.mov_number = @movnumber AND
				(s.lgh_number = @lghnumber OR @lghnumber = 0) AND 
				(s.cmp_id = lr.cmp_id OR lr.cmp_id = 'UNKNOWN') AND
				(f.cmd_code = lr.cmd_code OR lr.cmd_code = 'UNKNOWN') AND
				( (s.stp_type = lr.def_id_type AND s.ord_hdrnumber>0) OR lr.def_id_type = 'BOTH') --vjh 20516
				AND ISNULL(lr.lrq_expire_date,'20491231 23:59:59') >= @lgh_startdate
	
	/* 
	*	PTS 41178 - DJM - 4/07/08 - Capture Load Requirements for Bill To companies.
	*/
	INSERT INTO @lrq
		SELECT	'',
				lrq_equip_type,
				lrq_not,
				lrq_type,
				lrq_manditory,
				CASE
					WHEN lrq_equip_type = 'DRV' AND @drv1 <> 'UNKNOWN' THEN @drv1
					WHEN lrq_equip_type = 'TRC' AND @trc <> 'UNKNOWN' THEN @trc
					WHEN lrq_equip_type = 'TRL' AND @trl1 <> 'UNKNOWN' THEN @trl1
					WHEN lrq_equip_type = 'CAR' AND @CAR <> 'UNKNOWN' THEN @car
					ELSE 'UNKNOWN'
				END,
				ISNULL(lrq_quantity, 0),
				def_id_type,
				ISNULL(lf1.name, ''),
				CASE 
					WHEN lrq_not = 'N' THEN ' not have/be' 
					ELSE ' have/be' 
				END,
				ISNULL(lf2.name, ''),
				CASE 
					WHEN lrq_manditory = 'Y' THEN ' must' 
					ELSE ' should' 
				END,
				CASE 
					WHEN def_id_type = 'PUP' THEN 'Pickup ' 
					WHEN def_id_type = 'DRP' THEN 'Drop ' 
					ELSE 'Both ' 
				END,
				0,
				'N',
				lr.lrq_expire_date
		  FROM	loadrequirement lr join labelfile lf1 on lr.lrq_equip_type = lf1.abbr AND lf1.labeldefinition = 'AssType'
				join labelfile lf2 on lr.lrq_type = lf2.abbr AND lf2.labeldefinition IN ('TrlAcc', 'TrcAcc', 'DrvAcc', 'CarQual'),	-- PTS 36742 BDH added CarQual.
				stops s join freightdetail f on s.stp_number = f.stp_number
		 WHERE	lr.mov_number = @movnumber 
				AND ISNULL(lr.lrq_default, 'N') <> 'X' 
				AND s.mov_number = @movnumber
				and (f.cmd_code = lr.cmd_code OR lr.cmd_code = 'UNKNOWN')
				AND (s.lgh_number = @lghnumber OR @lghnumber = 0) 
				AND s.ord_hdrnumber = (select ord_hdrnumber from orderheader o where o.ord_hdrnumber = s.ord_hdrnumber and o.ord_billto = lr.cmp_id)
				and ( (s.stp_type = lr.def_id_type AND s.ord_hdrnumber>0) OR lr.def_id_type = 'BOTH') --vjh 20516
				AND ISNULL(lr.lrq_expire_date,'20491231 23:59:59') >= @trip_startdate
END 
IF (SELECT COUNT(*) FROM @lrq) > 0
BEGIN
	IF @drv2 <> 'UNKNOWN'
		INSERT INTO @lrq
			SELECT	requirement,
					lrq_equip_type,
					lrq_not,
					lrq_type,
					lrq_manditory,
					@drv2,
					lrq_quantity = isnull(lrq_quantity, 0),
					def_id_type,
					equip_type_str,
					not_str,
					type_str,
					manditory_str,
					id_type_str,
					0,
					'N',
					-- PTS 18488 -- BL (start)
					lrq_expire_date
					-- PTS 18488 -- BL (end)
			  FROM	@lrq
			 WHERE	lrq_equip_type = 'DRV'

	IF @trl2 <> 'UNKNOWN'
		INSERT INTO @lrq
			SELECT	requirement,
					lrq_equip_type,
					lrq_not,
					lrq_type,
					lrq_manditory,
					@trl2,
					lrq_quantity = isnull(lrq_quantity, 0),
					def_id_type,
					equip_type_str,
					not_str,
					type_str,
					manditory_str,
					id_type_str,
					0,
					'N',
					-- PTS 18488 -- BL (start)
					lrq_expire_date
					-- PTS 18488 -- BL (end)
			  FROM	@lrq
			 WHERE	lrq_equip_type = 'TRL'
--JLB PTS 49323
	IF @trailer3 <> 'UNKNOWN'
		INSERT INTO @lrq
			SELECT	requirement,
					lrq_equip_type,
					lrq_not,
					lrq_type,
					lrq_manditory,
					@trailer3,
					lrq_quantity = isnull(lrq_quantity, 0),
					def_id_type,
					equip_type_str,
					not_str,
					type_str,
					manditory_str,
					id_type_str,
					0,
					'N',
					-- PTS 18488 -- BL (start)
					lrq_expire_date
					-- PTS 18488 -- BL (end)
			  FROM	@lrq
			 WHERE	lrq_equip_type = 'TRL'
			   AND	asgn_id = @trl1
	IF @trailer4 <> 'UNKNOWN'
		INSERT INTO @lrq
			SELECT	requirement,
					lrq_equip_type,
					lrq_not,
					lrq_type,
					lrq_manditory,
					@trailer4,
					lrq_quantity = isnull(lrq_quantity, 0),
					def_id_type,
					equip_type_str,
					not_str,
					type_str,
					manditory_str,
					id_type_str,
					0,
					'N',
					-- PTS 18488 -- BL (start)
					lrq_expire_date
					-- PTS 18488 -- BL (end)
			  FROM	@lrq
			 WHERE	lrq_equip_type = 'TRL'
			   AND	asgn_id = @trl1
--end 49323
			 

	UPDATE	@lrq
	   SET	lrq_inventory_item = 'Y'
	 WHERE	EXISTS(SELECT	* 
					 FROM	labelfile
					WHERE	labeldefinition = 'TrcAcc' AND
							inventory_item = 'Y' AND
							abbr = lrq_type) AND
			lrq_equip_type = 'TRC'

	UPDATE	@lrq
	   SET	lrq_inventory_item = 'Y'
	 WHERE	EXISTS(SELECT	* 
					 FROM	labelfile
					WHERE	labeldefinition = 'TrlAcc' AND
							inventory_item = 'Y' AND
							abbr = lrq_type) AND
			lrq_equip_type = 'TRL'
	
	UPDATE	@lrq
	   SET	lrq_availqty = inventory_log.il_quantity
	  FROM	inventory_log
	 WHERE	inventory_log.il_trailer = asgn_id AND
			inventory_log.il_type = lrq_type AND
			inventory_log.il_inventory_date = (SELECT	MAX(il_inventory_date) 
												 FROM	inventory_log
												WHERE	il_trailer = asgn_id AND
														il_type = lrq_type) AND
			lrq_equip_type = 'TRL'

	UPDATE	@lrq
	   SET	lrq_availqty = inventory_log.il_quantity
	  FROM	inventory_log
	 WHERE	inventory_log.il_tractor = asgn_id AND
			inventory_log.il_type = lrq_type AND
			inventory_log.il_inventory_date = (SELECT	MAX(il_inventory_date) 
												 FROM	inventory_log
												WHERE	il_tractor = asgn_id AND
														il_type = lrq_type) AND
			lrq_equip_type = 'TRC'
	
-- Parse the load requirement string
	UPDATE	@lrq
	   SET	requirement = 'At ' + id_type_str + ' ' + equip_type_str + manditory_str 
								+ not_str + ' ' + type_str + ' Qty: '
								+ convert(char(3), lrq_quantity)
END


IF (SELECT COUNT(*) FROM @lrq) > 0
	SELECT	DISTINCT @drv1 drv1, @drv1_pri1soon drv1_pri1soon, @drv1_pri2soon drv1_pri2soon, 
			@drv1_pri1now drv1_pri1now, @drv1_pri2now drv1_pri2now, 
			@drv2 drv2, @drv2_pri1soon drv2_pri1soon, @drv2_pri2soon drv2_pri2soon,
			@drv2_pri1now drv2_pri1now, @drv2_pri2now drv2_pri2now, 
			@trc trc, @trc_pri1soon trc_pri1soon, @trc_pri2soon trc_pri2soon,  
			@trc_pri1now trc_pri1now,  @trc_pri2now trc_pri2now,
			@trl1 trl1, @trl1_pri1soon trl1_pri1soon, @trl1_pri2soon trl1_pri2soon, 
			@trl1_pri1now trl1_pri1now, @trl1_pri2now trl1_pri2now, 
			@trl2 trl2, @trl2_pri1soon trl2_pri1soon, @trl2_pri2soon trl2_pri2soon,
			@trl2_pri1now trl2_pri1now, @trl2_pri2now trl2_pri2now, 
			lrq_equip_type, lrq_not, lrq_type, lrq_manditory, requirement, asgn_id, 
			@car car, @car_pri1soon car_pri1soon, @car_pri2soon car_pri2soon,
			@car_pri1now car_pri1now, @car_pri2now car_pri2now, lrq_quantity, lrq_availqty, lrq_inventory_item,
			-- PTS 18488 -- BL (start)
			lrq_expire_date, @lgh_enddate, @lgh_startdate,
			-- PTS 18488 -- BL (end)
			@chassis chassis,	@chassis_pri1soon chassis_pri1soon,		@chassis_pri2soon chassis_pri2soon,		@chassis_pri1now chassis_pri1now, 	@chassis_pri2now chassis_pri2now,
			@chassis2 chassis2, @chassis2_pri1soon chassis2_pri1soon,	@chassis2_pri2soon chassis2_pri2soon,	@chassis2_pri1now chassis2_pri1now, @chassis2_pri2now chassis2_pri2now,
			@dolly dolly,		@dolly_pri1soon dolly_pri1soon,			@dolly_pri2soon dolly_pri2soon,			@dolly_pri1now dolly_pri1now, 		@dolly_pri2now dolly_pri2now,
			@dolly2 dolly2 ,	@dolly2_pri1soon dolly2_pri1soon,		@dolly2_pri2soon dolly2_pri2soon,		@dolly2_pri1now dolly2_pri1now,		@dolly2_pri2now dolly2_pri2now,
			@trailer3 trailer3, @trailer3_pri1soon trailer3_pri1soon,	@trailer3_pri2soon trailer3_pri2soon,	@trailer3_pri1now trailer3_pri1now, @trailer3_pri2now trailer3_pri2now,
			@trailer4 trailer4, @trailer4_pri1soon trailer4_pri1soon,	@trailer4_pri2soon trailer4_pri2soon,	@trailer4_pri1now trailer4_pri1now, @trailer4_pri2now trailer4_pri2now, def_id_type
			
	  FROM @lrq
ELSE
	SELECT	@drv1 drv1, @drv1_pri1soon drv1_pri1soon, @drv1_pri2soon drv1_pri2soon, 
			@drv1_pri1now drv1_pri1now, @drv1_pri2now drv1_pri2now, 
			@drv2 drv2, @drv2_pri1soon drv2_pri1soon, @drv2_pri2soon drv2_pri2soon,
			@drv2_pri1now drv2_pri1now, @drv2_pri2now drv2_pri2now, 
			@trc trc, @trc_pri1soon trc_pri1soon, @trc_pri2soon trc_pri2soon,  
			@trc_pri1now trc_pri1now,  @trc_pri2now trc_pri2now,
			@trl1 trl1, @trl1_pri1soon trl1_pri1soon, @trl1_pri2soon trl1_pri2soon, 
			@trl1_pri1now trl1_pri1now, @trl1_pri2now trl1_pri2now, 
			@trl2 trl2, @trl2_pri1soon trl2_pri1soon, @trl2_pri2soon trl2_pri2soon,
			@trl2_pri1now trl2_pri1now, @trl2_pri2now trl2_pri2now,		
			convert(char(6), '') lrq_equip_type, ' ' lrq_not, convert(char(6), '') lrq_type,
			' ' lrq_manditory, convert(char(80), '') requirement, 
			convert(char(13), '') asgn_id,
			@car car, @car_pri1soon car_pri1soon, @car_pri2soon car_pri2soon,
			@car_pri1now car_pri1now, @car_pri2now car_pri2now, 0 lrq_quantity,	0 lrq_availqty, 'N' lrq_inventory_item,
			-- PTS 18488 -- BL (start)
			convert(datetime, '2049-12-31 23:59'), @lgh_enddate, @lgh_startdate,
			-- PTS 18488 -- BL (end)
			@chassis chassis,	@chassis_pri1soon chassis_pri1soon,		@chassis_pri2soon chassis_pri2soon,		@chassis_pri1now chassis_pri1now, 	@chassis_pri2now chassis_pri2now,
			@chassis2 chassis2, @chassis2_pri1soon chassis2_pri1soon,	@chassis2_pri2soon chassis2_pri2soon,	@chassis2_pri1now chassis2_pri1now, @chassis2_pri2now chassis2_pri2now,
			@dolly dolly,		@dolly_pri1soon dolly_pri1soon,			@dolly_pri2soon dolly_pri2soon,			@dolly_pri1now dolly_pri1now, 		@dolly_pri2now dolly_pri2now,
			@dolly2 dolly2 ,	@dolly2_pri1soon dolly2_pri1soon,		@dolly2_pri2soon dolly2_pri2soon,		@dolly2_pri1now dolly2_pri1now,		@dolly2_pri2now dolly2_pri2now,
			@trailer3 trailer3, @trailer3_pri1soon trailer3_pri1soon,	@trailer3_pri2soon trailer3_pri2soon,	@trailer3_pri1now trailer3_pri1now, @trailer3_pri2now trailer3_pri2now,
			@trailer4 trailer4, @trailer4_pri1soon trailer4_pri1soon,	@trailer4_pri2soon trailer4_pri2soon,	@trailer4_pri1now trailer4_pri1now, @trailer4_pri2now trailer4_pri2now, 'Both'
GO
GRANT EXECUTE ON  [dbo].[d_notices_lrq_sp_with_car] TO [public]
GO
