SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  PROC [dbo].[d_settlement_sheet_summary_57](
	@report_type VARCHAR(5),
	@payperiodstart DATETIME,
	@payperiodend DATETIME,
	@drv_yes VARCHAR(3),
	@trc_yes VARCHAR(3),
	@trl_yes VARCHAR(3),
	@drv_id VARCHAR(8),
	@trc_id VARCHAR(8),
	@trl_id VARCHAR(13),
	@drv_type1 VARCHAR(6),
	@trc_type1 VARCHAR(6),
	@trl_type1 VARCHAR(6),
	@terminal VARCHAR(8),
	@name VARCHAR(64),
	@car_yes VARCHAR(3),
	@car_id VARCHAR(8),
	@car_type1 VARCHAR(6),
	@hld_yes VARCHAR(3),	
	@pyhnumber INT,
	@relcol VARCHAR(3),
	@relncol VARCHAR(3),
	@workperiodstart DATETIME,
	@workperiodend DATETIME)
AS

/**
 * 
 * NAME:
 * dbo.d_settlement_sheet_summary57
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for settlemetn sheet 57
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * see retrun SET
 *
 * PARAMETERS:
 * 001 - @report_type VARCHAR(5),
 * 002 - @payperiodstart DATETIME,
 * 003 - @payperiodend DATETIME,
 * 004 - @drv_yes VARCHAR(3),
 * 005 - @trc_yes VARCHAR(3),
 * 006 - @trl_yes VARCHAR(3),
 * 007 - @drv_id VARCHAR(8),
 * 008 - @trc_id VARCHAR(8),
 * 009 - @trl_id VARCHAR(13),
 * 010 - @drv_type1 VARCHAR(6),
 * 011 - @trc_type1 VARCHAR(6),
 * 012 - @trl_type1 VARCHAR(6),
 * 013 - @terminal VARCHAR(8),
 * 014 - @name VARCHAR(64),
 * 015 - @car_yes VARCHAR(3),
 * 016 - @car_id VARCHAR(8),
 * 017 - @car_type1 VARCHAR(6),
 * 018 - @hld_yes VARCHAR(3),	
 * 019 - @pyhnumber INT,
 * 020 - @relcol VARCHAR(3),
 * 021 - @relncol VARCHAR(3),
 * 022 - @workperiodstart DATETIME,
 * 023 - @workperiodend DATETIME
 *
 * REVISION HISTORY:
 * 03/26/07.01 PTS31819 - OS - Created stored proc as modification of proc for  d_stlmnt_det_report_general
 *
 **/

-- Create a temp table to the pay header AND detail numbers
CREATE TABLE #temp_pay(
	pyd_number INT NOT NULL,
	pyh_number INT NOT NULL,
	pyd_status VARCHAR(6) NULL,
	asgn_type1 VARCHAR(6) NULL)

