SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE        procedure [dbo].[settlement_precollect_process_svcustom] (	@pl_pyhnumber int , 
								@ps_asgn_type varchar(6),
								@ps_asgn_id varchar(13),
								@pdt_payperiod datetime)
as

declare @ldt_lastpayperiod datetime, 
	@li_numdays int,
	@ldec_daily float,
	@li_ctr int

declare	@ls_revtype1 varchar(6), 
	@ldec_daily_min float, 
	@ldec_period float, 
	@ldec_period_min money, 
	@ldec_qty float,
	@ldec_hold money		

declare @ll_pyd int,
	@ldec_hourlyrate money 

declare @ldec_rate money, 
	@ldec_amount money,
	@ls_paytype varchar(6),
	@ls_payto varchar(12),
	@li_id int 

declare @ls_dailyminpaytype varchar(6),
	@ls_periodminpaytype varchar(6),
	@ls_dailyguarpaytype varchar(6),
	@ls_periodguarpaytype varchar(6)

declare @li_tret int , 
	@li_ret int -- return 1 if we added hourlypay, 2 if we added hourly and did the compare routine. 

declare @ldt_hourlypaydate datetime

declare	@lt_otr_orders table (	oo_table_key int identity (1,1),
				ord_hdrnumber int)

declare	@ls_otr_orders_string varchar(30),
	@li_otr_count int

create table #temp(	temp_id int identity not null,
			pyt_itemcode varchar(6) not null, 
			pyd_quantity float not null, 
			pyd_rate money null,
			pyd_amount money null,
			work_date datetime null)	

select 	@li_tret = 0,
	@li_ret = 0

/*	@ls_dailyminpaytype = 	pay code used when adding paydetails to bring Kronos transactions 
				up to the minimum guaranteed hours.
	@ls_dailyguarpaytype = 	pay code used when adding paydetails to bring a day's work up the 
				minimum guaranteed pay for the day. */
select 	@ls_dailyminpaytype = gi_string1,	
	@ls_dailyguarpaytype = gi_string2 
from 	generalinfo 
where 	gi_name = 'DailyMinHourlyPayType'

/*	@ls_periodminpaytype = 	pay code used when adding pay details to bring an hourly driver's
				pay up to the minimum guaranteed weekly hours.
	@ls_periodguarpaytype= 	pay code used when adding pay details to bring an OTR driver's 
				pay up to the minimum guaranteed period pay amount. */
select 	@ls_periodminpaytype = gi_string1,
	@ls_periodguarpaytype = gi_string2
from 	generalinfo 
where 	gi_name = 'PeriodMinHourlyPayType'

/*	If the daily and period pay types were not filled in by the previous select
	statements, use "HR" as a default. If the guarantee pay types were not
	filled in, use "GUAR" as a default. */
select 	@ls_dailyminpaytype = isnull(@ls_dailyminpaytype, 'HR')

select 	@ls_periodminpaytype = isnull(@ls_periodminpaytype, 'HR')
				 
select 	@ls_dailyguarpaytype = isnull(@ls_dailyguarpaytype, 'GUAR')

select 	@ls_periodguarpaytype = isnull(@ls_periodguarpaytype, 'GUAR')

/*	Check to make sure that the asset being paid is a driver. */
if 	@ps_asgn_type <> 'DRV'
begin
	raiserror('Only resource type of driver can have the minimum hours computation', 16, 1)
	return -1
end

/*	Determine the last date on which this driver was paid. This will be used later when
	checking to make sure that the period guarantee hours or pay requirments are met. */
select  @ldt_lastpayperiod = max(pyh_payperiod) 
from 	payheader a
where 	a.asgn_type = @ps_asgn_type 
and 	a.asgn_id = @ps_asgn_id 
and 	pyh_payperiod < @pdt_payperiod

/* 	Determine the branch id for this driver by looking at the ord_revtype1
	for the trips in the current payperiod. */
