SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  StoredProcedure [dbo].[SSRS_RB_SETTLEMENT_ICC_01]    Script Date: 10/27/2014 12:38:30 ******/
/*
EXEC [dbo].[SSRS_RB_SETTLEMENT_ICC_01]
            @report_type = 'trial',
            @payperiodstart = '2012-10-27',
            @payperiodend = '2012-10-27',
            @drv_yes = 'DRV',
            @trc_yes = 'XXX',
            @trl_yes = 'XXX',
            @id = 'BENDYC',
            @type1 = 'XXX',
            @terminal = 'UNK',
            @name = 'TEST',
            @car_yes = 'XXX',
            @hld_yes = 'Y',
            @pyhnumber = 10901,
            @tpr_yes = 'XXX',
            @relcol = 'Y',
            @relncol = 'N',
            @workperiodstart = '1950-01-01',
            @workperiodend = '2049-12-31'

*/
CREATE  PROC [dbo].[SSRS_RB_SETTLEMENT_ICC_01](
	@report_type VARCHAR(5),
	@payperiodstart datetime,
	@payperiodend datetime,
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
	@workperiodstart datetime,
	@workperiodend datetime,
	@pto_yes varchar(3))
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


SELECT @PeriodforYTD = LEFT(ISNULL(gi_string1,'N') ,1) 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'
SELECT @PeriodforYTD = ISNULL(@PeriodforYTD,'N')


-- Create a temp table to the pay header AND detail numbers
CREATE TABLE #temp_pay (
	pyd_number INT not null,
	pyh_number INT not null,
	pyd_status VARCHAR(6) null,
	asgn_type1 VARCHAR(6) null)


--Don't get caught by PayDetails with PayPeriods or WorkPeriods that are 59 seconds after the Apocalypse!!!
if @payperiodend >= '2049-12-31 23:59:00.000'
	SELECT @payperiodend = '2049-12-31 23:59:59.999'
if @workperiodend >= '2049-12-31 23:59:00.000'
	SELECT @workperiodend = '2049-12-31 23:59:59.999'



IF @hld_yes = 'Y' 

BEGIN
	IF @drv_yes != 'XXX'
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
	IF @trc_yes != 'XXX'
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
	IF @car_yes != 'XXX'
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
	IF @trl_yes != 'XXX'
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

	-- Get the thirdparty pay header AND detail numbers for held pay
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
			AND pyd_workperiod BETWEEN @workperiodstart AND @workperiodend
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

IF @relcol  = 'N' AND @relncol = 'Y' 
BEGIN
	IF @drv_yes != 'XXX'
		-- Get the driver pay header AND detail numbers for pay released 
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
		AND pyd_status <> 'HLD'

	-- Get the tractor pay header AND detail numbers for pay released 
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
		AND pyd_status <> 'HLD'

	-- Get the carrier pay header AND detail numbers for pay released 
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
		AND pyd_status <> 'HLD'

	-- Get the trailer pay header AND detail numbers for pay released 
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
			AND pyd_status <> 'HLD'

	-- Get the thirdparty pay header AND detail numbers for pay released 
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
	  		AND pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
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

IF @relcol  = 'Y' AND @relncol = 'N'
BEGIN
	-- Get the driver pay header AND detail numbers for pay released to this payperiod
	-- AND collected 
	IF @drv_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@drv_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'DRV'
	  		AND ph.pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
	  		AND pd.pyh_number = ph.pyh_pyhnumber
	  		AND @drv_id = ph.asgn_id
			AND pyh_number = @pyhnumber
			

	-- Get the tractor pay header AND detail numbers pay released to this payperiod
	-- AND collected 
	IF @trc_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@trc_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'TRC'
			AND ph.pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @trc_id = ph.asgn_id
			AND pyh_number = @pyhnumber
			

	-- Get the carrier pay header AND detail numbers for pay released to this payperiod
	-- AND collected 
	IF @car_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@car_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'CAR'
			AND ph.pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @car_id = ph.asgn_id
			AND pyh_number = @pyhnumber
			
	-- Get the trailer pay header AND detail numbers for pay released to this payperiod
	-- AND collected 
	IF @trl_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@trl_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'TRL'
		AND ph.pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
		AND pd.pyh_number = ph.pyh_pyhnumber
		AND @trl_id = ph.asgn_id
		AND pyh_number = @pyhnumber
		

	-- Get the thirdparty pay header AND detail numbers for pay released to this payperiod
	-- AND collected 
	IF @tpr_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			''
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'TPR'
			AND ph.pyh_payperiod BETWEEN @payperiodstart AND @payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @tpr_id = ph.asgn_id
			AND pyh_number = @pyhnumber
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

