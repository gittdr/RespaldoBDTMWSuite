SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[settlement_precollect_process_DRVMIN](	@pl_pyhnumber int , @ps_asgn_type varchar(6),@ps_asgn_id varchar(13) ,
														@pdt_payperiod datetime, @psd_id int , @ps_returnmsg varchar(255) OUT)
as
/**
 * 
 * NAME:
 * settlement_precollect_process_DRVMIN
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Creates custom paydetails tied to a payheader for a payperiod based on required  Minimums
 *
 * RETURNS:
 * 1 success -1 error
 *
 * RESULT SETS: 
*   None *
 * PARAMETERS:
 * 001 - @pl_pyhnumber int 
 * 002 - @ps_asgn_type varchar(6)
 * 003 - @ps_asgn_id varchar(13)
 * 004 - @pdt_payperiod datetime
 * 005 - @psd_id int batch id
 * 006 - @ps_returnmsg varchar(255) OUTPUT
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 *
 * 10/14/2008	DJM		PTS 43872	Miller Transfer.  Added for processing Minimum requirements on Round Trip Dispatches.
 * 4/7/20909	DJM					Modified to set std_number = -1. This causes the record to be deleted automatically when the Payheader is re-opened
 *										after a collect.  Per Dale and Betty, this is a requirement of the process??. The f_unreleasepay function in
 *										settlements performs the actual delete.
 *
 **/
declare @PayType varchar(6),
		@actg_type char(1),
		@ap_glnum char(32),
		@Apocalypse datetime,		
		@asgn_id varchar(13),
		@asgn_number int,
		@currency varchar(6),
		@glnum char(32),
		@iFlags int,
		@Lgh int,
		@lgh_endcity int,
		@lgh_endpoint varchar(12),
		@lgh_startcity int,
		@lgh_startpoint varchar(12),
		@mov int,
		@ordhdr int,
		@payto varchar(12),
		@pr_glnum char(32),
		@pyd_number int,
		@pyd_number_test int,
		@pyd_quantity_test float,
		@pyd_sequence int,
		@pyt_description varchar(75),
		@pyt_minus int,
		@pyt_pretax char(1),
		@pyt_rateunit varchar(6),
		@pyt_unit varchar(6),
		@Quantity int,
		@spyt_minus char(1),
		@asgn_type varchar(6),
		@pyd_transdate datetime,
		@ps_payto varchar(8),
		@pdec_rate decimal(15,8),
		@pdec_amount decimal(15,8),
		@ls_revtype1 varchar(6),
		@ldt_lastpayperiod datetime,
		@minpayamt			money,
		@minpayincrement	integer,
		@minpaydaynumber	integer,
		@ineligible_days	integer,
		@computed_min		decimal(10,2),
		@logcompute			char(1),
		@pyd_description	varchar(75),
		@ineligible_start	datetime,
		@ineligible_end		datetime,
		@totallegpay		money,
		@totalmiscpay		money,
		@totalpay			money,
		@minpaypd			datetime,
		@excludedrvtype		varchar(60)


Declare	@seq	int
Declare @err_batch	int,
	@err_msg		varchar(256)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

-- Verify that the asset is a Company Driver
if @ps_asgn_type <> 'DRV'
	Return 0

if not exists (select 1 from Manpowerprofile where mpp_id = @ps_asgn_id and mpp_actg_type = 'P')
	Return 0

-- Verify that the Asset is not in the 30 probationary period
if exists (select 1 from Manpowerprofile where mpp_id = @ps_asgn_id and Datediff(day, mpp_hiredate, @pdt_payperiod) < 31)
	Return 0

-- Verify that the Asset is not flagged as 'part time'
select @excludedrvtype = isNull(gi_string1,'zzz1') from generalinfo where gi_name = 'DrvEligWeeklyMinCalcDrvExclude'
if exists (select 1 from manpowerprofile where mpp_id = @ps_asgn_id and  CHARINDEX(','+ mpp_type4+',', ',' + @excludedrvtype + ',') > 0)
	Return 0

-- Get the Paytype for the Minimum Paydetail records.
select @PayType = isnull(gi_string1,'UNK'),
	@minpayamt = isNull(gi_integer1,425),
	@minpayincrement = isNull(gi_integer2,6),
	@minpaydaynumber = isNull(gi_integer3,7),
	@logcompute = isNull(gi_string2,'N')