select 	@ls_revtype1 = min(ord_revtype1) 
from 	orderheader a, legheader b
where 	a.ord_hdrnumber = b.ord_hdrnumber 
and 	(b.lgh_driver1 = @ps_asgn_id or b.lgh_driver2 = @ps_asgn_id) 
and	lgh_startdate between @ldt_lastpayperiod and @pdt_payperiod

/* 	If there are no trips in the current payperiod, search older 
	history to determine the order revtype1. */
if @ls_revtype1 is null 
begin
	select 	top 1
		@ls_revtype1 = ord_revtype1 
	from 	orderheader a, legheader b
	where 	a.ord_hdrnumber = b.ord_hdrnumber 
	and 	(b.lgh_driver1 = @ps_asgn_id  or b.lgh_driver2 = @ps_asgn_id) 
end

/*	Get the daily guaranteed hours, the period guaranteed hours, and the hourly
	rate from the manpowerprofile record. */
select 	@ldec_daily_min = convert(float,mpp_dailyguarenteedhours), 
	@ldec_period_min = mpp_periodguarenteedhours,
	@ldec_hourlyrate = mpp_hourlyrate
from 	manpowerprofile 
where 	mpp_id = @ps_asgn_id

/*	If the manpowerprofile record didn't have a daily guaranteed hours,
	a weekly guaranteed hours, or an hourly rate, get that from the branch
	record instead. */
if isnull(@ldec_daily_min, 0) = 0 
	select 	@ldec_daily_min = convert(float,brn_dailyguarenteedhours)
	from 	branch 
	where 	brn_id = @ls_revtype1

if isnull(@ldec_period_min, 0) = 0 
	select  @ldec_period_min = brn_periodguarenteedhours 
	from 	branch 
	where 	brn_id = @ls_revtype1

if isnull(@ldec_hourlyrate, 0) = 0 
	select 	@ldec_hourlyrate = brn_hourlyrate 
	from 	branch 
	where 	brn_id = @ls_revtype1

/*	If there are still no values for daily guaranteed hours, weekly guaranteed 
	hours, or hourly rate, then generate an error message. */
if @ldec_daily_min is null or @ldec_period_min is null or @ldec_hourlyrate is null 
begin
	if @ls_revtype1 is null 
	begin
		raiserror ('Could not determine the branch for this resource.', 16, 1)
		return -1
	end
end

/*	Get the total quantity of existing time-based paydetails for this payperiod
	and store it in the variable @ldec_period. 
	NOTE: this section of the code assumes a weekly pay period. */
select 	@ldec_period  = isnull(sum(pyd_quantity), 0) 
from 	paydetail a, paytype b 
where  	a.asgn_type = @ps_asgn_type 
and 	a.asgn_id = @ps_asgn_id 
and  	a.pyt_itemcode = b.pyt_itemcode 
and 	b.pyt_basisunit = 'TIM'	
and 	(convert(varchar(8), a.pyh_payperiod, 101) = convert(varchar(8), @pdt_payperiod, 101)
     or a.pyh_payperiod = '20491231' and a.pyd_hourlypaydate between dateadd(d, -6, @pdt_payperiod) and @pdt_payperiod)

/*	Update the rate and the amount (quantity * rate) on time-based
	paydetails where the hourly rate is zero. */
if @ldec_hourlyrate > 0 
	update 	paydetail 
	set 	pyd_rate = @ldec_hourlyrate,
		pyd_amount = pyd_quantity * @ldec_hourlyrate 
	from   	paytype b
	where 	(pyh_payperiod = @pdt_payperiod
	      or pyh_payperiod = '20491231'
	     and pyd_hourlypaydate between dateadd(d, -6, @pdt_payperiod) and @pdt_payperiod)
	and 	pyd_rate = 0 
	and 	paydetail.pyt_itemcode = b.pyt_itemcode 
	and	b.pyt_basisunit = 'TIM'

