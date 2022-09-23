SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[d_ebe_report_sp] (@drv_id varchar(8), @type1 varchar(6), @type2 varchar(6), 
                             @type3 varchar(6), @type4 varchar(6), @company varchar(6), 
                             @fleet varchar(6), @division varchar(6), @terminal varchar(6), 
                             @payperiodstart datetime, @payperiodend datetime)
as
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
SET NOCOUNT ON
set ansi_nulls on
set ansi_warnings on

select @payperiodend = convert(datetime, convert(varchar(10), @payperiodend, 101) + ' 23:59')
declare @gross money , @reimb money
declare @sql nvarchar(900)
declare @gpserver varchar(50) ,@gpdb varchar(12)
declare @chekdatedefault varchar(8)

-- Create a temp table to the pay header and detail numbers
create table #temp_pay
  (stl_number      int            not null,    -- settlement number
   stl_payperiod   datetime       null,        -- pay period date
   stl_asgn_type   varchar(6)     null,        -- asset type (?DRV?, ?TRC?) 
   stl_asgn_id     varchar(13)    null,        -- asset ID (driver ID or tractor number)
   stl_payto       varchar(12)    null,        -- payto ID (null string if UNKNOWN)
   stl_name        varchar(255)   null,        -- manpowerprofile,mpp_lastfirst/payto.pto_lastfirst/payto.pto_companyname
   stl_terminal    varchar(50)    null,        -- manpowerprofile.mpp_terminal/tractorprofile.trc_terminal
   stl_cardnumber  varchar(25)    null,        -- issued on card number
   stl_grouping    varchar(20)    null,        -- pay code grouping (earnings, reimbursements, deductions)
                                               -- earings (pretax = Y and minus = +), reimbursements (pretax = N and minus = +), 
                                               -- and deductions (pretax = N and minus = -)
   stl_ordnumber   varchar(12)    null,        -- order number
   stl_orddate     datetime       null,        -- pickup date orderheader.ord_startdate (use pyd_transdate for non-order paydetails or fuel codes) 
   stl_description varchar(255)   null,        -- paydetail.pyd_description(start and end point for route pay), fuel description and pyt_item desctiption
   stl_quantity    decimal(12, 4) null,	       -- paydetail.pyd_quantity
   stl_mt_miles    decimal(8, 1)  null,        -- paydetail.pyd_quantity (where type is mileage and load state is MT/UNLD)
   stl_ld_miles    decimal(8, 1)  null,        -- paydetail.pyd_quantity (where type is mileage and load state is LD)
   stl_rate        decimal(9, 4)  null,        -- paydetail.pyd_rate
   stl_fee1        money          null,        -- paydetail.pyt_fee1
   stl_fee2        money          null,        -- paydetail.pyt_fee2
   stl_amount      money          null,        -- (less fees) paydetail.pyd_amount
   stl_status      varchar(25)    null,        -- paydetail.pyd_status (closed if header is closed else on hold)
   stl_dedbal      money          null,        -- standing deduction balance
                                               -- std_balance (from standing deduction where std_number > 0 else NULL)
   stl_grptotal    money          null,        -- group total (earnings, reimbursements, or deductions)
                                               -- payheader.pyh_totalcomp/payheader.pyh_totalreimbrs/payheader.pyt_totaldeduct
   stl_netb3tax    money          null,        -- net earnings before taxes and benefits (earnings + reimbursements + deductions)
   stl_avgqtlmil   money          null, 
   stl_avgqtdweeks int            null,
   stl_terminationdate datetime   null,		   -- manpowerprofile/tractorprofile termination date
   stl_terminalcode varchar(6)    null,		   -- manpowerprofile.mpp_terminal/tractorprofile.trc_terminal	code
   stl_prev_overdraft money		  null,		   -- prior overdraft identical to the pay macro value
   stl_curr_overdraft money		  null,		   -- current overdraft amount identical to pay macro value	
   stl_grossminusreimb money	  null,		   -- Gross pay minus reimbursements	
   stl_pyt_itemcode varchar(8)    null,         -- Paytype itemcode paydetail.pyt_itemcode
   stl_totalreimb	money		  null,			-- total reimb from the payheader
   stl_pyt_description varchar(30) null 		-- Description of the paytype
)

