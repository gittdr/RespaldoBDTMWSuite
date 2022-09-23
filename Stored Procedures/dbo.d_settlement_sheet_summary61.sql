SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_settlement_sheet_summary61](
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
	@relcol varchar(3),
	@relncol varchar(3),
	@workperiodstart datetime,
	@workperiodend datetime)
AS
/**
 * 
 * NAME:
 * dbo.d_settlement_sheet_summary61
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Procedure for settlement sheet 61
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
 * 020 -	@relcol varchar(3),
 * 021 -	@relncol varchar(3),
 * 022 -	@workperiodstart datetime,
 * 023 -	@workperiodend datetime)
 *
 * REVISION HISTORY:
 * 06-JUN-2006 z - PTS 32259 - Created
 * 09/18/2006 vjh - pts 34133 - change logic on consolidated detail amounts
 * 09/19/2006 vjh - pts 34133 - new interpretation of the logic
 * 04/04/2007 SLM - PTS 36756 - Populate "Pay To" field for Drivers based upon "Accounting Type"
 * 07/05/2007 MRK - PTS 37889 - Removed the pyd_description update.  Customer wants section to show what is in the field
 * 08/23/2007 MRK - PTS 37889 - Client requested to maintain the Origin destination descriptions
 * 				for the linehaul pay, but to show the real descriptions for ancillary pay types.
 **/
DECLARE	@PeriodforYTD 		varchar(3),
	@v_asgn_type 		varchar(3),
	@v_asgn_id		varchar(8),
	@v_exists 		varchar(4),
	@v_count		Int,
	@v_psh_id		Int,
	@v_ord_hdrnumber	Int,
	@v_lgh_number		Int,
	@v_i			Int,
	@v_quantity		float,
	@v_rev_loaded 		float,
	@v_rev_unloaded 	float,
	@v_pyd_amount_sum	float,
	@v_pyh_totalcomp 	float

DECLARE	@ld_asgn_number	INT,
	@ld_rate	MONEY,
	@ld_quant	MONEY,
	@ld_sum		MONEY

--Create a temp table for YTD balances
CREATE TABLE #ytdbal (asgn_type	varchar (6) not null,
	asgn_id			varchar (13) not null,
	ytdcomp			money null,
	ytddeduct		money null,
	ytdreimbrs		money null,
	pyh_payperiod		datetime null,
	pyh_issuedate		datetime null)


-- Create a temp table to the pay header and detail numbers
CREATE TABLE #temp_pay (
	pyd_number int not null,
	pyh_number int not null,
	pyd_status varchar(6) null,
	asgn_type1 varchar(6) null)

SELECT	@PeriodForYtd = 'no'

SELECT 	@PeriodforYTD = isnull(gi_string1,'no') 
FROM 	generalinfo
WHERE 	gi_name = 'UsePayperiodForYTD'


-- LOR PTS# 6404 elliminate trial and final settlement sheets - do just one
IF @hld_yes = 'Y' 
BEGIN
	-- Get the driver pay header and detail numbers for held pay
	IF @drv_yes <> 'XXX'
		SELECT	@v_asgn_type = 'DRV'

		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
			-- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
               		-- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@drv_type1
		FROM 	paydetail
		WHERE 	asgn_type = 'DRV'
			AND asgn_id = @drv_id
			AND pyh_number = 0 
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- Get the tractor pay header and detail numbers for held pay
	IF @trc_yes <> 'XXX'
		-- 01-JUN-2006 SWJ - PTS 32259
		SELECT	@v_asgn_type = 'TRC'

		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
                        -- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
                        -- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@trc_type1
		FROM 	paydetail
		WHERE 	asgn_type = 'TRC'
	  		AND asgn_id = @trc_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- Get the carrier pay header and detail numbers for held pay
	IF @car_yes <> 'XXX'
		-- 01-JUN-2006 SWJ - PTS 32259
		SELECT	@v_asgn_type = 'CAR'

		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
                        -- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
                        -- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@car_type1
		FROM 	paydetail
		WHERE 	asgn_type = 'CAR'
	  		AND asgn_id = @car_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- Get the trailer pay header and detail numbers for held pay
	IF @trl_yes <> 'XXX'
		-- 01-JUN-2006 SWJ - PTS 32259
		SELECT	@v_asgn_type = 'TRL'

		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
                        -- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
                        -- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@trl_type1
		FROM 	paydetail
		WHERE 	asgn_type = 'TRL'
	  		AND asgn_id = @trl_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend
END

IF @drv_yes <> 'XXX'
	SELECT @v_asgn_type = 'DRV'
