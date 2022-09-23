SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[Deduction_Arrears_Aging_sp]    
as    

/**
 * 
 * NAME:
 * dbo.Deduction_Arrears_Aging_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This proc provides data for an aging report of deduction arrears.
 * Basic flow is like this:
	For each payto
		Compute arrears
		Justify arrears amount
 * 
 *
 * RETURNS:
 * NA 
 *
 * RESULT SETS: 
 * See SELECT statement.
 *
 * PARAMETERS:
 * NA
 *
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 
 * 07/13/2012.01 - PTS63869 - vjh - Created this log and altered the proc.
 *
 **/
 
create table #tempinfo (
	ident			int	identity,
	pyh_pyhnumber	int not null,
	pyh_payto		varchar(12) not null,
	asgn_type		varchar(3)	not null,
	asgn_id			varchar(13)	not null,
	pyh_payperiod	datetime not null
)

create table #deductionactivity (
	ident			int	identity,
	std_number		int	null,
	asgn_type		varchar(3)	null,
	asgn_id			varchar(13)	null,
	pyd_amount		money null,
	age				int null
)

create table #tempresults (
	ident			int	identity,
	pyh_payto		varchar(12) null,
	asgn_type		varchar(3)	null,
	asgn_id			varchar(13)	null,
	descr			varchar(255) null,
	std_number		int null,
	tr_total		money null,
	tr_current		money null,
	tr_over30		money null,
	tr_over60		money null,
	tr_over90		money null,
	tr_over120		money null,
	tr_totalpct		decimal(5,2) null,
	tr_currentpct	decimal(5,2) null,
	tr_over30pct	decimal(5,2) null,
	tr_over60pct	decimal(5,2) null,
	tr_over90pct	decimal(5,2) null,
	tr_over120pct	decimal(5,2) null
)

declare @thispayto		varchar(12)
declare @thispayperiod	varchar(12)
declare @runningbalance	money
declare @thisident		int
declare @thispyhnumber	int
declare @thisasgntype	varchar(3)
declare @thisasgnid		varchar(13)
declare	@rundate		datetime
declare @justifiedamt	money
declare @thisamt		money
declare	@thisstdnumber	int
declare	@tr_total		money
declare	@tr_current		money
declare	@tr_over30		money
declare	@tr_over60		money
declare	@tr_over90		money
declare	@tr_over120		money
declare @age			int

select @rundate = '2011/01/01'

--get all payheaders since the last arrears start (genesis the first time through)
insert #tempinfo (pyh_pyhnumber, pyh_payto, pyh_payperiod, asgn_type, asgn_id)
select ph.pyh_pyhnumber, ph.pyh_payto, ph.pyh_payperiod, asgn_type, asgn_id
From payheader ph
join payto pto on ph.pyh_payto = pto.pto_id
where pyh_payto <> 'UNKNOWN'
and ph.pyh_payperiod > pto.pto_arrears_start
--development testing
--and ph.pyh_payto = 'ACAWI'
--and ph.pyh_payto = 'COXMA'
order by ph.pyh_payto,  ph.pyh_payperiod, asgn_type, asgn_id, ph.pyh_pyhnumber

--debug code
--select * from #tempinfo

