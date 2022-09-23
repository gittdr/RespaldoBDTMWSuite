SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_settlement_sheet_summary68](
	@report_type varchar(5),
	@payperiodstart datetime,
	@payperiodend datetime,
	@drv_yes varchar(3),
	@trc_yes varchar(3),
	@trl_yes varchar(3),
	@drv_id varchar(8),
	@trc_id varchar(8),
	@trl_id varchar(13),
	@drv_type1 varchar(6),
	@trc_type1 varchar(6),
	@trl_type1 varchar(6),
	@terminal varchar(8),
	@name varchar(64),
	@car_yes varchar(3),
	@car_id varchar(8),
	@car_type1 varchar(6),
	@hld_yes varchar(3),	
	@pyhnumber int,
	@tpr_yes varchar(3),
	@tpr_id	varchar(8),
	@relcol varchar(3),
	@relncol varchar(3),
	@workperiodstart datetime,
	@workperiodend datetime)
AS
/**
 * 
 * NAME:
 * dbo.d_settlement_sheet_summary68
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Procedure for settlement sheet 68
 *
 * RETURNS:
 * (NONE)
 * 
 * RESULT SETS: 
 * pyd_number, 
 * pyh_number,  
 * asgn_number, 
 * tp.asgn_type, 
 * tp.asgn_id, 
 * ivd_number, 
 * pyd_prorap, 
 * pyd_payto,
 * pyt_itemcode,
 * pyd_description,
 * pyr_ratecode, 
 * pyd_quantity, 
 * pyd_rev_loaded,
 * pyd_rev_unloaded,
 * pyd_rateunit, 
 * pyd_unit, 
 * pyd_pretax, 
 * pyd_status, 
 * tp.pyh_payperiod, 
 * lgh_startcity,
 * lgh_endcity, 
 * pyd_minus,
 * pyd_workperiod,
 * pyd_sequence,
 * pyd_rate,
 * pyd_amount,
 * pyd_payrevenue,
 * tp.mov_number,
 * lgh_number,
 * tp.ord_hdrnumber,
 * pyd_transdate,
 * payperiodstart,
 * payperiodend,
 * pyd_loadstate,
 * summary_code,
 * name,
 * terminal,
 * type1,
 * tp.pyh_totalcomp,
 * tp.pyh_totaldeduct,
 * tp.pyh_totalreimbrs,
 * ph.crd_cardnumber,
 * lgh_startdate,
 * std_balance,
 * itemsection,
 * tp.ord_startdate,
 * tp.ord_number,
 * ref_number,
 * stp_arrivaldate,
 * shipper_name,
 * shipper_city,
 * shipper_state,
 * consignee_name,
 * consignee_city,
 * consignee_state,
 * cmd_name,
 * pyd_billedweight,
 * adjusted_billed_rate,
 * pyd_payrevenue,
 * cht_basisunit,
 * pyt_description,
 * userlabelname,
 * label_name,
 * otherid,
 * pyt_fee1,
 * pyt_fee2,
 * start_city,
 * start_state,
 * end_city,
 * end_state, 
 * ph.pyh_paystatus,
 * ref_number_tds,
 * pyd_offsetpay_number,
 * pyd_credit_pay_flag,
 * pyd_refnumtype,
 * pyd_refnum,
 * ord.ord_tractor ,
 * pyt_basis 
 *
 * PARAMETERS:
 * 001 -	@report_type varchar(5),
 * 002 -	@payperiodstart datetime,
 * 003 -	@payperiodend datetime,
 * 004 -	@drv_yes varchar(3),
 * 005 -	@trc_yes varchar(3),
 * 006 -	@trl_yes varchar(3),
 * 007 -	@drv_id varchar(8),
 * 008 -	@trc_id varchar(8),
 * 009 -	@trl_id varchar(13),
 * 010 -	@drv_type1 varchar(6),
 * 011 -	@trc_type1 varchar(6),
 * 012 -	@trl_type1 varchar(6),
 * 013 -	@terminal varchar(8),
 * 014 -	@name varchar(64),
 * 015 -	@car_yes varchar(3),
 * 016 -	@car_id varchar(8),
 * 017 -	@car_type1 varchar(6),
 * 018 -	@hld_yes varchar(3),	
 * 019 -	@pyhnumber int,
 * 020 -    @tpr_yes varchar(3),
 * 021 -    @tpr_id varchar (8),
 * 022 -	@relcol varchar(3),
 * 023 -	@relncol varchar(3),
 * 024 -	@workperiodstart datetime,
 * 025 -	@workperiodend datetime)
 *
 * REVISION HISTORY:
 * 08/16/2006.01 PRB - PTS 33664 - Created this proc based off settlement 03.  This is for KAG and will handle
 *                                 their negative pay situation.  This will also call an external proc to get
 *                                 information into the temp table for the Open Items section.  The proc at KAG
 *                                 will accept an AltID of the payto and return us Invoice#, Date, and amount.
 *                                 We'll get Server and DB name from GI setting SettleSheet68OpenItemDB.
 * 08/16/2006.02 PRB - Below is the old mod log:
 * DPETE PTS 16764 Fix YTD totals
 * vjh 01/10/2008 PTS40937 issue date not being used for deduction YTD calcs
 * vjh 02/29/2008 PTS41605 Issue with deduction YTD amounts doubling when multiple deductions made
 * vjh 03/03/2008 PTS41589 Issue with Reference number
 * vjh 03/31/2009 PTS46717 remove the logic that ties the inverse deletion to the ivh_hdrnumber, and round amounts for comparison to pennies.
 *
 **/

set ansi_nulls OFF
set ansi_warnings OFF

Declare @PeriodforYTD	Varchar(3)
Declare @v_hidedetails	VARCHAR(60),
		@v_pbaprefix	VARCHAR(60)
Declare @pyh_issuedate	datetime

--vjh 1/10/2008 PTS40937 get issue date
if @pyhnumber > 0
	SELECT	@pyh_issuedate = pyh_issuedate
	FROM	payheader
	WHERE	pyh_pyhnumber = @pyhnumber
if @pyh_issuedate is null select @pyh_issuedate = @payperiodend
 
--PRB Added this to check cancel paydetails logic
SELECT @v_pbaprefix = Left(isnull(gi_string2,'') ,60) 
FROM generalinfo
WHERE gi_name = 'Settle68HideInverseDetails'
Select @v_pbaprefix = IsNull(@v_pbaprefix,'')

SELECT @v_hidedetails = Left(isnull(gi_string1,'Y') ,1) 
FROM generalinfo
WHERE gi_name = 'Settle68HideInverseDetails'
Select @v_hidedetails = IsNull(@v_hidedetails,'N')

SELECT @PeriodforYTD = Left(isnull(gi_string1,'N') ,1) 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'
Select @PeriodforYTD = IsNull(@PeriodforYTD,'N')


-- Create a temp table to the pay header and detail numbers
CREATE TABLE #temp_pay (
	pyd_number int not null,
	pyh_number int not null,
	pyd_status varchar(6) null,
	asgn_type1 varchar(6) null)


--vmj1+	01/14/2002	PTS12963	Don't get caught by PayDetails with PayPeriods or WorkPeriods that are 59 seconds after the
--								Apocalypse!!!
if @payperiodend >= '2049-12-31 23:59:00.000'
	select @payperiodend = '2049-12-31 23:59:59.999'
if @workperiodend >= '2049-12-31 23:59:00.000'
	select @workperiodend = '2049-12-31 23:59:59.999'
