SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/** Flags **/
-- +1 Check if paydetail exists, overwrite value if it does (Summary Systems/Meijer)
--		NOTE: the Summary Systems prepends the stop number to the pyd_description, so a check 
--			per stop can be made. Without this, it will check for any matching on the order
-- 		If flag +4 is set, then TransactionDate will be part of the match, but to the date part only.
-- +2 Use Rate from Pay Type		Will Pull Rate from Pay Type and calculate the amount
-- +4 Do not use Legheader			Will insert a Pay Datail without a Legheader or trip information.  
-- 									Pay Acts like a advance.
-- +8 Check if paydetail exists.  If it does add quantity and update.  
--		Only applies if Flag +1 = 0.
-- 		If flag +4 = 1, then TransactionDate will be part of the match, but to the date part only.
-- +16 Use Rate from Pay Type (Old Functionality)     Will Pull Rate from Pay Type and calculate the amount - leave amount = 0 
--									when quantity and rate are non zero
CREATE PROCEDURE [dbo].[tmail_AddPayDetail6] (@p_sLgh varchar(20),
										  @p_sMov varchar(20),
										  @p_sOrdHdr varchar(20),
							 			  @p_sQuantity varchar(20),
										  @p_DescPrefix varchar(45),	-- Will be Prepended to the pyd_description field
										  @p_asgn_type varchar(6),
										  @p_asgn_id varchar(13),
										  @p_PayType varchar(6),
										  @p_Flags varchar(10),
										  @p_TransactionDate varchar(30),
										  @p_sPayPeriod varchar(25),
										  @p_sMsgDate varchar(25),
										  @p_PaySchedulesHeaderName varchar(25),
										  @p_sStop varchar(20),
										  @p_cht_itemcode varchar(6))

AS


SET NOCOUNT ON 
/** 
 * 
 * NAME: 
 * dbo.tmail_AddPayDetail4
 * 
 * TYPE: 
 * StoredProcedure
 * 
 * DESCRIPTION: 
 * This procedure will insert a paydetail.
 * 
 * RETURNS: 
 * Raises error for specific issues.
 *
 * RESULT SETS: 
 * none
 * 
 * PARAMETERS: 	
 * 001 - @p_sLgh, varchar(20), input
 *       This is the lgh_number to apply the pay detail to.  If no lgh_number is passed
 *	   in and the +4 flag isn't set, an error will be raised.
 * 002 - @p_sMov, varchar(20), input
 * 	 Will insert into paydetail.mov_number. If not populated, it will be looked
 *	   up by the lgh_number (if the lgh_number is null then an error is raised).
 * 003 - @p_sOrdHdr, varchar(20), input
 * 	 Will insert into paydetail.ord_hdrnumber. If not populated, it will be looked
 *	   up by the lgh_number (if the lgh_number is null then an error is raised).
 * 004 - @p_sQuantity, varchar(20), input
 * 	 This is the quantity to put in for the paydetail (pyd_quantity)
 * 005 - @p_DescPrefix, varchar(45), input
 * 	 If a value is passed in this parameter, it will be prepended to 
 *	   the pyd_description field.
 * 006 - @p_asgn_type, varchar(6), input
 * 	 The paydetail asgn_type for the paydetail (DRV, TRC, CAR, TRL).  If none is
 *	   specified, then it will be determined by the lgh_number, and asgn_type 
 *	   (in this order: DRV, CAR, TRC).
 * 007 - @p_asgn_id, varchar(13), input
 * 	 The paydetail asgn_id for the paydetail.  If none is specified, then it will
 *	   be determined by the lgh_number and asgn_type.
 * 008 - @p_PayType, varchar(6), input
 * 	 The paytype used for the paydetail.pyt_itemcode field.  If nothing is supplied
 *	   then it will look in the generalinfo table for the 'TotalMailDefaultPayType'
 *	   value.  If none in there an error is raised.
 * 009 - @p_Flags, varchar(10), input
 * 	 Any flags that are used in this process as defined above.
 * 010 - @p_TransactionDate, varchar(30), input
 * 	 The transaction date (pyd_transdate) for the paydetail.  If no value is supplied,
 *	   GETDATE() is used.
 * 011 - @p_sPayPeriod, varchar(25), input
 * 	 The payperiod (pyd_payperiod) for this paydetail.  
 *		- If no value is supplied, Apocalyse will be used.
 *		- If 'NEXT' will find the min(psd_date) from payschedulesdetail that is 
 *		   greater than @p_MsgDate.  If @p_MsgDate is not supplied, the system
 *		   date is used.
 *		- If @p_sPayPeriod is supplied, it will use that (in conjuction with @p_PaySchedulesHeaderName)
 * 012 - @p_sMsgDate, varchar(25), input
 * 	 Only used if the @p_sPayPeriod is set to 'NEXT'.
 * 013 - @p_PaySchedulesHeaderName, varchar(25), input
 * 	 The name (psh_name) of the payschedulesheader used to find the next
 *	   available payperiod from the payschedulesdetail table.  This parameter is only 
 *	   noticed if @p_sPayPeriod is set to a datetime.
 * 014 - @p_sStop, varchar(20), input
 *   Will insert into paydetail.stp_number_pacos. If not populated, it will be left
 *     as blank.

 * REFERENCES:
 * Calls001    – dbo.getsystemnumber
 * CalledBy002 – dbo.tmail_AddPayDetailHrsMiles3 

 * 
 * REVISION HISTORY: 
 * 07/12/2004 - PTS      - TA  - Stole $/Total Mail 1.5/Custom - Customer Specific/Meijer/tm_InsertPayDetail by MZ; added @asgn_id parm; Quantity float.
 * 10/31/2005 – PTS30432 - MIZ – Added new parameter (@p_PaySchedulesHeaderName) and brought to db standards.
 * 
 **/ 