--Walk through all the payheaders by payto to calculate a running balance for each
--any time the running balance is above zero, then we can stamp this payto with the last arrears date
--since we know they were out of the hole as of that pay period (next time we can start there rather than the beginning of time)
select @thispayto = min(pyh_payto) from #tempinfo
while @thispayto is not null begin

	select @runningbalance = 0
	
	--walk through all payheaders for this payto to compute the arrears amount (in runningbalance)
	select 	@thisident = min(ident) from #tempinfo where pyh_payto = @thispayto
	while @thisident is not null begin
		select @thispayperiod = pyh_payperiod, @thispyhnumber = pyh_pyhnumber from #tempinfo where ident = @thisident

		select @runningbalance = @runningbalance + pyh_totalcomp + pyh_totaldeduct + pyh_totalreimbrs
		from payheader where pyh_pyhnumber = @thispyhnumber

		if @runningbalance>= 0 begin
			--push the pay period date back to the payto profile so that next time we do not have to start at genesis
			update payto set pto_arrears_start = @thispayperiod where pto_id = @thispayto
			--reset the running balance, since this payto is out of arrears at this point
			select @runningbalance = 0
		end
		--get next payheader
		select 	@thisident = min(ident) from #tempinfo where pyh_payto = @thispayto and ident > @thisident
	end
	
	--now justify the arrears amount
	if @runningbalance < 0 begin
		--get all deduction activity so that we can justify the arrears amount
		insert #deductionactivity (std_number, asgn_type, asgn_id, pyd_amount, age)
			select s.std_number, p.asgn_type, p.asgn_id, p.pyd_amount, datediff(day,p.pyh_payperiod, @rundate)
			from paydetail p
			join standingdeduction s on s.std_number = p.std_number
			join stdmaster m on m.sdm_itemcode = s.sdm_itemcode
			join stdhierarchy h on m.sth_abbr = h.sth_abbr
			where p.pyd_payto = @thispayto and p.std_number is not null and p.pyd_amount <> 0
			order by p.pyh_payperiod desc, h.sth_priority desc,  m.sdm_sth_priority desc, pyd_number desc

		--debug code
		--select @runningbalance
		--select * from #deductionactivity

		--and apply the deduction activity to the arrears total until it is justified.
		select @justifiedamt = 0
		select @thisident = min(ident) from #deductionactivity
		--walk through all detention activity for assets under this payto
		while @thisident is not null and @runningbalance < 0 begin
			select @thisamt = pyd_amount, @thisasgntype = asgn_type, @thisasgnid = asgn_id, @age = age, @thisstdnumber = std_number  from #deductionactivity where ident = @thisident
			--if this is the first time we have seen this std_number, add a row to the results in which to accumulate the aging buckets
			if not exists (select 1 from #tempresults where std_number=@thisstdnumber) begin
				insert #tempresults (pyh_payto, asgn_type, asgn_id, std_number, tr_total, tr_current, tr_over30, tr_over60, tr_over90, tr_over120)
					values (@thispayto, @thisasgntype, @thisasgnid, @thisstdnumber,0,0,0,0,0,0)
				select @tr_total = 0, @tr_current = 0, @tr_over30 = 0, @tr_over60 = 0, @tr_over90 = 0, @tr_over120 = 0
			end else begin
				select @tr_total = tr_total, @tr_current = tr_current, @tr_over30 = tr_over30, @tr_over60 = tr_over60, @tr_over90 = tr_over90, @tr_over120 = tr_over120
				from #tempresults where std_number = @thisstdnumber
			end	
			
			--debug code
			--select @thisamt '@thisamt', @runningbalance '@runningbalance', @age '@age'
						
			if @thisamt >= @runningbalance begin
				--apply whole amount of deduction to justification
				select @tr_total = @tr_total + @thisamt
				if @age <= 30 begin
					select @tr_current = @tr_current + @thisamt
				end else if @age <= 60 begin
					select @tr_over30 = @tr_over30 + @thisamt
				end else if @age <= 70 begin
					select @tr_over60 = @tr_over60 + @thisamt
				end else if @age <= 120 begin
					select @tr_over90 = @tr_over90 + @thisamt
				end else begin
					select @tr_over120 = @tr_over120 + @thisamt
				end	
				update #tempresults
					set tr_total = @tr_total, tr_current = @tr_current, tr_over30 = @tr_over30, tr_over60 = @tr_over60, tr_over90 = @tr_over90, tr_over120 = @tr_over120
					where std_number = @thisstdnumber
				

				select @justifiedamt = @justifiedamt + @thisamt
				select @runningbalance = @runningbalance - @thisamt
			end else if @thisamt < @runningbalance begin
				--only apply remainder of justification amount
				select @tr_total = @tr_total + @runningbalance
				if @age <= 30 begin
					select @tr_current = @tr_current + @runningbalance
				end else if @age <= 60 begin
					select @tr_over30 = @tr_over30 + @runningbalance
				end else if @age <= 70 begin
					select @tr_over60 = @tr_over60 + @runningbalance
				end else if @age <= 120 begin
					select @tr_over90 = @tr_over90 + @runningbalance
				end else begin
					select @tr_over120 = @tr_over120 + @runningbalance
				end	
				update #tempresults
					set tr_total = @tr_total, tr_current = @tr_current, tr_over30 = @tr_over30, tr_over60 = @tr_over60, tr_over90 = @tr_over90, tr_over120 = @tr_over120
					where std_number = @thisstdnumber
				select @justifiedamt = @justifiedamt + @thisamt
				select @runningbalance = @runningbalance - @thisamt
			end
			
			select 	@thisident = min(ident) from #deductionactivity where ident > @thisident
		end
			if @runningbalance < 0 begin
				--unjustified amount after applying all deductions
				insert #tempresults (pyh_payto, tr_total, descr, tr_current, tr_over30, tr_over60, tr_over90, tr_over120)
				values (@thispayto, @runningbalance, 'Unjustified arrears',@runningbalance,0,0,0,0)
			end

		delete #deductionactivity
	end
	
	--get next payto
	select @thispayto = min(pyh_payto) from #tempinfo where pyh_payto > @thispayto
end

--update percentages
update #tempresults
set 
	tr_totalpct		= cast( 100 as decimal(5,2)),
	tr_currentpct	= cast( tr_current/tr_total*100 as decimal(5,2)),
	tr_over30pct	= cast( tr_over30/tr_total*100 as decimal(5,2)),
	tr_over60pct	= cast( tr_over60/tr_total*100 as decimal(5,2)),
	tr_over90pct	= cast( tr_over90/tr_total*100 as decimal(5,2)),
	tr_over120pct	= cast( tr_over120/tr_total*100 as decimal(5,2))
where tr_total <> 0
update #tempresults
set 
	tr_totalpct		= cast( 100 as decimal(5,2)),
	tr_currentpct	= cast( 0 as decimal(5,2)),
	tr_over30pct	= cast( 0 as decimal(5,2)),
	tr_over60pct	= cast( 0 as decimal(5,2)),
	tr_over90pct	= cast( 0 as decimal(5,2)),
	tr_over120pct	= cast( 0 as decimal(5,2))
where tr_total = 0

update #tempresults set descr = s.std_description
from #tempresults t
join standingdeduction s on s.std_number = t.std_number


select * from #tempresults

GO
GRANT EXECUTE ON  [dbo].[Deduction_Arrears_Aging_sp] TO [public]
GO
