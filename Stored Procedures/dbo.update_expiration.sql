SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[update_expiration] @idtype varchar(6), @id varchar(13)
AS

--PTS 62031 NLOKE changes from Mindy to enhance performance
Set nocount on
Set transaction isolation level read uncommitted
--end 62031
BEGIN

DECLARE @exp1_date	datetime,
	@exp2_date	datetime,
	@exp1_enddate	datetime,
	@exp2_enddate	datetime,
	@begin_date	datetime,
	@end_date	datetime,
	@apocalypse	datetime,
	@count		integer

SELECT	@apocalypse = '12/31/2049 11:59:00 PM'

-- PTS 27060 -- BL (start)
--SELECT	@begin_date = MIN(exp_expirationdate)
--FROM	expiration
--WHERE 	exp_idtype = @idtype AND exp_id = @id and 
--	exp_completed = 'N' and
--	exp_priority = '1'
SELECT	@begin_date = MIN(exp_expirationdate)
FROM	expiration, labelfile
WHERE 	exp_idtype = @idtype AND exp_id = @id and 
	exp_completed = 'N' and
	exp_priority = '1'
	and expiration.exp_code = labelfile.abbr
-- PTS 27463 -- BL (start)
	and labelfile.labeldefinition = (CASE @idtype
							WHEN 'CAR' THEN 'CarExp'
							WHEN 'DRV' THEN 'DrvExp'
							WHEN 'TRC' THEN 'TrcExp'
							WHEN 'TRL' THEN 'TrlExp'
						 END)
-- PTS 27463 -- BL (end)
-- PTS 27060 -- BL (end)

SELECT	@end_date = MAX((CASE ISNULL(l.auto_complete, 'N')
							WHEN 'Y' THEN e.exp_compldate
							ELSE @apocalypse
						 END)), 
		@count = COUNT(*)
FROM	expiration e,
		labelfile l
WHERE 	e.exp_idtype = @idtype AND e.exp_id = @id and 
	e.exp_completed = 'N' and
	e.exp_priority = '1' and
	e.exp_expirationdate = @begin_date and
	e.exp_code = l.abbr and
	l.labeldefinition = (CASE @idtype
							WHEN 'CAR' THEN 'CarExp'
							WHEN 'DRV' THEN 'DrvExp'
							WHEN 'TRC' THEN 'TrcExp'
							WHEN 'TRL' THEN 'TrlExp'
						 END)

SELECT	@exp1_date = @begin_date, @exp1_enddate = @end_date

WHILE (@count > 0 AND @exp1_enddate < @apocalypse)
BEGIN
	SELECT	@begin_date = MAX(exp_expirationdate),
			@end_date = MAX((CASE ISNULL(l.auto_complete, 'N')
								WHEN 'Y' THEN e.exp_compldate
								ELSE @apocalypse
							 END)), 
			@count = COUNT(*)
	FROM	expiration e,
			labelfile l
	WHERE 	e.exp_idtype = @idtype AND e.exp_id = @id and 
		e.exp_completed = 'N' and
		e.exp_priority = '1' and
		e.exp_expirationdate >= @begin_date AND
		e.exp_expirationdate <= @end_date AND
		e.exp_code = l.abbr and
		l.labeldefinition = (CASE @idtype
								WHEN 'CAR' THEN 'CarExp'
								WHEN 'DRV' THEN 'DrvExp'
								WHEN 'TRC' THEN 'TrcExp'
								WHEN 'TRL' THEN 'TrlExp'
							 END)

	IF @end_date = @exp1_enddate
		SELECT @count = 0

	IF @count > 0
		SELECT	@exp1_enddate = @end_date
END

SELECT	@begin_date = MIN(exp_expirationdate)
FROM	expiration
WHERE 	exp_idtype = @idtype AND exp_id = @id and 
	exp_completed = 'N' and
	exp_priority > '1'

