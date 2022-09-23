SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_settlement_sheet_summary_58] (
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
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/02/2007.01 ? PTS40116 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

-- jyang pts13004
Declare @PeriodforYTD Varchar(3),
	@CheckIssueDate	Datetime

-- Create a temp table to the pay header and detail numbers
CREATE TABLE #temp_pay (
	pyd_number int not null,
	pyh_number int not null,
	pyd_status varchar(6) null,
	asgn_type1 varchar(6) null,
	mpp_senioritydate datetime null,
	mpp_otherid varchar(9) null)

--Create a temp table for YTD balances
CREATE TABLE #ytdbal (asgn_type	varchar (6) not null,
	asgn_id			varchar (13) not null,
	ytdcomp			money null,
	ytddeduct		money null,
	ytdreimbrs		money null,
	pyh_payperiod		datetime null,
	pyh_issuedate		datetime null)


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
	pyd_payto		varchar(12) null, -- changed from 6 to 12 for PTS #5849, JET - 6/10/99
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
	ord_number		varchar(10) null,
	ref_number		varchar(20) null,
	stp_arrivaldate		datetime null,
	shipper_name		varchar(100) null,
	shipper_city		varchar(18) null,
	shipper_state		char(6) null,
	consignee_name		varchar(100) null,
	consignee_city		varchar(18) null,
	consignee_state		char(6) null,
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
	end_city		varchar(18) null,
	end_state		char(2) null,
	lgh_count		int null,
	ref_number_tds		varchar(20) null,
	pyd_offsetpay_number	int null,
	pyd_credit_pay_flag	char(1) null,
	total_empty_miles	float null,
	total_loaded_miles	float null,
	grand_total_miles	float null,
	empty_miles		float null,
	loaded_miles		float null,
	total_miles		float null,	
	mpp_senioritydate	datetime null,
	pyh_issuedate		datetime null,
	mpp_otherid		varchar(9) null,
        delivery_date 		datetime null,
        ticket			varchar(12)null,
        job			varchar(30)null,
        tons			float null,
	transportation_rate		float null,
   ivd_charge              money null,
   ivd_miscmoney1          money null,     
	units			varchar(6) null,
	calc_rate		float null,
	fuel_amt		float null ,
	sub_amt			float null)


SELECT @PeriodforYTD = isnull(gi_string1,'no') 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'

/* DSK PTS# 3682 commented out
-- Determine custom options
DECLARE @gi_string1 varchar(60)

SELECT @gi_string1 = gi_string1 
FROM generalinfo
WHERE gi_name = 'STLTRIALSHT'	*/

DECLARE	@empty_miles	float,
	@loaded_miles	float,
	@total_miles	float

SELECT	@empty_miles = 0,
	@loaded_miles = 0,
	@total_miles = 0



-- LOR PTS# 6404 elliminate trial and final settlement sheets - do just one
IF @hld_yes = 'Y' 
--IF @report_type = 'TRIAL'
BEGIN
	-- Get the driver pay header and detail numbers for held pay
	IF @drv_yes <> 'XXX'
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1, 
		                       mpp_senioritydate, mpp_otherid)
		SELECT pyd_number,
			pyh_number,
			-- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
               		-- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@drv_type1,
			mpp_senioritydate,
			mpp_otherid
		FROM paydetail, manpowerprofile
		WHERE asgn_type = 'DRV'
			AND asgn_id = @drv_id
			AND pyh_number = 0 
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend 
                                        AND asgn_id = mpp_id 

	-- Get the tractor pay header and detail numbers for held pay
	IF @trc_yes <> 'XXX'
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1)
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
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1)
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
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1)
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
END

