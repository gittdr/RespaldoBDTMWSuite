SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[d_settlement_sheet_summary_81](
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
 * d_settlement_sheet_summary_81
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Populates data for settlement sheet 81 for client Overnite Transportation
 *
 * LAST MODIFIED:
 * 09/10/2007  SLM - PTS 38290 - Created from d_settlement_sheet_summary_new
 * 07/01/2008  vjh - PTS 43440 - continue development to correct failures in Totals, YTD and Escrow.
 * 02/17/2009  vjh - PTS 45968 - Change logic to include date restriction on >100 itemcodes
 * 09/20/2012  sgb - PTS 61492 - Populate Tractor, Driver, Begin & End Dates and Pay Header number on summary rows
 */


-- jyang pts13004
Declare @PeriodforYTD Varchar(3)

--vjh 43440
declare @asgn_id	varchar(13)
declare @asgn_type	varchar(6)
declare	@sdm_itemcode	varchar(6)
declare @pyd_payto	varchar(40)
declare @ytdmiles	int

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
	pyd_payto		varchar(40) null, 
	pyt_itemcode	varchar(6) null, 
	pyd_description	varchar(75) null, 
	pyr_ratecode	varchar(6) null, 
	pyd_quantity	float null,		--extension (BTC)
	pyd_rateunit	varchar(6) null,
	pyd_unit		varchar(6) null,
	pyd_pretax		char(1) null,
	pyd_status		varchar(6) null,
	pyh_payperiod	datetime null,
	lgh_startcity	int null,
	lgh_endcity		int null,
	pyd_minus		int null,
	pyd_workperiod	datetime null,
	pyd_sequence	int null,
	pyd_rate		money null,		--rate (BTC)
	pyd_amount		money null,
	pyd_payrevenue	money null,		
	mov_number		int null,
	lgh_number		int null,
	ord_hdrnumber	int null,
	pyd_transdate	datetime null,
	payperiodstart	datetime null,
	payperiodend	datetime null,
	pyd_loadstate	varchar(6) null,
	summary_code	varchar(6) null,
	name			varchar(64) null,
	terminal		varchar(6) null,
	type1			varchar(6) null,
	pyh_totalcomp	money null,
	pyh_totaldeduct	money null,
	pyh_totalreimbrs	money null,
	crd_cardnumber	char(20) null, 
	lgh_startdate	datetime null,
	std_balance		money null,
	itemsection		int null,
	ord_startdate	datetime null,
	ord_number		char(12) null,
	ref_number		varchar(30) null,
	stp_arrivaldate	datetime null,
	shipper_name	varchar(30) null,
	shipper_city	varchar(18) null,
	shipper_state	char(2) null,
	consignee_name	varchar(30) null,
	consignee_city	varchar(18) null,
	consignee_state	char(2) null,
	cmd_name		varchar(60) null,
	pyd_billedweight	int null,		--billed weight (BTC)
	adjusted_billed_rate	money null,		--rate (BTC)
	cht_basis		varchar(6) null,
	cht_basisunit	varchar(6) null,
	cht_unit		varchar(6) null,
	cht_rateunit	varchar(6) null,
	std_number		int null,
	stp_number		int null,
	unc_factor		float null,
	stp_mfh_sequence	int null,
	pyt_description	varchar(30) null,
	cht_itemcode	varchar(6) null,
	userlabelname	varchar(20) null,
	label_name		varchar(20) null,
	otherid			varchar(8) null,
	pyt_fee1		money null,
	pyt_fee2		money null,
	start_city		varchar(18) null,
	start_state		char(2) null,
	end_city		varchar(18) null,
	end_state		char(2) null,
	lgh_count		int null,
	ref_number_tds	varchar(30) null,
	pyd_offsetpay_number	int null,
	pyd_credit_pay_flag	char(1) null,
	pyd_refnumtype	varchar(6) null,
	pyd_refnum		varchar(30) null,
	pyh_issuedate	datetime null,
	pyt_basis		varchar(6) null,
    address1		varchar(30) null,
    address2		varchar(30) null,
    citystate		varchar(25) null,
    zip				varchar(10) null,
    city			int null,
	ytdgrandtotal	money null,
	mpp_tractornumber varchar(8) null,
	ytdmiles		int	null)

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
	null, -- pyt_basis
    null,
    null,
    null,
    null,
    null,
    null,
    null,
	null
