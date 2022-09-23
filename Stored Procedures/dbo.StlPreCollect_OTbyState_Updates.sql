SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[StlPreCollect_OTbyState_Updates](@pyd_number_update int,
													@OvertimePayType    varchar(6),
													@DoubleTimePayType  varchar(6),	
													@type_pay varchar(30),
													@DailyHrsReg float,
													@DailyHrsOT float,
													@DOW_7_OTHrs float,
													@DOW_7_Double float,
													@pyd_sequence int,
													@RegularPayType		varchar(6),
													@newDate			datetime,
													@effectiveRateOT   FLOAT,
													@effectiveRateDbl  FLOAT)
as
set nocount on 
declare @SetDebugON INT
set @SetDebugON = 0			-- if = 1, we will SEE debug messages.
--select @SetDebugON = 1
		
select @type_pay = UPPER(@type_pay)	

IF  @SetDebugON = 1
begin
	if @type_pay = 'SUMMARY NEW INSERT' 
		begin
			print 'Debug ON:  UPDATE PROC:  ' + LTrim(RTrim(@type_pay)) + space(1) +
					 'OT PayType:' + space(1) +  LTrim(RTrim(@OvertimePayType)) + space(1) +
						 'New OT Hours:' + space(1) +Convert(varchar(10),@DailyHrsOT)
		end
	else	
		begin
			print 'Debug ON: UPDATE PROC:  ' + LTrim(RTrim(@type_pay)) + space(1) +
					 'PayDetail Number:' + space(1) +  Convert(varchar(10),@pyd_number_update) + space(1) +
					 'New Regular Hours(qty):' + space(1) + Convert(varchar(10),@DailyHrsReg)	
		end		
end													
														
													

/**
 --- Goes With Settlement_OTbyState


 * DESCRIPTION:
 * PTS 71874  
 * Creates custom paydetails tied to a payheader for a payperiod based on custom rules 
 *		   several possible conditions:  update existing paydetail + create any of the flavor(s) of OT
 *									     update existing + various OT + NEW 'regular hrs' paydetail also.
 *		   Argument ==>	@type_pay controls which update mechanism is triggered.
 *						'SUMMARY NEW INSERT', 'SUMMARY UPDATE-EXISTS-REGULAR', 'SUMMARY INSERT-NEW-REGULAR' 
 *
 **/
 
 
declare @insert_qty float, @update_qty float

declare	@loopsNeeded	int
declare	@loopctr		int
declare @new_pyd_number int
Declare @newpydsequence	INT
declare @ls_workAcctType char(1)
declare @paytype_Description varchar(30)
declare @ls_workDescription varchar(30)
declare @NewRate		Float
 
declare @ot_actg_type char(1),
		@ap_glnum char(32),
		@glnum char(32),		
		@ot_pr_glnum char(32),		
		@ot_glnum char(32),		
		@ot_ap_glnum char(32),
		@pyd_number int,
		@ot_pyt_minus int,		
		@ot_pyt_pretax char(1),		
		@ot_pyt_rateunit varchar(6),		
		@ot_pyt_unit varchar(6),		
		@ot_spyt_minus char(1),		
		@ot_pyt_fee2 money,		
		@ot_pyt_fee1 money,		
		@PayType varchar(6)

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output


