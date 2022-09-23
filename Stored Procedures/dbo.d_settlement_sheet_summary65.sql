SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_settlement_sheet_summary65](
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
 * d_settlement_sheet_summary65
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Populates data for settlement sheet 65
 *
 * LAST MODIFIED:
 * 02-AUG-2006 SWJ - PTS 32844 - Created from d_settlement_sheet_summary16
 * 11-NOV-2006 vjh - PTS 34808 - Corrections to original work
 * 19-DEC-2006 vjh - PTS 35427 - Additional changes
 * 04-JAN-2007 vjh - PTS 35427 - better handle null check_date for processing without a schedule
 * 17-JAN-2007 vjh - PTS 35857 - get check date from payheader
 * BDH 6/3/08 43029:  Only calculate total_miles where pyt_basis = 'LGH'
 * PTS 47849:  Add ThirdParty  @tpr_yes,  @tpr_id	
 */

-- jyang pts13004
Declare	@PeriodforYTD 		Varchar(3),
		@ld_totalmiles		MONEY,
		@ld_pydnumber		INTEGER,
		@ld_stdnumber		INTEGER,
		@ld_pydrate			MONEY,
		@ls_description		VARCHAR(255),
		@ls_exists 			VARCHAR(4),
		@ls_asgn_id			VARCHAR(8),
		@ls_asgn_type		VARCHAR(4),
		@ls_pretax			CHAR(1),
		@ld_minus			INTEGER,
		@ldt_ordenedate		DATETIME,
		@li_sequence		INTEGER,
		@lgh_number			INTEGER,
		@min_pyd			INTEGER,
		@v_pyt_itemcode		varchar(6),
		@check_date			datetime

select @check_date = min(pyh_issuedate)
FROM 	payheader 
WHERE	pyh_pyhnumber = @pyhnumber

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

--Create a temp table for YTD balances
CREATE TABLE #ytdbal (asgn_type	varchar (6) not null,
	asgn_id			varchar (13) not null,
	ytdcomp			money null,
	ytddeduct		money null,
	ytdreimbrs		money null,
	pyh_payperiod		datetime null,
	pyh_issuedate		datetime null)

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
	pyd_description		varchar(75) null,	-- 02-AUG-2006 SWJ - PTS 32844 - Changed from 30 to 75 
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
	terminal		varchar(20) null, -- 08-AUG-2006 SWJ - Changed from 6 to 20
	type1			varchar(6) null,
	pyh_totalcomp		money null,
	pyh_totaldeduct		money null,
	pyh_totalreimbrs	money null,
	crd_cardnumber		char(20) null, /*pts 21137 cgk 7/19/2004, changed to 20 characters*/
	lgh_startdate		datetime null,
	std_balance		money null,
	itemsection		int null,
	ord_enddate		datetime null,
	ord_number		char(12) null,		-- 02-AUG-2006 SWJ - PTS 32844 - Changed from 10 to 12
	ref_number		varchar(30) null,
	stp_arrivaldate		datetime null,
	shipper_name		varchar(30) null,
	shipper_city		varchar(18) null,
	shipper_state		varchar(6) null,	-- 02-AUG-2006 SWJ - PTS 32844 - Changed from 2 to 6	
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
	pyt_fee1		money null,
	pyt_fee2		money null,
	start_city		varchar(18) null,
	start_state		varchar(6) null,	-- 02-AUG-2006 SWJ - PTS 32844 - Changed from 2 to 6	
	end_city		varchar(18) null,
	end_state		varchar(6) null,	-- 02-AUG-2006 SWJ - PTS 32844 - Changed from 2 to 6	
	lgh_count		int null,
	ref_number_tds		varchar(30) null,
	pyd_offsetpay_number	int null,
	pyd_credit_pay_flag	char(1) null,
	pyh_issuedate 		datetime null,
	total_miles		money null,
	payto_address		varchar(30) null,
	payto_address2		varchar(30) null,
	payto_city_state	varchar(255) null,
	payto_zip		varchar(10) null,
	period_cutoff		varchar(20) null,
	check_date		varchar(20) null,
	ytd_amount		decimal(9,2) null,
	display_date 	datetime null,
	sn				int identity  not null,
	payto_name		varchar(20) null)

