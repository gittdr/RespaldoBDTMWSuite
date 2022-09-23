SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_stlmnt_det_report_general106](
	@p_report_type varchar(5),
	@p_payperiodstart datetime,
	@p_payperiodend datetime,
	@p_drv_yes varchar(3),
	@p_trc_yes varchar(3),
	@p_trl_yes varchar(3),
	@p_drv_id varchar(8),
	@p_trc_id varchar(8),
	@p_trl_id varchar(13),
	@p_drv_type1 varchar(6),
	@p_trc_type1 varchar(6),
	@p_trl_type1 varchar(6),
	@p_terminal varchar(8),
	@p_name varchar(64),
	@p_car_yes varchar(3),
	@p_car_id varchar(8),
	@p_car_type1 varchar(6),
	@p_hld_yes varchar(3),	
	@p_pyhnumber int,
	@p_relcol varchar(3),
	@p_relncol varchar(3),
	@p_workperiodstart datetime,
	@p_workperiodend datetime)
AS

/**
 * 
 * NAME:
 * dbo.d_stlmnt_det_report_general106
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the pay detail & paty header records 
 * based on the settlement sheet (pyhnumber)  selected in the interface.
 *
 * RETURNS:
 * N/A 
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 *  001 - @p_report_type varchar(5),input	
 *	  type of settlement sheet (ie. Final)
 *  002 - @p_payperiodstart datetime,input
 *        pay period start date
 *  003 - @p_payperiodend datetime,input
 *         pay period end date
 *  004 - @p_drv_yes varchar(3),input
 *         settlement sheet for a driver, DRV if true else XXX
 *  005 - @p_trc_yes varchar(3),input
 *	  settlement sheet for a tractor, TRC if true else XXX
 *  006 - @p_trl_yes varchar(3),input
 *         settlement sheet for a trailer, TRL if true else XXX
 *  007 - @p_drv_id varchar(8),input
 *         settlement sheet for a driver, driver ID if true else XXX
 *  008 - @p_trc_id varchar(8),input
 *         settlement sheet for a tractor, tractor ID if true else XXX
 *  009 - @p_trl_id varchar(13),input
 *         settlement sheet for a trailer, trailer ID if true else XXX
 *  010 - @p_drv_type1 varchar(6),input
 *         driver type 1 field value 
 *  011 - @p_trc_type1 varchar(6),input
 *         tractor type1 field value
 *  012 - @p_trl_type1 varchar(6),input
 *         trialer type 1 field value
 *  013 - @p_terminal varchar(8),input
 *         terminal
 *  014 - @p_name varchar(64),input
 *         name of driver, tractor, trailer, carrier
 *  015 - @p_car_yes varchar(3),input
 *         settlement sheet for a carrier, CAR if true else XXX
 *  016 - @p_car_id varchar(8),input
 *         settlement sheet for a carrier, carrier ID if true else XXX
 *  017 - @p_car_type1 varchar(6),input
 *         carrier type1 field value
 *  018 - @p_hld_yes varchar(3),input
 *         is the settlement sheet on hold Y/N
 *  019 - @p_pyhnumber int,input
 *         settlement sheet number to be printed
 *  020 - @p_relcol varchar(3),input
 *         has the settlement sheet been released to the selected pay period 
 *         and collected
 *  021 - @p_relncol varchar(3),input
 *	  has the settlement sheet been released to the selected pay period 
 *         and but not collected
 *  022 - @p_workperiodstart datetime,input
 *         work period start date
 *  023 - @p_workperiodend datetime,input
 *         work period end date
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * 
 * REVISION HISTORY:
 * 05/21/2009   - PTS46135 - JSWINDELL - New format created ( using format 51 as basis )
 * 12/15/09 & 12/28/09     - PTS50156 - jswindell - NEW REQUESTS
 **/

-- PTS 46135 (checkdate)
declare @checkdate  datetime 
set @checkdate = (select psd_chkissuedate from payschedulesdetail where psd_date = convert(datetime, (convert(varchar(8), @p_payperiodend, 112)), 101	 ) )

-- jyang pts13004
Declare @v_PeriodforYTD Varchar(3)

--vmj1+	PTS 17099	04/03/2003	The isnull below works if a row is returned which has
--a null value for that column, but NOT if no row is returned.  Pre-set the value, so a 
--no-row select below will leave that value untouched..
select	@v_PeriodforYTD = 'no'
--vmj1-