DECLARE	@actg_type char(1),
		@ap_glnum char(32),
		@Apocalypse datetime,		
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
		@Quantity float,
		@spyt_minus char(1),
		@pyt_Rate money,
		@pyd_amount money,
		@iCheckIfPayDetailExists int,
		@iUseRateFromPayType int,
		@iInsertWithNoLegheader int,
		@iAddQtyIfPayDetailExists int,
		@pyd_status varchar(3),
		@pyd_transdate datetime,
		@pyd_rate money,
		@pyd_quantity float,
		@pyh_payperiod datetime,
		@MsgDate datetime,
		@psd_id int,		-- payschedulesdetail id
		@intTransDate int,
		@Stop int

-- Get apocalypse now, redux
SELECT @Apocalypse = gi_date1
FROM generalinfo (NOLOCK)
WHERE gi_name = 'APOCALYPSE'

IF (ISNULL(@p_Flags,'') <> '')
	SET @iFlags = @p_Flags

--See if a Transaction Date was passed in
IF ISDATE(@p_TransactionDate) = 1
	SET @pyd_transdate = CONVERT(datetime, @p_TransactionDate)
ELSE
	SET @pyd_transdate = GETDATE()
SET @intTransDate = DATEPART(yyyy,@pyd_transdate) * 10000 + DATEPART(mm,@pyd_transdate) * 100 + DATEPART(dd,@pyd_transdate) 

IF (ISDATE(@p_sMsgDate) = 1)
	SET @MsgDate = DATEADD(d,DATEDIFF(d,'19500101',CONVERT(datetime, @p_sMsgDate)),'19500101')
ELSE
	-- No message date so just use system date
	SET @MsgDate = DATEADD(d,DATEDIFF(d,'19500101',GETDATE()),'19500101')

-- Try to find Pay Period
SET @pyh_payperiod = @Apocalypse
SET @psd_id = NULL
IF (@p_sPayPeriod = 'NEXT')
  /* Use the min(psd_date) that is greater than the message date.

     NOTE: this method should only be used for situations where there
	    is only one payschedulesheader defined since this routine
	    only looks in the payschedulesdetail table (ignores 
	    payschedulesheader)
  */

  BEGIN
	SELECT @pyh_payperiod = ISNULL(MIN(psd_date), @Apocalypse)
	FROM payschedulesdetail (NOLOCK)
	WHERE psd_date >= @MsgDate
		AND psd_status = 'OPN'

	IF (@pyh_payperiod <> @Apocalypse)  -- We found a payperiod, so let's get the psd_id
		SELECT @psd_id = MIN(psd_id)
		FROM payschedulesdetail (NOLOCK)
		WHERE psd_date = @pyh_payperiod
			AND psd_status = 'OPN'
  END
