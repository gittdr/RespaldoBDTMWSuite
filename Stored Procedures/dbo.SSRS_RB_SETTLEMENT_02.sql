SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/**
 *
 * NAME:
 * dbo.[SSRS_RB_SETTLEMENT_02]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Stock SP for settlement sheet SSRS_RB_SETTLEMENT_02
 
 *
**************************************************************************

Sample call


EXEC [dbo].[SSRS_RB_SETTLEMENT_02]
            @report_type = 'trial',
            @payperiodstart = '2008-12-20',
            @payperiodend = '2008-12-20',
            @drv_yes = 'XXX',
            @trc_yes = 'Yes',
            @trl_yes = 'XXX',
            @id = '199',
            @type1 = 'XXX',
            @terminal = 'UNK',
            @name = 'Joe',
            @car_yes = 'XXX',
            @hld_yes = 'Y',
            @pyhnumber = 339,
            @tpr_yes = 'XXX',
            @relcol = 'Y',
            @relncol = 'N',
            @workperiodstart = '1950-01-01',
            @workperiodend = '2049-12-31'


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (Stored Procedure)
 *
 * PARAMETERS:
 *  @report_type VARCHAR(5),  
 *  @payperiodstart DATETIME,  
 *  @payperiodend DATETIME,  
 *  @drv_yes VARCHAR(3),  
 *  @trc_yes VARCHAR(3),  
 *  @trl_yes VARCHAR(3),  
 *  @id VARCHAR(13),  
 *  @type1 VARCHAR(6),  
 *  @terMINal VARCHAR(8),  
 *  @name VARCHAR(64),  
 *  @car_yes VARCHAR(3),  
 *  @hld_yes VARCHAR(3),   
 *  @pyhnumber int,  
 *  @tpr_yes VARCHAR(3),  
 *  @relcol VARCHAR(3),  
 *  @relncol VARCHAR(3),  
 *  @workperiodstart DATETIME,  
 *  @workperiodend DATETIME
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 07/18/2014 - MREED - changed Otherid to 25 characters
 ***********************************************************/

CREATE  PROC [dbo].[SSRS_RB_SETTLEMENT_02](
	@report_type VARCHAR(5),
	@payperiodstart DATETIME,
	@payperiodend DATETIME,
	@drv_yes VARCHAR(3),
	@trc_yes VARCHAR(3),
	@trl_yes VARCHAR(3),
	@id VARCHAR(13),
	@type1 VARCHAR(6),
	@terminal VARCHAR(8),
	@name VARCHAR(64),
	@car_yes VARCHAR(3),
	@hld_yes VARCHAR(3),	
	@pyhnumber INT,
	@tpr_yes VARCHAR(3),
	@relcol VARCHAR(3),
	@relncol VARCHAR(3),
	@workperiodstart DATETIME,
	@workperiodend DATETIME,
	@pto_yes VARCHAR(3))
AS

DECLARE @PeriodforYTD VARCHAR(3)

DECLARE @drv_id VARCHAR(8)
DECLARE @trc_id VARCHAR(8)
DECLARE @trl_id VARCHAR(13)
DECLARE @car_id VARCHAR(8)
DECLARE @tpr_id	VARCHAR(8)
DECLARE @drv_type1 VARCHAR(6)
DECLARE @trc_type1 VARCHAR(6)
DECLARE @trl_type1 VARCHAR(6)
DECLARE @car_type1 VARCHAR(6)
DECLARE @pto_id VARCHAR(8) 

select @pto_id = @id
SELECT @drv_id = @id
SELECT @trc_id = @id
SELECT @trl_id = @id
SELECT @car_id = @id
SELECT @tpr_id = @id
SELECT @drv_type1 = @type1
SELECT @trc_type1 = @type1
SELECT @trl_type1 = @type1
SELECT @car_type1 = @type1