FROM paydetail pd, #temp_pay tp
WHERE pd.pyd_number = tp.pyd_number

--Update the temp pay details with legheader data
UPDATE #temp_pd
   SET lgh_startdate = (SELECT lgh_startdate 
                          FROM legheader lh
                         WHERE lh.lgh_number = #temp_pd.lgh_number)

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
   SET ord_number = right(ord_number,10) + '/S'
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

UPDATE #temp_pd
   SET shipper_name = co.cmp_name 
  FROM #temp_pd tp, company co,orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber
       AND oh.ord_shipper = co.cmp_id

UPDATE #temp_pd
   SET consignee_name = co.cmp_name
  FROM #temp_pd tp, company co,orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber
       AND oh.ord_consignee = co.cmp_id

--vjh lets use a better balance calculation.
----Update the temp pay details with standingdeduction data
--UPDATE #temp_pd
--   SET std_balance = (SELECT std_balance 
--                        FROM standingdeduction sd 
--                       WHERE sd.std_number = #temp_pd.std_number)

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


UPDATE #temp_pd
   SET itemsection = 2
 WHERE pyd_pretax = 'N'
       AND pyd_minus = 1

UPDATE #temp_pd
   SET itemsection = 3
 WHERE pyd_pretax = 'N'
       AND pyd_minus = -1

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

update #temp_pd
set pyt_basis = p.pyt_basis 
from #temp_pd tp, paytype p
where tp.pyt_itemcode = p.pyt_itemcode

update #temp_pd
set mpp_tractornumber = m.mpp_tractornumber
from #temp_pd, manpowerprofile m
where asgn_id = m.mpp_id


--JD 11605 delete fake routing paydetails
if exists (select * from generalinfo where gi_name = 'StlFindNextMTLeg' and gi_string1 = 'Y')
	delete #temp_pd from paydetail where #temp_pd.pyd_number = paydetail.pyd_number and paydetail.tar_tarriffnumber = '-1'

-- Create a temp table for Summary Data
CREATE TABLE #summary
	(itemsection   int null,
     asgn_type	   varchar(6) null,
     asgn_id       varchar(13)null,     
     pyt_itemcode  varchar(6) null,
     pyd_pretax    char(1) null, 
     pyd_minus     int null,
     terminal      varchar(6) null,
     pyd_quantity  float null,
     pyd_amount    money null,
     ytdgrandtotal money null,
     pyd_payto     varchar(40) null,
	 interest	   money	null,
	 std_number	   int		null)

--vjh 43440 walk through all asgn_id/asgn_type values to get distinct pay used any time this year

select @asgn_type = min(asgn_type) from #temp_pd

while @asgn_type is not null begin
	select @asgn_id = min(asgn_id) from #temp_pd where asgn_type = @asgn_type
	while @asgn_id is not null begin

		--vjh 45968 only THIS year
		if left(ltrim(@PeriodforYTD),1) = 'Y'
			INSERT into #summary
				 SELECT DISTINCT itemsection = 100, @asgn_type, @asgn_id, pd.pyt_itemcode, pd.pyd_pretax, pd.pyd_minus, terminal=@terminal, pyd_quantity = 0, pyd_amount = 0, ytdgrandtotal = 0, pd.pyd_payto, 0, 0
					from payheader ph
					join paydetail pd on ph.pyh_pyhnumber = pd.pyh_number
					where ph.asgn_type = @asgn_type
					and ph.asgn_id = @asgn_id
					and pd.pyd_status <> 'HLD'
					AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
		else
			INSERT into #summary
				 SELECT DISTINCT itemsection = 100, @asgn_type, @asgn_id, pd.pyt_itemcode, pd.pyd_pretax, pd.pyd_minus, terminal=@terminal, pyd_quantity = 0, pyd_amount = 0, ytdgrandtotal = 0, pd.pyd_payto, 0, 0
					from payheader ph
					join paydetail pd on ph.pyh_pyhnumber = pd.pyh_number
					where ph.asgn_type = @asgn_type
					and ph.asgn_id = @asgn_id
					and pd.pyd_status <> 'HLD'
					AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
					AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend

		select @asgn_id = min(asgn_id) from #temp_pd where asgn_type = @asgn_type AND asgn_id > @asgn_id
	end
	select @asgn_type = min(asgn_type) from #temp_pd where asgn_type > @asgn_type
end

UPDATE #summary
     SET itemsection = 110 
       FROM #summary
     where (pyd_pretax = 'N' and pyd_minus = 1)

UPDATE #summary
     SET itemsection = 120 
       FROM #summary
     where (pyd_pretax = 'N' and pyd_minus = -1)

UPDATE #summary
     SET pyd_quantity = (select sum(isnull(pd.pyd_quantity,0))
                        FROM #temp_pd pd
						 where s.asgn_type = pd.asgn_type and s.asgn_id = pd.asgn_id and
							   s.pyt_itemcode = pd.pyt_itemcode),
         pyd_amount = (select sum(isnull(pd.pyd_amount,0)) 
                        FROM #temp_pd pd
						 where s.asgn_type = pd.asgn_type and s.asgn_id = pd.asgn_id and
							   s.pyt_itemcode = pd.pyt_itemcode)
       FROM #summary s




--vjh 43440 walk through all standing deduction escrows

select @pyd_payto = min(pyd_payto) from #temp_pd

select @sdm_itemcode = min(sdm_itemcode) from stdmaster where sdm_escrowstyle='Y'
while @sdm_itemcode is not null begin
	select @asgn_type = min(asgn_type) from #temp_pd

	while @asgn_type is not null begin
		select @asgn_id = min(asgn_id) from #temp_pd where asgn_type = @asgn_type
		while @asgn_id is not null begin

				INSERT into #summary
					 SELECT DISTINCT itemsection = 130, @asgn_type, @asgn_id, sdm.sdm_itemcode, '', '', terminal=@terminal, pyd_quantity = 0, pyd_amount = 0, ytdgrandtotal = 0, @pyd_payto, 0, std.std_number
						from stdmaster sdm
						join standingdeduction std on sdm.sdm_itemcode = std.sdm_itemcode and std.asgn_type = @asgn_type and std.asgn_id = @asgn_id
					   where sdm.sdm_itemcode = @sdm_itemcode

			select @asgn_id = min(asgn_id) from #temp_pd where asgn_type = @asgn_type AND asgn_id > @asgn_id
		end
		select @asgn_type = min(asgn_type) from #temp_pd where asgn_type > @asgn_type
	end
	select @sdm_itemcode = min(sdm_itemcode) from stdmaster where sdm_escrowstyle='Y' and sdm_itemcode > @sdm_itemcode
end

--vjh - PTS 43440 - This logic pulls all detail ever paid, not the year to date amount
--UPDATE #summary
--     SET ytdgrandtotal = (select sum(isnull(pd.pyd_amount,0))
--                        FROM paydetail pd
--						 where s.asgn_type = pd.asgn_type and s.asgn_id = pd.asgn_id and
--							   s.pyt_itemcode = pd.pyt_itemcode)
--       FROM #summary s

if left(ltrim(@PeriodforYTD),1) = 'Y' begin
	UPDATE #summary
		 SET ytdgrandtotal = (select sum(isnull(pd.pyd_amount,0))
							FROM paydetail pd join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
							 where s.asgn_type = ph.asgn_type 
								and s.asgn_id = ph.asgn_id
								and s.pyt_itemcode = pd.pyt_itemcode 
								AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        		AND ph.pyh_payperiod < @payperiodend
                        		AND ph.pyh_paystatus <> 'HLD')
		   FROM #summary s
		  where itemsection <> 130
	UPDATE #summary
		 SET ytdgrandtotal = (select sum(isnull(pd.pyd_amount,0))
							FROM paydetail pd join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
							 where s.asgn_type = ph.asgn_type 
								and s.asgn_id = ph.asgn_id
								and s.std_number = pd.std_number 
								AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        		AND ph.pyh_payperiod < @payperiodend
                        		AND ph.pyh_paystatus <> 'HLD')
			,pyd_minus = (select min(isnull(pd.pyd_minus,0))
							FROM paydetail pd join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
							 where s.asgn_type = ph.asgn_type 
								and s.asgn_id = ph.asgn_id
								and s.std_number = pd.std_number 
								AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        		AND ph.pyh_payperiod < @payperiodend
                        		AND ph.pyh_paystatus <> 'HLD')			
			,pyd_pretax = (select min(isnull(pd.pyd_pretax,''))
							FROM paydetail pd join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
							 where s.asgn_type = ph.asgn_type 
								and s.asgn_id = ph.asgn_id
								and s.std_number = pd.std_number 
								AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        		AND ph.pyh_payperiod < @payperiodend
                        		AND ph.pyh_paystatus <> 'HLD')
			,pyd_amount = (select sum(isnull(pd.pyd_amount,0))
							FROM paydetail pd join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
							 where s.asgn_type = ph.asgn_type 
								and s.asgn_id = ph.asgn_id 
								and s.std_number = pd.std_number 
								and pd.pyt_itemcode='IT+'
								AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                        		AND ph.pyh_payperiod < @payperiodend
                        		AND ph.pyh_paystatus <> 'HLD')

		   FROM #summary s
		  where itemsection = 130
end else begin
	UPDATE #summary
		 SET ytdgrandtotal = (select sum(isnull(pd.pyd_amount,0))
							FROM paydetail pd join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
							 where s.asgn_type = ph.asgn_type 
								and s.asgn_id = ph.asgn_id 
								and s.pyt_itemcode = pd.pyt_itemcode
								AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        		AND ph.pyh_paystatus <> 'HLD')
		   FROM #summary s
	  where itemsection <> 130
	UPDATE #summary
		 SET ytdgrandtotal = (select sum(isnull(pd.pyd_amount,0))
							FROM paydetail pd join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
							 where s.asgn_type = ph.asgn_type 
								and s.asgn_id = ph.asgn_id 
								and s.std_number = pd.std_number 
								AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        		AND ph.pyh_paystatus <> 'HLD')
			,pyd_minus = (select min(isnull(pd.pyd_minus,0))
							FROM paydetail pd join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
							 where s.asgn_type = ph.asgn_type 
								and s.asgn_id = ph.asgn_id
								and s.std_number = pd.std_number 
								AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        		AND ph.pyh_paystatus <> 'HLD')
			,pyd_pretax = (select min(isnull(pd.pyd_pretax,''))
							FROM paydetail pd join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
							 where s.asgn_type = ph.asgn_type 
								and s.asgn_id = ph.asgn_id
								and s.std_number = pd.std_number 
								AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        		AND ph.pyh_paystatus <> 'HLD')
			,pyd_amount = (select sum(isnull(pd.pyd_amount,0))
							FROM paydetail pd join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
							 where s.asgn_type = ph.asgn_type 
								and s.asgn_id = ph.asgn_id 
								and s.std_number = pd.std_number 
								and pd.pyt_itemcode='IT+'
								AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        		AND ph.pyh_paystatus <> 'HLD')

		   FROM #summary s
	  where itemsection = 130
END

--PTS 61492 SGB - BEGIN
/*
INSERT INTO #temp_pd  (pyd_number, pyh_number, itemsection, asgn_type, asgn_id, pyt_itemcode, pyd_pretax, pyd_minus, terminal, pyd_quantity, pyd_amount, ytdgrandtotal, pyd_payto, std_number)
       SELECT 9,9, s.itemsection, s.asgn_type, s.asgn_id, s.pyt_itemcode, s.pyd_pretax, s.pyd_minus, s.terminal, s.pyd_quantity, s.pyd_amount, s.ytdgrandtotal, s.pyd_payto, s.std_number
       FROM #summary s
       */
-- Added Begin and End Dates  Changed pyh_number from 9 to @pyh_number
INSERT INTO #temp_pd  (pyd_number, pyh_number, itemsection, asgn_type, asgn_id, pyt_itemcode, pyd_pretax, pyd_minus, terminal, pyd_quantity, pyd_amount, ytdgrandtotal, pyd_payto, std_number,payperiodstart,payperiodend)
       SELECT 9,@pyhnumber, s.itemsection, s.asgn_type, s.asgn_id, s.pyt_itemcode, s.pyd_pretax, s.pyd_minus, s.terminal, s.pyd_quantity, s.pyd_amount, s.ytdgrandtotal, s.pyd_payto, s.std_number,@payperiodstart,@payperiodend
       FROM #summary s
       
UPDATE  #temp_pd
SET mpp_tractornumber = (select max(pd2.mpp_tractornumber) 
						from #temp_pd pd2)
where mpp_tractornumber is NULL						
						
       
--PTS 61492  SGB - END

-- Moved from above
-- Get payto complete address
update #temp_pd
set pyd_payto = LTrim(p.pto_lname) + ', ' + LTrim(p.pto_fname),
    address1 = p.pto_address1,
    address2 = p.pto_address2,
    zip = p.pto_zip, 
    city = p.pto_city
from #temp_pd tp, payto p
where tp.pyd_payto = p.pto_id and p.pto_id <> 'UNKNOWN'

update #temp_pd
set citystate = LTrim(c.cty_name) + ', ' + c.cty_state
from #temp_pd tp, city c
where tp.city = c.cty_code

--vjh lets use a better balance calculation.
--Update the temp pay details with standingdeduction data
UPDATE #temp_pd
   SET std_balance = (
		select dbo.standingdeduction.std_balance * (case when dbo.standingdeduction.std_startbalance = 0 and dbo.standingdeduction.std_endbalance = 0 then -1 
														   when dbo.stdmaster.sdm_minusbalance = 'N' then 1 else -1 end) 
		from standingdeduction
		join stdmaster on stdmaster.sdm_itemcode = standingdeduction.sdm_itemcode
		where standingdeduction.std_number = #temp_pd.std_number
)
where itemsection = 130

update #temp_pd set ytdmiles = 7


--vjh walk through all asgn ID/Types to get YTD miles
select @asgn_type = min(asgn_type) from #temp_pd

while @asgn_type is not null begin
	select @asgn_id = min(asgn_id) from #temp_pd where asgn_type = @asgn_type
	while @asgn_id is not null begin

		if left(ltrim(@PeriodforYTD),1) = 'Y' begin
			update #temp_pd set ytdmiles = (select sum(isnull(pd.pyd_quantity,0))
				FROM paydetail pd 
				join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
				join paytype p on pd.pyt_itemcode = p.pyt_itemcode
				where ph.asgn_type = @asgn_type
				and ph.asgn_id = @asgn_id
				AND ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodend)
                AND ph.pyh_payperiod < @payperiodend
                AND ph.pyh_paystatus <> 'HLD'
				and p.pyt_basis = 'LGH'
				and	(pd.pyd_loadstate  = 'UNLD' or 
					pd.pyd_loadstate  =  'MT' or 
					pd.pyd_loadstate  = 'LD' )
				and pd.pyd_unit = 'MIL'
			)
			where #temp_pd.asgn_type = @asgn_type and #temp_pd.asgn_id = @asgn_id
		end else begin
			update #temp_pd set ytdmiles = (select sum(isnull(pd.pyd_quantity,0))
				FROM paydetail pd 
				join payheader ph on ph.pyh_pyhnumber = pd.pyh_number
				join paytype p on pd.pyt_itemcode = p.pyt_itemcode
				where ph.asgn_type = @asgn_type
				and ph.asgn_id = @asgn_id
				AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                AND ph.pyh_paystatus <> 'HLD'
				and p.pyt_basis = 'LGH'
				and	(pd.pyd_loadstate  = 'UNLD' or 
					pd.pyd_loadstate  =  'MT' or 
					pd.pyd_loadstate  = 'LD' )
				and pd.pyd_unit = 'MIL'
			)
			where #temp_pd.asgn_type = @asgn_type and #temp_pd.asgn_id = @asgn_id
		end

		select @asgn_id = min(asgn_id) from #temp_pd where asgn_type = @asgn_type AND asgn_id > @asgn_id
	end
	select @asgn_type = min(asgn_type) from #temp_pd where asgn_type > @asgn_type
end


SELECT pyd_number, 
	pyh_number, 
	asgn_number, 
	tp.asgn_type, 
	tp.asgn_id, 
	ivd_number, 
	pyd_prorap, 
	'Pay to: ' + pyd_payto,
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
	tp.asgn_type + ': ' + tp.asgn_id + ' ' + @name 'name',
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
	pyd_refnumtype,
	pyd_refnum,
	pyt_basis,
    address1,
    address2,
    citystate,
    zip,
    Round(ytdgrandtotal,2) 'ytdgrandtotal',
    'Tractor: ' + mpp_tractornumber 'mpp_tractornumber',
	ytdmiles
  FROM #temp_pd tp
			left outer join payheader ph  on tp.pyh_number = ph.pyh_pyhnumber

GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_summary_81] TO [public]
GO