-- Create a temp table to hold the pay header AND detail numbers
-- Create a temp table to hold the pay details
CREATE TABLE #temp_pd(
	pyd_number		INT not null,
	pyh_number		INT not null,
	asgn_number		INT null,
	asgn_type		VARCHAR(6) not null,
	asgn_id			VARCHAR(13) not null,
	ivd_number		INT null,
	pyd_prorap		VARCHAR(6) null, 
	pyd_payto		VARCHAR(20) null, 
	paytoaddress	VARCHAR(255) null,
	pyt_itemcode		VARCHAR(6) null, 
	pyt_fee1  money null,  
	pyt_fee2  money null,  
	pyd_description		VARCHAR(100) null, 
	pyr_ratecode		VARCHAR(6) null, 
	pyd_quantity		float null,	
	pyd_rateunit		VARCHAR(6) null,
	pyd_unit		VARCHAR(6) null,
	pyd_pretax		char(1) null,
	pyd_status		VARCHAR(6) null,
	pyh_payperiod		datetime null,
	lgh_startcity		INT null,
	lgh_endcity		INT null,
	pyd_minus		INT null,
	pyd_workperiod		datetime null,
	pyd_sequence		INT null,
	pyd_rate		money null,	
	pyd_amount		money null,
	pyd_payrevenue		money null,		
	mov_number		INT null,
	lgh_number		INT null,
	ord_hdrnumber		INT null,
	pyd_transdate		datetime null,
	payperiodstart		datetime null,
	payperiodend		datetime null,
	pyd_loadstate		VARCHAR(6) null,
	summary_code		VARCHAR(6) null,
	name			VARCHAR(64) null,
	terminal		VARCHAR(6) null,
	type1			VARCHAR(6) null,
	pyh_totalcomp		money null,
	pyh_totaldeduct		money null,
	pyh_totalreimbrs	money null,
	crd_cardnumber		char(20) null, 
	lgh_startdate		datetime null,
	lgh_enddate			datetime NULL,	
	std_balance		money null,
	itemsection		INT null,
	ord_startdate		datetime null,
	ord_number		VARCHAR(20) null,
	ref_number		VARCHAR(30) null,
	stp_arrivaldate		datetime null,
	shipper_name		VARCHAR(100) null,
	shipper_city		VARCHAR(18) null,
	shipper_state		char(6) null,
	consignee_name		VARCHAR(100) null,
	consignee_city		VARCHAR(18) null,
	consignee_state		char(6) null,
	cmd_name		VARCHAR(60) null,
	pyd_billedweight	INT null,		
	adjusted_billed_rate	money null,		
	cht_basis		VARCHAR(6) null,
	cht_basisunit		VARCHAR(6) null,
	cht_unit		VARCHAR(6) null,
	cht_rateunit		VARCHAR(6) null,
	std_number		INT null,
	stp_number		INT null,
	unc_factor		float null,
	stp_mfh_sequence	INT null,
	pyt_description		VARCHAR(30) null,
	cht_itemcode		VARCHAR(6) null,
	userlabelname		VARCHAR(20) null,
	label_name		VARCHAR(20) null,
	otherid			VARCHAR(8) null,
	trc_drv			VARCHAR(8) null,
	start_city		VARCHAR(18) null,
	start_state		char(2) null,
	end_city		VARCHAR(18) null,
	end_state		char(2) null,
	lgh_count		INT null,
	pyh_issuedate datetime null,
	mtlegmiles INT NULL,
	ldlegmiles INT NULL,
	totlegmiles INT NULL,
	stopmileage INT NULL,
	pyt_basisunit VARCHAR(40),
	pyt_basis VARCHAR(20),
	pyd_updsrc VARCHAR(10),
	mpp_name VARCHAR(100),
	mpp_address VARCHAR(200),
	mpp_citystzip VARCHAR(100))

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
	case 
		when pd.asgn_type = 'DRV' then  UPPER(mpp_lastfirst + char(10) + char(13)+ mpp_address1 + ' ' + ISNULL(mpp_address2,'') + char(10) + char(13) + mpcity.cty_name + ', '+ mpp_state + ' ' + mpp_zip)
		when pd.asgn_type = 'TRC' then  UPPER(pto_lname + ', '+ pto_fname + char(10) + char(13) + pto_address1 + pto_address2 + char(10) + char(13)  + ptocty.cty_name + ', ' + ptocty.cty_state + ' '+ pto_zip)
		else 'check this field'
		end as paytoaddress,
	pd.pyt_itemcode,
	pd.pyt_fee1,  
	pd.pyt_fee2, 
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
	0,
	0,
	0,
	0,
	NULL,
	NULL,
	pyd_updsrc,
	mpp_firstname + ' ' + mpp_lastname,
	mpp_address1 + ' ' + ISNULL(mpp_address2,''),
	mpcity.cty_name + ', ' + mpp_state + ' ' + mpp_zip	
FROM paydetail pd
join #temp_pay tp on pd.pyd_number = tp.pyd_number
LEFT outer join manpowerprofile on (mpp_id = pd.asgn_id AND asgn_type = 'DRV')
LEFT outer join payto on( pto_id = pd.pyd_payto AND  asgn_type = 'TRC')
LEFT outer join city mpcity on mpcity.cty_code = manpowerprofile.mpp_city
LEFT outer join city ptocty on ptocty.cty_code = payto.pto_city

