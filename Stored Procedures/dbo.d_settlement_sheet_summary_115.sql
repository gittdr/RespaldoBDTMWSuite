SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_settlement_sheet_summary_115](
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
 * Created for PTS 55374 - tmeze - Proc copied from d_settlement_sheet_summary_88 and modified to meet
 * SR requirements
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
 *
 **/

-- jyang pts13004
Declare @PeriodforYTD Varchar(3)

--SELECT @PeriodforYTD = isnull(gi_string1,'no')  
SELECT @PeriodforYTD = Left(isnull(gi_string1,'N') ,1) 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'
Select @PeriodforYTD = IsNull(@PeriodforYTD,'N')

DECLARE	@empty_miles	float,
	@loaded_miles	float,
	@total_miles	float, 
	@OrdCnt         INT,
	@MinMov			INT, 
	@MinOrd			INT,
	@MaxOrd			INT,
	@MaxOrdDate     datetime

SELECT	@empty_miles = 0,
	@loaded_miles = 0,
	@total_miles = 0

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
	pyd_number			int not null,
	pyh_number			int not null,
	asgn_number			int null,
	asgn_type			varchar(6) not null,
	asgn_id				varchar(13) not null,
	ivd_number			int null,
	pyd_prorap			varchar(6) null, 
	pyd_payto			varchar(12) null,
	pyt_itemcode		varchar(6) null, 
	pyd_description		varchar(30) null,		--10
	pyr_ratecode		varchar(6) null, 
	pyd_quantity		float null,
	pyd_rateunit		varchar(6) null,
	pyd_unit			varchar(6) null,
	pyd_pretax			char(1) null,
	pyd_status			varchar(6) null,
	pyh_payperiod		datetime null,
	lgh_startcity		int null,
	lgh_endcity			int null,
	pyd_minus			int null,				--20
	pyd_workperiod		datetime null,
	pyd_sequence		int null,
	pyd_rate			money null,
	pyd_amount			money null,
	pyd_payrevenue		money null,		
	mov_number			int null,
	lgh_number			int null,
	ord_hdrnumber		int null,
	pyd_transdate		datetime null,
	payperiodstart		datetime null,			--30
	payperiodend		datetime null,
	pyd_loadstate		varchar(6) null,
	summary_code		varchar(6) null,
	name				varchar(64) null,
	terminal			varchar(6) null,
	type1				varchar(6) null,
	pyh_totalcomp		money null,
	pyh_totaldeduct		money null,
	pyh_totalreimbrs	money null,
	crd_cardnumber		char(20) null,			--40
	lgh_startdate		datetime null,
	std_balance			money null,
	itemsection			int null,
	ord_startdate		datetime null,
	ord_number			char(12) null,
	ref_number			varchar(30) null,
	stp_arrivaldate		datetime null,
	shipper_name		varchar(30) null,
	shipper_city		varchar(18) null,
	shipper_state		char(2) null,			--50
	consignee_name		varchar(30) null,
	consignee_city		varchar(18) null,
	consignee_state		char(2) null,
	cmd_name			varchar(60) null,
	pyd_billedweight	int null,
	adjusted_billed_rate	money null,	
	cht_basis			varchar(6) null,
	cht_basisunit		varchar(6) null,
	cht_unit			varchar(6) null,
	cht_rateunit		varchar(6) null,		--60
	std_number			int null,
	stp_number			int null,
	unc_factor			float null,
	stp_mfh_sequence	int null,
	pyt_description		varchar(30) null,
	cht_itemcode		varchar(6) null,
	userlabelname		varchar(20) null,
	label_name			varchar(20) null,
	otherid				varchar(8) null,
	pyt_fee1			money null,				--70
	pyt_fee2			money null,
	start_city			varchar(18) null,
	start_state			char(2) null,
	end_city			varchar(18) null,
	end_state			char(2) null,
	lgh_count			int null,
	ref_number_tds		varchar(30) null,
	pyd_offsetpay_number	int null,
	pyd_credit_pay_flag	char(1) null,
	pyd_refnumtype		varchar(6) null,		--80
	pyd_refnum			varchar(30) null,
	total_empty_miles	float null,
	total_loaded_miles	float null,
	grand_total_miles	float null,
	empty_miles			float null,
	loaded_miles		float null,
	total_miles			float null,
	address_lastfirst	varchar(45) null,  
	address_address1	varchar(30) null,
	address_address2	varchar(30) null,		--90
	address_city		int null,
	address_nmst		varchar(25) null,
	address_zip			char(9) null,
	pyh_issuedate		datetime null,
	trl_type1			varchar(6) null,
	orderdetailsort		int null,
	pyd_gst_amount		money null,
	YTDGST				money null,
	OO_id				varchar(13) null,
	OO_name				varchar(64) null,
	ident				int identity,
	pyt_basis			varchar(6))	

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
	pd.pyd_description,		--10
	pd.pyr_ratecode,
	pd.pyd_quantity,
	pd.pyd_rateunit, 
	pd.pyd_unit,
	pd.pyd_pretax,
	tp.pyd_status,
	pd.pyh_payperiod,
	pd.lgh_startcity,
	pd.lgh_endcity,
	pd.pyd_minus,			--20
	pd.pyd_workperiod,
	pd.pyd_sequence,
	pd.pyd_rate,
	ROUND(pd.pyd_amount, 2),
	pd.pyd_payrevenue,
	pd.mov_number,
	pd.lgh_number,
	pd.ord_hdrnumber,
	pd.pyd_transdate,
	@payperiodstart,		--30
	@payperiodend,
	pd.pyd_loadstate,
	pd.pyd_unit,
	@name,
	@terminal,
	tp.asgn_type1,
	0.0,
	0.0,
	0.0,
	null,					--40
	null,
	null,
	0,
	null,
	null,
	null,
	null,
	null,
	null,
	null,					--50
	null,
	null,
	null,
	null,
	pd.pyd_billedweight,
	0.0,
	null,
	null,
	null,
	null,					--60
	pd.std_number,
	null,
	1.0,
	null,
	null,
	pd.cht_itemcode,
	null,
	null,
	null,
	pd.pyt_fee1,			--70
	pd.pyt_fee2,
	null,
	null,
	null,
	null,
	0,
	null,
	pyd_offsetpay_number,
	pyd_credit_pay_flag,
	pyd_refnumtype,			--80
	pyd_refnum,
	0,
	0,
	0,
	0,
	0,
	0,
	null,  
	null,
	null,					--90
	null,
	null,
	null,
	null,
	null,				--vjh 39688 trl_type1
	1,					--vjh 39688 orderdetailsort
	pyd_gst_amount,		--vjh 39688
	0,					--vjh 39688 YTDGST
	'',					--vjh 41736 owner operator (drv) id
	'',					--vjh 41736 owner operator (drv) name		--100
	pt.pyt_basis
 FROM paydetail pd
	  left outer join paytype pt ON pt.pyt_itemcode = pd.pyt_itemcode,
	 #temp_pay tp
	