ELSE IF ISDATE(@p_sPayPeriod) = 1  -- A PayPeriod was passed in
  BEGIN
	SET @pyh_payperiod = CONVERT(datetime, @p_sPayPeriod)

	IF @p_PaySchedulesHeaderName <> ''
		-- Both a payperiod and payschedulesheader name were supplied, so make sure they're valid.
		IF NOT EXISTS(SELECT * 
				FROM payschedulesdetail (NOLOCK)
				INNER JOIN payschedulesheader (NOLOCK) on payschedulesdetail.psh_id = payschedulesheader.psh_id
				WHERE payschedulesheader.psh_name = @p_PaySchedulesHeaderName
					AND payschedulesdetail.psd_date = @pyh_payperiod
					AND payschedulesdetail.psd_status = 'OPN')
		  BEGIN
			RAISERROR('No open payperiod found for payperiod: %s on payschedulesheader: %s', 16, 1, @p_sPayPeriod, @p_PaySchedulesHeaderName)
			RETURN
		  END
		ELSE
			SELECT @psd_id = payschedulesdetail.psd_id
			FROM payschedulesdetail
			INNER JOIN payschedulesheader on payschedulesdetail.psh_id = payschedulesheader.psh_id
			WHERE payschedulesheader.psh_name = @p_PaySchedulesHeaderName
				AND payschedulesdetail.psd_date = @pyh_payperiod
				AND payschedulesdetail.psd_status = 'OPN'
	ELSE 
	  BEGIN
		-- Have a PayPeriod but no PaySchedulesHeaderName.
		SELECT @psd_id = ISNULL(MIN(psd_id),0)
		FROM payschedulesdetail (NOLOCK)
		WHERE psd_date = @pyh_payperiod
			AND psd_status = 'OPN'

		IF (@psd_id = 0)
		  BEGIN
			RAISERROR('No open payschedule found for payperiod: %s', 16, 1, @p_sPayPeriod)
			RETURN
		  END

		IF EXISTS (SELECT * FROM payschedulesdetail WHERE psd_date = @pyh_payperiod AND psd_id <> @psd_id AND psd_status = 'OPN')
		  BEGIN
			RAISERROR('Multiple open payschedules were found for payperiod: %s', 16, 1, @p_sPayPeriod)
			RETURN
		  END
	  END
  END   -- ISDATE(@p_sPayPeriod) = 1
ELSE IF @p_PaySchedulesHeaderName <> ''
  BEGIN
	-- We have a payschedulesheader name, but no payperiod. Find next payperiod for this payschedulesheader name
	SELECT @pyh_payperiod = ISNULL(MIN(payschedulesdetail.psd_date), @Apocalypse)
	FROM payschedulesdetail (NOLOCK)
	INNER JOIN payschedulesheader (NOLOCK) on payschedulesdetail.psh_id = payschedulesheader.psh_id
	WHERE payschedulesheader.psh_name = @p_PaySchedulesHeaderName
		AND payschedulesdetail.psd_status = 'OPN'
		AND payschedulesdetail.psd_date >= @MsgDate	

	IF (@pyh_payperiod <> @Apocalypse)
		-- We found a payperiod, so get the psd_id
		SELECT @psd_id = psd_id
		FROM payschedulesdetail (NOLOCK)
		INNER JOIN payschedulesheader (NOLOCK) on payschedulesdetail.psh_id = payschedulesheader.psh_id
		WHERE payschedulesheader.psh_name = @p_PaySchedulesHeaderName
			AND payschedulesdetail.psd_date = @pyh_payperiod
			AND payschedulesdetail.psd_status = 'OPN'
  END
ELSE
	-- No way to find payperiod, so default to Apocalypse.
	SET @pyh_payperiod = @Apocalypse

-- Check if paydetail exists, overwrite value if it does (Summary Systems/Meijer)
SET @iCheckIfPayDetailExists = 0
IF (@iFlags & 1) <> 0
	SET @iCheckIfPayDetailExists = 1

--DWG {24655} - Use Rate from Pay Type
SET @iUseRateFromPayType = 0
IF (@iFlags & 2) <> 0
	SET @iUseRateFromPayType = 1

SET @iInsertWithNoLegheader = 0
IF (@iFlags & 4) <> 0
	SET @iInsertWithNoLegheader = 1
	
SET @iAddQtyIfPayDetailExists = 0
IF (@iFlags & 8) <> 0
	SET @iAddQtyIfPayDetailExists = 1
	
-- Override AddQty if necessary
IF @iCheckIfPayDetailExists = 1 
	SET @iAddQtyIfPayDetailExists = 0
	
IF (ISNULL(@p_PayType,'') = '') 
	-- No PayType specified in parameter list, so look up in generalinfo
	SELECT @p_PayType = ISNULL(gi_string1,'')
	FROM generalinfo
	WHERE gi_name = 'TotalMailDefaultPayType'