CREATE TABLE #temp_ytd (
	pyt_itemcode	varchar(6) null,
	ytd_amount		decimal(9,2) null, 
	pyd_description		varchar(75) null)

-- LOR PTS# 6404 elliminate trial and final settlement sheets - do just one
IF @hld_yes = 'Y' 
BEGIN
	-- Get the driver pay header and detail numbers for held pay
	IF @drv_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
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
		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
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
		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
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
		INSERT INTO #temp_pay
		SELECT 	pyd_number,
			pyh_number,
                        pyd_status,
			@trl_type1
		FROM 	paydetail
		WHERE 	asgn_type = 'TRL'
	  		AND asgn_id = @trl_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- PTS 47849
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
		SELECT  pyd_number,
			pyh_number,
			pyd_status,
			@trl_type1
		FROM 	paydetail
		WHERE 	asgn_type = 'TRL'
	  		AND asgn_id = @trl_id
	  		AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pyh_number = 0

	-- PTS 47849
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
			AND pyh_number = @pyhnumber
			
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
			AND pyh_number = @pyhnumber
			
	-- Get the carrier pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @car_yes <> 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@car_type1
		FROM 	paydetail pd, payheader ph
		WHERE	 ph.asgn_type = 'CAR'
			AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @car_id = ph.asgn_id
			AND pyh_number = @pyhnumber
			
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
			AND pyh_number = @pyhnumber

	-- PTS 47849
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
			AND pyh_number = @pyhnumber		
END

-- Insert into the temp pay details table with the paydetail data per #temp_pay
INSERT INTO #temp_pd
(	pyd_number		,
	pyh_number		,
	asgn_number		,
	asgn_type,
	asgn_id		,
	ivd_number		,
	pyd_prorap		,
	pyd_payto		,
	pyt_itemcode		,
	pyd_description		,
	pyr_ratecode		,
	pyd_quantity		,
	pyd_rateunit		,
	pyd_unit		,
	pyd_pretax		,
	pyd_status		,
	pyh_payperiod		,
	lgh_startcity		,
	lgh_endcity		,
	pyd_minus		,
	pyd_workperiod		,
	pyd_sequence		,
	pyd_rate		,
	pyd_amount		,
	pyd_payrevenue		,
	mov_number		,
	lgh_number		,
	ord_hdrnumber		,
	pyd_transdate		,
	payperiodstart		,
	payperiodend		,
	pyd_loadstate		,
	summary_code		,
	name			,
	terminal		,
	type1			,
	pyh_totalcomp		,
	pyh_totaldeduct		,
	pyh_totalreimbrs	,
	crd_cardnumber		,
	lgh_startdate		,
	std_balance		,
	itemsection		,
	ord_enddate		,
	ord_number		,
	ref_number		,
	stp_arrivaldate		,
	shipper_name		,
	shipper_city		,
	shipper_state		,
	consignee_name		,
	consignee_city		,
	consignee_state		,
	cmd_name		,
	pyd_billedweight	,
	adjusted_billed_rate	,
	cht_basis		,
	cht_basisunit		,
	cht_unit		,
	cht_rateunit		,
	std_number		,
	stp_number		,
	unc_factor		,
	stp_mfh_sequence	,
	pyt_description		,
	cht_itemcode		,
	userlabelname		,
	label_name		,
	otherid			,
	pyt_fee1		,
	pyt_fee2		,
	start_city		,
	start_state		,
	end_city		,
	end_state		,
	lgh_count		,
	ref_number_tds		,
	pyd_offsetpay_number	,
	pyd_credit_pay_flag	,
	pyh_issuedate 		,
	total_miles		,
	payto_address		,
	payto_address2		,
	payto_city_state	,
	payto_zip		,
	period_cutoff		,
	check_date		,
	ytd_amount		,
	display_date 	)
