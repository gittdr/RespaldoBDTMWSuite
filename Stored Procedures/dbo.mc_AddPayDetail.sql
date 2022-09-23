SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[mc_AddPayDetail] (	@TransactionDate datetime,
										@LegNumber int,
										@OrderHdrNumber int,
										@MoveNumber int,
										@PayType varchar(6),
										@ChargeType varchar(6),
										@Quantity decimal,
										@Status varchar(6),
										@StopNumber int,
										@AssetType varchar(6),
										@AssetId varchar(50),
										@DescriptionPrefix varchar(50)
									)

AS

SET NOCOUNT ON 

DECLARE	@actg_type char(1),
		@ap_glnum char(32),
		@Apocalypse datetime,		
		@asgn_number int,
		@currency varchar(6),
		@lgh_endcity int = NULL,
		@lgh_endpoint varchar(12) = NULL,
		@lgh_startcity int = NULL,
		@lgh_startpoint varchar(12) = NULL,
		@payto varchar(12),
		@pr_glnum char(32),
		@pyd_number int,
		@pyd_sequence int,
		@pyt_description varchar(75),
		@pyt_pretax char(1),
		@pyt_rateunit varchar(6),
		@pyt_unit varchar(6),
		@spyt_minus char(1),
		--@pyd_transdate datetime,
		@pyh_payperiod datetime,
		@psd_id int	

--Validation
IF NOT EXISTS (SELECT * 
				FROM paytype (NOLOCK)
				WHERE pyt_itemcode = @PayType)
BEGIN
	RAISERROR ('Invalid Pay Type specified: %s.', 16, 1, @PayType)
	RETURN
END

IF ISNULL(@ChargeType,'')<>''
BEGIN
	IF NOT EXISTS (SELECT * 
					FROM chargetype (NOLOCK)
					WHERE cht_itemcode = @ChargeType)
	BEGIN
		RAISERROR ('Invalid Charge Type specified: %s.', 16, 1, @ChargeType)
		RETURN
	END
END

IF (@LegNumber > 0) AND NOT EXISTS (SELECT asgn_number 
					FROM assetassignment (NOLOCK) 
					WHERE lgh_number = @LegNumber)
BEGIN
	RAISERROR ('Invalid leg %i.', 16, 1, @LegNumber)
	RETURN
END


IF @LegNumber > 0 AND NOT EXISTS (SELECT asgn_number 
					FROM assetassignment (NOLOCK)
					WHERE lgh_number = @LegNumber AND asgn_type = @AssetType AND asgn_id = @AssetId)
BEGIN
	RAISERROR ('Asset (%s: %s) is not assigned to leg %i.', 16, 1, @AssetType, @AssetId, @LegNumber)
	RETURN
END

IF ISNULL(@Status, '') NOT IN ('HLD', 'PND')
BEGIN
	RAISERROR ('Invalid status.  New paydetails must inserted in status Hold or Pending. (Submitted status: %s)', 16, 1, @Status)
	RETURN
END

--End Validation

--Initialize local variables	
	SELECT @Apocalypse = gi_date1
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'APOCALYPSE'
--End Initialize local variables

--Initialize Pay Variables Based on Asset
	IF @AssetType = 'DRV'
		SELECT  @actg_type = ISNULL(mpp_actg_type,''),
				@payto = ISNULL(mpp_payto,''),
				@currency = ISNULL(mpp_currency,'')
		FROM manpowerprofile (NOLOCK)
		WHERE mpp_id = @AssetId
	ELSE IF @AssetType = 'CAR'
		SELECT  @actg_type = ISNULL(car_actg_type,''),
				@payto = 'UNKNOWN',
				@currency = ISNULL(car_currency,'')
		FROM carrier
		WHERE car_id = @AssetId
	ELSE IF @AssetType = 'TRC'
		SELECT  @actg_type = ISNULL(trc_actg_type,''),
				@payto = 'UNKNOWN',
				@currency = 'US$'	-- There is no trc_currency field at this time, so default to US$
		FROM tractorprofile (NOLOCK)
		WHERE trc_number = @AssetId
	ELSE IF @AssetType = 'TRL'
		SELECT  @actg_type = ISNULL(trl_actg_type,''),
				@payto = 'UNKNOWN',
				@currency = 'US$'	-- There is no trl_currency field at this time, so default to US$
		FROM trailerprofile (NOLOCK)
		WHERE trl_number = @AssetId
