SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  PROC [dbo].[d_stlmnt_sheet_summary_33](
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
 * 11/07/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

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

/* DSK PTS# 3682 commented out
-- Determine custom options
DECLARE @gi_string1 varchar(60)

SELECT @gi_string1 = gi_string1 
FROM generalinfo
WHERE gi_name = 'STLTRIALSHT'	*/

-- Create a temp table to the pay header and detail numbers
CREATE TABLE #temp_pay (
	pyd_number int not null,
	pyh_number int not null,
	pyd_status varchar(6) null,
	asgn_type1 varchar(6) null)


-- LOR PTS# 6404 elliminate trial and final settlement sheets - do just one
IF @hld_yes = 'Y' 

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
	pyd_payto		varchar(12)null, -- changed from 6 to 12 for PTS #5849, JET - 6/10/99
	payto_fullname		varchar(41) null,  -- PTS 20747
	payto_address1		varchar(30) null,  -- PTS 20747
	payto_citystate		varchar(25) null,  -- PTS 20747
	payto_zip		varchar(25) null,  -- PTS 20747
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
	ord_number		char(12) null,
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
	pyt_description		varchar(100) null,
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
	pyd_refnumtype          varchar(6) null,
	pyd_refnum              varchar(30) null,
	pyh_issuedate		datetime null,
	first_check_issue	varchar(10) null,	--PTS 20747  first check issuance for this year
	last_check_issue	varchar(10) null,	--PTS 20747  last check issuance date for the resource
	num_weeks		int null,		--PTS 20747  number of weeks between first and last
	average_pay		money null,		--PTS 20747  total for the year / num_weeks
	escrow_balance		money null,		--PTS 20747  balance for deduction chargetype 'ESC'
	ytd_escrow_interest	money null,		--PTS 20747  balance * intrest on the paytype
	company_name		varchar(40) null,	--PTS 20747  Company name based on tractor company
	custom_ytd_payments	money null)		--PTS 21838  Linden's logic for payments is the sum of all paydetails
							--	     with a pyd_minus = 1 and tax/pretax = yes

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
	--payto.pto_fname + ' ' + payto.pto_lname,     -- PTS 20747  (commented out for PTS 21838)
	CASE isnull(ltrim(rtrim(pto_fname)),'') + isnull(ltrim(rtrim(pto_lname)),'')
		WHEN '' THEN pto_companyname
		ELSE isnull(ltrim(rtrim(pto_fname)),'') + ' ' + isnull(ltrim(rtrim(pto_lname)),'')
	END ,
	payto.pto_address1,  -- PTS 20747
	(left(city.cty_nmstct,len(city.cty_nmstct)-1)) 'city.cty_nmstct',     -- PTS 20747
	payto.pto_zip,       -- PTS 20747
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
	pd.pyd_description,
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
	null,
	null,
	null,
	null,
	0,
	0,
	null,
	null
 FROM paydetail pd, #temp_pay tp, payto, city
WHERE pd.pyd_number = tp.pyd_number
  and payto.pto_id = pd.pyd_payto
  and payto.pto_city = city.cty_code

