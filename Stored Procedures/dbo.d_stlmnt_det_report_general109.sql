SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  PROC [dbo].[d_stlmnt_det_report_general109](
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


/* MODIFICATION LOG
PTS 47501 JSwindell 06-24-2009 Proc created (copy of *d_stlmnt_det_report_general98* )
PTS 47501 JSwindell 07-28-09   Per Luella: USE ORDERHEADER ord_totalmiles for the miles/order.
							   Client does not do consolidations/splits.
*/

-- jyang pts13004
Declare @PeriodforYTD Varchar(3)

--:PJK PTS 64656
Declare @asgn_type varchar(6),@asgn_id varchar(6),@RowsToProcess int
       ,@CurrentRow int,@driving_hrs decimal(10,2),@ord_completiondate datetime, @mpp_id varchar(6)

--SELECT @PeriodforYTD = isnull(gi_string1,'no')  
SELECT @PeriodforYTD = Left(isnull(gi_string1,'N') ,1) 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'
Select @PeriodforYTD = IsNull(@PeriodforYTD,'N')

--: Create a temp table to the pay header and detail numbers
CREATE TABLE #temp_pay (
	pyd_number int not null,
	pyh_number int not null,
	pyd_status varchar(6) null,
	asgn_type1 varchar(6) null)

	
--:Create Temp Variable Table PJK 02/22/2013
declare @trcdrvhrs table(
         RowID int identity(1,1)
        ,trc_driver varchar(8)
        ,asgn_id varchar(6)
        ,asgn_number int
        ,pyd_transdate datetime
        ,driving_hrs decimal(10,2)
        ,on_duty_hrs decimal(10,2)
        )

--:Create Temp Variable Table calculate DRV Hour on completion datewise PJK 02/22/2013
declare @drvhrdatewise table(RowID int identity(1,1),asgn_id varchar(6),ord_completiondate datetime,driving_hrs decimal(10,2))

--vmj1+	01/14/2002	PTS12963	Don't get caught by PayDetails with PayPeriods or WorkPeriods that are 59 seconds after the
--								Apocalypse!!!
if @payperiodend >= '2049-12-31 23:59:00.000'
	select @payperiodend = '2049-12-31 23:59:59.999'
if @workperiodend >= '2049-12-31 23:59:00.000'
	select @workperiodend = '2049-12-31 23:59:59.999'