--End Initialize Pay Variables Based on Asset

--Initialize Pay Variables Based on PayType
	SELECT  @pyt_description = ISNULL(pyt_description,''),
			@pyt_rateunit = ISNULL(pyt_rateunit,''),
			@pyt_unit = ISNULL(pyt_unit,''),
			@pyt_pretax = ISNULL(pyt_pretax,''),
			@pr_glnum = ISNULL(pyt_pr_glnum,''),
			@ap_glnum = ISNULL(pyt_ap_glnum,''),
			@spyt_minus = ISNULL(pyt_minus,'')
	FROM paytype (NOLOCK)
	WHERE pyt_itemcode = @PayType
--End Initialize Pay Variables Based on PayType

-- Get info from legheader
if @LegNumber > 0
	BEGIN
		SELECT  @lgh_startcity = lgh_startcity,
				@lgh_endcity = lgh_endcity,
				@lgh_startpoint = ISNULL(cmp_id_start,''),
				@lgh_endpoint = ISNULL(cmp_id_end,'')
		FROM legheader (NOLOCK)
		WHERE lgh_number = @LegNumber
	END

-- Get the paydetail sequence number
if @LegNumber > 0
	SELECT @pyd_sequence = ISNULL(MAX(pyd_sequence),0) + 1
	FROM paydetail (NOLOCK)
	WHERE lgh_number = @LegNumber
else 
	SELECT @pyd_sequence = ISNULL(MAX(pyd_sequence),0) + 1
	FROM paydetail (NOLOCK)
	WHERE asgn_type = @AssetType AND asgn_id = @AssetId AND lgh_number = 0

-- Get the next pyd_number from the systemnumber table
EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM',''

-- Do the insert
INSERT INTO paydetail  (pyd_number,
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
						psd_id,
						stp_number,
						cht_itemcode   --45
						
						)
VALUES (@pyd_number,
		0,
		@LegNumber,
		@asgn_number,
		@AssetType,		--5

		@AssetId,
		0,  --ivd_number
		@actg_type,
		@payto,
		@PayType,		--10

		@MoveNumber,
		CASE WHEN ISNULL(@DescriptionPrefix,'') <> '' THEN @DescriptionPrefix + ' ' + @pyt_description ELSE @pyt_description END,
		@Quantity,
		@pyt_rateunit,
		@pyt_unit,		--15

		0, --pyt_rate,
		0, --pyt_amount
		@pyt_pretax,
		CASE @actg_type WHEN 'A' THEN @ap_glnum WHEN 'P' THEN @pr_glnum ELSE '' END,
		@currency,		--20

		@Status,
		@Apocalypse,
		@Apocalypse, --pyh_workperiod
		@lgh_startpoint,
		@lgh_startcity,		--25

		@lgh_endpoint,
		@lgh_endcity,
		0, --ivd_payrevenue
		0, --pyd_revenueratio
		0, --pyd_lessrevenue	--30

		0, --pyd_payrevenue
		@TransactionDate, 
		CASE @spyt_minus WHEN 'Y' THEN -1 ELSE 1 END,
		@pyd_sequence,	
		0, --std_number			--35

		'NA', --pyd_loadstate
		0, --pyd_xrefnumber
		@OrderHdrNumber,
		0, --pyt_fee1
		0, --pyt_fee2			--40

		0, --pyd_grossamount	
		'N', --pyd_adj_flag
				@psd_id,
		@StopNumber,
		@ChargeType				--45
		)

		select @pyd_number
GO
GRANT EXECUTE ON  [dbo].[mc_AddPayDetail] TO [public]
GO
