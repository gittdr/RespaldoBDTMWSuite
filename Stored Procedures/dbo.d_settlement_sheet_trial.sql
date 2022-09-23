SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_settlement_sheet_trial] (@payperiodstart datetime,
		@payperiodend   datetime,
		@drv_yes        varchar(3),
		@trc_yes        varchar(3),
		@trl_yes        varchar(3),
		@drv_id         varchar(8),
		@trc_id         varchar(8),
		@trl_id         varchar(13),
		@drv_type1      varchar(6),
		@trc_type1      varchar(6),
		@trl_type1      varchar(6),
		@terminal       varchar(8),
		@name	varchar(64),
		@car_yes	varchar(3),
		@car_id	varchar(8),
		@car_type1	varchar(6) )

as 
/**
 * 
 * NAME:
 * dbo.d_settlement_sheet_trial    
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

declare 	@type6		varchar(6), 
			@lgh_number	int,
			@dummydate	datetime,
			@stdbalance money,
			@itemsect	int,
			@dummymon money,
			@dummystr varchar(20)

/* CREATE TABLE */

CREATE TABLE #tt
(pyd_number int not null, 
pyh_number int not null, 
asgn_number int not null, 
asgn_type varchar(6) not null, 
asgn_id varchar (13) not null, 
ivd_number int null, 
pyd_prorap varchar (6) null, 
pyd_payto varchar (6) null, 
pyt_itemcode varchar (6) null, 
pyd_description varchar (30) null, 
pyr_ratecode varchar (6) null, 
pyd_quantity float null, 
pyd_rateunit varchar (6) null, 
pyd_unit varchar (6) null, 
pyd_pretax char (1) null, 
pyd_status varchar (6) null, 
pyh_payperiod datetime null, 
lgh_startcity int null,
lgh_endcity int null, 
pyd_minus int null,
pyd_workperiod datetime null, 
pyd_sequence int null, 
pyd_rate money null, 
pyd_amount money null, 
pyd_payrevenue money null, 
mov_number int null,
lgh_number int null, 
ord_hdrnumber int null ,
pyd_transdate datetime null,
payperiodstart datetime null,
payperiodend datetime null,
pyd_loadstate varchar (6) null,
summary_code varchar (6) null,
name  varchar (64) null,   
terminal varchar (6) null,
type1 varchar (6) null,
totalcomp money null,
totaldeduct money null,
totalreimbrs money null,
cardnumber char (10) null,
lgh_startdate datetime null,
std_balance money null,
itemsection int null,
ord_startdate datetime null,
ord_number char (8) null )


/* LOAD DATA INTO TABLE FOR DRV, TRC, and TRL */
if (@drv_yes <> 'XXX') 
begin
insert into #tt 

SELECT 	paydetail.pyd_number, 
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
round ( paydetail.pyd_amount, 2 ),
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
@terminal,
@drv_type1,
0.0,
0.0,
0.0,
null,
legheader.lgh_startdate,
0,
0,
orderheader.ord_startdate,
orderheader.ord_number
--pts40186 jguo outer join conversion
FROM legheader  RIGHT OUTER JOIN  paydetail  ON  legheader.lgh_number  = paydetail.lgh_number   
		LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber  