--vmj1-


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

	-- Get the thirdparty pay header and detail numbers for held pay
	IF @tpr_yes != 'XXX'
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

	-- Get the thirdparty pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @tpr_yes != 'XXX'
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

	-- Get the thirdparty pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @tpr_yes != 'XXX'
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
	pyd_number				int			not null,
	pyh_number				int			not null,
	asgn_number				int			null,
	asgn_type				varchar(6)  not null,
	asgn_id					varchar(13) not null,
	ivd_number				int			null,
	pyd_prorap				varchar(6)	null, 
	pyd_payto				varchar(8)	null, 
	pyt_itemcode			varchar(6)	null, 
	pyd_description			varchar(30) null, 
	pyr_ratecode			varchar(6)	null, 
	pyd_quantity			float		null,		--extension (BTC)
	pyd_rateunit			varchar(6)	null,
	pyd_unit				varchar(6)	null,
	pyd_pretax				char(1)		null,
	pyd_status				varchar(6)	null,
	pyh_payperiod			datetime	null,
	lgh_startcity			int			null,
	lgh_endcity				int			null,
	pyd_minus				int			null,
	pyd_workperiod			datetime	null,
	pyd_sequence			int			null,
	pyd_rate				money		null,		--rate (BTC)
	pyd_amount				money		null,
	pyd_payrevenue			money		null,		
	mov_number				int			null,
	lgh_number				int			null,
	ord_hdrnumber			int			null,
	pyd_transdate			datetime	null,
	payperiodstart			datetime	null,
	payperiodend			datetime	null,
	pyd_loadstate			varchar(6)	null,
	summary_code			varchar(6)	null,
	name					varchar(64) null,
	terminal				varchar(6)	null,
	type1					varchar(6)	null,
	pyh_totalcomp			money		null,
	pyh_totaldeduct			money		null,
	pyh_totalreimbrs		money		null,
	crd_cardnumber			char(20)	null, /*pts 21137 cgk 7/19/2004, changed to 20 characters*/
	lgh_startdate			datetime	null,
	std_balance				money		null,
	itemsection				int			null,
	ord_startdate			datetime	null,
	ord_number				char(8)		null,
	ref_number				varchar(30) null,
	stp_arrivaldate			datetime	null,
	shipper_name			varchar(30) null,
	shipper_city			varchar(18) null,
	shipper_state			char(2)		null,
	consignee_name			varchar(30) null,
	consignee_city			varchar(18) null,
	consignee_state			char(2)		null,
	cmd_name				varchar(60) null,
	pyd_billedweight		int			null,		--billed weight (BTC)
	adjusted_billed_rate	money		null,		--rate (BTC)
	cht_basis				varchar(6)	null,
	cht_basisunit			varchar(6)	null,
	cht_unit				varchar(6)	null,
	cht_rateunit			varchar(6)	null,
	std_number				int			null,
	stp_number				int			null,
	unc_factor				float		null,
	stp_mfh_sequence		int			null,
	pyt_description			varchar(30) null,
	cht_itemcode			varchar(6)	null,
	userlabelname			varchar(20) null,
	label_name				varchar(20) null,
	otherid					varchar(8)	null,
	trc_drv					varchar(8)	null,
	start_city				varchar(18) null,
	start_state				char(2)		null,
	end_city				varchar(18) null,
	end_state				char(2)		null,
	lgh_count				int			null,
	pyh_issuedate			datetime	null,
	True_pd_lgh_number		int			null,		-- PTS 47501
	evt_tractor				varchar(8)	null,		-- PTS 47501
	pyt_basisunit			varchar(6)	null,		-- PTS 47501	
	ls_freightdetail_bol	varchar(200) null,		-- PTS 47501	
	ord_totalmiles			int null,				-- PTS 47501 7-28-09	
	CC_IDENTITY				INT IDENTITY,			-- PTS 47501
    ord_ship_date           datetime null,          -- PTS 64656
	Stop_description        varchar(45) null,       -- PTS 64656
    WPTC                    VARCHAR(45) null,       -- PTS 64656
    total_load_count        int null,               -- PTS 64656
    drv_hour_total          decimal(12,2) null,     -- PTS 64656  
    ord_completiondate      datetime null,          -- PTS 64656 
    drvhr_dt_total          decimal(12,2) null      -- PTS 64656    	
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
	null,
	pd.lgh_number, -- True_pd_lgh_number   -- PTS 47501
	null,          -- evt_tractor		   -- PTS 47501	
	null,          -- pyt_basisunit		   -- PTS 47501		
	null,          -- ls_freightdetail_bol -- PTS 47501	
	0,	           -- ord_totalmiles  	   -- PTS 47501 7-28-09		
	getdate(),
    pd.pyd_description,
    'WPTC',
    999,
    999.55,
    getdate(),
    0.0

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
  AND oh.ord_shipper <> 'UNKNOWN'	

UPDATE #temp_pd
SET 	shipper_name = 'UNKNOWN',
	shipper_city = ct.cty_name,
	shipper_state = ct.cty_state
FROM    orderheader oh, city ct
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_origincity  = ct.cty_code
  AND oh.ord_shipper = 'UNKNOWN'	



--Update the temp pay details with consignee data
UPDATE #temp_pd
SET consignee_name = co.cmp_name,
	consignee_city = ct.cty_name,
	consignee_state = ct.cty_state
FROM  company co, city ct, orderheader oh
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_consignee = co.cmp_id
  AND co.cmp_city = ct.cty_code 
  AND oh.ord_consignee <> 'UNKNOWN'

UPDATE #temp_pd
SET 	consignee_name 	= 'UNKNOWN',
	consignee_city 	= ct.cty_name,
	consignee_state 	= ct.cty_state
FROM    orderheader oh, city ct
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_destcity  = ct.cty_code
  AND oh.ord_consignee = 'UNKNOWN'	


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