IF @relcol  = 'N' and @relncol = 'Y' 
BEGIN
	IF @drv_yes <> 'XXX'
		-- Get the driver pay header and detail numbers for pay released 
		-- to this payperiod, but not collected
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1, 
		                       mpp_senioritydate, mpp_otherid)
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@drv_type1,
			mpp_senioritydate,
			mpp_otherid
		FROM paydetail, manpowerprofile
		WHERE asgn_type = 'DRV'
	  	AND asgn_id = @drv_id
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		AND pyh_number = 0 
		AND asgn_id = mpp_id 

	-- Get the tractor pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @trc_yes <> 'XXX'
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1)
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
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1)
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
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1)
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@trl_type1
		FROM paydetail
		WHERE asgn_type = 'TRL'
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
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1, 
		                       mpp_senioritydate, mpp_otherid)
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@drv_type1,
			mpp_senioritydate,
			mpp_otherid
		FROM paydetail pd, manpowerprofile
		WHERE asgn_type = 'DRV'
	  		AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
	  		AND @drv_id = asgn_id
			-- LOR	select paydetails for the given payheader only
			AND pyh_number = @pyhnumber 
                                        AND asgn_id = mpp_id
			-- LOR

	-- Get the tractor pay header and detail numbers pay released to this payperiod
	-- and collected 
	IF @trc_yes <> 'XXX'
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1)
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@trc_type1
		FROM paydetail pd 
		WHERE asgn_type = 'TRC'
			AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND @trc_id = asgn_id
			-- LOR	select paydetails for the given payheader only
			AND pyh_number = @pyhnumber
			-- LOR

	-- Get the carrier pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @car_yes <> 'XXX'
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1)
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@car_type1
		FROM paydetail pd 
		WHERE asgn_type = 'CAR'
			AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND @car_id = asgn_id
			-- LOR	select paydetails for the given payheader only
			AND pyh_number = @pyhnumber
			-- LOR

	-- Get the trailer pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @trl_yes <> 'XXX'
		INSERT INTO #temp_pay (pyd_number, pyh_number, pyd_status, asgn_type1)
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@trl_type1
		FROM paydetail pd 
		WHERE asgn_type = 'TRL'
		AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		AND @trl_id = asgn_id
		-- LOR	select paydetails for the given payheader only
		AND pyh_number = @pyhnumber
		-- LOR
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
	0,
	0,
	0,
	0,
	0,
	0, 
	mpp_senioritydate,
	(select pyh_issuedate from payheader where pyh_pyhnumber = pd.pyh_number) pyh_issuedate,
	mpp_otherid,
  	null,
	null,
	null,
	null, 
	0.00,
   0.00,
   0.00,
	null, --units
	null,
	null,
	null
 FROM paydetail pd, #temp_pay tp
WHERE pd.pyd_number = tp.pyd_number