--PTS 20747 calculate the first and last payperiod for the current year
update #temp_pd set first_check_issue = (select convert(varchar(10),isnull(min(payheader.pyh_issuedate),''),101) from payheader, #temp_pd where payheader.pyh_issuedate is not null and #temp_pd.asgn_id = payheader.asgn_id and payheader.pyh_issuedate > (select convert(datetime,'12/31/' + convert(char(4),datepart(yy,getdate()) - 1)))),
                     last_check_issue = (select convert(varchar(10),isnull(max(payheader.pyh_issuedate),''),101) from payheader,#temp_pd where payheader.pyh_issuedate is not null and #temp_pd.asgn_id = payheader.asgn_id and payheader.pyh_issuedate < (select convert(datetime,'12/31/' + convert(char(4),datepart(yy,getdate()))))and payheader.pyh_issuedate > (select convert(datetime,'12/31/' + convert(char(4),datepart(yy,getdate())-1))))

--PTS 20747 generate the company name based on the tractor's company
if (select trc_company from tractorprofile where tractorprofile.trc_number = @trc_id) = 'SW'
update #temp_pd
  set company_name = 'Linden Bulk Transportation SW LLC'
else 
update #temp_pd
  set company_name = 'Linden Bulk Transportation Co., Inc.'

--PTS 20747 update the temp table for output if the first or last check issue date does not apply
 update #temp_pd
   set first_check_issue = 'N/A' where first_check_issue = '01/01/1900'
 
 update #temp_pd
   set last_check_issue = 'N/A' where last_check_issue = '01/01/1900'

/*  PTS 21838  Change in logic of the number of weeks is the distinct # of payheaders
--PTS 20747 update the temp table with the number of weeks between first and last as long as they are valid
if (select distinct(first_check_issue) from #temp_pd) <> 'N/A'
--need to add 1 so it includes the first week paid
	update #temp_pd
	  set num_weeks = datepart(wk,last_check_issue) - datepart(wk,first_check_issue) + 1
else
	update #temp_pd
	  set num_weeks = 0
*/
update #temp_pd set num_weeks = (select count(distinct pyh_pyhnumber)
				   from payheader
				  where pyh_issuedate >= (select convert(datetime,'01/01/'+convert(varchar(4),datepart(yy,getdate()))))
				    and asgn_id = (select max(asgn_id) from #temp_pd)
				    and asgn_type = (select max(asgn_type) from #temp_pd)
				    and isnull(pyh_totalcomp, 0) <> 0)

--PTS 20747  concatenate fuel descritpions with qty and rate for fuel purchases
 update #temp_pd
   set pyt_description = pyd_description + ' ' + convert(varchar(20),pyd_quantity) + ' ' + 'gal @ ' + convert(varchar(20),pyd_rate)
   where pyt_itemcode = 'FULTRC'

--PTS 22500
update #temp_pd
set 	pyt_description = (	select 	pyt_description 
						from 	paytype 
						where 	#temp_pd.pyt_itemcode = paytype.pyt_itemcode
						)
where 	pyt_itemcode != 'FULTRC'
		and isNull(pyt_description, '') = ''

--PTS 20747  calculate escrow amounts
 update #temp_pd 
   set escrow_balance = (select abs(sd.std_balance)
                         from standingdeduction sd
                         where sd.asgn_id = (select distinct (asgn_id) from #temp_pd)
                           and sd.sdm_itemcode = 'ESCINT'
                           and sd.std_status <> 'CLD')

--PTS 20747  now calculate interest on the escrow account
  update #temp_pd
    set ytd_escrow_interest = (select abs(sum (pyd_amount) )
  				from paydetail 
  				where pyt_itemcode = 'IT+'
  				  and asgn_id = (select distinct(asgn_id) from #temp_pd)
  				  and pyd_minus = 1
  				  and pyh_payperiod between
  							 (select convert(datetime,'01/01/' + convert(varchar(4),(datepart(yy,getdate())))))
  						    and 
  							 (select dateadd(mi,-1,convert(datetime,'01/01/' + convert(varchar(4),(datepart(yy,getdate())+1)))))
 			   )
--PTS 20747 now if the escrow amounts are still null update to 0  did not use isnull because if there are no records returned it will still be null this will catch all scenerios
  update #temp_pd
    set escrow_balance = 0
    where escrow_balance is NULL
update #temp_pd
	set ytd_escrow_interest = 0
        where ytd_escrow_interest is NULL

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
       ord_number = oh.ord_number
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


/*
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
*/

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
--       AND rn.ref_table = "orderheader"
--       AND rn.ref_type = "SID"


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
	

/*UPDATE #temp_pd
   SET pyh_totalcomp = (SELECT ISNULL(ytdcomp, 0)
                          FROM #ytdbal
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


--PTS 21838  YTD payments for Linden is sum of all paydetails where the pyd_minus = 1 and the tax/pretax is set to yes
update #temp_pd
	set custom_ytd_payments = (select isnull(sum(round(pd.pyd_amount,2)),0)
					from paydetail pd, payheader ph
					where pd.asgn_type = (select max (asgn_type) from #temp_pd)
					  and pd.asgn_id = (select max (asgn_id) from #temp_pd)
					  and pd.pyd_status <> 'HLD'
					  and pd.pyd_minus = 1
					  and pd.pyd_pretax = 'Y'
					  and ph.pyh_issuedate >= (select convert(datetime,'01/01/'+convert(varchar(4),datepart(yy,getdate()))))
					  and ph.pyh_pyhnumber = pd.pyh_number)
--PTS 21838 update the temp table with the calculated average weekly pay as long as the number of weeks is not 0
if (select max(num_weeks) from #temp_pd) > 0
	update #temp_pd
	  set average_pay = custom_ytd_payments / num_weeks
else
	update #temp_pd
	  set average_pay = 0

SELECT pyd_number, 
	pyh_number, 
	asgn_number, 
	tp.asgn_type, 
	tp.asgn_id, 
	ivd_number, 
	pyd_prorap, 
	pyd_payto,
	payto_fullname,
	payto_address1,
	payto_citystate,
-- PTS 29894 -- BL (start)	
--	payto_zip,
	payto_zip = '  ' + payto_zip,
-- PTS 29894 -- BL (end)	
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
	round(pyd_amount, 2) as pyd_amount,
	pyd_payrevenue,
	mov_number,
	lgh_number,
	ord_hdrnumber,
/*
PTS 25047 B.C.Young
The pyd_transdate did not produce consistent results. It would show 1900-01-01 on system added
min paydetails, and the VERY FINAL lgh_enddate on split trips, which was confusing for their drivers,
so I modified it with a CASE statement
*/
	pyd_transdate = CASE 	WHEN PYD_TRANSDATE < '20010101' THEN TP.pyh_payperiod
   							WHEN PYD_TRANSDATE > TP.pyh_payperiod THEN  TP.pyh_payperiod
   							ELSE PYD_TRANSDATE 
							END,

	payperiodstart,
	payperiodend,
	pyd_loadstate,
	summary_code,
	name,
	terminal,
	type1,
	round(tp.pyh_totalcomp, 2) 'pyh_totalcomp',
	round(tp.pyh_totaldeduct, 2) 'pyh_totaldeduct',
	round(tp.pyh_totalreimbrs, 2) 'pyh_totalreimbrs',
	ph.crd_cardnumber 'crd_cardnumber',
	lgh_startdate,
	std_balance,
	itemsection,
	ord_startdate,
-- PTS 29894 -- BL (start)	
--	ord_number,
	ord_number = case when ord_number is NULL and charindex('[', isNull(pyt_description,'') ) > 0 and  charindex(']', isNull(pyt_description,'') ) > 0 then  substring(isNull(pyt_description,''),  charindex('[', isNull(pyt_description,'') ) +1, (charindex(']', isNull(pyt_description,'') ) - charindex('[', isNull(pyt_description,'') ) -1)) ELSE ord_number END,
-- PTS 29894 -- BL (end)	
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
-- PTS 29894 -- BL (start)	
--	pyt_description,
	pyt_description = case when (pyt_description like '%(Less Fee)%' and pyt_description like 'com%' ) then Left(pyt_description, 18) 
				when (pyt_description like '%(Less Fee)%' and pyt_description like 'gas%' ) then Left(pyt_description, 17) 
				ELSE pyt_description END,
-- PTS 29894 -- BL (end)	
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
	tp.pyh_issuedate,
	isnull(first_check_issue,tp.pyh_issuedate) as 'first_issue_date',
	isnull(last_check_issue,tp.pyh_issuedate) as 'last_issue_date',
	num_weeks,
	average_pay,
	escrow_balance,
	ytd_escrow_interest,
	company_name,
	custom_ytd_payments
	
  FROM #temp_pd tp LEFT OUTER JOIN payheader ph ON tp.pyh_number = ph.pyh_pyhnumber
 ORDER BY pyd_minus desc, pyd_transdate

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_sheet_summary_33] TO [public]
GO
