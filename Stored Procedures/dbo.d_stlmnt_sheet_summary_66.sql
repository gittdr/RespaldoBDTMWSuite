SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROC [dbo].[d_stlmnt_sheet_summary_66](
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
 * dbo.d_stlmnt_sheet_summary_66
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Return data for settlemetn sheet 66
 * 
 * RETURNS:
 * na
 * 
 * RESULT SETS: 
 * see retrun SET
 *
 * PARAMETERS:
 * 001 - @report_type varchar(5),
 * 002 - @payperiodstart datetime,
 * 003 - @payperiodend datetime,
 * 004 - @drv_yes varchar(3),
 * 005 - @trc_yes varchar(3),
 * 006 - @trl_yes varchar(3),
 * 007 - @drv_id varchar(8),
 * 008 - @trc_id varchar(8),
 * 009 - @trl_id varchar(13),
 * 010 - @drv_type1 varchar(6),
 * 011 - @trc_type1 varchar(6),
 * 012 - @trl_type1 varchar(6),
 * 013 - @terminal varchar(8),
 * 014 - @name varchar(64),
 * 015 - @car_yes varchar(3),
 * 016 - @car_id varchar(8),
 * 017 - @car_type1 varchar(6),
 * 018 - @hld_yes varchar(3),	
 * 019 - @pyhnumber int,
 * 020 - @relcol varchar(3),
 * 021 - @relncol varchar(3),
 * 022 - @workperiodstart datetime,
 * 023 - @workperiodend datetime
 *
 * REVISION HISTORY:
 * 01/15/2007.01 PTS34011 - OS - Created stored proc as modification of proc for  d_stlmnt_det_report_general
 *
 **/

-- Create a temp table to the pay header and detail numbers
CREATE TABLE #temp_pay(
	pyd_number INT NOT NULL,
	pyh_number INT NOT NULL,
	pyd_status VARCHAR(6) NULL,
	asgn_type1 VARCHAR(6) NULL)

-- Create a temp table to hold the pay header and detail numbers
-- Create a temp table to hold the pay details
CREATE TABLE #temp_pd(
	pyd_number INT NOT NULL,
	pyh_number INT NOT NULL,
	asgn_number INT NULL,
	asgn_type VARCHAR(6) NOT NULL,
	asgn_id VARCHAR(13) NOT NULL,
	ivd_number INT NULL,
	pyd_prorap VARCHAR(6) NULL, 
	pyd_payto VARCHAR(12)NULL, 
	payto_fullname VARCHAR(41) NULL,  
	payto_address1 VARCHAR(30) NULL,  
	payto_citystate VARCHAR(25) NULL, 
	payto_zip VARCHAR(25) NULL, 
	pyt_itemcode VARCHAR(6) NULL, 
	pyd_description VARCHAR(30) NULL, 
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
	std_balance money NULL,
	itemsection INT NULL,
	ord_startdate DATETIME NULL,
	ord_number CHAR(12) NULL,
	ref_number VARCHAR(30) NULL,
	stp_arrivaldate DATETIME NULL,
	shipper_name VARCHAR(30) NULL,
	shipper_city VARCHAR(18) NULL,
	shipper_state CHAR(2) NULL,
	consignee_name VARCHAR(30) NULL,
	consignee_city VARCHAR(18) NULL,
	consignee_state CHAR(2) NULL,
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
	pyt_description VARCHAR(100) NULL,
	cht_itemcode VARCHAR(6) NULL,
	userlabelname VARCHAR(20) NULL,
	label_name VARCHAR(20) NULL,
	otherid VARCHAR(8) NULL,
	pyt_fee1 MONEY NULL,
	pyt_fee2 MONEY NULL,
	start_city VARCHAR(18) NULL,
	start_state CHAR(2) NULL,
	end_city VARCHAR(18) NULL,
	end_state CHAR(2) NULL,
	lgh_count INT NULL,
	ref_number_tds VARCHAR(30) NULL,
	pyd_offsetpay_number INT NULL,
	pyd_credit_pay_flag	CHAR(1) NULL,
	pyd_refnumtype VARCHAR(6) NULL,
	pyd_refnum VARCHAR(30) NULL,
	pyh_issuedate DATETIME NULL,
	first_check_issue VARCHAR(10) NULL,	--PTS 20747  first check issuance for this year
	last_check_issue VARCHAR(10) NULL,	--PTS 20747  last check issuance date for the resource
	num_weeks INT NULL,		--PTS 20747  number of weeks between first and last
	average_pay MONEY NULL,		--PTS 20747  total for the year / num_weeks
	escrow_balance MONEY NULL,		--PTS 20747  balance for deduction chargetype 'ESC'
	ytd_escrow_interest	MONEY NULL,		--PTS 20747  balance * intrest on the paytype
	company_name VARCHAR(40) NULL,	--PTS 20747  Company name based on tractor company
	custom_ytd_payments MONEY NULL,		--PTS 21838  Linden's logic for payments is the sum of all paydetails
	plates_balance MONEY NULL)						