from generalinfo where gi_name = 'DrvEligWeeklyMinCalc'

if @PayType = '' or @PayType = 'UNK'
	Begin
		select @ps_returnmsg = 'Driver Weekly Minimum PayType is not defined. Please set the DRVWeekMinPayType Generalinfo setting - gi_string1'
		Return -1
	End

-- Determine if the Driver is in one of the Excluded Terminals.
Declare @termlist	as varchar(60)

select @termlist = ','+ gi_string1 + ',' from generalinfo where gi_name = 'DrvEligWeeklyMinCalcExclude'
if exists (select 1 from manpowerprofile 
			where mpp_id = @ps_asgn_id
				and charindex(','+ mpp_terminal+ ',', @termlist) > 0)
	Begin
		if @logcompute = 'Y'
			Begin
				EXECUTE @err_batch = dbo.getsystemnumber 'BATCHQ',''

				select @err_msg = 'Calcualted Minimum for Driver: ' + @ps_asgn_id + '.  PayPeriod: ' + cast(@pdt_payperiod as Varchar(20)) + '.  Driver excluded from calculation due to Terminal code .'

				Insert into tts_errorlog (err_batch, err_user_id, err_message, err_date, err_title)
				Values(@err_batch, @tmwuser, @err_msg, getdate(), 'Driver Weekly Min Calc')



			End
		-- Get out, the Driver is exclueded from the Minimum calculation
		Return 0
	end

-- Determine the total misc pay for the Driver for the PayPeriod
-- NOTE: this uses the new field 'pyd_min_period' on the paydetail. This is because the pay may need to be applied to a
--		minimum calculation from a prior pay period if Pay is getting adjusted in a later pay period.  The 'pyd_min_period' date is 
--		set in the application whenever pay is created.  
select @totalpay = isNull(sum(pyd_amount),0) 
from PayDetail pd join payheader ph on pd.pyh_number = ph.pyh_pyhnumber
where isNull(pd.pyd_min_period, pd.pyh_payperiod) = @pdt_payperiod
	and pd.pyd_status in ('PND','REL')
	and pd.asgn_type = @ps_asgn_type
	and pd.asgn_id = @ps_asgn_id

-- Determine the number of Ineligible days for the Driver in the PayPeriod
select @ineligible_start = dateadd(d,(@minpaydaynumber * -1), dateadd(dd,0, datediff(dd,0,@pdt_payperiod)))
select @ineligible_end =  DateAdd(s,-1,dateadd(dd,1, datediff(dd,0,@pdt_payperiod)))

-- Be sure not to count records that have had the reason set back to 'UNK'
select @ineligible_days = isnull(count(*),0)
from di_header hdr join di_detail dt on hdr.dih_id = dt.dih_id
where hdr.dih_date between @ineligible_start and @ineligible_end
	and dt.mpp_id = @ps_asgn_id
	and isNull(dt.did_reason,'UNK') <> 'UNK'


-- Compute the Minimum pay for the Driver
select @computed_min = isNull(@minpayamt * (cast((@minpayincrement - @ineligible_days) as decimal(10,2)) / cast((@minpayincrement) as decimal(10,2))),0)