IF UPPER(@type_pay) = 'SUMMARY NEW INSERT'
begin
	select @loopsNeeded = 0
	--	we can potentially have 3 types of OT.
	IF @DailyHrsOT   > 0	select @loopsNeeded = @loopsNeeded + 1
	IF @DOW_7_OTHrs  > 0	select @loopsNeeded = @loopsNeeded + 1
	IF @DOW_7_Double > 0	select @loopsNeeded = @loopsNeeded + 1
	select @loopctr = 0		

	While @loopctr < @loopsNeeded
	begin
			select @loopctr = @loopctr + 1			
			
			IF @DailyHrsOT   > 0
				begin
					select @PayType = @OvertimePayType 
					select @insert_qty = @DailyHrsOT
					select @ls_workDescription = 'Daily OT Pay'
					select @NewRate = @effectiveRateOT
					set @DailyHrsOT = 0	-- so we don't run this one again
				end 
			Else If @DOW_7_OTHrs > 0
				begin
					select @PayType = @OvertimePayType 
					select @insert_qty = @DOW_7_OTHrs
					select @ls_workDescription = 'Daily OT Pay'
					select @NewRate = @effectiveRateOT
					set @DOW_7_OTHrs = 0	
				end 
			Else If @DOW_7_Double > 0
				begin
					select @PayType = @DoubleTimePayType 
					select @insert_qty = @DOW_7_Double
					select @ls_workDescription = 'Double Time Pay'
					select @NewRate = @effectiveRateDbl
					set @DOW_7_OTHrs = 0	
				end 	
				
				SELECT		@ot_pyt_rateunit = ISNULL(pyt_rateunit,''),
							@ot_pyt_unit = ISNULL(pyt_unit,''),
							@ot_pyt_pretax = ISNULL(pyt_pretax,''),
							@ot_pr_glnum = ISNULL(pyt_pr_glnum,''),
							@ot_ap_glnum = ISNULL(pyt_ap_glnum,''),
							@ot_spyt_minus = ISNULL(pyt_minus,''),
							@ot_pyt_minus = CASE ISNULL(pyt_minus,'Y') when 'Y' then -1 
											 Else 1
											 end,
							@ot_pyt_fee1 = ISNULL(pyt_fee1, 0),
							@ot_pyt_fee2 = ISNULL(pyt_fee2, 0),
							@paytype_Description = ISNULL(pyt_description, '')
				FROM 		paytype
				WHERE 		pyt_itemcode = @PayType	

				select  @ot_actg_type = pyd_prorap,
						@ls_workAcctType =  mpp_actg_type
				from paydetail 
				left join manpowerprofile on paydetail.asgn_id = manpowerprofile.mpp_id
				where paydetail.pyd_number = @pyd_number_update
				and paydetail.asgn_type = 'DRV'		--we only do this for Drivers!

				if @ot_actg_type is null select @ot_actg_type = ''
				if @ls_workAcctType is null select @ls_workAcctType = ''
				IF @paytype_Description is null select @paytype_Description = ''
				if ( LEN(LTRIM(RTRIM(@paytype_Description))) <= 0 ) select @paytype_Description = @ls_workDescription
				
				-- in the event the paytype data is missing....
				if ( LEN(LTRIM(RTRIM(@ot_actg_type))) <= 0  AND LEN(LTRIM(RTRIM(@ls_workAcctType))) > 0 )  
					begin
						set  @ot_actg_type = @ls_workAcctType
					end	
				-- end if :-)	
								
				SELECT  @ot_glnum = ''
				IF @ot_actg_type = 'A'
					SET @ot_glnum = @ot_ap_glnum
				ELSE IF @ot_actg_type = 'P'
					SET @ot_glnum = @ot_pr_glnum

		EXECUTE @new_pyd_number = dbo.getsystemnumber 'PYDNUM',''	
		if @loopctr > 1 select @pyd_sequence = @pyd_sequence + 1		-- increment seq.
				
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
						pyd_releasedby,
						pyd_updsrc)	
			SELECT	@new_pyd_number,			--***	set above in loop
					a.pyh_number,
					a.lgh_number,
					a.asgn_number,
					a.asgn_type,		--5
					a.asgn_id,
					a.ivd_number,
					a.pyd_prorap,
					a.pyd_payto,
					@PayType 'pyt_itemcode',				--10		--***   set above in loop
					a.mov_number,
					@paytype_Description,						--***   set above
					@insert_qty 'pyd_qty',						--***	set in calling proc
					@ot_pyt_rateunit,							--***	set from paytype above
					@ot_pyt_unit,		--15					--***	set from paytype above
					@NewRate 'pyd_rate',				  			--***   passed into proc	--0, --pyt_rate,
					Round(@insert_qty  * @NewRate,2) 'pyd_amount',	--pyt_amount  0, --pyt_amount
					@ot_pyt_pretax,									--***	set from paytype above
					@ot_glnum,										--***	set from paytype above
					a.pyd_currency,	--20
					a.pyd_status,
					a.pyh_payperiod,
					a.pyd_workperiod,
					a.lgh_startpoint,
					a.lgh_startcity,	--25
					a.lgh_endpoint,
					a.lgh_endcity,
					a.ivd_payrevenue,
					a.pyd_revenueratio,	
					a.pyd_lessrevenue,	--30
					a.pyd_payrevenue,
					a.pyd_transdate,
					@ot_pyt_minus,				--***	set from paytype above
					@pyd_sequence,				--***	set in calling proc & above
					a.std_number,		--35
					a.pyd_loadstate,
					a.pyd_xrefnumber,
					a.ord_hdrnumber,
					@ot_pyt_fee1,				--***	set from paytype above
					@ot_pyt_fee2,		--40	--***	set from paytype above
					0,											--pyd_grossamount	
					'N',										--pyd_adj_flag
					@tmwuser, 					--***			--pyd_updatedby
					GETDATE(),									--pyd_updatedon
					0,					--45					--pyd_ivh_hdrnumber		
					a.psd_id,
					a.pyd_releasedby,
					a.pyd_updsrc
					from 	paydetail a
					where	pyd_number = @pyd_number_update
	end
