SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.c_call_report    Script Date: 8/20/97 1:57:10 PM ******/
CREATE PROC [dbo].[c_call_report] @owner char(8) AS
DECLARE @trc varchar (8),
	@trc_end varchar (8),
	@date datetime,
	@lgh int, 
	@code int,
	@compdate datetime

-- PTS 3436 PG 1/8/98 Performance Enhancement added NOLOCK on expiration

SELECT @compdate = DATEADD ( MINUTE, 30, GETDATE () )

SELECT trc_number, 
	trc_terminal, 
	trc_status,
	driver_id = trc_driver, 
	driver_name = mpp1.mpp_lastfirst,
	codriver_id = trc_driver2,
	codriver_name = mpp2.mpp_lastfirst,	
	c1.cty_nmstct,
	trc_avl_date,
	ckc_date = convert ( datetime, null ),
	ckc_cityname = convert ( varchar (24), '' ),
	ckc_comment = convert ( varchar (254), '' ),
	eta = convert ( datetime, null ),
	available = convert ( datetime, null ),
	mpp1.mpp_type1,
	mpp1.mpp_type2,
	mpp1.mpp_type3,
	mpp1.mpp_type4
INTO #t1
FROM tractorprofile, 
	manpowerprofile mpp1, 
	manpowerprofile mpp2,
	city c1
WHERE trc_avl_city = c1.cty_code AND
	trc_number <> 'UNKNOWN' AND
	mpp1.mpp_id = trc_driver and
	mpp2.mpp_id = trc_driver2 and
	trc_status <> 'OUT' AND
	( @owner = '*' OR @owner = trc_owner )

SELECT @trc = '' 

-- load last tractor
SELECT @trc_end = Max(trc_number)
FROM tractorprofile
WHERE trc_number <> 'UNKNOWN' AND
	trc_status <> 'OUT' AND
	( trc_owner = @owner or @owner = '*' )

WHILE @trc <> @trc_end
BEGIN
		SELECT @trc = MIN(trc_number)
		FROM tractorprofile
		WHERE trc_number <> 'UNKNOWN' AND
			trc_status <> 'OUT' AND
			( trc_owner = @owner or @owner = '*' ) AND
			trc_number > @trc

	SELECT @date = null
	SELECT @date = MAX ( ckc_date )
	FROM checkcall 
	WHERE ckc_tractor = @trc AND
		ckc_updatedby <> 'MOBCOMM'
	IF @date IS NOT null 
		UPDATE #t1
		SET #t1.ckc_date = @date,
			ckc_cityname = city.cty_nmstct,
			#t1.ckc_comment = checkcall.ckc_comment
		FROM city, checkcall
		WHERE city.cty_code = checkcall.ckc_city AND
			checkcall.ckc_date = @date AND
			ckc_tractor = @trc AND
			#t1.trc_number = @trc

	SELECT @date = null
NO_LOCK1:
	SELECT @date = MAX ( exp_compldate )
	FROM expiration (NOLOCK), #t1
	WHERE exp_idtype = 'TRC' AND
		exp_id = @trc AND
		exp_expirationdate <= @compdate AND
		exp_compldate >= @compdate AND
		#t1.trc_number = exp_id AND
		exp_completed = 'N'
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) GOTO NO_LOCK1

	UPDATE #t1
	SET available = @date
	WHERE #t1.trc_number = @trc

	IF @date IS NOT null
	BEGIN
NO_LOCK2:
		UPDATE #t1
		SET trc_status = l2.abbr
		FROM labelfile l1, labelfile l2, expiration (NOLOCK)
		WHERE l1.abbr = exp_code AND
			l1.code = l2.code AND
			l1.labeldefinition = 'TrcExp' AND
			l2.labeldefinition = 'TrcStatus' AND
			exp_idtype = 'TRC' AND
			exp_id = @trc AND
			exp_expirationdate <= @compdate AND
			exp_compldate >= @compdate AND
			#t1.trc_number = exp_id AND
			#t1.trc_status = 'AVL' AND
			exp_completed = 'N'
		IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
			GOTO NO_LOCK2			
	END

	EXEC cur_activity 'TRC', @trc, @lgh OUT
	IF @lgh > 0
		UPDATE #t1
		SET eta = lgh_enddate
		FROM legheader
		WHERE lgh_number = @lgh AND
		#t1.trc_number = @trc

END

SELECT * from #t1
GO
GRANT EXECUTE ON  [dbo].[c_call_report] TO [public]
GO
