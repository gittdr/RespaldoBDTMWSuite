SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create  proc [dbo].[d_ebe_report_tractor_sp] (@trc_id varchar(8), @type1 varchar(6), @type2 varchar(6), 
                             @type3 varchar(6), @type4 varchar(6), @company varchar(6), 
                             @fleet varchar(6), @division varchar(6), @terminal varchar(6), 
                             @payperiodstart datetime, @payperiodend datetime)
as

/**
 * 
 * NAME:
 * dbo.d_ebe_report_tractor_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *  The stored procedure uses the follow spec to generate a return set
 *  that will be passed to EBE in order to be merged with a MBS GP
 *  document to produce a remittence/check
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * 001 - stl_number, 
 * 002 - stl_payperiod, 
 * 003 - stl_asgn_type, 
 * 004 - stl_asgn_id, 
 * 005 - stl_payto, 
 * 006 - stl_name, 
 * 007 - stl_terminal, 
 * 008 - stl_cardnumber, 
 * 009 - stl_grouping, 
 * 010 - stl_ordnumber, 
 * 011 - stl_orddate, 
 * 012 - stl_description, 
 * 013 - stl_quantity, 
 * 014 - stl_mt_miles, 
 * 015 - stl_ld_miles, 
 * 016 - stl_rate, 
 * 017 - stl_fee1, 
 * 018 - stl_fee2, 
 * 019 - stl_amount, 
 * 020 - stl_status, 
 * 021 - stl_dedbal, 
 * 022 - stl_grptotal, 
 * 023 - stl_netb3tax, 
 * 024 - stl_avg_qtd_miles,
 * 025 - stl_avg_qtd_miles_to_qualify,
 * 026 - stl_terminationdate ,
 * 027 - stl_terminalcode ,
 * 028 - stl_prev_overdraft,
 * 029 - stl_curr_overdraft,
 * 030 - stl_grossminusreimb 
 * 031 - pyt_description
 * 032 - pto_address1,
 * 033 - pto_address2,
 * 034 - pto_cty_name,
 * 035 - pto_cty_state,
 * 036 - pto_zip,
 * 037 - stl_TotalAllTrucks
 *
 * PARAMETERS:
 * 
 * 001 - @trc_id varchar(8)
 * 002 - @type1 varchar(6)
 * 003 - @type2 varchar(6)
 * 004 - @type3 varchar(6)
 * 005 - @type4 varchar(6)
 * 006 - @company varchar(6)
 * 007 - @fleet varchar(6)
 * 008 - @division varchar(6)
 * 009 - @terminal varchar(6)
 * 010 - @payperiodstart datetime
 * 011 - @payperiodend datetime
 *
 * REFERENCES:
 * not defined at this time
 * 
 * REVISION HISTORY:
 * 07/25/2005.01 - Vince Herman ? copied from d_ebe_report_tractor_sp
 *                                to incorporate logic from PTS 28560
 * 10/04/2005.01 - Vince Herman - 29974 new specs on overdraft
 * 10/24/2005.01 - Vince Herman - 28560 new description spec
 * 10/28/2005.01 - Vince Herman - 28560 handle linehaul with no order
 * 11/30/2005.01 - Vince Herman - 30755 license fund to show remainder
 * 12/01/2005.01 - Vince Herman - 30788 new logic for overdraft
 * 01/10/2006.01 - Vince Herman - 31241 handle payto with multiple trucks and change reimb/ded logic
 * 01/11/2006.01 - Vince Herman - 31289 reserve fund description change
 * 01/12/2006.01 - Vince Herman	- 31232 new rules for main description
 * 01/13/2006.01 - Vince Herman - 31279 get overdraft from GP & total all trucks new column
 * 01/26/2006.01 - Vince Herman - 31507 switch for collected or close/transferred
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 **/


set nocount on
set ansi_nulls on
set ansi_warnings on


declare @v_originalpayperiodend datetime
select @v_originalpayperiodend = @payperiodend
select @payperiodend = convert(datetime, convert(varchar(10), @payperiodend, 101) + ' 23:59')
declare	@gross money,
	@reimb money,
	@sql nvarchar(900),
	@gpserver varchar(50),
	@gpdb varchar(12),
	@v_last_asgn_id varchar(13),
	@v_trc_id varchar(13),
	@v_pto varchar(12),
	@v_last_itemcode varchar(6),
	@v_last_pyt_itemcode varchar(6),
	@PeriodforYTD	Varchar(3),
	@v_previousoverdraft money,
	@v_currentoverdraft money,
	@v_singlepayheadernet money,
	@v_last_pyh_payperiod datetime,
	@v_std_number int,
	@v_sdm_minusbalance char(1),
	@v_temp_payto	varchar(8)

