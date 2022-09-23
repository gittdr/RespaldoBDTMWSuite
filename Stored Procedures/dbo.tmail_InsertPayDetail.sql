SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 01/07/03 MZ Created */

/** Flags **/
-- +1	Check if paydetail exists, overwrite value if it does (Summary Systems/Meijer)
--		NOTE: the Summary Systems prepends the stop number to the pyd_description, so a check 
--			per stop can be made. Without this, it will check for any matching on the order

CREATE PROCEDURE [dbo].[tmail_InsertPayDetail] (@sLgh varchar(20),
												@sMov varchar(20),
												@sOrdHdr varchar(20),
												@sQuantity varchar(20),
												@DescPrefix varchar(45),	-- Will be Prepended to the pyd_description field
												@asgn_type varchar(6),
												@PayType varchar(6),
												@Flags varchar(10))

AS

SET NOCOUNT ON 

DECLARE	@actg_type char(1),
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
		@spyt_minus char(1)

IF (ISNULL(@Flags,'') <> '')
	SET @iFlags = @Flags

IF (ISNULL(@PayType,'') = '') 
	-- No PayType specified in parameter list, so look up in generalinfo
	SELECT @PayType = ISNULL(gi_string1,'')
	FROM generalinfo (NOLOCK)
	WHERE gi_name = 'TotalMailDefaultPayType'

IF ISNULL(@PayType,'') = '' 
  BEGIN
	RAISERROR ('No Pay Type specified, and generalinfo setting TotalMailDefaultPayType not set: %s', 16, 1, @sLgh)
	RETURN
  END

-- If no lgh number was passed in, raise an error
IF ISNULL(@sLgh,'') = ''
  BEGIN
	RAISERROR ('No legheader specified: %s', 16, 1, @sLgh)
	RETURN
  END
ELSE
	SET @lgh = CONVERT(int, @sLgh)
	
-- Get the move number squared away
IF ISNULL(@sMov,'') = '' 
	SELECT @mov = mov_number 
	FROM legheader (NOLOCK)
	where lgh_number = @lgh
ELSE
	SET @mov = CONVERT(int, @smov)

-- Get the order header number squared away
IF ISNULL(@sordhdr,'') = '' 
	SELECT @mov = mov_number 
	FROM legheader (NOLOCK)
	where lgh_number = @lgh
ELSE
	SET @ordhdr = CONVERT(int, @sordhdr)

IF ISNULL(@sQuantity,'') <> ''
	SET @Quantity = CONVERT(varchar(20), @sQuantity)
ELSE
	SET @Quantity = 0

-- Get apocalypse now, redux
SELECT @Apocalypse = gi_date1
FROM generalinfo (NOLOCK)
WHERE gi_name = 'APOCALYPSE'

IF ISNULL(@asgn_type, '') <> ''
	IF NOT EXISTS (SELECT asgn_number 
					FROM assetassignment (NOLOCK) 
					WHERE lgh_number = @lgh AND asgn_type = @asgn_type)
	  BEGIN
		RAISERROR ('An asgn_type was specified, but no match in assetassignment could be found: LGH: %s, ASGN_TYPE: %s', 16, 1, @sLgh, @asgn_type)
		RETURN
	  END

-- Do we have a driver assigned yet, or should we use carrier?
IF ISNULL(@asgn_type, '') = ''
  BEGIN
	IF EXISTS (SELECT asgn_number 
				FROM assetassignment (NOLOCK)
				WHERE lgh_number = @lgh AND asgn_type = 'DRV')
		SET @asgn_type = 'DRV'
	ELSE IF EXISTS (SELECT asgn_number 
					FROM assetassignment (NOLOCK)
					WHERE lgh_number = @lgh AND asgn_type = 'CAR')
		SET @asgn_type = 'CAR'
	ELSE IF EXISTS (SELECT asgn_number 
						FROM assetassignment (NOLOCK) 
						WHERE lgh_number = @lgh AND asgn_type = 'TRC')
		SET @asgn_type = 'TRC'
  END

-- Get info from assetassignment
SELECT  @asgn_number = asgn_number,
		@asgn_id = ISNULL(asgn_id,'')
FROM assetassignment (NOLOCK)
WHERE lgh_number = @lgh
	AND asgn_type = @asgn_type

-- Get info from manpowerprofile, carrierprofile, tractorprofile or trailerprofile.
IF @asgn_type = 'DRV'
	SELECT  @actg_type = ISNULL(mpp_actg_type,''),
			@payto = ISNULL(mpp_payto,''),
			@currency = ISNULL(mpp_currency,'')
	FROM manpowerprofile (NOLOCK)
	WHERE mpp_id = @asgn_id
