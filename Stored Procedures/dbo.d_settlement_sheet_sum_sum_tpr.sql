SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_settlement_sheet_sum_sum_tpr](@payperiodstart datetime,
					@payperiodend   datetime,
					@drv_yes        varchar(3),
					@trc_yes        varchar(3),
					@trl_yes        varchar(3),
					@drv_id         varchar(8),
					@trc_id         varchar(8),
					@trl_id         varchar(13),
					@drv_type1      varchar(6),
					@drv_type2      varchar(6),     
					@drv_type3      varchar(6),
					@drv_type4      varchar(6),
					@trc_type1      varchar(6),
					@trc_type2      varchar(6),     
					@trc_type3      varchar(6),
					@trc_type4      varchar(6),
					@trl_type1      varchar(6),
					@trl_type2      varchar(6),     
					@trl_type3      varchar(6),
					@trl_type4      varchar(6),
					@company        varchar(8),
					@fleet          varchar(8),
					@division       varchar(8),
					@domicile       varchar(8),
					@acct_type      char(1),
					@car_yes	varchar(3),
					@car_id		varchar(8),
					@car_type1      varchar(6),
					@car_type2      varchar(6),     
					@car_type3      varchar(6),
					@car_type4      varchar(6),
					@tpr_yes	varchar(3),
					@tpr_yes1 	varchar(1),
					@tpr_yes2 	varchar(1),
					@tpr_yes3 	varchar(1),
					@tpr_yes4 	varchar(1),
					@tpr_yes5 	varchar(1),
					@tpr_yes6 	varchar(1),
					@tpr_id  	varchar(8))

AS
/**
 * 
 * NAME:
 * dbo.d_settlement_sheet_sum_sum_tpr
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
 *
 **/

/* CREATE TABLE */
SELECT pyd_unit,
	pyd_pretax, 
	pyd_minus,
	pyt_itemcode, 
	pyd_status, 
	pyd_loadstate,
	pyh_payperiod, 
	pyd_workperiod, 
	pyd_amount,
	@payperiodstart payperiodstart,
	@payperiodend payperiodend
INTO #tt   
FROM paydetail
WHERE 1 = 2 


/* LOAD DATA INTO TABLE FOR DRV, TRC, TRL, CAR and TPR */