-- PTS 47501 <<start>>
UPDATE #temp_pd
set evt_tractor = ( select  min(evt_tractor) from event 
					where stp_number in (select stp_number from	stops where lgh_number  = #temp_pd.True_pd_lgh_number ))
where #temp_pd.True_pd_lgh_number > 0
-- PTS 47501 <<end>>

--========================================================== Start of BL# REFERENCE NUMBERS section <<start>>
-- PTS 47501 
declare @Maxlsrowcnt int
declare @BLloopCnt int
declare @work_CC_IDENTITY int
declare @work_ord_hdrnumber int
declare @next_ord_hdrnumber int
declare @work_string varchar(200)

create table #temp_BL_refnums (lsrowcnt int identity not null primary key clustered, ord_hdrnumber int, REF_NUMBER varchar(30) null) 
create table #temp_distinct_ord_hdrnumber (lsrowcnt int identity not null primary key clustered, ord_hdrnumber int) 

-------------------------------------
insert into #temp_distinct_ord_hdrnumber (ord_hdrnumber)
select  distinct(ord_hdrnumber)  from  #temp_pd

SET @Maxlsrowcnt = ( select max(lsrowcnt) from #temp_distinct_ord_hdrnumber ) 
	
If @Maxlsrowcnt > 0
BEGIN
set @BLloopCnt = 1
While @BLloopCnt <= @Maxlsrowcnt
	BEGIN
		SET @work_ord_hdrnumber = (select ord_hdrnumber from #temp_distinct_ord_hdrnumber where lsrowcnt = @BLloopCnt)
				insert into #temp_BL_refnums (ord_hdrnumber, REF_NUMBER)

				select  referencenumber.ord_hdrnumber, REF_NUMBER
				from referencenumber
				where ref_table = 'orderheader'
				AND ref_type = 'BL#'
				and referencenumber.ord_hdrnumber = @work_ord_hdrnumber
				order by ref_table, ref_tablekey, REF_SEQUENCE

	Set @BLloopCnt = @BLloopCnt + 1
	END
END 

---------------------------------------
set @BLloopCnt = 0
SET @Maxlsrowcnt = 0 
set @work_ord_hdrnumber = null
---------------------------------------


SET @Maxlsrowcnt = ( select max(lsrowcnt) from #temp_BL_refnums ) 
	
If @Maxlsrowcnt > 0
BEGIN

set @BLloopCnt = 1
set @work_ord_hdrnumber = (select ord_hdrnumber from #temp_BL_refnums where lsrowcnt = @BLloopCnt) 
set @next_ord_hdrnumber = (select ord_hdrnumber from #temp_BL_refnums where lsrowcnt = @BLloopCnt) 

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
								--set @work_CC_IDENTITY	= (select min(CC_IDENTITY) from  #temp_pd  where ord_hdrnumber = @work_ord_hdrnumber)

								set @work_CC_IDENTITY	= (select min(CC_IDENTITY) from  #temp_pd 
														   where ord_hdrnumber = @work_ord_hdrnumber
														   and pyd_sequence = (select max(pyd_sequence) from #temp_pd where ord_hdrnumber = @work_ord_hdrnumber))

 	
								UPDATE  #temp_pd
								SET ls_freightdetail_bol = LTRIM(RTRIM(@work_string)) 								
								WHERE CC_IDENTITY = @work_CC_IDENTITY	
---------------------------------------------------------
								set @work_ord_hdrnumber = @next_ord_hdrnumber
								set @work_string = ''
							end
					END 						

				IF @next_ord_hdrnumber = @work_ord_hdrnumber
					Begin
						Set @work_string = @work_string + (select REF_NUMBER from #temp_BL_refnums where lsrowcnt = @BLloopCnt ) + ', '
						Set @BLloopCnt = @BLloopCnt + 1
						set @next_ord_hdrnumber = (select ord_hdrnumber from #temp_BL_refnums where lsrowcnt = @BLloopCnt) 				
					End	

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

								--set @work_CC_IDENTITY	= (select min(CC_IDENTITY) from  #temp_pd  where ord_hdrnumber = @work_ord_hdrnumber) 

								set @work_CC_IDENTITY	= (select min(CC_IDENTITY) from  #temp_pd 
														   where ord_hdrnumber = @work_ord_hdrnumber
														   and pyd_sequence = (select max(pyd_sequence) from #temp_pd where ord_hdrnumber = @work_ord_hdrnumber))

								UPDATE  #temp_pd
								SET ls_freightdetail_bol = LTRIM(RTRIM(@work_string)) 								
								WHERE CC_IDENTITY = @work_CC_IDENTITY	
							end
					END 	
	
	END	-- end while
END	-- end IF

-- PTS 47501 <<end>>
--========================================================== End of BL# REFERENCE NUMBERS section <<end>>

-- PTS 47501 <<start>>
UPDATE #temp_pd
set pyt_basisunit = (select  min(pyt_basisunit) from paytype 
					 where pyt_itemcode = #temp_pd.pyt_itemcode)
UPDATE #temp_pd
set pyd_quantity = 0 
where (pyt_basisunit = 'REV' OR pyt_basisunit = 'CREV')
and itemsection = 0

UPDATE #temp_pd
set cmd_name = '' 
where cmd_name like ('UNK%')
-- PTS 47501 <<end>>

-- PTS 47501 7-28-09 ord total miles per Luella.
update #temp_pd
set ord_totalmiles = (select orderheader.ord_totalmiles from orderheader
					   where #temp_pd.itemsection = 0
						and  #temp_pd.ord_hdrnumber > 0 
						and  orderheader.ord_hdrnumber = #temp_pd.ord_hdrnumber)


--Update the Temp Ord_startDate and Ref_type  PTS 64656
UPDATE #temp_pd
SET ord_ship_date = oh.ord_startdate,
    ord_completiondate = oh.ord_completiondate
FROM  orderheader oh
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber


--: Update 'WPT#'
UPDATE #temp_pd
SET WPTC = r.ref_number
from referencenumber r
WHERE #temp_pd.ord_hdrnumber = r.ord_hdrnumber
and ref_type = 'WPT#'
and r.ref_table = 'orderheader'


--:Update loadcount  PTS 64656
UPDATE #temp_pd
set total_load_count = (select count(distinct(tmp.ord_completiondate)) from #temp_pd tmp)


--:Update BL# PTS 64656 02/20/2012
UPDATE #temp_pd
SET ref_number = rn.ref_number
FROM  referencenumber rn
	WHERE rn.ref_tablekey = #temp_pd.ord_hdrnumber
	AND rn.ref_table = 'orderheader'
	AND rn.ref_type = 'BL#'
	

--:Update pyd_qty 64656 02/20/2012
UPDATE #temp_pd
SET pyd_quantity = pd.pyd_quantity
FROM  paydetail pd
WHERE #temp_pd.ord_hdrnumber = pd.ord_hdrnumber 
	AND #temp_pd.asgn_id     = pd.asgn_id
	AND #temp_pd.asgn_type   = pd.asgn_type
	and #temp_pd.asgn_number = pd.asgn_number
	and #temp_pd.pyh_number  = pd.pyh_number
	and #temp_pd.pyd_number  = pd.pyd_number
	
	
--Update Driving Hours from log_driverlogs table(Glenn)PTS 64656
select top 1 @asgn_type = asgn_type, @asgn_id = asgn_id from #temp_pd
select @asgn_type = ltrim(rtrim(@asgn_type))

--:Per Glenn's Suggestion
/*
if @asgn_type = 'DRV' begin
	update #temp_pd
	set drvhr_dt_total = (isnull(l.driving_hrs,0)  + isnull(l.on_duty_hrs,0))
	from #temp_PD PD2
	left outer join log_driverlogs l
	on l.log_date = PD2.ord_completiondate
	and l.mpp_id = @drv_id
end
*/

if @asgn_type = 'DRV' begin
		insert into @drvhrdatewise(asgn_id,ord_completiondate)
		select distinct asgn_id,ord_completiondate from #temp_pd
		order by 2

		set @RowsToProcess = (select count(1) from @drvhrdatewise)
		set @CurrentRow=0

		WHILE @CurrentRow <@RowsToProcess
		BEGIN
			select @CurrentRow = @CurrentRow +1
			select @ord_completiondate = ord_completiondate, @mpp_id = asgn_id from @drvhrdatewise where RowID = @CurrentRow
		    
			select  @driving_hrs = isnull(sum(l.driving_hrs),0)  + isnull(sum(l.on_duty_hrs),0)
			from log_driverlogs l
			where l.mpp_id = @mpp_id
			--and l.log_date between DateAdd(DD,-6,@ord_completiondate) and @ord_completiondate
			--and l.log_date = @ord_completiondate
			and CONVERT(varchar(10),l.log_date,101) = CONVERT(varchar(10),@ord_completiondate,101)  

			update @drvhrdatewise
			set driving_hrs = @driving_hrs  where RowID = @CurrentRow
			
			update #temp_pd
			set drvhr_dt_total = @driving_hrs
			where @ord_completiondate = ord_completiondate

		END
		
        --:Update total Hours matched for(ord_completiondate)
        select @payperiodend = CONVERT(varchar(10),@payperiodend,101) --:Convert to date only
        
       	update #temp_pd
	    set drv_hour_total = (select isnull(SUM(l.driving_hrs),0) + isnull(SUM(l.on_duty_hrs),0)
	    from log_driverlogs l
	    where l.log_date between  DateAdd(DD,-6,@payperiodend) and @payperiodend
	    and l.mpp_id = @drv_id)

end

--:Tractor Validation
if @asgn_type = 'TRC' BEGIN
        Delete from @drvhrdatewise
        
        --:Note: log_driverlogs->log_date is date only. So forcely converted ord_completiondate to date only
		insert into @drvhrdatewise(asgn_id,ord_completiondate)
		select distinct pyd_payto,CONVERT(varchar(10),ord_completiondate,101)from #temp_pd  --:pyd_payto is Driver id
		where pyt_itemcode = 'TSR'
		order by 2

		set @RowsToProcess = (select count(1) from @drvhrdatewise)
		set @CurrentRow=0


		WHILE @CurrentRow <@RowsToProcess
		BEGIN
			select @CurrentRow = @CurrentRow +1
			select @ord_completiondate = ord_completiondate, @mpp_id = asgn_id from @drvhrdatewise where RowID = @CurrentRow
		    
			select  @driving_hrs = isnull(sum(l.driving_hrs),0)  + isnull(sum(l.on_duty_hrs),0)
			from log_driverlogs l
			where l.mpp_id = @mpp_id
			and CONVERT(varchar(10),l.log_date,101) = CONVERT(varchar(10),@ord_completiondate,101)  --l.log_date
			
			update @drvhrdatewise
			set driving_hrs = @driving_hrs  where RowID = @CurrentRow
			
			update #temp_pd
			set drvhr_dt_total = @driving_hrs
			where CONVERT(varchar(10),@ord_completiondate,101) = CONVERT(varchar(10),ord_completiondate,101)

		END
	    
	    --:Update Total Drv Hours matched for(ord_completiondate)
	    select @payperiodend = CONVERT(varchar(10),@payperiodend,101) --:Convert to date only
	    
       	update #temp_pd
	    set drv_hour_total = (select isnull(SUM(l.driving_hrs),0) + isnull(SUM(l.on_duty_hrs),0)
	    from log_driverlogs l
	    where l.log_date between  DateAdd(DD,-6,@payperiodend) and @payperiodend
	    and l.mpp_id = @mpp_id)
	
END

--:For debugging Only
--IF OBJECT_ID('abcd1','U') IS NOT NULL
--   DROP TABLE abcd1
--Select * into abcd1 from #temp_pd


--:Retrieve Final Data
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
	evt_tractor,			-- PTS 47501
	pyt_basisunit,			-- PTS 47501
	ls_freightdetail_bol,   -- PTS 47501	
	isnull(ord_totalmiles, 0) as 'ord_totalmiles',   --: PTS 47501(7-28-2009)
	ord_ship_date,			--PTS 64656
    Stop_description,		--PTS 64656
    WPTC,            		--PTS 64656
    total_load_count,		--PTS 64656
    drv_hour_total,			--PTS 64656   
    ord_completiondate,		--PTS 64656 
    drvhr_dt_total          --PTS 64656 
FROM #temp_pd

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_det_report_general109] TO [public]
GO