ELSE IF @trc_id <> 'XXX'
	SELECT @v_asgn_type = 'TRC'
ELSE IF @trl_id <> 'XXX'
	SELECT @v_asgn_type = 'TRL'
ELSE IF @car_id <> 'XXX'
	SELECT @v_asgn_type = 'CAR'

-- 01-JUN-2006 SWJ - PTS 32259 - Determine what ID to use based off of the type
SELECT	@v_asgn_id = 	CASE @v_asgn_type
				WHEN 'DRV' THEN @drv_id
				WHEN 'CAR' THEN @car_id
				WHEN 'TRC' THEN @trc_id
				WHEN 'TRL' THEN @trl_id
		 	END

-- 09-AUG-2006 SWJ - PTS 32259 - Modified to select the pay period date from payscheduledetail and not payheader
-- Get the last released payperiod for this resource and add a day. Make this the new pay period start
SELECT	TOP 1 @payperiodstart = DateAdd(day, 1, psd_date)
FROM	payschedulesdetail
WHERE	psd_date < @payperiodstart
ORDER BY psd_date DESC

IF @relcol  = 'N' and @relncol = 'Y' 
BEGIN
	IF @drv_yes <> 'XXX'
		-- Get the driver pay header and detail numbers for pay released 
		-- to this payperiod, but not collected
		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
			pyd_status,
			@drv_type1
		FROM 	paydetail
		WHERE 	asgn_type = 'DRV'
		  	AND asgn_id = @drv_id
		  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pyh_number = 0

	-- Get the tractor pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @trc_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
			pyd_status,
			@trc_type1
		FROM 	paydetail
		WHERE 	asgn_type = 'TRC'
		  	AND asgn_id = @trc_id
		  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pyh_number = 0

	-- Get the carrier pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @car_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
			pyd_status,
			@car_type1
		FROM 	paydetail
		WHERE 	asgn_type = 'CAR'
		  	AND asgn_id = @car_id
		  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pyh_number = 0

	-- LOR  PTS# 5744 add trailer settlements
	-- Get the trailer pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @trl_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
			pyd_status,
			@trl_type1
		FROM 	paydetail
		WHERE 	asgn_type = 'TRL'
	  		AND asgn_id = @trl_id
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
		SELECT 	pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@drv_type1
		FROM 	paydetail pd, payheader ph
		WHERE 	ph.asgn_type = 'DRV'
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
		SELECT 	pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@trc_type1
		FROM 	paydetail pd, payheader ph
		WHERE 	ph.asgn_type = 'TRC'
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
		SELECT 	pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,

			@car_type1
		FROM 	paydetail pd, payheader ph
		WHERE 	ph.asgn_type = 'CAR'
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
		SELECT 	pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@trl_type1
		FROM 	paydetail pd, payheader ph
		WHERE 	ph.asgn_type = 'TRL'
			AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @trl_id = ph.asgn_id
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
-- 31-MAY-2006 SWJ - PTS 32559 - Changed to 80 long for concatenation
	pyd_payto		varchar(80) null, -- changed from 6 to 12 for PTS #5849, JET - 6/10/99
        pto_id                  char(12) null, -- PTS 36756 
	pyt_itemcode		varchar(6) null, 
-- PTS 29303 -- BL (start)	
--	pyd_description		varchar(30) null, 
	pyd_description		varchar(75) null, 
-- PTS 29303 -- BL (end)	
	pyr_ratecode		varchar(6) null, 
	pyd_quantity		float null,		--extension (BTC)
-- 06-JUN-2006 SWJ - PTS 32559		
	pyd_rev_loaded		float null,
	pyd_rev_unloaded	float null,
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
	name			varchar(64) null,
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
	ord_number		char(12) null,
	ref_number		varchar(30) null,
	stp_arrivaldate		datetime null,
	shipper_name		varchar(50) null,
	shipper_city		varchar(18) null,
	shipper_state		char(2) null,
	consignee_name		varchar(50) null,
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
	otherid			varchar(8) null,
	pyt_fee1		money null,
	pyt_fee2		money null,
	start_city		varchar(18) null,
	start_state		char(2) null,
	end_city		varchar(30) null,
	end_state		char(2) null,
	lgh_count		int null,
	ref_number_tds		varchar(30) null,
	pyd_offsetpay_number	int null,
	pyd_credit_pay_flag	char(1) null,
	pyd_refnumtype             varchar(6) null,
	pyd_refnum              varchar(30) null,
	pyh_issuedate		datetime null,