-- If the Driver's actual pay is less than the computed minimum amount, create a pay amount to bring pay up to the minimum.
if @computed_min > @totalpay
	Begin

		Select @mov = 0
		Select @ordhdr = 0
		SELECT @quantity = 1
		Select @asgn_type = @ps_asgn_type
		Select @asgn_id = @ps_asgn_id
		SELECT @asgn_number = 0	
		SELECT @payto = mpp_payto from manpowerprofile where mpp_id = @ps_asgn_id

		SELECT  @pyt_description = ISNULL(pyt_description,''),
				@pyt_rateunit = ISNULL(pyt_rateunit,''),
				@pyt_unit = ISNULL(pyt_unit,''),
				@pyt_pretax = ISNULL(pyt_pretax,''),
				@pr_glnum = ISNULL(pyt_pr_glnum,''),
				@ap_glnum = ISNULL(pyt_ap_glnum,''),
				@spyt_minus = ISNULL(pyt_minus,'')
		FROM 	paytype
		WHERE 	pyt_itemcode = @PayType

		SELECT @pyt_minus = 1	-- default to 1
		IF @spyt_minus = 'Y'
			SELECT @pyt_minus = -1
		
		-- Compute the Adjustment amount
		select @pdec_amount = (@computed_min - @totalpay)
		select @pdec_rate = @pdec_amount

		select @pyd_description = @pyt_description + '( IE Days: ' + cast(@ineligible_days as varchar(2)) + ', Computed on Total Pay of: ' + convert(varchar(20), @totalpay, 2) + ' )'

		-- Get the paydetail sequence number
		SELECT @pyd_sequence = ISNULL(MAX(pyd_sequence),0) + 1
		FROM paydetail
		WHERE pyh_number = @pl_pyhnumber

 
		-- Get the next pyd_number from the systemnumber table
		EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM',''
	
		--TODO change lgh_number , workdate
		
		INSERT INTO paydetail  
				(pyd_number,
				pyh_number,
				lgh_number,
				asgn_number,
				asgn_type,		--5
	
				asgn_id,
				ivd_number,
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
				pyh_payperiod,	
				pyd_workperiod,
				lgh_startpoint,
				lgh_startcity,	--25
	
				lgh_endpoint,
				lgh_endcity,
				ivd_payrevenue,
				pyd_revenueratio,	
				pyd_lessrevenue,	--30
	
				pyd_payrevenue,
				pyd_transdate,
				pyd_minus,
				pyd_sequence,
				std_number,			--35
	
				pyd_loadstate,
				pyd_xrefnumber,
				ord_hdrnumber,
				pyt_fee1,
				pyt_fee2,		--40
	
				pyd_grossamount,
				pyd_adj_flag,
				pyd_updatedby,
				pyd_updatedon,
				pyd_ivh_hdrnumber,	--45
				psd_id,
				pyd_min_period)
		VALUES (@pyd_number,
				@pl_pyhnumber,
				@lgh,
				@asgn_number,
				@asgn_type,		--5
		
				@asgn_id,
				0,  --ivd_number
				@actg_type,
				@payto,
				@PayType,		--10
		
				@mov,
				@pyd_description, -- pyd_description
				@Quantity,
				@pyt_rateunit,
				@pyt_unit,		--15
		
				@pdec_rate, --pyd_rate,
				@pdec_amount, --pyd_amount
				@pyt_pretax,
				@glnum,
				@currency,		--20
		
				'PND', --pyd_status
				@pdt_payperiod, --pyh_payperiod
				@pdt_payperiod, --pyh_workperiod
				@lgh_startpoint,
				@lgh_startcity,		--25
		
				@lgh_endpoint,
				@lgh_endcity,
				0, --ivd_payrevenue
				0, --pyd_revenueratio
				0, --pyd_lessrevenue	--30
		
				0, --pyd_payrevenue
				getdate(), --pyd_transdate
				@pyt_minus,
				@pyd_sequence,	
				-1, --std_number		--35	-- Set to -1 so record is deleted when settlement is re-opened.
		
				'NA', --pyd_loadstate
				0, --pyd_xrefnumber
				@ordhdr,
				0, --pyt_fee1
				0, --pyt_fee2			--40
		
				0, --pyd_grossamount	
				'N', --pyd_adj_flag
				@tmwuser, --pyd_updatedby
				GETDATE(), --pyd_updatedon
				0, --pyd_ivh_hdrnumber		--45
				@psd_id,
				@pdt_payperiod -- pyd_min_period
				)
	

	End

if @logcompute = 'Y'
	Begin
		EXECUTE @err_batch = dbo.getsystemnumber 'BATCHQ',''

		select @err_msg = 'Calcualted Minimum for Driver: ' + @ps_asgn_id + '.  PayPeriod: ' + cast(@pdt_payperiod as Varchar(20)) + ' Total Pay: ' + Convert(VarChar(12),@totalpay,2 ) + ' Computed Min: ' + Convert(Varchar(12),@computed_min,2) + ' Adj. Amt: ' + Convert(varchar(12), @pdec_amount, 2)

		Insert into tts_errorlog (err_batch, err_user_id, err_message, err_date, err_title)
		Values(@err_batch, @tmwuser, @err_msg, getdate(),'Driver Weekly Min Calc')



	End


GO
GRANT EXECUTE ON  [dbo].[settlement_precollect_process_DRVMIN] TO [public]
GO
