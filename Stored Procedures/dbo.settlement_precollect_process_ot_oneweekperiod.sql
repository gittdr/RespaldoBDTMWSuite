SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[settlement_precollect_process_ot_oneweekperiod](	@pl_pyhnumber int , @ps_asgn_type varchar(6),@ps_asgn_id varchar(13) ,
														@pdt_payperiod datetime, @psd_id int , @ps_message varchar(255) OUT)
as
/**
 * 
 * NAME:
 * dbo.settlement_precollect_process_ot_oneweekperiod
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Creates custom paydetails tied to a payheader for a payperiod based on custom rules 
 *
 * RETURNS:
 * 1 success -1 error
 *
 * RESULT SETS: 
*   None *
 * PARAMETERS:
 * 001 - @pl_pyhnumber int			? for future use
 * 002 - @ps_asgn_type varchar(6)
 * 003 - @ps_asgn_id varchar(13)
 * 004 - @pdt_payperiod datetime
 * 005 - @psd_id int batch id		? for future use
 * 006 - @ps_returnmsg varchar(255) OUTPUT
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * LOr	PTS# 42217
 *
 **/
 
declare @asgn_id varchar(13),
		@asgn_number int,
		@pyd_number int,
		@pyd_sequence int,
		@pyt_description varchar(75),
		@asgn_type varchar(6),
		@ldt_lastpayperiod datetime,
		@ldt_lastpayperiod_7 datetime,
		@ldt_from datetime,
		@ldt_to datetime,
		@last_week datetime,
		@OvertimePayType varchar(6),
		@ps_returnmsg	varchar(255)

declare @ii int,
	@ldec_period_trans float,
	@ldec_period_lgh float,
	@pyd_number_update int,
	@ot_pyd_sequence int,
	@period_pyd_sequence int,
	@ldec_period float, 
	@ldec_period_new float, 
	@ldec_period_max money, 
	@ldec_period_qty float,
	@insert_ot_qty float,
	@update_qty float,
	@update_period_qty float,
	@insert_period_qty float,
	@ldec_ot_qty float,
	@ls_payto varchar(12),
	@last_pyd_number int,
	@li_tret int , 
	@li_ret int -- return 1 

declare @ot_actg_type char(1),
		@ap_glnum char(32),
		@glnum char(32),
		@ot_pr_glnum char(32),
		@ot_glnum char(32),
		@ot_ap_glnum char(32),
		@ot_pyt_minus int,
		@ot_pyt_pretax char(1),
		@ot_pyt_rateunit varchar(6),
		@ot_pyt_unit varchar(6),
		@ot_spyt_minus char(1),
		@ot_pyt_fee2 money,
		@ot_pyt_fee1 money

DECLARE @tmwuser varchar (255)

select @ps_returnmsg = 'Precollect processed successfully for Resource:' + @ps_asgn_id

select 	@li_tret = 0,
	@li_ret = 1

create table #temp_trip_pay
	(pyd_sequence int not null,
	pyd_quantity float null,
	lgh_number int null,
	pyd_number int not null,
	enddate datetime null,
	pyt_itemcode varchar(6) null)

create table #temp_non_trip_pay
	(pyd_sequence int not null,
	pyd_quantity float null,
	lgh_number int null,
	pyd_number int not null,
	enddate datetime null,
	pyt_itemcode varchar(6) null)

/*	@OvertimePayType = 	Pay type to use for overtime pay  */

select 	@OvertimePayType = IsNull(gi_string1, 'OT')	
from 	generalinfo 
where 	gi_name = 'OTPayCode'

if 	@ps_asgn_type <> 'DRV' 
begin
	raiserror('Only resource type of driver can have the OT computation', 16, 1)
	return -1
end

/*	Determine the last date on which this driver was paid. This will be used later when
	checking to make sure that pay requirments are met. 
	If this is the first pay period ever, start counting from a week before. */
select  @ldt_lastpayperiod = IsNull(max(pyh_payperiod), dateadd(dd, -14, @pdt_payperiod))
from 	payheader a
where 	a.asgn_type = @ps_asgn_type 
and 	a.asgn_id = @ps_asgn_id 
and 	pyh_payperiod < @pdt_payperiod

select @last_week = dateadd(dd, -7, @pdt_payperiod)

If @ldt_lastpayperiod <> @last_week
	select @ldt_lastpayperiod = @last_week

/*	Get the weekly time limit */
select 	@ldec_period_max = IsNull(mpp_periodguarenteedhours, 40.0),
		@ls_payto = mpp_payto
from 	manpowerprofile 
where 	mpp_id = @ps_asgn_id

/*	If asset record didn't have weekly OT limits, generate an error message. */
if @ldec_period_max is null 
	begin
		raiserror ('Could not determine weekly time limits for this resource.', 16, 1)
		return -1
	end

