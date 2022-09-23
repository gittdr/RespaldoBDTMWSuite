SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
Create procedure [dbo].[aprecon_insert_paydetail_sp] (@pl_lgh int , @pdec_amount money)
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
		@Quantity int,
		@spyt_minus char(1),
		@asgn_type varchar(6),
		@pyd_transdate datetime

	SELECT @lgh = @pl_lgh
	SELECT @quantity = 1

	SELECT @Apocalypse = gi_date1
	FROM generalinfo
	WHERE gi_name = 'APOCALYPSE'

	If @Apocalypse is null  
		select @Apocalypse = convert(datetime,'20491231 23:59:59')

	Select @asgn_type = 'CAR'
	Select @asgn_id = lgh_carrier from legheader where lgh_number = @pl_lgh

	SELECT  @asgn_number = asgn_number
	FROM 	assetassignment
	WHERE 	lgh_number = @lgh
			AND asgn_type = @asgn_type

	
	SELECT @payto = pto_id from carrier where car_id = @asgn_id
	
	
	
	SELECT @PayType = IsNull(gi_string1,'FLAT') from generalinfo where gi_name = 'APRECONPAYTYPE'
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
	
	-- Get the appropriate ap/pr gl number
	SELECT  @glnum = ''
	IF @actg_type = 'A'
		SET @glnum = @ap_glnum
	ELSE IF @actg_type = 'P'
		SET @glnum = @pr_glnum
	
	-- Get info from legheader
	SELECT  @lgh_startcity = lgh_startcity,
			@lgh_endcity = lgh_endcity,
			@lgh_startpoint = ISNULL(cmp_id_start,''),
			@lgh_endpoint = ISNULL(cmp_id_end,''),
			@mov = mov_number			
	FROM legheader
	WHERE lgh_number = @lgh

	Select @ordhdr = min(ord_hdrnumber) from orderheader where mov_number = @mov
	-- transdate 
	Select @pyd_transdate = stp_arrivaldate from stops where lgh_number = @lgh and
	stp_mfh_sequence = (select max(stp_mfh_sequence) from stops where lgh_number = @lgh)	
	-- Get the paydetail sequence number
	SELECT @pyd_sequence = ISNULL(MAX(pyd_sequence),0) + 1
	FROM paydetail
	WHERE lgh_number = @lgh
	


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
		0,
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

		@pdec_amount, --pyt_rate,
		@pdec_amount, --pyt_amount
		@pyt_pretax,
		@glnum,
		@currency,		--20

		'PND', --pyd_status
		@apocalypse, --pyh_payperiod
		@apocalypse, --pyh_workperiod
		@lgh_startpoint,
		@lgh_startcity,		--25

		@lgh_endpoint,
		@lgh_endcity,
		0, --ivd_payrevenue
		0, --pyd_revenueratio
		0, --pyd_lessrevenue	--30

		0, --pyd_payrevenue
		@pyd_transdate, --pyd_transdate
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
		0) --pyd_ivh_hdrnumber		--45

		return @@error

GO
GRANT EXECUTE ON  [dbo].[aprecon_insert_paydetail_sp] TO [public]
GO