-- Create a temp table to hold the pay header AND detail numbers
-- Create a temp table to hold the pay details
CREATE TABLE #temp_pd(
	pyd_number INT NOT NULL,
	pyh_number INT NOT NULL,
	asgn_number INT NULL,
	asgn_type VARCHAR(6) NOT NULL,
	asgn_id	VARCHAR(13) NOT NULL,
	ivd_number INT NULL,
	pyd_prorap VARCHAR(6) NULL, 
	pyd_payto VARCHAR(12) NULL, 
	pyt_itemcode VARCHAR(6) NULL, 
	pyd_description VARCHAR(75) NULL, 
	pyr_ratecode VARCHAR(6) NULL, 
	pyd_quantity FLOAT NULL,		--extension (BTC)
	pyd_rateunit VARCHAR(6) NULL,
	pyd_unit VARCHAR(6) NULL,
	pyd_pretax CHAR(1) NULL,
	pyd_status VARCHAR(6) NULL,
	pyh_payperiod DATETIME NULL,
	lgh_startcity INT NULL,
	lgh_endcity INT NULL,
	pyd_minus INT NULL,
	pyd_workperiod DATETIME NULL,
	pyd_sequence INT NULL,
	pyd_rate MONEY NULL,		--rate (BTC)
	pyd_amount MONEY NULL,
	pyd_payrevenue MONEY NULL,		
	mov_number INT NULL,
	lgh_number INT NULL,
	ord_hdrnumber INT NULL,
	pyd_transdate DATETIME NULL,
	payperiodstart DATETIME NULL,
	payperiodend DATETIME NULL,
	pyd_loadstate VARCHAR(6) NULL,
	summary_code VARCHAR(6) NULL,
	name VARCHAR(64) NULL,
	terminal VARCHAR(6) NULL,
	type1 VARCHAR(6) NULL,
	pyh_totalcomp MONEY NULL,
	pyh_totaldeduct MONEY NULL,
	pyh_totalreimbrs MONEY NULL,
	crd_cardnumber CHAR(20) NULL,
	lgh_startdate DATETIME NULL,
	std_balance MONEY NULL,
	itemsection INT NULL,
	ord_startdate DATETIME NULL,
	ord_number CHAR(12) NULL,
	ref_number VARCHAR(30) NULL,
	stp_arrivaldate	DATETIME NULL,
	shipper_name VARCHAR(30) NULL,
	shipper_city VARCHAR(18) NULL,
	shipper_state CHAR(2) NULL,
	consignee_name VARCHAR(30) NULL,
	consignee_city VARCHAR(18) NULL,
	consignee_state	CHAR(2) NULL,
	cmd_name VARCHAR(60) NULL,
	pyd_billedweight INT NULL,		--billed weight (BTC)
	adjusted_billed_rate MONEY NULL,		--rate (BTC)
	cht_basis VARCHAR(6) NULL,
	cht_basisunit VARCHAR(6) NULL,
	cht_unit VARCHAR(6) NULL,
	cht_rateunit VARCHAR(6) NULL,
	std_number INT NULL,
	stp_number INT NULL,
	unc_factor FLOAT NULL,
	stp_mfh_sequence INT NULL,
	pyt_description	VARCHAR(30) NULL,
	cht_itemcode VARCHAR(6) NULL,
	userlabelname VARCHAR(20) NULL,
	label_name VARCHAR(20) NULL,
	otherid	VARCHAR(8) NULL,
	pyt_fee1 MONEY NULL,
	pyt_fee2 MONEY NULL,
	start_city VARCHAR(18) NULL,
	start_state	CHAR(2) NULL,
	end_city VARCHAR(18) NULL,
	end_state CHAR(2) NULL,
	lgh_count INT NULL,
	ref_number_tds VARCHAR(30) NULL,
	pyd_offsetpay_number INT NULL,
	pyd_credit_pay_flag	CHAR(1) NULL,
	pyd_refnumtype VARCHAR(6) NULL,
	pyd_refnum VARCHAR(30) NULL,
	pyh_issuedate DATETIME NULL,
	pyt_basis VARCHAR(6) NULL)

--Create a temp table for YTD balances
CREATE TABLE #ytdbal(
	asgn_type VARCHAR (6) NOT NULL,
	asgn_id	VARCHAR (13) NOT NULL,
	ytdcomp	MONEY NULL,
	ytddeduct MONEY NULL,
	ytdreimbrs MONEY NULL,
	pyh_payperiod DATETIME NULL,
	pyh_issuedate DATETIME NULL)

DECLARE @PeriodforYTD VARCHAR(3)

--no-row SELECT below will leave that value untouched..
SELECT	@PeriodForYtd = 'no'

SELECT @PeriodforYTD = ISNULL(gi_string1,'no') 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'