if @ldt_lastpayperiod < @pdt_payperiod and @ldec_period_max is not null and @ldec_period_max > 0
begin	
	/*	Get values from @OvertimePayType 	*/
	SELECT  @ot_pyt_rateunit = ISNULL(pyt_rateunit,''),
			@ot_pyt_unit = ISNULL(pyt_unit,''),
			@ot_pyt_pretax = ISNULL(pyt_pretax,''),
			@ot_pr_glnum = ISNULL(pyt_pr_glnum,''),
			@ot_ap_glnum = ISNULL(pyt_ap_glnum,''),
			@ot_spyt_minus = ISNULL(pyt_minus,''),
			@ot_pyt_fee1 = IsNull(pyt_fee1, 0),
			@ot_pyt_fee2 = IsNull(pyt_fee2, 0)
	FROM 	paytype
	WHERE 	pyt_itemcode = @OvertimePayType

	SELECT @ot_pyt_minus = 1	-- default to 1
	IF @ot_spyt_minus = 'Y'
		SELECT @ot_pyt_minus = -1
				
	SELECT  @ot_glnum = ''
	IF @ot_actg_type = 'A'
		SET @ot_glnum = @ot_ap_glnum
	ELSE IF @ot_actg_type = 'P'
		SET @ot_glnum = @ot_pr_glnum

	/*	Get the total quantity of existing time-based paydetails for this payperiod
	and store it in the variable @ldec_period_new. 
	NOTE: this section of the code assumes a 1 week pay period  */

		insert #temp_trip_pay
		select pyd_sequence,
				pyd_quantity,
				a.lgh_number,
				pyd_number,
				b.lgh_enddate,
				a.pyt_itemcode
		from paydetail a, legheader b, paytype c
		where 	a.lgh_number = b.lgh_number 
				and	a.asgn_type = @ps_asgn_type 
				and a.asgn_id = @ps_asgn_id 
				and	a.pyt_itemcode = c.pyt_itemcode 
				and c.pyt_basisunit = 'TIM'	
				and	IsNull(c.pyt_otflag, 'N') = 'Y'
				and	a.pyt_itemcode not in (@OvertimePayType)
				and a.pyh_payperiod = @pdt_payperiod

		insert #temp_non_trip_pay
		select IsNull(pyd_sequence, 0),
				pyd_quantity,
				IsNull(a.lgh_number, 0),
				pyd_number,
				pyd_transdate,
				a.pyt_itemcode
		from paydetail a, paytype c
		where 	a.asgn_type = @ps_asgn_type 
				and a.asgn_id = @ps_asgn_id 
				and	a.pyt_itemcode = c.pyt_itemcode 
				and c.pyt_basisunit = 'TIM'	
				and	IsNull(c.pyt_otflag, 'N') = 'Y'
				and	a.pyt_itemcode not in (@OvertimePayType)
				and a.pyh_payperiod = @pdt_payperiod
				and pyd_number not in (select pyd_number from #temp_trip_pay)

		select 	@ldec_period_lgh = isnull(sum(pyd_quantity), 0) from #temp_trip_pay

		select 	@ldec_period_trans = isnull(sum(pyd_quantity), 0) from #temp_non_trip_pay

		select @ldec_period_new = @ldec_period_lgh + @ldec_period_trans

		insert #temp_trip_pay select * from #temp_non_trip_pay

		If @ldec_period_new > @ldec_period_max
		begin
			select @ldec_period_qty = @ldec_period_new - @ldec_period_max

			select	@period_pyd_sequence = (pyd_sequence + 1),
					@pyd_number_update = pyd_number
			from 	#temp_trip_pay 
			Where	enddate = (select max(enddate) from #temp_trip_pay)
--		end	

		-- Get the next pyd_number from the systemnumber table
		EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM',''

		exec gettmwuser @tmwuser output

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
					tar_tarriffnumber,
					psd_id,
					pyd_releasedby,
					pyd_updsrc)
		SELECT @pyd_number,
				a.pyh_number,
				0,	-- lgh_number,
				a.asgn_number,
				a.asgn_type,		--5
				a.asgn_id,
				a.ivd_number,
				a.pyd_prorap,
				a.pyd_payto,
				@OvertimePayType,		--10
				0,	--	mov_number,
				'Pay Period OT Pay for week ' + convert(varchar, @ii),
				@ldec_period_qty,
				@ot_pyt_rateunit,
				@ot_pyt_unit,		--15
				(pyd_rate / 2.00),
				((@ot_pyt_minus * ((pyd_rate / 2.00) * @ldec_period_qty)) - (@ot_pyt_fee1 + @ot_pyt_fee2)),	--pyd_amount
				@ot_pyt_pretax,
				@ot_glnum,
				a.pyd_currency,	--20
				a.pyd_status,
				a.pyh_payperiod,
				a.pyd_workperiod,
				'UNKNOWN',	--	lgh_startpoint,
				0,	--	lgh_startcity,	--25
				'UNKNOWN',	--	lgh_endpoint,
				0,	--	lgh_endcity,
				a.ivd_payrevenue,
				a.pyd_revenueratio,	
				a.pyd_lessrevenue,	--30
				a.pyd_payrevenue,
				a.pyd_transdate,
				@ot_pyt_minus,
				1,	
				a.std_number,			--35
				'NA',	--	pyd_loadstate,
				a.pyd_xrefnumber,
				0,	--	ord_hdrnumber,
				@ot_pyt_fee1,
				@ot_pyt_fee2,			--40
				(@ot_pyt_minus * ((pyd_rate / 2.00) * @ldec_period_qty)), --pyd_grossamount	
				'N', --pyd_adj_flag
				@tmwuser, --pyd_updatedby
				GETDATE(), --pyd_updatedon
				0, --pyd_ivh_hdrnumber		--45	
				a.tar_tarriffnumber,
				a.psd_id,
				a.pyd_releasedby,
				a.pyd_updsrc
		from 	paydetail a
		Where	pyd_number = @pyd_number_update
		end

		delete #temp_trip_pay
		delete #temp_non_trip_pay
end

drop table #temp_trip_pay
drop table #temp_non_trip_pay

return @li_ret 
GO
GRANT EXECUTE ON  [dbo].[settlement_precollect_process_ot_oneweekperiod] TO [public]
GO