SELECT @v_PeriodforYTD = isnull(gi_string1,'no') 
FROM generalinfo
WHERE gi_name = 'UsePayperiodForYTD'

/* DSK PTS# 3682 commented out
-- Determine custom options
DECLARE @v_gi_string1 varchar(60)

SELECT @v_gi_string1 = gi_string1 
FROM generalinfo
WHERE gi_name = 'STLTRIALSHT'	*/

-- Create a temp table to the pay header and detail numbers
CREATE TABLE #temp_pay (
	pyd_number int not null,
	pyh_number int not null,
	pyd_status varchar(6) null,
	asgn_type1 varchar(6) null)

-- LOR PTS# 6404 elliminate trial and final settlement sheets - do just one
IF @p_hld_yes = 'Y' 
--IF @p_report_type = 'TRIAL'
BEGIN
	-- Get the driver pay header and detail numbers for held pay
	IF @p_drv_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			-- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
               		-- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@p_drv_type1
		FROM paydetail
		WHERE asgn_type = 'DRV'
			AND asgn_id = @p_drv_id
			AND pyh_number = 0 
			AND pyd_status = 'HLD'
			and pyd_workperiod between @p_workperiodstart and @p_workperiodend

	-- Get the tractor pay header and detail numbers for held pay
	IF @p_trc_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
                        -- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
                        -- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@p_trc_type1
		FROM paydetail
		WHERE asgn_type = 'TRC'
	  		AND asgn_id = @p_trc_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @p_workperiodstart and @p_workperiodend

	-- Get the carrier pay header and detail numbers for held pay
	IF @p_car_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
                        -- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
                        -- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@p_car_type1
		FROM paydetail
		WHERE asgn_type = 'CAR'
	  		AND asgn_id = @p_car_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @p_workperiodstart and @p_workperiodend

	-- Get the trailer pay header and detail numbers for held pay
	IF @p_trl_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
                        -- JET - 5/7/99 - PTS #5667, show actual status, not all as on hold
                        -- 'HLD',
			-- LOR PTS# 6404 fix settlement sheets
			--pyd_status + '*',
			pyd_status,
			@p_trl_type1
		FROM paydetail
		WHERE asgn_type = 'TRL'
	  		AND asgn_id = @p_trl_id
			AND pyh_number = 0
			AND pyd_status = 'HLD'
			and pyd_workperiod between @p_workperiodstart and @p_workperiodend
END

IF @p_relcol  = 'N' and @p_relncol = 'Y' 
BEGIN
	IF @p_drv_yes != 'XXX'
		-- Get the driver pay header and detail numbers for pay released 
		-- to this payperiod, but not collected
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@p_drv_type1
		FROM paydetail
		WHERE asgn_type = 'DRV'
	  	AND asgn_id = @p_drv_id
	  	AND pyh_payperiod BETWEEN @p_payperiodstart and @p_payperiodend
		AND pyh_number = 0

	-- Get the tractor pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @p_trc_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@p_trc_type1
		FROM paydetail
		WHERE asgn_type = 'TRC'
	  	AND asgn_id = @p_trc_id
	  	AND pyh_payperiod BETWEEN @p_payperiodstart and @p_payperiodend
		AND pyh_number = 0

	-- Get the carrier pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @p_car_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@p_car_type1
		FROM paydetail
		WHERE asgn_type = 'CAR'
	  	AND asgn_id = @p_car_id
	  	AND pyh_payperiod BETWEEN @p_payperiodstart and @p_payperiodend
		AND pyh_number = 0

	-- LOR  PTS# 5744 add trailer settlements
	-- Get the trailer pay header and detail numbers for pay released 
	-- to this payperiod, but not collected
	IF @p_trl_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pyd_number,
			pyh_number,
			pyd_status,
			@p_trl_type1
		FROM paydetail
		WHERE asgn_type = 'TRL'
	  		AND asgn_id = @p_trl_id
	  		AND pyh_payperiod BETWEEN @p_payperiodstart and @p_payperiodend
			AND pyh_number = 0
END