--vmj1-


-- LOR PTS# 6404 eliminate trial and final settlement sheets - do just one
IF @hld_yes = 'Y' 
--IF @report_type = 'TRIAL'
BEGIN
	-- Get the driver pay header and detail numbers for held pay
	IF @drv_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			-- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
               		-- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@drv_type1
		FROM paydetail
		WHERE asgn_type = 'DRV'
			AND asgn_id = @drv_id
			AND pyh_number = 0 
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- Get the tractor pay header and detail numbers for held pay
	IF @trc_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
                        -- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
                        -- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@trc_type1
		FROM paydetail
		WHERE asgn_type = 'TRC'
	  		AND asgn_id = @trc_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- Get the carrier pay header and detail numbers for held pay
	IF @car_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
                        -- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
                        -- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@car_type1
		FROM paydetail
		WHERE asgn_type = 'CAR'
	  		AND asgn_id = @car_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- Get the trailer pay header and detail numbers for held pay
	IF @trl_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
                        -- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
                        -- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@trl_type1
		FROM paydetail
		WHERE asgn_type = 'TRL'
	  		AND asgn_id = @trl_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- Get the thirdparty pay header and detail numbers for held pay
	IF @tpr_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			''
		FROM paydetail
		WHERE asgn_type = 'TPR'
	  		AND asgn_id = @tpr_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend
END

IF @relcol  = 'N' and @relncol = 'Y' 
BEGIN
	IF @drv_yes <> 'XXX'
		-- Get the driver pay header and detail numbers for pay released 
		-- to this payperiod, but not collected
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@drv_type1
		FROM paydetail
		WHERE asgn_type = 'DRV'
	  	AND asgn_id = @drv_id
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		AND pyh_number = 0

	-- Get the tractor pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @trc_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@trc_type1
		FROM paydetail
		WHERE asgn_type = 'TRC'
	  	AND asgn_id = @trc_id
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		AND pyh_number = 0

	-- Get the carrier pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @car_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@car_type1
		FROM paydetail
		WHERE asgn_type = 'CAR'
	  	AND asgn_id = @car_id
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		AND pyh_number = 0

	-- LOR  PTS# 5744 add trailer settlements
	-- Get the trailer pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @trl_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@trl_type1
		FROM paydetail
		WHERE asgn_type = 'TRL'
	  		AND asgn_id = @trl_id
	  		AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pyh_number = 0

	-- Get the thirdparty pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @tpr_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			''
		FROM paydetail
		WHERE asgn_type = 'TPR'
			AND @tpr_id = asgn_id
	  		AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pyh_number = 0
END

IF @relcol  = 'Y' and @relncol = 'N'
BEGIN
--IF @report_type = 'FINAL'
	-- Get the driver pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @drv_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@drv_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'DRV'
	  		AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
	  		AND pd.pyh_number = ph.pyh_pyhnumber
	  		AND @drv_id = ph.asgn_id
			-- LOR	select paydetails for the given payheader only
			AND pyh_number = @pyhnumber
			-- LOR

	-- Get the tractor pay header and detail numbers pay released to this payperiod
	-- and collected 
	IF @trc_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@trc_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'TRC'
			AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @trc_id = ph.asgn_id
			-- LOR	select paydetails for the given payheader only
			AND pyh_number = @pyhnumber
			-- LOR

	-- Get the carrier pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @car_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@car_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'CAR'
			AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @car_id = ph.asgn_id
			-- LOR	select paydetails for the given payheader only
			AND pyh_number = @pyhnumber
			-- LOR

	-- Get the trailer pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @trl_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@trl_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'TRL'
		AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		AND pd.pyh_number = ph.pyh_pyhnumber
		AND @trl_id = ph.asgn_id
		-- LOR	select paydetails for the given payheader only
		AND pyh_number = @pyhnumber
		-- LOR

	-- Get the thirdparty pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @tpr_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			''
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'TPR'
			AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @tpr_id = ph.asgn_id
		-- LOR	select paydetails for the given payheader only
		AND pyh_number = @pyhnumber
		-- LOR
END

-- Create a temp table to hold the pay header and detail numbers
-- Create a temp table to hold the pay details
CREATE TABLE #temp_pd(
	pyd_number		int not null,
	pyh_number		int not null,
	asgn_number		int null,
	asgn_type		varchar(6) not null,
	asgn_id			varchar(13) not null,
	ivd_number		int null,
	pyd_prorap		varchar(6) null, 
	pyd_payto		varchar(8) null, 
	pyt_itemcode		varchar(6) null, 
	pyd_description		varchar(75) null, 
	pyr_ratecode		varchar(6) null, 
	pyd_quantity		float null,		--extension (BTC)
	pyd_rateunit		varchar(6) null,
	pyd_unit		varchar(6) null,
	pyd_pretax		char(1) null,
	pyd_status		varchar(6) null,
	pyh_payperiod		datetime null,
	lgh_startcity		int null,
	lgh_endcity		int null,
	pyd_minus		int null,
	pyd_workperiod		datetime null,
	pyd_sequence		int null,
	pyd_rate		money null,		--rate (BTC)
	pyd_amount		money null,
	pyd_payrevenue		money null,		
	mov_number		int null,
	lgh_number		int null,
	ord_hdrnumber		int null,
	pyd_transdate		datetime null,
	payperiodstart		datetime null,
	payperiodend		datetime null,
	pyd_loadstate		varchar(6) null,
	summary_code		varchar(6) null,
	name			varchar(100) null,
	terminal		varchar(6) null,
	type1			varchar(6) null,
	pyh_totalcomp		money null,
	pyh_totaldeduct		money null,
	pyh_totalreimbrs	money null,
	crd_cardnumber		char(20) null, /*pts 21137 cgk 7/19/2004, changed to 20 characters*/
	lgh_startdate		datetime null,
	std_balance		money null,
	itemsection		int null,
	ord_startdate		datetime null,
	ord_number		char(9) null,
	ref_number		varchar(30) null,
	stp_arrivaldate		datetime null,
	shipper_name		varchar(30) null,
	shipper_city		varchar(18) null,
	shipper_state		char(2) null,
	consignee_name		varchar(30) null,
	consignee_city		varchar(18) null,
	consignee_state		char(2) null,
	cmd_name		varchar(60) null,
	pyd_billedweight	int null,		--billed weight (BTC)
	adjusted_billed_rate	money null,		--rate (BTC)
	cht_basis		varchar(6) null,
	cht_basisunit		varchar(6) null,
	cht_unit		varchar(6) null,
	cht_rateunit		varchar(6) null,
	std_number		int null,
	stp_number		int null,
	unc_factor		float null,
	stp_mfh_sequence	int null,
	pyt_description		varchar(30) null,
	cht_itemcode		varchar(6) null,
	userlabelname		varchar(20) null,
	label_name		varchar(20) null,
	otherid			varchar(9) null, --PRB PTS33664 Changed from 8 to 9.
	trc_drv			varchar(8) null,
	start_city		varchar(18) null,
	start_state		char(2) null,
	end_city		varchar(18) null,
	end_state		char(2) null,
	lgh_count		int null,
	pyh_issuedate datetime null,