-- elliminate trial AND final settlement sheets - do just one
IF @hld_yes = 'Y' 
BEGIN
	-- Get the driver pay header AND detail numbers for held pay
	IF @drv_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@drv_type1
		FROM paydetail
		WHERE asgn_type = 'DRV'
		AND asgn_id = @drv_id
		AND pyh_number = 0 
		AND pyd_status = 'HLD'
		AND pyd_workperiod BETWEEN @workperiodstart AND @workperiodend

	-- Get the tractor pay header AND detail numbers for held pay
	IF @trc_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
            pyd_status,
			@trc_type1
		FROM paydetail
		WHERE asgn_type = 'TRC'
	  	AND asgn_id = @trc_id
		AND pyh_number = 0
		AND pyd_status = 'HLD'
		AND pyd_workperiod BETWEEN @workperiodstart AND @workperiodend

	-- Get the carrier pay header AND detail numbers for held pay
	IF @car_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
            pyd_status,
			@car_type1
		FROM paydetail
		WHERE asgn_type = 'CAR'
	  	AND asgn_id = @car_id
		AND pyh_number = 0
		AND pyd_status = 'HLD'
		AND pyd_workperiod BETWEEN @workperiodstart AND @workperiodend

	-- Get the trailer pay header AND detail numbers for held pay
	IF @trl_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
           	pyd_status,
			@trl_type1
		FROM paydetail
		WHERE asgn_type = 'TRL'
	  	AND asgn_id = @trl_id
		AND pyh_number = 0
		AND pyd_status = 'HLD'
		AND pyd_workperiod BETWEEN @workperiodstart AND @workperiodend
END

IF @relcol  = 'N' AND @relncol = 'Y' 
BEGIN
	IF @drv_yes <> 'XXX'
		-- Get the driver pay header AND detail numbers for pay released 
		-- to this payperiod, but NOT collected
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@drv_type1
		FROM paydetail
		WHERE asgn_type = 'DRV'
	  	AND asgn_id = @drv_id
	  	AND pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
		AND pyh_number = 0

	-- Get the tractor pay header AND detail numbers for pay released 
	-- to this payperiod, but NOT collected
	IF @trc_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@trc_type1
		FROM paydetail
		WHERE asgn_type = 'TRC'
	  	AND asgn_id = @trc_id
	  	AND pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
		AND pyh_number = 0

	-- Get the carrier pay header AND detail numbers for pay released 
	-- to this payperiod, but NOT collected
	IF @car_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@car_type1
		FROM paydetail
		WHERE asgn_type = 'CAR'
	  	AND asgn_id = @car_id
	  	AND pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
		AND pyh_number = 0

	-- add trailer settlements
	-- Get the trailer pay header AND detail numbers for pay released 
	-- to this payperiod, but NOT collected
	IF @trl_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@trl_type1
		FROM paydetail
		WHERE asgn_type = 'TRL'
	  	AND asgn_id = @trl_id
	  	AND pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
		AND pyh_number = 0
END

IF @relcol  = 'Y' AND @relncol = 'N'
BEGIN
	-- Get the driver pay header AND detail numbers for pay released to this payperiod
	-- AND collected 
	IF @drv_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@drv_type1
		FROM paydetail pd JOIN payheader ph ON (pd.pyh_number = ph.pyh_pyhnumber)
		WHERE ph.asgn_type = 'DRV'
	  	AND ph.pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
	  	AND @drv_id = ph.asgn_id
		-- SELECT paydetails for the given payheader only
		AND pyh_number = @pyhnumber
			
	-- Get the tractor pay header AND detail numbers pay released to this payperiod
	-- AND collected 
	IF @trc_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@trc_type1
		FROM paydetail pd JOIN payheader ph ON (pd.pyh_number = ph.pyh_pyhnumber)
		WHERE ph.asgn_type = 'TRC'
		AND ph.pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
		AND @trc_id = ph.asgn_id
		-- SELECT paydetails for the given payheader only
		AND pyh_number = @pyhnumber
			
	-- Get the carrier pay header AND detail numbers for pay released to this payperiod
	-- AND collected 
	IF @car_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@car_type1
		FROM paydetail pd JOIN payheader ph ON (pd.pyh_number = ph.pyh_pyhnumber)
		WHERE ph.asgn_type = 'CAR'
		AND ph.pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
		AND @car_id = ph.asgn_id
		-- SELECT paydetails for the given payheader only
		AND pyh_number = @pyhnumber
			
	-- Get the trailer pay header AND detail numbers for pay released to this payperiod
	-- AND collected 
	IF @trl_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@trl_type1
		FROM paydetail pd JOIN payheader ph ON (pd.pyh_number = ph.pyh_pyhnumber)
		WHERE ph.asgn_type = 'TRL'
		AND ph.pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
		AND @trl_id = ph.asgn_id
		-- SELECT paydetails for the given payheader only
		AND pyh_number = @pyhnumber