-- PTS 29515 -- BL (start)
	pyt_basis		varchar(6) null )
-- PTS 29515 -- BL (end)

-- Insert into the temp pay details table with the paydetail data per #temp_pay
INSERT INTO #temp_pd
SELECT 	pd.pyd_number,
	pd.pyh_number,
	pd.asgn_number,
	pd.asgn_type,
	pd.asgn_id,
	pd.ivd_number,
	pd.pyd_prorap,
	pyd_payto,
        pyd_payto pto_id, -- SLM PTS 36756
	pd.pyt_itemcode,
	pd.pyd_description,
	pd.pyr_ratecode,
	pd.pyd_quantity,
	0,
	0,
	pd.pyd_rateunit, 
	pd.pyd_unit,
	pd.pyd_pretax,
	tp.pyd_status,
	@payperiodstart,
	pd.lgh_startcity,
	pd.lgh_endcity,
	pd.pyd_minus,
	pd.pyd_workperiod,
	pd.pyd_sequence,
	pd.pyd_rate,
	ROUND(pd.pyd_amount, 2),
	pd.pyd_payrevenue,
	pd.mov_number,
	pd.lgh_number,
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
        -- JET - 5/7/99 - PTS #5667
	pd.pyt_fee1,
	pd.pyt_fee2,
	null,
	null,
	null,
	null,
	0,
	null,
	pyd_offsetpay_number,
	pyd_credit_pay_flag,
	pyd_refnumtype,
	pyd_refnum,
	(select pyh_issuedate from payheader where pyh_pyhnumber = pd.pyh_number) pyh_issuedate,
 -- PTS 29515 -- BL (start)
	null -- pyt_basis
-- PTS 29515 -- BL (end)
FROM 	paydetail pd, 
	#temp_pay tp
WHERE 	pd.pyd_number = tp.pyd_number