IF ISNULL(@p_PayType,'') = '' 
  BEGIN
	RAISERROR ('No Pay Type specified, and generalinfo setting TotalMailDefaultPayType not set.', 16, 1)
	RETURN
  END

IF NOT EXISTS (SELECT * 
				FROM paytype (NOLOCK)
				WHERE pyt_itemcode = @p_PayType)
  BEGIN
	RAISERROR ('Invalid Pay Type specified: %s.', 16, 1, @p_PayType)
	RETURN
  END
  
  IF ISNULL(@p_cht_itemcode,'')<>''
  BEGIN
	  IF NOT EXISTS (SELECT * 
					FROM chargetype (NOLOCK)
					WHERE cht_itemcode = @p_cht_itemcode)
	  BEGIN
		RAISERROR ('Invalid Charge Type specified: %s.', 16, 1, @p_cht_itemcode)
		RETURN
	  END
  END

-- If no lgh number was passed in, raise an error
If @iInsertWithNoLegheader = 0
	BEGIN
	IF ISNULL(@p_sLgh,'') = '' 
	  BEGIN
		RAISERROR ('No legheader specified: %s', 16, 1, @p_sLgh)
		RETURN
	  END
	ELSE
		SET @lgh = CONVERT(int, ISNULL(@p_sLgh, ''))

	-- Get the move number squared away
	IF ISNULL(@p_sMov,'') = '' 
		SELECT @mov = mov_number 
		FROM legheader (NOLOCK)
		where lgh_number = @lgh
	ELSE
		SET @mov = CONVERT(int, ISNULL(@p_sMov, ''))

	-- Set the Stop Number from parameter
	IF ISNULL(@p_sStop,'') = '' 
		SET @Stop = NULL 
	ELSE
	BEGIN
		IF ISNUMERIC(@p_sStop)=1
			SET @Stop = CONVERT(int, ISNULL(@p_sStop, ''))
		ELSE
			SET @Stop = NULL
	END

	-- Get the order header number squared away
	IF ISNULL(@p_sordhdr,'') = '' 
		SELECT @ordhdr = ord_hdrnumber 
		FROM legheader (NOLOCK)
		where lgh_number = @lgh
	ELSE
		SET @ordhdr = CONVERT(int, ISNULL(@p_sordhdr, ''))
	END
ELSE
	BEGIN
	SELECT @lgh = 0, @mov = 0, @ordhdr = 0
	IF ISNULL(@p_asgn_id, '') = '' 
		BEGIN
			RAISERROR ('An asgn_id must be specified when a leg header is not specified', 16, 1)
			RETURN
		END
	IF ISNULL(@p_asgn_type, '') = '' 
		BEGIN
			RAISERROR ('An asgn_type must be specified when a leg header is not specified', 16, 1)
			RETURN
		END
	END

IF ISNULL(@p_sQuantity,'') <> ''
	SET @Quantity = CONVERT(float, @p_sQuantity)
ELSE
	SET @Quantity = 0

IF ISNULL(@p_asgn_type, '') <> '' AND @lgh > 0
	IF NOT EXISTS (SELECT asgn_number 
					FROM assetassignment (NOLOCK) 
					WHERE lgh_number = @lgh AND asgn_type = @p_asgn_type)
	  BEGIN
		RAISERROR ('An asgn_type was specified, but no match in assetassignment could be found: LGH: %s, ASGN_TYPE: %s', 16, 1, @p_sLgh, @p_asgn_type)
		RETURN
	  END

-- Do we have a driver assigned yet, or should we use carrier?
IF ISNULL(@p_asgn_type, '') = '' 
	  BEGIN
		IF EXISTS (SELECT asgn_number 
					FROM assetassignment (NOLOCK)
					WHERE lgh_number = @lgh AND asgn_type = 'DRV')
			SET @p_asgn_type = 'DRV'
		ELSE IF EXISTS (SELECT asgn_number 
						FROM assetassignment (NOLOCK)
						WHERE lgh_number = @lgh AND asgn_type = 'CAR')
			SET @p_asgn_type = 'CAR'
		ELSE IF EXISTS (SELECT asgn_number 
						FROM assetassignment (NOLOCK) 
						WHERE lgh_number = @lgh AND asgn_type = 'TRC')
			SET @p_asgn_type = 'TRC'
	  END

