SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[days_athome_for_payperiod_sp] (@p_mpp_id VARCHAR(8), 
                                       		   @p_psd_id INTEGER,
											   @p_days_athome INTEGER OUTPUT)
AS
BEGIN
/**
 * 
 * NAME:
 * dbo.days_athome_for_payperiod_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns the days at home for payperiod
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_mpp_id, varchar(8), input
 *       This parameter indicates driver ID in which to gather info on
 * 002 - @p_psd_id, integer, input
 *       This parameter indicates payscheduledetail id in which to gather info on
 * 003 - @p_days_athome, integer, output
 *		 This is the number of days at home
 * 
 * REVISION HISTORY:
 * 10/24/2005.01 ? PTS29946 - Ron Eyink ? Original
 *
 **/


DECLARE	 @v_days_at_home         INTEGER,
         @v_min_date             DATETIME,
         @v_max_date             DATETIME,
         @v_cur_pay_date         DATETIME,
         @v_min_date_next        DATETIME,
         @v_psh_id               INTEGER,
		 @prev_min_day_id		 INTEGER,
		 @cur_min_day_id		 INTEGER,
		 @cur_start				 DATETIME,
		 @cur_end				 DATETIME,
		 @prev_start			 DATETIME,
		 @prev_end				 DATETIME,
		 @max_mhl_date			 DATETIME,
		 @v_min_mhl_datetime	 DATETIME,
		 @v_max_mhl_datetime	 DATETIME

	CREATE TABLE #days1 (
		days_id		INTEGER 	NOT NULL IDENTITY(1,1),
		start_day	DATETIME 	NOT NULL,
		end_day		DATETIME 	NOT NULL)
	
	--get info from the current schedule
	SELECT @v_psh_id = psh_id,
	       @v_cur_pay_date = psd_date
	  FROM payschedulesdetail
	 WHERE psd_id = @p_psd_id
	
	
	--get the start date of the pay period based on the method of calc'in per diem
	SELECT	@v_min_date = max(psd_date)
	  FROM	payschedulesdetail
	 WHERE	psh_id = @v_psh_id AND 
			psd_date < @v_cur_pay_date
	
	IF @v_min_date IS NULL
	BEGIN
		SELECT	@v_min_date_next = MIN(psd_date)
		  FROM	payschedulesdetail
		 WHERE	psh_id = @v_psh_id AND 
		   		psd_date > @v_cur_pay_date
	
		SELECT	@v_max_date = @v_cur_pay_date, @v_min_date = dateadd(dd,datediff(dd, @v_min_date_next, @v_cur_pay_date) + 1, @v_cur_pay_date)		
	END
	ELSE
	BEGIN
		SELECT @v_max_date = @v_cur_pay_date, @v_min_date = dateadd(dd,1,@v_min_date)
	END
	
	--get the number of days at home for the calc period
	-- SELECT	@v_days_at_home = ISNULL(SUM(DATEDIFF(dd, 
	-- 								   CASE WHEN mhl_start < @v_min_date THEN @v_min_date ELSE mhl_start END,
	-- 								   DATEADD(dd, 1, CASE WHEN mhl_end > @v_cur_pay_date THEN @v_cur_pay_date ELSE mhl_end END))), 0)
	--   FROM	manpowerhomelog
	--  WHERE	mpp_id = @p_mpp_id AND
	-- 		mhl_end > @v_min_date AND
	--		mhl_start < DATEADD(dd, 1, @v_cur_pay_date)
	
	SELECT	@v_min_mhl_datetime = MIN(mhl_start)
	  FROM	manpowerhomelog
	 WHERE	mpp_id = @p_mpp_id AND
			mhl_end >= @v_min_date AND
			mhl_start <= @v_cur_pay_date
	
	SELECT	@v_max_mhl_datetime = MAX(mhl_end)
	  FROM	manpowerhomelog
	 WHERE	mpp_id = @p_mpp_id AND
			mhl_end >= @v_min_date AND
			mhl_start < DATEADD(dd, 1, @v_cur_pay_date)

	INSERT INTO #days1
		(start_day, end_day)
	SELECT	CASE WHEN mhl_start < @v_min_date THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), @v_min_date, 112)) ELSE CONVERT(DATETIME, CONVERT(VARCHAR(8), mhl_start, 112)) END,
			CASE WHEN mhl_end > @v_cur_pay_date THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), @v_cur_pay_date, 112)) ELSE CONVERT(DATETIME, CONVERT(VARCHAR(8), mhl_end, 112)) END
	  FROM	manpowerhomelog
	 WHERE	mpp_id = @p_mpp_id AND
			CONVERT(DATETIME, CONVERT(VARCHAR(8), mhl_end, 112)) >= CONVERT(DATETIME, CONVERT(VARCHAR(8), @v_min_date, 112)) AND
			CONVERT(DATETIME, CONVERT(VARCHAR(8), mhl_start, 112)) <= CONVERT(DATETIME, CONVERT(VARCHAR(8), @v_cur_pay_date, 112))
	ORDER BY mhl_start 
	
	IF (SELECT COUNT(*) FROM #days1) > 0 
	BEGIN
		SELECT	@max_mhl_date = MAX(end_day) FROM #days1
	END
	ELSE
	BEGIN
		SELECT @max_mhl_date = @v_min_date
	END
	
	IF EXISTS(SELECT	* 
				FROM	checkcall
			   WHERE	ckc_asgntype = 'DRV' AND 
						ckc_asgnid = @p_mpp_id AND 
						ckc_date > ISNULL(@v_max_mhl_datetime, @v_min_date) AND
						ckc_date < DATEADD(dd, 1, @v_cur_pay_date) AND 
						ISNULL(ckc_home, 'N') = 'Y')
	BEGIN
		SELECT	@cur_start = MIN(ckc_date)
		  FROM	checkcall
		 WHERE	ckc_asgntype = 'DRV' AND 
				ckc_asgnid = @p_mpp_id AND 
				ckc_date > ISNULL(@v_max_mhl_datetime, @v_min_date) AND
				ISNULL(ckc_home, 'N') = 'Y'

		SELECT	@cur_start = MIN(ckc_date)
		  FROM	checkcall
		 WHERE	ckc_asgntype = 'DRV' AND 
				ckc_asgnid = @p_mpp_id AND
				ISNULL(ckc_home, 'N') = 'Y' AND
				ckc_date > (SELECT	MAX(ckc_date)
							  FROM	checkcall
							 WHERE	ckc_asgntype = 'DRV' AND 
									ckc_asgnid = @p_mpp_id AND
									ISNULL(ckc_home, 'N') = 'N' AND
									ckc_date < @cur_start)

		SELECT	@cur_end = MAX(ckc_date)
		  FROM	checkcall
		 WHERE	ckc_asgntype = 'DRV' AND
				ckc_asgnid = @p_mpp_id AND 
				ISNULL(ckc_home, 'N') = 'Y' and
				ckc_date < (SELECT	MIN(ckc_date) 
							  FROM	checkcall 
							 WHERE	ckc_asgntype = 'DRV' AND
									ckc_asgnid = @p_mpp_id AND 
									ISNULL(ckc_home, 'N') = 'N' and
									ckc_date > @cur_start)

		SELECT @cur_start = ISNULL(@cur_start, '19500101'), @cur_end = ISNULL(@cur_end, '20491231')

		SELECT	@cur_start = CASE WHEN @cur_start < @v_min_date THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), @v_min_date, 112)) ELSE CONVERT(DATETIME, CONVERT(VARCHAR(8), @cur_start, 112)) END,
				@cur_end = CASE WHEN @cur_end > @v_cur_pay_date THEN CONVERT(DATETIME, CONVERT(VARCHAR(8), @v_cur_pay_date, 112)) ELSE CONVERT(DATETIME, CONVERT(VARCHAR(8), @cur_end, 112)) END

		INSERT INTO #days1
			(start_day, end_day)
		VALUES
			(@cur_start, @cur_end)
	END
	
	SELECT	@prev_min_day_id = MIN(days_id)
	  FROM	#days1
	
	SELECT 	@prev_start = start_day,
			@prev_end = end_day
	  FROM	#days1
	 WHERE	days_id = @prev_min_day_id
	
	SELECT	@cur_min_day_id = MIN(days_id)
	  FROM	#days1
	 WHERE	days_id > @prev_min_day_id
	
	WHILE ISNULL(@cur_min_day_id, -1) > -1
	BEGIN
		SELECT 	@cur_start = start_day,
				@cur_end = end_day
		  FROM	#days1
		 WHERE	days_id = @cur_min_day_id
	
		IF @prev_end = @cur_start	
		BEGIN
			UPDATE	#days1
			   SET	end_day = @cur_end
			 WHERE	days_id = @prev_min_day_id
	
			DELETE	#days1
			 WHERE	days_id = @cur_min_day_id
	
			SELECT @prev_end = @cur_end
		END
		ELSE
		BEGIN
			SELECT 	@prev_start = @cur_start, @prev_end = @cur_end, @prev_min_day_id = @cur_min_day_id
		END
		
		SELECT	@cur_min_day_id = MIN(days_id)
		  FROM	#days1
		 WHERE	days_id > @prev_min_day_id
	END
	
	SELECT	@v_days_at_home = ISNULL(SUM(DATEDIFF(dd, start_day, DATEADD(dd, 1, end_day))), 0)
	  FROM	#days1
	
	SELECT	@p_days_athome = @v_days_at_home
END	
GO
GRANT EXECUTE ON  [dbo].[days_athome_for_payperiod_sp] TO [public]
GO
