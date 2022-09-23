SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_settlement_sheet_summary2    Script Date: 8/20/97 1:58:17 PM ******/
create proc [dbo].[d_settlement_sheet_summary2](
@payperiodstart datetime,
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
@acct_type      char(1) )

as 
/**
 * 
 * NAME:
 * dbo.d_settlement_sheet_summary2
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
 * 11/02/2007.01 ? PTS40116 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

declare 	@name 		varchar(50),
@type6		varchar(6), 
@lgh_number	int,
@dummydate	datetime


/* CREATE TABLE */
SELECT 		paydetail.pyd_number, 
paydetail.pyh_number, 
paydetail.asgn_number, 
paydetail.asgn_type, 
paydetail.asgn_id, 
paydetail.ivd_number, 
paydetail.pyd_prorap, 
paydetail.pyd_payto, 	
paydetail.pyt_itemcode, 
paydetail.pyd_description, 
paydetail.pyr_ratecode, 
paydetail.pyd_quantity, 
paydetail.pyd_rateunit, 
paydetail.pyd_unit, 
paydetail.pyd_pretax, 
paydetail.pyd_status, 
paydetail.pyh_payperiod, 
paydetail.lgh_startcity,
paydetail.lgh_endcity, 
paydetail.pyd_minus,
paydetail.pyd_workperiod, 
paydetail.pyd_sequence, 
paydetail.pyd_rate, 

paydetail.pyd_amount, 
paydetail.pyd_payrevenue, 
legheader.mov_number,
@lgh_number lgh_number, 
paydetail.ord_hdrnumber ,
paydetail.pyd_transdate,
@payperiodstart payperiodstart,
@payperiodend payperiodend,
paydetail.pyd_loadstate,
paydetail.pyd_unit summary_code,
@name name,   
@type6 company,
@type6 fleet,
@type6 division,
@type6 terminal,
payheader.pyh_totalcomp,
payheader.pyh_totaldeduct,
payheader.pyh_totalreimbrs,
payheader.crd_cardnumber,
@dummydate previous_payperiod
INTO #tt   
FROM paydetail, legheader, payheader 
where 1 = 2 


/* LOAD DATA INTO TABLE FOR DRV, TRC, and TRL */
if (@drv_yes <> 'XXX') 
begin
insert into #tt 

SELECT
paydetail.pyd_number, 
paydetail.pyh_number, 
paydetail.asgn_number, 
paydetail.asgn_type, 
paydetail.asgn_id, 
paydetail.ivd_number, 
paydetail.pyd_prorap, 
paydetail.pyd_payto, 
paydetail.pyt_itemcode, 
paydetail.pyd_description, 
paydetail.pyr_ratecode, 
paydetail.pyd_quantity, 
paydetail.pyd_rateunit, 
paydetail.pyd_unit, 
paydetail.pyd_pretax, 	
paydetail.pyd_status, 
paydetail.pyh_payperiod, 
paydetail.lgh_startcity,
paydetail.lgh_endcity, 	
paydetail.pyd_minus,
paydetail.pyd_workperiod, 
paydetail.pyd_sequence, 
paydetail.pyd_rate, 
paydetail.pyd_amount, 
paydetail.pyd_payrevenue, 
legheader.mov_number,
legheader.lgh_number, 
paydetail.ord_hdrnumber ,
paydetail.pyd_transdate,
@payperiodstart payperiodstart,
@payperiodend payperiodend,
paydetail.pyd_loadstate,
paydetail.pyd_unit, 
manpowerprofile.mpp_lastname + ', ' + manpowerprofile.mpp_firstname name,   
manpowerprofile.mpp_company,
manpowerprofile.mpp_fleet,
manpowerprofile.mpp_division,
manpowerprofile.mpp_terminal,
0.0,
0.0,
0.0,
null,
'19500101'

FROM legheader  RIGHT OUTER JOIN  paydetail  ON  legheader.lgh_number  = paydetail.lgh_number ,
	 payheader,
	 manpowerprofile 

