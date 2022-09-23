SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[FinalSettlementsPlanningBoardClose_sp]    (
	@PayScheduleList	varchar(4000),
	@DateList			varchar(4000)
)  AS

/**
*
* NAME@
* dbo.FinalSettlementsPlanningBoardClose_sp
*
* TYPE@
* StoredProcedure
*
* DESCRIPTION@
* Stored Procedure used as a data source for the settlement queues.
*
* Result Set
*
* pyh_pyhnumber		int
* asgn_type			char(6)
* asgn_id			varchar(13)
* pyh_paystatus		varchar(6)
* pyh_payperiod		datetime
* Earnings			money
* Deductions		money
* Expenses			money
* Total				money
* pyh_payto			varchar(12)
* terminal			varchar(6)
* Driver Name		varchar(45)
* Payto Name		varchar(45)
* pay detail count	int
* Type1				varchar(6)
*
* 2011/08/11 | PTS 58375 | LOR  created proc instead of dw sql to accommodate views
* 2012/11/26 | PTS 64692 | jet - add 3rd party revenue types to restrict Collect queue by 3rd Party revenue types
* 2012/12/03 | PTS 63448 | SPN fixing trailer parm issue and changed join to trailerprofile to be trl_id instead of trl_number
* 2012/11/08 | PTS 65645 | SPN - Added Restriction @mpp_branch, @trc_branch, @trl_branch, @car_branch
* 2014/10/03 | PTS 83178 | vjh convert original d_scroll_payheaders_sp to FinalSettlementsPlanningBoardClose_sp
* 2014/10/09 | PTS 83178 | vjh redesign, change result set
* 2014/10/30 | PTS 83476 | vjh pay schedule based retrieval
*/


create table #temp 
( 
	pyh_pyhnumber			int,
	asgn_type				varchar(6),
	asgn_id					varchar(13),
	pyh_paystatus			varchar(6),
	pyh_payperiod			datetime,
	pyh_taxableearnings		money,
	pyh_taxabledeductions	money,
	pyh_adjustments			money,
	pyh_deductions			money,
	pyh_payto				varchar(12),
	terminal				varchar(6),
	drivername				varchar(45),
	paytoname				varchar(45),
	paydetailcount			int,
	type1					varchar(6),
	payScheduleId			int
)

DECLARE @scheduletable TABLE
(
	st_id	int	identity,
	sch_id	int
)

DECLARE @datetable TABLE
(
	dt_id	int	identity,
	paydate	datetime
)

exec dbo.UpdateAssetSchedules_sp

insert @scheduletable (sch_id)
(SELECT * FROM CSVStringsToTable_fn(@PayScheduleList))

insert @datetable (paydate)
(SELECT * FROM CSVStringsToTable_fn(@DateList))

insert into #temp
SELECT DISTINCT payheader.pyh_pyhnumber,
	payheader.asgn_type,
	payheader.asgn_id,
	payheader.pyh_paystatus,
	payheader.pyh_payperiod,
	Cast (0 as Money) 'pyh_taxableearnings' ,
	Cast (0 as Money) 'pyh_taxabledeductions' ,
	Cast (0 as Money) 'pyh_adjustments',
	Cast (0 as Money) 'pyh_deductions',
	payheader.pyh_payto,
	mp.mpp_terminal,
	mp.mpp_lastfirst driver_id,
	payto.pto_lastfirst,
	(SELECT COUNT(pyd_number)
		FROM paydetail
		WHERE paydetail.pyh_number = payheader.pyh_pyhnumber),
	mpp_type1,
	st.sch_id
