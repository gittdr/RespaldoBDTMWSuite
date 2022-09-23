SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[FinalSettlementsPlanningBoardCollect_sp]    (
	@PayScheduleList	varchar(4000),
	@DateList			varchar(4000),
	@excludenopay		char(1)
)  AS

/*WITH RECOMPILE */

/**
*
* NAME:
* dbo.FinalSettlementsPlanningBoardCollect_sp
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
* 001 -	@PayScheduleList	varchar(4000),
* 002 -	@DateList			varchar(4000),
* 003 - @excludenopay		char(1)
*
* Sample Call:

FinalSettlementsPlanningBoardCollect_sp '12,13', '2014/02/05,2014/10/16', 'N'

* REVISION HISTORY:
* 2005/08/08 | PTS 29148 | jguo - replace double quotes around literals, table and column names.
* 2007/11/30 | PTS 40463 | JGUO � convert old style outer join syntax to ansi outer join syntax.
* 2009/04/27 | PTS 46278 | vjh - added grace logic and new setting
* 2010/11/02 | PTS 54303 | Additional filtering mechanism based on new GI setting
* 2011/06/07 | PTS 54402 | vjh - add coowner logic for tractor
* 2012/11/26 | PTS 64692 | jet - add 3rd party revenue types to restrict Collect queue by 3rd Party revenue types
* 2012/06/24 | PTS 70279 | SPN - Asset should appear in the queue when headers reopened (PND)
* 2014/09/19 | PTS 82887 | vjh convert from TMWSuite (d_pay_scroll_payfors_tpr_sp) to .NetBackOffice
* 2014/09/24 | PTS 82887 | vjh remove co-owner and replace with backoffice payto logic
* 2014/10/09 | PTS 82887 | vjh redesign, change result set
* 2014/10/30 | PTS 83476 | vjh pay schedule based retrieval
* 2015/01/08 | PTS 82887 | vjh clean up payto to be paytos rather than other assets with settle by payto
* 2015/01/08 | PTS 82887 | vjh more payto cleanup, earnings must include all assets with this payto
* 2015/01/13 | PTS 85979 | vjh add @excludenopay
*/

declare
	@AcctType1		varchar(1) ,
	@AcctType2		varchar(1) ,
	@type			varchar(6),
	@id				varchar(13),
	@tpr_type1		char(1),
	@tpr_type2		char(1),
	@tpr_type3		char(1),
	@tpr_type4		char(1),
	@tpr_type5		char(1),
	@tpr_type6		char(1),
	@daysout		int,
	@alltprsX		char(1),
	@tprTypeMode	int