-- 31-MAY-2006 SWJ - PTS 32259 - Concatenate the driver's first and last name
UPDATE 	#temp_pd
SET	pyd_payto =	(SELECT	IsNull(mpp_firstname + ' ', '') + IsNull(mpp_lastname, '')
			FROM	manpowerprofile mpp
			WHERE	mpp.mpp_id = #temp_pd.asgn_id)
WHERE	asgn_type = 'DRV'
AND     #temp_pd.pyd_prorap = 'P' -- PTS 36756 SLM 4/4/2007 Only do this for Accounting type of Payroll

-- PTS 36756 SLM 4/4/2007 Display the "CompanyName" if the Driver has an accounting type of Accounts Payable
UPDATE 	#temp_pd
SET	pyd_payto =	(SELECT	IsNull(pto_companyname, '')
			FROM	payto 
			WHERE	payto.pto_id = #temp_pd.pto_id)
WHERE	asgn_type = 'DRV'
AND     #temp_pd.pyd_prorap = 'A' 

-- If the name is null, set it to UNKNOWN
UPDATE	#temp_pd
SET	pyd_payto = 'UNKNOWN'
WHERE	pyd_payto IS NULL
	OR pyd_payto = ''

--Update the temp pay details with legheader data
UPDATE 	#temp_pd
SET 	lgh_startdate = (SELECT	lgh_startdate 
                        FROM 	legheader lh
                        WHERE 	lh.lgh_number = #temp_pd.lgh_number)

-- Update the temp with number of legheaders for the move
-- actually, just find if there was another legheader on the move
UPDATE #temp_pd
   SET lgh_count = (SELECT COUNT(lgh_number) 
                      FROM legheader lh 
                     WHERE lh.mov_number = #temp_pd.mov_number)

--Update the temp pay details with orderheader data
UPDATE 	#temp_pd
   SET 	ord_startdate = oh.ord_startdate,
       	ord_number = oh.ord_number
  FROM 	#temp_pd tp, 
       	orderheader oh
 WHERE 	tp.ord_hdrnumber = oh.ord_hdrnumber

-- 02-JUN-2006 SWJ - Added RTRIM to concatenation. Ord_number is a CHAR(12), and concatenating the /S to it makes it 14 characters long,
--			causing a truncation error
--Update the temp, for split trips, set ord_number = ord_number + '/S'
UPDATE 	#temp_pd
   SET 	ord_number = RTRIM(ord_number) + '/S'
 WHERE 	ord_hdrnumber > 0 
       	AND lgh_count > 1 -- JET - 5/28/99 - PTS #5788, this was set to 0 and I changed it to 1

--JD #11490 09/24/01
UPDATE 	#temp_pd
SET    	shipper_city = ct.cty_name,
	shipper_state = ct.cty_state
  FROM 	#temp_pd tp, city ct, orderheader oh
 WHERE 	tp.ord_hdrnumber = oh.ord_hdrnumber
       	AND oh.ord_origincity = ct.cty_code


UPDATE 	#temp_pd
SET    	consignee_city = ct.cty_name,
	consignee_state = ct.cty_state
  FROM 	#temp_pd tp, city ct, orderheader oh
 WHERE 	tp.ord_hdrnumber = oh.ord_hdrnumber
       	AND oh.ord_destcity = ct.cty_code

UPDATE 	#temp_pd
   SET 	shipper_name = co.cmp_name 
  FROM 	#temp_pd tp, company co,orderheader oh
 WHERE 	tp.ord_hdrnumber = oh.ord_hdrnumber
       	AND oh.ord_shipper = co.cmp_id

UPDATE 	#temp_pd
   SET 	consignee_name = co.cmp_name
  FROM 	#temp_pd tp, company co,orderheader oh
 WHERE 	tp.ord_hdrnumber = oh.ord_hdrnumber
      	AND oh.ord_consignee = co.cmp_id

--Update the temp pay details with standingdeduction data
UPDATE #temp_pd
   SET std_balance = (SELECT std_balance 
                        FROM standingdeduction sd 
                       WHERE sd.std_number = #temp_pd.std_number)

--Update the temp pay details for summary code
UPDATE #temp_pd
   SET summary_code = 'OTHER'
 WHERE summary_code <> 'MIL'

--Update the temp pay details for load status
UPDATE #temp_pd
   SET pyd_loadstate = 'NA'
 WHERE pyd_loadstate IS NULL

-- JET - 5/14/99 - trying to reduce I/O by using a nested select
--Update the temp pay details with payheader data
UPDATE #temp_pd
SET crd_cardnumber = (SELECT ph.crd_cardnumber 
                           FROM payheader ph
                          WHERE ph.pyh_pyhnumber = #temp_pd.pyh_number)

--Need to get the stop of the 1st delivery and find the commodity and arrival date
--associated with it.
--Update the temp pay details table with stop data for the 1st unload stop
UPDATE #temp_pd
   SET stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                             FROM stops st
                            WHERE st.mov_number = #temp_pd.mov_number 
                                  AND stp_event IN ('DRL', 'LUL', 'DUL', 'PUL')) 
--  FROM #temp_pd tp

UPDATE #temp_pd
   SET stp_number = (SELECT MAX(stp_number) 
                       FROM stops st 
                      WHERE st.mov_number = #temp_pd.mov_number
                            AND st.stp_mfh_sequence = #temp_pd.stp_mfh_sequence)

-- Update for stop arrivaldate
UPDATE #temp_pd
   SET stp_arrivaldate = (SELECT stp_arrivaldate
                            FROM stops st
                           WHERE st.stp_number = #temp_pd.stp_number)

--Update the temp pay details with commodity data
UPDATE #temp_pd
   SET cmd_name = (SELECT MIN(cmd_name) 
                     FROM freightdetail fd, 
                          commodity cd
                    WHERE fd.stp_number = #temp_pd.stp_number 
                          AND fd.cmd_code = cd.cmd_code)

--Need to get the bill-of-lading from the reference number table
--Update the temp pay details with reference number data
UPDATE #temp_pd
   SET ref_number = (SELECT MIN(ref_number) 
                       FROM referencenumber 
                      WHERE ref_tablekey = #temp_pd.ord_hdrnumber
                            AND ref_table = 'orderheader'
                            AND ref_type = 'SID')

-- Could this be written to reduce I/O, I'm not sure breaking it up will help
--Need to get revenue charge type data from the chargetype table
UPDATE #temp_pd
   SET cht_basis = ct.cht_basis,
       cht_basisunit = ct.cht_basisunit,
       cht_unit = ct.cht_unit,
       cht_rateunit = ct.cht_rateunit
  FROM #temp_pd tp, chargetype ct
 WHERE tp.cht_itemcode = ct.cht_itemcode

UPDATE #temp_pd 
   SET unc_factor = uc.unc_factor
  FROM #temp_pd tp, unitconversion uc
 WHERE uc.unc_from = tp.cht_basisunit
       AND uc.unc_to = tp.cht_rateunit
       AND uc.unc_convflag = 'R'

UPDATE #temp_pd
   SET adjusted_billed_rate = ROUND(pyd_payrevenue / pyd_billedweight / unc_factor, 2)
 WHERE pyd_billedweight > 0
       AND unc_factor > 0
       AND pyd_payrevenue > 0


UPDATE #temp_pd
   SET itemsection = 4
 WHERE pyt_itemcode = 'MN+'
       OR pyt_itemcode = 'MN-'

--Update the temp pay details with labelfile data and drv alt id
UPDATE #temp_pd
   SET userlabelname = l.userlabelname,
       label_name = l.name,
       otherid = m.mpp_otherid
  FROM #temp_pd tp, labelfile l, manpowerprofile m
 WHERE m.mpp_id = tp.asgn_id 
       AND l.labeldefinition = 'DrvType1'
       AND m.mpp_type1 = l.abbr 

--Update the temp pay details with start/end city/state data - LOR PTS# 4457
UPDATE #temp_pd
   SET start_city = ct.cty_name, 
       start_state = ct.cty_state
  FROM #temp_pd tp, city ct
 WHERE ct.cty_code = tp.lgh_startcity

UPDATE #temp_pd
   SET end_city = ct.cty_name,
       end_state = ct.cty_state
  FROM #temp_pd tp, city ct
 WHERE ct.cty_code = tp.lgh_endcity

--Update the temp pay details with TDS ref# for CryOgenics - LOR PTS# 6837
UPDATE #temp_pd
   SET ref_number_tds = r.ref_number
  FROM #temp_pd tp, labelfile l, orderheader o, referencenumber r
 WHERE r.ref_table = 'orderheader' and
	r.ref_tablekey = tp.ord_hdrnumber and
	l.labeldefinition = 'ReferenceNumbers' and
	l.abbr = r.ref_type and
	r.ref_type = 'TRIP' and
	o.ord_hdrnumber = tp.ord_hdrnumber and
	r.ref_type = o.ord_reftype

-- PTS 29515 -- BL (start)
update 	#temp_pd
set 	pyt_basis = p.pyt_basis
from 	#temp_pd tp, paytype p
where 	tp.pyt_itemcode = p.pyt_itemcode
-- PTS 29515 -- BL (end)

--JD 11605 delete fake routing paydetails
if exists (select * from generalinfo where gi_name = 'StlFindNextMTLeg' and gi_string1 = 'Y')
	delete #temp_pd from paydetail where #temp_pd.pyd_number = paydetail.pyd_number and paydetail.tar_tarriffnumber = '-1'


-- 31-MAY-2006 SWJ - PTS 32259 - Concatenate the driver's first and last name
UPDATE	#temp_pd
SET	pyd_payto = 	(SELECT	IsNull(mpp_firstname + ' ', '') + IsNull(mpp_lastname, '') 
			FROM 	manpowerprofile mpp 
			WHERE mpp.mpp_id = #temp_pd.asgn_id)
WHERE	asgn_type = 'DRV'
AND     #temp_pd.pyd_prorap = 'P' -- PTS 36756 SLM 4/4/2007 Only do this for Accounting type of Payroll

-- PTS 36756 SLM 4/4/2007 Display the "CompanyName" if the Driver has an accounting type of Accounts Payable
UPDATE 	#temp_pd
SET	pyd_payto =	(SELECT	IsNull(pto_companyname, '')
			FROM	payto 
			WHERE	payto.pto_id = #temp_pd.pto_id)
WHERE	asgn_type = 'DRV'
AND     #temp_pd.pyd_prorap = 'A' 

-- Set to UNKNOWN if name is NULL
UPDATE 	#temp_pd
SET	pyd_payto = 'UNKNOWN'
WHERE	pyd_payto IS NULL 
	OR pyd_payto = ''

-- Get the smallest order number that is a primary line haul and is revenue based
SELECT 	@v_ord_hdrnumber = MIN(tp.ord_hdrnumber)
FROM	#temp_pd tp,
	paytype p
WHERE	tp.pyt_itemcode = p.pyt_itemcode
	AND p.pyt_basis = 'LGH'
	AND p.pyt_basisunit = 'REV'

-- Loop while there is still an order number
WHILE @v_ord_hdrnumber >= 0
BEGIN
--vjh 34133 change from this logic to logic that more closely matches the SR
-- QTY = sum(amount)
-- RATE = same % from original detail
-- AMOUNT = QTY * RATE

--vjh 34133 new interpretation.  QTY = sum(QTY)
--	-- Get the SUM of all of the quantities for this order
	SELECT	@v_quantity = SUM(pyd_quantity)
	FROM	#temp_pd
	WHERE	pyt_itemcode IN ('FSCD', 'FSCPC', 'FSCPF', 'FSCPU', 'EXPSUR', 'TSRC')
		AND ord_hdrnumber = @v_ord_hdrnumber
--	SELECT	@v_pyd_amount_sum = SUM(pyd_amount)
--	FROM	#temp_pd
--	WHERE	pyt_itemcode IN ('FSCD', 'FSCPC', 'FSCPF', 'FSCPU', 'EXPSUR', 'TSRC')
--		AND ord_hdrnumber = @v_ord_hdrnumber
--
--	-- Update the TSRC with the new total quantity
	UPDATE	#temp_pd
	SET	pyd_quantity = @v_quantity,
		pyd_amount = @v_quantity * pyd_rate
	WHERE	pyt_itemcode = 'TSRC'
		AND ord_hdrnumber = @v_ord_hdrnumber 

	-- Delete all of the surcharges from the temp table for this order
	DELETE
	FROM	#temp_pd
	WHERE	pyt_itemcode IN ('FSCD', 'FSCPC', 'FSCPF', 'FSCPU', 'EXPSUR')
		AND ord_hdrnumber = @v_ord_hdrnumber

	SELECT	@v_exists = NULL

	SELECT	@v_exists = 'TRUE'
	FROM	#temp_pd
	WHERE	ord_hdrnumber = @v_ord_hdrnumber
		AND pyt_itemcode = 'TSRC'

	IF @v_exists IS NOT NULL AND @v_exists <> ''
	BEGIN
		SELECT 	@v_lgh_number = lgh_number
		FROM	#temp_pd
		WHERE	ord_hdrnumber = @v_ord_hdrnumber
			AND pyt_itemcode = 'TSRC'

		SELECT	@v_rev_loaded = 0
		SELECT	@v_rev_unloaded = 0

		SELECT	@v_rev_loaded = SUM(stp_lgh_mileage)
		FROM	stops
		WHERE	lgh_number = @v_lgh_number
			AND stp_loadstatus = 'LD'

		SELECT	@v_rev_unloaded = SUM(stp_lgh_mileage)
		FROM	stops
		WHERE	lgh_number = @v_lgh_number
			AND stp_loadstatus <> 'LD'

		IF @v_rev_loaded IS NULL OR @v_rev_loaded = ''
			SELECT @v_rev_loaded = 0

		IF @v_rev_unloaded IS NULL OR @v_rev_unloaded = ''
			SELECT @v_rev_unloaded = 0

		UPDATE	#temp_pd
		SET	pyd_rev_loaded = @v_rev_loaded,
			pyd_rev_unloaded = @v_rev_unloaded
		WHERE 	ord_hdrnumber = @v_ord_hdrnumber
			AND lgh_number = @v_lgh_number
			AND pyt_itemcode = 'TSRC'

	END
	
	-- Get the next order number
	SELECT 	@v_ord_hdrnumber = MIN(tp.ord_hdrnumber)
	FROM	#temp_pd tp,
		paytype p
	WHERE	tp.pyt_itemcode = p.pyt_itemcode
		AND p.pyt_basis = 'LGH'
		AND p.pyt_basisunit = 'REV'
		AND ord_hdrnumber > @v_ord_hdrnumber
END


--Insert into the temp YTD balances table the assets from the temp pay details table
INSERT INTO #ytdbal
     SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
       FROM #temp_pd

--Compute the YTD balances for each assets
--LOR	fixed null problem SR 7095
--JYang pts13004
if left(ltrim(@PeriodforYTD),1) = 'Y' 
BEGIN
	UPDATE #ytdbal
	   SET	ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
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
	FROM  #ytdbal yb
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
 
UPDATE #ytdbal
   SET ytdcomp = ytdcomp + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2))
                              FROM #temp_pd tp
                             WHERE tp.asgn_id = yb.asgn_id
                                   AND tp.asgn_type = yb.asgn_type
                                   AND tp.pyd_pretax = 'Y'
                                   AND tp.pyd_status <> 'HLD'
				   AND pyh_number = 0), 0)
   FROM  #ytdbal yb

UPDATE #ytdbal
   SET ytddeduct = ytddeduct + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2)) 
                                  FROM #temp_pd tp
                                 WHERE tp.asgn_id = yb.asgn_id
                                       AND tp.asgn_type = yb.asgn_type
                                       AND tp.pyd_pretax = 'N'
                                       AND tp.pyd_minus = -1
                                       AND tp.pyd_status <> 'HLD'
				       AND pyh_number = 0), 0)
   FROM  #ytdbal yb

UPDATE #ytdbal
   SET ytdreimbrs = ytdreimbrs + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2))
                                    FROM #temp_pd tp
                                   WHERE tp.asgn_id = yb.asgn_id
                                         AND tp.asgn_type = yb.asgn_type
                                         AND tp.pyd_pretax = 'N'
                                         AND tp.pyd_minus = 1
                                         AND tp.pyd_status <> 'HLD'
					 AND pyh_number = 0 ), 0)
   FROM  #ytdbal yb