IF ISNULL(@p_asgn_id, '') <> '' AND @lgh > 0
	IF NOT EXISTS (SELECT asgn_number 
					FROM assetassignment (NOLOCK)
					WHERE lgh_number = @lgh AND asgn_type = @p_asgn_type AND asgn_id = @p_asgn_id)
	  BEGIN
		RAISERROR ('An asgn_id was specified, but no match in assetassignment could be found: LGH: %s, ASGN_TYPE: %s, ASGN_ID: %s', 16, 1, @p_sLgh, @p_asgn_type, @p_asgn_id)
		RETURN
	  END

-- Get info from assetassignment
IF ISNULL(@p_asgn_id, '') = ''
	SELECT  @asgn_number = asgn_number,
			@p_asgn_id = ISNULL(asgn_id,'')
		FROM assetassignment (NOLOCK)
		WHERE lgh_number = @lgh
			AND asgn_type = @p_asgn_type
ELSE
	BEGIN
	IF @lgh > 0
		SELECT  @asgn_number = asgn_number
			FROM assetassignment (NOLOCK)
			WHERE lgh_number = @lgh
				AND asgn_type = @p_asgn_type
				AND asgn_id = @p_asgn_id
	ELSE
		SELECT @asgn_number = 0
	END
-- Get info from manpowerprofile, carrierprofile, tractorprofile or trailerprofile.
IF @p_asgn_type = 'DRV'
	SELECT  @actg_type = ISNULL(mpp_actg_type,''),
			@payto = ISNULL(mpp_payto,''),
			@currency = ISNULL(mpp_currency,'')
	FROM manpowerprofile (NOLOCK)
	WHERE mpp_id = @p_asgn_id
ELSE IF @p_asgn_type = 'CAR'
	SELECT  @actg_type = ISNULL(car_actg_type,''),
			@payto = 'UNKNOWN',
			@currency = ISNULL(car_currency,'')
	FROM carrier
	WHERE car_id = @p_asgn_id
ELSE IF @p_asgn_type = 'TRC'
	SELECT  @actg_type = ISNULL(trc_actg_type,''),
			@payto = 'UNKNOWN',
			@currency = 'US$'	-- There is no trc_currency field at this time, so default to US$
	FROM tractorprofile (NOLOCK)
	WHERE trc_number = @p_asgn_id
ELSE IF @p_asgn_type = 'TRL'
	SELECT  @actg_type = ISNULL(trl_actg_type,''),
			@payto = 'UNKNOWN',
			@currency = 'US$'	-- There is no trl_currency field at this time, so default to US$
	FROM trailerprofile (NOLOCK)
	WHERE trl_number = @p_asgn_id

-- Get info from PayType
SELECT  @pyt_description = ISNULL(pyt_description,''),
		@pyt_rateunit = ISNULL(pyt_rateunit,''),
		@pyt_unit = ISNULL(pyt_unit,''),
		@pyt_pretax = ISNULL(pyt_pretax,''),
		@pr_glnum = ISNULL(pyt_pr_glnum,''),
		@ap_glnum = ISNULL(pyt_ap_glnum,''),
		@spyt_minus = ISNULL(pyt_minus,''),
		@pyt_Rate = pyt_rate
FROM paytype (NOLOCK)
WHERE pyt_itemcode = @p_PayType

-- PTS32148
if (@iUseRateFromPayType = 0) AND (@iFlags & 16) = 0 
	BEGIN
		SET @pyd_rate = 0
		SET @pyt_rate = 0
  		SET @pyd_amount = null
	END

-- Add the prefix if there is one
IF (@p_DescPrefix <> '')
	SET @pyt_description = @p_DescPrefix + ' ' + @pyt_description

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
if @lgh > 0
	BEGIN
		SELECT  @lgh_startcity = lgh_startcity,
				@lgh_endcity = lgh_endcity,
				@lgh_startpoint = ISNULL(cmp_id_start,''),
				@lgh_endpoint = ISNULL(cmp_id_end,'')
		FROM legheader (NOLOCK)
		WHERE lgh_number = @lgh
	END
else
	SELECT  @lgh_startcity = NULL,
			@lgh_endcity = NULL,
			@lgh_startpoint = NULL,
			@lgh_endpoint = NULL

-- Get the paydetail sequence number
if @lgh > 0
	SELECT @pyd_sequence = ISNULL(MAX(pyd_sequence),0) + 1
	FROM paydetail (NOLOCK)
	WHERE lgh_number = @lgh