FROM @scheduletable st
join @datetable dt on dt.dt_id = st.st_id
join manpowerprofile mp on mp.PayScheduleId = st.sch_id
join payheader ON payheader.asgn_id = mp.mpp_id and payheader.asgn_type = 'DRV' and payheader.pyh_payperiod = dt.paydate
join dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('manpowerprofile', null) rsva on (rsva.rowsec_rsrv_id = mp.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id
WHERE payheader.pyh_paystatus = 'COL'

insert into #temp
SELECT DISTINCT payheader.pyh_pyhnumber,
	payheader.asgn_type,
	payheader.asgn_id,
	payheader.pyh_paystatus,
	payheader.pyh_payperiod,
	Cast (0 as Money) 'pyh_taxableearnings' ,
	Cast (0 as Money) 'pyh_taxabledeductions' ,
	Cast (0 as Money) 'pyh_adjustments',
	Cast (0 as Money) 'pyh_deductions',
	payheader.pyh_payto,
	tp.trc_terminal,
	'' driver_id,
	payto.pto_lastfirst,
	(SELECT count(pyd_number)
		from paydetail
		where paydetail.pyh_number = payheader.pyh_pyhnumber),
	trc_type1,
	st.sch_id
FROM @scheduletable st
join @datetable dt on dt.dt_id = st.st_id
join tractorprofile tp on tp.PayScheduleId = st.sch_id
join payheader  on payheader.asgn_id = tp.trc_number and payheader.asgn_type = 'TRC' and payheader.pyh_payperiod = dt.paydate
INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('tractorprofile', null) rsva on (rsva.rowsec_rsrv_id = tp.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE payheader.pyh_paystatus = 'COL'

insert into #temp
SELECT DISTINCT payheader.pyh_pyhnumber,
	payheader.asgn_type,
	payheader.asgn_id,
	payheader.pyh_paystatus,
	payheader.pyh_payperiod,
	Cast (0 as Money) 'pyh_taxableearnings' ,
	Cast (0 as Money) 'pyh_taxabledeductions' ,
	Cast (0 as Money) 'pyh_adjustments',
	Cast (0 as Money) 'pyh_deductions',
	payheader.pyh_payto,
	'',
	'' driver_id,
	payto.pto_lastfirst,
	(SELECT count(pyd_number)
		from paydetail
		where paydetail.pyh_number = payheader.pyh_pyhnumber),
	car_type1,
	st.sch_id
FROM @scheduletable st
join @datetable dt on dt.dt_id = st.st_id
join carrier cr on cr.PayScheduleId = st.sch_id
join payheader  on payheader.asgn_id = cr.car_id and payheader.asgn_type = 'CAR' and payheader.pyh_payperiod = dt.paydate
INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('carrier', null) rsva on (rsva.rowsec_rsrv_id = cr.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE payheader.pyh_paystatus = 'COL'

insert into #temp
SELECT DISTINCT payheader.pyh_pyhnumber,
	payheader.asgn_type,
	payheader.asgn_id,
	payheader.pyh_paystatus,
	payheader.pyh_payperiod,
	Cast (0 as Money) 'pyh_taxableearnings' ,
	Cast (0 as Money) 'pyh_taxabledeductions' ,
	Cast (0 as Money) 'pyh_adjustments',
	Cast (0 as Money) 'pyh_deductions',
	payheader.pyh_payto,
	trl_terminal,
	'' driver_id,
	payto.pto_lastfirst,
	(SELECT count(pyd_number)
		from paydetail
		where paydetail.pyh_number = payheader.pyh_pyhnumber),
	trl_type1,
	st.sch_id
FROM @scheduletable st
join @datetable dt on dt.dt_id = st.st_id
join trailerprofile tp on tp.PayScheduleId = st.sch_id
join payheader on payheader.asgn_id = tp.trl_id and payheader.asgn_type = 'TRL' and payheader.pyh_payperiod = dt.paydate
INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('trailerprofile', null) rsva on (rsva.rowsec_rsrv_id = tp.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE payheader.pyh_paystatus = 'COL'

insert into #temp
SELECT DISTINCT payheader.pyh_pyhnumber,
	payheader.asgn_type,
	payheader.asgn_id,
	payheader.pyh_paystatus,
	payheader.pyh_payperiod,
	Cast (0 as Money) 'pyh_taxableearnings' ,
	Cast (0 as Money) 'pyh_taxabledeductions' ,
	Cast (0 as Money) 'pyh_adjustments',
	Cast (0 as Money) 'pyh_deductions',
	payheader.pyh_payto,
	'',
	'' driver_id,
	payto.pto_lastfirst,
	(SELECT count(pyd_number)
		from paydetail
		where paydetail.pyh_number = payheader.pyh_pyhnumber),
	tpr_revtype1,
	st.sch_id
FROM @scheduletable st
join @datetable dt on dt.dt_id = st.st_id
join thirdpartyprofile tpr on tpr.PayScheduleId = st.sch_id
join payheader on payheader.asgn_id = tpr.tpr_id AND payheader.asgn_type = 'TPR' and payheader.pyh_payperiod = dt.paydate
left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE payheader.pyh_paystatus = 'COL'

insert into #temp
SELECT DISTINCT payheader.pyh_pyhnumber,
	payheader.asgn_type,
	payheader.asgn_id,
	payheader.pyh_paystatus,
	payheader.pyh_payperiod,
	Cast (0 as Money) 'pyh_taxableearnings' ,
	Cast (0 as Money) 'pyh_taxabledeductions' ,
	Cast (0 as Money) 'pyh_adjustments',
	Cast (0 as Money) 'pyh_deductions',
	payheader.pyh_payto,
	'',
	'' driver_id,
	pto.pto_lastfirst,
	(SELECT count(pyd_number)
		from paydetail
		where paydetail.pyh_number = payheader.pyh_pyhnumber),
	pto.pto_type1,
	st.sch_id
FROM @scheduletable st
join @datetable dt on dt.dt_id = st.st_id
join payto pto on pto.PayScheduleId = st.sch_id
join payheader on payheader.pyh_payto = pto.pto_id and payheader.asgn_type = 'PTO' and payheader.pyh_payperiod = dt.paydate
WHERE  payheader.pyh_paystatus = 'COL'

update a SET
	pyh_taxableearnings		= sum_pyh_taxableearnings,
	pyh_taxabledeductions	= sum_pyh_taxabledeductions,
	pyh_adjustments			= sum_pyh_adjustments,
	pyh_deductions			= sum_pyh_deductions
From #temp a
join
(
	SELECT pyh_number, 
		sum ( case when (pyd_amount > 0 and pyd_pretax = 'Y') then paydetail.pyd_amount else 0 end) sum_pyh_taxableearnings, 
		sum ( case when (pyd_amount < 0 and pyd_pretax = 'Y') then paydetail.pyd_amount else 0 end) sum_pyh_taxabledeductions, 
		sum ( case when (pyd_amount > 0 and pyd_pretax = 'N') then paydetail.pyd_amount else 0 end) sum_pyh_adjustments, 
		sum ( case when (pyd_amount < 0 and pyd_pretax = 'N') then paydetail.pyd_amount else 0 end) sum_pyh_deductions
	FROM paydetail
	group by pyh_number
) s on a.pyh_pyhnumber = s.pyh_number


select 
	pyh_pyhnumber,
	asgn_type,
	asgn_id,
	pyh_paystatus,
	pyh_payperiod,
	abs(isnull(pyh_taxableearnings, 0)) pyh_taxableearnings,
	abs(isnull(pyh_taxabledeductions, 0)) pyh_taxabledeductions,
	abs(isnull(pyh_adjustments, 0)) pyh_adjustments,
	abs(isnull(pyh_deductions, 0)) pyh_deductions,
	pyh_payto,
	terminal,
	drivername,
	paytoname,
	paydetailcount,
	type1,
	payScheduleId
from #temp
order by asgn_type, asgn_id


GO
GRANT EXECUTE ON  [dbo].[FinalSettlementsPlanningBoardClose_sp] TO [public]
GO
