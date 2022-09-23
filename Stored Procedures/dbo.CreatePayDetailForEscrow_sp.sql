SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create procedure [dbo].[CreatePayDetailForEscrow_sp] (@p_asgn_type varchar(6), @p_asgn_id varchar(13), @p_sdm_itemcode varchar(6), @p_dec_amount money, @results varchar(100) OUTPUT)
AS

/**
 * DESCRIPTION:
 *
 *		This proc is used to create the pay detail that disburses funds from an escrow style standing deduction
 *
 * PARAMETERS:
 *
 *		@p_asgn_type varchar(6), 
 *		@p_asgn_id varchar(13), 
 *		@p_sdm_itemcode varchar(6), 
 *		@p_dec_amount money, 
 *		@results varchar(100) OUTPUT)
 *
 * RETURNS:
 *
 *		results are placed in the @results ouput parameter, Dollar amount if successful.
			'BADPTO, PTO not assigned to a tractor.  No pay detail created.'
			'BADDED, No such standing deduction for that asset.  No pay detail created.'
			'INSF, xxx.xx Insufficient funds.  No pay detail created.' where xxx.xx is the remaining funds in the escrow sccount.
			yyy.yy where yyy.yy is the amount of the successfully created pay detail
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
 		exec CreatePayDetailForEscrow_sp 'DRV', 'HANS', 'ESCPCT', 100.37, @results OUTPUT
		select @results
 *
 **/

declare 
		@asgn_type			varchar(6),
		@asgn_id			varchar(13),
		@PayType			varchar(6),
		@actg_type			char(1),
		@ap_glnum			char(32),
		@Apocalypse			datetime,
		@currency			varchar(6),
		@glnum				char(32),
		@payto				varchar(12),
		@pr_glnum			char(32),
		@pyd_number			int,
		@pyd_sequence		int,
		@pyd_description	varchar(75),
		@pyt_minus			int,
		@pyt_rateunit		varchar(6),
		@pyt_unit			varchar(6),
		@spyt_minus			char(1),
		@std_number			int,
		@pyr_ratecode		varchar(20),
		@currentbalance		money, 
		@sumpending				money
SET NOCOUNT ON

	SELECT @Apocalypse = gi_date1
	FROM generalinfo
	WHERE gi_name = 'APOCALYPSE'

	If @Apocalypse is null  
		select @Apocalypse = convert(datetime,'20491231 23:59:59')

	if @p_asgn_type = 'PTO' begin
		--Payto pay details are really tractor pay details
		select @asgn_type = 'TRC'
		select @asgn_id = min(trc_number) from tractorprofile where trc_owner = @p_asgn_id and trc_retiredate > GETDATE()
		if @asgn_id is null begin
			select @results = 'BADPTO, PTO not assigned to a tractor.  No pay detail created.'
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
		select @results = 'BADDED, No such standing deduction for that asset.  No pay detail created.'
		return
	end
	
	--check balance (with outstanding pay details)
	select @currentbalance = std_startbalance - std_balance from standingdeduction d
	join stdmaster m on m.sdm_itemcode = d.sdm_itemcode
	where std_number = @std_number
	select @sumpending = SUM(pyd_amount) from paydetail 
	where asgn_type = @asgn_type and asgn_id = @p_asgn_id and pyd_status = 'PND' and std_number_adj = @std_number
if @sumpending is not null select @currentbalance = @currentbalance - @sumpending

	if @p_dec_amount > @currentbalance begin
		select @results = 'INSF, ' + cast(@currentbalance as varchar(20)) + ' Insufficient funds.  No pay detail created.'
		return
	end
	
	select @PayType = m.pyt_itemcode, @pyd_description = d.std_description
	from standingdeduction d
	join stdmaster m on  m.sdm_itemcode = d.sdm_itemcode
	where d.std_number = @std_number
	
	
	
	SELECT  @pyt_rateunit = ISNULL(pyt_rateunit,''),
			@pyt_unit = ISNULL(pyt_unit,''),
			@pr_glnum = ISNULL(pyt_pr_glnum,''),
			@ap_glnum = ISNULL(pyt_ap_glnum,''),
			@spyt_minus = ISNULL(pyt_minus,''),
			@pyr_ratecode = ISNULL(pyt_basisunit,'')
	FROM 	paytype
	WHERE 	pyt_itemcode = @PayType
	
	if @actg_type = 'P' select @glnum = @pr_glnum else select @glnum = @ap_glnum
	

	SELECT @pyt_minus = 1	-- default to 1
	IF @spyt_minus = 'Y'
		SELECT @pyt_minus = -1
	
	-- Get the next pyd_number from the systemnumber table
	EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM',''

	INSERT INTO paydetail  
			(pyd_number,
			pyh_number,
			lgh_number,
			asgn_number,
			asgn_type,		--5

			asgn_id,
			
			pyd_prorap,
			pyd_payto,
			pyt_itemcode,	--10

			mov_number,
			pyd_description,
			pyd_quantity,
			pyd_rateunit,
			pyd_unit,		--15

			pyd_rate,
			pyd_amount,
			pyd_pretax,
			pyd_glnum,
			pyd_currency,	--20

			pyd_status,
			pyd_transdate,
			pyd_minus,
			pyd_sequence,
						--25

			pyd_loadstate,


			pyt_fee1,
			pyt_fee2,		--30

			pyd_grossamount,

			pyd_updatedby,
			pyd_updatedon,
						--35
			
			pyh_payperiod,
			pyd_workperiod,
			std_number_adj,
			std_number, 
			pyd_vendorpay,
			pyd_updsrc,
			
			pyr_ratecode,
			ord_hdrnumber,
			psd_id
			)
VALUES (@pyd_number,
		0,
		0,
		0,
		@asgn_type,							--5

		@asgn_id,

		@actg_type,
		@payto,
		@PayType,								--10

		0,				--mov_number
		@pyd_description,
		-1,				--pyd_quantity
		@pyt_rateunit,
		@pyt_unit,								--15

		@p_dec_amount,	--pyt_rate,
		@p_dec_amount,	--pyt_amount
		'E',				--pyd_pretax
		@glnum,
		@currency,								--20

		'PND',			--pyd_status
		GETDATE(),		--pyd_transdate
		@pyt_minus,
		@pyd_sequence,	
				--25

		'NA',			--pyd_loadstate

	
		0,				--pyt_fee1
		0,				--pyt_fee2				--30

		0,				--pyd_grossamount	

		suser_sname(),	--pyd_updatedby
		GETDATE(),		--pyd_updatedon
												--35
		
		@Apocalypse,	--pyh_payperiod
		@Apocalypse,	--pyd_workperiod
		@std_number,	--std_number_adj
		@std_number,	--std_number
		'N',			--pyd_vendorpay
		'M',			--pyd_updsrc
		
		@pyr_ratecode,	--pyr_ratecode
		0,				--ord_hdrnumber
		0				--psd_id
		)

		select @results = cast(@p_dec_amount as varchar(100))

GO
GRANT EXECUTE ON  [dbo].[CreatePayDetailForEscrow_sp] TO [public]
GO