--SELECT @PeriodforYTD = ISNULL(gi_string1,'no')  
SELECT @PeriodforYTD = LEFT(ISNULL(gi_string1,'N') ,1) 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'
SELECT @PeriodforYTD = ISNULL(@PeriodforYTD,'N')


/* DSK PTS# 3682 commented out
-- Determine custom options
DECLARE @gi_string1 VARCHAR(60)

SELECT @gi_string1 = gi_string1 
FROM generalinfo
WHERE gi_name = 'STLTRIALSHT'	*/

-- Create a temp table to the pay header and detail numbers
CREATE TABLE #temp_pay (
	pyd_number INT NOT NULL,
	pyh_number INT NOT NULL,
	pyd_status VARCHAR(6) NULL,
	asgn_type1 VARCHAR(6) NULL)


--vmj1+	01/14/2002	PTS12963	Don't get caught by PayDetails with PayPeriods or WorkPeriods that are 59 seconds after the
--								Apocalypse!!!
if @payperiodend >= '2049-12-31 23:59:00.000'
	SELECT @payperiodend = '2049-12-31 23:59:59.999'
if @workperiodend >= '2049-12-31 23:59:00.000'
	SELECT @workperiodend = '2049-12-31 23:59:59.999'
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
   -- Get the payto pay header AND detail numbers for held pay  
 IF @pto_yes != 'XXX'  
  INSERT INTO #temp_pay  
  SELECT pyd_number,  
   pyh_number,  
   pyd_status,  
   ''  
  FROM paydetail  
  WHERE asgn_type = 'PTO'  
     AND asgn_id = @pto_id  
   AND pyh_number = 0  
   AND pyd_status = 'HLD'  
   AND pyd_workperiod between @workperiodstart AND @workperiodend 

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
		AND pyd_status <> 'HLD' 

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
		AND pyd_status <> 'HLD'

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
		AND pyd_status <> 'HLD'

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
			AND pyd_status <> 'HLD'

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
			AND pyd_status <> 'HLD'
			
 -- Get the payto pay header AND detail numbers for pay released   
 -- to this payperiod, but not collected  
 IF @pto_yes != 'XXX'  
  INSERT INTO #temp_pay  
  SELECT pyd_number,  
   pyh_number,  
   pyd_status,  
   ''  
  FROM paydetail  
  WHERE asgn_type = 'PTO'  
   AND @pto_id = asgn_id  
     AND pyh_payperiod BETWEEN @payperiodstart AND @payperiodend  
   AND pyh_number = 0
   AND pyd_status <> 'HLD'  			
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
		FROM paydetail pd
			join payheader ph on pd.pyh_number = ph.pyh_pyhnumber
		WHERE ph.asgn_type = 'DRV'
	  		AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
	  		AND @drv_id = ph.asgn_id
			-- LOR	SELECT paydetails for the given payheader only
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
		FROM paydetail pd
			join payheader ph on pd.pyh_number = ph.pyh_pyhnumber
		WHERE ph.asgn_type = 'TRC'
			AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND @trc_id = ph.asgn_id
			-- LOR	SELECT paydetails for the given payheader only
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
		FROM paydetail pd
			join payheader ph on pd.pyh_number = ph.pyh_pyhnumber
		WHERE ph.asgn_type = 'CAR'
			AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND @car_id = ph.asgn_id
			-- LOR	SELECT paydetails for the given payheader only
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
		FROM paydetail pd
			join payheader ph on pd.pyh_number = ph.pyh_pyhnumber
		WHERE ph.asgn_type = 'TRL'
		AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
		AND @trl_id = ph.asgn_id
		-- LOR	SELECT paydetails for the given payheader only
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
		FROM paydetail pd
			join  payheader ph on pd.pyh_number = ph.pyh_pyhnumber
		WHERE ph.asgn_type = 'TPR'
			AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND @tpr_id = ph.asgn_id
		-- LOR	SELECT paydetails for the given payheader only
		AND pyh_number = @pyhnumber
		-- LOR
		
  -- Get the thirdparty pay header AND detail numbers for pay released to this payperiod  
 -- AND collected   
 IF @pto_yes != 'XXX'  
  INSERT INTO #temp_pay  
  SELECT pd.pyd_number,  
   pd.pyh_number,  
   pd.pyd_status,  
   ''  
  FROM paydetail pd, payheader ph  
  WHERE ph.asgn_type = 'PTO'  
   AND ph.pyh_payperiod BETWEEN @payperiodstart AND @payperiodend  
   AND pd.pyh_number = ph.pyh_pyhnumber  
   AND @pto_id = ph.asgn_id   
  AND pyh_number = @pyhnumber  		