WHERE pd.pyd_number = tp.pyd_number

--vjh 39688 - walk through all orders > 0, and insert rows with the description and qty form the freight detail
--			  set orderdetailsort to 2 so that they show up at the end of each order.
select @minord = min(ord_hdrnumber) from #temp_pd where ord_hdrnumber > 0
declare @minident int
while @minord is not null begin
	select @minident = min(ident) from #temp_pd where ord_hdrnumber = @minord


	INSERT INTO #temp_pd
	SELECT 
		pd.pyd_number,
		pd.pyh_number,
		pd.asgn_number,
		pd.asgn_type,
		pd.asgn_id,
		pd.ivd_number,
		pd.pyd_prorap,
		pd.pyd_payto,
		pd.pyt_itemcode,
		f.fgt_description,		--10
		pd.pyr_ratecode, 
		case
			when fgt_count is not null and fgt_count > 0 then fgt_count
			when fgt_weight is not null and fgt_weight > 0 then fgt_weight
			when fgt_volume is not null and fgt_volume > 0 then fgt_volume
			else null
		end,
		pd.pyd_rateunit,
		pd.pyd_unit,
		pd.pyd_pretax,
		pd.pyd_status,
		pd.pyh_payperiod,
		pd.lgh_startcity,
		pd.lgh_endcity,
		pd.pyd_minus,				--20
		pd.pyd_workperiod,
		pd.pyd_sequence,
		pd.pyd_rate,
		pd.pyd_amount,
		pd.pyd_payrevenue,
		pd.mov_number,
		pd.lgh_number,
		pd.ord_hdrnumber,
		pd.pyd_transdate,
		pd.payperiodstart,			--30
		payperiodend,
		pd.pyd_loadstate,
		pd.summary_code,
		pd.name,
		pd.terminal,
		pd.type1,
		pd.pyh_totalcomp,
		pd.pyh_totaldeduct,
		pd.pyh_totalreimbrs,
		pd.crd_cardnumber,			--40
		pd.lgh_startdate,
		pd.std_balance,
		pd.itemsection,
		pd.ord_startdate,
		pd.ord_number,
		pd.ref_number,
		pd.stp_arrivaldate,
		pd.shipper_name,
		pd.shipper_city,
		pd.shipper_state,			--50
		pd.consignee_name,
		pd.consignee_city,
		pd.consignee_state,
		pd.cmd_name,
		pd.pyd_billedweight,
		pd.adjusted_billed_rate,
		pd.cht_basis,
		pd.cht_basisunit,
		pd.cht_unit,
		pd.cht_rateunit,			--60
		pd.std_number,
		pd.stp_number,
		pd.unc_factor,
		pd.stp_mfh_sequence,
		pd.pyt_description,
		pd.cht_itemcode,
		pd.userlabelname,
		pd.label_name,
		pd.otherid,
		pd.pyt_fee1,				--70
		pd.pyt_fee2,
		pd.start_city,
		pd.start_state,
		pd.end_city,
		pd.end_state,
		pd.lgh_count,
		pd.ref_number_tds,
		pd.pyd_offsetpay_number,
		pd.pyd_credit_pay_flag,
		pd.pyd_refnumtype,			--80
		pd.pyd_refnum,
		pd.total_empty_miles,
		pd.total_loaded_miles,
		pd.grand_total_miles,
		pd.empty_miles,
		pd.loaded_miles,
		pd.total_miles	,
		pd.address_lastfirst,
		pd.address_address1,
		pd.address_address2,		--90
		pd.address_city,
		pd.address_nmst,
		pd.address_zip,
		pd.pyh_issuedate,
		pd.trl_type1,
		2,
		0,
		null,
		'',
		'',							--100
		pt.pyt_basis
		

	FROM	#temp_pd pd
			join stops s on pd.ord_hdrnumber = s.ord_hdrnumber
			join freightdetail f on s.stp_number = f.stp_number
			left outer join paytype pt ON pt.pyt_itemcode = pd.pyt_itemcode
	WHERE	pd.ident = @minident
			and s.stp_type = 'PUP'




	select @minord = min(ord_hdrnumber) from #temp_pd where ord_hdrnumber > @minord
