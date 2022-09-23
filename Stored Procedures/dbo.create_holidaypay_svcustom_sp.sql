SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create procedure [dbo].[create_holidaypay_svcustom_sp](
	@ps_asgn_type varchar(6),
	@ps_asgn_id varchar(13),
	@ps_paytype varchar(6),
	@pdec_hours decimal(15,8),
	@pdt_workdate datetime,
	@p_rate decimal(15,8),
	@p_pyh_payperiod datetime) 	-- added for PTS 66431 	


AS
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
		--@Quantity int,	LOR	PTS# 61123
		@Quantity decimal(15,8),
		@spyt_minus char(1),
		@asgn_type varchar(6),
		@pyd_transdate datetime,
		@ps_payto varchar(8),
		@pl_pyhnumber int,
		@pdec_rate decimal(15,8),
		@pdec_amount decimal(15,8),
		@ls_revtype1 varchar(6),
		@ldt_lastpayperiod datetime,
		@PayFilter	varchar(60),
		@pyh_payperiod datetime 	-- added for PTS 66431

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

	SELECT @Apocalypse = gi_date1
	FROM generalinfo
	WHERE gi_name = 'APOCALYPSE'

--	LOR	PTS# 61123
	SELECT @PayFilter = IsNull(gi_string1, 'N')
	FROM generalinfo
	WHERE gi_name = 'HolidayVacationPayFilter'
--	LOR		
		
	If @Apocalypse is null  
		select @Apocalypse = convert(datetime,'20491231 23:59:59')
		
	select @pyh_payperiod = ISNULL(@p_pyh_payperiod, @Apocalypse)			-- NQIAO PTS 66431

	SELECT @lgh = 0
	SELECT @pl_pyhnumber = 0
	SELECT @quantity = @pdec_hours
	
	Select @asgn_type = @ps_asgn_type
	Select @asgn_id = @ps_asgn_id
	SELECT  @asgn_number = 0	
	SELECT @payto = @ps_payto
	SELECT @PayType = @ps_paytype


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
	
	--Select @ordhdr = min(ord_hdrnumber) from orderheader where mov_number = @mov
	-- transdate 
	Select @pyd_transdate = @apocalypse

	-- Get the paydetail sequence number
	SELECT @pyd_sequence = MAX(isnull(pyd_sequence, 0)) + 1
	FROM paydetail
	WHERE pyh_number = @pl_pyhnumber