END

-- Create a temp table to hold the pay header and detail numbers
-- Create a temp table to hold the pay details
CREATE TABLE #temp_pd(
	pyd_number		INT NOT NULL,
	pyh_number		INT NOT NULL,
	asgn_number		INT NULL,
	asgn_type		VARCHAR(6) NOT NULL,
	asgn_id			VARCHAR(13) NOT NULL,
	ivd_number		INT NULL,
	pyd_prorap		VARCHAR(6) NULL, 
	pyd_payto		VARCHAR(8) NULL, 
	pyt_itemcode		VARCHAR(6) NULL, 
	pyd_description		VARCHAR(100) NULL, 
	pyr_ratecode		VARCHAR(6) NULL, 
	pyd_quantity		float NULL,		--extension (BTC)
	pyd_rateunit		VARCHAR(6) NULL,
	pyd_unit		VARCHAR(6) NULL,
	pyd_pretax		char(1) NULL,
	pyd_status		VARCHAR(6) NULL,
	pyh_payperiod		DATETIME NULL,
	lgh_startcity		INT NULL,
	lgh_endcity		INT NULL,
	pyd_minus		INT NULL,
	pyd_workperiod		DATETIME NULL,
	pyd_sequence		INT NULL,
	pyd_rate		money NULL,		--rate (BTC)
	pyd_amount		money NULL,
	pyd_payrevenue		money NULL,		
	mov_number		INT NULL,
	lgh_number		INT NULL,
	ord_hdrnumber		INT NULL,
	pyd_transdate		DATETIME NULL,
	payperiodstart		DATETIME NULL,
	payperiodend		DATETIME NULL,
	pyd_loadstate		VARCHAR(6) NULL,
	summary_code		VARCHAR(6) NULL,
	name			VARCHAR(64) NULL,
	terminal		VARCHAR(6) NULL,
	type1			VARCHAR(6) NULL,
	pyh_totalcomp		money NULL,
	pyh_totaldeduct		money NULL,
	pyh_totalreimbrs	money NULL,
	crd_cardnumber		char(20) NULL, /*pts 21137 cgk 7/19/2004, changed to 20 characters*/
	lgh_startdate		DATETIME NULL,
	std_balance		money NULL,
	itemsection		INT NULL,
	ord_startdate		DATETIME NULL,
	ord_number		VARCHAR(20) NULL,
	ref_number		VARCHAR(30) NULL,
	stp_arrivaldate		DATETIME NULL,
	shipper_name		VARCHAR(100) NULL,
	shipper_city		VARCHAR(18) NULL,
	shipper_state		char(6) NULL,
	consignee_name		VARCHAR(100) NULL,
	consignee_city		VARCHAR(18) NULL,
	consignee_state		char(6) NULL,
	cmd_name		VARCHAR(60) NULL,
	pyd_billedweight	INT NULL,		--billed weight (BTC)
	adjusted_billed_rate	money NULL,		--rate (BTC)
	cht_basis		VARCHAR(6) NULL,
	cht_basisunit		VARCHAR(6) NULL,
	cht_unit		VARCHAR(6) NULL,
	cht_rateunit		VARCHAR(6) NULL,
	std_number		INT NULL,
	stp_number		INT NULL,
	unc_factor		float NULL,
	stp_mfh_sequence	INT NULL,
	pyt_description		VARCHAR(30) NULL,
	cht_itemcode		VARCHAR(6) NULL,
	userlabelname		VARCHAR(20) NULL,
	label_name		VARCHAR(20) NULL,
	otherid			VARCHAR (25) NULL, ---changed to 25 characters mreed 07182014
	trc_drv			VARCHAR(8) NULL,
	start_city		VARCHAR(18) NULL,
	start_state		char(2) NULL,
	end_city		VARCHAR(18) NULL,
	end_state		char(2) NULL,
	lgh_count		INT NULL,
	pyh_issuedate DATETIME NULL)