create index temp_pay_asgn_id on #temp_pay(stl_asgn_id)
create index temp_pay_stl_number on #temp_pay(stl_number)
insert into #temp_pay (stl_number, stl_payperiod, stl_asgn_type, stl_asgn_id, stl_payto, stl_name, 
                       stl_terminal, stl_cardnumber, stl_grouping, stl_ordnumber, stl_orddate, stl_description, 
                       stl_quantity, stl_mt_miles, stl_ld_miles, stl_rate, stl_fee1, stl_fee2, 
                       stl_amount, stl_status, stl_dedbal, stl_grptotal, stl_netb3tax,stl_pyt_itemcode,stl_totalreimb,stl_pyt_description) 
select payheader.pyh_pyhnumber, 
       payheader.pyh_payperiod, 
       payheader.asgn_type, 
       payheader.asgn_id, 
       case when payheader.pyh_payto = 'UNKNOWN' then '' else payheader.pyh_payto end, 
       case when payheader.pyh_payto = 'UNKNOWN' then manpowerprofile.mpp_lastfirst 
            when len(payto.pto_companyname) > 0 then payto.pto_companyname 
            when len(payto.pto_lastfirst) > 0 then payto.pto_lastfirst else '' end, 
       case when manpowerprofile.mpp_terminal = 'UNK' then '' 
            else (select labelfile.name from labelfile where labelfile.abbr = manpowerprofile.mpp_terminal and labelfile.labeldefinition = 'Terminal') end, 
       isnull(payheader.crd_cardnumber, ''), 
       case when isnull(paydetail.std_number_adj, 0) <> 0 then '4 - standing ded adj'
            when paydetail.pyd_pretax = 'N' and paydetail.pyd_minus = 1 then '2 - reimbursements' 
            when paydetail.pyd_pretax = 'N' and paydetail.pyd_minus = -1 then '3 - deductions' 
            else '1 - earnings' end, 
       isnull(orderheader.ord_number, ''), 
       case when paydetail.ord_hdrnumber = 0 then paydetail.pyd_transdate 
            when paytype.pyt_fservprocess in ('A', 'C', 'T', 'U') then paydetail.pyd_transdate 
            when paydetail.ord_hdrnumber > 0 then orderheader.ord_startdate 
            else paydetail.pyd_transdate end, 
       case when paytype.pyt_basis = 'LGH' then  ((select city.cty_name + ', ' + city.cty_state from city
                                                   where city.cty_code = paydetail.lgh_startcity) + ' / ' + 
                                                 (select city.cty_name + ', ' + city.cty_state from city
                                                   where city.cty_code = paydetail.lgh_endcity)) 
            when paytype.pyt_fservprocess in ('A', 'C', 'T', 'U') then paydetail.pyd_description 
            else paytype.pyt_description end, 
       case when paydetail.pyd_rateunit = 'MIL' then NULL else paydetail.pyd_quantity end, 
       case when paydetail.pyd_rateunit = 'MIL' and paydetail.pyd_loadstate in ('MT', 'UNLD') then paydetail.pyd_quantity else 0 end, 
       case when paydetail.pyd_rateunit = 'MIL' and paydetail.pyd_loadstate <> 'MT' and paydetail.pyd_loadstate <> 'UNLD' then paydetail.pyd_quantity else 0 end, 
       paydetail.pyd_rate, 
       isnull(paydetail.pyt_fee1, 0), 
       isnull(paydetail.pyt_fee2, 0), 
       paydetail.pyd_amount, 
       paydetail.pyd_status, 
       isnull((select std_balance from standingdeduction where standingdeduction.std_number = paydetail.std_number), 0), 
       case when paydetail.pyd_pretax = 'N' and paydetail.pyd_minus = -1 and isnull(paydetail.std_number_adj, 0) = 0 then isnull(payheader.pyh_totaldeduct, 0) 
            when paydetail.pyd_pretax = 'N' and paydetail.pyd_minus = 1 and isnull(paydetail.std_number_adj, 0) = 0 then isnull(payheader.pyh_totalreimbrs, 0) 
            when paydetail.pyd_pretax = 'Y' and isnull(paydetail.std_number_adj, 0) = 0 then isnull(payheader.pyh_totalcomp, 0) else 0 end,
       isnull(payheader.pyh_totalcomp, 0) + isnull(payheader.pyh_totaldeduct, 0) + isnull(payheader.pyh_totalreimbrs, 0) ,
	   paydetail.pyt_itemcode,
	   isnull(payheader.pyh_totalreimbrs, 0),	
	paytype.pyt_description
  from payheader, 
       paytype, 
       manpowerprofile, 
       payto, 
       orderheader RIGHT OUTER JOIN  paydetail ON orderheader.ord_hdrnumber = paydetail.ord_hdrnumber  --pts40462 outer join conversion
 where payheader.asgn_type = 'DRV' 
   and payheader.pyh_paystatus in ('REL', 'XFR') 
   and (payheader.asgn_id = @drv_id or @drv_id = 'UNKNOWN') 
   and paydetail.pyh_number = payheader.pyh_pyhnumber 
   and manpowerprofile.mpp_id = payheader.asgn_id 
   and payto.pto_id = payheader.pyh_payto 
   and paytype.pyt_itemcode = paydetail.pyt_itemcode 
   --and orderheader.ord_hdrnumber =* paydetail.ord_hdrnumber 
   and (manpowerprofile.mpp_type1 = @type1 or @type1 = 'UNK') 
   and (manpowerprofile.mpp_type2 = @type2 or @type2 = 'UNK') 
   and (manpowerprofile.mpp_type3 = @type3 or @type3 = 'UNK') 
   and (manpowerprofile.mpp_type4 = @type4 or @type4 = 'UNK') 
   and (manpowerprofile.mpp_company = @company or @company = 'UNK') 
   and (manpowerprofile.mpp_fleet = @fleet or @fleet = 'UNK') 
   and (manpowerprofile.mpp_division = @division or @division = 'UNK') 
   and (manpowerprofile.mpp_terminal = @terminal or @terminal = 'UNK') 
   and payheader.pyh_payperiod between @payperiodstart and @payperiodend 
   and (paydetail.tar_tarriffnumber <> '-1' or paydetail.tar_tarriffnumber is null)