/* LOAD DATA INTO TABLE FOR DRV */
if (@drv_yes <> 'XXX') 
begin
	/* MAKE TEMPTABLE FOR DRIVERS THAT MATCH RESTRICTION SET */
	SELECT mp.mpp_id
	INTO #tt_mpp
	FROM manpowerprofile mp
	WHERE @drv_id in ( 'UNKNOWN', mp.mpp_id) and 
		@drv_type1 in ('UNK', mp.mpp_type1) and 
		@drv_type2 in ('UNK', mp.mpp_type2) and 
		@drv_type3 in ('UNK', mp.mpp_type3) and 
		@drv_type4 in ('UNK', mp.mpp_type4) and 
		@company in ('UNK',mp.mpp_company) and
		@fleet in ('UNK', mp.mpp_fleet) and 
		@division in ( 'UNK', mp.mpp_division) and
		@domicile in ('UNK', mp.mpp_domicile ) and
		@acct_type in ('X', mp.mpp_actg_type)

	CREATE INDEX id
	ON #tt_mpp(mpp_id)

	INSERT into #tt 
	SELECT pd.pyd_unit,
		pd.pyd_pretax, 
		pd.pyd_minus,
		pd.pyt_itemcode, 
		pd.pyd_status, 
		pd.pyd_loadstate,
		ph.pyh_payperiod, 
		pd.pyd_workperiod, 
		sum(round(pd.pyd_amount, 2)), 
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader ph, paydetail pd, #tt_mpp
	WHERE (ph.asgn_type = 'DRV' ) AND  
		( ph.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
		( pd.pyh_number = ph.pyh_pyhnumber ) AND 
		( ph.asgn_id = #tt_mpp.mpp_id )
	GROUP BY pd.pyd_unit,

		pd.pyd_pretax,
		pd.pyd_minus,
		pd.pyt_itemcode,
		pd.pyd_loadstate,
		pd.pyd_status,
		pd.pyd_workperiod,
		ph.pyh_payperiod


	INSERT INTO #tt
	SELECT 
		pd.pyd_unit,
		pd.pyd_pretax, 
		pd.pyd_minus,
		pd.pyt_itemcode, 
		'HLD',
		pd.pyd_loadstate,
		ph.pyh_payperiod, 
		pd.pyd_workperiod, 
		sum(round(pd.pyd_amount, 2)),
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader ph, paydetail pd, #tt_mpp
	WHERE (pd.asgn_type = 'DRV' ) AND
			/*  This will only work for whatever is on hold when */
			/*  this report is run.  Next two lines fix that, */
			/*  if all drivers are colledted before run this report */
			/*( paydetail.pyh_payperiod > @payperiodend ) AND */
			/*( paydetail.pyd_workperiod <= @payperiodend ) AND  */
			/*  Replace these two lines with above two lines */
		( ph.pyh_payperiod > @payperiodend ) AND
		( pd.pyh_number = ph.pyh_pyhnumber ) AND
		( pd.pyd_status = 'HLD' ) AND 
			/* end replace */
		( pd.asgn_id = #tt_mpp.mpp_id )
	GROUP BY pd.pyd_unit,
		pd.pyd_pretax,
		pd.pyd_minus,
		pd.pyt_itemcode,
		pd.pyd_loadstate,
		pd.pyd_status,
		pd.pyd_workperiod,
		ph.pyh_payperiod

END 


/* LOAD DATA INTO TABLE FOR TRC */
if (@trc_yes <> 'XXX') 
BEGIN

	/* MAKE TEMPTABLE FOR TRACTORS THAT MATCH RESTRICTION SET */
	SELECT tp.trc_number
	INTO #tt_trc
	FROM tractorprofile tp
	WHERE @trc_id in ( 'UNKNOWN', tp.trc_number) and 
		@trc_type1 in ('UNK', tp.trc_type1) and 
		@trc_type2 in ('UNK', tp.trc_type2) and 
		@trc_type3 in ('UNK', tp.trc_type3) and 
		@trc_type4 in ('UNK', tp.trc_type4) and 
		@company in ('UNK', tp.trc_company) and
		@fleet in ('UNK', tp.trc_fleet) and 
		@division in ( 'UNK', tp.trc_division) and
		@domicile in ('UNK', tp.trc_terminal ) and
		@acct_type in ('X', tp.trc_actg_type) 

	CREATE INDEX id
	ON #tt_trc(trc_number)

	INSERT into #tt 
	SELECT pd.pyd_unit,
		pd.pyd_pretax, 
		pd.pyd_minus,
		pd.pyt_itemcode, 
		pd.pyd_status, 
		pd.pyd_loadstate,
		ph.pyh_payperiod, 
		pd.pyd_workperiod, 
		round(pd.pyd_amount, 2),
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader ph, paydetail pd, #tt_trc
	WHERE (ph.asgn_type = 'TRC' ) AND  
		( ph.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
		( pd.pyh_number = ph.pyh_pyhnumber ) AND
		( ph.asgn_id = #tt_trc.trc_number )

	INSERT INTO #tt
	SELECT 	pd.pyd_unit,
		pd.pyd_pretax, 
		pd.pyd_minus,
		pd.pyt_itemcode, 
		'HLD',
		pd.pyd_loadstate,
		ph.pyh_payperiod, 
		pd.pyd_workperiod, 
		round(pd.pyd_amount, 2),
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader ph, paydetail pd, #tt_trc
	WHERE ( pd.asgn_type = 'TRC' ) AND
		( ph.pyh_payperiod > @payperiodend ) AND 
		( pd.pyh_number = ph.pyh_pyhnumber ) AND
		( pd.pyd_status = 'HLD' ) AND 
		( pd.asgn_id = #tt_trc.trc_number )
END

/* LOAD DATA INTO TABLE FOR CAR */
if (@car_yes <> 'XXX') 
BEGIN

	/* GET INTO TEMPTABLE FOR CARRIERS THAT MATCH RESTRICTION SET */
	SELECT cp.car_id
	INTO #tt_car
	FROM carrier cp 
	WHERE @car_id in ( 'UNKNOWN', cp.car_id) and 
		@car_type1 in ('UNK', cp.car_type1) and 
		@car_type2 in ('UNK', cp.car_type2) and 
		@car_type3 in ('UNK', cp.car_type3) and 
		@car_type4 in ('UNK', cp.car_type4) and 
		@acct_type in ('X', cp.car_actg_type) 

	CREATE INDEX id
	ON #tt_car(car_id)

	INSERT into #tt 
	SELECT pd.pyd_unit,
		pd.pyd_pretax, 
		pd.pyd_minus,
		pd.pyt_itemcode, 
		pd.pyd_status, 
		pd.pyd_loadstate,
		ph.pyh_payperiod, 
		pd.pyd_workperiod, 
		round(pd.pyd_amount, 2 ),
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader ph, paydetail pd, #tt_car
	WHERE ( ph.asgn_type = 'CAR' ) AND  
		( ph.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
		( pd.pyh_number = ph.pyh_pyhnumber ) AND
		( ph.asgn_id = #tt_car.car_id )

	INSERT INTO #tt
	SELECT 
		pd.pyd_unit,
		pd.pyd_pretax, 
		pd.pyd_minus,
		pd.pyt_itemcode, 
		'HLD',
		pd.pyd_loadstate,
		ph.pyh_payperiod, 
		pd.pyd_workperiod, 
		round(pd.pyd_amount, 2),
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader ph, paydetail pd, #tt_car
	WHERE ( pd.asgn_type = 'CAR' ) AND  /*  This will only work for whatever is on hold when */
		( pd.pyh_payperiod > @payperiodend ) AND 
		( pd.pyh_number = ph.pyh_pyhnumber ) AND
		( pd.pyd_status = 'HLD' ) AND 
		( pd.asgn_id = #tt_car.car_id )
END

/* LOAD DATA INTO TABLE FOR Thirdparty */
if (@tpr_yes <> 'XXX') 
BEGIN

	/* GET INTO TEMPTABLE FOR Thirdparty THAT MATCH RESTRICTION SET */
	SELECT tpr_id
	INTO #tt_tpr
	FROM thirdpartyprofile
	WHERE ((@tpr_id = tpr_id and @tpr_id not in ('UNKNOWN')) OR
		(@tpr_id = 'UNKNOWN' and
			(tpr_thirdpartytype1 = @tpr_yes1 or tpr_thirdpartytype1 is null) and
			(tpr_thirdpartytype2 = @tpr_yes2 or tpr_thirdpartytype2 is null) and
			(tpr_thirdpartytype3 = @tpr_yes3 or tpr_thirdpartytype3 is null) and
			(tpr_thirdpartytype4 = @tpr_yes4 or tpr_thirdpartytype4 is null) and
			(tpr_thirdpartytype5 = @tpr_yes5 or tpr_thirdpartytype5 is null) and
			(tpr_thirdpartytype6 = @tpr_yes6 or tpr_thirdpartytype6  is null))) and
		@acct_type in ('X', tpr_actg_type)
	CREATE INDEX id
	ON #tt_tpr(tpr_id)

	INSERT into #tt 
	SELECT pd.pyd_unit,
		pd.pyd_pretax, 
		pd.pyd_minus,
		pd.pyt_itemcode, 
		pd.pyd_status, 
		pd.pyd_loadstate,
		ph.pyh_payperiod, 
		pd.pyd_workperiod, 
		round(pd.pyd_amount, 2 ),
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader ph, paydetail pd, #tt_tpr
	WHERE ( ph.asgn_type = 'TPR' ) AND  
		( ph.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
		( pd.pyh_number = ph.pyh_pyhnumber ) AND
		( ph.asgn_id = #tt_tpr.tpr_id )


	INSERT INTO #tt
	SELECT 
		pd.pyd_unit,
		pd.pyd_pretax, 
		pd.pyd_minus,
		pd.pyt_itemcode, 
		'HLD',
		pd.pyd_loadstate,
		ph.pyh_payperiod, 
		pd.pyd_workperiod, 
		round(pd.pyd_amount, 2),
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader ph, paydetail pd, #tt_tpr
	WHERE ( pd.asgn_type = 'TPR' ) AND  
		( pd.pyh_payperiod > @payperiodend ) AND 
		( pd.pyh_number = ph.pyh_pyhnumber ) AND
		( pd.pyd_status = 'HLD' ) AND 
		( pd.asgn_id = #tt_tpr.tpr_id )
END

UPDATE #tt
SET pyd_unit = 'OTHER'
WHERE pyd_unit <> 'MIL'

UPDATE #tt
SET pyd_loadstate = 'NA'
WHERE pyd_loadstate IS null

SELECT pyd_unit,
	pyd_pretax, 
	pyd_minus,
	pyt_itemcode, 
	pyd_status,
	pyd_loadstate,
	pyh_payperiod, 
	pyd_workperiod, 
	SUM(round(pyd_amount, 2)),
	@payperiodstart,
	@payperiodend
FROM #tt
GROUP BY pyd_unit,
	pyd_pretax,
	pyd_minus,
	pyt_itemcode,
	pyd_loadstate,
	pyd_status,
	pyd_workperiod,
	pyh_payperiod

RETURN
 
GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_sum_sum_tpr] TO [public]
GO
