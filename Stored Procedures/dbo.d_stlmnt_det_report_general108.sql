SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_stlmnt_det_report_general108](
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
 * 11/02/2007.01 - PTS40116 - JGUO convert old style outer join syntax to ansi outer join syntax.
 * 06/12/2009 - PTS 46836 - Created ( using General as the basis ).
 * 07/22/2009 - PTS 46836 fix.  Changed how ref#'s are pulled/displayed.
 * 08/24/2009 - PTS 48755 (Client deceided to use Flat rates instead of revenue.)
 * 08/31/2009 - PTS 48755 (Changes to proc to match client site changes. look for 8/31/09)
 * 10/16/2008 - PTS 49239 (add list of all consignee's (drops) to descr for flat paydetails)
 * 06/28/2010 - vjh 52725 check in Jeremy's changes.
 * 07/16/2010 - PTS 53212 Client decided to have descriptions print for manually entered/altered lines and not be nulled out when
 *                        pyt_itemcode = 'FLAT' and any of the following columns are not null - shipper_city, consignee_name, end_city.
 **/
SET NOCOUNT ON
-- jyang pts13004
Declare @PeriodforYTD Varchar(3)

--vmj1+	PTS 17099	04/03/2003	The isnull below works if a row is returned which has
--a null value for that column, but NOT if no row is returned.  Pre-set the value, so a 
--no-row select below will leave that value untouched..
select	@PeriodForYtd = 'no'
--vmj1-

SELECT @PeriodforYTD = isnull(gi_string1,'no') 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'

-- Create a temp table to the pay header and detail numbers
CREATE TABLE #temp_pay (
	pyd_number int not null,
	pyh_number int not null,
	pyd_status varchar(6) null,
	asgn_type1 varchar(6) null) 

-- LOR PTS# 6404 elliminate trial and final settlement sheets - do just one
IF @hld_yes = 'Y' 
--IF @report_type = 'TRIAL'
BEGIN
	-- Get the driver pay header and detail numbers for held pay
	IF @drv_yes != 'XXX'
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
	IF @trc_yes != 'XXX'
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
	IF @car_yes != 'XXX'
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
	IF @trl_yes != 'XXX'
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
END

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
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
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
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
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
	  	AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		AND pyh_number = 0

	-- LOR  PTS# 5744 add trailer settlements
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
	  		AND pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pyh_number = 0
END

IF @relcol  = 'Y' and @relncol = 'N'
BEGIN
--IF @report_type = 'FINAL'
	-- Get the driver pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @drv_yes != 'XXX'
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
	IF @trc_yes != 'XXX'
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
	IF @car_yes != 'XXX'
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
	IF @trl_yes != 'XXX'
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
	pyd_payto		varchar(12) null, -- changed from 6 to 12 for PTS #5849, JET - 6/10/99
	pyt_itemcode		varchar(6) null, 
-- PTS 29303 -- BL (start)	
--	pyd_description		varchar(30) null, 
--	pyd_description		varchar(75) null,		-- PTS 49239  10/16/09
	pyd_description		varchar(800) null,		-- PTS 49239  need more work space.
-- PTS 29303 -- BL (end)	
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
	--ord_number		char(12) null,
	ord_number			char(20) null,  -- PTS 46836 
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
	pyt_fee1		money null,
	pyt_fee2		money null,
	start_city		varchar(18) null,
	start_state		char(2) null,
	end_city		varchar(18) null,
	end_state		char(2) null,
	lgh_count		int null,
	ref_number_tds		varchar(30) null,
	pyd_offsetpay_number	int null,
	pyd_credit_pay_flag	char(1) null,
	pyd_refnumtype             varchar(6) null,
	pyd_refnum              varchar(30) null,
	pyh_issuedate		datetime null,
	pyt_basis		varchar(6) null,				-- PTS 29515 -- BL
	generic_ALT_ID			varchar(30) null,		-- PTS 46836
	real_stp_number			int null,				-- PTS 46836
	ls_reference_numbers	varchar(200) null,		-- PTS 46836
	ldt_sortdate				datetime null,		-- PTS 46836
	det_date_time				datetime null,		-- PTS 46836
	pyt_basisunit			varchar(6) null,		-- PTS 46836	
	CC_IDENTITY				INT IDENTITY			-- PTS 46836
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
	null,	-- pyt_basis  -- PTS 29515 -- BL 
	null,	-- generic_ALT_ID		 -- PTS 46836
	stp_number as 'real_stp_number', -- PTS 46836
	null,	-- ls_reference_numbers	 -- PTS 46836
	null,	-- ldt_sortdate			 -- PTS 46836
	null,	-- det_date_time 		 -- PTS 46836	
	(select pyt_basisunit from paytype where pyt_itemcode = pd.pyt_itemcode) as 'pyt_basisunit'	-- PTS 46836		
		
FROM paydetail pd, #temp_pay tp
WHERE pd.pyd_number = tp.pyd_number

-- PTS 46836 <<start>>
IF @drv_yes != 'XXX'
BEGIN
	Update #temp_pd
	Set generic_ALT_ID  = (select mpp_otherid from manpowerprofile where mpp_id = #temp_pd.asgn_id) 
END

-- 08/31/2009 - PTS 48755 comment out this code
--IF @trc_yes != 'XXX'
--BEGIN
--	Update #temp_pd
--	Set generic_ALT_ID  = (select trc_otherid  from  tractorprofile where trc_number = #temp_pd.asgn_id) 
--END

IF @car_yes != 'XXX'
BEGIN
	Update #temp_pd
	Set generic_ALT_ID  = (select car_otherid  from  carrier where car_id = #temp_pd.asgn_id) 
END

-- 08/31/2009 - PTS 48755 comment out this code
--IF @trl_yes != 'XXX'
--BEGIN
--	--no alt ID on the trailer file.
--	Update #temp_pd 
--	Set generic_ALT_ID  = ''
--END

-----------  no third party ? No. -------
--IF @TPR_yes != 'XXX'
--BEGIN
--Update #temp_pd
--	Set generic_ALT_ID  = (select  tpr_otherid  from  thirdpartyprofile   where tpr_id,    = #temp_pd.asgn_id) 
--END
-- PTS 46836 <<end>>

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

--Update the temp pay details with orderheader data
UPDATE #temp_pd
   SET ord_startdate = oh.ord_startdate,
       ord_number = oh.ord_number
  FROM #temp_pd tp, 
       orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber

--Update the temp, for split trips, set ord_number = ord_number + '/S'
UPDATE #temp_pd
   SET ord_number = Ltrim(RTrim(ord_number)) + '/S'
 WHERE ord_hdrnumber > 0 
       AND lgh_count > 1 -- JET - 5/28/99 - PTS #5788, this was set to 0 and I changed it to 1


--JD #11490 09/24/01
UPDATE #temp_pd
SET    shipper_city = ct.cty_name,
	   shipper_state = ct.cty_state
  FROM #temp_pd tp, city ct, orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber
       AND oh.ord_origincity = ct.cty_code


UPDATE #temp_pd
SET    consignee_city = ct.cty_name,
	   consignee_state = ct.cty_state
  FROM #temp_pd tp, city ct, orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber
       AND oh.ord_destcity = ct.cty_code

-- PTS 49239  Size issue
-- cmp name is x(100), shipper_name is x(30)
UPDATE #temp_pd
   --SET shipper_name = co.cmp_name 
	 SET shipper_name = substring(co.cmp_name, 1, 30) 
  FROM #temp_pd tp, company co,orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber
       AND oh.ord_shipper = co.cmp_id

-- PTS 49239  Size issue
UPDATE #temp_pd
   --SET consignee_name = co.cmp_name
	 SET consignee_name = substring(co.cmp_name, 1, 30) 
  FROM #temp_pd tp, company co,orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber
       AND oh.ord_consignee = co.cmp_id

--Update the temp pay details with standingdeduction data
UPDATE #temp_pd
   SET std_balance = (SELECT std_balance 
                        FROM standingdeduction sd 
                       WHERE sd.std_number = #temp_pd.std_number)

--Update the temp pay details for summary code
UPDATE #temp_pd
   SET summary_code = 'OTHER'
 WHERE summary_code != 'MIL'

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

--Create a temp table for YTD balances
CREATE TABLE #ytdbal (asgn_type	varchar (6) not null,
	asgn_id			varchar (13) not null,
	ytdcomp			money null,
	ytddeduct		money null,
	ytdreimbrs		money null,
	pyh_payperiod		datetime null,
	pyh_issuedate		datetime null)

--Insert into the temp YTD balances table the assets from the temp pay details table
INSERT INTO #ytdbal
     SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
       FROM #temp_pd

--Compute the YTD balances for each assets
--LOR	fixed null problem SR 7095
--JYang pts13004
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
end else begin
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
	

-- Expense Reimbursements (section)
UPDATE #temp_pd
   SET itemsection = 2
 WHERE pyd_pretax = 'N'
       AND pyd_minus = 1

-- Settlement Deductions (section)
UPDATE #temp_pd
   SET itemsection = 3
 WHERE pyd_pretax = 'N'
       AND pyd_minus = -1

-- 4 = "Overdrawn" (section)
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
update #temp_pd
set pyt_basis = p.pyt_basis 
from #temp_pd tp, paytype p
where tp.pyt_itemcode = p.pyt_itemcode
-- PTS 29515 -- BL (end)

--JD 11605 delete fake routing paydetails
if exists (select * from generalinfo where gi_name = 'StlFindNextMTLeg' and gi_string1 = 'Y')
	delete #temp_pd from paydetail where #temp_pd.pyd_number = paydetail.pyd_number and paydetail.tar_tarriffnumber = '-1'

--============================= Start of REFERENCE NUMBERS section -- PTS 46836 6-17-09
---- * 07/22/2009 - PTS 46836 fix.  Changed  this ENTIRE section.

declare @Maxlsrowcnt int
declare @BLloopCnt int
declare @work_CC_IDENTITY int
declare @work_ord_hdrnumber int
declare @next_ord_hdrnumber int
declare @work_string varchar(200)

create table #temp_refnums (lsrowcnt int identity not null primary key clustered, ord_hdrnumber int, REF_NUMBER varchar(30) null) 
create table #temp_distinct_ord_hdrnumber (lsrowcnt int identity not null primary key clustered, ord_hdrnumber int) 

insert into #temp_distinct_ord_hdrnumber (ord_hdrnumber)
select  distinct(ord_hdrnumber)  from  #temp_pd

-----------ref_type + ': ' + REF_NUMBER 

insert into #temp_refnums (ord_hdrnumber, REF_NUMBER)
--select  referencenumber.ord_hdrnumber, REF_NUMBER
select  referencenumber.ord_hdrnumber, ref_type + ': ' + REF_NUMBER 
from referencenumber
where ref_table = 'stops'
AND ref_type = 'DEL#'		
and referencenumber.ord_hdrnumber in (select distinct(ord_hdrnumber) from #temp_distinct_ord_hdrnumber )
order by ref_table, ref_tablekey, REF_SEQUENCE

---------------------------------------
set @BLloopCnt = 0
SET @Maxlsrowcnt = 0 
set @work_ord_hdrnumber = null
---------------------------------------

SET @Maxlsrowcnt = ( select max(lsrowcnt) from #temp_refnums ) 
If @Maxlsrowcnt > 0
BEGIN

	set @BLloopCnt = 1
	set @work_ord_hdrnumber = (select ord_hdrnumber from #temp_refnums where lsrowcnt = @BLloopCnt) 
	set @next_ord_hdrnumber = (select ord_hdrnumber from #temp_refnums where lsrowcnt = @BLloopCnt) 

	SET @work_string = ''
	While @BLloopCnt <= @Maxlsrowcnt
	BEGIN

			IF @next_ord_hdrnumber <> @work_ord_hdrnumber
					BEGIN 
						IF LEN(@work_string) > 1 
							begin
								-- clean up the list.		
								SET @work_string = LTRIM(RTRIM(SUBSTRING(@work_string, 1, LEN(@work_string)-1)))
							end

						IF @work_string IS not NULL
							begin			
								set @work_CC_IDENTITY	= (select min(CC_IDENTITY) from  #temp_pd  where ord_hdrnumber = @work_ord_hdrnumber) 	
								UPDATE  #temp_pd
								SET ls_reference_numbers = LTRIM(RTRIM(@work_string)) 								
								WHERE CC_IDENTITY = @work_CC_IDENTITY								
								set @work_ord_hdrnumber = @next_ord_hdrnumber
								set @work_string = ''
							end
					END 	

				IF @next_ord_hdrnumber = @work_ord_hdrnumber
					Begin
						Set @work_string = @work_string + (select REF_NUMBER from #temp_refnums where lsrowcnt = @BLloopCnt ) + ', '
						Set @BLloopCnt = @BLloopCnt + 1
						set @next_ord_hdrnumber = (select ord_hdrnumber from #temp_refnums where lsrowcnt = @BLloopCnt) 				
					End	

----------------

			-- CATCH the last Write...
			IF @BLloopCnt > @Maxlsrowcnt
			  BEGIN 
					IF LEN(@work_string) > 1 
						begin
							-- clean up the list.		
							SET @work_string = LTRIM(RTRIM(SUBSTRING(@work_string, 1, LEN(@work_string)-1)))
						end

					IF @work_string IS not NULL
						begin		
							set @work_CC_IDENTITY	= (select min(CC_IDENTITY) from  #temp_pd  where ord_hdrnumber = @work_ord_hdrnumber) 
							UPDATE  #temp_pd
							SET ls_reference_numbers = LTRIM(RTRIM(@work_string)) 								
							WHERE CC_IDENTITY = @work_CC_IDENTITY	
						end
				END 				
---------------------------------------------------------		
	END	-- end while	
END	-- end IF

--============================= End of REFERENCE NUMBERS section -- PTS 46836 6-17-09


---------------------------- * PTS 46836 change the DESCRIPTION for Calculated Revenue items.
-- PTS 48755 (Client deceided to use Flat rates instead of revenue.)
--update #temp_pd
--set pyd_description = shipper_city + '- ' + consignee_name + ' ' + end_city
--where pyt_basisunit = 'CREV'

update #temp_pd
set pyd_description = shipper_city + '- ' + consignee_name + ' ' + end_city
where pyt_itemcode = 'FLAT'
and ( shipper_city is not null or consignee_name is not null or end_city is not null )  --PTS 53212
----------------------------

-- PTS 49239  10/16/09  << START >>
-- Add list of all consignee's (drops) to descr for flat paydetails
-- Show  1st live load and ALL Drop Stops 

create table #temp_distinct_lgh_number(lsrowcnt int identity not null primary key clustered, lgh_number int, drop_stops varchar(200) ) 

insert into #temp_distinct_lgh_number (lgh_number)
select distinct(lgh_number) 
from #temp_pd  
where lgh_number > 0 and pyt_itemcode = 'FLAT' 
order by lgh_number

update #temp_distinct_lgh_number
set drop_stops = ''
---------------------------------------
declare @test varchar(800)
select @test = ''
set @BLloopCnt = 0
SET @Maxlsrowcnt = ( select max(lsrowcnt) from #temp_distinct_lgh_number ) 
declare @work_lgh_number int
---------------------------------------

If @Maxlsrowcnt > 0
BEGIN
	set @BLloopCnt = 1
	
	SET @work_string = ''
	While @BLloopCnt <= @Maxlsrowcnt
		BEGIN
		select @test = ''
		select @work_lgh_number = (select lgh_number from #temp_distinct_lgh_number where @BLloopCnt = lsrowcnt) 
 
			select @test = @test + stops.cmp_name + ' ' + city.cty_name + ', ' 
			from stops 
			join city on stops.stp_city = city.cty_code
			where stp_type = 'DRP'  
			and stops.lgh_number = @work_lgh_number
			order by stops.lgh_number, stops.stp_mfh_sequence

			update #temp_distinct_lgh_number
			set drop_stops = @test
			where @BLloopCnt = lsrowcnt

			-- 11-5-2009 fix substring error messsage 	
			--set @test = LTRIM(RTRIM(SUBSTRING(@test, 1, LEN(@test)-1)))	-- remove final comma.			
			IF LEN(@test) > 1 
			Begin
				set @test = LTRIM(RTRIM(SUBSTRING(@test, 1, LEN(@test)-1)))	-- remove final comma.
			End	

			update #temp_pd
			set pyd_description = shipper_city + '- ' +  @test 			
			where #temp_pd.lgh_number = @work_lgh_number
			and  lgh_number > 0 and pyt_itemcode = 'FLAT' 

			Set @BLloopCnt = @BLloopCnt + 1

		END	-- end while	
END	-- end IF

-- PTS 49239  10/16/09  << END >>
----------------------------

-- PTS 46836 prepare for sorting like the dwo does to control Ord# + ref# printing.
update #temp_pd
set ldt_sortdate = lgh_startdate

update #temp_pd
set ldt_sortdate = pyd_transdate
where lgh_startdate IS null

Update #temp_pd
set det_date_time = ord_startdate

Update #temp_pd
--set det_date_time = pyd_transdate
--JKIRK changed below
--set det_date_time = dateadd(ss,86399,pyd_transdate)
set pyd_transdate = dateadd(ss,86399,pyd_transdate)
where ord_startdate is null 
OR (pyt_itemcode like 'ADV%')
OR (pyt_itemcode in ('LDMNY', 'FULTRC', 'FULTRL')) 

----------------------------

SELECT pyd_number, 
	pyh_number, 
	asgn_number, 
	tp.asgn_type, 
	tp.asgn_id, 
	ivd_number, 
	pyd_prorap, 
	pyd_payto,
	pyt_itemcode,	
	--pyd_description,   --PTS 49239  (set size back again)
	cast( pyd_description as varchar(200)) 'pyd_description',  --PTS 49239 
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
	round(pyd_amount, 2) 'pyd_amount',
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
	round(tp.pyh_totalcomp, 2) 'pyh_totalcomp',
	round(tp.pyh_totaldeduct, 2) 'pyh_totaldeduct',
	round(tp.pyh_totalreimbrs, 2)'pyh_totalreimbrs',
	ph.crd_cardnumber 'crd_cardnumber',
	lgh_startdate,
	std_balance,
	itemsection,
	ord_startdate,
	Cast(ord_number as varchar(12)) 'ord_number',    -- pts 46836
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
	pyd_payrevenue 'pyd_payrevenue1',
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
	pyt_basis,  -- PTS 29515 BL 
	--pyt_basisunit,															-- PTS 46836
	generic_ALT_ID,																-- PTS 46836
	--real_stp_number,															-- PTS 46836
	ISNULL (LTRIM(RTRIM(ls_reference_numbers)), '') as 'ls_reference_numbers',  -- PTS 46836
	cast('' as char(1)) 'ls_first_line',  										-- PTS 46836	
	IDENTITY(int, 1,1) AS 'ID_Num'												-- PTS 46836

	INTO #temp_sorted_output	
	FROM #temp_pd tp LEFT OUTER JOIN payheader ph ON tp.pyh_number = ph.pyh_pyhnumber
	ORDER BY itemsection Asc, 
			 pyd_pretax Desc,
			 pyd_minus Desc,
			 det_date_time Asc,
			 ord_hdrnumber Asc,
			 ldt_sortdate Asc ,
			 lgh_number Asc,
			 pyd_sequence Asc

select min(id_num) 'ID_Num', ord_hdrnumber
into #temp_1
from #temp_sorted_output
where itemsection = 0
group by ord_hdrnumber

update #temp_sorted_output	
set ls_first_line = 'Y'
where ID_Num in (select ID_NUM from #temp_1) 

--============================= Final result set:
select * from #temp_sorted_output


GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_det_report_general108] TO [public]
GO
