SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[create_custom_arrow_pay_sp] as
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
		@pl_pyhnumber int,
		@pdec_rate decimal(15,8),
		@pdec_amount decimal(15,8),
		@ls_revtype1 varchar(6),
		@ldt_lastpayperiod datetime,
		@dopay char(1),
		@li_ctr int,
		@enddate datetime,
		@range int,
		@row int,
		@tarnum int,
		@li_rscr int,
		@ldt_curr_date datetime,
		@ldt_next_open_period datetime,
		@ldt_next_open_orientation_period datetime,
		@ldt_payperiod datetime 
		



--	create table #paytypes (pyt_itemcode varchar(8) not null)
	create table #resources (asgn_type varchar(3) not null, asgn_id varchar(8) not null)


	select @dopay = gi_string1 from generalinfo where gi_name = 'TrainerTraineePay'
	If IsNull(@dopay,'N') = 'N' 
		return 0

		
--	insert 	into #paytypes 
--	select 	pyt_itemcode from paytype a , generalinfo b where a.pyt_itemcode = b.gi_string1 and 
--			b.gi_name in ('LinehaulTrainerPaytype','RegionalTrainerPaytype','TraineePaytype','OrientationPaytype')

	

	SELECT @Apocalypse = gi_date1
	FROM generalinfo
	WHERE gi_name = 'APOCALYPSE'
	
	If @Apocalypse is null  
		select @Apocalypse = convert(datetime,'20491231 23:59:59')


	select @ldt_curr_date = getdate()
	select @ldt_next_open_period = min(psd_date) from payschedulesdetail 
	where psd_status ='OPN' and convert(varchar(8) ,psd_date,112) >= convert(varchar(8) , @ldt_curr_date,112)
	
--	select @ldt_next_open_period
	if @ldt_next_open_period is null
		select @ldt_next_open_period = @Apocalypse


	-- Orientation pay date
	select @ldt_next_open_orientation_period = min(psd_date) from payschedulesdetail 
	where psd_status = 'OPN' and convert(varchar(8),psd_date,112) > convert(varchar(8),dateadd(dd, 7 - datepart (dw,@ldt_curr_date), @ldt_curr_date),112)

	if @ldt_next_open_orientation_period is null
		select @ldt_next_open_orientation_period = @Apocalypse
	
--	select @ldt_next_open_period,@ldt_next_open_orientation_period
	
	SELECT @lgh = 0
	SELECT @pl_pyhnumber = 0
--	SELECT @quantity = @pdec_hours

--	Select @asgn_type = @asgn_type
--	Select @asgn_id = @asgn_id
	SELECT  @asgn_number = 0	