--	LOR	PTS# 61123	add @PayFilter logic
	If @asgn_type = 'DRV'
	Begin
		select @ps_payto = mpp_payto,@actg_type = mpp_actg_type, 
				@pdec_rate = Case 
								when @PayFilter = 'Y' then @p_rate
								else mpp_avghourlypay 
							End 
		from manpowerprofile where mpp_id = @asgn_id
	
		If @PayFilter = 'N'
		Begin
			If IsNull(@pdec_rate,0) = 0 
				select @pdec_rate = mpp_hourlyrate from manpowerprofile where mpp_id = @asgn_id	

			IF IsNull(@Quantity ,0) = 0 
			Begin
				select @quantity = mpp_dailyguarenteedhours from manpowerprofile where mpp_id = @asgn_id
			End
			
			
			If IsNull(@quantity,0) = 0 or IsNull(@pdec_rate,0)= 0 
			BEGIN
				select  @ldt_lastpayperiod = max(pyh_payperiod) from payheader a --, sv_kronos_import b
				where 	a.asgn_type = @ps_asgn_type and a.asgn_id = @ps_asgn_id and pyh_payperiod < @pdt_workdate

				-- determine the branch id by looking at the trips in the current payperiod
				select @ls_revtype1 = min(ord_revtype1) from orderheader a , legheader b
				where a.ord_hdrnumber = b.ord_hdrnumber and (b.lgh_driver1 = @ps_asgn_id  or b.lgh_driver2 = @ps_asgn_id) and
					  lgh_startdate between @ldt_lastpayperiod and @pdt_workdate
			
				-- If we dont find any trips in the current payperiod search his older history to determine the order revtype1
				If @ls_revtype1 is null 
				begin
					set rowcount 1
					select @ls_revtype1 = ord_revtype1 from orderheader a , legheader b
					where a.ord_hdrnumber = b.ord_hdrnumber and (b.lgh_driver1 = @ps_asgn_id  or b.lgh_driver2 = @ps_asgn_id) 
					set rowcount 0
				end
					
				If IsNull(@Quantity,0) = 0 
					select @Quantity = brn_dailyguarenteedhours from branch where brn_id = @ls_revtype1

				If IsNull(@pdec_rate,0) = 0
					select @pdec_rate = brn_hourlyrate from branch where brn_id = @ls_revtype1
			END
		End
	End

	IF @asgn_type = 'TRC' 
		select @ps_payto = trc_owner,@actg_type = trc_actg_type, 
				@pdec_rate = Case 
								when @PayFilter = 'Y' then @p_rate
								else 0.00 
							End 
		from tractorprofile where trc_number = @asgn_id	

	IF @asgn_type = 'TRL' 
		select @ps_payto = trl_owner,@actg_type = trl_actg_type, 
				@pdec_rate = Case 
								when @PayFilter = 'Y' then @p_rate
								else 0.00 
							End 
		from trailerprofile where trl_id = @asgn_id	
	
	IF @asgn_type = 'CAR'
		select @ps_payto = pto_id,@actg_type = car_actg_type, 
				@pdec_rate = Case 
								when @PayFilter = 'Y' then @p_rate
								else 0.00 
							End 
		from carrier where car_id = @asgn_id	

	If IsNull(@pdec_rate,0) = 0 
		select @pdec_rate = pyt_rate from paytype where pyt_itemcode = @PayType

	If IsNull(@Quantity,0) = 0 
		select @Quantity = pyt_quantity 	from paytype where pyt_itemcode = @PayType

	select @pdec_amount = @Quantity * @pdec_rate * @pyt_minus
	
	-- Get the appropriate ap/pr gl number
	SELECT  @glnum = ''
	IF @actg_type = 'A'
		SET @glnum = @ap_glnum
	ELSE IF @actg_type = 'P'
		SET @glnum = @pr_glnum
	
	-- Get the next pyd_number from the systemnumber table
	EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM',''

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
			pyd_ivh_hdrnumber)	--45
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
		@pyt_description,
		@Quantity,
		@pyt_rateunit,
		@pyt_unit,		--15

		@pdec_rate, --pyt_rate,
		@pdec_amount, --pyt_amount
		@pyt_pretax,
		@glnum,
		@currency,		--20

		'PND', --pyd_status
		@pyh_payperiod,		-- 66431
		--@apocalypse, --pyh_payperiod		-- 66431 replaced by @pyh_payperiod
		@apocalypse, --pyh_workperiod
		@lgh_startpoint,
		@lgh_startcity,		--25

		@lgh_endpoint,
		@lgh_endcity,
		0, --ivd_payrevenue
		0, --pyd_revenueratio
		0, --pyd_lessrevenue	--30

		0, --pyd_payrevenue
		@pdt_workdate, --pyd_transdate
		@pyt_minus,
		@pyd_sequence,	
		0, --std_number			--35

		'NA', --pyd_loadstate
		0, --pyd_xrefnumber
		@ordhdr,
		0, --pyt_fee1
		0, --pyt_fee2			--40

		0, --pyd_grossamount	
		'N', --pyd_adj_flag
		@tmwuser, --pyd_updatedby
		GETDATE(), --pyd_updatedon
		0) --pyd_ivh_hdrnumber		--45)

		If @@error <> 0 
			return -1
		else
			return @pyd_number


GO
GRANT EXECUTE ON  [dbo].[create_holidaypay_svcustom_sp] TO [public]
GO
