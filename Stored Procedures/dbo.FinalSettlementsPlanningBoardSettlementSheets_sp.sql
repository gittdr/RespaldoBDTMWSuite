SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[FinalSettlementsPlanningBoardSettlementSheets_sp] (
	@PayScheduleList	varchar(4000),
	@DateList			varchar(4000),
	@report_type		int,
	@hldstatus			int
)
AS

/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 * 001 - @PayScheduleList	varchar(4000)	comma separated list of payScheduleIds, paired with @datelist
 * 002 - @DateList			varchar(4000)	comma separated list of pay period dates, paired with @PayScheduleList
 * 003 - @report_type		int				0 for trial released, 1 for trial collected and 2 for final
 * 004 - @hldstatus			int				0 for dont include on hold, 1 for do

 *
 * Sample Call:

 FinalSettlementsPlanningBoardSettlementSheets_sp '12,13', '2014/10/01,2014/10/02', 2, 0
 
 
 FinalSettlementsPlanningBoardSettlementSheets_sp '12,13', '2014/02/05,2014/10/16', 2, 0


 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 2007/11/06 | PTS 40186 | JGUO � convert old style outer join syntax to ansi outer join syntax.
 * 2011/02/25 | PTS 55217 | SPN added ivh_billto and ivh_revtype1
 * 2011/08/01 | PTS 54604 | vjh add payto
 * 2014/09/19 | PTS 82740 | vjh convert from TMWSuite to .NetBackOffice
 * 2014/08/06 | PTS 81134 | AVANE - Add support for filtering by pay to
 * 2014/09/24 | PTS 82894 | vjh remove co-owner and replace with backoffice payto logic
 * 2014/10/30 | PTS 83476 | vjh pay schedule based retrieval
 * 2015/04/01 | PTS 88847 | vjh add trial settlement sheet support
 * 2015/07/23 | PTS 88847 | vjh new trial settlements cannot use final logic for pay summaries.
 * 2015/07/28 | PTS 88847 | vjh make trial sheets only look at pay details during this period
 * 2015/08/11 | PTS 88847 | vjh Trial Released includes pay headers in released status
 *								Trial Collected include on hold tweak
 *								Final Sheet include on hold tweak
 **/

declare @tprTypeMode int

CREATE TABLE #temp_que (
	pyhnumber				int null,
	asgn_type				varchar(3) not null,
	asgn_id					varchar(13) not null,
	status					varchar(8) null,
	previouspayperiod		datetime null,
	payperiod				datetime null,
	pyh_taxableearnings		money null,
	pyh_taxabledeductions	money null,
	pyh_adjustments			money null,
	pyh_deductions			money null,
	payto					varchar(12) null,
	terminal				varchar(8) null,
	driver					varchar(65) null,
	payto_lastfirst			varchar(65) null,
	type1					varchar(6) null,
	type2					varchar(6) null,
	type3					varchar(6) null,
	type4					varchar(6) null,
	det_count				smallint null,
	socsecfedtax			varchar(10) null,
	payScheduleId			int null)

DECLARE @scheduletable TABLE
(
	st_id	int	identity,
	sch_id	int
)

DECLARE @datetable TABLE
(
	dt_id	int	identity,
	paydate	datetime,
	previouspaydate datetime
)

exec dbo.UpdateAssetSchedules_sp

insert @scheduletable (sch_id)
(SELECT * FROM CSVStringsToTable_fn(@PayScheduleList))

insert @datetable (paydate)
(SELECT * FROM CSVStringsToTable_fn(@DateList))

update dt
set dt.previouspaydate = 
	(select max(p.PeriodCutoff) from PaySchedules s
	join PaySchedulePeriod p on p.PayScheduleId = s.PayScheduleId
	where s.PayScheduleId = st.sch_id and p.PeriodCutoff < dt.paydate)
from @datetable dt
join @scheduletable st on st.st_id = dt.dt_id

