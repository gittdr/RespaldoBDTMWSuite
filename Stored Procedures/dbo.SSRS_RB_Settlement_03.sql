SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/****** Object:  StoredProcedure [dbo].[SSRS_RB_Settlement_03]    Script Date: 10/27/2014 12:29:47 ******/
/**
 *
 * NAME:
 * dbo.[SSRS_RB_Settlement_03]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Stock SP for settlement sheet SSRS_RB_Settlement_03
 
 *
**************************************************************************

Sample call


EXEC [dbo].[SSRS_RB_Settlement_03]
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

create  PROC [dbo].[SSRS_RB_Settlement_03](
	@report_type varchar(5),
	@payperiodstart datetime,
	@payperiodend datetime,
	@drv_yes varchar(3),
	@trc_yes varchar(3),
	@trl_yes varchar(3),
	@id varchar(13),
	@type1 varchar(6),
	@terminal varchar(8),
	@name varchar(64),
	@car_yes varchar(3),
	@hld_yes varchar(3),	
	@pyhnumber int,
	@tpr_yes varchar(3),
	@relcol varchar(3),
	@relncol varchar(3),
	@workperiodstart datetime,
	@workperiodend datetime,
	@pto_yes varchar(3))
AS

Declare @PeriodforYTD Varchar(3)
declare @drv_id varchar(8)
declare @trc_id varchar(8)
declare @trl_id varchar(13)
declare @car_id varchar(8)
declare @tpr_id	varchar(8)
declare @drv_type1 varchar(6)
declare @trc_type1 varchar(6)
declare @trl_type1 varchar(6)
declare @car_type1 varchar(6)
DECLARE @pto_id VARCHAR(8) 

SELECT @pto_id = @id  
SELECT @drv_id = @id
SELECT @trc_id = @id
SELECT @trl_id = @id
SELECT @car_id = @id
SELECT @tpr_id = @id
SELECT @drv_type1 = @type1
SELECT @trc_type1 = @type1
SELECT @trl_type1 = @type1
SELECT @car_type1 = @type1


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


--Don't get caught by PayDetails with PayPeriods or WorkPeriods that are 59 seconds after the Apocalypse!!!
if @payperiodend >= '2049-12-31 23:59:00.000'
	select @payperiodend = '2049-12-31 23:59:59.999'
if @workperiodend >= '2049-12-31 23:59:00.000'
	select @workperiodend = '2049-12-31 23:59:59.999'



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
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- Get the tractor pay header and detail numbers for held pay
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
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- Get the carrier pay header and detail numbers for held pay
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
			and pyd_workperiod between @workperiodstart and @workperiodend

	-- Get the trailer pay header and detail numbers for held pay
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
			AND pyh_number = @pyhnumber
			

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
			AND pyh_number = @pyhnumber
			

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
			AND pyh_number = @pyhnumber
			
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
		AND pyh_number = @pyhnumber
		

	-- Get the thirdparty pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @tpr_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			''
		FROM paydetail pd
			join payheader ph on pd.pyh_number = ph.pyh_pyhnumber
		WHERE ph.asgn_type = 'TPR'
			AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
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
	paytoaddress	varchar(685) null,
	pyt_itemcode		varchar(6) null, 
	pyt_fee1  money null,  
	pyt_fee2  money null,  
	pyd_description		varchar(100) null, 
	pyr_ratecode		varchar(6) null, 
	pyd_quantity		float null,	
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
	pyd_rate		money null,	
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
	crd_cardnumber		char(20) null, 
	lgh_startdate		datetime null,
	lgh_enddate			datetime NULL,	
	std_balance		money null,
	itemsection		int null,
	ord_startdate		datetime null,
	ord_number		varchar(20) null,
	ref_number		varchar(30) null,
	stp_arrivaldate		datetime null,
	shipper_name		varchar(100) null,
	shipper_city		varchar(18) null,
	shipper_state		char(6) null,
	consignee_name		varchar(100) null,
	consignee_city		varchar(18) null,
	consignee_state		char(6) null,
	cmd_name		varchar(60) null,
	pyd_billedweight	int null,		
	adjusted_billed_rate	money null,		
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
	otherid			varchar(25) null,
	trc_drv			varchar(8) null,
	start_city		varchar(18) null,
	start_state		char(2) null,
	end_city		varchar(18) null,
	end_state		char(2) null,
	lgh_count		int null,
	pyh_issuedate datetime null,
	mtlegmiles int NULL,
	ldlegmiles int NULL,
	totlegmiles int NULL,
	stopmileage int NULL,
	pyt_basisunit varchar(40),
	pyt_basis varchar(20),
	pyd_updsrc varchar(10))

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
	case 
		when pd.asgn_type = 'DRV' then  UPPER(mpp_lastfirst + char(10) + char(13)+ isnull(mpp_address1,'') + ' ' + isnull(mpp_address2,'') + char(10) + char(13) + mpcity.cty_name + ', '+ mpp_state + ' ' + mpp_zip)
		when pd.asgn_type = 'TRC' then  UPPER(payto.pto_companyname + ' - ' + asgn_id + char(10) + char(13)+ isnull(payto.pto_address1,'') + isnull(payto.pto_address2,'') + char(10) + char(13)  + ptocty.cty_name + ', ' + ptocty.cty_state + ' '+ payto.pto_zip)
		when pd.asgn_type = 'CAR' then  UPPER(ptocar.pto_companyname + char(10) + char(13)+ isnull(ptocar.pto_address1,'') + isnull(ptocar.pto_address2,'') + char(10) + char(13)  + ptoctyc.cty_name + ', ' + ptoctyc.cty_state + ' '+ ptocar.pto_zip)
		when pd.asgn_type = 'TRL' then  UPPER(asgn_id + char(10) + char(13)+ isnull(ptotrl.pto_address1,'') + isnull(ptotrl.pto_address2,'') + char(10) + char(13)  + ptoctyt.cty_name + ', ' + ptoctyt.cty_state + ' '+ ptotrl.pto_zip)
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
	pyd_updsrc
FROM paydetail pd
join #temp_pay tp on pd.pyd_number = tp.pyd_number
left outer join manpowerprofile on (mpp_id = pd.asgn_id and pd.asgn_type = 'DRV')
left outer join payto on( payto.pto_id = pd.pyd_payto and  pd.asgn_type = 'TRC')
left outer join payto ptocar on( ptocar.pto_id = pd.pyd_payto and  pd.asgn_type = 'CAR')
left outer join payto ptotrl on( ptotrl.pto_id = pd.pyd_payto and  pd.asgn_type = 'TRL')
left outer join city mpcity on mpcity.cty_code = manpowerprofile.mpp_city
left outer join city ptocty on ptocty.cty_code = payto.pto_city
left outer join city ptoctyc on ptoctyc.cty_code = ptocar.pto_city
left outer join city ptoctyt on ptoctyt.cty_code = ptotrl.pto_city

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
FROM  company co
	join city ct on co.cmp_city = ct.cty_code
	join orderheader oh on oh.ord_shipper = co.cmp_id
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
	join city ct on co.cmp_city = ct.cty_code
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
WHERE pyd_loadstate IS null

--Update the temp pay details with payheader data
UPDATE #temp_pd
SET crd_cardnumber = ph.crd_cardnumber,
pyh_issuedate = IsNull(ph.pyh_issuedate,ph.pyh_payperiod)
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
SET mtlegmiles = IsNull((select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = #temp_pd.lgh_number and stp_loadstatus <> 'LD'),0),
	ldlegmiles = IsNull((select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = #temp_pd.lgh_number and stp_loadstatus = 'LD'),0)
FROM 	stops 
WHERE #temp_pd.lgh_number = stops.lgh_number
--and pyt_basis = 'LGH'

--Need to get the stop of the 1st delivery and find the commodity and arrival date
--associated with it.
--Update the temp pay details table with stop data for the 1st unload stop
UPDATE #temp_pd
SET stp_mfh_sequence = (SELECT MIN(st.stp_mfh_sequence)
	FROM stops st

	WHERE st.ord_hdrnumber > 0 and #temp_pd.ord_hdrnumber > 0
	  AND st.ord_hdrnumber = #temp_pd.ord_hdrnumber
	  AND st.stp_event in ('DLUL', 'LUL', 'DUL', 'PUL')) 


UPDATE #temp_pd
SET stp_number = st.stp_number
FROM stops st
WHERE st.ord_hdrnumber > 0 and #temp_pd.ord_hdrnumber > 0 
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
CREATE TABLE #YTDBAL (asgn_type	varchar (6) not null,
	asgn_id			varchar (13) not null,
	ytdcomp			money null,
	ytddeduct		money null,
	ytdreimbrs		money null,
	pyh_payperiod		datetime null,
	pyh_issuedate		datetime null)

--Insert into the temp YTD balances table the assets from the temp pay details table
If @pyhnumber > 0
	INSERT INTO #YTDBAL
	SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
	FROM payheader 
	WHERE pyh_pyhnumber = @pyhnumber
else
	INSERT INTO #YTDBAL
	SELECT min(asgn_type), min(asgn_id), 0, 0, 0, @payperiodend, @payperiodend
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


Update #temp_pd
set 	totlegmiles =  IsNull((select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number in (select distinct lgh_number from #temp_pd where  #temp_pd.pyd_minus <> -1)),0)


--Update the temp pay details with labelfile data and drv alt id
UPDATE #temp_pd
SET 	#temp_pd.userlabelname = l.userlabelname,
	#temp_pd.label_name = l.name,
	#temp_pd.otherid = m.mpp_otherid
FROM  labelfile l
	join manpowerprofile m on m.mpp_type1 = l.abbr 
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
	Case WHEN Type1 = 'DD' and asgn_type = 'DRV' then 'Y' else 'N' end as deposit,
	ref_bol = isnull((select top 1 ref_number from referencenumber where referencenumber.ord_hdrnumber = ord_hdrnumber and ref_type = 'LPBL'),''),
	mtlegmiles,
	ldlegmiles,
	totlegmiles,
	stopmileage,
	stp_number,
	pyt_basisunit,
	pyt_basis,
	pyd_updsrc

FROM #temp_pd
order by itemsection asc, lgh_startdate asc, pyd_sequence asc,pyd_updsrc asc, pyt_description desc


GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_Settlement_03] TO [public]
GO
