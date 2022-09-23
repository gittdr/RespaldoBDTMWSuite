SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[perdiem_calc_info_sp] (@p_mpp_id VARCHAR(8), 
                                       @p_psd_id INTEGER)
AS
BEGIN
/**
 * 
 * NAME:
 * dbo.perdiem_calc_info_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure gathers information for Per Diem pay
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_mpp_id, varchar(8), input
 *       This parameter indicates driver ID in which to gather info on
 * 002 - @p_psd_id, integer, input
 *       This parameter indicates payscheduledetail id in which to gather info on
 *
 * 
 * REVISION HISTORY:
 * 10/10/2005.01 ? PTS29946 - Jason Bauwin ? Original
 *
 **/


DECLARE	@v_perdiem_paytype      VARCHAR(8),
         @v_perdiem_calc_period  VARCHAR(9),
         @v_perdiem_daily_limit  MONEY,
         @v_perdiem_period_pay   MONEY,
         @v_days_at_home         INTEGER,
         @v_min_date             DATETIME,
         @v_max_date             DATETIME,
         @v_cur_pay_date         DATETIME,
         @v_min_date_next        DATETIME,
         @v_perdiem_calc_method  VARCHAR(8),
         @v_psh_id               INTEGER,
         @v_curr_month           INTEGER,
         @v_curr_year            INTEGER,
         @v_days_in_calc_period  INTEGER,
         @v_number_calc_days     INTEGER,
		 @v_perdiem_exceeded	 CHAR(1),
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

SELECT	@v_perdiem_paytype = LEFT(ISNULL(gi_string1, 'UNKNOWN'), 8)
  FROM	generalinfo
 WHERE	gi_name = 'PerDiemPayType'

SELECT	@v_perdiem_calc_period = UPPER(LEFT(ISNULL(gi_string1, 'MONTHLY'), 9)),
         @v_perdiem_calc_method = UPPER(LEFT(ISNULL(gi_string2, 'FIXED'), 8)),
         @v_number_calc_days = abs(ISNULL(gi_integer1, 30))
  FROM	generalinfo
 WHERE	gi_name = 'PerDiemCalcPeriod'

IF isnull(@v_perdiem_calc_period,'XXX') NOT IN ('MONTHLY', 'PAYPERIOD') 
BEGIN
	SELECT @v_perdiem_calc_period = 'MONTHLY',  @v_perdiem_calc_method = 'FIXED', @v_number_calc_days = 30
END

/*debugs*/
--SELECT @v_perdiem_calc_period = 'PAYPERIOD', @v_perdiem_calc_method = 'FIXED', @v_number_calc_days = 30 
--SELECT @v_perdiem_calc_period = 'PAYPERIOD', @v_perdiem_calc_method = 'VARIABLE', @v_number_calc_days = 30 
--SELECT @v_perdiem_calc_period = 'MONTHLY', @v_perdiem_calc_method = 'FIXED', @v_number_calc_days = 30
--SELECT @v_perdiem_calc_period = 'MONTHLY', @v_perdiem_calc_method = 'FIXED', @v_number_calc_days = 31
--SELECT @v_perdiem_calc_period = 'MONTHLY', @v_perdiem_calc_method = 'VARIABLE', @v_number_calc_days = 30
/* end of debugs */

--get info from the current schedule
SELECT @v_psh_id = psh_id,
       @v_cur_pay_date = psd_date,
       @v_curr_month = psd_applicable_month,
       @v_curr_year = psd_applicable_year
  FROM payschedulesdetail
 WHERE psd_id = @p_psd_id


--get the start date of the pay period based on the method of calc'in per diem
IF @v_perdiem_calc_period = 'PAYPERIOD'
BEGIN
   SELECT @v_min_date = max(psd_date)
   FROM payschedulesdetail
  WHERE psh_id = @v_psh_id
    AND psd_date < @v_cur_pay_date

	IF @v_min_date IS NULL
	BEGIN
		SELECT @v_min_date_next = MIN(psd_date)
		  FROM payschedulesdetail
		 WHERE psh_id = @v_psh_id
		   AND psd_date > @v_cur_pay_date

		SELECT @v_max_date = @v_cur_pay_date, @v_min_date = dateadd(dd,datediff(dd, @v_min_date_next, @v_cur_pay_date) + 1, @v_cur_pay_date)		
	END
	ELSE
	BEGIN
		SELECT @v_max_date = @v_cur_pay_date, @v_min_date = dateadd(dd,1,@v_min_date)
	END
END

