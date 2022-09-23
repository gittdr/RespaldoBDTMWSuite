SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/* MODIFICATION LOG

DPETE PTS 16764 Fix YTD totals 

*/
/****** Object:  Stored Procedure dbo.d_stlmnt_sheet_summary_03    Script Date: 6/24/98 10:17:22 AM ******/
CREATE PROC [dbo].[d_stlmnt_sheet_summary_03](
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
	@hld_yes varchar(3),	-- Not used
	@pyhnumber int,
	@tpr_yes varchar(3),
	@tpr_id	varchar(8))
AS
/**
 * 
 * NAME:
 * dbo.d_stlmnt_sheet_summary_03
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

-- Determine custom options
DECLARE @gi_string1 varchar(60)

SELECT @gi_string1 = gi_string1 
FROM generalinfo
WHERE gi_name = 'STLTRIALSHT'

-- jyang pts13004
Declare @PeriodforYTD Varchar(3)

--SELECT @PeriodforYTD = isnull(gi_string1,'no')  
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

IF @report_type = 'TRIAL'
BEGIN
	-- Get the driver pay header and detail numbers that we want
	IF @drv_yes != 'XXX'
	BEGIN
		-- Get any computed pay
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			'DRV',
			@drv_type1
		FROM paydetail
		WHERE asgn_type = 'DRV'
	  	AND asgn_id = @drv_id
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		-- LOR	select paydetails for the given payheader only
		AND pyh_number = @pyhnumber
		-- LOR

		-- Get any held pay
/* DSK PTS# 3682 DON'T KNOW WHAT STERLING WAS THINKING HERE. COMMENT OUT THE 'TRANSDATE' STUFF */
/*		IF @gi_string1 = 'TRANSDATE'
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				@drv_type1
			FROM paydetail
			WHERE asgn_type = 'DRV'
	  		AND asgn_id = @drv_id
	  		AND pyd_transdate BETWEEN @payperiodstart and @payperiodend
		ELSE		
*/
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				@drv_type1
			FROM paydetail
			WHERE asgn_type = 'DRV'
	  		AND asgn_id = @drv_id
	  		AND pyh_payperiod > @payperiodend
			AND (pyd_workperiod <= @payperiodstart
			OR pyd_workperiod >= '20491231')
	END
	-- Get the tractor pay header and detail numbers that we want
	IF @trc_yes != 'XXX'
	BEGIN
		-- Get any computed pay
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@trc_type1
		FROM paydetail
		WHERE asgn_type = 'TRC'
	  	AND asgn_id = @trc_id
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		-- LOR	select paydetails for the given payheader only
		AND pyh_number = @pyhnumber
		-- LOR

		-- Get any held pay
/* DSK PTS# 3682 DON'T KNOW WHAT STERLING WAS THINKING HERE. COMMENT OUT THE 'TRANSDATE' STUFF */
/*		IF @gi_string1 = 'TRANSDATE'
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				@trc_type1
			FROM paydetail
			WHERE asgn_type = 'TRC'
	  		AND asgn_id = @trc_id
	  		AND pyd_transdate BETWEEN @payperiodstart and @payperiodend
			AND pyd_status = 'HLD'
		ELSE
*/
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				@trc_type1
			FROM paydetail
			WHERE asgn_type = 'TRC'
	  		AND asgn_id = @trc_id
	  		AND pyh_payperiod > @payperiodend
			AND (pyd_workperiod <= @payperiodstart
			OR pyd_workperiod >= '20491231')
	END
	-- Get the carrier pay header and detail numbers that we want
	IF @car_yes != 'XXX'
	BEGIN
		-- Get any computed pay
		INSERT INTO #temp_pay
		SELECT pyd_number,

			pyh_number,
			pyd_status,
			@car_type1
		FROM paydetail
		WHERE asgn_type = 'CAR'
	  	AND asgn_id = @car_id
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		-- LOR	select paydetails for the given payheader only
		AND pyh_number = @pyhnumber
		-- LOR

		-- Get any held pay