--After this point are additions for PTS33664
	pro_number      varchar(30) null,  --First instance of PRO# on the orderheader
    bol_number      varchar(30) null,  --First instance of BL# on the orderheader
    barcode         varchar(30) null,  --First instance of BCD#
    billdate        datetime null,     --Bill Date
    ord_tractor     varchar(8) null,  --ord_tractor
    trailer         varchar(8) null,  --ord_trailer
    shipper_id      varchar(8) null,   --ord_shipper
	consignee_id    varchar(8) null,   --ord_consignee
    order_miles     int null,          --ord_totalmiles
    order_gallons   int null,          --ord_totalvolume
	ivh_invoicenumber varchar(12) null,--invoice header invoice number.
	std_priorbalance money null,        --std_priorbalance on standingdeduction table.
	std_description  varchar(30) null,  --std_description on standingdeduction table.
	sdm_itemcode varchar(6) null,       --sdm_itemcode to determine type of deduction
	payments money null,                --total payments for escrow account
	withdrawals money null,             --total withdrawals for escrow account.
    mpp_type4 varchar(6),
	ytd_deduction money null,            --accrual of non-escrow standing deductions for the year.
    ytd_reoccur INT NULL,                      --tells datawindow to not repeat.
	pyd_ivh_hdrnumber INT Null,          -- get invoiceheader number for comparison.
	pba VARCHAR(30) NULL,                -- Need to get PBA ref number off of rebill
    pos1 INT NULL,                       -- was using to supress repeating values.
    mpp_type2 Varchar(6) Null            -- from driver profile
	
--End PTS33664
)

-- Insert into the temp pay details table with the paydetail data per #temp_pay
INSERT INTO #temp_pd
SELECT pd.pyd_number,
	pd.pyh_number,
	pd.asgn_number,
	pd.asgn_type,
	pd.asgn_id,
	pd.ivd_number,
	pd.pyd_prorap,
	pd.pyd_payto,
	pd.pyt_itemcode,
	ISNULL(pd.pyd_description, ''),
	pd.pyr_ratecode,
	pd.pyd_quantity,
	pd.pyd_rateunit, 
	pd.pyd_unit,
	pd.pyd_pretax,
	tp.pyd_status,
	pd.pyh_payperiod,
	pd.lgh_startcity,
	pd.lgh_endcity,
	pd.pyd_minus,
	pd.pyd_workperiod,
	pd.pyd_sequence,
	pd.pyd_rate,
	ROUND(pd.pyd_amount, 2),
	pd.pyd_payrevenue,
	'',
	'',
	pd.ord_hdrnumber,
	pd.pyd_transdate,
	@payperiodstart,
	@payperiodend,
	pd.pyd_loadstate,
	pd.pyd_unit,
	@name,
	@terminal,
	tp.asgn_type1,
	0.0,
	0.0,
	0.0,
	null,
	null,
	null,
	0,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	pd.pyd_billedweight,
	0.0,
	null,
	null,
	null,
	null,
	pd.std_number,
	null,
	1.0,
	null,
	null,
	pd.cht_itemcode,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	0,
	null,
	pro_number = (SELECT MIN(ref_number)
				   FROM referencenumber
				   WHERE ref_table = 'orderheader'
				   AND ref_type = 'DIS#'
				   AND ref_tablekey = pd.ord_hdrnumber),
    bol_number = (SELECT MIN(ref_number)
				   FROM referencenumber
				   WHERE ref_table = 'orderheader'
				   AND ref_type = 'BL#'
				   AND ref_tablekey = pd.ord_hdrnumber),
    barcode =    (SELECT MIN(ref_number)
				   FROM referencenumber
				   WHERE ref_table = 'orderheader'
				   AND ref_type = 'BCD#'
				   AND ref_tablekey = pd.ord_hdrnumber),
    billdate =   (SELECT MIN(ivh_billdate)
				   FROM invoiceheader
				   WHERE invoiceheader.ord_hdrnumber = pd.ord_hdrnumber),
    ord_tractor = (SELECT MIN(ord_tractor)
				   FROM orderheader
				   WHERE orderheader.ord_hdrnumber = pd.ord_hdrnumber),
    trailer = (SELECT MIN(ord_trailer)
				   FROM orderheader
				   WHERE orderheader.ord_hdrnumber = pd.ord_hdrnumber),
    '',   --ord_shipper
	--'',   --ord_consignee
	consignee_id = (select IsNull(ivh_furthestpointconsignee, '') 
					from invoiceheader 
					where ivh_invoicenumber = (SELECT MIN(ivh_invoicenumber)
											 FROM invoiceheader
											 WHERE ord_hdrnumber = pd.ord_hdrnumber)),   --		LOR	PTS# 47552
    order_miles = (SELECT MIN(ord_paymiles)
				   FROM orderheader
				   WHERE orderheader.ord_hdrnumber = pd.ord_hdrnumber),
    order_gallons = (SELECT MIN(ord_totalvolume)
				   FROM orderheader
				   WHERE orderheader.ord_hdrnumber = pd.ord_hdrnumber),
	ivh_invoicenumber = (SELECT MIN(ivh_invoicenumber)
						 FROM invoiceheader
						 WHERE ord_hdrnumber = pd.ord_hdrnumber),
    0.0,
	'',
	'',
	payments = (SELECT SUM(ISNULL(pyd_rate, 0.00))
				FROM paydetail
				INNER JOIN #temp_pay ON paydetail.pyd_number = #temp_pay.pyd_number
				WHERE pyd_amount > 0
				AND std_number = pd.std_number),
	withdrawals = (SELECT SUM(ISNULL(pyd_rate, 0.00))
					FROM paydetail
					INNER JOIN #temp_pay ON paydetail.pyd_number = #temp_pay.pyd_number
					WHERE pyd_amount < 0
					AND std_number = pd.std_number),
    mpp_type4 = (SELECT 'mpp' = CASE 
									WHEN @drv_yes = 'XXX' Then ''
									ELSE (SELECT mpp_type4 
										 FROM manpowerprofile
										 WHERE mpp_id = @drv_id)
								END),
   0.0,
   0,
   pd.pyd_ivh_hdrnumber,
  /* original pba code.
   pba = (CASE ISNULL(ref.ref_type, '')
				WHEN 'PBA' THEN CASE ISNULL(invoiceheader.ivh_definition, '') 
								  WHEN 'RBIL' THEN 'REBILL ' + ref.ref_number
								  WHEN 'CRD' THEN 'CRMEMO '
								  ELSE ''
								END
				WHEN '' THEN CASE ISNULL(hd.ivh_definition, '') 
								  WHEN 'RBIL' THEN 'REBILL'
								  WHEN 'CRD' THEN 'CRMEMO'
								  ELSE ''
								END
				ELSE ''
	     END),
   */
   pba = (CASE ISNULL(ref.ref_type, '')
				WHEN 'PBA' THEN ref.ref_number
				ELSE ''
	     END),
   0,
   mpp_type2 = (SELECT 'mpp' = CASE 
									WHEN @drv_yes = 'XXX' Then ''
									ELSE (SELECT mpp_type2 
										  FROM manpowerprofile
										  WHERE mpp_id = @drv_id)
								END)
FROM paydetail pd
INNER JOIN #temp_pay tp
ON pd.pyd_number = tp.pyd_number
LEFT OUTER JOIN invoiceheader
ON pd.pyd_ivh_hdrnumber = invoiceheader.ivh_hdrnumber
LEFT OUTER JOIN referencenumber ref
ON pd.ord_hdrnumber = ref.ord_hdrnumber
and ref.ord_hdrnumber <> 0		-- vjh 41589
AND ref.ref_type = 'PBA'
AND ref.ref_sequence = (SELECT MIN(ref_sequence)
						FROM referencenumber r
						WHERE r.ord_hdrnumber = pd.ord_hdrnumber
						AND r.ref_type = 'PBA')