-- update avg qtd miles

update #temp_pay 
   set stl_avgqtlmil = (select sum(paydetail.pyd_quantity) 
                          from paytype,
                               paydetail,
							   manpowerprofile
                         where paydetail.asgn_type = 'DRV' 
                           and paydetail.asgn_type = #temp_pay.stl_asgn_type 
                           and paydetail.asgn_id = #temp_pay.stl_asgn_id 
                           and paydetail.asgn_id = manpowerprofile.mpp_id 
                           and paytype.pyt_itemcode = paydetail.pyt_itemcode 
                           and paytype.pyt_basisunit = 'DIS' 
                           and paydetail.pyh_payperiod between mpp_90daystart and @payperiodend)

-- update avg qtd weeks

update #temp_pay 
   set stl_avgqtdweeks = datediff(ww, mpp_90daystart, @payperiodend)
  from manpowerprofile 
 where #temp_pay.stl_asgn_type = 'DRV' 
   and #temp_pay.stl_asgn_id = manpowerprofile.mpp_id 


-- update new computed fields
update #temp_pay 
	set stl_avgqtlmil = isnull(stl_avgqtlmil, 0)/(case when stl_avgqtdweeks is null or stl_avgqtdweeks = 0 then 1 else stl_avgqtdweeks end)


--select @gross = min(stl_grptotal) from #temp_pay where stl_grouping = '1 - earnings'
--select @reimb = min(stl_grptotal) from #temp_pay where stl_grouping = '2 - reimbursements'
--select @gross = IsNull(@gross,0)
--select @reimb = IsNull(@reimb,0)