end

/* PTS 15564 - DJM - Add address for asset		*/
UPDATE #temp_pd
SET	address_lastfirst	= payto.pto_fname + ' ' + payto.pto_mname + ' ' + payto.pto_lname,
	address_address1	= payto.pto_address1,
	address_address2	= payto.pto_address2,
	address_city		= payto.pto_city,
	address_zip		= payto.pto_zip
from payto	
WHERE 	#temp_pd.pyd_payto <> 'UNKNOWN'
	and #temp_pd.pyd_payto = payto.pto_id

UPDATE #temp_pd
SET	address_lastfirst	= manpowerprofile.mpp_firstname + ' ' + manpowerprofile.mpp_middlename + ' ' + manpowerprofile.mpp_lastname,
	address_address1	= manpowerprofile.mpp_address1,
	address_address2	= manpowerprofile.mpp_address2,
	address_city		= manpowerprofile.mpp_city,
	address_zip		= manpowerprofile.mpp_zip,
	name			= manpowerprofile.mpp_firstname + ' ' + manpowerprofile.mpp_middlename + ' ' + manpowerprofile.mpp_lastname
from manpowerprofile
WHERE 	#temp_pd.pyd_payto = 'UNKNOWN' and 
	#temp_pd.asgn_type = 'DRV' and
	#temp_pd.asgn_id = manpowerprofile.mpp_id

UPDATE #temp_pd
SET	address_nmst = city.cty_name + ', ' + city.cty_state
from city
WHERE 	#temp_pd.address_city = city.cty_code

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
       ord_number = oh.ord_number,
	   trl_type1 = oh.trl_type1
  FROM #temp_pd tp, 

       orderheader oh
 WHERE tp.ord_hdrnumber = oh.ord_hdrnumber

--Update the temp, for split trips, set ord_number = ord_number + '/S'
UPDATE #temp_pd
   SET ord_number = ord_number + '/S'
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

UPDATE #temp_pd
SET crd_cardnumber = ph.crd_cardnumber,
pyh_issuedate = IsNull(ph.pyh_issuedate,ph.pyh_payperiod)
FROM #temp_pd tp, payheader ph
WHERE tp.pyh_number = ph.pyh_pyhnumber

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