END

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
	pd.pyd_description,
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
	NULL,
	NULL,
	NULL,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	pd.pyd_billedweight,
	0.0,
	NULL,
	NULL,
	NULL,
	NULL,
	pd.std_number,
	NULL,
	1.0,
	NULL,
	NULL,
	pd.cht_itemcode,
	NULL,
	NULL,
	NULL,
    	pd.pyt_fee1,
	pd.pyt_fee2,
	NULL,
	NULL,
	NULL,
	NULL,
	0,
	NULL,
	pyd_offsetpay_number,
	pyd_credit_pay_flag,
	pyd_refnumtype,
	pyd_refnum,
	(SELECT pyh_issuedate FROM payheader WHERE pyh_pyhnumber = pd.pyh_number) pyh_issuedate,
 	NULL -- pyt_basis
FROM paydetail pd JOIN #temp_pay tp ON (pd.pyd_number = tp.pyd_number)

--Update the temp pay details with legheader data
UPDATE #temp_pd
SET lgh_startdate = (SELECT lgh_startdate 
                     FROM legheader lh
                     WHERE lh.lgh_number = #temp_pd.lgh_number)

-- Update the temp with number of legheaders for the move
-- actually, just find if there was another legheader ON the move
UPDATE #temp_pd
SET lgh_count = (SELECT COUNT(lgh_number) 
                 FROM legheader lh 
                 WHERE lh.mov_number = #temp_pd.mov_number)

--Update the temp pay details with orderheader data
UPDATE #temp_pd
SET ord_startdate = oh.ord_startdate,
    ord_number = oh.ord_number
FROM #temp_pd tp JOIN orderheader oh ON (tp.ord_hdrnumber = oh.ord_hdrnumber)

--Update the temp, for split trips, set ord_number = ord_number + '/S'
UPDATE #temp_pd
SET ord_number = ord_number + '/S'
WHERE ord_hdrnumber > 0 
AND lgh_count > 1

UPDATE #temp_pd
SET shipper_city = ct.cty_name,
	shipper_state = ct.cty_state
FROM #temp_pd tp JOIN orderheader oh ON (tp.ord_hdrnumber = oh.ord_hdrnumber) 
	JOIN city ct ON (oh.ord_origincity = ct.cty_code)  
 
UPDATE #temp_pd
SET consignee_city = ct.cty_name,
	consignee_state = ct.cty_state
FROM #temp_pd tp JOIN orderheader oh ON (tp.ord_hdrnumber = oh.ord_hdrnumber) 
	JOIN city ct ON (oh.ord_destcity = ct.cty_code) 

UPDATE #temp_pd
SET shipper_name = co.cmp_name 
FROM #temp_pd tp JOIN orderheader oh ON (tp.ord_hdrnumber = oh.ord_hdrnumber) 
	JOIN company co ON (oh.ord_shipper = co.cmp_id)

UPDATE #temp_pd
SET consignee_name = co.cmp_name
FROM #temp_pd tp JOIN orderheader oh ON (tp.ord_hdrnumber = oh.ord_hdrnumber) 
	JOIN company co ON (oh.ord_consignee = co.cmp_id)

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

--trying to reduce I/O by using a nested SELECT
--Update the temp pay details with payheader data
UPDATE #temp_pd
SET crd_cardnumber = (SELECT ph.crd_cardnumber 
                      FROM payheader ph
                      WHERE ph.pyh_pyhnumber = #temp_pd.pyh_number)

--Need to get the stop of the 1st delivery AND find the commodity AND arrival date
--associated with it.
--Update the temp pay details table with stop data for the 1st unload stop
UPDATE #temp_pd
SET stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                        FROM stops st
                        WHERE st.mov_number = #temp_pd.mov_number 
                        AND stp_event IN ('DRL', 'LUL', 'DUL', 'PUL')) 

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
                FROM freightdetail fd JOIN commodity cd ON (fd.cmd_code = cd.cmd_code)
                WHERE fd.stp_number = #temp_pd.stp_number) 
                      
--Need to get the bill-of-lading FROM the reference number table
--Update the temp pay details with reference number data
UPDATE #temp_pd
SET ref_number = (SELECT MIN(ref_number) 
                  FROM referencenumber 
                  WHERE ref_tablekey = #temp_pd.ord_hdrnumber
                  AND ref_table = 'orderheader'
                  AND ref_type = 'SID')

-- Could this be written to reduce I/O, I'm NOT sure breaking it up will help
--Need to get revenue charge type data FROM the chargetype table
UPDATE #temp_pd
SET cht_basis = ct.cht_basis,
    cht_basisunit = ct.cht_basisunit,
    cht_unit = ct.cht_unit,
    cht_rateunit = ct.cht_rateunit
FROM #temp_pd tp JOIN chargetype ct ON (tp.cht_itemcode = ct.cht_itemcode)

UPDATE #temp_pd 
SET unc_factor = uc.unc_factor
FROM #temp_pd tp JOIN unitconversion uc ON (uc.unc_from = tp.cht_basisunit AND uc.unc_to = tp.cht_rateunit) 
WHERE uc.unc_convflag = 'R'

UPDATE #temp_pd
SET adjusted_billed_rate = ROUND(pyd_payrevenue / pyd_billedweight / unc_factor, 2)
WHERE pyd_billedweight > 0
AND unc_factor > 0
AND pyd_payrevenue > 0

--Insert into the temp YTD balances table the assets FROM the temp pay details table
INSERT INTO #ytdbal
SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
FROM #temp_pd

--Compute the YTD balances for each assets
--fixed NULL problem SR 7095
IF LEFT(LTRIM(@PeriodforYTD),1) = 'Y' 
BEGIN
UPDATE #ytdbal
SET	ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
					  FROM payheader ph
					  WHERE ph.asgn_id = yb.asgn_id
					  AND ph.asgn_type = yb.asgn_type
                      AND ph.pyh_payperiod >= '01/01/' + DATENAME(yy, @payperiodend)
                      AND ph.pyh_payperiod < @payperiodend
                      AND ph.pyh_paystatus <> 'HLD'), 0),
    ytddeduct = ISNULL((SELECT SUM(ROUND(ph.pyh_totaldeduct, 2))
                   		FROM payheader ph
                  		WHERE ph.asgn_id = yb.asgn_id
                       	AND ph.asgn_type = yb.asgn_type
                        AND ph.pyh_payperiod >= '01/01/' + DATENAME(yy, @payperiodend)
                       	AND ph.pyh_payperiod < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0),
    ytdreimbrs = ISNULL((SELECT SUM(ROUND(ph.pyh_totalreimbrs, 2))
                   		 FROM payheader ph
                  		 WHERE ph.asgn_id = yb.asgn_id
                         AND ph.asgn_type = yb.asgn_type
                         AND ph.pyh_payperiod >= '01/01/' + DATENAME(yy, @payperiodend)
                         AND ph.pyh_payperiod < @payperiodend
                         AND ph.pyh_paystatus <> 'HLD'), 0)
FROM #ytdbal yb
END
 
ELSE 
BEGIN
UPDATE #ytdbal
SET	ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
					  FROM payheader ph
	          		  WHERE ph.asgn_id = yb.asgn_id
	                  AND ph.asgn_type = yb.asgn_type
	                  AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + DATENAME(yy, ISNULL(yb.pyh_issuedate,yb.pyh_payperiod))
	                  AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) <= ISNULL(yb.pyh_issuedate,yb.pyh_payperiod)
	                  AND ph.pyh_paystatus <> 'HLD'), 0),
	ytddeduct = ISNULL((SELECT SUM(ROUND(ph.pyh_totaldeduct, 2))
	           			FROM payheader ph
	          			WHERE ph.asgn_id = yb.asgn_id
	               		AND ph.asgn_type = yb.asgn_type
	                	AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + DATENAME(yy, ISNULL(yb.pyh_issuedate,yb.pyh_payperiod))
	                	AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) <= ISNULL(yb.pyh_issuedate,yb.pyh_payperiod)
	                	AND ph.pyh_paystatus <> 'HLD'), 0),
	ytdreimbrs = ISNULL((SELECT SUM(ROUND(ph.pyh_totalreimbrs, 2))
	           			 FROM payheader ph
	          			 WHERE ph.asgn_id = yb.asgn_id
	                	 AND ph.asgn_type = yb.asgn_type
	                	 AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + DATENAME(yy, ISNULL(yb.pyh_issuedate,yb.pyh_payperiod))
	                	 AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) <= ISNULL(yb.pyh_issuedate,yb.pyh_payperiod)
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
FROM #ytdbal yb

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
FROM #ytdbal yb

UPDATE 	#temp_pd
SET pyh_totalcomp = yb.ytdcomp,
    pyh_totaldeduct = yb.ytddeduct,
    pyh_totalreimbrs = yb.ytdreimbrs
FROM #ytdbal yb JOIN #temp_pd tp ON (tp.asgn_type = yb.asgn_type AND tp.asgn_id = yb.asgn_id) 
WHERE --is a very unlikely date value which is used to compare NULL 
	  --to NULL..
ISNULL(tp.pyh_issuedate, '1950-02-02') = ISNULL(yb.pyh_issuedate, '1950-02-02')
AND ISNULL(tp.pyh_payperiod, '1950-02-02') = ISNULL(yb.pyh_payperiod, '1950-02-02')

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
WHERE pyt_itemcode = 'MN+'
OR pyt_itemcode = 'MN-'

--Update the temp pay details with labelfile data AND drv alt id
UPDATE #temp_pd
SET userlabelname = l.userlabelname,
    label_name = l.name,
    otherid = m.mpp_otherid
FROM #temp_pd tp JOIN manpowerprofile m ON (m.mpp_id = tp.asgn_id) 
	JOIN labelfile l ON (m.mpp_type1 = l.abbr) 
WHERE l.labeldefinition = 'DrvType1'

--Update the temp pay details with start/end city/state data 
UPDATE #temp_pd
SET start_city = ct.cty_name, 
    start_state = ct.cty_state
FROM #temp_pd tp JOIN city ct ON (ct.cty_code = tp.lgh_startcity)

UPDATE #temp_pd
SET end_city = ct.cty_name,
    end_state = ct.cty_state
FROM #temp_pd tp JOIN city ct ON (ct.cty_code = tp.lgh_endcity)

--Update the temp pay details with TDS ref# for CryOgenics 
UPDATE #temp_pd
SET ref_number_tds = r.ref_number
FROM #temp_pd tp JOIN orderheader o ON (o.ord_hdrnumber = tp.ord_hdrnumber) 
	JOIN referencenumber r ON (r.ref_type = o.ord_reftype AND r.ref_tablekey = tp.ord_hdrnumber) 
	JOIN labelfile l ON (l.abbr = r.ref_type) 
WHERE r.ref_table = 'orderheader' 
AND l.labeldefinition = 'ReferenceNumbers' 
AND r.ref_type = 'TRIP' 

UPDATE #temp_pd
SET pyt_basis = p.pyt_basis 
FROM #temp_pd tp JOIN paytype p ON (tp.pyt_itemcode = p.pyt_itemcode)

--delete fake routing paydetails
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'StlFindNextMTLeg' AND gi_string1 = 'Y')
	DELETE #temp_pd FROM paydetail WHERE #temp_pd.pyd_number = paydetail.pyd_number AND paydetail.tar_tarriffnumber = '-1'

SELECT pyd_number, 
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
	ROUND(pyd_amount, 2),
	pyd_payrevenue,
	mov_number,
	lgh_number,
	ord_hdrnumber,
	pyd_transdate,
	payperiodstart,
	payperiodend,
	pyd_loadstate,
	summary_code,
	name,
	terminal,
	type1,
	ROUND(tp.pyh_totalcomp, 2),
	ROUND(tp.pyh_totaldeduct, 2),
	ROUND(tp.pyh_totalreimbrs, 2),
	ph.crd_cardnumber 'crd_cardnumber',
	lgh_startdate,
	std_balance,
	itemsection,
	ord_startdate,
	ord_number,
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
	pyt_basis
FROM #temp_pd tp LEFT OUTER JOIN payheader ph ON (tp.pyh_number = ph.pyh_pyhnumber) 

GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_summary_57] TO [public]
GO