-- Create a temp table to the pay header and detail numbers
create table #temp_pay
  (stl_number      int            not null,    -- settlement number
   stl_payperiod   datetime       null,        -- pay period date
   stl_issuedate   datetime       null,        -- pay header issue date
   stl_asgn_type   varchar(6)     null,        -- asset type (?DRV?, ?TRC?) 
   stl_asgn_id     varchar(13)    null,        -- asset ID (driver ID or tractor number)
   stl_payto       varchar(12)    null,        -- payto ID (null string if UNKNOWN)
   stl_name        varchar(255)   null,        -- manpowerprofile,mpp_lastfirst/payto.pto_lastfirst/payto.pto_companyname
   stl_terminal    varchar(50)    null,        -- manpowerprofile.mpp_terminal/tractorprofile.trc_terminal
   stl_cardnumber  varchar(25)    null,        -- issued on card number
   stl_grouping    varchar(25)    null,        -- pay code grouping (earnings, reimbursements, deductions)
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
   stl_terminationdate datetime   null,		-- manpowerprofile/tractorprofile termination date
   stl_terminalcode varchar(6)    null,		-- manpowerprofile.mpp_terminal/tractorprofile.trc_terminal	code
   stl_prev_overdraft money	null,		-- prior overdraft identical to the pay macro value
   stl_curr_overdraft money	null,		-- current overdraft amount identical to pay macro value	
   stl_grossminusreimb money	null,		-- Gross pay minus reimbursements	
   tpy_fund_description varchar(30) null,	--description from stdmaster for reserve funds rows (stdmaster sdm_description)
   tpy_beginning_balance money	null,		--beginning balance for reserve funds rows (standingdeduction std_prior_balance)
   tpy_ending_balance money	null,		--ending balance for reserve funds rows (standingdeduction std_balance)
   stl_itemcode    varchar(6)	null,		-- itemcode
   pyt_description varchar(30)	null,		-- item description
   ytd_comp        money	null,		-- ytd earnings
   pto_address1    varchar(50)	null,		-- Payto address 1
   pto_address2    varchar(50)	null,		-- Payto Address 2
   pto_cty_name    varchar(18)	null,		-- Payto City name
   pto_cty_state   varchar(6)	null,		-- Payto City state
   pto_zip         varchar(10)	null,		-- Payto Zip
   std_number      int		null,		-- standing deduction number
   sdm_minusbalance char(1)	null,		-- 
   stl_TotalAllTrucks money	null		-- Total Due/Overdrawn for all trucks for a payto
)

create index temp_pay_asgn_id on #temp_pay(stl_asgn_id)

--Create a temp table for YTD balances
CREATE TABLE #ytdbal (asgn_type	varchar (6) not null,
	asgn_id			varchar (13) not null,
	ytdcomp			money null,
	pyh_payperiod		datetime null,
	pyh_issuedate		datetime null)

select	@PeriodForYtd = 'no'
SELECT @PeriodforYTD = isnull(gi_string1,'no') 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'

--vjh 31507
declare @EBETractorPayStatus varchar(60)
select @EBETractorPayStatus = gi_string1 from generalinfo where gi_name = 'EBETractorPayStatus'
select @EBETractorPayStatus = isnull(@EBETractorPayStatus, 'RELXFR')

--vjh 28560 put tractor section in for this tractor version of the proc
insert into #temp_pay (
	stl_number,	--01
	stl_payperiod,	--02
	stl_issuedate, 	--03
	stl_asgn_type, 	--04
	stl_asgn_id, 	--05
	stl_payto, 	--06
	stl_name, 	--07
	stl_terminal, 	--08
	stl_cardnumber,	--09
	stl_grouping, 	--10
	stl_ordnumber, 	--11
	stl_orddate, 	--12
	stl_description, --13
	stl_quantity, 	--14
	stl_mt_miles, 	--15
	stl_ld_miles, 	--16
	stl_rate, 	--17
	stl_fee1, 	--18
	stl_fee2, 	--19
	stl_amount, 	--20
	stl_status, 	--21
	stl_dedbal, 	--22
	stl_grptotal, 	--23
	stl_netb3tax,	--24
	tpy_fund_description, 	--25
	tpy_beginning_balance, 	--26
	tpy_ending_balance, 	--27
	stl_itemcode, 	--28
	pyt_description,	--29
	pto_address1,	--30
	pto_address2,	--31
	pto_cty_name,	--32
	pto_cty_state,	--33
	pto_zip, 	--34
	std_number,	--35
	sdm_minusbalance, --36
	stl_TotalAllTrucks, --37
	stl_prev_overdraft) --38