--PTS# 22927 ILB 05/25/2004
Set @OrdCnt = 0
Set @MinMov = 0
Set @MinOrd = 0

WHILE (SELECT COUNT(*) FROM #temp_pd WHERE mov_number > @MinMov) > 0
	BEGIN
	  SELECT @MinMov = (SELECT MIN(mov_number) FROM #temp_pd WHERE mov_number > @MinMov)
	  
	  SELECT @OrdCnt = count(distinct ord_hdrnumber)
	    FROM #temp_pd 
	   WHERE ord_hdrnumber <> 0 and
		 ord_hdrnumber IS NOT NULL and
                 mov_number = @MinMOv

	  IF @OrdCnt > 1      
	    BEGIN
              SELECT @MaxOrdDate = (select max(ord_startdate) 
				      from #temp_pd 
				     where mov_number = @MinMov)
              SELECT @MaxOrd = (select max(ord_hdrnumber) 
				  from #temp_pd 
				 where ord_startdate = @MaxOrdDate and
                                       mov_number = @MinMov)
	      SELECT @empty_miles = sum(case stp_loadstatus when 'LD' then 0 else stp_lgh_mileage end),
		     @loaded_miles = sum(case stp_loadstatus when 'LD' then stp_lgh_mileage else 0 end),
		     @total_miles = sum(stp_lgh_mileage)
	        FROM stops
	       WHERE stops.lgh_number IN (SELECT distinct lgh_number
				            FROM #temp_pd)
	      UPDATE #temp_pd
	         SET empty_miles = (SELECT sum(case stp_loadstatus when 'LD' then 0 else stp_lgh_mileage end) 
				      FROM stops
				     WHERE stops.lgh_number = #temp_pd.lgh_number ),
		     loaded_miles =(SELECT sum(case stp_loadstatus when 'LD' then stp_lgh_mileage else 0 end)
				      FROM stops
				     WHERE stops.lgh_number = #temp_pd.lgh_number ),
		     total_miles = (SELECT sum(stp_lgh_mileage)
			  	      FROM stops
				     WHERE stops.lgh_number = #temp_pd.lgh_number )
		FROM stops
	       WHERE stops.lgh_number = #temp_pd.lgh_number and
                     #temp_pd.ord_hdrnumber = @MaxOrd and 
					((#temp_pd.pyd_unit = 'MIL' and #temp_pd.pyd_loadstate = 'LD' and #temp_pd.pyd_status <> 'HLD') or 
					((#temp_pd.pyt_itemcode = 'TSR' or #temp_pd.pyt_itemcode = 'HR') and #temp_pd.pyd_status <> 'HLD') or
					(#temp_pd.pyt_basis = 'INV' and #temp_pd.pyd_status <> 'HLD') and pyd_quantity is not null and orderdetailsort = 1)
                	
	      UPDATE #temp_pd
	         SET total_empty_miles = @empty_miles,
		     total_loaded_miles = @loaded_miles,
		     grand_total_miles = @total_miles
	       Where #temp_pd.ord_hdrnumber = @MaxOrd	    			
  
  	    END
	   ELSE
	    BEGIN
		-- PTS 15564 - DJM - Calculate miles
		SELECT	@empty_miles = sum(case stp_loadstatus when 'LD' then 0 else stp_lgh_mileage end),
			@loaded_miles = sum(case stp_loadstatus when 'LD' then stp_lgh_mileage else 0 end),
			@total_miles = sum(stp_lgh_mileage)
		FROM	stops
		WHERE	stops.lgh_number IN 	(SELECT	distinct lgh_number
						FROM	#temp_pd)
		UPDATE	#temp_pd
		SET	empty_miles = 	(SELECT	sum(case stp_loadstatus when 'LD' then 0 else stp_lgh_mileage end) 
					FROM 	stops
					WHERE	stops.lgh_number = #temp_pd.lgh_number),
			loaded_miles = 	(SELECT	sum(case stp_loadstatus when 'LD' then stp_lgh_mileage else 0 end)
					FROM	stops
					WHERE	stops.lgh_number = #temp_pd.lgh_number),
			total_miles = 	(SELECT	sum(stp_lgh_mileage)
					FROM 	stops
					WHERE	stops.lgh_number = #temp_pd.lgh_number)
		FROM	stops
		WHERE	stops.lgh_number = #temp_pd.lgh_number and 
					((#temp_pd.pyd_unit = 'MIL' and #temp_pd.pyd_loadstate = 'LD' and #temp_pd.pyd_status <> 'HLD') or 
					((#temp_pd.pyt_itemcode = 'TSR' or #temp_pd.pyt_itemcode = 'HR') and #temp_pd.pyd_status <> 'HLD') or
					(#temp_pd.pyt_basis = 'INV' and #temp_pd.pyd_status <> 'HLD') and pyd_quantity is not null and orderdetailsort = 1)
		
		UPDATE	#temp_pd
		SET	total_empty_miles = @empty_miles,
			total_loaded_miles = @loaded_miles,
			grand_total_miles = @total_miles
	    END
	END

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
	pyh_issuedate		datetime null,
	YTDGST			money null
)

--Insert into the temp YTD balances table the assets from the temp pay details table
INSERT INTO #ytdbal
    SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate, 0
       FROM #temp_pd


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
                        AND ph.pyh_paystatus <> 'HLD'), 
    YTDGST = (SELECT SUM(ROUND(ISNULL(pd.pyd_gst_amount, 0), 2))
                   FROM payheader ph
				   JOIN paydetail pd on pd.pyh_number = ph.pyh_pyhnumber
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
	                	AND ph.pyh_paystatus <> 'HLD'), 0),
		YTDGST = ISNULL((SELECT SUM(ROUND(pd.pyd_gst_amount, 2))
	           	FROM payheader ph
				JOIN paydetail pd on pd.pyh_number = ph.pyh_pyhnumber
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

UPDATE #ytdbal
   SET YTDGST = YTDGST + ISNULL((SELECT SUM(ROUND(tp.pyd_gst_amount, 2))
                                    FROM #temp_pd tp
                                   WHERE tp.asgn_id = yb.asgn_id
                                         AND tp.asgn_type = yb.asgn_type
                                         AND tp.pyd_pretax = 'N'
                                         AND tp.pyd_minus = 1
                                         AND tp.pyd_status <> 'HLD'
					 AND pyh_number = 0 ), 0)
   FROM  #ytdbal yb

UPDATE #temp_pd
SET pyh_totalcomp = yb.ytdcomp,
       pyh_totaldeduct = yb.ytddeduct,
       pyh_totalreimbrs = yb.ytdreimbrs
FROM #ytdbal yb, #temp_pd tp
WHERE tp.asgn_type = yb.asgn_type
       AND tp.asgn_id = yb.asgn_id
-- PTS 31348 -- BL (start)
	and tp.pyh_payperiod = yb.pyh_payperiod
-- PTS 31348 -- BL (end)

UPDATE #temp_pd
SET YTDGST = yb.YTDGST
FROM #ytdbal yb, #temp_pd tp
WHERE tp.asgn_type = yb.asgn_type
       AND tp.asgn_id = yb.asgn_id
---- PTS 31348 -- BL (start)
--	and tp.pyh_payperiod = yb.pyh_payperiod
---- PTS 31348 -- BL (end)

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

--vjh 41736 add owner operator id and name
update #temp_pd
set oo_id = a.asgn_id,
oo_name = case isnull(mpp_lastname,'')
when '' then ''
else isnull(mpp_lastname,'') + ', ' + isnull(mpp_firstname,'') + ' ' + isnull(mpp_middlename,'')
end
from assetassignment a
join manpowerprofile m on m.mpp_id = a.asgn_id
where #temp_pd.asgn_type='TRC' and #temp_pd.lgh_number <> 0
and a.lgh_number = #temp_pd.lgh_number
and a.asgn_controlling='Y'
and a.asgn_type='DRV'


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
	pyd_refnumtype,
	pyd_refnum,
	IsNull(total_empty_miles, 0) total_empty_miles,
	IsNull(total_loaded_miles, 0) total_loaded_miles,
	IsNull(grand_total_miles, 0) grand_total_miles,
	IsNull(empty_miles, 0) empty_miles,
	IsNull(loaded_miles, 0) loaded_miles,
	IsNull(total_miles, 0) total_miles,
	address_lastfirst,  
	address_address1,
	address_address2,
	address_city,
	address_nmst,
	address_zip,
	trl_type1,
	orderdetailsort,
	pyd_gst_amount,
	YTDGST,
	OO_id,
	OO_name,
	pyt_basis,
	(select top 1 ref_number from referencenumber rf where rf.ref_type = 'BL#' and rf.ord_hdrnumber = tp.ord_hdrnumber) as 'bl_number'
  FROM #temp_pd tp
       LEFT OUTER JOIN payheader ph ON tp.pyh_number = ph.pyh_pyhnumber
GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_summary_115] TO [public]
GO