--Create a temp table for YTD balances
CREATE TABLE #ytdbal(
	asgn_type VARCHAR (6) NOT NULL,
	asgn_id VARCHAR (13) NOT NULL,
	ytdcomp MONEY NULL,
	ytddeduct MONEY NULL,
	ytdreimbrs MONEY NULL,
	pyh_payperiod DATETIME NULL,
	pyh_issuedate DATETIME NULL)

DECLARE @PeriodforYTD Varchar(3)
SELECT	@PeriodForYtd = 'no'

SELECT @PeriodforYTD = ISNULL(gi_string1,'no') 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'

-- elliminate trial and final settlement sheets - do just one
IF @hld_yes = 'Y' 

IF @relcol  = 'N' and @relncol = 'Y' 
BEGIN
	IF @drv_yes != 'XXX'
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
	  	AND pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
		AND pyh_number = 0

	-- Get the tractor pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @trc_yes != 'XXX'
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

	-- Get the carrier pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @car_yes != 'XXX'
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
	-- Get the trailer pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @trl_yes != 'XXX'
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

IF @relcol  = 'Y' and @relncol = 'N'
BEGIN
	-- Get the driver pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @drv_yes != 'XXX'
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

	-- Get the tractor pay header and detail numbers pay released to this payperiod
	-- and collected 
	IF @trc_yes != 'XXX'
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
		
	-- Get the carrier pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @car_yes != 'XXX'
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
		
	-- Get the trailer pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @trl_yes != 'XXX'
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
	CASE ISNULL(LTRIM(RTRIM(pto_fname)),'') + ISNULL(LTRIM(RTRIM(pto_lname)),'')
		WHEN '' THEN pto_companyname
		ELSE ISNULL(LTRIM(RTRIM(pto_fname)),'') + ' ' + ISNULL(LTRIM(RTRIM(pto_lname)),'')
	END ,
	payto.pto_address1, 
	(LEFT(city.cty_nmstct,LEN(city.cty_nmstct)-1)) 'city.cty_nmstct',    
	payto.pto_zip,     
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
	pd.pyd_description,
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
	NULL,
	NULL,
	NULL,
	NULL,
	0,
	0,
	NULL,
	NULL,
	0
 FROM paydetail pd 
	JOIN #temp_pay tp ON (pd.pyd_number = tp.pyd_number) 
	JOIN payto ON (payto.pto_id = pd.pyd_payto) JOIN city ON (payto.pto_city = city.cty_code)