end	-- end of 'SUMMARY NEW INSERT'


IF UPPER(@type_pay) = 'SUMMARY UPDATE-EXISTS-REGULAR'
begin
	IF @newDate is Null OR @newDate <= '1950-01-01'
	begin
		select @newDate = pyd_transdate from paydetail Where pyd_number = @pyd_number_update		
	end
	
	UPDATE paydetail
	SET		pyd_reg_time_qty = pyd_quantity,
			pyd_quantity = @DailyHrsReg,
			pyd_amount = (pyd_rate * @DailyHrsReg),
			pyd_grossamount = (pyd_rate * @DailyHrsReg),
			pyd_transdate = @newDate						
	from	paydetail 
	Where	pyd_number = @pyd_number_update	
		
end		-- end of 'SUMMARY UPDATE-EXISTS-REGULAR'



IF UPPER(@type_pay) = 'SUMMARY INSERT-NEW-REGULAR'
begin
													
	EXECUTE @new_pyd_number = dbo.getsystemnumber 'PYDNUM',''		
			INSERT INTO paydetail  
						(pyd_number,			-- new pyd_number, of course.
						pyd_reg_time_qty,		-- new pyd_reg_time_qty is old pyd_quantity
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
						pyd_quantity,				-- 13 ***
						pyd_rateunit,
						pyd_unit,		--15
						pyd_rate,
						pyd_amount,					-- 17 ***
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
						pyd_transdate,				--***  new transdate = @newDate
						pyd_minus,
						pyd_sequence,
						std_number,			--35
						pyd_loadstate,
						pyd_xrefnumber,
						ord_hdrnumber,
						pyt_fee1,
						pyt_fee2,		--40
						pyd_grossamount,			--***  pyd_grossamount = (pyd_rate * @DailyHrsReg)	
						pyd_adj_flag,
						pyd_updatedby,
						pyd_updatedon,
						pyd_ivh_hdrnumber,	--45	
						psd_id,
						pyd_releasedby,
						pyd_updsrc)											
	SELECT			@new_pyd_number,
					a.pyd_quantity 'pyd_reg_time_qty',				--*** update pyd_reg_time_qty with PREVIOUS pyd_quantity			
					a.pyh_number,
					a.lgh_number,
					a.asgn_number,
					a.asgn_type,		--5
					a.asgn_id,
					a.ivd_number,
					a.pyd_prorap,
					a.pyd_payto,
					a.pyt_itemcode,		--10		
					a.mov_number,
					a.pyd_description,
		 			@DailyHrsReg,		-- 13		-- *** new value
		 			a.pyd_rateunit,
		 			a.pyd_unit,		 --15
		 			a.pyd_rate,
		 			a.pyd_rate * @DailyHrsReg 'pyd_amount',		-- 17 -- *** calc new value for pyd_amount
					a.pyd_pretax,
		 			a.pyd_glnum,
					a.pyd_currency,	--20
					a.pyd_status,
					a.pyh_payperiod,
					a.pyd_workperiod,
					a.lgh_startpoint,
					a.lgh_startcity,	--25
					a.lgh_endpoint,
					a.lgh_endcity,
					a.ivd_payrevenue,
					a.pyd_revenueratio,	
					a.pyd_lessrevenue,	--30
					a.pyd_payrevenue,
					@newDate 'a.pyd_transdate,'	,					-- *** new value			
					a.pyd_minus,		 							
					@pyd_sequence 'new pyd_sequence',				-- *** new value					
					a.std_number,		--35
					a.pyd_loadstate,
					a.pyd_xrefnumber,
					a.ord_hdrnumber,
					a.pyt_fee1,
		 			a.pyt_fee2,
					a.pyd_rate * @DailyHrsReg 'pyd_grossamount	',	--*** new value for pyd_grossamount	
					'N',										--pyd_adj_flag
					@tmwuser, 								    --pyd_updatedby
					GETDATE(),									--pyd_updatedon
					a.pyd_ivh_hdrnumber,				--45		
					a.psd_id,
					a.pyd_releasedby,
					a.pyd_updsrc
					from 	paydetail a
					where	pyd_number = @pyd_number_update	

end  -- end of 'SUMMARY INSERT-NEW-REGULAR'

RETURN 
GO
GRANT EXECUTE ON  [dbo].[StlPreCollect_OTbyState_Updates] TO [public]
GO