else 
	SELECT @pyd_sequence = ISNULL(MAX(pyd_sequence),0) + 1
	FROM paydetail (NOLOCK)
	WHERE asgn_type = @p_asgn_type AND asgn_id = @p_asgn_id AND lgh_number = 0

-- Duplicate check/update
IF (@iCheckIfPayDetailExists = 1) or (@iAddQtyIfPayDetailExists = 1)
 	BEGIN
	if @lgh >0 
  	  	BEGIN
		-- Check if this record already exists
		SET @pyd_number_test = 0
		SELECT  @pyd_number_test = pyd_number, 
				@pyd_quantity_test = ISNULL(pyd_quantity,0),
				@pyd_rate = pyd_rate
		FROM paydetail (NOLOCK)
		WHERE lgh_number = @lgh 
			AND asgn_number = @asgn_number 
			AND pyd_description = @pyt_description
	  	END
    else
  	  	BEGIN
		-- Check if this record already exists
		SET @pyd_number_test = 0
		SELECT  @pyd_number_test = pyd_number, 
				@pyd_quantity_test = ISNULL(pyd_quantity,0),
				@pyd_rate = pyd_rate
		FROM paydetail (NOLOCK)
		WHERE pyt_itemcode = @p_PayType
			AND DATEPART(yyyy,pyd_transdate) * 10000 + DATEPART(mm,pyd_transdate) * 100 + DATEPART(dd,pyd_transdate) = @intTransDate
			AND asgn_id = @p_asgn_id
			AND asgn_type = @p_asgn_type
	  	END

	IF (ISNULL(@pyd_number_test,0) > 0)
		BEGIN
		IF @iCheckIfPayDetailExists = 1
			SET @pyd_quantity = @Quantity
		ELSE
			SET @pyd_quantity = @Quantity + @pyd_quantity_test
		IF @iCheckIfPayDetailExists = 1 AND (@pyd_quantity = 0) 
			-- A record exists, but the new Quantity is Zero, 
			--  so just delete the paydetail
			DELETE paydetail
				WHERE pyd_number = @pyd_number_test
		ELSE IF (@pyd_quantity_test <> @pyd_quantity)
			-- An entry for this stop exists, with a different quantity
			-- Update the existing record with the new quantity
		  	BEGIN
			IF @iUseRateFromPayType = 1 AND ISNULL(@pyt_Rate, 0) > 0 
	  			SET @pyd_rate = @pyt_rate
	  		SET @pyd_amount = @pyd_quantity * @pyd_Rate
	  		UPDATE paydetail
				SET pyd_quantity = @pyd_quantity,
					pyd_amount = @pyd_amount,
					pyd_rate = @pyd_rate,
					pyd_updsrc = 'T'
				WHERE pyd_number = @pyd_number_test
	  		END
		RETURN
		END
  	END

-- Get the next pyd_number from the systemnumber table
EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM',''

--calculate the amount if the flag is on and we have a pay rate
IF @iUseRateFromPayType = 1 AND ISNULL(@pyt_Rate, 0) > 0 
	SET @pyd_amount = @Quantity * @pyt_Rate

if @lgh > 0
	SET @pyd_status = 'HLD'
else 
	SET @pyd_status = 'PND'

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
						pyd_ivh_hdrnumber,	--45
	
						psd_id,
						stp_number_pacos,
						cht_itemcode,   --48
						pyd_updsrc)
VALUES (@pyd_number,
		0,
		@lgh,
		@asgn_number,
		@p_asgn_type,		--5

		@p_asgn_id,
		0,  --ivd_number
		@actg_type,
		@payto,
		@p_PayType,		--10

		@mov,
		@pyt_description,
		@Quantity,
		@pyt_rateunit,
		@pyt_unit,		--15

		@pyt_Rate, --pyt_rate,
		@pyd_amount, --pyt_amount
		@pyt_pretax,
		@glnum,
		@currency,		--20

		@pyd_status, --pyd_status
		@pyh_payperiod,
		@Apocalypse, --pyh_workperiod
		@lgh_startpoint,
		@lgh_startcity,		--25

		@lgh_endpoint,
		@lgh_endcity,
		0, --ivd_payrevenue
		0, --pyd_revenueratio
		0, --pyd_lessrevenue	--30

		0, --pyd_payrevenue
		@pyd_transdate, 
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

		@psd_id,
		@Stop,
		@p_cht_itemcode,				--48
		'T')
GO
GRANT EXECUTE ON  [dbo].[tmail_AddPayDetail6] TO [public]
GO