ELSE IF @asgn_type = 'CAR'
	SELECT  @actg_type = ISNULL(car_actg_type,''),
			@payto = 'UNKNOWN',
			@currency = ISNULL(car_currency,'')
	FROM carrier (NOLOCK)
	WHERE car_id = @asgn_id
ELSE IF @asgn_type = 'TRC'
	SELECT  @actg_type = ISNULL(trc_actg_type,''),
			@payto = 'UNKNOWN',
			@currency = 'US$'	-- There is no trc_currency field at this time, so default to US$
	FROM tractorprofile (NOLOCK)
	WHERE trc_number = @asgn_id
ELSE IF @asgn_type = 'TRL'
	SELECT  @actg_type = ISNULL(trl_actg_type,''),
			@payto = 'UNKNOWN',
			@currency = 'US$'	-- There is no trl_currency field at this time, so default to US$
	FROM trailerprofile (NOLOCK)
	WHERE trl_number = @asgn_id

-- Get info from PayType
SELECT  @pyt_description = ISNULL(pyt_description,''),
		@pyt_rateunit = ISNULL(pyt_rateunit,''),
		@pyt_unit = ISNULL(pyt_unit,''),
		@pyt_pretax = ISNULL(pyt_pretax,''),
		@pr_glnum = ISNULL(pyt_pr_glnum,''),
		@ap_glnum = ISNULL(pyt_ap_glnum,''),
		@spyt_minus = ISNULL(pyt_minus,'')
FROM paytype (NOLOCK)
WHERE pyt_itemcode = @PayType

-- Add the prefix if there is one
IF (@DescPrefix <> '')
	SET @pyt_description = @DescPrefix + ' ' + @pyt_description

SET @pyt_minus = 1	-- default to 1
IF @spyt_minus = 'Y'
	SET @pyt_minus = -1

-- Get the appropriate ap/pr gl number
SET @glnum = ''
IF @actg_type = 'A'
	SET @glnum = @ap_glnum
ELSE IF @actg_type = 'P'
	SET @glnum = @pr_glnum

-- Get info from legheader
SELECT  @lgh_startcity = lgh_startcity,
		@lgh_endcity = lgh_endcity,
		@lgh_startpoint = ISNULL(cmp_id_start,''),
		@lgh_endpoint = ISNULL(cmp_id_end,'')
FROM legheader (NOLOCK)
WHERE lgh_number = @lgh

-- Get the paydetail sequence number
SELECT @pyd_sequence = ISNULL(MAX(pyd_sequence),0) + 1
FROM paydetail (NOLOCK)
WHERE lgh_number = @lgh

-- Summary Systems duplicate check/update
IF (@iFlags & 1) <> 0	
  BEGIN
	-- Check if this record already exists
	SET @pyd_number_test = 0
	SELECT  @pyd_number_test = pyd_number, 
			@pyd_quantity_test = ISNULL(pyd_quantity,0)
	FROM paydetail (NOLOCK)
	WHERE lgh_number = @lgh 
		AND asgn_number = @asgn_number 
		AND pyd_description = @pyt_description

	IF (ISNULL(@pyd_number_test,0) > 0)
	  BEGIN
		IF (@Quantity = 0) 
			-- A record exists, but the new Quantity is Zero, 
			--  so just delete the paydetail
			DELETE paydetail 
			WHERE pyd_number = @pyd_number_test
		ELSE IF (@pyd_quantity_test <> @Quantity)
			-- An entry for this stop exists, with a different quantity
			-- Update the existing record with the new quantity
			UPDATE paydetail
			SET pyd_quantity = @Quantity,
				pyd_updsrc = 'T'
			WHERE pyd_number = @pyd_number_test

		RETURN  -- We have an entry, so return when finished
	  END
  END

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
						pyd_updatedby,
						pyd_updatedon,
						pyd_ivh_hdrnumber, 	--45
						pyd_updsrc)
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

		0, --pyt_rate,
		0, --pyt_amount
		@pyt_pretax,
		@glnum,
		@currency,		--20

		'HLD', --pyd_status
		@Apocalypse, --pyh_payperiod
		@Apocalypse, --pyh_workperiod
		@lgh_startpoint,
		@lgh_startcity,		--25

		@lgh_endpoint,
		@lgh_endcity,
		0, --ivd_payrevenue
		0, --pyd_revenueratio
		0, --pyd_lessrevenue	--30

		0, --pyd_payrevenue
		GETDATE(), --pyd_transdate
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
		'TMAIL', --pyd_updatedby
		GETDATE(), --pyd_updatedon
		0, --pyd_ivh_hdrnumber		--45
		'T')
GO
GRANT EXECUTE ON  [dbo].[tmail_InsertPayDetail] TO [public]
GO