SELECT 	pd.pyd_number,
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
	null, 
	0,
	null,
	null,
	null,
	null,
	null,
	null,
	0,
	null
FROM 	paydetail pd, 
		#temp_pay tp
WHERE 	pd.pyd_number = tp.pyd_number
Order by pyd_minus desc,ord_hdrnumber asc,pyt_itemcode asc,pyd_sequence asc

-- JD 32844 First detail must have startdate and last detail on the order the enddate.
UPDATE 	#temp_pd
SET		#temp_pd.lgh_startdate = lh.lgh_startdate,
    	#temp_pd.ord_enddate = lh.lgh_enddate
  FROM 	#temp_pd tp, 
       	legheader lh
 WHERE 	tp.lgh_number = lh.lgh_number

Update #temp_pd set display_date = lgh_startdate 
where sn = (select  min(sn) from #temp_pd temp_pd2 where temp_pd2.lgh_number = #temp_pd.lgh_number)

Update #temp_pd set display_date = ord_enddate 
where sn = (select  max(sn) from #temp_pd temp_pd2 where temp_pd2.lgh_number = #temp_pd.lgh_number)


--Update the temp pay details with orderheader data
 UPDATE 	#temp_pd
 SET	#temp_pd.ord_number = oh.ord_number
   FROM 	#temp_pd tp, 
        	orderheader oh
  WHERE 	tp.ord_hdrnumber = oh.ord_hdrnumber

-- Update the temp with number of legheaders for the move
-- actually, just find if there was another legheader on the move
UPDATE #temp_pd
   SET lgh_count = (SELECT 	COUNT(lgh_number) 
                      FROM 	legheader lh 
                     WHERE 	lh.mov_number = #temp_pd.mov_number)

--Update the temp pay details with orderheader data
-- UPDATE 	#temp_pd
--    SET 	#temp_pd.ord_enddate = oh.ord_completiondate,
-- 	#temp_pd.ord_number = oh.ord_number
--   FROM 	#temp_pd tp, 
--        	orderheader oh
--  WHERE 	tp.ord_hdrnumber = oh.ord_hdrnumber




-- 02-AUG-2006 SWJ - PTS 32844 - Added trims to ord_number as it is a CHAR type and was causing an overflow with the concatenation
--Update the temp, for split trips, set ord_number = ord_number + '/S'
UPDATE 	#temp_pd
   SET 	ord_number = LTRIM(RTRIM(ord_number)) + '/S'
 WHERE 	ord_hdrnumber > 0 
       	AND lgh_count > 1 -- JET - 5/28/99 - PTS #5788, this was set to 0 and I changed it to 1

--Update the temp pay details with shipper data
UPDATE 	#temp_pd
   SET 	shipper_name = co.cmp_name, 
       	shipper_city = ct.cty_name,
       	shipper_state = ct.cty_state
  FROM 	#temp_pd tp, 
	company co, 
	city ct, 
	orderheader oh
 WHERE 	tp.ord_hdrnumber = oh.ord_hdrnumber
       	AND oh.ord_shipper = co.cmp_id
       	AND co.cmp_city = ct.cty_code

--Update the temp pay details with consignee data
UPDATE 	#temp_pd
   SET 	consignee_name = co.cmp_name,
       	consignee_city = ct.cty_name,
       	consignee_state = ct.cty_state
  FROM 	#temp_pd tp, 
       	company co, 
       	city ct, 
       	orderheader oh
 WHERE 	tp.ord_hdrnumber = oh.ord_hdrnumber
       	AND oh.ord_consignee = co.cmp_id
       	AND co.cmp_city = ct.cty_code

--Update the temp pay details for summary code
UPDATE 	#temp_pd
   SET 	summary_code = 'OTHER'
 WHERE 	summary_code <> 'MIL'

--Update the temp pay details for load status
UPDATE 	#temp_pd
   SET 	pyd_loadstate = 'NA'
 WHERE 	pyd_loadstate IS NULL

UPDATE 	#temp_pd
SET 	crd_cardnumber = ph.crd_cardnumber,
	pyh_issuedate = IsNull(ph.pyh_issuedate,ph.pyh_payperiod)
FROM 	#temp_pd tp, 
	payheader ph
WHERE 	tp.pyh_number = ph.pyh_pyhnumber

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

--Insert into the temp YTD balances table the assets from the temp pay details table
INSERT INTO #ytdbal (asgn_type, asgn_id, ytdcomp, ytddeduct, ytdreimbrs, pyh_payperiod, pyh_issuedate)
SELECT	asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
FROM	#temp_pd

IF left(ltrim(@PeriodforYTD),1) = 'Y' 
BEGIN
	UPDATE #ytdbal
	   SET ytdcomp = (SELECT SUM(ROUND(ISNULL(ph.pyh_totalcomp, 0), 2))
	                   FROM payheader ph
	                  WHERE ph.asgn_id = #ytdbal.asgn_id
	                        AND ph.asgn_type = #ytdbal.asgn_type
	                       	AND ph.pyh_payperiod >= '01/01/' + datename(yy, isnull(@check_date,@payperiodend))
	                        AND ph.pyh_payperiod <= isnull(@check_date,@payperiodend)
	                        AND ph.pyh_paystatus <> 'HLD'), 
	     ytddeduct = (SELECT SUM(ROUND(ISNULL(ph.pyh_totaldeduct, 0), 2))
	                   FROM payheader ph
	         WHERE ph.asgn_id = #ytdbal.asgn_id
	                        AND ph.asgn_type = #ytdbal.asgn_type
	                        AND ph.pyh_payperiod >= '01/01/' + datename(yy, isnull(@check_date,@payperiodend))
	                        AND ph.pyh_payperiod <= isnull(@check_date,@payperiodend)
	                        AND ph.pyh_paystatus <> 'HLD'), 
	    ytdreimbrs = (SELECT SUM(ROUND(ISNULL(ph.pyh_totalreimbrs, 0), 2))
	                   FROM payheader ph
	                  WHERE ph.asgn_id = #ytdbal.asgn_id
	                        AND ph.asgn_type = #ytdbal.asgn_type
	                        AND ph.pyh_payperiod >= '01/01/' + datename(yy, isnull(@check_date,@payperiodend))
	                        AND ph.pyh_payperiod <= isnull(@check_date,@payperiodend)
	                        AND ph.pyh_paystatus <> 'HLD') 
END 
ELSE 
BEGIN
	UPDATE #ytdbal
	SET	ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
				FROM payheader ph
		          	WHERE ph.asgn_id = yb.asgn_id
		                	AND ph.asgn_type = yb.asgn_type
		                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, isnull(@check_date,isnull(yb.pyh_issuedate,yb.pyh_payperiod)))
		                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) <= isnull(@check_date,isnull(yb.pyh_issuedate,yb.pyh_payperiod))
		                	AND ph.pyh_paystatus <> 'HLD'), 0),
		ytddeduct = ISNULL((SELECT SUM(ROUND(ph.pyh_totaldeduct, 2))
		           	FROM payheader ph
		          	WHERE ph.asgn_id = yb.asgn_id
		               		AND ph.asgn_type = yb.asgn_type
		                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, isnull(@check_date,isnull(yb.pyh_issuedate,yb.pyh_payperiod)))
		                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) <= isnull(@check_date,isnull(yb.pyh_issuedate,yb.pyh_payperiod))
		                	AND ph.pyh_paystatus <> 'HLD'), 0),
		ytdreimbrs = ISNULL((SELECT SUM(ROUND(ph.pyh_totalreimbrs, 2))
		           	FROM payheader ph
		          	WHERE ph.asgn_id = yb.asgn_id
		                	AND ph.asgn_type = yb.asgn_type
		                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, isnull(@check_date,isnull(yb.pyh_issuedate,yb.pyh_payperiod)))
		                	AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) <= isnull(@check_date,isnull(yb.pyh_issuedate,yb.pyh_payperiod))
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