IF @p_relcol  = 'Y' and @p_relncol = 'N'
BEGIN
--IF @p_report_type = 'FINAL'
	-- Get the driver pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @p_drv_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@p_drv_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'DRV'
	  		AND ph.pyh_payperiod BETWEEN @p_payperiodstart and @p_payperiodend
	  		AND pd.pyh_number = ph.pyh_pyhnumber
	  		AND @p_drv_id = ph.asgn_id
			-- LOR	select paydetails for the given payheader only
			AND pyh_number = @p_pyhnumber
			-- LOR

	-- Get the tractor pay header and detail numbers pay released to this payperiod
	-- and collected 
	IF @p_trc_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@p_trc_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'TRC'
			AND ph.pyh_payperiod BETWEEN @p_payperiodstart and @p_payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @p_trc_id = ph.asgn_id
			-- LOR	select paydetails for the given payheader only
			AND pyh_number = @p_pyhnumber
			-- LOR

	-- Get the carrier pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @p_car_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,

			@p_car_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'CAR'
			AND ph.pyh_payperiod BETWEEN @p_payperiodstart and @p_payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @p_car_id = ph.asgn_id
			-- LOR	select paydetails for the given payheader only
			AND pyh_number = @p_pyhnumber
			-- LOR

	-- Get the trailer pay header and detail numbers for pay released to this payperiod
	-- and collected 
	IF @p_trl_yes != 'XXX'
		INSERT INTO #temp_pay
		SELECT pd.pyd_number,
			pd.pyh_number,
			pd.pyd_status,
			@p_trl_type1
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'TRL'
		AND ph.pyh_payperiod BETWEEN @p_payperiodstart and @p_payperiodend
		AND pd.pyh_number = ph.pyh_pyhnumber
		AND @p_trl_id = ph.asgn_id
		-- LOR	select paydetails for the given payheader only
		AND pyh_number = @p_pyhnumber
		-- LOR
END

--===============================================================

-- Create a temp table to hold the pay header and detail numbers
-- Create a temp table to hold the pay details
CREATE TABLE #temp_pd(
	pyd_number				int not null,
	pyh_number				int not null,
	asgn_number				int null,
	asgn_type				varchar(6) not null,
	asgn_id					varchar(13) not null,
	ivd_number				int null,
	pyd_prorap				varchar(6) null, 
	pyd_payto				varchar(12) null, -- changed from 6 to 12 for PTS #5849, JET - 6/10/99
	pyt_itemcode			varchar(6) null, 
	pyd_description			varchar(75) null, 
	pyr_ratecode			varchar(6) null, 
	pyd_quantity			float null,		--extension (BTC)
	pyd_rateunit			varchar(6) null,
	pyd_unit				varchar(6) null,
	pyd_pretax				char(1) null,
	pyd_status				varchar(6) null,
	pyh_payperiod			datetime null,
	lgh_startcity			int null,
	lgh_endcity				int null,
	pyd_minus				int null,
	pyd_workperiod			datetime null,
	pyd_sequence			int null,
	pyd_rate				money null,		--rate (BTC)
	pyd_amount				money null,
	pyd_payrevenue			money null,		
	mov_number				int null,
	lgh_number				int null,
	ord_hdrnumber			int null,
	pyd_transdate			datetime null,
	payperiodstart			datetime null,
	payperiodend			datetime null,
	pyd_loadstate			varchar(6) null,
	summary_code			varchar(6) null,
	name					varchar(64) null,
	terminal				varchar(6) null,
	type1					varchar(6) null,
	pyh_totalcomp			money null,
	pyh_totaldeduct			money null,
	pyh_totalreimbrs		money null,
	crd_cardnumber			char(20) null, /*pts 21137 cgk 7/19/2004, changed to 20 characters*/
	lgh_startdate			datetime null,
	std_balance				money null,
	itemsection				int null,
	ord_startdate			datetime null,
	ord_number				varchar(30) null,
	ref_number				varchar(30) null,
	stp_arrivaldate			datetime null,
	shipper_name			varchar(30) null,
	shipper_city			varchar(18) null,
	shipper_state			char(2) null,
	consignee_name			varchar(30) null,
	consignee_city			varchar(18) null,
	consignee_state			char(2) null,
	cmd_name				varchar(60) null,
	pyd_billedweight		int null,		--billed weight (BTC)
	adjusted_billed_rate	money null,		--rate (BTC)
	cht_basis				varchar(6) null,
	cht_basisunit			varchar(6) null,
	cht_unit				varchar(6) null,
	cht_rateunit			varchar(6) null,
	std_number				int null,
	stp_number				int null,
	unc_factor				float null,
	stp_mfh_sequence		int null,
	pyt_description			varchar(30) null,
	cht_itemcode			varchar(6) null,
	userlabelname			varchar(20) null,
	label_name				varchar(20) null,
	otherid					varchar(8) null,
	pyt_fee1				money null,
	pyt_fee2				money null,
	start_city				varchar(18) null,
	start_state				char(2) null,
	end_city				varchar(18) null,
	end_state				char(2) null,
	lgh_count				int null,
	ref_number_tds			varchar(30) null,
	pyd_offsetpay_number	int null,
	pyd_credit_pay_flag		char(1) null,
	pyd_refnumtype			varchar(6) null,
	pyd_refnum				varchar(30) null,
	pyh_issuedate			datetime null,
	pyt_basis				varchar(6) null,
	----------------------------------------------------
	stp_event varchar(6) null,						-- PTS46135
	true_stp_number		int null,					-- PTS46135
	stp_event_sort_sequence int null,				-- PTS46135
	true_stp_mfh_sequence int null,					-- PTS46135
	----------------------------------------------------
	ls_split_trip_cty_nmstct varchar(30) null,		-- PTS46135
	ls_split_trip_stp_event  varchar(6) null,		-- PTS46135
	lgh_startcty_nmstct varchar(30) null,			-- PTS46135     
	lgh_endcty_nmstct  varchar(30) null,			-- PTS46135
	lgh_split_flag	char(1) null,					-- PTS46135
	----------------------------------------------------
	ivd_distance	float null,						-- PTS46135
	----------------------------------------------------
	ls_freightdetail_bol	varchar(300) null,		-- PTS46135	
	CC_IDENTITY				INT IDENTITY			-- PTS46135
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
	@p_payperiodstart,
	@p_payperiodend,
	pd.pyd_loadstate,
	pd.pyd_unit,
	@p_name,
	@p_terminal,
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
	null, -- pyt_basis
	-------------------------------------
	null,   -- stp_event varchar(6) null		-- PTS 46135
	pd.stp_number, -- true_stp_number			-- PTS 46135
	null, -- stp_event_sort_sequence			-- PTS 46135
	isnull(pd.stp_mfh_sequence, 99+pyd_sequence)'stp_mfh_sequence', --true_stp_mfh_sequence	-- PTS 46135
	-------------------------------------
	null, -- ls_split_trip_cty_nmstct	-- PTS46135
	null, -- ls_split_trip_stp_event  	-- PTS46135
	-------------------------------------
	null, --lgh_startcty_nmstct 		-- PTS46135     
	null, --lgh_endcty_nmstct  			-- PTS46135
	null, --lgh_split_flag				-- PTS46135
	-------------------------------------
	null, --ivd_distance				-- PTS46135
	-------------------------------------
	null -- ls_freightdetail_bol		-- PTS46135