--it's 'monthly' based on applicable month of the pay schedule
ELSE IF @v_perdiem_calc_period = 'MONTHLY'
BEGIN
	SELECT @v_max_date = MAX(psd_date)
	  FROM payschedulesdetail
	 WHERE psh_id = @v_psh_id
	   AND psd_applicable_month = @v_curr_month
	   AND psd_applicable_year = @v_curr_year

   --find the first date of the applicable pay month 
   --by finding the day after the payperiod of the last schedule that does not apply to this month
   SELECT @v_min_date = max(psd_date)
     FROM payschedulesdetail
    WHERE psd_date < (SELECT min(psd_date)
                        FROM payschedulesdetail
                       WHERE psh_id = @v_psh_id
                         AND psd_applicable_month = @v_curr_month
                         AND psd_applicable_year = @v_curr_year)
     AND psh_id = @v_psh_id

	IF @v_min_date IS NULL
	BEGIN
	  --nothing found so just take the period before
	   SELECT @v_min_date_next = min(psd_date)
	     FROM payschedulesdetail
	    WHERE psd_date > (SELECT max(psd_date)
	                        FROM payschedulesdetail
	                       WHERE psh_id = @v_psh_id
	                         AND psd_applicable_month = @v_curr_month
	                         AND psd_applicable_year = @v_curr_year)
	     AND psh_id = @v_psh_id   
	
	  SELECT @v_min_date = min(psd_date)
	    FROM payschedulesdetail
	   WHERE psh_id = @v_psh_id
	     AND psd_applicable_month = @v_curr_month
	     AND psd_applicable_year = @v_curr_year
	
	   SELECT @v_min_date = dateadd(dd,datediff(dd, @v_min_date_next, @v_max_date) + 1,@v_min_date)
	END
	ELSE
	BEGIN
	   SELECT  @v_min_date = dateadd(dd,1,@v_min_date)
	END
END
--Now that the start period has been computed based on settings
--get the number of days to be considered in the per diem calcs
IF @v_perdiem_calc_period = 'MONTHLY' AND  @v_perdiem_calc_method = 'FIXED'
BEGIN
   SELECT @v_days_in_calc_period = @v_number_calc_days
END 
ELSE
BEGIN   
   SELECT @v_days_in_calc_period = datediff(dd, @v_min_date, @v_max_date) + 1
END

--get the Per Diem Daily Rate effective during the payperiod (must be applicable before or on the first date of the calc
SELECT @v_perdiem_daily_limit = pdl_daily_limit
  FROM perdiem_daily_limit
 WHERE pdl_eff_date = (SELECT max(pdl_eff_date)
                         FROM perdiem_daily_limit
                        WHERE pdl_eff_date <= @v_min_date)

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

--get the amount of pay this period for per diem pay
IF @v_perdiem_calc_period = 'PAYPERIOD'
BEGIN
   SELECT @v_perdiem_period_pay = 0.00
END
ELSE
BEGIN
   SELECT @v_perdiem_period_pay = isnull(sum(isnull(paydetail.pyd_amount, 0.00)), 0.00)
     FROM paydetail
    WHERE paydetail.asgn_type = 'DRV'
      AND paydetail.asgn_id = @p_mpp_id
      AND paydetail.pyt_itemcode = @v_perdiem_paytype
      AND paydetail.pyh_payperiod >= @v_min_date
      AND paydetail.pyh_payperiod <= @v_max_date
	  AND paydetail.pyh_payperiod <> @v_cur_pay_date
END

SELECT @v_perdiem_exceeded = MAX(ISNULL(pyd_perdiem_exceeded, 'N'))
 FROM paydetail
WHERE paydetail.asgn_type = 'DRV'
  AND paydetail.asgn_id = @p_mpp_id
  AND paydetail.pyh_payperiod >= @v_min_date
  AND paydetail.pyh_payperiod <= @v_cur_pay_date

SELECT @v_perdiem_exceeded = ISNULL(@v_perdiem_exceeded, 'N')

IF (select count(*) from manpowerprofile_perdiem_history where mpp_id = @p_mpp_id) > 0
BEGIN
      SELECT @v_perdiem_calc_period as 'Calc Method',  
             CASE @v_perdiem_calc_period WHEN 'PAYPERIOD' THEN 'N/A' ELSE @v_perdiem_calc_method END 'Monthly Method',
             @v_days_at_home 'Days At Home',
             @v_min_date 'Calc Period Begins On', 
             @v_max_date 'Calc Period Ends On', 
             @v_days_in_calc_period '# Days In Period', 
             @v_perdiem_daily_limit 'Daily Limit',
             @v_perdiem_period_pay 'Per Diem Pay This Calc Period',
             mph1.mpp_id,
             mph1.mpp_perdiem_flag,
             mph1.mpp_perdiem_eff_date,
			 @v_perdiem_exceeded 'pyd_perdiem_exceeded'
        FROM manpowerprofile_perdiem_history mph1
       WHERE mph1.mpp_id = @p_mpp_id AND
			 mph1.mph_id = (SELECT MAX(mph2.mph_id) 
							  FROM manpowerprofile_perdiem_history mph2 
							 WHERE mph2.mpp_id = @p_mpp_id AND 
								   mph2.mpp_perdiem_eff_date = mph1.mpp_perdiem_eff_date)
END
ELSE
BEGIN
   SELECT @v_perdiem_calc_period as 'Calc Method',  
          CASE @v_perdiem_calc_period WHEN 'PAYPERIOD' THEN 'N/A' ELSE @v_perdiem_calc_method END 'Monthly Method',
          @v_days_at_home 'Days At Home',
          @v_min_date 'Calc Period Begins On', 
          @v_max_date 'Calc Period Ends On', 
          @v_days_in_calc_period '# Days In Period', 
          @v_perdiem_daily_limit 'Daily Limit',
          @v_perdiem_period_pay 'Per Diem Pay This Calc Period',
          @p_mpp_id AS mpp_id,
          'N' AS mpp_perdiem_flag,
          CAST('19500101' AS datetime) as mpp_perdiem_eff_date,
		  @v_perdiem_exceeded 'pyd_perdiem_exceeded'
END

END
GO
GRANT EXECUTE ON  [dbo].[perdiem_calc_info_sp] TO [public]
GO
