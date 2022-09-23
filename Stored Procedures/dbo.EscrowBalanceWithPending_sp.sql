SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create procedure [dbo].[EscrowBalanceWithPending_sp] (@p_asgn_type varchar(6), @p_asgn_id varchar(13), @p_sdm_itemcode varchar(6), @p_dec_balance money OUTPUT, @results varchar(100) OUTPUT)
AS

/**
 * DESCRIPTION:
 *
 *		This proc is used to show the balance on an escrow style standing
 *		deduction, including any pending pay details for withholdings and
 *		disbursements
 *
 * PARAMETERS:
 *
 *		@p_asgn_type varchar(6), 
 *		@p_asgn_id varchar(13), 
 *		@p_sdm_itemcode varchar(6), 
 *		@p_dec_balance money OUTPUT,
 *		@results varchar(100) OUTPUT
 *
 * RETURNS:
 *
 *		balance is placed in the @p_dec_balance ouput parameter, Dollar amount if successful.
 *
 * RESULT SETS:
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 *
 * vjh 59637 created
 *
 * SAMPLE CALL:
 *
		declare @results varchar(100)
		declare @p_dec_balance money
 		exec EscrowBalanceWithPending_sp 'DRV', 'HANS', 'MAINTE', @p_dec_balance OUTPUT, @results OUTPUT
		select @p_dec_balance, @results
 *
 **/
 
 declare 
		@asgn_type			varchar(6),
		@asgn_id			varchar(13),
		@PayType			varchar(6),
		@actg_type			char(1),
		@payto				varchar(12),
		@std_number			int,
		@currentbalance		money, 
		@sumpending				money
 
 	if @p_asgn_type = 'PTO' begin
		--Payto pay details are really tractor pay details
		select @asgn_type = 'TRC'
		select @asgn_id = min(trc_number) from tractorprofile where trc_owner = @p_asgn_id and trc_retiredate > GETDATE()
		if @asgn_id is null begin
			select @results = 'BADPTO, PTO not assigned to a tractor.  No pay detail created.'
			select @p_dec_balance=null
			return
		end
	end else begin
		select @asgn_type = @p_asgn_type
		select @asgn_id = @p_asgn_id
	end
	exec dbo.getpayto_sp @asgn_type, @asgn_id, @payto OUTPUT, @actg_type OUTPUT

	select @std_number = min(std_number)
	from standingdeduction d
	join stdmaster m on  m.sdm_itemcode = d.sdm_itemcode
	where d.asgn_type = @asgn_type and d.asgn_id = @p_asgn_id
	and d.sdm_itemcode = @p_sdm_itemcode

	if @std_number is null begin
		select @results = 'BADDED, No such standing deduction for that asset.'
		select @p_dec_balance=null
		return
	end

	--check balance (with outstanding pay details)
	select @currentbalance = std_startbalance - std_balance from standingdeduction d
	join stdmaster m on m.sdm_itemcode = d.sdm_itemcode
	where std_number = @std_number
	select @sumpending = SUM(pyd_amount) from paydetail 
	where asgn_type = @asgn_type and asgn_id = @p_asgn_id and pyd_status = 'PND' and std_number_adj = @std_number
if @sumpending is not null select @currentbalance = @currentbalance - @sumpending


select @p_dec_balance= @currentbalance


GO
GRANT EXECUTE ON  [dbo].[EscrowBalanceWithPending_sp] TO [public]
GO
