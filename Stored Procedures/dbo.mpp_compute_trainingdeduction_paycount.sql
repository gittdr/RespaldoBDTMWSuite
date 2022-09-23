SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
*	PTS 36333 - DJM - Procedure created to determine how many Deduction
*		payments are required based on the eff_date and the pay period date.
*		Assumes one payperiod per week.
*/

Create procedure [dbo].[mpp_compute_trainingdeduction_paycount] 
	@drv_id varchar(10), 
	@payperiod datetime, 
	@reimbursement_count int OUT

as

DECLARE @mpp TABLE(
	mpp_id						varchar(8)	not null,   
	mpp_type					varchar(6)	null,   
	mpp_eff_date				datetime null,   
	mpp_tuitioncost				Decimal(18,2) null,   
	mpp_forgive_amt				Decimal(18,2) null,   
	mpp_forgive_week_crd_amt	Decimal(18,2) null,   
	mpp_forgive_period			int null,   
	mpp_contribution_amt		Decimal(18,2) null,   
	mpp_cont_period				int null,   
	mpp_cont_week_amt			Decimal(18,2) null, 
	mpp_forgive_crd_nbr			int null,   
	mpp_cont_ded_nbr			int null,   
	mpp_eligible_start_date		datetime null,  
	mpp_tuition_acct_status		char(1) null,   
	mpp_train_anv_bonus_pd		datetime null,  
	mpp_forgive_remain_balance	Decimal(18,2) null,
	mpp_cont_remain_balance		Decimal(18,2) null,  
	mpp_train_anv_bonus_amt		Decimal(18,2) null
	)

insert into @mpp
Select manpowerprofile.mpp_id   
	,manpowerprofile.mpp_type   
	,manpowerprofile.mpp_eff_date   
	,manpowerprofile.mpp_tuitioncost   
	,manpowerprofile.mpp_forgive_amt   
	,manpowerprofile.mpp_forgive_week_crd_amt   
	,manpowerprofile.mpp_forgive_period   
	,manpowerprofile.mpp_contribution_amt   
	,manpowerprofile.mpp_cont_period   
	,manpowerprofile.mpp_cont_week_amt   
	,manpowerprofile.mpp_forgive_crd_nbr   
	,manpowerprofile.mpp_cont_ded_nbr   
	,manpowerprofile.mpp_eligible_start_date  
	,manpowerprofile.mpp_tuition_acct_status   
	,manpowerprofile.mpp_train_anv_bonus_pd   
	,manpowerprofile.mpp_forgive_remain_balance   
	,manpowerprofile.mpp_cont_remain_balance
	,manpowerprofile.mpp_train_anv_bonus_amt
FROM manpowerprofile   
where manpowerprofile.mpp_tuition_acct_status = 'O' and
	manpowerprofile.mpp_eff_date <= @payperiod
	and manpowerprofile.mpp_id = @drv_id

Select @reimbursement_count = 0

/*	
*		Compute how many Reimbursement Payments are owed for the passed Payperiod.
*/
If exists (select 1 from @mpp where mpp_id = @drv_id) 
Begin
	Declare @startdate	datetime,
		@wk_diff		int,
		@wk_count		int,
		@ded_count		int,
		@period_count	int,
		@remaining_con	decimal(18,2),
		@contribuion_amt	decimal(18,2)

	select @startdate = mpp_eligible_start_date 
		,@ded_count = mpp_cont_ded_nbr
		,@period_count = mpp_cont_period
		,@contribuion_amt = mpp_cont_week_amt
		,@remaining_con = mpp_cont_remain_balance
	from @mpp 
	where mpp_id = @drv_id

	select @wk_diff = DateDiff(wk, @startdate, @payperiod) + 1
	if @wk_diff < 1 
		Return 0

	if @wk_diff > @period_count 
		select @wk_diff = @period_count
	
	select @reimbursement_count = @wk_diff - @ded_count
	if @reimbursement_count < 1 
		Return 0
End


GO
GRANT EXECUTE ON  [dbo].[mpp_compute_trainingdeduction_paycount] TO [public]
GO
