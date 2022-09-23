SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_stlmnt_queue_sp] (
	@report_type varchar(5),
	@drv_yes varchar(3),
	@trc_yes varchar(3),
	@trl_yes varchar(3),
	@car_yes varchar(3),
	@hldstatus varchar(3),
	@pndstatus varchar(3),
	@colstatus varchar(3),
	@relstatus varchar(3),
	@prnstatus varchar(3),
	@xfrstatus varchar(3),
	@lopaydate datetime,
	@hipaydate datetime,
	@company varchar(6),
	@fleet varchar(6),
	@division varchar(6),
	@terminal varchar(6),
	@drvtype1 varchar(6),
	@drvtype2 varchar(6),
	@drvtype3 varchar(6),
	@drvtype4 varchar(6),
	@trctype1 varchar(6),
	@trctype2 varchar(6),
	@trctype3 varchar(6),
	@trctype4 varchar(6),
	@trltype1 varchar(6),
	@trltype2 varchar(6),
	@trltype3 varchar(6),
	@trltype4 varchar(6),
	@cartype1 varchar(6),
	@cartype2 varchar(6),
	@cartype3 varchar(6),
	@cartype4 varchar(6),
	@drv_id varchar(8),
	@trc_id varchar(8),
	@trl_id varchar(8),
	@car_id varchar(8),
	@acct_type char(1))