select payheader.pyh_pyhnumber,	--01
       payheader.pyh_payperiod,	--02
       payheader.pyh_issuedate,	--03
       payheader.asgn_type, 	--04
       payheader.asgn_id, 	--05
       case when payheader.pyh_payto = 'UNKNOWN' then '' else payheader.pyh_payto end, 	--06
       case when payheader.pyh_payto = 'UNKNOWN' then '' 
            when len(payto.pto_companyname) > 0 then payto.pto_companyname 
            when len(payto.pto_lastfirst) > 0 then payto.pto_lastfirst else '' end, 	--07
       case when tractorprofile.trc_terminal = 'UNK' then '' 
            else (select labelfile.name from labelfile where labelfile.abbr = tractorprofile.trc_terminal and labelfile.labeldefinition = 'Terminal') end, 	--08
       isnull(payheader.crd_cardnumber, ''), 	--09

       case when (isnull(paydetail.std_number_adj, 0) <> 0 and pyd_pretax = 'N'and paydetail.pyd_amount > 0) then '2 - reimbursements'
            when (isnull(paydetail.std_number_adj, 0) <> 0 and pyd_pretax = 'N') then '3 - deductions'
            when isnull(paydetail.std_number_adj, 0) <> 0 then '99 - standing ded adj'
            when paydetail.pyd_pretax = 'N' and paydetail.pyd_amount > 0 then '2 - reimbursements' 
            when paydetail.pyd_pretax = 'N' then '3 - deductions' 
            else '1 - earnings' end, 	--10

       isnull(orderheader.ord_number, ''), 	--11
       case when paydetail.ord_hdrnumber = 0 then paydetail.pyd_transdate 
            when paytype.pyt_fservprocess in ('A', 'C', 'T', 'U') then paydetail.pyd_transdate 
            when paydetail.ord_hdrnumber > 0 then orderheader.ord_startdate 
            else paydetail.pyd_transdate end, 	--12
       case when paytype.pyt_basis = 'LGH' and paydetail.lgh_startcity is null then paydetail.pyd_description
            when paytype.pyt_basis = 'LGH' then ((select city.cty_name + ', ' + city.cty_state from city  
                                                   where city.cty_code = paydetail.lgh_startcity) + ' / ' +   
                                                 (select city.cty_name + ', ' + city.cty_state from city  
                                                   where city.cty_code = paydetail.lgh_endcity))   
            when paytype.pyt_fservprocess in ('A', 'C', 'T', 'U') then paydetail.pyd_description
            when paydetail.pyd_refnumtype='TMT' then paydetail.pyd_description
            when isnull(paydetail.std_number_adj, 0) <> 0 then paydetail.pyd_description
            when isnull(paydetail.pyd_description, '') <> '' then paydetail.pyd_description --pts 31232
            else paytype.pyt_description end,  --13  
       case when paydetail.pyd_rateunit = 'MIL' then NULL else paydetail.pyd_quantity end, 	--14
       case when paydetail.pyd_rateunit = 'MIL' and paydetail.pyd_loadstate in ('MT', 'UNLD') then paydetail.pyd_quantity else 0 end, 	--15
       case when paydetail.pyd_rateunit = 'MIL' and paydetail.pyd_loadstate <> 'MT' and paydetail.pyd_loadstate <> 'UNLD' then paydetail.pyd_quantity else 0 end, 	--16
       paydetail.pyd_rate, 	--17
       isnull(paydetail.pyt_fee1, 0), 	--18
       isnull(paydetail.pyt_fee2, 0), 	--19
       paydetail.pyd_amount, 	--20
       paydetail.pyd_status, 	--21
       0, --22 
       --isnull((select std_balance from standingdeduction where standingdeduction.std_number = paydetail.std_number), 0), 	--22
       case when paydetail.pyd_pretax = 'N' and paydetail.pyd_minus = -1 and isnull(paydetail.std_number_adj, 0) = 0 then isnull(payheader.pyh_totaldeduct, 0) 
            when paydetail.pyd_pretax = 'N' and paydetail.pyd_minus = 1 and isnull(paydetail.std_number_adj, 0) = 0 then isnull(payheader.pyh_totalreimbrs, 0) 
            when paydetail.pyd_pretax = 'Y' and isnull(paydetail.std_number_adj, 0) = 0 then isnull(payheader.pyh_totalcomp, 0) else 0 end,	--23
       isnull(payheader.pyh_totalcomp, 0) + isnull(payheader.pyh_totaldeduct, 0) + isnull(payheader.pyh_totalreimbrs, 0),	--24
	null, -- tpy_fund_description	--25
	null, -- tpy_beginning_balance	--26
	null,  -- tpy_ending_balance	--27
	paydetail.pyt_itemcode,	--28
	paytype.pyt_description,--29
	pto_address1,	--30
	pto_address2,	--31
	cty_name,	--32
	cty_state,	--33
	isnull(pto_zip,cty_zip),	--34
	isnull(paydetail.std_number,abs(std_number_adj)), --35
	null,		--36
	null,		--37
	isnull((select sum(gpcurtrxam) from apsummary where type='TRC' and payto=payheader.pyh_payto),0) --38
  from payheader, 
       paytype, 
       tractorprofile, 
       payto, 
       orderheader  RIGHT OUTER JOIN paydetail ON orderheader.ord_hdrnumber = paydetail.ord_hdrnumber, --pts40462 outer join conversion
       city 
 where payheader.asgn_type = 'TRC' 
   -- vjh 31507
   --and payheader.pyh_paystatus in ('REL', 'XFR') 
   --and payheader.pyh_paystatus in ('COL') 
   and	(
	(pyh_paystatus in ('REL', 'XFR') and @EBETractorPayStatus <> 'COL')
  	OR (pyh_paystatus in ('COL') and @EBETractorPayStatus = 'COL')	 
	)
   and (payheader.asgn_id = @trc_id or @trc_id = 'UNKNOWN') 
   and paydetail.pyh_number = payheader.pyh_pyhnumber 
   and tractorprofile.trc_number = payheader.asgn_id 
   and payto.pto_id = payheader.pyh_payto 
   and paytype.pyt_itemcode = paydetail.pyt_itemcode 
   --and orderheader.ord_hdrnumber =* paydetail.ord_hdrnumber 
   and (tractorprofile.trc_type1 = @type1 or @type1 = 'UNK') 
   and (tractorprofile.trc_type2 = @type2 or @type2 = 'UNK') 
   and (tractorprofile.trc_type3 = @type3 or @type3 = 'UNK') 
   and (tractorprofile.trc_type4 = @type4 or @type4 = 'UNK') 
   and (tractorprofile.trc_company = @company or @company = 'UNK') 
   and (tractorprofile.trc_fleet = @fleet or @fleet = 'UNK') 
   and (tractorprofile.trc_division = @division or @division = 'UNK') 
   and (tractorprofile.trc_terminal = @terminal or @terminal = 'UNK') 
   and payheader.pyh_payperiod between @payperiodstart and @payperiodend  
   and (paydetail.tar_tarriffnumber <> '-1' or paydetail.tar_tarriffnumber is null)
   and pto_city = cty_code