--Update the temp pay details with legheader data
UPDATE #temp_pd
--   SET mov_number = lh.mov_number,
--       lgh_number = lh.lgh_number,
   SET lgh_startdate = (SELECT lgh_startdate 
                          FROM legheader lh
                         WHERE lh.lgh_number = #temp_pd.lgh_number)
--  FROM #temp_pd tp
-- WHERE tp.lgh_number = lh.lgh_number

-- Update the temp with number of legheaders for the move
-- actually, just find if there was another legheader on the move
UPDATE #temp_pd
   SET lgh_count = (SELECT COUNT(lgh_number) 
                      FROM legheader lh 
                     WHERE lh.mov_number = #temp_pd.mov_number)
--FROM legheader
--WHERE legheader.mov_number = #temp_pd.mov_number 
--  AND legheader.lgh_number <> #temp_pd.lgh_number

--Update the temp pay details with orderheader data
UPDATE #temp_pd
   SET ord_startdate = oh.ord_startdate,
       ord_number = rtrim(oh.ord_number)
  FROM #temp_pd tp, 
       orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber

--Update the temp, for split trips, set ord_number = ord_number + '/S'
UPDATE #temp_pd
   SET ord_number = ord_number + '/S'
 WHERE ord_hdrnumber > 0 
       AND lgh_count > 1 -- JET - 5/28/99 - PTS #5788, this was set to 0 and I changed it to 1

--Update the temp pay details with shipper data


UPDATE #temp_pd
   SET shipper_name = co.cmp_name, 
       shipper_city = ct.cty_name,
       shipper_state = ct.cty_state
  FROM #temp_pd tp, company co, city ct, orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber
       AND oh.ord_shipper = co.cmp_id
       AND co.cmp_city = ct.cty_code


--Update the temp pay details with consignee data
UPDATE #temp_pd
   SET consignee_name = co.cmp_name,
       consignee_city = ct.cty_name,
       consignee_state = ct.cty_state
  FROM #temp_pd tp, 
       company co, 
       city ct, 
       orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber
       AND oh.ord_consignee = co.cmp_id
       AND co.cmp_city = ct.cty_code

--Update the temp pay details with standingdeduction data
UPDATE #temp_pd
   SET std_balance = (SELECT std_balance 
                        FROM standingdeduction sd 
                       WHERE sd.std_number = #temp_pd.std_number)
-- FROM #temp_pd tp, standingdeduction sd
-- WHERE tp.std_number = sd.std_number

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
-- FROM #temp_pd tp, payheader ph
-- WHERE tp.pyh_number = ph.pyh_pyhnumber

/* JET need to pull the fee straight from the pay details, 5/14/99
--Update the temp pay details with paytype data
--LOR	PTS#4339 - add fee1, fee2

UPDATE #temp_pd
SET pyt_description = pt.pyt_description,
    pyt_fee1 = pt.pyt_fee1,
    pyt_fee2 = pt.pyt_fee2
FROM #temp_pd tp, paytype pt
WHERE tp.pyt_itemcode = pt.pyt_itemcode


*/


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
                            AND st.stp_mfh_sequence = IsNull(#temp_pd.stp_mfh_sequence, 1))
--  FROM stops st, #temp_pd tp
--WHERE st.mov_number = tp.mov_number
--  AND st.stp_mfh_sequence = tp.stp_mfh_sequence

-- KM PTS 7731, McFarland Settlement Sheet
SELECT	@empty_miles = sum(case stp_loadstatus when 'MT' then stp_lgh_mileage WHEN 'BT' then stp_lgh_mileage else 0 end),
	@loaded_miles = sum(case stp_loadstatus when 'LD' then stp_lgh_mileage else 0 end),
	@total_miles = sum(case stp_loadstatus when 'LD' then stp_lgh_mileage WHEN 'MT' then stp_lgh_mileage WHEN 'BT' then stp_lgh_mileage else 0 end)
FROM	stops
WHERE	stops.lgh_number IN 	(SELECT	distinct lgh_number
				FROM	#temp_pd)

UPDATE	#temp_pd
SET	empty_miles = 	(SELECT	sum(case stp_loadstatus when 'MT' then stp_lgh_mileage WHEN 'BT' then stp_lgh_mileage else 0 end) 
			FROM 	stops
			WHERE	stops.lgh_number = #temp_pd.lgh_number),
	loaded_miles = 	(SELECT	sum(case stp_loadstatus when 'LD' then stp_lgh_mileage else 0 end)
			FROM	stops
			WHERE	stops.lgh_number = #temp_pd.lgh_number),
	total_miles = 	(SELECT	sum(case stp_loadstatus when 'LD' then stp_lgh_mileage WHEN 'MT' then stp_lgh_mileage WHEN 'BT' then stp_lgh_mileage else 0 end)
			FROM 	stops
			WHERE	stops.lgh_number = #temp_pd.lgh_number)
FROM	stops
WHERE	stops.lgh_number = #temp_pd.lgh_number

UPDATE	#temp_pd
SET	total_empty_miles = @empty_miles,
	total_loaded_miles = @loaded_miles,
	grand_total_miles = @total_miles

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
--       stp_arrivaldate = st.stp_arrivaldate
--  FROM #temp_pd tp, 
--       freightdetail fd, 
--       commodity cd, 
--       stops st
-- WHERE st.stp_number = tp.stp_number
--       AND fd.stp_number = st.stp_number
--       AND cd.cmd_code = fd.cmd_code

--Need to get the bill-of-lading from the reference number table
--Update the temp pay details with reference number data
UPDATE #temp_pd
   SET ref_number = (SELECT MIN(ref_number) 
                       FROM referencenumber 
                      WHERE ref_tablekey = #temp_pd.ord_hdrnumber
                            AND ref_table = 'orderheader'
                            AND ref_type = 'SID')
--  FROM #temp_pd tp, referencenumber rn
-- WHERE rn.ref_tablekey = tp.ord_hdrnumber
--       AND rn.ref_table = 'orderheader'
--       AND rn.ref_type = 'SID'


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


--Insert into the temp YTD balances table the assets from the temp pay details table
INSERT INTO #ytdbal
     SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
       FROM #temp_pd

--Compute the YTD balances for each assets
--LOR	fixed null problem SR 7095
--JYAng pts13004
if left(ltrim(@PeriodforYTD),1) = 'Y' begin
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
END ELSE 
Begin
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
				   	 AND pyh_number = 0), 0)
   FROM  #ytdbal yb

UPDATE #temp_pd
SET pyh_totalcomp = yb.ytdcomp,
       pyh_totaldeduct = yb.ytddeduct,
       pyh_totalreimbrs = yb.ytdreimbrs
FROM #ytdbal yb, #temp_pd tp
WHERE tp.asgn_type = yb.asgn_type
       AND tp.asgn_id = yb.asgn_id

/*UPDATE #temp_pd
   SET pyh_totalcomp = (SELECT ISNULL(ytdcomp, 0)                           FROM #ytdbal
                         WHERE #ytdbal.asgn_type = #temp_pd.asgn_type
                               AND #ytdbal.asgn_id = #temp_pd.asgn_id)
UPDATE #temp_pd
   SET pyh_totaldeduct = (SELECT ISNULL(ytddeduct, 0)
                            FROM #ytdbal
                           WHERE #ytdbal.asgn_type = #temp_pd.asgn_type
                                 AND #ytdbal.asgn_id = #temp_pd.asgn_id)
UPDATE #temp_pd
   SET pyh_totalreimbrs = (SELECT ISNULL(ytdreimbrs, 0)
                             FROM #ytdbal
                            WHERE #ytdbal.asgn_type = #temp_pd.asgn_type
                                  AND #ytdbal.asgn_id = #temp_pd.asgn_id)	*/

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

--JD 11605 delete fake routing paydetails
if exists (select * from generalinfo where gi_name = 'StlFindNextMTLeg' and gi_string1 = 'Y')
	delete #temp_pd from paydetail where #temp_pd.pyd_number = paydetail.pyd_number and paydetail.tar_tarriffnumber = '-1'

-- Update the temp pay details with the start city information when a flat charge is used
UPDATE #temp_pd 
   SET shipper_name = 'UNKNOWN',
       shipper_city = start_city, 
       shipper_state = start_state 
 WHERE pyt_itemcode in ('FLAT', 'FLATN') 

-- Update the temp pay details with the end city information when a flat charge is used
UPDATE #temp_pd 
   SET consignee_name = 'UNKNOWN',
       consignee_city = end_city, 
       consignee_state = end_state 
 WHERE pyt_itemcode in ('FLAT', 'FLATN') 

--PTS#23437 ILB 03/16/2005
--get the required order, freight information and calculate the rate 
UPDATE #temp_pd
   SET delivery_date 	  = ord.ord_completiondate,
       ticket	          = ord.ord_number,
       job	          = ord.ord_refnum
  FROM #temp_pd, orderheader ord
 WHERE #temp_pd.ord_hdrnumber = ord.ord_hdrnumber

--PTS bcy here
UPDATE #temp_pd
   SET  ticket=(	select 	max(fgt_refnum) -- I had to do this b/c the Agg Entry window doesn't denorm to ref table
				  from 	freightdetail, stops
				 where 	stops.ord_hdrnumber = #temp_pd.ord_hdrnumber
						and stops.stp_number = freightdetail.stp_number
						and isNull(fgt_refnum,'') <> '' 
						--and stp_type = 'PUP'
					),


       job	          = CONVERT(VARCHAR,ord.ORD_HDRNUMBER) +' / '+ (SELECT isNull(max(isNull(ivh_ref_number,'')),'')
						FROM INVOICEHEADER
						WHERE INVOICEHEADER.ORD_HDRNUMBER = #temp_pd.ord_hdrnumber and INVOICEHEADER.ORD_HDRNUMBER >0)
  FROM #temp_pd, orderheader ord
 WHERE #temp_pd.ord_hdrnumber = ord.ord_hdrnumber

-- 	UPDATE 	#temp_pd
-- 	   SET 	tons =	invoicedetail.ivd_quantity
-- 	  from 	invoicedetail, chargetype
-- 	 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
-- 			and invoicedetail.cht_itemcode = chargetype.cht_itemcode
-- 			and chargetype.cht_basis = 'SHP'
-- 
-- select * from #temp_pd


/* 2006-01-24 BYoung BEGIN OLD WAY
	UPDATE 	#temp_pd
	   SET 	tons = case when (select count(*) 
							   from invoicedetail
							  where invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
									AND (invoicedetail.cht_itemcode = 'MIN' and invoicedetail.ivd_unit = 'TON')) > 0 
						then 
							(select min(invoicedetail.ivd_quantity)
							  from 	invoicedetail, chargetype
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
									and invoicedetail.cht_itemcode = chargetype.cht_itemcode
									and invoicedetail.cht_itemcode = 'MIN' 
									and invoicedetail.ivd_unit ='TON')

-- 						when (select count(*) 
-- 							   from invoicedetail
-- 							  where invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
-- 									AND (invoicedetail.cht_itemcode = 'MIN' and invoicedetail.ivd_unit = 'TON')) = 0 
-- 						then 
						else
							(select min(invoicedetail.ivd_quantity)
							  from 	invoicedetail, chargetype
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
									and invoicedetail.cht_itemcode = chargetype.cht_itemcode
									and chargetype.cht_basis = 'SHP' and ivd_charge > 0)
						END
  FROM #temp_pd, orderheader ord
 WHERE #temp_pd.ord_hdrnumber = ord.ord_hdrnumber
-- 	   and #temp_pd.pyt_itemcode = paytype.pyt_itemcode
-- 	   and paytype.pyt_basis = 'LGH'



UPDATE	#temp_pd
   SET	units = chargetype.cht_unit
  from 	invoicedetail, chargetype
 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
		and 
		invoicedetail.cht_itemcode = chargetype.cht_itemcode
		and chargetype.cht_basis = 'SHP'


UPDATE 	#temp_pd
   set 	units = pyd_unit
 where 	units is NULL

 2006-01-24 BYoung END OLD WAY */

--bcy 2006-01-24 BEGIN new way
--tons and units actually come from invoice details the stl sheet needs
--to show these value for Line Haul and Acc PAT that relates to the invoicedetail

update	#temp_pd
SET		TONS = case when pyt_basis = 'LGH' then (
							select min(invoicedetail.ivd_quantity)
							  from 	invoicedetail join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
							   and #temp_pd.ord_hdrnumber > 0
							   and (chargetype.cht_basis = 'SHP' or invoicedetail.cht_itemcode = 'MIN') and ivd_charge > 0

					)
					 when pyt_basis <> 'LGH' then (
							select 	min(invoicedetail.ivd_quantity)
							  from 	invoicedetail join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
							   and #temp_pd.ord_hdrnumber > 0
									and invoicedetail.cht_itemcode = paytype.cht_itemcode
									and ivd_charge > 0
					)				
				END		
		,transportation_rate = case when pyt_basis = 'LGH' then (
							select CASE isnull(min(invoicedetail.ivd_miscmoney1),0) when 0 then min(invoicedetail.ivd_rate) else min(invoicedetail.ivd_miscmoney1)END
							  from 	invoicedetail join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
							   and #temp_pd.ord_hdrnumber > 0
 							   and (chargetype.cht_basis = 'SHP' or invoicedetail.cht_itemcode = 'MIN') and ivd_charge > 0

					)
					 when pyt_basis <> 'LGH' then (
							select 	min(invoicedetail.ivd_rate) --BYoung - changed from ivd_quantity to ivd_rate
							  from 	invoicedetail join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
							   and #temp_pd.ord_hdrnumber > 0
							   and invoicedetail.cht_itemcode = paytype.cht_itemcode
							   and ivd_charge > 0
					)				
				END		
      , ivd_charge = case when pyt_basis = 'LGH' then (
							select min(isnull(ivd_charge,0.00))
							  from 	invoicedetail join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
							   and #temp_pd.ord_hdrnumber > 0
 							   and (chargetype.cht_basis = 'SHP' or invoicedetail.cht_itemcode = 'MIN') and ivd_charge > 0

					)
					 when pyt_basis <> 'LGH' then (
							select 	min(isnull(invoicedetail.ivd_charge,0))
							  from 	invoicedetail join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
							   and #temp_pd.ord_hdrnumber > 0
							   and invoicedetail.cht_itemcode = paytype.cht_itemcode
							   and ivd_charge > 0
					)				
				END
      ,ivd_miscmoney1 = case when pyt_basis = 'LGH' then (
							select min(isnull(ivd_miscmoney1,0.00))
							  from 	invoicedetail join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
							   and #temp_pd.ord_hdrnumber > 0
 							   and (chargetype.cht_basis = 'SHP' or invoicedetail.cht_itemcode = 'MIN') and ivd_charge > 0

					)
					 when pyt_basis <> 'LGH' then (
							select 	min(isnull(invoicedetail.ivd_miscmoney1,0))
							  from 	invoicedetail join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
							   and #temp_pd.ord_hdrnumber > 0
							   and invoicedetail.cht_itemcode = paytype.cht_itemcode
							   and ivd_charge > 0
					)				
				END	
		,  UNITS = case when pyt_basis = 'LGH' then (
							select min(invoicedetail.ivd_unit)
							  from 	invoicedetail join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
							   and #temp_pd.ord_hdrnumber > 0
							   and (chargetype.cht_basis = 'SHP' or invoicedetail.cht_itemcode = 'MIN') and ivd_charge > 0

					)
					 when pyt_basis <> 'LGH' then (
							select 	isNull(min(chargetype.cht_rateunit),'FLT')
							  from 	invoicedetail join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
							 where	invoicedetail.ord_hdrnumber = #temp_pd.ord_hdrnumber
							   and  #temp_pd.ord_hdrnumber > 0
   							   and invoicedetail.cht_itemcode = paytype.cht_itemcode
							   and ivd_charge > 0
					)				
				END		

  from	paytype 
  where	#temp_pd.pyt_itemcode = paytype.pyt_itemcode

update #temp_pd
   set transportation_rate = #temp_pd.pyd_quantity/tons
 where round(#temp_pd.pyd_quantity,2) <> round(#temp_pd.ivd_charge,2)
   and isnull(#temp_pd.ivd_miscmoney1,0.00) < 0.01

--select * from #temp_pd

update	#temp_pd
  set	fuel_amt = (select isNull(sum(round(isNull(pyd_amount,0),2)),0)
	  				  from #temp_pd
	 				 where	CHARINDEX('FSC', upper(pyt_itemcode)) > 0)
-- 
-- update	#temp_pd
--   set	sub_amt = pyh_totalcomp - isNull(fuel_amt,0)

--bcy 2006-01-24end new way
--bcy 02-06-07 Handle Misc Pay

update	#temp_pd
  set	ticket=left(isNull(paydetail.pyd_refnum,' '),10)
		,tons = isNull(paydetail.pyd_quantity,0)
		,calc_rate = paydetail.pyd_rate
		,job=case when len(isNull(paydetail.pyd_refnum,' ')) > 10 then substring(isNull(paydetail.pyd_refnum,' '),11,len(isNull(paydetail.pyd_refnum,' '))-10) end
  from	paydetail
 where	#temp_pd.pyd_number = paydetail.pyd_number
		and isnull(#temp_pd.ord_hdrnumber,0) = 0

--bcy 02-06-07 End Misc Pay

SELECT pyd_number, 
	pyh_number, 
	asgn_number, 
	tp.asgn_type, 
	tp.asgn_id, 
	ivd_number, 
	pyd_prorap, 
	pyd_payto,
	pyt_itemcode,
	pyd_description = case when (isNull(ord_hdrnumber,'') = '' or pyt_itemcode = 'CORR') then pyd_description else (	select min(pt.pyt_description)
						  FROM 	paytype pt
						 WHERE 	tp.pyt_itemcode = pt.pyt_itemcode) END,

	pyr_ratecode, 
	IsNull(pyd_quantity, 0),
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
	round(tp.pyh_totalcomp, 2),
	round(tp.pyh_totaldeduct, 2),
	round(tp.pyh_totalreimbrs, 2),
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
	IsNull(total_empty_miles, 0) total_empty_miles,
	IsNull(total_loaded_miles, 0) total_loaded_miles,
	IsNull(grand_total_miles, 0) grand_total_miles,
	IsNull(empty_miles, 0) empty_miles,
	IsNull(loaded_miles, 0) loaded_miles,
	IsNull(total_miles, 0) total_miles,
	stp_number,	
	mpp_senioritydate,
	mpp_otherid,
	delivery_date = case when isNull(delivery_date,'') ='' THEN pyd_transdate else delivery_date END,
        ticket,
        job,
        tons = isNull(tons,1),
	units,
--02-06-07 bcy added ord_hdrnumber > 0 for Misc pay
--	calc_rate = case when isNull(tons,0) > 0 and isNull(ord_hdrnumber,0) > 0 then round(convert(money,transportation_rate * isNull(pyd_rate,1)),2) else pyd_rate end,
	calc_rate = case when isNull(tons,0) > 0 and isNull(ord_hdrnumber,0) > 0 then round(convert(money,transportation_rate * isNull(pyd_rate,1)),2,1) else pyd_rate end,
	fuel_amt,
	sub_amt
  FROM #temp_pd tp LEFT OUTER JOIN payheader ph ON tp.pyh_number = ph.pyh_pyhnumber
  WHERE (isNull(tp.pyd_amount,0) <> 0 or pyd_sequence = 1)
  order by delivery_date, ord_hdrnumber,pyd_amount desc


GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_summary_58] TO [public]
GO