IF @drv_yes <> 'XXX'
BEGIN
	SET @ls_asgn_id = @drv_id
	SET @ls_asgn_type = 'DRV'
END

IF @trc_yes <> 'XXX'
BEGIN
	SET @ls_asgn_id = @trc_id
	SET @ls_asgn_type = 'TRC'
END

IF @trl_yes <> 'XXX'
BEGIN
	SET @ls_asgn_id = @trl_id
	SET @ls_asgn_type = 'TRL'
END

-- get balance information
declare @sdm_minusbalance int,@sdm_itemcode varchar(12)

SELECT	@ld_stdnumber = MIN(s.std_number)
FROM	standingdeduction s
JOIN stdmaster m on s.sdm_itemcode = m.sdm_itemcode
WHERE	s.asgn_id = @ls_asgn_id
	AND s.asgn_type = @ls_asgn_type
	AND m.sdm_escrowstyle = 'Y'

WHILE @ld_stdnumber IS not NULL
BEGIN
select @sdm_itemcode=sdm_itemcode from standingdeduction where std_number=@ld_stdnumber
select @sdm_minusbalance=CASE sdm_minusbalance WHEN 'Y' THEN -1 ELSE 1 END from stdmaster where sdm_itemcode = @sdm_itemcode

	SELECT	@ls_description = std_description
	FROM	standingdeduction
	WHERE	std_number = @ld_stdnumber


	SET @ls_exists = NULL
	SELECT	@ls_exists = 'TRUE'
	FROM	#temp_pd
	WHERE	pyd_description = @ls_description

	IF @li_sequence IS NULL
		SET @li_sequence = 0

	IF @ls_exists = 'TRUE' 
	BEGIN