WHERE ( paydetail.asgn_type = 'DRV' ) AND  
( paydetail.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
@drv_id = paydetail.asgn_id 

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
round ( paydetail.pyd_amount, 2 ),
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
@terminal,
@drv_type1,
0.0,
0.0,
0.0,
null,
legheader.lgh_startdate,
0,
0,
orderheader.ord_startdate,
orderheader.ord_number 
FROM  paydetail  LEFT OUTER JOIN  legheader  ON  paydetail.lgh_number  = legheader.lgh_number   
	LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber  
WHERE ( paydetail.asgn_type = 'DRV' ) AND  
( paydetail.pyh_payperiod > @payperiodend ) AND  
( paydetail.pyd_workperiod <= @payperiodstart OR paydetail.pyd_workperiod >= '20491231' ) AND  
paydetail.asgn_id = @drv_id
 
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
round ( paydetail.pyd_amount, 2 ),
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
@terminal,
@trc_type1,
0.0,
0.0,
0.0,
null,
legheader.lgh_startdate,
0,
0,
orderheader.ord_startdate,
orderheader.ord_number
FROM  orderheader  RIGHT OUTER JOIN  paydetail  ON  orderheader.ord_hdrnumber  = paydetail.ord_hdrnumber   
	LEFT OUTER JOIN  legheader  ON  legheader.lgh_number  = paydetail.lgh_number  
WHERE ( paydetail.asgn_type = 'TRC' ) AND  
( paydetail.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
( @trc_id = paydetail.asgn_id ) 

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
round ( paydetail.pyd_amount, 2 ),
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
@terminal,
@trc_type1,
0.0,
0.0,
0.0,
null,
legheader.lgh_startdate,
standingdeduction.std_balance,
0,
orderheader.ord_startdate,
orderheader.ord_number
FROM standingdeduction  RIGHT OUTER JOIN  paydetail  ON  standingdeduction.std_number  = paydetail.std_number   
		LEFT OUTER JOIN  legheader  ON  paydetail.lgh_number  = legheader.lgh_number   
		LEFT OUTER JOIN  orderheader  ON  orderheader.ord_hdrnumber  = paydetail.ord_hdrnumber  
WHERE ( paydetail.asgn_type = 'TRC' ) AND  
( paydetail.pyh_payperiod > @payperiodend ) AND  
( paydetail.pyd_workperiod <= @payperiodstart OR paydetail.pyd_workperiod >= '20491231' ) AND  
paydetail.asgn_id = @trc_id
END


/* TRAILERS NOT SUPORTED AT THIS TIME 06-09-94 */

if (@car_yes <> 'XXX') 
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
round ( paydetail.pyd_amount, 2 ),
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
@terminal,
@car_type1,
0.0,
0.0,
0.0,
null,
legheader.lgh_startdate,
0,
0,
orderheader.ord_startdate,
orderheader.ord_number
FROM  orderheader  RIGHT OUTER JOIN  paydetail  ON  orderheader.ord_hdrnumber  = paydetail.ord_hdrnumber   
		LEFT OUTER JOIN  legheader  ON  legheader.lgh_number  = paydetail.lgh_number  
WHERE ( paydetail.asgn_type = 'CAR' ) AND  
( paydetail.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
( @car_id = paydetail.asgn_id ) 

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
round ( paydetail.pyd_amount, 2 ),
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
@terminal,
@car_type1,
0.0,
0.0,
0.0,
null,
legheader.lgh_startdate,
standingdeduction.std_balance,
0,
orderheader.ord_startdate,
orderheader.ord_number
FROM  standingdeduction  RIGHT OUTER JOIN  paydetail  ON  standingdeduction.std_number  = paydetail.std_number   
		LEFT OUTER JOIN  legheader  ON  paydetail.lgh_number  = legheader.lgh_number   
		LEFT OUTER JOIN  orderheader  ON  orderheader.ord_hdrnumber  = paydetail.ord_hdrnumber  
WHERE ( paydetail.asgn_type = 'CAR' ) AND  
( paydetail.pyh_payperiod > @payperiodend ) AND  
( paydetail.pyd_workperiod <= @payperiodstart OR paydetail.pyd_workperiod >= '20491231' ) AND  
paydetail.asgn_id = @car_id
END

UPDATE #tt
set summary_code = 'OTHER'
where summary_code <> 'MIL'

UPDATE #tt
SET pyd_loadstate = 'NA'
WHERE pyd_loadstate IS null

/*Determine what section each item belongs in*/
update #tt
set itemsection = 2
where pyd_pretax = 'N' and
		pyd_minus = 1

update #tt
set itemsection = 3
where pyd_pretax = 'N' and
		pyd_minus = -1

update #tt
set itemsection = 4
where pyt_itemcode = 'MN+' OR
		pyt_itemcode = 'MN-' 


SELECT 
pyd_number, 
pyh_number, 
asgn_number, 
asgn_type, 
asgn_id, 
ivd_number, 
pyd_prorap, 
pyd_payto, 
pyt_itemcode, 
pyd_description, 
pyr_ratecode, 
pyd_quantity, 
pyd_rateunit, 
pyd_unit, 
pyd_pretax, 
pyd_status, 
pyh_payperiod, 
lgh_startcity,
lgh_endcity, 
pyd_minus,
pyd_workperiod, 

pyd_sequence, 
pyd_rate, 

round ( pyd_amount, 2 ),
pyd_payrevenue, 
mov_number,
lgh_number, 
ord_hdrnumber ,
pyd_transdate,
payperiodstart,
payperiodend,
pyd_loadstate,
summary_code,
name,   
terminal,
type1,
round ( totalcomp, 2 ),
round ( totaldeduct, 2 ),
round ( totalreimbrs, 2 ),
cardnumber,
lgh_startdate,
std_balance,
itemsection,
ord_startdate,
ord_number 
from #tt 

RETURN 


GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_trial] TO [public]
GO