--Update the temp pay details with legheader data
UPDATE #temp_pd
SET mov_number = lh.mov_number,
	lgh_number = lh.lgh_number,
	lgh_startdate = lh.lgh_startdate,
	lgh_enddate = lh.lgh_enddate
FROM 	legheader lh
WHERE #temp_pd.lgh_number = lh.lgh_number


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
FROM  orderheader oh
WHERE #temp_pd.ord_hdrnumber = oh.ord_hdrnumber

--Update the temp, for split trips, set ord_number = ord_number + '/S'
UPDATE #temp_pd    
   SET ord_number = ord_number + '/S'    
 WHERE ord_hdrnumber > 0     
       AND lgh_count > 1 

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


--Update the temp pay details with stANDingdeduction data
UPDATE #temp_pd
SET std_balance = sd.std_balance
FROM  stANDingdeduction sd
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
pyh_issuedate = ISNULL(ph.pyh_issuedate,ph.pyh_payperiod)
FROM  payheader ph
WHERE #temp_pd.pyh_number = ph.pyh_pyhnumber

--Update the temp pay details with paytype data
UPDATE #temp_pd
SET pyt_description = pt.pyt_description,
pyt_basisunit = pt.pyt_basisunit,
pyt_basis = pt.pyt_basis
FROM  paytype pt
WHERE #temp_pd.pyt_itemcode = pt.pyt_itemcode


UPDATE #temp_pd
SET mtlegmiles = ISNULL((SELECT sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = #temp_pd.lgh_number AND stp_loadstatus <> 'LD'),0),
	ldlegmiles = ISNULL((SELECT sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = #temp_pd.lgh_number AND stp_loadstatus = 'LD'),0)
FROM 	stops 
WHERE #temp_pd.lgh_number = stops.lgh_number
--AND pyt_basis = 'LGH'

--Need to get the stop of the 1st delivery AND find the commodity AND arrival date
--associated with it.
--Update the temp pay details table with stop data for the 1st unload stop
UPDATE #temp_pd
SET stp_mfh_sequence = (SELECT MIN(st.stp_mfh_sequence)
	FROM stops st

	WHERE st.ord_hdrnumber > 0 AND #temp_pd.ord_hdrnumber > 0
	  AND st.ord_hdrnumber = #temp_pd.ord_hdrnumber
	  AND st.stp_event in ('DLUL', 'LUL', 'DUL', 'PUL')) 


UPDATE #temp_pd
SET stp_number = st.stp_number
FROM stops st
WHERE st.ord_hdrnumber > 0 AND #temp_pd.ord_hdrnumber > 0 
	AND st.ord_hdrnumber = #temp_pd.ord_hdrnumber
  AND st.stp_mfh_sequence = #temp_pd.stp_mfh_sequence
  
UPDATE #temp_pd
SET  stopmileage = stp_lgh_mileage
FROM 	stops 
WHERE #temp_pd.stp_number = stops.stp_number

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
CREATE TABLE #YTDBAL (asgn_type	VARCHAR (6) not null,
	asgn_id			VARCHAR (13) not null,
	ytdcomp			money null,
	ytddeduct		money null,
	ytdreimbrs		money null,
	pyh_payperiod		datetime null,
	pyh_issuedate		datetime null)

--Insert INTo the temp YTD balances table the assets from the temp pay details table
If @pyhnumber > 0
	INSERT INTO #YTDBAL
	SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
	FROM payheader 
	WHERE pyh_pyhnumber = @pyhnumber
else
	INSERT INTO #YTDBAL
	SELECT min(asgn_type), min(asgn_id), 0, 0, 0, @payperiodend, @payperiodend
	FROM #temp_pd 


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


Update #temp_pd
set 	totlegmiles =  ISNULL((SELECT sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number in (SELECT lgh_number from #temp_pd)),0)


--Update the temp pay details with labelfile data AND drv alt id
UPDATE #temp_pd
SET 	#temp_pd.userlabelname = l.userlabelname,
	#temp_pd.label_name = l.name,
	#temp_pd.otherid = m.mpp_otherid
FROM  labelfile l, manpowerprofile m
WHERE 	m.mpp_id = #temp_pd.asgn_id AND
	l.labeldefinition = 'DrvType1' AND
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
	paytoaddress,
	pyt_itemcode,
	pyt_fee1,  
	pyt_fee2,  
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
	lgh_enddate,
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
	Case WHEN Type1 = 'DD' AND asgn_type = 'DRV' then 'Y' else 'N' end as deposit,
	ref_bol = ISNULL((SELECT top 1 ref_number from referencenumber where referencenumber.ord_hdrnumber = ord_hdrnumber AND ref_type = 'LPBL'),''),
	mtlegmiles,
	ldlegmiles,
	totlegmiles,
	stopmileage,
	stp_number,
	pyt_basisunit,
	pyt_basis,
	pyd_updsrc,
	mpp_name,
	mpp_address,
	mpp_citystzip

FROM #temp_pd
order by itemsection asc, lgh_startdate asc, pyd_sequence asc,pyd_updsrc asc, pyt_description desc


GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_SETTLEMENT_ICC_01] TO [public]
GO