--		vjh move to separate loop
--		UPDATE	#temp_pd
--		SET	ytd_amount = (	SELECT	SUM(pyd_amount)
--					FROM	paydetail
--					WHERE	asgn_type = @ls_asgn_type
--						AND asgn_id = @ls_asgn_id
--						AND pyd_transdate >= cast( '01-01-' + cast( year(@payperiodend) as varchar(4)) as datetime)
--						AND pyd_description = @ls_description )
--		FROM	#temp_pd
--		WHERE	pyd_description = @ls_description

		UPDATE 	#temp_pd
		SET 	std_balance = (SELECT	@sdm_minusbalance * std_balance 
		                        FROM 	standingdeduction sd 
		                       WHERE 	sd.std_number = #temp_pd.std_number)
		where	std_number = @ld_stdnumber
	END
	ELSE
	BEGIN
		INSERT INTO #temp_pd (pyh_number, pyd_number, asgn_type, asgn_id, pyd_pretax, pyd_status, pyd_minus, 
					pyd_workperiod, pyd_transdate, pyd_sequence, pyd_description, ytd_amount, ord_enddate, 
					pyd_quantity, pyd_rateunit, pyd_amount, itemsection, pyt_itemcode,name )
		
		SELECT 	@pyhnumber, 0, @ls_asgn_type, @ls_asgn_id, pyt_pretax, '', CASE pyt_minus WHEN 'Y' THEN -1 ELSE 1 END, 
			@payperiodstart, @payperiodend, @li_sequence, @ls_description, @sdm_minusbalance * std_balance, @payperiodstart, 
			1, 'FLT', 0, 0, pyt_itemcode, @name
		FROM	standingdeduction,
			paytype
		WHERE	std_description = @ls_description
			AND standingdeduction.asgn_id = @ls_asgn_id
			AND standingdeduction.asgn_type = @ls_asgn_type
			AND paytype.pyt_description = standingdeduction.std_description

	END

	SELECT	@ld_stdnumber = MIN(s.std_number)
	FROM	standingdeduction s
	JOIN stdmaster m on s.sdm_itemcode = m.sdm_itemcode
	WHERE	s.asgn_id = @ls_asgn_id
		AND s.asgn_type = @ls_asgn_type
		AND m.sdm_escrowstyle = 'Y'
		AND s.std_number > @ld_stdnumber