--LEFT OUTER JOIN invoiceheader hd
--ON pd.pyd_ivh_hdrnumber = hd.ivh_cmrbill_link

--Kag has supplied a table that will be local for us to call.  Here is the tables structure.
/*
[OPEN_PAYABLES](
	[INVOICE_ID] [decimal](15, 0) NOT NULL,
	[VENDOR_ID] [decimal](15, 0) NOT NULL,
	[INVOICE_NUM] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[INVOICE_AMOUNT] [float] NOT NULL,
	[VENDOR_SITE_ID] [decimal](15, 0) NOT NULL,
	[AMOUNT_PAID] [float] NULL,
	[INVOICE_DATE] [datetime] NULL,
	[TMW_ALT_ID] [varchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) */

--We'll insert values from here into our temp table for display on negative settlement sheet.  We will need the drivers
--alt id to do it.
IF @drv_yes <> 'XXX' or @car_yes <> 'XXX'
BEGIN
	CREATE TABLE #temp_openitems
	( 
	  temp_id INT identity NOT NULL,
	  invoice_number VARCHAR(50) NULL,
	  invoice_date DATETIME NULL,
	  invoice_total FLOAT NULL
	)

	INSERT INTO #temp_openitems(invoice_number, invoice_date, invoice_total)
	 SELECT p.INVOICE_NUM, p.INVOICE_DATE, (ISNULL(p.INVOICE_AMOUNT, 0) + ISNULL(AMOUNT_PAID, 0)) AS InvoiceTotal 
	 FROM OPEN_PAYABLES p
	 WHERE p.TMW_ALT_ID IN (SELECT pto_altid
							FROM payto
							--vjh 37042 use the payto from the paydetail
							--RIGHT OUTER JOIN #temp_pd ON payto.pto_id = #temp_pd.asgn_id)
							RIGHT OUTER JOIN #temp_pd ON payto.pto_id = #temp_pd.pyd_payto)
							/* OLD CODE (01/31/06)
							(SELECT mpp_otherid
						   FROM manpowerprofile mp
						   JOIN #temp_pd ON mp.mpp_id = #temp_pd.asgn_id)
							*/
   DELETE FROM #temp_openitems
   WHERE invoice_total = 0
END


--Update the temp pay details with legheader data
UPDATE #temp_pd
SET mov_number = lh.mov_number,
	lgh_number = lh.lgh_number,
	lgh_startdate = lh.lgh_startdate
FROM 	legheader lh
WHERE #temp_pd.lgh_number = lh.lgh_number

-- Update the temp with number of legheaders for the move
-- actually, just find if there was another legheader on the move
UPDATE 	#temp_pd
SET lgh_count = legheader.lgh_number
FROM legheader
WHERE legheader.mov_number = #temp_pd.mov_number 
  AND legheader.lgh_number <> #temp_pd.lgh_number

--Update the temp pay details with orderheader data
UPDATE #temp_pd
SET ord_startdate = oh.ord_startdate,
	ord_number = oh.ord_number
FROM  orderheader oh
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber

--Update the temp, for split trips, set ord_number = ord_number + '/S'
UPDATE 	#temp_pd
SET	ord_number = ord_number + '/S'
WHERE 	ord_hdrnumber > 0 
  AND	lgh_count > 0

--Update the temp pay details with shipper data
UPDATE #temp_pd
SET shipper_name = co.cmp_name,
	shipper_city = ct.cty_name,
	shipper_state = ct.cty_state,
	shipper_id = oh.ord_shipper
FROM  company co, city ct, orderheader oh
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_shipper = co.cmp_id
  AND co.cmp_city = ct.cty_code
  AND oh.ord_shipper <> 'UNKNOWN'	

UPDATE #temp_pd
SET 	shipper_name = 'UNKNOWN',
	shipper_city = ct.cty_name,
	shipper_state = ct.cty_state,
    shipper_id = oh.ord_shipper
FROM    orderheader oh, city ct
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_origincity  = ct.cty_code
  AND oh.ord_shipper = 'UNKNOWN'	

--Update the temp pay details with consignee data
/*	LOR	PTS# 47552	changed consignee 
UPDATE #temp_pd
SET consignee_name = co.cmp_name,
	consignee_city = ct.cty_name,
	consignee_state = ct.cty_state,
	consignee_id = oh.ord_consignee 
FROM  company co, city ct, orderheader oh
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_consignee = co.cmp_id
  AND co.cmp_city = ct.cty_code 
  AND oh.ord_consignee <> 'UNKNOWN'

UPDATE #temp_pd
SET 	consignee_name 	= 'UNKNOWN',
	consignee_city 	= ct.cty_name,
	consignee_state 	= ct.cty_state,
    consignee_id = oh.ord_consignee 
FROM    orderheader oh, city ct
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_destcity  = ct.cty_code
  AND oh.ord_consignee = 'UNKNOWN'	
*/

UPDATE #temp_pd
SET consignee_name = co.cmp_name,
	consignee_city = ct.cty_name,
	consignee_state = ct.cty_state,
	consignee_id = (case #temp_pd.consignee_id when '' then oh.ord_consignee else #temp_pd.consignee_id end)
FROM  company co, city ct, orderheader oh
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND co.cmp_id = (case #temp_pd.consignee_id when '' then oh.ord_consignee else #temp_pd.consignee_id end)
  AND co.cmp_city = ct.cty_code 

/* 01/31/06 - Moved down
--Update the temp pay details with standingdeduction data
UPDATE #temp_pd
SET std_balance = sd.std_balance,
    std_priorbalance = sd.std_priorbalance,
	std_description = sd.std_description,
	std_number = sd.std_number,
	sdm_itemcode = sd.sdm_itemcode
FROM  standingdeduction sd
WHERE #temp_pd.std_number = sd.std_number
*/


--Update the temp pay details for summary code
UPDATE #temp_pd
SET summary_code = 'OTHER'
WHERE summary_code <> 'MIL'

--Update the temp pay details for load status
UPDATE #temp_pd
SET pyd_loadstate = 'NA'
WHERE pyd_loadstate IS null

--Update the temp pay details with payheader data
UPDATE #temp_pd
SET crd_cardnumber = ph.crd_cardnumber,
pyh_issuedate = IsNull(ph.pyh_issuedate,ph.pyh_payperiod)
FROM  payheader ph
WHERE #temp_pd.pyh_number = ph.pyh_pyhnumber

--Update the temp pay details with paytype data
UPDATE #temp_pd
SET pyt_description = ISNULL(pt.pyt_description, '')
FROM  paytype pt
WHERE #temp_pd.pyt_itemcode = pt.pyt_itemcode

--Need to get the stop of the 1st delivery and find the commodity and arrival date
--associated with it.
--Update the temp pay details table with stop data for the 1st unload stop
UPDATE #temp_pd
SET stp_mfh_sequence = (SELECT MIN(st.stp_mfh_sequence)
	FROM stops st

	WHERE st.ord_hdrnumber = #temp_pd.ord_hdrnumber
	  AND st.stp_event in ('DLUL', 'LUL', 'DUL', 'PUL')) 


UPDATE #temp_pd
SET stp_number = st.stp_number
FROM stops st
WHERE st.ord_hdrnumber = #temp_pd.ord_hdrnumber
  AND st.stp_mfh_sequence = #temp_pd.stp_mfh_sequence

--Update the temp pay details with commodity data
UPDATE #temp_pd
SET cmd_name = cd.cmd_name,
	stp_arrivaldate = st.stp_arrivaldate
FROM   freightdetail fd, commodity cd, stops st
WHERE st.stp_number = #temp_pd.stp_number
 AND fd.stp_number = st.stp_number
 AND cd.cmd_code = fd.cmd_code

--Need to get the bill-of-lading from the reference number table
--Update the temp pay details with reference number data
UPDATE #temp_pd
SET ref_number = rn.ref_number
FROM  referencenumber rn
WHERE rn.ref_tablekey = #temp_pd.ord_hdrnumber
  AND rn.ref_table = 'orderheader'
  AND rn.ref_type = 'SID'

--Need to get revenue charge type data from the chargetype table
UPDATE #temp_pd
SET cht_basis =	ct.cht_basis,
	cht_basisunit = ct.cht_basisunit,
	cht_unit = ct.cht_unit,
	cht_rateunit = ct.cht_rateunit
FROM  chargetype ct
WHERE #temp_pd.cht_itemcode = ct.cht_itemcode

UPDATE #temp_pd
SET unc_factor = uc.unc_factor
FROM unitconversion uc
WHERE uc.unc_from = #temp_pd.cht_basisunit
  AND uc.unc_to = #temp_pd.cht_rateunit
  AND uc.unc_convflag = 'R'

UPDATE #temp_pd
SET adjusted_billed_rate = ROUND(pyd_payrevenue / pyd_billedweight / unc_factor, 2)
WHERE pyd_billedweight > 0
  AND unc_factor > 0
  AND pyd_payrevenue > 0

--Create a temp table for YTD balances
CREATE TABLE #YTDBAL (asgn_type	varchar (6) not null,
	asgn_id			varchar (13) not null,
	ytdcomp			money null,
	ytddeduct		money null,
	ytdreimbrs		money null,
	pyh_payperiod		datetime null,
	pyh_issuedate		datetime null)

--Insert into the temp YTD balances table the assets from the temp pay details table
-- JD pts 28499 06/29/05 commented the following insert out, this table needs to have just one row for the later update on the #temp_pd table to work consistently
-- we are running into issues when the ytdbal has 2 rows since we have details that are on the 12/31/49 payperiod.
--INSERT INTO #YTDBAL
--SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
--FROM #temp_pd

-- new insert for 28499
If @pyhnumber > 0
	INSERT INTO #YTDBAL
	SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
	FROM payheader 
	WHERE pyh_pyhnumber = @pyhnumber
else
	INSERT INTO #YTDBAL
	SELECT min(asgn_type), min(asgn_id), 0, 0, 0, @payperiodend, @payperiodend
	FROM #temp_pd 
-- end new insert for 28499 JD 06/29/05
	
--
--Compute the YTD balances for each assets
--LOR	fixed null problem SR 7095
--JYAng pts13004
/*
if left(ltrim(@PeriodforYTD),1) = 'Y' begin
UPDATE #YTDBAL
SET ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        AND ph.pyh_payperiod < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0),
   ytddeduct = ISNULL((SELECT SUM(ROUND(ph.pyh_totaldeduct, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        AND ph.pyh_payperiod < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0),
   ytdreimbrs = ISNULL((SELECT SUM(ROUND(ph.pyh_totalreimbrs, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        AND ph.pyh_payperiod < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0)
FROM #YTDBAL yb
END ELSE BEGIN
UPDATE #YTDBAL
SET ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0),
   ytddeduct = ISNULL((SELECT SUM(ROUND(ph.pyh_totaldeduct, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0),
   ytdreimbrs = ISNULL((SELECT SUM(ROUND(ph.pyh_totalreimbrs, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0)
FROM #YTDBAL yb
END
*/
IF left(ltrim(@PeriodforYTD),1) = 'Y' 
BEGIN
	UPDATE #ytdbal
   SET ytdcomp = (SELECT SUM(ROUND(ISNULL(ph.pyh_totalcomp, 0), 2))
                   FROM payheader ph
                  WHERE ph.asgn_id = #ytdbal.asgn_id
                        AND ph.asgn_type = #ytdbal.asgn_type
                       	AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        AND ph.pyh_payperiod < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 
     ytddeduct = (SELECT SUM(ROUND(ISNULL(ph.pyh_totaldeduct, 0), 2))
                   FROM payheader ph
                  WHERE ph.asgn_id = #ytdbal.asgn_id
                        AND ph.asgn_type = #ytdbal.asgn_type
                        AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        AND ph.pyh_payperiod < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 
    ytdreimbrs = (SELECT SUM(ROUND(ISNULL(ph.pyh_totalreimbrs, 0), 2))
                   FROM payheader ph
                  WHERE ph.asgn_id = #ytdbal.asgn_id
                        AND ph.asgn_type = #ytdbal.asgn_type
                        AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        AND ph.pyh_payperiod < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD') 
END 
ELSE 
BEGIN
	UPDATE #ytdbal
	SET	ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
			FROM payheader ph
	          	WHERE ph.asgn_id = yb.asgn_id
	                	AND ph.asgn_type = yb.asgn_type
	                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, isnull(yb.pyh_issuedate,yb.pyh_payperiod))
	                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) <= isnull(yb.pyh_issuedate,yb.pyh_payperiod)
	                	AND ph.pyh_paystatus <> 'HLD'), 0),
		ytddeduct = ISNULL((SELECT SUM(ROUND(ph.pyh_totaldeduct, 2))
	           	FROM payheader ph
	          	WHERE ph.asgn_id = yb.asgn_id
	               		AND ph.asgn_type = yb.asgn_type
	                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, isnull(yb.pyh_issuedate,yb.pyh_payperiod))
	                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) <= isnull(yb.pyh_issuedate,yb.pyh_payperiod)
	                	AND ph.pyh_paystatus <> 'HLD'), 0),
		ytdreimbrs = ISNULL((SELECT SUM(ROUND(ph.pyh_totalreimbrs, 2))
	           	FROM payheader ph
	          	WHERE ph.asgn_id = yb.asgn_id
	                	AND ph.asgn_type = yb.asgn_type
	                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, isnull(yb.pyh_issuedate,yb.pyh_payperiod))
	                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) <= isnull(yb.pyh_issuedate,yb.pyh_payperiod)
	                	AND ph.pyh_paystatus <> 'HLD'), 0)
   FROM  #ytdbal yb