if exists (	select 	'x' 
		from 	paydetail d
		where	(pyh_payperiod = @pdt_payperiod
	      or pyh_payperiod = '20491231'
	     and pyd_hourlypaydate between dateadd(d, -6, @pdt_payperiod) and @pdt_payperiod)
		and	d.pyd_rate <> 0
		and	d.pyd_quantity <> 0
		and	(d.pyd_amount = 0 or d.pyd_amount is null) )
	update	paydetail
	set	pyd_amount = pyd_rate * pyd_quantity
	where	(pyh_payperiod = @pdt_payperiod
	      or pyh_payperiod = '20491231'
	     and pyd_hourlypaydate between dateadd(d, -6, @pdt_payperiod) and @pdt_payperiod)
	and	pyd_rate <> 0
	and	pyd_quantity <> 0
	and	(pyd_amount = 0 or pyd_amount is null)

if @ldt_lastpayperiod < @pdt_payperiod
begin	
	/*	@li_numdays is the number of days between the last period in 
		which this driver was paid and the current payperiod. */
	select 	@li_numdays = datediff(dd, @ldt_lastpayperiod, @pdt_payperiod)
	
	/*	Now step through each date between the last time the driver
		was paid and the end of the current payperiod. */
	select 	@li_ctr = 0
	
	while 	@li_ctr  < @li_numdays
	begin
		select 	@li_ctr = @li_ctr + 1
					
		/*	@ldec_daily is the total quantity of paydetails for
			that workdate that came from Kronos. */
		select 	@ldec_daily = isnull(sum(a.pyd_quantity), 0) 
		from 	paydetail a, sv_kronos_import b, paytype c
		where 	a.pyd_number = b.pyd_number 
		and 	a.asgn_type = @ps_asgn_type 
		and 	a.asgn_id = @ps_asgn_id 
		and 	a.asgn_id = b.drv_id 
		and	a.pyt_itemcode = c.pyt_itemcode 
		and 	c.pyt_basisunit = 'TIM'	
		and	convert(varchar(8), b.work_date, 1) = convert(varchar(8), dateadd(dd, @li_ctr, @ldt_lastpayperiod), 1)

		/*	If there are any Kronos hours (@ldec_daily > 0), and there are NO
			non-Kronos paydetails for that date, then compare the quantity to 
			the minimum daily hours. If it is below the minimum, add a line to 
			a temporary table for the difference.

			NOTE: If there ARE non-Kronos paydetails, we will be checking
			the pay for the day again later and adding a single line using the
			guarantee pay code instead of the hourly pay code if necessary to bring
			the day up to the minimum.
			
			NOTE: sick/vacation/personal time would be created by the driver 

			calendar rollover program and do not need to be considered here. */
		if @ldec_daily > 0 and not exists (	select *
							from 	paydetail a, legheader b 
							where 	a.lgh_number = b.lgh_number 
							and	a.asgn_type = @ps_asgn_type 
							and 	a.asgn_id = @ps_asgn_id 
							and 	convert(varchar(8), b.lgh_enddate, 1) = convert(varchar(8), dateadd(dd, @li_ctr, @ldt_lastpayperiod), 1))
		begin
			if @ldec_daily < @ldec_daily_min 
			begin
				select @ldec_qty = @ldec_daily_min - @ldec_daily

				insert into #temp (	pyt_itemcode,
							pyd_quantity,
							pyd_rate,
							pyd_amount,
							work_date) 
					select 	@ls_dailyminpaytype,
						@ldec_qty, 
						@ldec_hourlyrate,
						@ldec_qty * @ldec_hourlyrate,
						convert(varchar(8), dateadd(dd, @li_ctr, @ldt_lastpayperiod), 1)
			end
		end
	end

	/*	Now step through #temp and create the paydetails lines. */
	if exists (select * from #temp)
	begin
		select 	@li_ret = @li_ret + 1

		select 	@li_id = 0

		while 1 = 1 
		begin
			select 	@li_id = min(temp_id) 
			from 	#temp 
			where 	temp_id > @li_id

			if @li_id is null
				break

			select 	@ldec_qty = pyd_quantity, 
				@ldec_rate = pyd_rate,
				@ldec_amount = pyd_amount,
				@ls_paytype =pyt_itemcode,
				@ldt_hourlypaydate = work_date 
			from 	#temp 
			where 	temp_id = @li_id

			exec 	create_hourlypay_svcustom_sp  	@pl_pyhnumber, @ldec_qty, @ldec_rate, @ldec_amount,
				 				@ls_paytype, @ps_asgn_type, @ps_asgn_id,@ls_payto, 
								@ldt_hourlypaydate, 'Daily minimum added during collect'
		end 
	end 
end -- check for prior payperiod

/*	The rest of this stored procedure does the comparison between OTR pay 
	and Hourly pay. (SR 21111) */
declare @ls_drvtype1 varchar(6),
	@ls_compareflag char(1),
	@ldec_otrpay money,
	@ldec_hourlypay money,
	@ldec_calchourlypay money

declare @ldec_newhourlypay money,
	@ldec_hours money

/*	Get the driver's type1 from manpowerprofile. */
select 	@ls_drvtype1 = mpp_type1 
from 	manpowerprofile 
where 	mpp_id = @ps_asgn_id

/*	Check the branch_drivertype1 table to see whether this driver's
	pay should be based on the higher or lower of hourly pay or over
	the road components, or if no comparison should be made at all. */
select 	@ls_compareflag = bdt_comparisonflag
from 	branch_drivertype1 
where 	brn_id = @ls_revtype1 
and 	mpp_type1 = @ls_drvtype1

/*	If there was no comparison flag for the driver type 1, then get
	it from the branch record. */
if @ls_compareflag is null
	select 	@ls_compareflag = brn_comparisonflag 
	from 	branch 
	where 	brn_id = @ls_revtype1

if @ldt_lastpayperiod < @pdt_payperiod
begin	
	select 	@li_numdays = datediff(dd, @ldt_lastpayperiod,@pdt_payperiod)

	select 	@li_ctr = 0

	-- Add kronos daily minimum pay.
	while 	@li_ctr  < @li_numdays
	begin
		select 	@li_ctr = @li_ctr + 1

		/*	Build a list of all order numbers for the workdate. This will
			be used if we need to add a paydetail line. The description
			will indicate what orders are being supplemented or replaced
			with guarantee or hourly pay. */
		select	@ls_otr_orders_string = ' ',
			@li_otr_count = ' '

		delete from @lt_otr_orders

		insert into @lt_otr_orders
			select distinct a.ord_hdrnumber
			from 	paydetail a, legheader b 
			where 	a.lgh_number = b.lgh_number 
			and	a.asgn_type = @ps_asgn_type 
			and 	a.asgn_id = @ps_asgn_id 
			and 	convert(varchar(8), b.lgh_startdate, 1) = convert(varchar(8), dateadd(dd, @li_ctr, @ldt_lastpayperiod), 1)	

		while exists (select 'x' from @lt_otr_orders where oo_table_key > @li_otr_count)
		begin
			select	@li_otr_count = min(oo_table_key)
			from	@lt_otr_orders
			where	oo_table_key > @li_otr_count

			if @ls_otr_orders_string = ' '
				select	@ls_otr_orders_string = convert(varchar,ord_hdrnumber)
				from	@lt_otr_orders
				where	oo_table_key = @li_otr_count
			else
				select	@ls_otr_orders_string = @ls_otr_orders_string + ', ' 
						+ convert(varchar,ord_hdrnumber)
				from	@lt_otr_orders
				where	oo_table_key = @li_otr_count
		end

		/*	@ldec_otrpay is the sum of all paydetails associated with orders
			that ended on the workdate we are evaluating. 
			NOTE: end date is being used because of Sunday trips that are
			actually dispatched Saturday afternoon. Might need to reevaluate
			this. */
		if exists (select 'x' from @lt_otr_orders)
		begin
			select 	@ldec_otrpay = isnull(sum(pyd_amount), 0) 
			from 	paydetail a, legheader b 
			where 	a.lgh_number = b.lgh_number 
			and	a.asgn_type = @ps_asgn_type 
			and 	a.asgn_id = @ps_asgn_id 
			and 	convert(varchar(8), b.lgh_startdate, 1) = convert(varchar(8), dateadd(dd, @li_ctr, @ldt_lastpayperiod), 1)	
			
			/*	@ldec_hourlypay is the sum of the amount of all hourly pay details, 
				and @ldec_hours is the sum of the quantity of all hourly pay 
				details, for the workdate we are evaluating. */
			select 	@ldec_hourlypay = isnull(sum(pyd_amount), 0), 
				@ldec_hours = isnull(sum(pyd_quantity), 0) 
			from 	paydetail 
			where 	asgn_type = @ps_asgn_type 
			and 	asgn_id = @ps_asgn_id 
			and 	convert(varchar(8), pyd_hourlypaydate, 1) = convert(varchar(8), dateadd(dd, @li_ctr, @ldt_lastpayperiod), 1) 
		 	and 	lgh_number = 0
			and not pyd_adj_flag = 'Y'	
	
			/* 	Now add in the hourly pay details in #temp. */
			select	@ldec_hourlypay = @ldec_hourlypay + isnull(sum(pyd_amount),0),
				@ldec_hours = isnull(sum(pyd_quantity),0)
			from	#temp
			where	work_date = dateadd(dd, @li_ctr, @ldt_lastpayperiod)
					
			/*	Add @ldec_hourlypay to @ldec_otrpay so that we are evaluating the
				total pay for the day against the daily guaranteed minimum. */
			select	@ldec_otrpay = @ldec_otrpay + @ldec_hourlypay
			
			/*	@ldec_calchourlypay is the daily amount against which the existing
				paydetails will be compared, calculated by multiplying the daily 
				minumum quantity by the hourly rate. */
			select 	@ldec_calchourlypay = @ldec_daily_min * @ldec_hourlyrate
	
			select 	@ldt_hourlypaydate = dateadd(dd, @li_ctr, @ldt_lastpayperiod)			
	
			/*	If the sum of existing pay details is greater than 0 and is
				not equal to the calculated daily amount, then take action based
				on the comparison flag settings. */
			if @ldec_calchourlypay <> @ldec_otrpay 	and @ldec_otrpay > 0				
			begin	
				/*	If the comparison flag indicates that the higher of OTR or hourly
					should be used, then add a pay line using the guarantee pay type
					for the difference. The description for the guarantee pay detail
					will include the order numbers that were evaluated. */
				if @ls_compareflag = 'H' 
				begin
					if @ldec_calchourlypay > @ldec_otrpay
					begin
						select 	@ldec_qty = 1, 
							@ldec_rate = @ldec_calchourlypay - @ldec_otrpay,
							@ls_paytype = @ls_dailyguarpaytype 
	
						select 	@ldec_amount = @ldec_qty * @ldec_rate
	
						if @ldec_qty > 0 
						begin
							select	@ls_otr_orders_string = 'Guarantee for Order(s) #'+ @ls_otr_orders_string
	
							insert 	#temp (	pyt_itemcode, 
									pyd_quantity, 
									pyd_rate,
									pyd_amount,
									work_date)
							values (	@ls_paytype,
									@ldec_qty, 
									@ldec_rate, 
									@ldec_amount, 
									@ldt_hourlypaydate)

							exec create_hourlypay_svcustom_sp	@pl_pyhnumber, @ldec_qty, @ldec_rate, @ldec_amount,
												@ls_paytype, @ps_asgn_type, @ps_asgn_id, @ls_payto, 
												@ldt_hourlypaydate, @ls_otr_orders_string
						end
					end			
	
				end
				/*	If the comparison flag indicates that the lower of existing pay details
					or the calculated pay should be used, then delete the existing pay lines
					and create a pay detail line for hourly pay instead. */
				else if @ls_compareflag = 'L'
				begin
					if @ldec_calchourlypay < @ldec_otrpay
					begin
						if @ldec_daily_min > @ldec_hours 
						begin
							select 	@ldec_qty = @ldec_daily_min - @ldec_hours, 
								@ldec_rate = @ldec_hourlyrate,
								@ls_paytype =@ls_dailyminpaytype 
	
							select 	@ldec_amount = @ldec_qty * @ldec_rate
	
							select	@ls_otr_orders_string = 'Replaced OTR pay for Order(s)'+ @ls_otr_orders_string
	
							exec 	create_hourlypay_svcustom_sp	@pl_pyhnumber, @ldec_qty, @ldec_rate, @ldec_amount,
												@ls_paytype, @ps_asgn_type, @ps_asgn_id, @ls_payto, 
												@ldt_hourlypaydate, @ls_otr_orders_string
						end
	
						insert into paydetail_moves 
							select 	pyd_number, 
								a.mov_number 
							from 	paydetail a,legheader b 
							where 	asgn_type = @ps_asgn_type 
							and 	asgn_id = @ps_asgn_id 
							and 	a.lgh_number = b.lgh_number 
							and	convert(varchar(8), b.lgh_startdate, 1) = convert(varchar(8), dateadd(dd, @li_ctr, @ldt_lastpayperiod), 1)	
							and not exists (select * from paydetail_moves c where a.pyd_number = c.pyd_number)
	
						delete 	paydetail 
						from 	legheader b 
						where 	asgn_type = @ps_asgn_type 
						and 	asgn_id = @ps_asgn_id 
						and 	paydetail.lgh_number = b.lgh_number 
						and	convert(varchar(8), b.lgh_startdate, 1) = convert(varchar(8), dateadd(dd, @li_ctr, @ldt_lastpayperiod), 1)	
					end
				end			
			end
		end
	end 

	/*	If the driver doesn't have any sick, vacation, or personal time during the period,
		check to make sure that the sum of paydetails (not counting adjustments) is
		equal to the weekly minimum hours times the rate. If not, add a paydetail line for that. */
	if not exists (	select 'x' 
			from 	paydetail
			where 	asgn_type = @ps_asgn_type
			and	asgn_id = @ps_asgn_id
			and	(pyh_payperiod = @pdt_payperiod
	      			or pyh_payperiod = '20491231'
	     			and pyd_hourlypaydate between dateadd(d, -6, @pdt_payperiod) and @pdt_payperiod)
			and	pyt_itemcode in ('PD','SICK','SICKN','VAC'))
	begin
		select	@ldec_hold = isnull(sum(pyd_amount),0)
		from	#temp

		select	@ldec_period = sum(pyd_amount)
		from 	paydetail
		where 	asgn_type = @ps_asgn_type
		and	asgn_id = @ps_asgn_id
		and	(pyh_payperiod = @pdt_payperiod
	      		or pyh_payperiod = '20491231'
	     		and pyd_hourlypaydate between dateadd(d, -6, @pdt_payperiod) and @pdt_payperiod)
		and 	(pyd_adj_flag = 'N' or pyd_adj_flag is null)

		select	@ldec_period = @ldec_period + @ldec_hold

		if	@ldec_period < @ldec_hourlyrate * @ldec_period_min
		begin
			select 	@ldec_qty = (@ldec_hourlyrate * @ldec_period_min) - @ldec_period

			exec 	create_hourlypay_svcustom_sp	@pl_pyhnumber, @ldec_qty, 1, @ldec_qty,
								@ls_periodguarpaytype, @ps_asgn_type, @ps_asgn_id, @ls_payto, 
								@ldt_hourlypaydate, 'Weekly guarantee added during collect'
		end
	end

	If @li_ctr > 0 
		select 	@li_ret = @li_ret + 1
end

return @li_ret 

GO
GRANT EXECUTE ON  [dbo].[settlement_precollect_process_svcustom] TO [public]
GO