--calculate the first and last payperiod for the current year
UPDATE #temp_pd 
SET first_check_issue = (SELECT CONVERT(varchar(10),ISNULL(MIN(payheader.pyh_issuedate),''),101) 
						 FROM payheader 
							JOIN #temp_pd ON (#temp_pd.asgn_id = payheader.asgn_id) 
						 WHERE payheader.pyh_issuedate IS NOT NULL 
						 AND payheader.pyh_issuedate > (SELECT CONVERT(DATETIME,'12/31/' + CONVERT(CHAR(4),DATEPART(yy,GETDATE()) - 1)))),
	last_check_issue = (SELECT CONVERT(varchar(10),ISNULL(MAX(payheader.pyh_issuedate),''),101) 
						FROM payheader 
							JOIN #temp_pd ON (#temp_pd.asgn_id = payheader.asgn_id) 
						WHERE payheader.pyh_issuedate IS NOT NULL 
						AND payheader.pyh_issuedate < (SELECT CONVERT(DATETIME,'12/31/' + CONVERT(CHAR(4),DATEPART(yy,GETDATE()))))
						AND payheader.pyh_issuedate > (SELECT CONVERT(DATETIME,'12/31/' + CONVERT(char(4),DATEPART(yy,GETDATE())-1))))

--generate the company name based on the tractor's company
UPDATE #temp_pd
SET company_name = 'Pinnacle'

