SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_stlmnt_queue_with_tpr_sp    Script Date: 2/11/98 11:12:16 AM ******/
CREATE PROCEDURE [dbo].[d_stlmnt_queue_with_tpr_sp] (
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
	@trl_id varchar(13),
	@car_id varchar(8),
	@acct_type char(1),
	@tpr_yes1 varchar(1),
	@tpr_yes2 varchar(1),
	@tpr_yes3 varchar(1),
	@tpr_yes4 varchar(1),
	@tpr_yes5 varchar(1),
	@tpr_yes6 varchar(1),
	@tpr_id  varchar(8),
	@tpr_yes varchar(3))
AS
/**
 * 
 * NAME:
 * dbo.d_stlmnt_queue_with_tpr_sp 
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
 * 11/06/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
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
	det_count smallint null,
        socsecfedtax varchar(10) null)

-- JET - 4/28/99 - PTS #5494, need to change value to 1 that is not in the database. It was
--	checking for a specific combination of types.  Need to see if tpr is in any of the
--	Y types.
IF @tpr_yes1 <> 'Y'
   SELECT @tpr_yes1 = 'X'
IF @tpr_yes2 <> 'Y'
   SELECT @tpr_yes2 = 'X'
IF @tpr_yes3 <> 'Y'
   SELECT @tpr_yes3 = 'X'
IF @tpr_yes4 <> 'Y'
   SELECT @tpr_yes4 = 'X'
IF @tpr_yes5 <> 'Y'
   SELECT @tpr_yes5 = 'X'
IF @tpr_yes6 <> 'Y'
   SELECT @tpr_yes6 = 'X'
-- JET - 4/28/99 - PTS #5494

IF @report_type = 'TRIAL'
BEGIN
     IF @drv_yes != 'XXX'
        INSERT INTO #temp_que 
             SELECT 0, 
                    'DRV', 
                    mp.mpp_id, 
                    -- JET - 5/11/99 - PTS #5681
                    'TRIAL', 
                    -- mp.mpp_status, 
                    '20491231', 
                    NULL,
                    NULL,
                    NULL,
                    NULL,
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
                      WHERE pd.asgn_id = mp.mpp_id AND 
                            pd.asgn_type = 'DRV' AND 
                            ((pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate) OR 
                             (pd.pyd_transdate BETWEEN @lopaydate AND @hipaydate AND 
                              pd.pyh_payperiod >= '20491231 00:00')) AND 
                            pd.pyh_number = 0), 
                    pt.pto_ssn 
               FROM manpowerprofile mp LEFT OUTER JOIN payto pt ON mp.mpp_payto = pt.pto_id
              WHERE @drv_id IN ('UNKNOWN', mp.mpp_id) AND 
                    @drvtype1 IN ('UNK', mp.mpp_type1) AND 
                    @drvtype2 IN ('UNK', mp.mpp_type2) AND 
                    @drvtype3 IN ('UNK', mp.mpp_type3) AND 
                    @drvtype4 IN ('UNK', mp.mpp_type4) AND 
                    @company IN ('UNK', mp.mpp_company) AND 
                    @fleet IN ('UNK', mp.mpp_fleet) AND 
                    @division IN ('UNK', mp.mpp_division) AND 
	 ( (@acct_type = 'X' AND mp.mpp_actg_type IN ('A', 'P')) OR (@acct_type = mp.mpp_actg_type) ) AND
                    @terminal IN ('UNK', mp.mpp_terminal) AND 
                    (mp.mpp_terminationdt > dateadd(day, -45, getdate()) OR
                     mp.mpp_status <> 'OUT')
     IF @trc_yes != 'XXX' 
        INSERT INTO #temp_que 
             SELECT 0, 
                    'TRC', 
                    tp.trc_number, 
                    -- JET - 5/11/99 - PTS #5681
                    'TRIAL', 
                    -- tp.trc_status, 
                    '20491231', 
                    NULL,
                    NULL,
                    NULL,
                    NULL,
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
                      WHERE pd.asgn_id = tp.trc_number AND 
                            pd.asgn_type = 'TRC' AND 
                            ((pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate) OR 
                             (pd.pyd_transdate BETWEEN @lopaydate AND @hipaydate AND 
                              pd.pyh_payperiod >= '20491231 00:00')) AND 
                            pd.pyh_number = 0), 
                    pt.pto_ssn 
               FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner = pt.pto_id
              WHERE @trc_id IN ('UNKNOWN', tp.trc_number) AND 
                    @trctype1 IN ('UNK', tp.trc_type1) AND 
                    @trctype2 IN ('UNK', tp.trc_type2) AND 
                    @trctype3 IN ('UNK', tp.trc_type3) AND 
                    @trctype4 IN ('UNK', tp.trc_type4) AND 
                    @company IN ('UNK', tp.trc_company) AND 
                    @fleet IN ('UNK', tp.trc_fleet) AND 
                    @division IN ('UNK', tp.trc_division) AND 
	 ( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
                    @terminal IN ('UNK', tp.trc_terminal) AND 
                    (tp.trc_retiredate > dateadd(day, -45, getdate()) OR 
                     tp.trc_status <> 'OUT')
     IF @car_yes != 'XXX'
        INSERT INTO #temp_que 
             SELECT 0, 
                    'CAR', 
                    cr.car_id,
                    -- JET - 5/11/99 - PTS #5681
                    'TRIAL', 
                    -- cr.car_status, 
                    '20491231', 
                    NULL,
                    NULL,
                    NULL,
                    NULL,
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
                      WHERE pd.asgn_id = cr.car_id AND 
                            pd.asgn_type = 'CAR' AND 
                            ((pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate) OR 
                             (pd.pyd_transdate BETWEEN @lopaydate AND @hipaydate AND 

                              pd.pyh_payperiod >= '20491231 00:00')) AND 
                            pd.pyh_number = 0), 
                    pt.pto_ssn 
               FROM carrier cr LEFT OUTER JOIN payto pt ON cr.pto_id = pt.pto_id
              WHERE @car_id IN ('UNKNOWN', cr.car_id) AND 
                    @cartype1 IN ('UNK', cr.car_type1) AND 
                    @cartype2 IN ('UNK', cr.car_type2) AND 
                    @cartype3 IN ('UNK', cr.car_type3) AND 
                    @cartype4 IN ('UNK', cr.car_type4) AND 
	 ( (@acct_type = 'X' AND cr.car_actg_type IN ('A', 'P')) OR (@acct_type = cr.car_actg_type) ) AND
                    cr.car_status <> 'OUT'

	--  LOR PTS# 5744  trailer settlements
     IF @trl_yes != 'XXX' 
        INSERT INTO #temp_que 
             SELECT 0, 
                    'TRL', 
                    tp.trl_number, 
                    -- JET - 5/11/99 - PTS #5681
                    'TRIAL', 
                    -- tp.trl_status, 
                    '20491231', 
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    tp.trl_owner, 
                    tp.trl_terminal, 
                    '', 
                    pt.pto_lastfirst, 
                    tp.trl_type1, 
                    tp.trl_type2, 
                    tp.trl_type3, 
                    tp.trl_type4, 
                    (SELECT COUNT (pd.pyd_number) 
                       FROM paydetail pd 
                      WHERE pd.asgn_id = tp.trl_number AND 
                            pd.asgn_type = 'TRL' AND 
                            ((pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate) OR 
                             (pd.pyd_transdate BETWEEN @lopaydate AND @hipaydate AND 
                              pd.pyh_payperiod >= '20491231 00:00')) AND 
                            pd.pyh_number = 0), 
                    pt.pto_ssn 
               FROM trailerprofile tp LEFT OUTER JOIN payto pt ON tp.trl_owner = pt.pto_id
              WHERE @trl_id IN ('UNKNOWN', tp.trl_id) AND 
                    @trltype1 IN ('UNK', tp.trl_type1) AND 
                    @trltype2 IN ('UNK', tp.trl_type2) AND 
                    @trltype3 IN ('UNK', tp.trl_type3) AND 
                    @trltype4 IN ('UNK', tp.trl_type4) AND 
                    @company IN ('UNK', tp.trl_company) AND 
                    @fleet IN ('UNK', tp.trl_fleet) AND 
                    @division IN ('UNK', tp.trl_division) AND 
	 	   ((@acct_type = 'X' AND tp.trl_actg_type IN ('A', 'P')) 
				OR (@acct_type = tp.trl_actg_type) ) AND
                    @terminal IN ('UNK', tp.trl_terminal) AND 
                    (tp.trl_retiredate > dateadd(day, -45, getdate()) OR 
                     tp.trl_status <> 'OUT')
	--LOR
/* mucho I/O, need to tune
     -- update the total compensation, total deductions, total reimbursements and net amount fields
     UPDATE #temp_que 
        SET totalcomp =  (SELECT SUM(pd.pyd_amount)
                           FROM paydetail pd 
                          WHERE pd.asgn_id = tq.asgn_id AND 
                                pd.asgn_type = tq.type AND 
                                pd.pyd_pretax = 'Y' AND 
                                pd.pyd_status <> 'HLD' AND 
                                ((pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate) OR 
                                 (pd.pyd_transdate BETWEEN @lopaydate AND @hipaydate AND 
                                  pd.pyh_payperiod >= '20491231 00:00')) AND 
                                pd.pyh_number = 0) ,
	    totaldeduct = (SELECT SUM(pd.pyd_amount)
                             FROM paydetail pd 
                            WHERE pd.asgn_id = tq.asgn_id AND 
                                  pd.asgn_type = tq.type AND 
                                  pd.pyd_pretax = 'N' AND 
                                  pd.pyd_minus = -1 AND 
                                  pd.pyd_status <> 'HLD' AND 
                                  ((pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate) OR 
                                   (pd.pyd_transdate BETWEEN @lopaydate AND @hipaydate AND 
                                    pd.pyh_payperiod >= '20491231 00:00')) AND 
                                  pd.pyh_number = 0), 
            totalreimbrs = (SELECT (pd.pyd_amount)
                              FROM paydetail pd 
                             WHERE pd.asgn_id = tq.asgn_id AND 
                                   pd.asgn_type = tq.type AND 
                                   pd.pyd_pretax = 'N' AND 
                                   pd.pyd_minus = 1 AND 
                                   pd.pyd_status <> 'HLD' AND 
                                   ((pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate) OR 
                                    (pd.pyd_transdate BETWEEN @lopaydate AND @hipaydate AND 
                                     pd.pyh_payperiod >= '20491231 00:00')) AND 
                                   pd.pyh_number = 0),
           total
       FROM #temp_que tq
*/

	IF @tpr_yes != 'XXX'
		INSERT INTO #temp_que
		SELECT 0,
			'TPR',
			tpr.tpr_id,
			'',
			'20491231',
			0,
			0,
			0,
			0,
			tpr.tpr_payto,
			'',
			tpr.tpr_name,
			pt.pto_lastfirst,
			'',
			'',
			'',
			'',
			(SELECT COUNT (pd.pyd_number)
				FROM paydetail pd
				WHERE pd.asgn_id = tpr.tpr_id and
				      pd.asgn_type = 'TPR' and	
                                      ((pd.pyh_payperiod between @lopaydate and @hipaydate) or 
                                       (pd.pyd_transdate between @lopaydate and @hipaydate and
                                        pd.pyh_payperiod >= '20491231 00:00')) and
                                      pd.pyh_number = 0), 
                        pt.pto_ssn 
		FROM thirdpartyprofile tpr LEFT OUTER JOIN payto pt ON tpr.tpr_payto = pt.pto_id
		WHERE 	(@company in ('UNK', tpr_revtype1)) AND
			(@terminal in ('UNK', tpr_revtype2)) AND
			((@tpr_id = tpr.tpr_id and @tpr_id not in ('UNKNOWN')) OR
			 (@tpr_id = 'UNKNOWN' and
                          (tpr_thirdpartytype1 = @tpr_yes1 OR 
                           tpr_thirdpartytype2 = @tpr_yes2 OR 
                           tpr_thirdpartytype3 = @tpr_yes3 OR 
                           tpr_thirdpartytype4 = @tpr_yes4 OR 
                           tpr_thirdpartytype5 = @tpr_yes5 OR 
                           tpr_thirdpartytype6 = @tpr_yes6)))
		AND  ( (@acct_type = 'X' AND tpr.tpr_actg_type IN ('A', 'P')) OR (@acct_type = tpr.tpr_actg_type) )
		AND tpr.tpr_active = 'Y'
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
                    (SELECT COUNT(pd.pyd_number) 
                       FROM paydetail pd 
                      WHERE pd.pyh_number = ph.pyh_pyhnumber), 
                    pt.pto_ssn 
               FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, 
                    manpowerprofile mp
              WHERE ph.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
                    ph.pyh_paystatus IN (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus) AND 
                    ph.asgn_type = 'DRV' AND 
                    @drv_id IN ('UNKNOWN', ph.asgn_id) AND 
                    ph.asgn_id = mp.mpp_id AND 
                    @drvtype1 IN ('UNK', mp.mpp_type1) AND 
                    @drvtype2 IN ('UNK', mp.mpp_type2) AND 
                    @drvtype3 IN ('UNK', mp.mpp_type3) AND 
                    @drvtype4 IN ('UNK', mp.mpp_type4) AND 
                    @company IN ('UNK', mp.mpp_company) AND 
                    @fleet IN ('UNK', mp.mpp_fleet) AND 
                    @division IN ('UNK', mp.mpp_division) AND 
	 ( (@acct_type = 'X' AND mp.mpp_actg_type IN ('A', 'P')) OR (@acct_type = mp.mpp_actg_type) ) AND
                    @terminal IN ('UNK', mp.mpp_terminal)
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
                    (SELECT COUNT(pd.pyd_number) 
                       FROM paydetail pd 
                      WHERE pd.pyh_number = ph.pyh_pyhnumber), 
                    pt.pto_ssn 
               FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, 
                    tractorprofile tp
              WHERE ph.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
                    ph.pyh_paystatus IN (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus) AND 
                    ph.asgn_type = 'TRC' AND 
                    @trc_id IN ('UNKNOWN', ph.asgn_id) AND 
                    ph.asgn_id = tp.trc_number AND 
                    @trctype1 IN ('UNK', tp.trc_type1) AND 
                    @trctype2 IN ('UNK', tp.trc_type2) AND 
                    @trctype3 IN ('UNK', tp.trc_type3) AND 
                    @trctype4 IN ('UNK', tp.trc_type4) AND 
                    @company IN ('UNK', tp.trc_company) AND 
                    @fleet IN ('UNK', tp.trc_fleet) AND 
                    @division IN ('UNK', tp.trc_division) AND 
	 ( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
                    @terminal IN ('UNK', tp.trc_terminal)
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
                    (SELECT COUNT(pd.pyd_number) 
                       FROM paydetail pd 
                      WHERE pd.pyh_number = ph.pyh_pyhnumber), 
                    pt.pto_ssn 
               FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, 
                    carrier cr
              WHERE ph.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
                    ph.pyh_paystatus IN (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus) AND 
                    ph.asgn_type = 'CAR' AND 
                    @car_id IN ('UNKNOWN', ph.asgn_id) AND 
                    ph.asgn_id = cr.car_id AND 
                    @cartype1 IN ('UNK', cr.car_type1) AND 
                    @cartype2 IN ('UNK', cr.car_type2) AND 
                    @cartype3 IN ('UNK', cr.car_type3) AND 
                    @cartype4 IN ('UNK', cr.car_type4) AND 
		    ( (@acct_type = 'X' AND cr.car_actg_type IN ('A', 'P')) OR (@acct_type = cr.car_actg_type) )

	IF @tpr_yes != 'XXX'
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
			'',
			'',
			'',
			'',
			(SELECT count(pd.pyd_number)
				FROM paydetail pd
				WHERE pd.pyh_number = ph.pyh_pyhnumber), 
                        pt.pto_ssn 
		FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id,
			 thirdpartyprofile tpr
		WHERE ph.pyh_payperiod between @lopaydate and @hipaydate
			AND ph.pyh_paystatus in (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus)
			AND ph.asgn_type = 'TPR'
			AND ph.asgn_id = tpr.tpr_id 
			AND (@company IN('UNK', tpr.tpr_revtype1))
			AND (@terminal IN('UNK', tpr.tpr_revtype2))
			AND ((@tpr_id = tpr.tpr_id and @tpr_id not in ('UNKNOWN')) OR
			 	(@tpr_id = 'UNKNOWN' and
				 (tpr_thirdpartytype1 = @tpr_yes1 OR 
                                  tpr_thirdpartytype2 = @tpr_yes2 OR 
                                  tpr_thirdpartytype3 = @tpr_yes3 OR 
                                  tpr_thirdpartytype4 = @tpr_yes4 OR 
                                  tpr_thirdpartytype5 = @tpr_yes5 OR 
                                  tpr_thirdpartytype6 = @tpr_yes6)))
				AND ( (@acct_type = 'X' AND tpr.tpr_actg_type IN ('A', 'P')) OR (@acct_type = tpr.tpr_actg_type) )
	--  LOR PTS# 5744  trailer settlements
     IF @trl_yes != 'XXX' 
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
                    tp.trl_terminal, 
                    '', 
                    pt.pto_lastfirst, 
                    tp.trl_type1, 
                    tp.trl_type2, 
                    tp.trl_type3, 
                    tp.trl_type4, 
                    (SELECT COUNT(pd.pyd_number) 
                       FROM paydetail pd 
                      WHERE pd.pyh_number = ph.pyh_pyhnumber), 
                    pt.pto_ssn 
               FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, 
                    trailerprofile tp
              WHERE ph.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
                    ph.pyh_paystatus IN (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus) AND 
                    ph.asgn_type = 'TRL' AND 
                    @trl_id IN ('UNKNOWN', ph.asgn_id) AND 
                    ph.asgn_id = tp.trl_number AND 
                    @trltype1 IN ('UNK', tp.trl_type1) AND 
                    @trltype2 IN ('UNK', tp.trl_type2) AND 
                    @trltype3 IN ('UNK', tp.trl_type3) AND 
                    @trltype4 IN ('UNK', tp.trl_type4) AND 
                    @company IN ('UNK', tp.trl_company) AND 
                    @fleet IN ('UNK', tp.trl_fleet) AND 
                    @division IN ('UNK', tp.trl_division) AND 
	 	   ((@acct_type = 'X' AND tp.trl_actg_type IN ('A', 'P')) OR 
					(@acct_type = tp.trl_actg_type) ) AND
                    @terminal IN ('UNK', tp.trl_terminal)
	--LOR
END

SELECT *
FROM #temp_que
WHERE det_count > 0

DROP TABLE #temp_que
GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_queue_with_tpr_sp] TO [public]
GO