-- vjh pts 30775 put sdm_minusbalance in for later work
update #temp_pay set sdm_minusbalance = m.sdm_minusbalance 
	from standingdeduction s
	join stdmaster m on m.sdm_itemcode=s.sdm_itemcode
	where s.std_number = #temp_pay.std_number

--vjh new overdraft logic
--vjh 31241 use payto logic in this new overdraft logic

--select @v_pto = min(stl_payto) --get first value @v_pto
--  from #temp_pay where stl_payto is not null
--while @v_pto is not null begin
--	select @v_previousoverdraft = 0	
--	select @v_last_pyh_payperiod = min(pyh_payperiod) --get first value @v_last_pyh_payperiod
--	  from payheader
--	 where pyh_payperiod < @v_originalpayperiodend
--	   and pyh_payto = @v_pto
--
--	while @v_last_pyh_payperiod is not null begin
--		select @v_singlepayheadernet = sum(pyh_totalcomp) + sum(pyh_totaldeduct) + sum(pyh_totalreimbrs)
--		  from payheader
--		 where pyh_payperiod = @v_last_pyh_payperiod
--		   and pyh_payto = @v_pto
--	
--		select @v_previousoverdraft = @v_previousoverdraft + @v_singlepayheadernet
--		if @v_previousoverdraft > 0 select @v_previousoverdraft = 0
--
--		select @v_last_pyh_payperiod = min(pyh_payperiod) --get next value @v_last_pyh_payperiod
--		  from payheader
--		 where pyh_payperiod > @v_last_pyh_payperiod
--		   and pyh_payperiod < @v_originalpayperiodend
--		   and pyh_payto = @v_pto
--	end
--
--	update #temp_pay 
--	   set stl_prev_overdraft = @v_previousoverdraft
--	 where stl_payto = @v_pto
--	select @v_pto = min(stl_payto) --get next value @v_pto
--	  from #temp_pay
--	 where stl_payto > @v_pto
--end