UPDATE 	#temp_pd
  SET 	pyh_totalcomp = yb.ytdcomp,
       	pyh_totaldeduct = yb.ytddeduct,
       	pyh_totalreimbrs = yb.ytdreimbrs
  FROM 	#ytdbal yb
		,#temp_pd tp
  WHERE tp.asgn_type = yb.asgn_type
	AND tp.asgn_id = yb.asgn_id
	--vmj1+	Note that 2/2/1950 is a very unlikely date value which is used to compare NULL 
	--to NULL..
	and isnull(tp.pyh_issuedate, '1950-02-02') = isnull(yb.pyh_issuedate, '1950-02-02')
	and isnull(tp.pyh_payperiod, '1950-02-02') = isnull(yb.pyh_payperiod, '1950-02-02')
	--vmj1-

UPDATE #temp_pd
   SET itemsection = 2
 WHERE pyd_pretax = 'N'
       AND pyd_minus = 1

UPDATE #temp_pd
   SET itemsection = 3
 WHERE pyd_pretax = 'N'
       AND pyd_minus = -1
-- MRK Start 08/23/07 PTS 37889
Update #temp_pd
   SET pyd_description = 
	Case when #temp_pd.pyt_basis = 'LGH' and #temp_pd.ord_hdrnumber <> 0 then ( SELECT 	IsNull(cty_name + ', ', '') +  IsNull(cty_state, '')
				FROM	city
				WHERE	cty_code IN (	SELECT 	ord_origincity
							FROM	orderheader
							WHERE	ord_hdrnumber = #temp_pd.ord_hdrnumber))+ ' to ' +( SELECT IsNull(cty_name + ', ', '') +  IsNull(cty_state, '')
			FROM	city
			WHERE	cty_code IN (	SELECT 	ord_destcity
						FROM	orderheader
	    				WHERE	ord_hdrnumber = #temp_pd.ord_hdrnumber))
	    when #temp_pd.pyt_basis = 'LGH' and #temp_pd.ord_hdrnumber = 0 then ( SELECT 	IsNull(cty_name + ', ', '') +  IsNull(cty_state, '')
				FROM	city
				WHERE	cty_code IN (	SELECT 	lgh_startcity
							FROM	legheader
							WHERE	lgh_number = #temp_pd.lgh_number))+ ' to ' +( SELECT IsNull(cty_name + ', ', '') +  IsNull(cty_state, '')
			FROM	city
			WHERE	cty_code IN (	SELECT 	lgh_endcity
						FROM	Legheader
	    				WHERE	lgh_number = #temp_pd.lgh_number))
	else pyd_description
	end
Where pyt_basis = 'LGH'
--MRK End 08/23/07 PTS 37889
	

-- 31-MAY-2006 SWJ - PTS 32259 - See if there are any line haul details
/*SELECT	@v_count = COUNT(*)
FROM	#temp_pd	
WHERE	pyt_basis = 'LGH'

-- If there are, find the start and finish city and put them in the description
IF @v_count > 0
--IF (select pyt_basis from #temp_pd) = 'LGH'
-- PTS 37889 MRK (start)
BEGIN
	UPDATE	#temp_pd
	SET	pyd_description = ( SELECT 	IsNull(cty_name + ', ', '') +  IsNull(cty_state, '')
				FROM	city
				WHERE	cty_code IN (	SELECT 	ord_origincity
							FROM	orderheader
							WHERE	ord_hdrnumber = #temp_pd.ord_hdrnumber)and #temp_pd.pyt_basis = 'LGH')
		
	
	UPDATE	#temp_pd
	SET	pyd_description = pyd_description + ' to ' + 
			( SELECT IsNull(cty_name + ', ', '') +  IsNull(cty_state, '')
			FROM	city
			WHERE	cty_code IN (	SELECT 	ord_destcity
						FROM	orderheader
						WHERE	ord_hdrnumber = #temp_pd.ord_hdrnumber)and #temp_pd.pyt_basis = 'LGH')
		

	UPDATE	#temp_pd
	SET	pyd_description = NULL
	WHERE	LTRIM(RTRIM(pyd_description)) = 'to'
		and #temp_pd.pyt_basis = 'LGH'
END*/
-- PTS 37889 MRK (start)


SELECT	@ld_asgn_number = MIN(asgn_number)
FROM	#temp_pd

WHILE 1=1
BEGIN
	IF @ld_asgn_number IS NULL
		BREAK

	SELECT	@ld_quant = MIN(pyd_quantity)
	FROM	#temp_pd
	WHERE	asgn_number = @ld_asgn_number
		AND pyt_itemcode = 'TSM'

	
	WHILE 1=1
	BEGIN
		IF @ld_quant IS NULL
			BREAK

		SELECT	@ld_sum = SUM(pyd_amount)
		FROM	#temp_pd
		WHERE	asgn_number = @ld_asgn_number
			AND pyd_quantity = @ld_quant
			AND pyt_itemcode IN ('FSCD', 'FSCPC', 'FSCPF', 'FSCPU', 'EXPSUR', 'FUEL D')

		IF @ld_sum IS NOT NULL
		BEGIN
			UPDATE	#temp_pd
			SET	pyd_amount = pyd_amount + @ld_sum
			WHERE	asgn_number = @ld_asgn_number
				AND pyd_quantity = @ld_quant
				AND pyt_itemcode = 'TSM'
		END

		SELECT	@ld_quant = MIN(pyd_quantity)
		FROM	#temp_pd
		WHERE	asgn_number = @ld_asgn_number
			AND pyt_itemcode = 'TSM'
			AND pyd_quantity > @ld_quant

	END

	SELECT	@ld_asgn_number = MIN(asgn_number)
	FROM	#temp_pd
	WHERE	asgn_number > @ld_asgn_number
END
	

SELECT 	pyd_number, 
	pyh_number, 
	asgn_number, 
	tp.asgn_type, 
	tp.asgn_id, 
	ivd_number, 
	pyd_prorap, 
	pyd_payto,
	pyt_itemcode,
	pyd_description,
	pyr_ratecode, 
	pyd_quantity, 
	pyd_rev_loaded,
	pyd_rev_unloaded,
	pyd_rateunit, 
	pyd_unit, 
	pyd_pretax, 
	pyd_status, 
	tp.pyh_payperiod, 
	lgh_startcity,
	lgh_endcity, 
	pyd_minus,
	pyd_workperiod,
	pyd_sequence,
	pyd_rate,
	round(pyd_amount, 2),
	pyd_payrevenue,
	tp.mov_number,
	lgh_number,
	tp.ord_hdrnumber,
	pyd_transdate,
	payperiodstart,
	payperiodend,
	pyd_loadstate,
	summary_code,
	name,
	terminal,
	type1,
	round(tp.pyh_totalcomp, 2),
	round(tp.pyh_totaldeduct, 2),
	round(tp.pyh_totalreimbrs, 2),
	ph.crd_cardnumber 'crd_cardnumber',
	lgh_startdate,
	std_balance,
	itemsection,
	tp.ord_startdate,
	tp.ord_number,
	ref_number,
	stp_arrivaldate,
	shipper_name,
	shipper_city,
	shipper_state,
	consignee_name,
	consignee_city,
	consignee_state,
	cmd_name,
	pyd_billedweight,
	adjusted_billed_rate,
	pyd_payrevenue,
	cht_basisunit,
	pyt_description,
	userlabelname,
	label_name,
	otherid,
	pyt_fee1,
	pyt_fee2,
	start_city,
	start_state,
	end_city,
	end_state, 
       	ph.pyh_paystatus,
	ref_number_tds,
	pyd_offsetpay_number,
	pyd_credit_pay_flag,
	pyd_refnumtype,
	pyd_refnum,
	ord.ord_tractor ,
-- PTS 29515 -- BL (start)
	pyt_basis
-- PTS 29515 -- BL (end)
FROM 	#temp_pd tp 
       	LEFT OUTER JOIN payheader ph ON ph.pyh_pyhnumber = tp.pyh_number
	LEFT OUTER JOIN orderheader ord ON ord.ord_hdrnumber = tp.ord_hdrnumber
WHERE	pyt_itemcode NOT IN ('FSCD', 'FSCPC', 'FSCPF', 'FSCPU', 'EXPSUR', 'FUEL D')

DROP TABLE #ytdbal
DROP TABLE #temp_pay
DROP TABLE #temp_pd

GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_summary61] TO [public]
GO