END
-- vjh expand to get YTD for all deductions, even those with no activity this pay period
insert	#temp_ytd (pyt_itemcode, ytd_amount) --, pyd_description)
select	pd.pyt_itemcode, sum(pd.pyd_amount) --, 't' --min(pd.pyd_description)
from	paydetail pd
join	payheader ph on ph.pyh_pyhnumber = pd.pyh_number
where	pd.asgn_id = @ls_asgn_id
	AND pd.asgn_type = @ls_asgn_type
	AND	ph.pyh_issuedate >= '01/01/' + datename(yy, isnull(@check_date,@payperiodend))
	AND	ph.pyh_issuedate <= isnull(@check_date,@payperiodend)
	AND	pd.pyd_pretax = 'N' 
	AND	pd.pyd_minus = -1
	AND	pyh_paystatus <> 'HLD'
group by pyt_itemcode

UPDATE 	#temp_pd
SET 	ytd_amount = #temp_ytd.ytd_amount
from	#temp_ytd
where	#temp_pd.pyt_itemcode = #temp_ytd.pyt_itemcode

select @v_pyt_itemcode = min(pyt_itemcode) 
from #temp_ytd

while @v_pyt_itemcode is not null begin
	SET		@ls_exists = NULL
	SELECT	@ls_exists = 'TRUE'
	FROM	#temp_pd
	WHERE	pyt_itemcode = @v_pyt_itemcode
	IF @ls_exists is null
	BEGIN
		INSERT INTO #temp_pd (pyh_number, pyd_number, asgn_type, asgn_id, pyd_pretax, pyd_status, pyd_minus, 
					pyd_workperiod, pyd_transdate, pyd_sequence, pyd_description, ytd_amount, ord_enddate, 
					pyd_quantity, pyd_rateunit, pyd_amount, itemsection, pyt_itemcode, std_balance, ivd_number, name )
		SELECT 	@pyhnumber, 0, @ls_asgn_type, @ls_asgn_id, 'N', '', -1, 
					@payperiodstart, @payperiodend, @li_sequence, #temp_ytd.pyd_description, #temp_ytd.ytd_amount, @payperiodstart, 
					1, 'FLT', 0, 0, pyt_itemcode, 0, 0, @name
		FROM	#temp_ytd
		WHERE	#temp_ytd.pyt_itemcode = pyt_itemcode
		and		#temp_ytd.pyt_itemcode = @v_pyt_itemcode
	END
	select @v_pyt_itemcode = min(pyt_itemcode) 
	from #temp_ytd
	where pyt_itemcode > @v_pyt_itemcode
end --while

-- To add new pay details for mileage total:
--	Add new unit and new itemcode to WHERE clause
--	Current total mileages:	Route Pay

SELECT	@min_pyd = MIN(pyd_number)
FROM	#temp_pd
WHERE	pyd_number > 0

WHILE @min_pyd IS NOT NULL
BEGIN

	SELECT	@lgh_number = lgh_number
	FROM	#temp_pd
	WHERE	pyd_number = @min_pyd

-- BDH 43029:  Only calculate mileage where pyt_basis = 'LGH'
--	UPDATE	#temp_pd
--	SET	total_miles = (SELECT 	SUM( stp_lgh_mileage)
--				FROM	stops
--				WHERE	lgh_number = @lgh_number)
--	WHERE	pyd_number = @min_pyd

	UPDATE	#temp_pd
	SET	total_miles = (SELECT 	SUM( stp_lgh_mileage)
				FROM	stops
				WHERE	lgh_number = @lgh_number)
	from paytype
	WHERE	pyd_number = @min_pyd
		and #temp_pd.pyt_itemcode = paytype.pyt_itemcode
		and paytype.pyt_basis = 'LGH'
	-- 43209 end

	SELECT	@min_pyd = MIN(pyd_number)
	FROM	#temp_pd
	WHERE	pyd_number > @min_pyd
		AND lgh_number <> @lgh_number
		AND pyd_number > 0