-- Insert INTo the temp pay details table with the paydetail data per #temp_pay
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
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	0,
	NULL
FROM paydetail pd
	join #temp_pay tp on pd.pyd_number = tp.pyd_number


--Update the temp pay details with legheader data
UPDATE #temp_pd
SET mov_number = lh.mov_number,
	lgh_number = lh.lgh_number,
	lgh_startdate = lh.lgh_startdate
FROM 	legheader lh
WHERE #temp_pd.lgh_number = lh.lgh_number

-- Update the temp with number of legheaders for the move
-- actually, just find if there was another legheader on the move
--UPDATE 	#temp_pd
--SET lgh_count = legheader.lgh_number
--FROM legheader
--WHERE legheader.mov_number = #temp_pd.mov_number 
--  AND legheader.lgh_number <> #temp_pd.lgh_number

UPDATE #temp_pd    
   SET lgh_count = (SELECT COUNT(lgh_number)     
                      FROM legheader lh     
                     WHERE lh.mov_number = #temp_pd.mov_number)   

--Update the temp pay details with orderheader data
UPDATE #temp_pd
SET ord_startdate = oh.ord_startdate,
	ord_number = oh.ord_number
FROM  orderheader oh
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber

--Update the temp, for split trips, set ord_number = ord_number + '/S'
--UPDATE 	#temp_pd
--SET	ord_number = ord_number + '/S'
--WHERE 	ord_hdrnumber > 0 
--  AND	lgh_count > 0

UPDATE #temp_pd    
   SET ord_number = ord_number + '/S'    
 WHERE ord_hdrnumber > 0     
       AND lgh_count > 1 

--Update the temp pay details with shipper data
UPDATE #temp_pd
SET shipper_name = co.cmp_name,
	shipper_city = ct.cty_name,
	shipper_state = ct.cty_state
FROM  company co
	join city ct on co.cmp_city = ct.cty_code
	join  orderheader oh on oh.ord_shipper = co.cmp_id
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_shipper <> 'UNKNOWN'	

UPDATE #temp_pd
SET 	shipper_name = 'UNKNOWN',
	shipper_city = ct.cty_name,
	shipper_state = ct.cty_state
FROM    orderheader oh
	join city ct on oh.ord_origincity  = ct.cty_code
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_shipper = 'UNKNOWN'	



--Update the temp pay details with consignee data
UPDATE #temp_pd
SET consignee_name = co.cmp_name,
	consignee_city = ct.cty_name,
	consignee_state = ct.cty_state
FROM  company co
	join  city ct on co.cmp_city = ct.cty_code
	join orderheader oh on oh.ord_consignee = co.cmp_id
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_consignee <> 'UNKNOWN'

UPDATE #temp_pd
SET 	consignee_name 	= 'UNKNOWN',
	consignee_city 	= ct.cty_name,
	consignee_state 	= ct.cty_state
FROM    orderheader oh
	join city ct on oh.ord_destcity  = ct.cty_code
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber
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
WHERE pyd_loadstate IS NULL

--Update the temp pay details with payheader data
UPDATE #temp_pd
SET crd_cardnumber = ph.crd_cardnumber,
pyh_issuedate = ISNULL(ph.pyh_issuedate,ph.pyh_payperiod)
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
FROM   freightdetail fd
	join commodity cd on cd.cmd_code = fd.cmd_code
	join stops st on fd.stp_number = st.stp_number
WHERE st.stp_number = #temp_pd.stp_number


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
CREATE TABLE #YTDBAL (asgn_type	VARCHAR (6) NOT NULL,
	asgn_id			VARCHAR (13) NOT NULL,
	ytdcomp			money NULL,
	ytddeduct		money NULL,
	ytdreimbrs		money NULL,
	pyh_payperiod		DATETIME NULL,
	pyh_issuedate		DATETIME NULL)