END


UPDATE #YTDBAL
SET ytdcomp = ytdcomp + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2))
			FROM #temp_pd tp
			WHERE tp.asgn_id = yb.asgn_id
	 			AND tp.asgn_type = yb.asgn_type
	  			AND tp.pyd_pretax = 'Y'
	  			AND tp.pyd_status <> 'HLD'
				AND pyh_number = 0), 0)
FROM #YTDBAL yb

UPDATE #YTDBAL
SET ytddeduct = ytddeduct + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2)) 
				FROM #temp_pd tp
				WHERE tp.asgn_id = yb.asgn_id
	  				AND tp.asgn_type = yb.asgn_type
	  				AND tp.pyd_pretax = 'N'
	  				AND tp.pyd_minus = -1
	  				AND tp.pyd_status <> 'HLD'
				   	AND pyh_number = 0), 0)
FROM #YTDBAL yb

UPDATE #YTDBAL
SET ytdreimbrs = ytdreimbrs + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2))
				FROM #temp_pd tp
				WHERE tp.asgn_id = yb.asgn_id
	  				AND tp.asgn_type = yb.asgn_type
	  				AND tp.pyd_pretax = 'N'
	  				AND tp.pyd_minus = 1
	  				AND tp.pyd_status <> 'HLD'
				   	AND pyh_number = 0), 0)