FROM paydetail pd, #temp_pay tp
WHERE pd.pyd_number = tp.pyd_number
order by pd.ord_hdrnumber, pd.lgh_number, pd.pyd_sequence

--===============================================================

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


-- PTS46135 - << start >> get leg header beginning/end city (needed for splits)
UPDATE #temp_pd
	SET 	lgh_startcty_nmstct = (SELECT lgh_startcty_nmstct
								   FROM legheader lh
								   WHERE lh.lgh_number = #temp_pd.lgh_number)	
UPDATE #temp_pd
	SET 	lgh_endcty_nmstct   = (SELECT lgh_endcty_nmstct
								   FROM legheader lh
								   WHERE lh.lgh_number = #temp_pd.lgh_number)	
UPDATE #temp_pd
	SET 		lgh_split_flag  = (SELECT lgh_split_flag
								   FROM legheader lh
								   WHERE lh.lgh_number = #temp_pd.lgh_number)	
-- PTS46135 - << end >> get leg header beginning/end city (needed for splits)


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
-- FROM #temp_pd tp, standingdeduction sd
-- WHERE tp.std_number = sd.std_number

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
-- FROM #temp_pd tp, payheader ph
-- WHERE tp.pyh_number = ph.pyh_pyhnumber

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
--  FROM stops st, #temp_pd tp
--WHERE st.mov_number = tp.mov_number
--  AND st.stp_mfh_sequence = tp.stp_mfh_sequence

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
if left(ltrim(@v_PeriodforYTD),1) = 'Y' begin
UPDATE #ytdbal
   SET	ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
			FROM payheader ph
                  	WHERE ph.asgn_id = yb.asgn_id
                        	AND ph.asgn_type = yb.asgn_type
                        	AND ph.pyh_payperiod >= '01/01/' + datename(yy, @p_payperiodend)
                        	AND ph.pyh_payperiod < @p_payperiodend
                        	AND ph.pyh_paystatus <> 'HLD'), 0),
     	ytddeduct = ISNULL((SELECT SUM(ROUND(ph.pyh_totaldeduct, 2))
                   	FROM payheader ph
                  	WHERE ph.asgn_id = yb.asgn_id
                       		AND ph.asgn_type = yb.asgn_type
                        	AND ph.pyh_payperiod >= '01/01/' + datename(yy, @p_payperiodend)
                       		AND ph.pyh_payperiod < @p_payperiodend
                        	AND ph.pyh_paystatus <> 'HLD'), 0),
    	ytdreimbrs = ISNULL((SELECT SUM(ROUND(ph.pyh_totalreimbrs, 2))
                   	FROM payheader ph
                  	WHERE ph.asgn_id = yb.asgn_id
                        	AND ph.asgn_type = yb.asgn_type
                        	AND ph.pyh_payperiod >= '01/01/' + datename(yy, @p_payperiodend)
                        	AND ph.pyh_payperiod < @p_payperiodend
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


-- 0 = Taxable Settlement Earnings (default)
-- 2 = Expense Reimbursements (section)
UPDATE #temp_pd
   SET itemsection = 2
 WHERE pyd_pretax = 'N'
       AND pyd_minus = 1

-- 3 = Settlement Deductions (section)
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


--=============================================================== Establish custom sort order PTS46135
UPDATE #temp_pd
	SET stp_event = (select stp_event from stops 
				where stops.stp_number = #temp_pd.true_stp_number)

Update #temp_pd
set stp_event_sort_sequence = true_stp_mfh_sequence

Update #temp_pd	
set stp_event_sort_sequence = pyd_sequence
where true_stp_mfh_sequence = 0

Update #temp_pd	
set stp_event_sort_sequence = ( stp_event_sort_sequence + 10 ) 
where pyt_itemcode <> 'CLH' 

--=============================================================== BL# REFERENCE NUMBERS for PTS46135
-- PTS 46135 7-27-09 to capture ref numbers from all orders on Consolidated Orders (rather than just the one listed on the report).

declare @Maxlsrowcnt int
declare @BLloopCnt int
declare @work_CC_IDENTITY int
declare @work_ord_hdrnumber int
declare @next_ord_hdrnumber int
declare @work_string varchar(300)
declare @work_mov_number int			-- PTS 46135 7-27-09

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
		SET @work_mov_number	= (select min(mov_number) from #temp_pd where #temp_pd.ord_hdrnumber = @work_ord_hdrnumber) -- PTS 46135 7-27-09
 				
-- Client want to use Freight Detail IF AVAILABLE or orderheader otherwise.

-- PTS 46135 7-27-09 
--				insert into #temp_BL_refnums (ord_hdrnumber, REF_NUMBER)
--				select  distinct referencenumber.ord_hdrnumber, REF_NUMBER
--				from referencenumber
--				where ref_table in ('freightdetail')
--				and ref_type = 'BL#'
--				and referencenumber.ord_hdrnumber = @work_ord_hdrnumber
--				and @work_ord_hdrnumber > 0		

				insert into #temp_BL_refnums	
				select  distinct @work_ord_hdrnumber,  REF_Number 
				from referencenumber
				where ref_table in ('freightdetail')
				and ref_type = 'BL#'
				--and referencenumber.ord_hdrnumber = @work_ord_hdrnumber
				and @work_ord_hdrnumber > 0		
				and referencenumber.ord_hdrnumber IN (select distinct(ord_hdrnumber)
														from stops 														
														where mov_number = @work_mov_number
														and ord_hdrnumber > 0 )				


				insert into #temp_BL_refnums	
					select  distinct @work_ord_hdrnumber, REF_Number
					from referencenumber
					where ref_table in ('orderheader')
					and ref_type = 'BL#'
					--and referencenumber.ord_hdrnumber = @work_ord_hdrnumber
					and @work_ord_hdrnumber > 0
					and referencenumber.ord_hdrnumber IN (select distinct(ord_hdrnumber)
														from stops 														
														where mov_number = @work_mov_number
														and ord_hdrnumber > 0 )
					-- PTS 50156 DON'T ADD DUPLICATE BL NUMBERS
					and ( convert(varchar(25), ord_hdrnumber)+convert(varchar(25), REF_Number) )  not in (select ( convert(varchar(25), ord_hdrnumber)+convert(varchar(25), REF_Number)) from #temp_BL_refnums	) 
								
		
-- PTS 46135 7-27-09			
--declare @ls_rowcount int
--set	@ls_rowcount = ( select count(*) from #temp_BL_refnums) 
--				IF @ls_rowcount = 0 
--				BEGIN
--					insert into #temp_BL_refnums (ord_hdrnumber, REF_NUMBER)
--					select  distinct referencenumber.ord_hdrnumber, REF_NUMBER
--					from referencenumber
--					where ref_table in ('orderheader')
--					and ref_type = 'BL#'
--					and referencenumber.ord_hdrnumber = @work_ord_hdrnumber
--					and @work_ord_hdrnumber > 0
--				END		

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
															and stp_event_sort_sequence = (select max(stp_event_sort_sequence) from #temp_pd where ord_hdrnumber = @work_ord_hdrnumber AND itemsection = 0))
															---and stp_event_sort_sequence = (select max(stp_event_sort_sequence) from #temp_pd where ord_hdrnumber = @work_ord_hdrnumber))  -- pts 50156
								UPDATE  #temp_pd
								SET ls_freightdetail_bol = LTRIM(RTRIM(@work_string)) 								
								WHERE CC_IDENTITY = @work_CC_IDENTITY
								AND itemsection = 0								
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
															and stp_event_sort_sequence = (select max(stp_event_sort_sequence) from #temp_pd where ord_hdrnumber = @work_ord_hdrnumber AND itemsection = 0	))
														   ---and stp_event_sort_sequence = (select max(stp_event_sort_sequence) from #temp_pd where ord_hdrnumber = @work_ord_hdrnumber)) -- pts 50156
								UPDATE  #temp_pd
								SET ls_freightdetail_bol = LTRIM(RTRIM(@work_string)) 								
								WHERE CC_IDENTITY = @work_CC_IDENTITY	
								AND itemsection = 0	
							end
					END 	
	
	END	-- end while
END	-- end IF


--PTS 46135 7-27-09
UPDATE  #temp_pd
SET ls_freightdetail_bol = 'BL# ' + ls_freightdetail_bol 	
where LEN(ls_freightdetail_bol)  > 0


--========================================================== End of BL# REFERENCE NUMBERS section 
              
Update #temp_pd
----set pyd_description =  '***  ' + lgh_startcty_nmstct + ' to ' +  lgh_endcty_nmstct
set pyd_description =  lgh_startcty_nmstct + ' to ' +  lgh_endcty_nmstct
where pyt_itemcode = 'OLNHL' 
and pyd_prorap = 'A'
and		#temp_pd.itemsection = 0

--Update #temp_pd
--set ivd_distance = (select max(ivd_distance) from invoicedetail 
--					where ord_hdrnumber = #temp_pd.ord_hdrnumber
--					and	#temp_pd.ord_hdrnumber > 0
--					and stp_number = #temp_pd.stp_number
--					and #temp_pd.pyt_itemcode = 'OLNHL' 
--					and	#temp_pd.pyd_prorap = 'A'
--					and	#temp_pd.itemsection = 0 ) 

--PTS 46135 7-27-09
Update #temp_pd
set ivd_distance  = (select stops.stp_lgh_mileage from stops
					 where #temp_pd.ord_hdrnumber > 0
						and stops.ord_hdrnumber = #temp_pd.ord_hdrnumber
						and stops.stp_number = #temp_pd.stp_number
					    and stops.stp_loadstatus = 'LD'
					    and #temp_pd.pyt_itemcode = 'OLNHL' 
					    and	#temp_pd.pyd_prorap = 'A'
					    and	#temp_pd.itemsection = 0 ) 





--================  final select ================================

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
	cast(LTRIM(RTRIM(ord_number)) as varchar(12))'ord_number',
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
	@checkdate as 'checkdate',	-- PTS46135
	stp_event,					-- PTS46135
	true_stp_number,			-- PTS46135
	stp_event_sort_sequence,	-- PTS46135
	true_stp_mfh_sequence,		-- PTS46135
	ivd_distance,				-- PTS46135
	ls_freightdetail_bol		-- PTS46135

  FROM #temp_pd tp
        LEFT OUTER JOIN PAYHEADER as PH ON (tp.pyh_number = ph.pyh_pyhnumber)
 



GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_det_report_general106] TO [public]
GO