--vjh 31279 get sums of netb3tax for payto.  Hoops to jump through, since this is denormalized onto each detail
create table #temp_pay_summary
  (stl_asgn_id     varchar(13)    not null,   -- asset ID (driver ID or tractor number)
   stl_payto       varchar(12)    not null,   -- payto ID (null string if UNKNOWN)
   stl_netb3tax    money          null        -- net earnings before taxes and benefits (earnings + reimbursements + deductions)
)

insert #temp_pay_summary (stl_asgn_id, stl_payto, stl_netb3tax)
select stl_asgn_id, stl_payto, min(stl_netb3tax) from #temp_pay group by stl_asgn_id, stl_payto

update #temp_pay 
set stl_TotalAllTrucks = (select sum(stl_netb3tax) 
			from #temp_pay_summary 
			where #temp_pay_summary.stl_payto = #temp_pay.stl_payto)

--vjh remove Great Plains overdraft logic and replace with similar logic to the settlement sheet 43
select @v_last_asgn_id = min(stl_asgn_id) --get first value @v_last_asgn_id
  from #temp_pay
while @v_last_asgn_id is not null begin

  
	--vjh calculate current overdraft
	select @v_currentoverdraft = 0
	select @v_currentoverdraft = pyh_totalcomp + pyh_totaldeduct + pyh_totalreimbrs
	  from payheader
	 where pyh_payperiod = @v_originalpayperiodend
	   and asgn_type='TRC'
	   and asgn_id = @v_last_asgn_id

	if @v_currentoverdraft < 0
		update #temp_pay set stl_curr_overdraft = @v_currentoverdraft where stl_asgn_id = @v_last_asgn_id

  select @v_last_itemcode = min(sdm_itemcode) --get first value @v_last_itemcode
    from stdmaster
   where sdm_interestrate =.0001
  while @v_last_itemcode is not null begin

if exists(select 1 from standingdeduction
		where sdm_itemcode = @v_last_itemcode
		  and asgn_id = @v_last_asgn_id) begin
  --declare @v_nummatches int

select @v_last_pyt_itemcode = pyt_itemcode
from stdmaster
where sdm_itemcode = @v_last_itemcode

-- vjh ptsxxxxx handle due payee as well
-- @v_std_number = std_number, from standingdeduction
--where sdm_itemcode = @v_last_itemcode and asgn_id = @v_last_asgn_id

select @v_std_number = s.std_number, @v_sdm_minusbalance = m.sdm_minusbalance 
from standingdeduction s
join stdmaster m on m.sdm_itemcode=s.sdm_itemcode
where s.sdm_itemcode = @v_last_itemcode and asgn_id = @v_last_asgn_id

  if not exists(select 1 from #temp_pay where std_number = @v_std_number) begin


--  if not exists(select 1 from #temp_pay where stl_itemcode = @v_last_itemcode
--		  and stl_asgn_id = @v_last_asgn_id) begin

--if more zero matches exist, insert a row and update these columns
--stl_number = -1 This is not null on the table, so we need something, and it should not conflict with other numbers
--stl_payperiod = ??? This comes form the payheader, but on inserted escro funds, there is no pay header
--stl_asgn_type = 'TRC'
--stl_asgn_id = @v_last_asgn_id
--stl_terminal = when tractorprofile.trc_terminal = 'UNK' then '' 
--            else (select labelfile.name from labelfile where labelfile.abbr = tractorprofile.trc_terminal and labelfile.labeldefinition = 'Terminal') end, 
--stl_description = paytype.pyt_description (joined on itemcode)
--stl_amount = 0	
--stl_terminationdate = tractorprofile
--stl_terminalcode = tractorprofile.trc_terminal
--stl_itemcode

	insert into #temp_pay (stl_number,
		stl_payperiod,
		stl_issuedate,
		stl_asgn_type,
		stl_asgn_id,
		stl_payto,
		stl_name,
		stl_terminal,
		stl_description,
		stl_amount,
		stl_terminationdate,
		stl_terminalcode,
		stl_itemcode,
		pyt_description,
		std_number,
		sdm_minusbalance) 
	select 	-1,
		@payperiodend, 
		@payperiodend, --yes, same thing twice - need issue date on these constructed rows
		'TRC', 
		@v_last_asgn_id,
		case when trc_owner = 'UNKNOWN' then '' else trc_owner end, 
		case when trc_owner = 'UNKNOWN' then '' 
		     when len(payto.pto_companyname) > 0 then payto.pto_companyname 
		     when len(payto.pto_lastfirst) > 0 then payto.pto_lastfirst else '' end, 
		case when tractorprofile.trc_terminal = 'UNK' then '' 
	            else (select labelfile.name from labelfile where labelfile.abbr = tractorprofile.trc_terminal and labelfile.labeldefinition = 'Terminal') end, 
		paytype.pyt_description,
		0,
		trc_retiredate,
		trc_terminal,
		@v_last_itemcode,
		paytype.pyt_description,
		@v_std_number,
		@v_sdm_minusbalance
	from tractorprofile , paytype, payto
	where trc_number = @v_last_asgn_id
	and paytype.pyt_itemcode = @v_last_pyt_itemcode
	and payto.pto_id = trc_owner
  end
--for all rows that match, (including new ones) update these columns
--tpy_fund_description = paytype.pyt_description (joined on itemcode)
--tpy_beginning_balance = standingdeduction
--tpy_ending_balance = standingdeduction

-- vjh pts30775 changing license funds to show remainder rather than paid to date

	If @v_sdm_minusbalance='N'
	  update #temp_pay
	     set tpy_fund_description = isnull(s.std_description,''),
		 tpy_beginning_balance = case when sdm_itemcode in ('T-LF','T-LFNX') 
			then -1 * (isnull(s.std_balance,0) - (select sum(stl_amount) from #temp_pay where std_number = @v_std_number))
			else isnull(s.std_startbalance-s.std_endbalance-s.std_balance,0) + (select sum(stl_amount) from #temp_pay where std_number = @v_std_number)
			end,
		 tpy_ending_balance = case when sdm_itemcode in ('T-LF','T-LFNX') 
			then isnull(-1 * s.std_balance,0)
			else isnull(s.std_startbalance-s.std_endbalance-s.std_balance,0)
			end
	  from standingdeduction s
	   where stl_asgn_type = 'TRC'
	     and #temp_pay.std_number = @v_std_number
	     and s.std_number = @v_std_number
	else
	  update #temp_pay
	     set tpy_fund_description = isnull(s.std_description,''),
		 tpy_beginning_balance = case when sdm_itemcode in ('T-LF','T-LFNX') 
			then -1 * (isnull(s.std_balance - s.std_endbalance,0) - (select sum(stl_amount) from #temp_pay where std_number = @v_std_number))
			else isnull(-1 * s.std_balance,0) + (select sum(stl_amount) from #temp_pay where std_number = @v_std_number)
			end,
		 tpy_ending_balance = case when sdm_itemcode in ('T-LF','T-LFNX') 
			then -1 * (isnull(s.std_balance - s.std_endbalance,0))
			else isnull(-1 * s.std_balance,0)
			end
	  from standingdeduction s
	   where stl_asgn_type = 'TRC'
	     and #temp_pay.std_number = @v_std_number
	     and s.std_number = @v_std_number

end 

    select @v_last_itemcode = min(sdm_itemcode) --get next value @v_last_itemcode
      from stdmaster
     where sdm_itemcode > @v_last_itemcode
       and sdm_interestrate =.0001
  end
  select @v_last_asgn_id = min(stl_asgn_id) --get next value @v_last_asgn_id
    from #temp_pay
   where stl_asgn_id > @v_last_asgn_id
end

--DPH 34474
select @v_last_asgn_id = min(id) --get first value @v_last_asgn_id
  from apsummary
 where type = 'TRC'
   and not exists (Select 1 from #temp_pay where apsummary.payto = #temp_pay.stl_payto)


while @v_last_asgn_id is not null begin

 --get payto from @v_last_asgn_id

 If isnull((select sum(gpcurtrxam) from apsummary where type='TRC' and id=@v_last_asgn_id),0) = 0  
	BEGIN
		select @v_last_asgn_id = min(id) --get next value @v_last_asgn_id
		from apsummary
	   where type = 'TRC'
		 and not exists (Select 1 from #temp_pay where apsummary.payto = #temp_pay.stl_payto) 
		 and id > @v_last_asgn_id

		Continue
    END


  select @v_currentoverdraft = 0
	insert into #temp_pay (stl_number,
		stl_payperiod,
		stl_issuedate,
		stl_asgn_type,
		stl_asgn_id,
		stl_payto,
		stl_name,
		stl_terminal,
		stl_description,
		stl_amount,
		stl_terminationdate,
		stl_terminalcode,
		stl_itemcode,
		pyt_description,
		std_number,
		sdm_minusbalance,
		stl_prev_overdraft,
		stl_dedbal,
		tpy_fund_description)

		--stl_grossminusreimb = ???

	select 	-1,
		@payperiodend, 
		@payperiodend, --yes, same thing twice - need issue date on these constructed rows
		'TRC', 
		@v_last_asgn_id,
		case when trc_owner = 'UNKNOWN' then '' else trc_owner end, 
		case when trc_owner = 'UNKNOWN' then '' 
		     when len(payto.pto_companyname) > 0 then payto.pto_companyname 
		     when len(payto.pto_lastfirst) > 0 then payto.pto_lastfirst else '' end, 
		case when tractorprofile.trc_terminal = 'UNK' then '' 
	            else (select labelfile.name from labelfile where labelfile.abbr = tractorprofile.trc_terminal and labelfile.labeldefinition = 'Terminal') end, 
		'Previous Overdraft',
		0,
		trc_retiredate,
		trc_terminal,
		'',
		'Previous Overdraft',
		0,
		@v_sdm_minusbalance,
		isnull((select sum(gpcurtrxam) from apsummary where type='TRC' and id=@v_last_asgn_id),0),
		0,
		'Previous Overdraft'
	from tractorprofile , payto
	where trc_number = @v_last_asgn_id
	and payto.pto_id = trc_owner

	If @v_sdm_minusbalance='N'
	  update #temp_pay
	     set tpy_fund_description = isnull(s.std_description,''),
		 tpy_beginning_balance = case when sdm_itemcode in ('T-LF','T-LFNX') 
			then -1 * (isnull(s.std_balance,0) - (select sum(stl_amount) from #temp_pay where std_number = @v_std_number))
			else isnull(s.std_startbalance-s.std_endbalance-s.std_balance,0) + (select sum(stl_amount) from #temp_pay where std_number = @v_std_number)
			end,
		 tpy_ending_balance = case when sdm_itemcode in ('T-LF','T-LFNX') 
			then isnull(-1 * s.std_balance,0)
			else isnull(s.std_startbalance-s.std_endbalance-s.std_balance,0)
			end
	  from standingdeduction s
	   where stl_asgn_type = 'TRC'
	     and #temp_pay.std_number = @v_std_number
	     and s.std_number = @v_std_number
	else
	  update #temp_pay
	     set tpy_fund_description = isnull(s.std_description,''),
		 tpy_beginning_balance = case when sdm_itemcode in ('T-LF','T-LFNX') 
			then -1 * (isnull(s.std_balance - s.std_endbalance,0) - (select sum(stl_amount) from #temp_pay where std_number = @v_std_number))
			else isnull(-1 * s.std_balance,0) + (select sum(stl_amount) from #temp_pay where std_number = @v_std_number)
			end,
		 tpy_ending_balance = case when sdm_itemcode in ('T-LF','T-LFNX') 
			then -1 * (isnull(s.std_balance - s.std_endbalance,0))
			else isnull(-1 * s.std_balance,0)
			end
	  from standingdeduction s
	   where stl_asgn_type = 'TRC'
	     and #temp_pay.std_number = @v_std_number
	     and s.std_number = @v_std_number

  select @v_last_asgn_id = min(id) --get next value @v_last_asgn_id
    from apsummary
   where type = 'TRC'
	 and not exists (Select 1 from #temp_pay where apsummary.payto = #temp_pay.stl_payto) 
	 and id > @v_last_asgn_id
end

--DPH 34474

update #temp_pay set stl_prev_overdraft = 0 where stl_prev_overdraft is null

update #temp_pay set stl_curr_overdraft = 0 where stl_curr_overdraft is null

--vjh pts30775 change std_dedbal to use minusbalance logic and show accurate remainder
update #temp_pay
     set stl_dedbal = 
	case when #temp_pay.sdm_minusbalance='N' 
	then isnull(s.std_balance,0)
	else isnull(s.std_balance - s.std_endbalance,0) 
	end
    from standingdeduction s where s.std_number = #temp_pay.std_number

-- update avg qtd miles
update #temp_pay 
   set stl_avgqtlmil = (select sum(paydetail.pyd_quantity) 
                          from paytype,
                               paydetail, 
                               manpowerprofile 
                         where paydetail.asgn_type = 'TRC' 
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
 where #temp_pay.stl_asgn_type = 'TRC' 
   and #temp_pay.stl_asgn_id = manpowerprofile.mpp_id 


-- update new computed fields
update #temp_pay 
	set stl_avgqtlmil = isnull(stl_avgqtlmil, 0)/(case when stl_avgqtdweeks is null or stl_avgqtdweeks = 0 then 1 else stl_avgqtdweeks end)


select @gross = min(stl_grptotal) from #temp_pay where stl_grouping = '1 - earnings'
select @reimb = min(stl_grptotal) from #temp_pay where stl_grouping = '2 - reimbursements'
select @gross = IsNull(@gross,0)
select @reimb = IsNull(@reimb,0)

update a
set	 stl_grossminusreimb =IsNull(( select IsNull(min(stl_grptotal),0) from #temp_pay b where a.stl_asgn_id = b.stl_asgn_id and b.stl_grouping = '1 - earnings') - 
						  ( select IsNull(min(stl_grptotal),0) from #temp_pay c where a.stl_asgn_id = c.stl_asgn_id and c.stl_grouping = '2 - reimbursements'),0)

from #temp_pay a

update #temp_pay set   stl_terminalcode =  case when tractorprofile.trc_terminal = 'UNK' then '' else tractorprofile.trc_terminal end,
stl_terminationdate = trc_retiredate
from tractorprofile where stl_asgn_type = 'TRC' and stl_asgn_id = tractorprofile.trc_number


--Insert into the temp YTD balances table the assets from the temp pay details table
INSERT INTO #ytdbal
     SELECT DISTINCT stl_asgn_type, stl_asgn_id, 0, stl_payperiod, stl_issuedate
       FROM #temp_pay


--Compute the YTD balances for each assets
if left(ltrim(@PeriodforYTD),1) = 'Y' begin
UPDATE #ytdbal
   SET	ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
			FROM payheader ph
                  	WHERE ph.asgn_id = yb.asgn_id
                        	AND ph.asgn_type = yb.asgn_type
                        	AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        	AND ph.pyh_payperiod < @payperiodend
                        	AND ph.pyh_paystatus <> 'HLD'), 0)
   FROM  #ytdbal yb
end else begin
UPDATE #ytdbal
	SET	ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
			FROM payheader ph
	          	WHERE ph.asgn_id = yb.asgn_id
	                	AND ph.asgn_type = yb.asgn_type
	                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, isnull(yb.pyh_issuedate,yb.pyh_payperiod))
	                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) <= isnull(yb.pyh_issuedate,yb.pyh_payperiod)
	                	AND ph.pyh_paystatus <> 'HLD'), 0)
   FROM  #ytdbal yb
END

UPDATE 	#temp_pay
  SET 	ytd_comp = yb.ytdcomp
  FROM 	#ytdbal yb
		,#temp_pay tp
  WHERE tp.stl_asgn_type = yb.asgn_type
	AND tp.stl_asgn_id = yb.asgn_id
	--vmj1+	Note that 2/2/1950 is a very unlikely date value which is used to compare NULL 
	--to NULL..
	and isnull(tp.stl_issuedate, '1950-02-02') = isnull(yb.pyh_issuedate, '1950-02-02')
	and isnull(tp.stl_payperiod, '1950-02-02') = isnull(yb.pyh_payperiod, '1950-02-02')
	--vmj1-

--vjh 31289 reserve fund activity is a mix of different detail lines.  The must have the same description
--to be able to group together.  Force the pyt_description to be the tpy_fund_description when there
--is a fund description

update #temp_pay
   set pyt_description = tpy_fund_description
 where tpy_fund_description is not null


select	stl_number, 
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
	round(isnull(stl_avgqtlmil,0),2) stl_avg_qtd_miles,
	round(29900 - isnull(stl_avgqtlmil,0),2) stl_avg_qtd_miles_to_qualify,
	stl_terminationdate ,
	stl_terminalcode ,
	stl_prev_overdraft,
	stl_curr_overdraft,
	stl_grossminusreimb,
	tpy_fund_description,
	tpy_beginning_balance,
	tpy_ending_balance,
	pyt_description,
	null as 'ytd_comp', --ytd_comp,
	pto_address1,
	pto_address2,
	pto_cty_name,
	pto_cty_state,
	pto_zip,
	stl_TotalAllTrucks
  from #temp_pay 
 order by stl_asgn_type, stl_asgn_id, stl_grouping, stl_ordnumber, stl_orddate, stl_description

GO
GRANT EXECUTE ON  [dbo].[d_ebe_report_tractor_sp] TO [public]
GO