update a
set	 stl_grossminusreimb =IsNull(( select IsNull(min(stl_grptotal),0) from #temp_pay b where a.stl_asgn_id = b.stl_asgn_id and b.stl_grouping = '1 - earnings') - 
						  ( select IsNull(min(stl_grptotal),0) from #temp_pay c where a.stl_asgn_id = c.stl_asgn_id and c.stl_grouping = '2 - reimbursements'),0)

from #temp_pay a


update #temp_pay set   stl_terminalcode =  case when manpowerprofile.mpp_terminal = 'UNK' then '' else manpowerprofile.mpp_terminal end,
stl_terminationdate =  mpp_terminationdt
from manpowerprofile where stl_asgn_type = 'DRV' and stl_asgn_id = manpowerprofile.mpp_id

--update #temp_pay set   stl_terminalcode =  case when tractorprofile.trc_terminal = 'UNK' then '' else tractorprofile.trc_terminal end,
--stl_terminationdate = trc_retiredate
--from tractorprofile where stl_asgn_type = 'TRC' and stl_asgn_id = tractorprofile.trc_number

select @gpserver = server_name,@gpdb = dbname from gpdefaults
/* commented out  JD 091905 prev overdraft not needed.
select @chekdatedefault = '19000101'
select @sql = 'update #temp_pay set stl_prev_overdraft = (' +
				'SELECT	SUM(a.DA_ARREARS_AMOUNT)' +		
				  'FROM	'+ @gpserver + '.'+ @gpdb+ '.dbo.'+'APR_DIA30100  a' +
				 ' WHERE a.EMPLOYID = #temp_pay.stl_asgn_id AND '+
					' a.CHEKDATE >= (SELECT	ISNULL(MAX(b.CHEKDATE),'''+ @chekdatedefault +''')' +
						' FROM '	+ @gpserver + '.'+ @gpdb+ '.dbo.'+'UPR30100 b' +
						' WHERE	b.CHEKDATE < '''+ convert(varchar(8) ,@payperiodend,112) + ''' AND '+
						' b.EMPLOYID = a.EMPLOYID) ) '


--select @sql
--select datalength(@sql)
EXEC sp_executesql @sql
*/
select @sql = 'update #temp_pay set stl_curr_overdraft = (' +
				'SELECT	SUM(a.DA_ARREARS_AMOUNT)' +		
				  'FROM	'+ @gpserver + '.'+ @gpdb+ '.dbo.'+'APR_DIA20100  a' +
				 ' WHERE a.EMPLOYID = #temp_pay.stl_asgn_id )'


EXEC sp_executesql @sql


select @sql = 'insert into #temp_pay(stl_number,stl_description, stl_amount,stl_asgn_id) select  0,DEDUCTON, sum(DA_Arrears_Amount), EMPLOYID ' +
				  'FROM	'+ @gpserver + '.'+ @gpdb+ '.dbo.'+'APR_DIA20100  a' + 	' WHERE exists (select * from #temp_pay b where b.stl_asgn_id = a.EMPLOYID) GROUP BY DEDUCTON, EMPLOYID '


--select @sql
EXEC sp_executesql @sql


select @sql = 'update #temp_pay set stl_description = a.dscriptn ' +
				  'FROM	'+ @gpserver + '.'+ @gpdb+ '.dbo.'+'UPR40900  a' +
				 ' WHERE #temp_pay.stl_description = a.DEDUCTON and #temp_pay.stl_number = 0'


EXEC sp_executesql @sql

update #temp_pay set stl_grouping = '5 - GPDEDUCTIONS' where stl_grouping is null
update #temp_pay set stl_asgn_type = 'DRV' where stl_asgn_type is null
update #temp_pay set stl_name = mpp_lastfirst from manpowerprofile where stl_Asgn_id = mpp_id and stl_name is null
update a set stl_number = (select min(stl_number) from #temp_pay b where a.stl_asgn_type = b.stl_asgn_type and a.stl_asgn_id = b.stl_asgn_id and b.stl_number > 0 )
from #temp_pay a where a.stl_number = 0

update a set stl_payperiod = (select min(stl_payperiod) from #temp_pay b where a.stl_asgn_type = b.stl_asgn_type and a.stl_asgn_id = b.stl_asgn_id and b.stl_payperiod is not null )
from #temp_pay a where a.stl_payperiod  is null 


update #temp_pay set stl_prev_overdraft = 0 where stl_prev_overdraft is null

update #temp_pay set stl_curr_overdraft = 0 where stl_curr_overdraft is null

select stl_number, 
       stl_payperiod, 
       stl_asgn_type, 
       stl_asgn_id, 
       stl_payto, 
       stl_name, 
       stl_terminal, 
       stl_cardnumber, 
       stl_grouping, 
       stl_ordnumber, 
       stl_orddate, 
       stl_description, 
       stl_quantity, 
       stl_mt_miles, 
       stl_ld_miles, 
       stl_rate, 
       stl_fee1, 
       stl_fee2, 
       stl_amount, 
       stl_status, 
       stl_dedbal, 
       stl_grptotal, 
       stl_netb3tax, 
--       round(isnull(stl_avgqtlmil, 0)/(case when stl_avgqtdweeks is null or stl_avgqtdweeks = 0 then 1 else stl_avgqtdweeks end), 2) stl_avg_qtd_miles 
	   round(isnull(stl_avgqtlmil,0),2) stl_avg_qtd_miles,
	   round(29900 - isnull(stl_avgqtlmil,0),2) stl_avg_qtd_miles_to_qualify,
	   stl_terminationdate ,
	   stl_terminalcode ,
	   stl_prev_overdraft,
	   stl_curr_overdraft,
	   stl_grossminusreimb ,
	   stl_pyt_itemcode,
	   stl_totalreimb,
	   stl_pyt_description
  from #temp_pay 
 order by stl_asgn_type, stl_asgn_id, stl_grouping, stl_ordnumber, stl_orddate, stl_description

GO
GRANT EXECUTE ON  [dbo].[d_ebe_report_sp] TO [public]
GO
