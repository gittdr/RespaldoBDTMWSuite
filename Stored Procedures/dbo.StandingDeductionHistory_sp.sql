SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[StandingDeductionHistory_sp] 
@asgn_type varchar(6), 
@asgn_id varchar(20),
@deducion_type	varchar(6),
@begindate datetime,
@enddate datetime

AS
/**
 *
 * NAME:
 * dbo.dbo.StandingDeductionHistory_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * 
 * RETURNS:
 * none
 *
 * RESULT SETS:
 * none
 *
 * PARAMETERS:
 * 001 - @asgn_type varchar(6), 
 * 002 - @asgn_id varchar(20),
 * 003 - @deducion_type	varchar(6),
 * 004 - @begindate datetime,
 * 005 - @enddate datetime
 *
 * REFERENCES: 
 *
 * Sample call:
 *
 *		exec StandingDeductionHistory_sp 'DRV', 'GARTH', 'UNKNOWN', '2011-01-01', '2011-01-31'
 *
 * REVISION HISTORY:
 * 05/02/2011.01 - PTS54613 - vjh
 * 01/27/2014	 - PTS75004 - vjh removing restriction on due payee
 **/
declare @min_std_number	int
declare @min_tt_ident	int
declare @calcbalance	money
declare @assetname		varchar(45)

CREATE TABLE #tstandingdeduction (std_number int, sdm_itemcode varchar(6),  currentbalance money, startbalance money, endbalance money)
CREATE TABLE #ttransactions (tt_ident int identity, std_number int, pyd_number int, pyd_description varchar(75), activitydate datetime, pyd_amount money, deductions money, additions money, runningbalance money)


--get list of standing deductions
insert #tstandingdeduction
select s.std_number, s.sdm_itemcode, s.std_balance, 0, 0
from standingdeduction s 
join stdmaster sm on sm.sdm_itemcode = s.sdm_itemcode
where s.asgn_type = @asgn_type and s.asgn_id = @asgn_id
and s.std_issuedate < @enddate
and s.std_status <> 'CAN'
and not (s.std_status = 'CLD' and s.std_balance = 0 and s.std_closedate < @begindate)
and sm.sdm_escrowstyle = 'Y'
--and sm.sdm_minusbalance = 'Y'		--vjh 75004 client wants to see due company also
and (s.sdm_itemcode = @deducion_type or @deducion_type = 'UNKNOW' or @deducion_type = '' or @deducion_type = 'UNK' or @deducion_type = 'UNKNOWN')

update #tstandingdeduction
set endbalance = #tstandingdeduction.currentbalance - isnull((select SUM(p.pyd_amount)
from paydetail p
where p.std_number = #tstandingdeduction.std_number
and p.pyd_status = 'REL' and p.pyt_itemcode <> 'IT+'
and pyh_payperiod > @enddate),0)

--make entries for starting balance
insert #ttransactions
select t.std_number, -1, 'Beginning Balance', @begindate, 0, 0, 0, t.startbalance from #tstandingdeduction t

--make entries for transactions
insert #ttransactions
select p.std_number, p.pyd_number, p.pyd_description, p.pyh_payperiod, pyd_amount, null, null, 0 from paydetail p
join #tstandingdeduction t on t.std_number = p.std_number
where p.std_number = t.std_number
and p.pyd_status = 'REL' and p.pyt_itemcode <> 'IT+'
and pyh_payperiod between @begindate and @enddate
order by p.pyh_payperiod

update #tstandingdeduction
set startbalance = endbalance - isnull((select SUM(pyd_amount) from #ttransactions where #tstandingdeduction.std_number = #ttransactions.std_number),0)

select @min_std_number = MIN(std_number) from #tstandingdeduction
while @min_std_number is not null begin
	--walk through all the standing deduction entries
	select @min_tt_ident = MIN(tt_ident) from #ttransactions where #ttransactions.std_number = @min_std_number
	-- blow on the starting balance to the beginning balance row
	update #ttransactions 
	set runningbalance = startbalance 
	from #tstandingdeduction 
	where #ttransactions.tt_ident = @min_tt_ident
	and #tstandingdeduction.std_number = @min_std_number
	--keep the runing balance for use calculating the next
	select @calcbalance = runningbalance
	from #ttransactions 
	where #ttransactions.tt_ident = @min_tt_ident
	
	--move to first transaction row
	select @min_tt_ident = MIN(tt_ident) from #ttransactions where #ttransactions.std_number = @min_std_number and tt_ident > @min_tt_ident
	while @min_tt_ident is not null begin
		--walk through all the transactions
		select @calcbalance = @calcbalance + pyd_amount from #ttransactions where tt_ident = @min_tt_ident
		update #ttransactions set runningbalance = @calcbalance where tt_ident = @min_tt_ident
		select @min_tt_ident = MIN(tt_ident) from #ttransactions where #ttransactions.std_number = @min_std_number and tt_ident > @min_tt_ident
	end
	select @min_std_number = MIN(std_number) from #tstandingdeduction where std_number > @min_std_number
end

update #ttransactions set runningbalance = runningbalance * -1
update #ttransactions set additions = pyd_amount * -1 where pyd_amount < 0
update #ttransactions set deductions = pyd_amount where pyd_amount > 0

if @asgn_type = 'DRV' begin
	select @assetname = mpp_lastfirst from manpowerprofile where mpp_id = @asgn_id
end else begin
	select @assetname = @asgn_id
end

select 
tt_ident,
@asgn_type "asgn_type", 
@asgn_id "asgn_id",
@assetname "assetname",
@deducion_type "deducion_type",
@begindate "begindate",
@enddate "enddate",
ts.std_number, tt.activitydate,ts.sdm_itemcode, tt.pyd_description, tt.deductions, tt.additions, tt.runningbalance from #tstandingdeduction ts
join #ttransactions tt on ts.std_number = tt.std_number
order by ts.std_number, tt_ident

 --*		exec StandingDeductionHistory_sp 'DRV', 'GARTH', 'UNKNOWN', '2011-01-01', '2011-01-31'
GO
GRANT EXECUTE ON  [dbo].[StandingDeductionHistory_sp] TO [public]
GO