SELECT	@end_date = MAX((CASE ISNULL(l.auto_complete, 'N')
							WHEN 'Y' THEN e.exp_compldate
							ELSE @apocalypse
						 END)), 
		@count = COUNT(*)
FROM	expiration e,
		labelfile l
WHERE 	e.exp_idtype = @idtype AND e.exp_id = @id and 
	e.exp_completed = 'N' and
	e.exp_priority > '1' and
	e.exp_expirationdate = @begin_date and
	e.exp_code = l.abbr and
	l.labeldefinition = (CASE @idtype
							WHEN 'CAR' THEN 'CarExp'
							WHEN 'DRV' THEN 'DrvExp'
							WHEN 'TRC' THEN 'TrcExp'
							WHEN 'TRL' THEN 'TrlExp'
						 END)

SELECT	@exp2_date = @begin_date, @exp2_enddate = @end_date

WHILE (@count > 0 AND @end_date < @apocalypse)
BEGIN
	SELECT	@begin_date = MAX(exp_expirationdate),
			@end_date = MAX((CASE ISNULL(l.auto_complete, 'N')
								WHEN 'Y' THEN e.exp_compldate
								ELSE @apocalypse
							 END)), 
			@count = COUNT(*)
	FROM	expiration e,
			labelfile l
	WHERE 	e.exp_idtype = @idtype AND e.exp_id = @id and 
		e.exp_completed = 'N' and
		e.exp_priority > '1' and
		e.exp_expirationdate >= @begin_date AND
		e.exp_expirationdate <= @end_date AND
		e.exp_code = l.abbr and
		l.labeldefinition = (CASE @idtype
								WHEN 'CAR' THEN 'CarExp'
								WHEN 'DRV' THEN 'DrvExp'
								WHEN 'TRC' THEN 'TrcExp'
								WHEN 'TRL' THEN 'TrlExp'
							 END)

	IF @end_date = @exp2_enddate
		SELECT @count = 0

	IF @count > 0
		SELECT	@exp2_enddate = @end_date
END

IF  @idtype = 'DRV'
BEGIN
	UPDATE	manpowerprofile
	SET	mpp_exp1_date = @exp1_date,
		mpp_exp1_enddate = @exp1_enddate,
		mpp_exp2_date = @exp2_date,
		mpp_exp2_enddate = @exp2_enddate
	WHERE	mpp_id = @id
	--JLB PTS 28174 need to run exp status procs to sync assets master file
	exec drv_expstatus @id
	--end 28174
END
IF @idtype = 'TRC'
BEGIN
	UPDATE	tractorprofile
	SET	trc_exp1_date = @exp1_date,
		trc_exp1_enddate = @exp1_enddate,
		trc_exp2_date = @exp2_date,
		trc_exp2_enddate = @exp2_enddate
	WHERE	trc_number = @id
	--JLB PTS 28174 need to run exp status procs to sync assets master file
	exec trc_expstatus @id
	--end 28174
END
IF @idtype = 'TRL'
BEGIN
	UPDATE	trailerprofile
	SET	trl_exp1_date = @exp1_date,
		trl_exp1_enddate = @exp1_enddate,
		trl_exp2_date = @exp2_date,
		trl_exp2_enddate = @exp2_enddate
	WHERE	trl_id = @id
	--JLB PTS 28174 need to run exp status procs to sync assets master file
	exec trl_expstatus @id
	--end 28174
END
IF @idtype = 'CAR'
BEGIN
	UPDATE	carrier
	SET	car_exp1_date = @exp1_date,
		car_exp1_enddate = @exp1_enddate,
		car_exp2_date = @exp2_date,
		car_exp2_enddate = @exp2_enddate
	WHERE	car_id = @id
	--JLB PTS 28174 need to run exp status procs to sync assets master file
	exec car_expstatus @id
	--end 28174
END
END
GO
GRANT EXECUTE ON  [dbo].[update_expiration] TO [public]
GO
