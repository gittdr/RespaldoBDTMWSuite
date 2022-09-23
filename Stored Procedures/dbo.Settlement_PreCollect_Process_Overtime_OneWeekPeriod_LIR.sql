SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| BEGIN CREATE procedure for 'Settlement_PreCollect_Process_Overtime_OneWeekPeriod_LIR' for .NET Overtime Pay calculations                                     	                 |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[Settlement_PreCollect_Process_Overtime_OneWeekPeriod_LIR](@pl_pyhnumber INT, @ps_asgn_type VARCHAR(6), @ps_asgn_id VARCHAR(13), @pdt_payperiod DATETIME, @psd_id INT)
AS

DECLARE @asgn_id VARCHAR(13),
		@asgn_number INT,
		@pyd_number INT,
		@pyd_sequence INT,
		@pyt_description VARCHAR(75),
		@asgn_type VARCHAR(6),
		@ldt_lastpayperiod DATETIME,
		@ldt_lastpayperiod_7 DATETIME,
		@ldt_FROM DATETIME,
		@ldt_to DATETIME,
		@last_week DATETIME,
		@OvertimePayType VARCHAR(6),
		@ps_returnmsg	VARCHAR(255)

DECLARE @ii INT,
	@ldec_period_trans FLOAT,
	@ldec_period_lgh FLOAT,
	@pyd_number_update INT,
	@ot_pyd_sequence INT,
	@period_pyd_sequence INT,
	@ldec_period FLOAT, 
	@ldec_period_new FLOAT, 
	@ldec_period_max MONEY, 
	@ldec_period_qty FLOAT,
	@insert_ot_qty FLOAT,
	@update_qty FLOAT,
	@update_period_qty FLOAT,
	@insert_period_qty FLOAT,
	@ldec_ot_qty FLOAT,
	@ls_payto VARCHAR(12),
	@last_pyd_number INT,
	@li_tret INT , 
	@li_ret INT -- RETURN 1 

DECLARE @ot_actg_type CHAR(1),
		@ap_glnum CHAR(32),
		@glnum CHAR(32),
		@ot_pr_glnum CHAR(32),
		@ot_glnum CHAR(32),
		@ot_ap_glnum CHAR(32),
		@ot_pyt_minus INT,
		@ot_pyt_pretax CHAR(1),
		@ot_pyt_rateunit VARCHAR(6),
		@ot_pyt_unit VARCHAR(6),
		@ot_spyt_minus CHAR(1),
		@ot_pyt_fee2 MONEY,
		@ot_pyt_fee1 MONEY

DECLARE @tmwuser VARCHAR (255)

SELECT @ps_returnmsg = 'Precollect processed successfully for Resource:' + @ps_asgn_id

SELECT 	@li_tret = 0,
	@li_ret = 1

CREATE TABLE #temp_trip_pay
	(pyd_sequence INT NOT null,
	pyd_quantity FLOAT null,
	lgh_number INT null,
	pyd_number INT NOT null,
	enddate DATETIME null,
	pyt_itemcode VARCHAR(6) null)

CREATE TABLE #temp_non_trip_pay
	(pyd_sequence INT NOT null,
	pyd_quantity FLOAT null,
	lgh_number INT null,
	pyd_number INT NOT null,
	enddate DATETIME null,
	pyt_itemcode VARCHAR(6) null)

/*	@OvertimePayType = 	Pay type to use for overtime pay  */

DECLARE @payDetailIdsForReturn TABLE (PayDetailId INT NOT NULL)

SELECT 	@OvertimePayType = ISNULL(gi_string1, 'OT')	
FROM 	generalinfo 
WHERE 	gi_name = 'OTPayCode'

IF 	@ps_asgn_type <> 'DRV' 
BEGIN
	RAISERROR('Only resource type of driver can have the OT computation', 16, 1)
	RETURN -1
END

/*	Determine the last date on which this driver was paid. This will be used later when
	checking to make sure that pay requirments are met. 
	IF this is the first pay period ever, start counting FROM a week before. */
SELECT  @ldt_lastpayperiod = ISNULL(MAX(pyh_payperiod), DATEADD(dd, -14, @pdt_payperiod))
FROM 	payheader a
WHERE 	a.asgn_type = @ps_asgn_type 
AND 	a.asgn_id = @ps_asgn_id 
AND 	pyh_payperiod < @pdt_payperiod

SELECT @last_week = DATEADD(dd, -7, @pdt_payperiod)

IF @ldt_lastpayperiod <> @last_week
	SELECT @ldt_lastpayperiod = @last_week

/*	Get the weekly time limit */
SELECT 	@ldec_period_max = ISNULL(mpp_periodguarenteedhours, 40.0),
		@ls_payto = mpp_payto
FROM 	manpowerprofile 
WHERE 	mpp_id = @ps_asgn_id

/*	IF asset record didn't have weekly OT limits, generate an error message. */
IF @ldec_period_max is null 
	BEGIN
		RAISERROR ('Could NOT determine weekly time limits for this resource.', 16, 1)
		RETURN -1
	END