update dt
set dt.previouspaydate = '1950/01/01'
from @datetable dt
where dt.previouspaydate is null

IF @report_type = 0 --0 for trial released
BEGIN 
	INSERT INTO #temp_que 
		SELECT DISTINCT 0, --ph.pyh_pyhnumber, 
			'DRV', --ph.asgn_type, 
			mp.mpp_id, --ph.asgn_id, 
			'', --ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			dt.paydate, --ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			mp.mpp_payto, --ph.pyh_payto, 
			mp.mpp_terminal, 
			mp.mpp_lastfirst, 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			mp.mpp_type1, 
			mp.mpp_type2, 
			mp.mpp_type3, 
			mp.mpp_type4, 
			0,	--det_count
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join manpowerprofile mp on mp.PayScheduleId = st.sch_id
		JOIN payto pt ON mp.mpp_payto = pt.pto_id
		where not exists( --let the inclusion of the released (PND) payheader in the UNION below take precedence
			select 1 from payheader ph where ph.asgn_type = 'DRV' AND ph.asgn_id = mp.mpp_id AND ph.pyh_payperiod = dt.paydate and ph.pyh_paystatus = 'PND'
			)
		UNION
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			mp.mpp_terminal, 
			mp.mpp_lastfirst, 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			mp.mpp_type1, 
			mp.mpp_type2, 
			mp.mpp_type3, 
			mp.mpp_type4, 
			0, 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join manpowerprofile mp on mp.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'DRV' AND ph.asgn_id = mp.mpp_id AND ph.pyh_payperiod = dt.paydate
		JOIN payto pt ON ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus = 'PND'

	INSERT INTO #temp_que 
		SELECT DISTINCT 0, --ph.pyh_pyhnumber, 
			'TRC', --ph.asgn_type, 
			tp.trc_number, --ph.asgn_id, 
			'', --ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			dt.paydate, --ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			tp.trc_owner, --ph.pyh_payto, 
			tp.trc_terminal, 
			'', 
			case 
				when  len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			tp.trc_type1, 
			tp.trc_type2, 
			tp.trc_type3, 
			tp.trc_type4, 
			0,	--det_count
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join tractorprofile tp on tp.PayScheduleId = st.sch_id
		join payto pt on tp.trc_owner = pt.pto_id
		where not exists( --let the inclusion of the released (PND) payheader in the UNION below take precedence
			select 1 from payheader ph where ph.asgn_type = 'TRC' AND ph.asgn_id = tp.trc_number AND ph.pyh_payperiod = dt.paydate and ph.pyh_paystatus = 'PND'
			)
		UNION
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			tp.trc_terminal, 
			'', 
			case 
				when  len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			tp.trc_type1, 
			tp.trc_type2, 
			tp.trc_type3, 
			tp.trc_type4, 
			0, 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join tractorprofile tp on tp.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'TRC' AND ph.asgn_id = tp.trc_number AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus = 'PND'

	INSERT INTO #temp_que 
		SELECT DISTINCT 0, --ph.pyh_pyhnumber, 
			'CAR', --ph.asgn_type, 
			cr.car_id, --ph.asgn_id, 
			'', --ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			dt.paydate, --ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			cr.pto_id, --ph.pyh_payto, 
			'', 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			cr.car_type1, 
			cr.car_type2, 
			cr.car_type3, 
			cr.car_type4, 
			0,	--det_count
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join carrier cr on cr.PayScheduleId = st.sch_id
		join payto pt on cr.pto_id = pt.pto_id
		where not exists( --let the inclusion of the released (PND) payheader in the UNION below take precedence
			select 1 from payheader ph where ph.asgn_type = 'CAR' AND ph.asgn_id = cr.car_id AND ph.pyh_payperiod = dt.paydate and ph.pyh_paystatus = 'PND'
			)
		UNION
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			'', 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			cr.car_type1, 
			cr.car_type2, 
			cr.car_type3, 
			cr.car_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber
				), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join carrier cr on cr.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'CAR' AND ph.asgn_id = cr.car_id AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus = 'PND'

	INSERT INTO #temp_que
		SELECT DISTINCT 0, --ph.pyh_pyhnumber,
			'TPR', --ph.asgn_type,
			tpr.tpr_id, --ph.asgn_id,
			'', --ph.pyh_paystatus,
			dt.previouspaydate, --previouspaydate to be used for range
			dt.paydate, --ph.pyh_payperiod,
			0, 
			0, 
			0, 
			0, 
			tpr.tpr_payto, --ph.pyh_payto,
			'',
			'',
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end,
			'',
			'',
			'',
			'',
			0,	--det_count
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join thirdpartyprofile tpr on tpr.PayScheduleId = st.sch_id
		join payto pt on tpr.tpr_payto = pt.pto_id
		where not exists( --let the inclusion of the released (PND) payheader in the UNION below take precedence
			select 1 from payheader ph where ph.asgn_type = 'TPR' AND ph.asgn_id = tpr.tpr_id AND ph.pyh_payperiod = dt.paydate and ph.pyh_paystatus = 'PND'
			)
		UNION
		SELECT DISTINCT ph.pyh_pyhnumber,
			ph.asgn_type,
			ph.asgn_id,
			ph.pyh_paystatus,
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod,
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto,
			'',
			'',
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end,
			'',
			'',
			'',
			'',
			(SELECT count(DISTINCT pd.pyd_number)
				FROM paydetail pd
				WHERE pd.pyh_number = ph.pyh_pyhnumber
				), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join thirdpartyprofile tpr on tpr.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'TPR' AND ph.asgn_id = tpr.tpr_id AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus = 'PND'

	INSERT INTO #temp_que 
		SELECT DISTINCT 0, --ph.pyh_pyhnumber, 
			'TRL', --ph.asgn_type, 
			tp.trl_id, --ph.asgn_id, 
			'', --ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			dt.paydate, --ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0,  
			tp.trl_owner, --ph.pyh_payto, 
			tp.trl_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end,
			tp.trl_type1, 
			tp.trl_type2, 
			tp.trl_type3, 
			tp.trl_type4, 
			0,	--det_count
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join trailerprofile tp on tp.PayScheduleId = st.sch_id
		join payto pt on tp.trl_owner = pt.pto_id
		where not exists( --let the inclusion of the released (PND) payheader in the UNION below take precedence
			select 1 from payheader ph where ph.asgn_type = 'TRL' AND ph.asgn_id = tp.trl_id AND ph.pyh_payperiod = dt.paydate and ph.pyh_paystatus = 'PND'
			)
		UNION
				SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0,  
			ph.pyh_payto, 
			tp.trl_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end,
			tp.trl_type1, 
			tp.trl_type2, 
			tp.trl_type3, 
			tp.trl_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber
				), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join trailerprofile tp on tp.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'TRL' AND ph.asgn_id = tp.trl_number AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus = 'PND'

	INSERT INTO #temp_que 
		SELECT DISTINCT 0, --ph.pyh_pyhnumber, 
			'PTO', --ph.asgn_type, 
			pt.pto_id, --ph.asgn_id, 
			'', --ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			dt.paydate, --ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			pt.pto_id, --ph.pyh_payto, 
			pt.pto_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			pt.pto_type1, 
			pt.pto_type2, 
			pt.pto_type3, 
			pt.pto_type4, 
			0,	--det_count
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join payto pt on pt.PayScheduleId = st.sch_id
		where not exists( --let the inclusion of the released (PND) payheader in the UNION below take precedence
			select 1 from payheader ph where ph.asgn_type = 'PTO' AND ph.asgn_id = pt.pto_id AND ph.pyh_payperiod = dt.paydate and ph.pyh_paystatus = 'PND'
			)
		UNION
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			pt.pto_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			pt.pto_type1, 
			pt.pto_type2, 
			pt.pto_type3, 
			pt.pto_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber
				), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join payto pt on pt.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'PTO' AND ph.asgn_id = pt.pto_id AND ph.pyh_payperiod = dt.paydate
		WHERE ph.pyh_paystatus = 'PND'

	--update summary information using similar logic to the final settlements summary section in back office
	--update in 2 states, one for no pay header and the second for with pay header
	--no payheader
	update a SET
		det_count				= sum_pyh_detailcount,
		pyh_taxableearnings		= sum_pyh_taxableearnings,
		pyh_taxabledeductions	= sum_pyh_taxabledeductions,
		pyh_adjustments			= sum_pyh_adjustments,
		pyh_deductions			= sum_pyh_deductions
	From #temp_que a
	join
	(
		SELECT pd.asgn_type, pd.asgn_id,
			count(*) sum_pyh_detailcount,
			sum ( case when (pyd_amount > 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxableearnings, 
			sum ( case when (pyd_amount < 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxabledeductions, 
			sum ( case when (pyd_amount > 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_adjustments, 
			sum ( case when (pyd_amount < 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_deductions
	
		FROM #temp_que b
		join  paydetail pd on pd.asgn_type = b.asgn_type and pd.asgn_id = b.asgn_id
		where 
			(
				pd.pyh_payperiod > b.previouspayperiod AND 
				pd.pyh_payperiod <= b.payperiod AND
				pd.pyh_number = 0 AND
				pd.pyd_status = 'PND'
			)
		group by pd.asgn_type, pd.asgn_id
	) s on s.asgn_type = a.asgn_type and s.asgn_id = a.asgn_id
	--all loose pay details
	--where a.pyhnumber = 0

	--with payheader
	update a SET
		det_count				= sum_pyh_detailcount,
		pyh_taxableearnings		= sum_pyh_taxableearnings,
		pyh_taxabledeductions	= sum_pyh_taxabledeductions,
		pyh_adjustments			= sum_pyh_adjustments,
		pyh_deductions			= sum_pyh_deductions
	From #temp_que a
	join
	(
		SELECT pd.asgn_type, pd.asgn_id, ph.pyh_payperiod,
			count(*) sum_pyh_detailcount,
			sum ( case when (pyd_amount > 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxableearnings, 
			sum ( case when (pyd_amount < 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxabledeductions, 
			sum ( case when (pyd_amount > 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_adjustments, 
			sum ( case when (pyd_amount < 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_deductions
		FROM #temp_que b
		join paydetail pd on pd.asgn_type = b.asgn_type and pd.asgn_id = b.asgn_id
		join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
		where ph.pyh_pyhnumber = pd.pyh_number
		group by pd.asgn_type, pd.asgn_id, ph.pyh_payperiod
	) s on s.asgn_type = a.asgn_type and s.asgn_id = a.asgn_id and a.payperiod = s.pyh_payperiod
	where a.pyhnumber > 0

	--Now increase the detail count (but not $) with on hold
	IF @hldstatus = 1 BEGIN
		update a SET
		det_count				+= sum_pyh_detailcount
		From #temp_que a
		join
			(
		SELECT pd.asgn_type, pd.asgn_id,
			count(*) sum_pyh_detailcount
		FROM #temp_que b
		join paydetail pd on pd.asgn_type = b.asgn_type and pd.asgn_id = b.asgn_id
		where pyd_status = 'HLD'
		group by pd.asgn_type, pd.asgn_id
	) s on s.asgn_type = a.asgn_type and s.asgn_id = a.asgn_id
	END	
END

IF @report_type = 1 --1 for trial collected
BEGIN 
	INSERT INTO #temp_que 
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			mp.mpp_terminal, 
			mp.mpp_lastfirst, 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			mp.mpp_type1, 
			mp.mpp_type2, 
			mp.mpp_type3, 
			mp.mpp_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join manpowerprofile mp on mp.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'DRV' AND ph.asgn_id = mp.mpp_id AND ph.pyh_payperiod = dt.paydate
		JOIN payto pt ON ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus = 'COL'
	
	INSERT INTO #temp_que 
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			tp.trc_terminal, 
			'', 
			case 
				when  len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			tp.trc_type1, 
			tp.trc_type2, 
			tp.trc_type3, 
			tp.trc_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join tractorprofile tp on tp.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'TRC' AND ph.asgn_id = tp.trc_number AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus = 'COL'

	INSERT INTO #temp_que 
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			'', 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			cr.car_type1, 
			cr.car_type2, 
			cr.car_type3, 
			cr.car_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join carrier cr on cr.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'CAR' AND ph.asgn_id = cr.car_id AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus = 'COL'

	INSERT INTO #temp_que
		SELECT DISTINCT ph.pyh_pyhnumber,
			ph.asgn_type,
			ph.asgn_id,
			ph.pyh_paystatus,
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod,
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto,
			'',
			'',
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end,
			'',
			'',
			'',
			'',
			(SELECT count(DISTINCT pd.pyd_number)
				FROM paydetail pd
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join thirdpartyprofile tpr on tpr.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'TPR' AND ph.asgn_id = tpr.tpr_id AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus = 'COL'

	INSERT INTO #temp_que 
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0,  
			ph.pyh_payto, 
			tp.trl_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end,
			tp.trl_type1, 
			tp.trl_type2, 
			tp.trl_type3, 
			tp.trl_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join trailerprofile tp on tp.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'TRL' AND ph.asgn_id = tp.trl_number AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus = 'COL'

	INSERT INTO #temp_que 
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			pt.pto_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			pt.pto_type1, 
			pt.pto_type2, 
			pt.pto_type3, 
			pt.pto_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join payto pt on pt.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'PTO' AND ph.asgn_id = pt.pto_id AND ph.pyh_payperiod = dt.paydate
		WHERE ph.pyh_paystatus = 'COL'

		--update summary information using similar logic to the final settlements summary secion in back office
	update a SET
		pyh_taxableearnings		= sum_pyh_taxableearnings,
		pyh_taxabledeductions	= sum_pyh_taxabledeductions,
		pyh_adjustments			= sum_pyh_adjustments,
		pyh_deductions			= sum_pyh_deductions
	From #temp_que a
	join
	(
		SELECT b.pyhnumber, 
			sum ( case when (pyd_amount > 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxableearnings, 
			sum ( case when (pyd_amount < 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxabledeductions, 
			sum ( case when (pyd_amount > 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_adjustments, 
			sum ( case when (pyd_amount < 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_deductions
		FROM #temp_que b
		join paydetail pd on b.pyhnumber = pd.pyh_number
		group by b.pyhnumber
	) s on a.pyhnumber = s.pyhnumber
	where a.pyhnumber <> 0
END

IF @report_type = 2 --2 for final
BEGIN 
	INSERT INTO #temp_que 
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			mp.mpp_terminal, 
			mp.mpp_lastfirst, 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			mp.mpp_type1, 
			mp.mpp_type2, 
			mp.mpp_type3, 
			mp.mpp_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join manpowerprofile mp on mp.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'DRV' AND ph.asgn_id = mp.mpp_id AND ph.pyh_payperiod = dt.paydate
		JOIN payto pt ON ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus in ('REL','XFR')
				
	INSERT INTO #temp_que 
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			tp.trc_terminal, 
			'', 
			case 
				when  len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			tp.trc_type1, 
			tp.trc_type2, 
			tp.trc_type3, 
			tp.trc_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join tractorprofile tp on tp.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'TRC' AND ph.asgn_id = tp.trc_number AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus in ('REL','XFR')

	INSERT INTO #temp_que 
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			'', 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			cr.car_type1, 
			cr.car_type2, 
			cr.car_type3, 
			cr.car_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join carrier cr on cr.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'CAR' AND ph.asgn_id = cr.car_id AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus in ('REL','XFR')

	INSERT INTO #temp_que
		SELECT DISTINCT ph.pyh_pyhnumber,
			ph.asgn_type,
			ph.asgn_id,
			ph.pyh_paystatus,
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod,
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto,
			'',
			'',
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end,
			'',
			'',
			'',
			'',
			(SELECT count(DISTINCT pd.pyd_number)
				FROM paydetail pd
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join thirdpartyprofile tpr on tpr.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'TPR' AND ph.asgn_id = tpr.tpr_id AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus in ('REL','XFR')

	INSERT INTO #temp_que 
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0,  
			ph.pyh_payto, 
			tp.trl_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end,
			tp.trl_type1, 
			tp.trl_type2, 
			tp.trl_type3, 
			tp.trl_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join trailerprofile tp on tp.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'TRL' AND ph.asgn_id = tp.trl_number AND ph.pyh_payperiod = dt.paydate
		join payto pt on ph.pyh_payto = pt.pto_id
		WHERE ph.pyh_paystatus in ('REL','XFR')

	INSERT INTO #temp_que 
		SELECT DISTINCT ph.pyh_pyhnumber, 
			ph.asgn_type, 
			ph.asgn_id, 
			ph.pyh_paystatus, 
			dt.previouspaydate, --previouspaydate to be used for range
			ph.pyh_payperiod, 
			0, 
			0, 
			0, 
			0, 
			ph.pyh_payto, 
			pt.pto_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			pt.pto_type1, 
			pt.pto_type2, 
			pt.pto_type3, 
			pt.pto_type4, 
			(SELECT COUNT(DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				WHERE pd.pyh_number = ph.pyh_pyhnumber OR
					(@hldstatus = 1 AND
					pd.pyd_status = 'HLD' AND 
					pd.asgn_type = ph.asgn_type AND
					pd.asgn_id = ph.asgn_id
					)
			), 
			pt.pto_ssn,
			st.sch_id
		FROM @scheduletable st
		join @datetable dt on dt.dt_id = st.st_id
		join payto pt on pt.PayScheduleId = st.sch_id
		join payheader ph on ph.asgn_type = 'PTO' AND ph.asgn_id = pt.pto_id AND ph.pyh_payperiod = dt.paydate
		WHERE ph.pyh_paystatus in ('REL','XFR')

	--update summary information using similar logic to the final settlements summary secion in back office
	update a SET
		pyh_taxableearnings		= sum_pyh_taxableearnings,
		pyh_taxabledeductions	= sum_pyh_taxabledeductions,
		pyh_adjustments			= sum_pyh_adjustments,
		pyh_deductions			= sum_pyh_deductions
	From #temp_que a
	join
	(
		SELECT b.pyhnumber, 
			sum ( case when (pyd_amount > 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxableearnings, 
			sum ( case when (pyd_amount < 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxabledeductions, 
			sum ( case when (pyd_amount > 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_adjustments, 
			sum ( case when (pyd_amount < 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_deductions
		FROM #temp_que b
		join paydetail pd on b.pyhnumber = pd.pyh_number
		group by b.pyhnumber
	) s on a.pyhnumber = s.pyhnumber
	where a.pyhnumber <> 0
END

SELECT 
	pyhnumber,
	asgn_type,
	asgn_id,
	status,
	payperiod,
	pyh_taxableearnings,
	pyh_taxabledeductions,
	pyh_adjustments,
	pyh_deductions,
	payto,
	terminal,
	driver,
	payto_lastfirst,
	type1,
	type2,
	type3,
	type4,
	det_count,
	socsecfedtax,
	payScheduleId
FROM #temp_que
WHERE det_count > 0

DROP TABLE #temp_que
GO
GRANT EXECUTE ON  [dbo].[FinalSettlementsPlanningBoardSettlementSheets_sp] TO [public]
GO