WHERE ( payheader.asgn_type = 'DRV' ) AND  
( payheader.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
( paydetail.pyh_number = payheader.pyh_pyhnumber ) AND 
@drv_id in ( 'UNKNOWN', payheader.asgn_id) and 
payheader.asgn_id = manpowerprofile.mpp_id and 
@drv_type1 in ('UNK', manpowerprofile.mpp_type1) and 
@drv_type2 in ('UNK', manpowerprofile.mpp_type2) and 
@drv_type3 in ('UNK', manpowerprofile.mpp_type3) and 
@drv_type4 in ('UNK', manpowerprofile.mpp_type4) and 
@company in ('UNK',manpowerprofile.mpp_company) and
@fleet in ('UNK', manpowerprofile.mpp_fleet) and 
@division in ( 'UNK', manpowerprofile.mpp_division) and
@domicile in ('UNK', manpowerprofile.mpp_domicile ) and
@acct_type in ('X', manpowerprofile.mpp_actg_type)


insert into #tt

SELECT 
paydetail.pyd_number, 
paydetail.pyh_number, 
paydetail.asgn_number, 
paydetail.asgn_type, 
paydetail.asgn_id, 
paydetail.ivd_number, 
paydetail.pyd_prorap, 
paydetail.pyd_payto, 
paydetail.pyt_itemcode, 
paydetail.pyd_description, 
paydetail.pyr_ratecode, 
paydetail.pyd_quantity, 
paydetail.pyd_rateunit, 
paydetail.pyd_unit, 
paydetail.pyd_pretax, 
'HLD', 
paydetail.pyh_payperiod, 
paydetail.lgh_startcity,
paydetail.lgh_endcity, 
paydetail.pyd_minus,
paydetail.pyd_workperiod, 
paydetail.pyd_sequence, 
paydetail.pyd_rate, 
paydetail.pyd_amount, 
paydetail.pyd_payrevenue, 
legheader.mov_number,
legheader.lgh_number, 
paydetail.ord_hdrnumber ,
paydetail.pyd_transdate,
@payperiodstart payperiodstart,
@payperiodend payperiodend,
paydetail.pyd_loadstate,
paydetail.pyd_unit,
manpowerprofile.mpp_lastname + ', ' + manpowerprofile.mpp_firstname name,   
manpowerprofile.mpp_company,
manpowerprofile.mpp_fleet,
manpowerprofile.mpp_division,
manpowerprofile.mpp_terminal,
0.0,
0.0,
0.0,
null,
'19500101'

FROM paydetail  LEFT OUTER JOIN  legheader  ON  paydetail.lgh_number  = legheader.lgh_number, 
	manpowerprofile
WHERE ( paydetail.asgn_type = 'DRV' ) AND  
( paydetail.pyh_payperiod > @payperiodend ) AND  
( paydetail.pyd_workperiod <= @payperiodstart ) AND  
( manpowerprofile.mpp_id = paydetail.asgn_id ) AND 
paydetail.asgn_id in ( SELECT DISTINCT asgn_id from #tt where asgn_type = 'DRV' ) 

END 


if (@trc_yes <> 'XXX') 
begin
insert into #tt

SELECT 
paydetail.pyd_number, 
paydetail.pyh_number, 
paydetail.asgn_number, 
paydetail.asgn_type, 
paydetail.asgn_id, 
paydetail.ivd_number, 
paydetail.pyd_prorap, 
paydetail.pyd_payto, 
paydetail.pyt_itemcode, 
paydetail.pyd_description, 
paydetail.pyr_ratecode, 
paydetail.pyd_quantity, 
paydetail.pyd_rateunit, 
paydetail.pyd_unit, 
paydetail.pyd_pretax, 	
paydetail.pyd_status, 
paydetail.pyh_payperiod, 
paydetail.lgh_startcity,
paydetail.lgh_endcity, 	
paydetail.pyd_minus,
paydetail.pyd_workperiod, 
paydetail.pyd_sequence, 
paydetail.pyd_rate, 
paydetail.pyd_amount, 
paydetail.pyd_payrevenue, 
legheader.mov_number,
legheader.lgh_number, 
paydetail.ord_hdrnumber ,
paydetail.pyd_transdate,
@payperiodstart payperiodstart,
@payperiodend payperiodend,
paydetail.pyd_loadstate,
paydetail.pyd_unit, 
@name,	
t.trc_company,
t.trc_fleet,
t.trc_division,
t.trc_terminal,
0.0,
0.0,
0.0,
null,
'19500101'

FROM legheader  RIGHT OUTER JOIN  paydetail  ON  legheader.lgh_number  = paydetail.lgh_number ,
	 payheader,
	 tractorprofile t 
WHERE ( payheader.asgn_type = 'TRC' ) AND  
( payheader.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
( paydetail.pyh_number = payheader.pyh_pyhnumber ) AND 
@trc_id in ( 'UNKNOWN', payheader.asgn_id) and 
payheader.asgn_id = t.trc_number and 
@trc_type1 in ('UNK', t.trc_type1) and 
@trc_type2 in ('UNK', t.trc_type2) and 
@trc_type3 in ('UNK', t.trc_type3) and 
@trc_type4 in ('UNK', t.trc_type4) and 
@company in ('UNK', t.trc_company) and
@fleet in ('UNK', t.trc_fleet) and 
@division in ( 'UNK', t.trc_division) and
@domicile in ('UNK', t.trc_terminal ) and
@acct_type in ('X', t.trc_actg_type)

insert into #tt

SELECT 
paydetail.pyd_number, 
paydetail.pyh_number, 
paydetail.asgn_number, 
paydetail.asgn_type, 
paydetail.asgn_id, 
paydetail.ivd_number, 
paydetail.pyd_prorap, 
paydetail.pyd_payto, 
paydetail.pyt_itemcode, 
paydetail.pyd_description, 

paydetail.pyr_ratecode, 
paydetail.pyd_quantity, 
paydetail.pyd_rateunit, 
paydetail.pyd_unit, 
paydetail.pyd_pretax, 
'HLD', 
paydetail.pyh_payperiod, 
paydetail.lgh_startcity,
paydetail.lgh_endcity, 
paydetail.pyd_minus,
paydetail.pyd_workperiod, 
paydetail.pyd_sequence, 
paydetail.pyd_rate, 
paydetail.pyd_amount, 
paydetail.pyd_payrevenue, 
legheader.mov_number,
legheader.lgh_number, 
paydetail.ord_hdrnumber ,
paydetail.pyd_transdate,
@payperiodstart payperiodstart,
@payperiodend payperiodend,	
paydetail.pyd_loadstate,	
paydetail.pyd_unit,
@name,
t.trc_company,
t.trc_fleet,
t.trc_division,
t.trc_terminal,
0.0,
0.0,
0.0,
null,
'19500101'

FROM paydetail  LEFT OUTER JOIN  legheader  ON  paydetail.lgh_number  = legheader.lgh_number, 
	tractorprofile t
WHERE ( paydetail.asgn_type = 'TRC' ) AND  
( paydetail.pyh_payperiod > @payperiodend ) AND  
( paydetail.pyd_workperiod <= @payperiodstart ) AND  
( paydetail.asgn_id = t.trc_number ) AND 
paydetail.asgn_id in ( SELECT DISTINCT asgn_id from #tt where asgn_type = 'TRC' ) 
END


CREATE INDEX idx1 ON #tt (asgn_id, asgn_type )



SELECT
DISTINCT 
pyd_pretax, 
pyd_minus,
pyt_itemcode, 	
sum(pyd_amount )



from #tt
group by	pyd_pretax, 	pyd_minus,pyt_itemcode
ORDER BY pyd_pretax, 	pyd_minus,pyt_itemcode


/*pyd_status, 
pyh_payperiod, 
pyd_status, 
pyh_payperiod, 
pyd_transdate*/
return





GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_summary2] TO [public]
GO