IF @ldt_lastpayperiod < @pdt_payperiod AND @ldec_period_max is NOT null AND @ldec_period_max > 0
BEGIN	
	/*	Get values FROM @OvertimePayType 	*/
	SELECT  @ot_pyt_rateunit = ISNULL(pyt_rateunit,''),
			@ot_pyt_unit = ISNULL(pyt_unit,''),
			@ot_pyt_pretax = ISNULL(pyt_pretax,''),
			@ot_pr_glnum = ISNULL(pyt_pr_glnum,''),
			@ot_ap_glnum = ISNULL(pyt_ap_glnum,''),
			@ot_spyt_minus = ISNULL(pyt_minus,''),
			@ot_pyt_fee1 = ISNULL(pyt_fee1, 0),
			@ot_pyt_fee2 = ISNULL(pyt_fee2, 0)
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
	AND store it IN the variable @ldec_period_new. 
	NOTE: this section of the code assumes a 1 week pay period  */

		INSERT #temp_trip_pay
		SELECT pyd_sequence,
				pyd_quantity,
				a.lgh_number,
				pyd_number,
				b.lgh_enddate,
				a.pyt_itemcode
		FROM paydetail a, legheader b, paytype c
		WHERE 	a.lgh_number = b.lgh_number 
				AND	a.asgn_type = @ps_asgn_type 
				AND a.asgn_id = @ps_asgn_id 
				AND	a.pyt_itemcode = c.pyt_itemcode 
				AND c.pyt_basisunit = 'TIM'	
				AND	ISNULL(c.pyt_otflag, 'N') = 'Y'
				AND	a.pyt_itemcode NOT IN (@OvertimePayType)
				AND a.pyh_payperiod = @pdt_payperiod

		INSERT #temp_non_trip_pay
		SELECT ISNULL(pyd_sequence, 0),
				pyd_quantity,
				ISNULL(a.lgh_number, 0),
				pyd_number,
				pyd_transdate,
				a.pyt_itemcode
		FROM paydetail a, paytype c
		WHERE 	a.asgn_type = @ps_asgn_type 
				AND a.asgn_id = @ps_asgn_id 
				AND	a.pyt_itemcode = c.pyt_itemcode 
				AND c.pyt_basisunit = 'TIM'	
				AND	ISNULL(c.pyt_otflag, 'N') = 'Y'
				AND	a.pyt_itemcode NOT IN (@OvertimePayType)
				AND a.pyh_payperiod = @pdt_payperiod
				AND pyd_number NOT IN (SELECT pyd_number FROM #temp_trip_pay)

		SELECT 	@ldec_period_lgh = ISNULL(SUM(pyd_quantity), 0) FROM #temp_trip_pay

		SELECT 	@ldec_period_trans = ISNULL(SUM(pyd_quantity), 0) FROM #temp_non_trip_pay

		SELECT @ldec_period_new = @ldec_period_lgh + @ldec_period_trans

		INSERT #temp_trip_pay SELECT * FROM #temp_non_trip_pay

		IF @ldec_period_new > @ldec_period_max
		BEGIN
			SELECT @ldec_period_qty = @ldec_period_new - @ldec_period_max

			SELECT	@period_pyd_sequence = (pyd_sequence + 1),
					@pyd_number_update = pyd_number
			FROM 	#temp_trip_pay 
			WHERE	enddate = (SELECT MAX(enddate) FROM #temp_trip_pay)
--		END	

		-- Get the next pyd_number FROM the systemnumber TABLE
		EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM',''

		EXEC gettmwuser @tmwuser OUTPUT

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
					lgh_startpoINT,
					lgh_startcity,	--25
					lgh_endpoINT,
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
					tar_tarrIFfnumber,
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
				'Pay Period OT Pay for week ' + CONVERT(VARCHAR, ISNULL(@ii,'')),
				@ldec_period_qty,
				@ot_pyt_rateunit,
				@ot_pyt_unit,		--15
				0,
				0,	--pyd_amount
				@ot_pyt_pretax,
				@ot_glnum,
				a.pyd_currency,	--20
				a.pyd_status,
				a.pyh_payperiod,
				a.pyd_workperiod,
				'UNKNOWN',	--	lgh_startpoINT,
				0,	--	lgh_startcity,	--25
				'UNKNOWN',	--	lgh_endpoINT,
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
				0, --pyd_grossamount	
				'N', --pyd_adj_flag
				@tmwuser, --pyd_updatedby
				GETDATE(), --pyd_updatedon
				0, --pyd_ivh_hdrnumber		--45	
				0,
				a.psd_id,
				a.pyd_releasedby,
				a.pyd_updsrc
		FROM 	paydetail a
		WHERE	pyd_number = @pyd_number_update

			IF (SELECT COUNT(*) FROM @payDetailIdsForReturn WHERE PayDetailId IN (@pyd_number)) = 0
			BEGIN
				INSERT INTO @payDetailIdsForReturn (PayDetailId) SELECT (@pyd_number)
			END
		END

		DELETE #temp_trip_pay
		DELETE #temp_non_trip_pay
END
DROP TABLE #temp_trip_pay
DROP TABLE #temp_non_trip_pay
SELECT PayDetailId FROM @payDetailIdsForReturn
GO
GRANT EXECUTE ON  [dbo].[Settlement_PreCollect_Process_Overtime_OneWeekPeriod_LIR] TO [public]
GO