AS
/**
 * 
 * NAME:
 * dbo.d_stlmnt_queue_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 * 11/26/2007.01 ? PTS40189 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/


CREATE TABLE #temp_que (
	pyhnumber int null,
	type varchar(3) not null,
	asgn_id varchar(8) not null,
	status varchar(6) null,
	payperiod datetime null,
	totalcomp money null,
	totaldeduct money null,
	totalreimbrs money null,
	totalpay money null,
	payto varchar(12) null,
	terminal varchar(8) null,
	driver varchar(45) null,
	payto_lastfirst varchar(45) null,
	type1 varchar(6) null,
	type2 varchar(6) null,
	type3 varchar(6) null,
	type4 varchar(6) null,
	det_count smallint null)

IF @report_type = 'TRIAL'
	BEGIN

	IF @drv_yes != 'XXX'

		INSERT INTO #temp_que
		SELECT 0,
			'DRV',
			mp.mpp_id,
			mp.mpp_status,
			'20491231',
			0,
			0,
			0,
			0,
			mp.mpp_payto,
			mp.mpp_terminal,
			mp.mpp_lastfirst,
			pt.pto_lastfirst,
			mp.mpp_type1,
			mp.mpp_type2,
			mp.mpp_type3,
			mp.mpp_type4, 
			(SELECT COUNT (pd.pyd_number)
				FROM paydetail pd
				WHERE pd.asgn_id = mp.mpp_id)
		FROM manpowerprofile mp LEFT OUTER JOIN payto pt ON mp.mpp_payto = pt.pto_id  --pts40189 outer join conversion
		WHERE @drv_id in ('UNKNOWN', mp.mpp_id)		
		AND @drvtype1 in ('UNK', mp.mpp_type1)
		AND @drvtype2 in ('UNK', mp.mpp_type2)
		AND @drvtype3 in ('UNK', mp.mpp_type3)
		AND @drvtype4 in ('UNK', mp.mpp_type4)
		AND @company in ('UNK', mp.mpp_company)
		AND @fleet in ('UNK', mp.mpp_fleet)
		AND @division in ('UNK', mp.mpp_division)
		AND @acct_type in ('X', mp.mpp_actg_type)
		AND @terminal in ('UNK', mp.mpp_terminal)
 		AND (mp.mpp_terminationdt > dateadd(day, -45, getdate())
		OR mp.mpp_status <> 'OUT')

	IF @trc_yes != 'XXX'

		INSERT INTO #temp_que
		SELECT 0,
			'TRC',
			tp.trc_number,
			tp.trc_status,
			'20491231',
			0,
			0,
			0,
			0,
			tp.trc_owner,
			tp.trc_terminal,
			'',
			pt.pto_lastfirst,
			tp.trc_type1,
			tp.trc_type2,
			tp.trc_type3,
			tp.trc_type4,
			(SELECT COUNT (pd.pyd_number)
				FROM paydetail pd
				WHERE pd.asgn_id = tp.trc_number)
		FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner = pt.pto_id  --pts40189 outer join conversion
		WHERE @trc_id in ('UNKNOWN', tp.trc_number)		
		AND @trctype1 in ('UNK', tp.trc_type1)
		AND @trctype2 in ('UNK', tp.trc_type2)
		AND @trctype3 in ('UNK', tp.trc_type3)
		AND @trctype4 in ('UNK', tp.trc_type4)
		AND @company in ('UNK', tp.trc_company)
		AND @fleet in ('UNK', tp.trc_fleet)
		AND @division in ('UNK', tp.trc_division)
		AND @acct_type in ('X', tp.trc_actg_type)
		AND @terminal in ('UNK', tp.trc_terminal)
		AND (tp.trc_retiredate > dateadd(day, -45, getdate())
		OR tp.trc_status <> 'OUT')
 
	IF @car_yes != 'XXX'

		INSERT INTO #temp_que
		SELECT 0,
			'CAR',
			cr.car_id,
			cr.car_status,
			'20491231',
			0,
			0,
			0,
			0,
			cr.pto_id,
			'',
			cr.car_name,
			pt.pto_lastfirst,
			cr.car_type1,
			cr.car_type2,
			cr.car_type3,
			cr.car_type4,
			(SELECT COUNT (pd.pyd_number)
				FROM paydetail pd
				WHERE pd.asgn_id = cr.car_id)
		FROM carrier cr LEFT OUTER JOIN payto pt ON cr.pto_id = pt.pto_id  --pts40189 outer join conversion
		WHERE @car_id in ('UNKNOWN', cr.car_id)
		AND @cartype1 in ('UNK', cr.car_type1)
		AND @cartype2 in ('UNK', cr.car_type2)
		AND @cartype3 in ('UNK', cr.car_type3)
		AND @cartype4 in ('UNK', cr.car_type4)
		AND @acct_type in ('X', cr.car_actg_type)
		AND cr.car_status <> 'OUT'

	END

IF @report_type = 'FINAL'
	BEGIN

	IF @drv_yes != 'XXX'

		INSERT INTO #temp_que
		SELECT DISTINCT ph.pyh_pyhnumber,
			ph.asgn_type,
			ph.asgn_id,
			ph.pyh_paystatus,
			ph.pyh_payperiod,
 			ph.pyh_totalcomp,
			ph.pyh_totaldeduct,
			ph.pyh_totalreimbrs,
 			ph.pyh_totalcomp + ph.pyh_totaldeduct + ph.pyh_totalreimbrs,
			ph.pyh_payto,
			mp.mpp_terminal,
			mp.mpp_lastfirst,
			pt.pto_lastfirst,
			mp.mpp_type1,
			mp.mpp_type2,
			mp.mpp_type3,
			mp.mpp_type4,
			(SELECT count(pd.pyd_number)
				FROM paydetail pd
				WHERE pd.pyh_number = ph.pyh_pyhnumber)
 		FROM payheader ph  LEFT OUTER JOIN  manpowerprofile mp  ON  (
				    ph.asgn_id  = mp.mpp_id   
				AND @drvtype1 in ('UNK', mp.mpp_type1)
				AND @drvtype2 in ('UNK', mp.mpp_type2)
				AND @drvtype3 in ('UNK', mp.mpp_type3)
				AND @drvtype4 in ('UNK', mp.mpp_type4)
				AND @company in ('UNK', mp.mpp_company)  
				AND @fleet in ('UNK', mp.mpp_fleet)
				AND @division in ('UNK', mp.mpp_division)
				AND @acct_type in ('X', mp.mpp_actg_type)
				AND @terminal in ('UNK', mp.mpp_terminal) )
			LEFT OUTER JOIN  payto pt  ON  ph.pyh_payto  = pt.pto_id  
 		WHERE ph.pyh_payperiod between @lopaydate and @hipaydate
		AND ph.pyh_paystatus in (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus)
		AND ph.asgn_type = 'DRV'
 		AND @drv_id in ('UNKNOWN', ph.asgn_id)
/*  pts 40189 outer join conversion
			(SELECT count(pd.pyd_number)
				FROM paydetail pd
				WHERE pd.pyh_number =* ph.pyh_pyhnumber)
 		FROM payheader ph, manpowerprofile mp, payto pt
 		WHERE ph.pyh_payperiod between @lopaydate and @hipaydate
		AND ph.pyh_paystatus in (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus)
		AND ph.asgn_type = 'DRV'
 		AND @drv_id in ('UNKNOWN', ph.asgn_id)
		AND ph.asgn_id *= mp.mpp_id
		AND ph.pyh_payto *= pt.pto_id
		AND @drvtype1 in ('UNK', mp.mpp_type1)
		AND @drvtype2 in ('UNK', mp.mpp_type2)
		AND @drvtype3 in ('UNK', mp.mpp_type3)
		AND @drvtype4 in ('UNK', mp.mpp_type4)
		AND @company in ('UNK', mp.mpp_company)
		AND @fleet in ('UNK', mp.mpp_fleet)
		AND @division in ('UNK', mp.mpp_division)
		AND @acct_type in ('X', mp.mpp_actg_type)
		AND @terminal in ('UNK', mp.mpp_terminal)
*/

	IF @trc_yes != 'XXX'

		INSERT INTO #temp_que
		SELECT DISTINCT ph.pyh_pyhnumber,
			ph.asgn_type,
			ph.asgn_id,
			ph.pyh_paystatus,
			ph.pyh_payperiod,
			ph.pyh_totalcomp,
			ph.pyh_totaldeduct,
			ph.pyh_totalreimbrs,
			ph.pyh_totalcomp + ph.pyh_totaldeduct + ph.pyh_totalreimbrs,
			ph.pyh_payto,
			tp.trc_terminal,
			'',
			pt.pto_lastfirst,
			tp.trc_type1,
			tp.trc_type2,
			tp.trc_type3,
			tp.trc_type4,
			(SELECT count(pd.pyd_number)
				FROM paydetail pd
				WHERE pd.pyh_number = ph.pyh_pyhnumber)  --PTS40189 removed the right outer join from the correlated query 
		FROM payheader ph left outer join payto pt on ph.pyh_payto = pt.pto_id, --PTS40189 OUTER JOIN CONVERSION
			 tractorprofile tp
		WHERE ph.pyh_payperiod between @lopaydate and @hipaydate
		AND ph.pyh_paystatus in (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus)
		AND ph.asgn_type = 'TRC'
		AND @trc_id in ('UNKNOWN', ph.asgn_id)
		AND ph.asgn_id = tp.trc_number
		AND @trctype1 in ('UNK', tp.trc_type1)
		AND @trctype2 in ('UNK', tp.trc_type2)
		AND @trctype3 in ('UNK', tp.trc_type3)
		AND @trctype4 in ('UNK', tp.trc_type4)
		AND @company in ('UNK', tp.trc_company)
		AND @fleet in ('UNK', tp.trc_fleet)
		AND @division in ('UNK', tp.trc_division)
		AND @acct_type in ('X', tp.trc_actg_type)
		AND @terminal in ('UNK', tp.trc_terminal)

	IF @car_yes != 'XXX'

		INSERT INTO #temp_que
		SELECT DISTINCT ph.pyh_pyhnumber,
			ph.asgn_type,
			ph.asgn_id,
			ph.pyh_paystatus,
			ph.pyh_payperiod,
			ph.pyh_totalcomp,
			ph.pyh_totaldeduct,
			ph.pyh_totalreimbrs,
			ph.pyh_totalcomp + ph.pyh_totaldeduct + ph.pyh_totalreimbrs,
			ph.pyh_payto,
			'',
			'',
			pt.pto_lastfirst,
			cr.car_type1,
			cr.car_type2,
			cr.car_type3,
			cr.car_type4,
			(SELECT count(pd.pyd_number)
				FROM paydetail pd
				WHERE pd.pyh_number = ph.pyh_pyhnumber)  --PTS40189 removed the right outer join from the correlated query
		FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, --pts40189 outer join conversion
			 carrier cr 
		WHERE ph.pyh_payperiod between @lopaydate and @hipaydate
		AND ph.pyh_paystatus in (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus)
		AND ph.asgn_type = 'CAR'
		AND @car_id in ('UNKNOWN', ph.asgn_id)
		AND ph.asgn_id = cr.car_id
		AND @cartype1 in ('UNK', cr.car_type1)
		AND @cartype2 in ('UNK', cr.car_type2)
		AND @cartype3 in ('UNK', cr.car_type3)
		AND @cartype4 in ('UNK', cr.car_type4)
		AND @acct_type in ('X', cr.car_actg_type)

	END

SELECT *
FROM #temp_que
WHERE det_count > 0

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_queue_sp] TO [public]
GO