FROM #YTDBAL yb

UPDATE #temp_pd
SET pyh_totalcomp = yb.ytdcomp,
	pyh_totaldeduct = yb.ytddeduct,
	pyh_totalreimbrs = yb.ytdreimbrs
FROM #YTDBAL yb
WHERE #temp_pd.asgn_type = yb.asgn_type
  	AND #temp_pd.asgn_id = yb.asgn_id

UPDATE #temp_pd
SET itemsection = 2
WHERE pyd_pretax = 'N'
  	AND pyd_minus = 1

UPDATE #temp_pd
SET itemsection = 3
WHERE pyd_pretax = 'N'
  	AND pyd_minus = -1

UPDATE #temp_pd
SET itemsection = 4
WHERE pyt_itemcode = 'MN+'	/*minimum credit */
   OR pyt_itemcode = 'MN-'	/*minimum debit */

--Update the temp pay details with labelfile data and drv alt id
UPDATE #temp_pd
SET 	#temp_pd.userlabelname = l.userlabelname,
	#temp_pd.label_name = l.name,
	#temp_pd.otherid = m.mpp_otherid
FROM  labelfile l, manpowerprofile m
WHERE 	m.mpp_id = #temp_pd.asgn_id and
	l.labeldefinition = 'DrvType1' and
	m.mpp_type1 = l.abbr 

--Update the temp pay details with start/end city/state data - LOR PTS# 4457
UPDATE #temp_pd
SET 	start_city = ct.cty_name,
	start_state = ct.cty_state
FROM   city ct
WHERE  ct.cty_code = #temp_pd.lgh_startcity

UPDATE #temp_pd
SET 	end_city = ct.cty_name,
	end_state = ct.cty_state
FROM    city ct
WHERE  ct.cty_code = #temp_pd.lgh_endcity

--remove paydetails that are 0.00 dollars
DELETE FROM #temp_pd
WHERE pyd_amount = 0 OR pyd_amount IS NULL
AND itemsection = 0

/*
UPDATE #temp_pd
SET itemsection = 6
FROM                 (SELECT 
						amount = CASE
									WHEN p.pyd_amount > 0 THEN p.pyd_amount
									WHEN p.pyd_amount < 0 THEN p.pyd_amount  * -1
									ELSE 0
								 END,
						quantity = CASE
								    WHEN p.pyd_quantity > 0 THEN p.pyd_quantity
								    WHEN p.pyd_quantity < 0 THEN p.pyd_quantity  * -1
								    ELSE 0
								   END, 
	   --pyd_adj_flag,
	   --pyd_description,
						p.ord_hdrnumber,
						p.pyd_adj_flag,
						COUNT(*) As RepeatCount
					FROM paydetail p
					WHERE p.ord_hdrnumber IN (SELECT #temp_pd.ord_hdrnumber FROM #temp_pd)
					GROUP BY p.ord_hdrnumber, p.pyd_amount, p.pyd_quantity, p.pyd_adj_flag
					HAVING count(*) > 1) As UResult
WHERE (#temp_pd.pyd_amount = UResult.amount OR (#temp_pd.pyd_amount * -1) = UResult.amount)
AND #temp_pd.ord_hdrnumber = UResult.ord_hdrnumber

*/