--Insert INTo the temp YTD balances table the assets from the temp pay details table
-- JD pts 28499 06/29/05 commented the following insert out, this table needs to have just one row for the later update on the #temp_pd table to work consistently
-- we are running INTo issues when the ytdbal has 2 rows since we have details that are on the 12/31/49 payperiod.
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
	
--
--Compute the YTD balances for each assets
--LOR	fixed NULL problem SR 7095
--JYAng pts13004
/*
if LEFT(ltrim(@PeriodforYTD),1) = 'Y' begin
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
	  		AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0),
   ytddeduct = ISNULL((SELECT SUM(ROUND(ph.pyh_totaldeduct, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0),
   ytdreimbrs = ISNULL((SELECT SUM(ROUND(ph.pyh_totalreimbrs, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0)
FROM #YTDBAL yb
END
*/
IF LEFT(ltrim(@PeriodforYTD),1) = 'Y' 
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
	                	AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, ISNULL(yb.pyh_issuedate,yb.pyh_payperiod))
	                	AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) <= ISNULL(yb.pyh_issuedate,yb.pyh_payperiod)
	                	AND ph.pyh_paystatus <> 'HLD'), 0),
		ytddeduct = ISNULL((SELECT SUM(ROUND(ph.pyh_totaldeduct, 2))
	           	FROM payheader ph
	          	WHERE ph.asgn_id = yb.asgn_id
	               		AND ph.asgn_type = yb.asgn_type
	                	AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, ISNULL(yb.pyh_issuedate,yb.pyh_payperiod))
	                	AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) <= ISNULL(yb.pyh_issuedate,yb.pyh_payperiod)
	                	AND ph.pyh_paystatus <> 'HLD'), 0),
		ytdreimbrs = ISNULL((SELECT SUM(ROUND(ph.pyh_totalreimbrs, 2))
	           	FROM payheader ph
	          	WHERE ph.asgn_id = yb.asgn_id
	                	AND ph.asgn_type = yb.asgn_type
	                	AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, ISNULL(yb.pyh_issuedate,yb.pyh_payperiod))
	                	AND ISNULL(ph.pyh_issuedate,ph.pyh_payperiod) <= ISNULL(yb.pyh_issuedate,yb.pyh_payperiod)
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
FROM  labelfile l
	join manpowerprofile m on 	m.mpp_type1 = l.abbr 
WHERE 	m.mpp_id = #temp_pd.asgn_id 
	and l.labeldefinition = 'DrvType1' 


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
	round(pyd_amount, 2) as pyd_amount,
	pyd_payrevenue,
	mov_number,
	lgh_number,
	ord_hdrnumber,
	pyd_transdate,
	payperiodstart,
	payperiodend,
	pyd_loadstate,
	summary_code,
	[name],
	terminal,
	type1,
	round(pyh_totalcomp, 2) as pyh_totalcomp,
	round(pyh_totaldeduct, 2) as pyh_totaldeduct,
	round(pyh_totalreimbrs, 2) as pyh_totalreimbrs,
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
	cht_basis,
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
	lgh_count,
	Case WHEN Type1 = 'DD' and asgn_type = 'DRV' then 'Y' else 'N' end as deposit,
	ref_bol = ISNULL((SELECT top 1 ref_number from referencenumber where referencenumber.ord_hdrnumber = ord_hdrnumber and ref_type = 'LPBL'),'')

FROM #temp_pd


GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_SETTLEMENT_02] TO [public]
GO