END

UPDATE	#temp_pd
SET	total_miles = NULL
WHERE	total_miles = 0

-- Update any NULL payto to the correct one
UPDATE	#temp_pd
SET	pyd_payto = (	SELECT	TOP 1 pyd_payto
			FROM	#temp_pd
			WHERE	pyd_payto IS NOT NULL)

UPDATE 	#temp_pd
SET 	pyh_totalcomp = yb.ytdcomp,
       	pyh_totaldeduct = yb.ytddeduct,
       	pyh_totalreimbrs = yb.ytdreimbrs
FROM 	#ytdbal yb, #temp_pd tp
WHERE 	tp.asgn_type = yb.asgn_type
       AND tp.asgn_id = yb.asgn_id

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
UPDATE 	#temp_pd
   SET 	ref_number_tds = r.ref_number
  FROM 	#temp_pd tp, labelfile l, orderheader o, referencenumber r
 WHERE 	r.ref_table = 'orderheader' and
	r.ref_tablekey = tp.ord_hdrnumber and
	l.labeldefinition = 'ReferenceNumbers' and
	l.abbr = r.ref_type and
	r.ref_type = 'TRIP' and
	o.ord_hdrnumber = tp.ord_hdrnumber and
	r.ref_type = o.ord_reftype

--JD 11605 delete fake routing paydetails
if exists (select * from generalinfo where gi_name = 'StlFindNextMTLeg' and gi_string1 = 'Y')
	delete #temp_pd from paydetail where #temp_pd.pyd_number = paydetail.pyd_number and paydetail.tar_tarriffnumber = '-1'

-- 02-AUG-2006 SWJ - PTS 32844
UPDATE	#temp_pd
SET	payto_address = pto_address1,
	payto_address2 = pto_address2,
	payto_city_state = ( SELECT city.cty_name + ', ' + city.cty_state FROM city WHERE cty_code = pto_city),
	payto_zip = pto_zip
FROM	payto,
	#temp_pd	
WHERE	payto.pto_id = #temp_pd.pyd_payto;

-- 08-AUG-2006 SWJ - PTS 32844 - Modified to pull full name from label file instead of just the abbreviation that's saved in manpowerprofile	
IF @drv_yes <> 'XXX'
	UPDATE	#temp_pd
	SET	terminal = labelfile.name
	FROM	manpowerprofile,
		labelfile
	WHERE	manpowerprofile.mpp_id = @drv_id
		AND manpowerprofile.mpp_teamleader = labelfile.abbr
		AND labeldefinition='TeamLeader'
else IF @trc_yes <> 'XXX' begin

	declare @v_teamleader as varchar(20)
	select @v_teamleader = max(mpp_teamleader )
	from #temp_pd p 
	join legheader l on p.lgh_number = l.lgh_number

	if @v_teamleader is null
		UPDATE	#temp_pd
		SET	terminal = ''
	else

		UPDATE	#temp_pd
		SET	terminal = labelfile.name
		FROM	labelfile
		where labelfile.abbr = @v_teamleader
			AND labeldefinition='TeamLeader'
end
else
	UPDATE	#temp_pd
	SET	terminal = ''

UPDATE  #temp_pd
SET	period_cutoff = CONVERT(VARCHAR(20), @payperiodstart, 101),
	check_date = CONVERT(VARCHAR(20), psd_chkissuedate, 101)
FROM 	payschedulesdetail  
WHERE	psd_date = @payperiodstart

-- vjh 35857
update #temp_pd set check_date = convert(varchar, @check_date, 101)

update #temp_pd set ord_enddate = pyd_transdate where ord_enddate is null
--update #temp_pd set lgh_startdate = pyd_transdate where lgh_startdate is null
update #temp_pd set display_date = pyd_transdate where lgh_number = 0 and display_date is null
update #temp_pd set display_date = pyd_transdate where pyd_number = 0 and display_date is null
-- Update any NULL terminal to the correct one
UPDATE	#temp_pd
SET	terminal = (	SELECT	TOP 1 terminal
			FROM	#temp_pd
			WHERE	terminal IS NOT NULL)