--	SELECT @payto = @ps_payto
	SELECT @li_ctr = 0
	WHILE @li_ctr < 7
	BEGIN		
		SELECT @li_ctr = @li_ctr + 1

		IF @li_ctr = 1
			SELECT @PayType = gi_string1 from generalinfo where gi_name = 'LinehaulTrainerPaytype'
		ELSE IF @li_ctr = 2
			SELECT @PayType = gi_string1 from generalinfo where gi_name = 'RegionalTrainerPaytype'
		ELSE IF @li_ctr = 3
			SELECT @PayType = gi_string1 from generalinfo where gi_name = 'TraineePaytype'
		ELSE IF @li_ctr = 4
			SELECT @PayType = gi_string1 from generalinfo where gi_name = 'OrientationPaytype'
		ELSE IF @li_ctr = 5
			SELECT @PayType = gi_string1 from generalinfo where gi_name = 'BonusPayType'
		ELSE IF @li_ctr = 6
			SELECT @PayType = gi_string1 from generalinfo where gi_name = 'LinehaulTrainerTrcPaytype'
		ELSE IF @li_ctr = 7
			SELECT @PayType = gi_string1 from generalinfo where gi_name = 'RegionalTrainerTrcPaytype'
		
		if IsNull(@paytype,'') = '' 
			continue
				
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
		Select @pyd_transdate= getdate()
	
	
		select @pdec_rate = pyt_rate from paytype where pyt_itemcode = @PayType
	
		select @Quantity = pyt_quantity 	from paytype where pyt_itemcode = @PayType
		
		select @pdec_amount = @Quantity * @pdec_rate * @pyt_minus
		
			

		delete #resources
		
		IF @li_ctr = 1 
			Insert into #resources 
			Select 'DRV',mpp_id from manpowerprofile where mpp_status <> 'OUT' and mpp_type1 = 'MIL' and mpp_type4 = 'TRN'
		ELSE IF @li_ctr = 2 
			Insert into #resources 
			Select 'DRV',mpp_id from manpowerprofile where mpp_status <> 'OUT' and mpp_type1 = 'PER' and mpp_type4 = 'TRN'
		ELSE IF @li_ctr = 3
			Insert into #resources 
			Select 'DRV',mpp_id from manpowerprofile where mpp_status <> 'OUT' and mpp_type4 = 'TRE'
		ELSE IF @li_ctr = 4
			Insert into #resources 
			Select 'DRV',mpp_id from manpowerprofile where mpp_status <> 'OUT' and mpp_type4 = 'ORN'
		ELSE IF @li_ctr = 5
			Insert into #resources 
			Select 'DRV',mpp_id from manpowerprofile where datediff(dd,mpp_90daystart,getdate()) = 91 and mpp_status <> 'OUT' and mpp_type1 = 'MIL' and (mpp_type4 = 'TRN' or mpp_type4 = 'ASU')
		ELSE IF @li_ctr = 6
			Insert into #resources 
			Select 'TRC',trc_number from tractorprofile  where trc_status <> 'OUT' and trc_type1 = 'MIL' and trc_type4 = 'TRN'
		ELSE IF @li_ctr = 7
			Insert into #resources 
			Select 'TRC',trc_number from tractorprofile where trc_status <> 'OUT' and trc_type1 = 'PER' and trc_type4 = 'TRN'
			


				
	
		
		select @asgn_id = ''
				
		WHILE 2 = 2
		BEGIN			
			SELECT @asgn_id = min(asgn_id) from #resources where  asgn_id > @asgn_id
			IF @asgn_id is null
				break

				
			select @asgn_type = asgn_type from #resources where asgn_id = @asgn_id
			if @asgn_type = 'DRV'
				select @actg_type = mpp_actg_type ,@payto = mpp_payto from manpowerprofile where mpp_id = @asgn_id
			else if @asgn_type = 'TRC'
				select @actg_type = trc_actg_type ,@payto = trc_owner from tractorprofile where trc_number = @asgn_id					
			
			-- Get the appropriate ap/pr gl number
			SELECT  @glnum = ''
			IF @actg_type = 'A'
				SET @glnum = @ap_glnum
			ELSE IF @actg_type = 'P'
				SET @glnum = @pr_glnum
		
			if @li_ctr = 5 
			BEGIN
				select @enddate = convert(datetime , convert(varchar(8) ,getdate(),1)+ ' 23:59:59')
				select @Quantity = sum(pyd_quantity) 
				from paydetail a ,manpowerprofile b ,paytype c
				where 	a.asgn_type = 'DRV' and 
						a.asgn_id = @asgn_id and
						a.asgn_id = b.mpp_id and
						a.pyt_itemcode = c.pyt_itemcode and c.pyt_basisunit = 'DIS' and
						a.pyh_payperiod between mpp_90daystart and @enddate

				-- find the rate for this quantity 
				-- must be a lineitem rate matching the paytype. Picks the first hit.
				select @tarnum = min(a.tar_number) from tariffheaderstl a, tariffkey b
				where a.tar_number = b.tar_number and a.cht_itemcode = @paytype and b.trk_primary = 'L'
				if @tarnum > 0 
				begin
					select @range = min(trc_rangevalue)from tariffrowcolumnstl where tar_number = @tarnum and trc_rangevalue >= @Quantity
					if @range > 0 
					begin
						select @row = min(trc_number) from tariffrowcolumnstl where tar_number = @tarnum and trc_rangevalue = @range
						if @row > 0 					
						begin
							select @pdec_rate = tra_rate from tariffratestl where tar_number = @tarnum and trc_number_row = @row
						end
					end
				end 
				
				select @Quantity = @Quantity - 29900 -- reduce the quantity so only the mileage over this is paid.
				select @pdec_rate = IsNull(@pdec_rate,0)  
				select @pdec_amount = @Quantity * @pdec_rate
			END
					
			
	-- Get the next pyd_number from the systemnumber table
		IF @Quantity > 0 
		BEGIN
			IF @li_ctr = 5 
				update manpowerprofile set mpp_90daystart = convert(varchar(8) , dateadd(dd,1,getdate()),1) where mpp_id = @asgn_id


			IF @li_ctr = 4 -- orientation pay
				select @ldt_payperiod = @ldt_next_open_orientation_period
			ELSE
				select @ldt_payperiod = @ldt_next_open_period

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
			@ldt_payperiod, --@apocalypse, --pyh_payperiod
			@ldt_payperiod, --@apocalypse, --pyh_workperiod
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
			0, --std_number			--35
			
			'NA', --pyd_loadstate
			0, --pyd_xrefnumber
			@ordhdr,
			0, --pyt_fee1
			0, --pyt_fee2			--40
			
			0, --pyd_grossamount	
			'N', --pyd_adj_flag
			suser_sname(), --pyd_updatedby
			GETDATE(), --pyd_updatedon
			0) --pyd_ivh_hdrnumber		--45)
		END -- @quantity > 0 check
	END 

END 
--	drop table #paytypes
	drop table #resources

GO
GRANT EXECUTE ON  [dbo].[create_custom_arrow_pay_sp] TO [public]
GO