UPDATE #temp_pd 
SET escrow_balance = (SELECT ABS(sd.std_balance)
                      FROM standingdeduction sd
                      WHERE sd.asgn_id = (SELECT DISTINCT (asgn_id) FROM #temp_pd)
                      AND sd.sdm_itemcode = 'BOND'
                      AND sd.std_status NOT IN ( 'CLD','CAN'))

UPDATE #temp_pd
SET plates_balance = (SELECT ABS(sd.std_balance)
		      FROM standingdeduction sd
		      WHERE sd.asgn_id = (SELECT DISTINCT (asgn_id) FROM #temp_pd)
		      AND sd.sdm_itemcode = 'PLATES'
		      AND sd.std_status NOT IN ('CLD','CAN'))

--UPDATE the temp table for output if the first or last check issue date does not apply
UPDATE #temp_pd
SET first_check_issue = 'N/A' 
WHERE first_check_issue = '01/01/1900'
UPDATE #temp_pd
SET last_check_issue = 'N/A' 
WHERE last_check_issue = '01/01/1900'

UPDATE #temp_pd 
SET num_weeks = (SELECT COUNT(DISTINCT pyh_pyhnumber)
				 FROM payheader
				 WHERE pyh_issuedate >= (SELECT CONVERT(DATETIME,'01/01/'+CONVERT(varchar(4),DATEPART(yy,GETDATE()))))
				 AND asgn_id = (SELECT MAX(asgn_id) FROM #temp_pd)
				 AND asgn_type = (SELECT MAX(asgn_type) FROM #temp_pd)
				 AND ISNULL(pyh_totalcomp, 0) <> 0)

--concatenate fuel descritpions with qty and rate for fuel purchases
UPDATE #temp_pd
SET pyt_description = pyd_description + ' ' + CONVERT(varchar(20),pyd_quantity) + ' ' + 'gal @ ' + CONVERT(varchar(20),pyd_rate)
WHERE pyt_itemcode = 'FULTRC'

UPDATE #temp_pd
SET pyt_description = (SELECT pyt_description 
					   FROM paytype 
					   WHERE #temp_pd.pyt_itemcode = paytype.pyt_itemcode)
WHERE pyt_itemcode != 'FULTRC'
AND ISNULL(pyt_description, '') = ''

--now calculate interest on the escrow account
UPDATE #temp_pd
SET ytd_escrow_interest = (SELECT ABS(SUM (pyd_amount))
  						   FROM paydetail 
  						   WHERE pyt_itemcode = 'IT+'
  						   AND asgn_id = (SELECT DISTINCT(asgn_id) FROM #temp_pd)
  						   AND pyd_minus = 1
  						   AND pyh_payperiod BETWEEN
  								(SELECT CONVERT(DATETIME,'01/01/' + CONVERT(varchar(4),(DATEPART(yy,GETDATE())))))
  								and 
  								(SELECT DATEADD(mi,-1,CONVERT(DATETIME,'01/01/' + CONVERT(varchar(4),(DATEPART(yy,GETDATE())+1))))))

--now if the escrow amounts are still NULL UPDATE to 0  did not use ISNULL because if there are no records returned it will still be NULL this will catch all scenerios
UPDATE #temp_pd
SET escrow_balance = 0
WHERE escrow_balance IS NULL

UPDATE #temp_pd
SET plates_balance = 0
WHERE plates_balance IS NULL

UPDATE #temp_pd
SET ytd_escrow_interest = 0
WHERE ytd_escrow_interest IS NULL

--UPDATE the temp pay details with legheader data
UPDATE #temp_pd
SET lgh_startdate = (SELECT lgh_startdate 
                     FROM legheader lh
                     WHERE lh.lgh_number = #temp_pd.lgh_number)

-- UPDATE the temp with number of legheaders for the move
-- actually, just find if there was another legheader on the move
UPDATE #temp_pd
SET lgh_count = (SELECT COUNT(lgh_number) 
                 FROM legheader lh 
                 WHERE lh.mov_number = #temp_pd.mov_number)

--UPDATE the temp pay details with orderheader data
UPDATE #temp_pd
SET ord_startdate = oh.ord_startdate,
	ord_number = oh.ord_number
FROM #temp_pd tp 
	JOIN orderheader oh ON (tp.ord_hdrnumber = oh.ord_hdrnumber)

--UPDATE the temp, for split trips, SET ord_number = ord_number + '/S'
UPDATE #temp_pd
SET ord_number = ord_number + '/S'
WHERE ord_hdrnumber > 0 
       AND lgh_count > 1 

UPDATE #temp_pd
SET shipper_city = ct.cty_name,
	shipper_state = ct.cty_state
FROM #temp_pd tp 
	JOIN orderheader oh ON (tp.ord_hdrnumber = oh.ord_hdrnumber) 
	JOIN city ct ON (oh.ord_origincity = ct.cty_code) 

UPDATE #temp_pd
SET consignee_city = ct.cty_name,
	consignee_state = ct.cty_state
FROM #temp_pd tp 
	JOIN orderheader oh ON (tp.ord_hdrnumber = oh.ord_hdrnumber) 
	JOIN city ct ON (oh.ord_destcity = ct.cty_code) 

UPDATE #temp_pd
SET shipper_name = co.cmp_name 
FROM #temp_pd tp 
	JOIN orderheader oh ON (tp.ord_hdrnumber = oh.ord_hdrnumber) 
	JOIN company co ON (oh.ord_shipper = co.cmp_id)

UPDATE #temp_pd
SET consignee_name = co.cmp_name
FROM #temp_pd tp 
	JOIN orderheader oh ON (tp.ord_hdrnumber = oh.ord_hdrnumber) 
	JOIN company co ON (oh.ord_consignee = co.cmp_id)

--UPDATE the temp pay details with standingdeduction data
UPDATE #temp_pd
SET std_balance = (SELECT std_balance 
                   FROM standingdeduction sd 
                   WHERE sd.std_number = #temp_pd.std_number)

--UPDATE the temp pay details for summary code
UPDATE #temp_pd
SET summary_code = 'OTHER'
WHERE summary_code != 'MIL'

--UPDATE the temp pay details for load status
UPDATE #temp_pd
SET pyd_loadstate = 'NA'
WHERE pyd_loadstate IS NULL

--trying to reduce I/O by using a nested SELECT
--UPDATE the temp pay details with payheader data
UPDATE #temp_pd
SET crd_cardnumber = (SELECT ph.crd_cardnumber 
                      FROM payheader ph
                      WHERE ph.pyh_pyhnumber = #temp_pd.pyh_number)

--Need to get the stop of the 1st delivery and find the commodity and arrival date
--associated with it.
--UPDATE the temp pay details table with stop data for the 1st unload stop
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

-- UPDATE for stop arrivaldate
UPDATE #temp_pd
SET stp_arrivaldate = (SELECT stp_arrivaldate
                       FROM stops st
                       WHERE st.stp_number = #temp_pd.stp_number)

--UPDATE the temp pay details with commodity data
UPDATE #temp_pd
SET cmd_name = (SELECT MIN(cmd_name) 
                FROM freightdetail fd 
					JOIN commodity cd ON (fd.cmd_code = cd.cmd_code)
                WHERE fd.stp_number = #temp_pd.stp_number) 
                  
--Need to get the bill-of-lading FROM the reference number table
--UPDATE the temp pay details with reference number data
UPDATE #temp_pd
SET ref_number = (SELECT MIN(ref_number) 
                  FROM referencenumber 
                  WHERE ref_tablekey = #temp_pd.ord_hdrnumber
                  AND ref_table = 'orderheader'
                  AND ref_type = 'SID')

-- Could this be written to reduce I/O, I'm not sure breaking it up will help
--Need to get revenue charge type data FROM the chargetype table
UPDATE #temp_pd
SET cht_basis = ct.cht_basis,
	cht_basisunit = ct.cht_basisunit,
    cht_unit = ct.cht_unit,
    cht_rateunit = ct.cht_rateunit
FROM #temp_pd tp 
	JOIN chargetype ct ON (tp.cht_itemcode = ct.cht_itemcode)

UPDATE #temp_pd 
SET unc_factor = uc.unc_factor
FROM #temp_pd tp 
	JOIN unitconversion uc ON (uc.unc_from = tp.cht_basisunit AND uc.unc_to = tp.cht_rateunit)
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
   FROM  #ytdbal yb
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
SET pyh_totalcomp = yb.ytdcomp,
    pyh_totaldeduct = yb.ytddeduct,
    pyh_totalreimbrs = yb.ytdreimbrs
FROM #ytdbal yb 
	JOIN #temp_pd tp ON (tp.asgn_type = yb.asgn_type AND tp.asgn_id = yb.asgn_id)
WHERE ISNULL(tp.pyh_issuedate, '1950-02-02') = ISNULL(yb.pyh_issuedate, '1950-02-02')
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

--UPDATE the temp pay details with labelfile data and drv alt id
UPDATE #temp_pd
SET userlabelname = l.userlabelname,
	label_name = l.name,
	otherid = m.mpp_otherid
FROM #temp_pd tp 
	JOIN manpowerprofile m ON (m.mpp_id = tp.asgn_id) 
	JOIN labelfile l ON (m.mpp_type1 = l.abbr) 
WHERE l.labeldefinition = 'DrvType1'

--UPDATE the temp pay details with start/end city/state data 
UPDATE #temp_pd
SET start_city = ct.cty_name, 
	start_state = ct.cty_state
FROM #temp_pd tp 
	JOIN city ct ON (ct.cty_code = tp.lgh_startcity)

UPDATE #temp_pd
SET end_city = ct.cty_name,
	end_state = ct.cty_state
FROM #temp_pd tp 
	JOIN city ct ON (ct.cty_code = tp.lgh_endcity)

--UPDATE the temp pay details with TDS ref# for CryOgenics 
UPDATE #temp_pd
SET ref_number_tds = r.ref_number
FROM #temp_pd tp 
	JOIN orderheader o ON (o.ord_hdrnumber = tp.ord_hdrnumber) 
	JOIN referencenumber r ON (r.ref_tablekey = tp.ord_hdrnumber AND r.ref_type = o.ord_reftype) 
	JOIN labelfile l ON (l.abbr = r.ref_type)
WHERE r.ref_table = 'orderheader'
AND l.labeldefinition = 'ReferenceNumbers' 
AND r.ref_type = 'TRIP' 	

--delete fake routing paydetails
IF EXISTS (SELECT * FROM generalinfo WHERE gi_name = 'StlFindNextMTLeg' AND gi_string1 = 'Y')
	DELETE #temp_pd 
	FROM paydetail 
	WHERE #temp_pd.pyd_number = paydetail.pyd_number 
	AND paydetail.tar_tarriffnumber = '-1'

--YTD payments for Linden is sum of all paydetails WHERE the pyd_minus = 1 and the tax/pretax is SET to yes
UPDATE #temp_pd
SET custom_ytd_payments = (SELECT ISNULL(SUM(ROUND(pd.pyd_amount,2)),0)
						   FROM paydetail pd JOIN payheader ph ON (ph.pyh_pyhnumber = pd.pyh_number)
						   WHERE pd.asgn_type = (SELECT MAX (asgn_type) FROM #temp_pd)
						   AND pd.asgn_id = (SELECT MAX (asgn_id) FROM #temp_pd)
						   AND pd.pyd_status <> 'HLD'
						   AND pd.pyd_minus = 1
						   AND pd.pyd_pretax = 'Y'
						   AND ph.pyh_issuedate >= (SELECT CONVERT(DATETIME,'01/01/' + CONVERT(VARCHAR(4),DATEPART(yy,GETDATE())))))
					
--UPDATE the temp table with the calculated average weekly pay as long as the number of weeks is not 0
IF (SELECT MAX(num_weeks) FROM #temp_pd) > 0
	UPDATE #temp_pd
	SET average_pay = custom_ytd_payments / num_weeks
ELSE
	UPDATE #temp_pd
	SET average_pay = 0

SELECT pyd_number, 
	pyh_number, 
	asgn_number, 
	tp.asgn_type, 
	tp.asgn_id, 
	ivd_number, 
	pyd_prorap, 
	pyd_payto,
	payto_fullname,
	payto_address1,
	payto_citystate,
	payto_zip = '  ' + payto_zip,
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
	ROUND(pyd_amount, 2) AS pyd_amount,
	pyd_payrevenue,
	mov_number,
	lgh_number,
	ord_hdrnumber,
	pyd_transdate = CASE 	
		WHEN PYD_TRANSDATE < '20010101' THEN TP.pyh_payperiod
   		WHEN PYD_TRANSDATE > TP.pyh_payperiod THEN  TP.pyh_payperiod
   		ELSE PYD_TRANSDATE 
	END,
	payperiodstart,
	payperiodend,
	pyd_loadstate,
	summary_code,
	name,
	terminal,
	type1,
	ROUND(tp.pyh_totalcomp, 2) 'pyh_totalcomp',
	ROUND(tp.pyh_totaldeduct, 2) 'pyh_totaldeduct',
	ROUND(tp.pyh_totalreimbrs, 2) 'pyh_totalreimbrs',
	ph.crd_cardnumber 'crd_cardnumber',
	lgh_startdate,
	std_balance,
	itemsection,
	ord_startdate,
	ord_number = CASE 
		WHEN ord_number IS NULL 
		AND CHARINDEX('[', ISNULL(pyt_description,'') ) > 0 
		AND CHARINDEX(']', ISNULL(pyt_description,'') ) > 0 
		THEN SUBSTRING(ISNULL(pyt_description,''), CHARINDEX('[', ISNULL(pyt_description,'') ) + 1, (CHARINDEX(']', ISNULL(pyt_description,'') ) - CHARINDEX('[', ISNULL(pyt_description,'') ) - 1)) 
		ELSE ord_number 
	END,
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
	pyt_description = CASE 
		WHEN (pyt_description LIKE '%(Less Fee)%' AND pyt_description LIKE 'com%' ) THEN LEFT(pyt_description, 18) 
		WHEN (pyt_description LIKE '%(Less Fee)%' AND pyt_description LIKE 'gas%' ) THEN LEFT(pyt_description, 17) 
		ELSE pyt_description 
	END,
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
	tp.pyh_issuedate,
	ISNULL(first_check_issue,tp.pyh_issuedate) AS 'first_issue_date',
	ISNULL(last_check_issue,tp.pyh_issuedate) AS 'last_issue_date',
	num_weeks,
	average_pay,
	escrow_balance,
	ytd_escrow_interest,
	company_name,
	custom_ytd_payments,
	plates_balance
FROM #temp_pd tp 
	LEFT OUTER JOIN payheader ph ON (tp.pyh_number = ph.pyh_pyhnumber)
ORDER BY pyd_minus DESC, pyd_transdate

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_sheet_summary_66] TO [public]
GO