where terminal is null
-- Update any NULL check_date to the correct one
UPDATE	#temp_pd
SET	check_date = (	SELECT	TOP 1 check_date
			FROM	#temp_pd
			WHERE	check_date IS NOT NULL)
where check_date is null
-- Update any NULL pyh_payperiod to the correct one
UPDATE	#temp_pd
SET	pyh_payperiod = (	SELECT	TOP 1 pyh_payperiod
			FROM	#temp_pd
			WHERE	pyh_payperiod IS NOT NULL)
where pyh_payperiod is null
-- Update any NULL payperiodstart to the correct one
UPDATE	#temp_pd
SET	payperiodstart = (	SELECT	TOP 1 payperiodstart
			FROM	#temp_pd
			WHERE	payperiodstart IS NOT NULL)
where payperiodstart is null
-- Update any NULL payperiodend to the correct one
UPDATE	#temp_pd
SET	payperiodend = (	SELECT	TOP 1 payperiodend
			FROM	#temp_pd
			WHERE	payperiodend IS NOT NULL)
where payperiodend is null

--vjh 35427 need the paytoname, as was described on a different PTS
UPDATE	#temp_pd
SET	payto_name = isnull(pto_lname, '') + ', ' + isnull(pto_fname, '')
FROM	payto
WHERE	#temp_pd.pyd_payto = payto.pto_id

SELECT 	pyd_number, 
	pyh_number, 
	asgn_number, 
	tp.asgn_type, 
	tp.asgn_id, 
	ivd_number, 
	pyd_prorap, 
	pyd_payto,
	pyt_itemcode,
	pyd_description,	--10
	pyr_ratecode,		 
	pyd_quantity, 
	pyd_rateunit, 
	pyd_unit, 
	pyd_pretax, 
	pyd_status, 
	tp.pyh_payperiod, 
	lgh_startcity,
	lgh_endcity, 
	pyd_minus,		--20
	pyd_workperiod,		
	pyd_sequence,
	pyd_rate,
	round(pyd_amount, 2),
	pyd_payrevenue,
	mov_number,
	lgh_number,
	ord_hdrnumber,
	pyd_transdate,
	payperiodstart,		--30
	payperiodend,		
	pyd_loadstate,
	summary_code,
	isnull(name,'') name,
	terminal,
	type1,
	round(tp.pyh_totalcomp, 2),
	round(tp.pyh_totaldeduct, 2),
	round(tp.pyh_totalreimbrs, 2),
	ph.crd_cardnumber 'crd_cardnumber',	--40
	lgh_startdate,		
	std_balance,
	itemsection,
	ord_enddate,
	ord_number,
	ref_number,
	stp_arrivaldate,
	shipper_name,
	shipper_city,
	shipper_state,		--50
	consignee_name,		
	consignee_city,
	consignee_state,
	cmd_name,
	pyd_billedweight,	
	adjusted_billed_rate,
	pyd_payrevenue,
	cht_basisunit,
	pyt_description,	
	userlabelname,		--60
	label_name,
	otherid,
	pyt_fee1,
	pyt_fee2,
	start_city,
	start_state,
	end_city,
	end_state, 
       	ph.pyh_paystatus,	
	ref_number_tds,		--70
	pyd_offsetpay_number,	
	pyd_credit_pay_flag,
	total_miles,
	isnull(payto_address,'') payto_address,
	isnull(payto_address2,'') payto_address2,
	isnull(payto_city_state,'') payto_city_state,
	isnull(payto_zip,'') payto_zip,
	period_cutoff,
	check_date,
	ytd_amount,
	display_date,
	payto_name
  FROM 	#temp_pd tp
	LEFT OUTER JOIN payheader ph ON ph.pyh_pyhnumber = tp.pyh_number

GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_summary65] TO [public]
GO