-- Need to include a loop here to change paydetails that are Pay Adjustments from prior periods - Criteria for this is:
-- pyd_quantity is inverse of another detail and pyd_amount is inverse.  Must share the same ord_hdrnumber
-- vjh 46717 remove the logic that ties the deletion to the ivh_hdrnumber, and round amounts for comparison to pennies.
IF @v_hidedetails = 'Y'
BEGIN

	DELETE #temp_pd FROM
						(SELECT 
							amount = CASE
													WHEN p.pyd_amount > 0 THEN round(p.pyd_amount,2)
													WHEN p.pyd_amount < 0 THEN round(p.pyd_amount  * -1,2)
													ELSE 0
												  END,
							quantity = CASE
													WHEN p.pyd_quantity > 0 THEN round(p.pyd_quantity,2)
													WHEN p.pyd_quantity < 0 THEN round(p.pyd_quantity  * -1,2)
													ELSE 0
												 END, 
							p.ord_hdrnumber,
							p.pyt_itemcode,
							p.pyh_number,
							--p.pyd_ivh_hdrnumber,	--vjh 46717
							COUNT(pyd_number) As RepeatCount
						FROM paydetail p
						WHERE p.ord_hdrnumber IN (SELECT #temp_pd.ord_hdrnumber FROM #temp_pd)
						--AND p.pyh_number = 0
						--GROUP BY p.ord_hdrnumber, p.pyd_amount, p.pyd_quantity, p.pyt_itemcode, p.pyh_number
						GROUP BY p.ord_hdrnumber, CASE
													WHEN p.pyd_amount > 0 THEN round(p.pyd_amount,2)
													WHEN p.pyd_amount < 0 THEN round(p.pyd_amount  * -1,2)
													ELSE 0
												  END,
												 CASE
													WHEN p.pyd_quantity > 0 THEN round(p.pyd_quantity,2)
													WHEN p.pyd_quantity < 0 THEN round(p.pyd_quantity  * -1,2)
													ELSE 0
												 END, 
								p.pyt_itemcode, p.pyh_number --, p.pyd_ivh_hdrnumber  --vjh 46717
						HAVING count(*) > 1) As UResult
	WHERE ((#temp_pd.pyd_amount = UResult.amount OR (#temp_pd.pyd_amount * -1) = UResult.amount) AND (round(#temp_pd.pyd_quantity,2) = round(UResult.quantity,2) OR (round(#temp_pd.pyd_quantity,2) * -1) = round(UResult.quantity,2)) AND (#temp_pd.pyt_itemcode = UResult.pyt_itemcode) AND (#temp_pd.pyh_number = UResult.pyh_number))
	AND #temp_pd.ord_hdrnumber = UResult.ord_hdrnumber --AND #temp_pd.pyd_ivh_hdrnumber = UResult.pyd_ivh_hdrnumber	--vjh 46717
END

-- END Of Deletions

-- Need to add standing deductions even if they have not been drawn for the period
INSERT INTO #temp_pd (pyd_number,pyh_number,asgn_number,asgn_type,asgn_id,ivd_number,pyd_prorap,pyd_payto,pyt_itemcode,		 
					pyd_description,pyr_ratecode,pyd_quantity,pyd_rateunit,pyd_unit,pyd_pretax,pyd_status,pyh_payperiod	,	
					lgh_endcity,pyd_minus,pyd_workperiod,pyd_sequence,pyd_rate,pyd_amount,pyd_payrevenue,mov_number	,	
					lgh_number,ord_hdrnumber,pyd_transdate,payperiodstart,payperiodend,pyd_loadstate,summary_code,name,			
					terminal,type1,pyh_totalcomp,pyh_totaldeduct,pyh_totalreimbrs,crd_cardnumber,lgh_startdate,std_balance,		
					itemsection,ord_startdate,ord_number,ref_number,stp_arrivaldate,shipper_name,shipper_city,shipper_state,		
					consignee_name,consignee_city,consignee_state,cmd_name,pyd_billedweight,adjusted_billed_rate,cht_basis,		
					cht_basisunit,cht_unit,cht_rateunit,std_number,stp_number,unc_factor,stp_mfh_sequence,pyt_description,		
					cht_itemcode,userlabelname,label_name,otherid,trc_drv,start_city,start_state,end_city,end_state,		
					lgh_count,pyh_issuedate,pro_number,bol_number,barcode,billdate,ord_tractor,trailer,shipper_id,consignee_id,    
					order_miles,order_gallons, ivh_invoicenumber, std_priorbalance, std_description, sdm_itemcode, payments, withdrawals, mpp_type4,
					ytd_deduction, ytd_reoccur, pyd_ivh_hdrnumber, pba, pos1, mpp_type2)
--87 items in insert list.
SELECT  -1, 
	    -1, 
	    null,
	    asgn_type = (SELECT MIN(asgn_type) FROM #temp_pd),
	    asgn_id = (SELECT MIN(asgn_id) FROM #temp_pd),
	    -1,
		'P',
		'',
		sd.sdm_itemcode,
		sd.std_description,
		'',
		null,
		'',
		'',
		'',
		'',
		payperiod = (SELECT MIN(pyh_payperiod) FROM #temp_pd),
	    null,
		-1,
		null,
		null,
		0,
		0.00,
		0.00,
		null,
		null,
		null,
		'12/29/2049',  --was date
		null,
		null,
		null,
		null,
		null,
		terminal = (SELECT MIN(terminal) FROM #temp_pd),
		null,
		pyh_totalcomp = (SELECT MIN(round(pyh_totalcomp, 2)) FROM #temp_pd),
		pyh_totaldeduct = (SELECT MIN(round(pyh_totaldeduct, 2)) FROM #temp_pd),
		pyh_totalreimbrs = (SELECT MIN(round(pyh_totalreimbrs, 2)) FROM #temp_pd),
		null,
		null,
		null,
		3,
		'12/29/2049',  --was date
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		sd.std_number,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
	    null,
		0.00,
		'',
		'',
		0.00,
		0.00,
		'',
		0.00,
		0,
		0,
		'',
		1,
		''
FROM standingdeduction sd
WHERE sd.asgn_id = (SELECT MIN(asgn_id) FROM #temp_pd)
AND sd.std_number NOT IN (SELECT DISTINCT(std_number)
						 FROM #temp_pd
						 WHERE std_number IS NOT NULL
						 AND #temp_pd.asgn_id = (SELECT MIN(asgn_id) FROM #temp_pd))

-- End add of standing deductions.

-- Put Open Items into the temp table - mark them as itemtype 5.
IF @drv_yes <> 'XXX' or @car_yes <> 'XXX'
BEGIN
INSERT INTO #temp_pd (pyd_number,pyh_number,asgn_number,asgn_type,asgn_id,ivd_number,pyd_prorap,pyd_payto,pyt_itemcode,		 
					pyd_description,pyr_ratecode,pyd_quantity,pyd_rateunit,pyd_unit,pyd_pretax,pyd_status,pyh_payperiod	,	
					lgh_endcity,pyd_minus,pyd_workperiod,pyd_sequence,pyd_rate,pyd_amount,pyd_payrevenue,mov_number	,	
					lgh_number,ord_hdrnumber,pyd_transdate,payperiodstart,payperiodend,pyd_loadstate,summary_code,name,			
					terminal,type1,pyh_totalcomp,pyh_totaldeduct,pyh_totalreimbrs,crd_cardnumber,lgh_startdate,std_balance,		
					itemsection,ord_startdate,ord_number,ref_number,stp_arrivaldate,shipper_name,shipper_city,shipper_state,		
					consignee_name,consignee_city,consignee_state,cmd_name,pyd_billedweight,adjusted_billed_rate,cht_basis,		
					cht_basisunit,cht_unit,cht_rateunit,std_number,stp_number,unc_factor,stp_mfh_sequence,pyt_description,		
					cht_itemcode,userlabelname,label_name,otherid,trc_drv,start_city,start_state,end_city,end_state,		
					lgh_count,pyh_issuedate,pro_number,bol_number,barcode,billdate,ord_tractor,trailer,shipper_id,consignee_id,    
					order_miles,order_gallons, ivh_invoicenumber, std_priorbalance, std_description, sdm_itemcode, payments, withdrawals, mpp_type4,
					ytd_deduction, ytd_reoccur, pyd_ivh_hdrnumber, pba, pos1,mpp_type2)
--87 items in insert list.
SELECT  -1, 
	    -1, 
	    null,
	    asgn_type = (SELECT MIN(asgn_type) FROM #temp_pd),
	    asgn_id = (SELECT MIN(asgn_id) FROM #temp_pd),
	    -1,
		'P',
		'',
		'',
		'',
		'',
		null,
		'',
		'',
		'',
		'',
		payperiod = (SELECT MIN(pyh_payperiod) FROM #temp_pd),
	    null,
		1,
		null,
		null,
		null,
		#temp_openitems.invoice_total,
		0.00,
		null,
		null,
		null,
		invoice_date,
		null,
		null,
		null,
		null,
		null,
		terminal = (SELECT MIN(terminal) FROM #temp_pd),
		null,
		pyh_totalcomp = (SELECT MIN(round(pyh_totalcomp, 2)) FROM #temp_pd),
		pyh_totaldeduct = (SELECT MIN(round(pyh_totaldeduct, 2)) FROM #temp_pd),
		pyh_totalreimbrs = (SELECT MIN(round(pyh_totalreimbrs, 2)) FROM #temp_pd),
		null,
		null,
		null,
		5,
		invoice_date,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		invoice_number,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
	    null,--invoice_number,
		0.00,
		'',
		'',
		0.00,
		0.00,
		'',
		0.00,
		0,
		0,
		'',
		1,
		''
FROM #temp_openitems

DROP TABLE #temp_openitems
--END OF Insert.
END

 --Update sequence on escrow so we don't get multiple summaries.  We'll get the max pyd_number for the group and set it to 1.

 /* UPDATE #temp_pd
  SET #temp_pd.pyd_sequence = 1
  WHERE #temp_pd.pyd_number IN (select t1.pyd_number
								from #temp_pd t1 join (select std_number, max(pyd_number) as pyd_number from #temp_pd group by std_number) as t2
								on t1.pyd_number = t2.pyd_number
								WHERE t1.pyd_number <> -1
								AND t1.std_number IS NOT NULL
								AND t1.sdm_itemcode = 'ESCROW') */



--Update the temp pay details with standingdeduction data
--UPDATE #temp_pd
--SET std_balance = sd.std_balance,
--    std_priorbalance = sd.std_priorbalance,
--	std_description = sd.std_description,
--	std_number = sd.std_number,
--	sdm_itemcode = sd.sdm_itemcode,
--	pyd_transdate = '12/31/2049',
--	ord_startdate = '12/31/2049'
--FROM  standingdeduction sd
--WHERE #temp_pd.std_number = sd.std_number

UPDATE #temp_pd
SET std_balance = case when sdm_minusbalance = 'Y' then -1 * sd.std_balance else sd.std_balance end,
    std_priorbalance = sd.std_priorbalance,
	std_description = sd.std_description,
	std_number = sd.std_number,
	sdm_itemcode = sd.sdm_itemcode,
	pyd_transdate = '12/31/2049',
	ord_startdate = '12/31/2049'
FROM  standingdeduction sd, stdmaster sdm
where sd.sdm_itemcode = sdm.sdm_itemcode
and #temp_pd.std_number = sd.std_number

--Update sequence on escrow so we don't get multiple summaries.  We'll get the max pyd_number for the group and set it to 1.
  UPDATE #temp_pd
  SET #temp_pd.ytd_reoccur = 1,
  #temp_pd.ord_startdate = '12/31/2049',
  #temp_pd.pyd_transdate = '12/31/2049'
  WHERE #temp_pd.pyd_number IN (select t1.pyd_number
								from #temp_pd t1 join (select std_number, max(pyd_number) as pyd From #temp_pd group by std_number) as t2
								on t1.pyd_number = t2.pyd 
								WHERE t1.std_number IS NOT NULL)
  AND itemsection <> 5


--UPDATE pos1 to show summary

  UPDATE #temp_pd
  SET #temp_pd.pos1 = 1
  /* WHERE #temp_pd.pyd_number IN (select t1.pyd_number
								from #temp_pd t1 join (select ord_hdrnumber, min(ord_startdate) as pyd, min(pyd_number) as pyd_number From #temp_pd group by ord_hdrnumber) as t2
								on t1.ord_startdate = t2.pyd
								AND t1.pyd_number = t2.pyd_number )
  AND itemsection NOT IN (3,5) */


--vjh new instructions on YTD amounts for the deductions.  use UsePayperiodForYTD logic
----Update the temp pay detail with YTD totals - Kenan wants to use the transferdate.
--UPDATE #temp_pd
--SET ytd_deduction = results.ytdamount
--FROM paydetail p
--INNER JOIN
--(SELECT SUM(ROUND(ISNULL(pd.pyd_amount, 0), 2)) as ytdamount, pd.std_number
--					 FROM paydetail pd, #temp_pd
--					 WHERE pd.std_number = #temp_pd.std_number
--					 --AND pd.pyd_transferdate >= '01/01/' + datename(yy, @payperiodstart)
--                     --AND pd.pyd_transferdate <= @payperiodend
--					 AND pd.pyd_transdate >= '01/01/' + datename(yy, @payperiodstart) --should be pyd_transferdate  --  vjh no, transferdate is null in their data, use transdate
--                     AND pd.pyd_transdate <= @payperiodend
--                     AND pd.pyd_status <> 'HLD'
--					 GROUP BY pd.std_number) As results
--ON results.std_number = p.std_number
--WHERE results.std_number = #temp_pd.std_number

IF left(ltrim(@PeriodforYTD),1) = 'Y' 
BEGIN
	UPDATE #temp_pd
	SET ytd_deduction = results.ytdamount
	FROM paydetail p
	INNER JOIN
	(SELECT SUM(ROUND(ISNULL(pd.pyd_amount, 0), 2)) as ytdamount, pd.std_number
						 FROM paydetail pd, #temp_pd
						 WHERE pd.std_number = #temp_pd.std_number
						 AND pd.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend) 
						 AND pd.pyh_payperiod <= @payperiodend
						 AND pd.pyd_status <> 'HLD'
						 -- SGB (vjh) 41605
						 AND #temp_pd.ytd_reoccur > 0
						 GROUP BY pd.std_number) As results
	ON results.std_number = p.std_number
	WHERE results.std_number = #temp_pd.std_number
END 
ELSE 
BEGIN
	UPDATE #temp_pd
	SET ytd_deduction = results.ytdamount
	FROM paydetail p
	INNER JOIN
	(SELECT SUM(ROUND(ISNULL(pd.pyd_amount, 0), 2)) as ytdamount, pd.std_number
						 FROM paydetail pd, payheader ph, #temp_pd
						 WHERE pd.std_number = #temp_pd.std_number
						 AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @pyh_issuedate) 
						 AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) <= @pyh_issuedate
						 AND pd.pyd_status <> 'HLD'
						 -- SGB (vjh) 41605
						 AND #temp_pd.ytd_reoccur > 0
						 AND ph.pyh_pyhnumber = pd.pyh_number
						 GROUP BY pd.std_number) As results
	ON results.std_number = p.std_number
	WHERE results.std_number = #temp_pd.std_number
END

--Update escrows to get them last on settlement.
UPDATE #temp_pd
SET pyt_itemcode = 'ZCROW'
WHERE pyt_itemcode = 'ESCROW'

SELECT pyd_number, --1
	pyh_number, --2
	asgn_number, --3
	asgn_type, --4
	asgn_id, --5
	ivd_number, --6
	pyd_prorap,  --7
	pyd_payto,  --8 
	pyt_itemcode,  --9
	pyd_description,  --10
	pyr_ratecode,  --11
	pyd_quantity,  --12
	pyd_rateunit,  --13
	pyd_unit,      --14
	pyd_pretax,    --15
	pyd_status,    --16
	pyh_payperiod, --17
	lgh_startcity, --18
	lgh_endcity,   --19
	pyd_minus,	   --20
	pyd_workperiod,--21
	pyd_sequence,  --22
	pyd_rate,      --23
	round(pyd_amount, 2) As pyd_amount,  --24
	pyd_payrevenue,  --25
	mov_number,      --26
	lgh_number,      --27
	ord_hdrnumber,   --28
	pyd_transdate,   --29
	payperiodstart,  --30
	payperiodend,    --31
	pyd_loadstate,   --32
	summary_code,    --33
	name,            --34
	terminal,        --35
	type1,           --36
	round(pyh_totalcomp, 2),  --37
	0,  --FMM 3/20/2007 was round(pyh_totaldeduct, 2), --38
	0,  --FMM 3/20/2007 was round(pyh_totalreimbrs, 2), --39
	crd_cardnumber,  --40
	lgh_startdate,   --41
	std_balance,     --42
	itemsection,     --43 
	ord_startdate,   --44
	ord_number,      --45
	ref_number,      --46
	stp_arrivaldate, --47
	shipper_name,    --48
	shipper_city,    --49
	shipper_state,   --50
	consignee_name,  --51
	consignee_city,  --52
	consignee_state, --53
	cmd_name,        --54
	pyd_billedweight,--55
	adjusted_billed_rate, --56
	pyd_payrevenue,  --57
	cht_basisunit,   --58
	pyt_description, --59
	userlabelname,   --60
	label_name,      --61
	otherid,         --62
	trc_drv,         --63
	start_city,      --64
	start_state,     --65
	end_city,        --66
	end_state,       --67
	--lgh_count,       --68
	pro_number,      --68
    bol_number,      --69
    barcode,         --70
    billdate,        --71
    ord_tractor,     --72
    trailer,         --73
    shipper_id,      --74
	consignee_id,    --75 
    order_miles,     --76
    order_gallons,   --77
	ivh_invoicenumber,--78
	Round(ISNULL(std_priorbalance, 0.00),2) As std_priorbalance, --79
    std_description,  --80
	std_number,       --81
	sdm_itemcode,     --82
	Round(ISNULL(payments, 0.00), 2) As payments, --83
    Round(ISNULL(withdrawals, 0.00), 2) As withdrawals, --84
	mpp_type4,         --85
    ytd_deduction = (CASE     --86
						WHEN ytd_deduction < 0.00 THEN ytd_deduction * -1
						ELSE ytd_deduction
					END),
    ytd_reoccur,         --87
	pyd_ivh_hdrnumber,   --88
    pba = (CASE 
			WHEN ISNULL(pba, '') = '' THEN ''
			ELSE (@v_pbaprefix + ' ' + pba)
		   END),                 --89
    pos1,                --90
    mpp_type2            --91
FROM #temp_pd
set ansi_nulls ON
set ansi_warnings ON

GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_summary68] TO [public]
GO