DECLARE @tmp5 TABLE
(
	pto_id          VARCHAR(12)  NULL,
	paydate			datetime null,
	paySchedulId	int null
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

SELECT @daysout = -60

If exists (select * from generalinfo where gi_name = 'UseGraceInCollectQueue' and gi_string1 = 'Y')
	if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
		select @daysout = lbp_daysout
		from ListBoxProperty
		where lbp_id=@@spid
	else
		SELECT @daysout = gi_integer1
		FROM  generalinfo
		WHERE gi_name = 'GRACE'

if @daysout is null SELECT @daysout = -60

/* CREATE TEMP TABLE */
SELECT   
	pyh_pyhnumber,
	asgn_type,
	asgn_id,
	pyh_paystatus ,
	pyh_payperiod ,
	Cast (0 as Money) 'pyh_taxableearnings' ,
	Cast (0 as Money) 'pyh_taxabledeductions' ,
	Cast (0 as Money) 'pyh_adjustments',
	Cast (0 as Money) 'pyh_deductions',
	pyh_payto,
	0 'payScheduleId'
INTO #temp
FROM payheader
WHERE 1 = 2

/* GENERATE ASSET LISTS FOR DRIVER */
	insert into #temp
	SELECT   
		-1,
		'DRV',
		mpp_id,
		'-' ,
		dt.paydate,
		0.0000,
		0.0000,
		0.0000,
		0.0000,
		mpp_payto,
		st.sch_id
	FROM @scheduletable st
	join @datetable dt on dt.dt_id = st.st_id
	join manpowerprofile mp on mp.PayScheduleId = st.sch_id
	join payto on mpp_payto = pto_id
	WHERE ( mpp_status <> 'OUT' OR mpp_terminationdt > dateadd ( day, @daysout, dt.paydate ) or @daysout=999) AND
		( NOT EXISTS ( SELECT *
			FROM payheader
			WHERE asgn_type = 'DRV' AND
			asgn_id = mp.mpp_id AND
			pyh_payperiod = dt.paydate AND
			pyh_paystatus <> 'PND' )
		OR EXISTS ( SELECT 1
			FROM payheader
			WHERE asgn_type = 'DRV'
			AND asgn_id = mp.mpp_id
			AND pyh_payperiod = dt.paydate
			AND pyh_paystatus = 'PND' )
		)
		AND isnull(pto_stlByPayTo,0) <> 1

/* GENERATE ASSET LISTS FOR TRACTOR */
	insert into #temp
	SELECT   
		-1,
		'TRC',
		trc_number,
		'-' ,
		dt.paydate,
		0.0000,
		0.0000,
		0.0000,
		0.0000,
		trc_owner,
		st.sch_id
	FROM @scheduletable st
	join @datetable dt on dt.dt_id = st.st_id
	join tractorprofile tp on tp.PayScheduleId = st.sch_id
	join payto on trc_owner = pto_id
	WHERE ( trc_status <> 'OUT' OR trc_retiredate > dateadd ( day, @daysout, dt.paydate )  or @daysout=999) AND
		( NOT EXISTS ( SELECT *
			FROM payheader
			WHERE asgn_type = 'TRC' AND
			asgn_id = tp.trc_number AND
			pyh_payperiod = dt.paydate AND
			pyh_paystatus <> 'PND' )
		OR EXISTS ( SELECT 1
			FROM payheader
			WHERE asgn_type = 'TRC'
			AND asgn_id = tp.trc_number
			AND pyh_payperiod = dt.paydate
			AND pyh_paystatus = 'PND' )
		)
		AND isnull(pto_stlByPayTo,0) <> 1

/* GENERATE ASSET LISTS FOR TRAILER */
	insert into #temp
	SELECT
	   -1,
		'TRL',
		trl_id,
		'-' ,
		dt.paydate,
		0.0000,
		0.0000,
		0.0000,
		0.0000,
		trl_owner,
		st.sch_id
	FROM @scheduletable st
	join @datetable dt on dt.dt_id = st.st_id
	join trailerprofile tp on tp.PayScheduleId = st.sch_id
	join payto on trl_owner = pto_id
	WHERE ( trl_status <> 'OUT' ) AND
		( NOT EXISTS ( SELECT *
			FROM payheader
			WHERE asgn_type = 'TRL' AND
			asgn_id = tp.trl_id AND
			pyh_payperiod = dt.paydate AND
			pyh_paystatus <> 'PND' )
		OR EXISTS ( SELECT 1
			FROM payheader
			WHERE asgn_type = 'TRL'
			AND asgn_id = tp.trl_id
			AND pyh_payperiod = dt.paydate
			AND pyh_paystatus = 'PND' )
		)
		AND isnull(pto_stlByPayTo,0) <> 1

/* GENERATE ASSET LISTS FOR CARRIER */
	insert into #temp
	SELECT   
		-1,
		'CAR',
		car_id,
		'-' ,
		dt.paydate,
		0.0000,
		0.0000,
		0.0000,
		0.0000,
		'UNKNOWN',
		st.sch_id
	FROM @scheduletable st
	join @datetable dt on dt.dt_id = st.st_id
	join carrier cr on cr.PayScheduleId = st.sch_id
	join payto on cr.pto_id = payto.pto_id
	WHERE ( car_status <> 'OUT' OR car_terminationdt > dateadd ( day, @daysout, dt.paydate ) or @daysout=999) AND
		( NOT EXISTS ( SELECT *
			FROM payheader
			WHERE asgn_type = 'CAR' AND
			asgn_id = cr.car_id AND
			pyh_payperiod = dt.paydate AND
			pyh_paystatus <> 'PND' )
		OR EXISTS ( SELECT 1
			FROM payheader
			WHERE asgn_type = 'CAR'
			AND asgn_id = cr.car_id
			AND pyh_payperiod = dt.paydate
			AND pyh_paystatus = 'PND' )
		)
		AND isnull(pto_stlByPayTo,0) <> 1

/* GENERATE ASSET LISTS FOR thirdparty */
	insert into #temp
	SELECT
		-1,
		'TPR',
		tpr_id,
		'-' ,
		dt.paydate,
		0.0000,
		0.0000,
		0.0000,
		0.0000,
		tpr_payto,
		st.sch_id
	FROM @scheduletable st
	join @datetable dt on dt.dt_id = st.st_id
	join thirdpartyprofile tpr on tpr.PayScheduleId = st.sch_id
	join payto on tpr_payto = pto_id
	WHERE tpr_active = 'Y' AND
		( NOT EXISTS ( SELECT *
			FROM payheader
			WHERE asgn_type = 'TPR' AND
			asgn_id = tpr.tpr_id AND
			pyh_payperiod = dt.paydate AND
			pyh_paystatus <> 'PND' )
		OR EXISTS ( SELECT 1
			FROM payheader
			WHERE asgn_type = 'TPR'
			AND asgn_id = tpr.tpr_id
			AND pyh_payperiod = dt.paydate
			AND pyh_paystatus = 'PND' )
		)
		AND isnull(pto_stlByPayTo,0) <> 1


/* GENERATE ASSET LISTS FOR PayTo */
	insert into #temp
	SELECT   
		-1,
		'PTO',
		pto_id,
		'-' ,
		paydate,
		0.0000,
		0.0000,
		0.0000,
		0.0000,
		pto_id,
		pto.payScheduleId
	FROM @scheduletable st
	join @datetable dt on dt.dt_id = st.st_id
	join payto pto on pto.PayScheduleId = st.sch_id
	WHERE isnull(pto_stlByPayTo,0) = 1
		and
		( NOT EXISTS ( SELECT *
			FROM payheader
			WHERE asgn_type = 'PTO' AND
			asgn_id = pto_id AND
			pyh_payperiod = paydate AND
			pyh_paystatus <> 'PND' )
		OR EXISTS ( SELECT 1
			FROM payheader
			WHERE asgn_type = 'PTO'
			AND asgn_id = pto_id
			AND pyh_payperiod = paydate
			AND pyh_paystatus = 'PND' )
		)

update a SET
	pyh_taxableearnings		= sum_pyh_taxableearnings,
	pyh_taxabledeductions	= sum_pyh_taxabledeductions,
	pyh_adjustments			= sum_pyh_adjustments,
	pyh_deductions			= sum_pyh_deductions
From #temp a
join
(
	SELECT b.asgn_type,
		b.asgn_id, 
		sum ( case when (pyd_amount > 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxableearnings, 
		sum ( case when (pyd_amount < 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxabledeductions, 
		sum ( case when (pyd_amount > 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_adjustments, 
		sum ( case when (pyd_amount < 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_deductions
	FROM #temp b
	join paydetail pd on b.asgn_type = pd.asgn_type and b.asgn_id = pd.asgn_id and (pd.pyh_payperiod = b.pyh_payperiod)
	group by b.asgn_type, b.asgn_id
) s on a.asgn_type = s.asgn_type and a.asgn_id = s.asgn_id
where a.asgn_type <> 'PTO'

update a SET
	pyh_taxableearnings		= sum_pyh_taxableearnings,
	pyh_taxabledeductions	= sum_pyh_taxabledeductions,
	pyh_adjustments			= sum_pyh_adjustments,
	pyh_deductions			= sum_pyh_deductions
From #temp a
join
(
	SELECT b.asgn_type,
		b.asgn_id, 
		sum ( case when (pyd_amount > 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxableearnings, 
		sum ( case when (pyd_amount < 0 and pyd_pretax = 'Y') then pd.pyd_amount else 0 end) sum_pyh_taxabledeductions, 
		sum ( case when (pyd_amount > 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_adjustments, 
		sum ( case when (pyd_amount < 0 and pyd_pretax = 'N') then pd.pyd_amount else 0 end) sum_pyh_deductions
	FROM #temp b
	join paydetail pd on b.asgn_id = pd.pyd_payto and (pd.pyh_payperiod = b.pyh_payperiod)
	where b.asgn_type = 'PTO'
	group by b.asgn_type, b.asgn_id
) s on a.asgn_type = s.asgn_type and a.asgn_id = s.asgn_id
where a.asgn_type = 'PTO'

/* FINAL SELECT TO RETRIEVE RETURN SET */
select 
	--pyh_pyhnumber,
	asgn_type,
	asgn_id,
	pyh_paystatus,
	pyh_payperiod,
	abs(isnull(pyh_taxableearnings, 0)) pyh_taxableearnings,
	abs(isnull(pyh_taxabledeductions, 0)) pyh_taxabledeductions,
	abs(isnull(pyh_adjustments, 0)) pyh_adjustments,
	abs(isnull(pyh_deductions, 0)) pyh_deductions,
	pyh_payto,
	payScheduleId
from #temp
where @excludenopay = 'N' or
	(pyh_taxableearnings <> 0 or pyh_taxabledeductions <> 0 or pyh_adjustments <> 0 or pyh_deductions <> 0)
order by asgn_type, asgn_id
return
GO
GRANT EXECUTE ON  [dbo].[FinalSettlementsPlanningBoardCollect_sp] TO [public]
GO