/* DSK PTS# 3682 DON'T KNOW WHAT STERLING WAS THINKING HERE. COMMENT OUT THE 'TRANSDATE' STUFF */
/*		IF @gi_string1 = 'TRANSDATE'
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				@car_type1
			FROM paydetail
			WHERE asgn_type = 'CAR'
	  		AND asgn_id = @car_id
			AND pyd_transdate BETWEEN @payperiodstart and @payperiodend
		ELSE
*/
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				@car_type1
			FROM paydetail
			WHERE asgn_type = 'CAR'
	  		AND asgn_id = @car_id
			AND pyh_payperiod > @payperiodend
			AND (pyd_workperiod <= @payperiodstart
			OR pyd_workperiod >= '20491231')
	END
	-- Get the thirdparty pay header and detail numbers that we want
	IF @tpr_yes != 'XXX'
	BEGIN
		-- Get any computed pay
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			''
		FROM paydetail
		WHERE asgn_type = 'TPR'
	  	AND asgn_id = @tpr_id
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		-- LOR	select paydetails for the given payheader only
		AND pyh_number = @pyhnumber
		-- LOR

		-- Get any held pay
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			'HLD',
			''
		FROM paydetail
		WHERE asgn_type = 'TPR'
	  		AND asgn_id = @tpr_id
			AND pyh_payperiod > @payperiodend
			AND (pyd_workperiod <= @payperiodstart
			OR pyd_workperiod >= '20491231')
	END

	-- LOR PTS# 5744 add trailer settlements
	-- Get the trailer pay header and detail numbers that we want
	IF @trl_yes != 'XXX'
	BEGIN
		-- Get any computed pay
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@trl_type1
		FROM paydetail
		WHERE asgn_type = 'TRL'
	  	AND asgn_id = @trl_id
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		-- LOR	select paydetails for the given payheader only
		AND pyh_number = @pyhnumber
		-- LOR

		-- Get any held pay
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			'HLD',
			@trl_type1
		FROM paydetail
		WHERE asgn_type = 'TRL'
	  		AND asgn_id = @trl_id
	  		AND pyh_payperiod > @payperiodend
			AND (pyd_workperiod <= @payperiodstart
			OR pyd_workperiod >= '20491231')
	END
	--LOR
END

IF @report_type = 'FINAL'
BEGIN
	-- Get the driver pay header and detail numbers that we want
	IF @drv_yes != 'XXX'
	BEGIN
		-- Get the collected pay
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

		-- Get any computed pay that's on hold
		IF @hld_yes = 'Y'
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				@drv_type1
			FROM paydetail
			WHERE asgn_type = 'DRV'
	  		AND pyh_payperiod > @payperiodend
	  		AND (pyd_workperiod <= @payperiodstart
	   		OR pyd_workperiod >= '20491231')
	  		AND @drv_id = asgn_id
	END
	-- Get the tractor pay header and detail numbers that we want
	IF @trc_yes != 'XXX'
	BEGIN
		-- Get the collected pay
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

		-- Get any computed pay that's on hold
		IF @hld_yes = 'Y'
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				@trc_type1
			FROM paydetail 
			WHERE asgn_type = 'TRC'
			AND pyh_payperiod > @payperiodend
			AND (pyd_workperiod <= @payperiodstart
			OR pyd_workperiod >= '20491231')
			AND @trc_id = asgn_id
	END
	-- Get the carrier pay header and detail numbers that we want
	IF @car_yes != 'XXX'
	BEGIN	
		-- Get the collected pay
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

		-- Get any computed pay that's on hold
		IF @hld_yes = 'Y'
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				@car_type1
			FROM paydetail
			WHERE asgn_type = 'CAR'
		  	AND pyh_payperiod > @payperiodend
	  		AND (pyd_workperiod <= @payperiodstart
		 	OR pyd_workperiod >= '20491231')

			AND @car_id = asgn_id
	END
	-- Get the thirdparty pay header and detail numbers that we want
	IF @tpr_yes != 'XXX'
	BEGIN
		-- Get the collected pay
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

		-- Get any computed pay that's on hold
		IF @hld_yes = 'Y'
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				''
			FROM paydetail
			WHERE asgn_type = 'TPR'
		  	AND pyh_payperiod > @payperiodend
	  		AND (pyd_workperiod <= @payperiodstart
		 	OR pyd_workperiod >= '20491231')
			AND @tpr_id = asgn_id
	END

	-- LOR PTS# 5744 add trailer settlements
	-- Get the trailer pay header and detail numbers that we want
	IF @trl_yes != 'XXX'
	BEGIN
		-- Get the collected pay
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

		-- Get any computed pay that's on hold
		IF @hld_yes = 'Y'
			INSERT INTO #temp_pay
			SELECT pyd_number,
				pyh_number,
				'HLD',
				@trl_type1
			FROM paydetail 
			WHERE asgn_type = 'TRL'
			AND pyh_payperiod > @payperiodend
			AND (pyd_workperiod <= @payperiodstart
			OR pyd_workperiod >= '20491231')
			AND @trl_id = asgn_id
	END
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
	pyd_description		varchar(30) null, 
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
	ord_number		char(8) null,
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
	otherid			varchar(8) null,
	trc_drv			varchar(8) null,
	start_city		varchar(18) null,
	start_state		char(2) null,
	end_city		varchar(18) null,
	end_state		char(2) null,
	lgh_count		int null,
	pyh_issuedate datetime null
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
	null,
	null,
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
	null
FROM paydetail pd, #temp_pay tp
WHERE pd.pyd_number = tp.pyd_number

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
	shipper_state = ct.cty_state
FROM  company co, city ct, orderheader oh
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_shipper = co.cmp_id
  AND co.cmp_city = ct.cty_code

--Update the temp pay details with consignee data
UPDATE #temp_pd
SET consignee_name = co.cmp_name,
	consignee_city = ct.cty_name,
	consignee_state = ct.cty_state
FROM  company co, city ct, orderheader oh
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_consignee = co.cmp_id
  AND co.cmp_city = ct.cty_code

--Update the temp pay details with standingdeduction data
UPDATE #temp_pd
SET std_balance = sd.std_balance
FROM  standingdeduction sd
WHERE #temp_pd.std_number = sd.std_number


--Update the temp pay details for summary code
UPDATE #temp_pd
SET summary_code = 'OTHER'
WHERE summary_code != 'MIL'

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
SET pyt_description = pt.pyt_description
FROM  paytype pt
WHERE #temp_pd.pyt_itemcode = pt.pyt_itemcode

--Need to get the stop of the 1st delivery and find the commodity and arrival date
--associated with it.
--Update the temp pay details table with stop data for the 1st unload stop
UPDATE #temp_pd
SET stp_mfh_sequence = (SELECT MIN(st.stp_mfh_sequence)
	FROM stops st

	WHERE st.ord_hdrnumber > 0 and #temp_pd.ord_hdrnumber > 0 --JD Added this clause to stop joins on zero ord_hdrnumbers 35949
	  AND st.ord_hdrnumber = #temp_pd.ord_hdrnumber
	  AND st.stp_event in ('DLUL', 'LUL', 'DUL', 'PUL')) 


UPDATE #temp_pd
SET stp_number = st.stp_number
FROM stops st
WHERE st.ord_hdrnumber > 0 and #temp_pd.ord_hdrnumber > 0 --JD Added this clause to stop joins on zero ord_hdrnumbers 35949
  AND st.ord_hdrnumber = #temp_pd.ord_hdrnumber
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
INSERT INTO #YTDBAL
SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
FROM #temp_pd

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

SELECT pyd_number, 
	pyh_number, 
	asgn_number, 
	asgn_type, 
	asgn_id, 
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
	pyh_payperiod, 
	lgh_startcity,
	lgh_endcity, 
	pyd_minus,
	pyd_workperiod,
	pyd_sequence,
	pyd_rate,
	round(pyd_amount, 2),
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
	round(pyh_totalcomp, 2),
	round(pyh_totaldeduct, 2),
	round(pyh_totalreimbrs, 2),
	crd_cardnumber,
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
	trc_drv,
	start_city,
	start_state,
	end_city,
	end_state,
	lgh_count
FROM #temp_pd

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_sheet_summary_03] TO [public]
GO
