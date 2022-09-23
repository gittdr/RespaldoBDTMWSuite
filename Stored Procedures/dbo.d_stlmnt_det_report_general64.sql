SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_stlmnt_det_report_general64](
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
 * dbo.d_stlmnt_det_report_general64
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Resultset for settlement sheet 64 
 *
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 *
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 04-AUG-2006 SWJ - PTS 33302 - Created
 * 09/12/2006 vjh - PTS 34471 - multiple changes
 * 01/08/2007 vjh - PTS 34834
 *
 **/
DECLARE	@ls_drv_fname	VARCHAR(40),
		@ls_drv_minit	VARCHAR(1),
		@ls_drv_lname	VARCHAR(40),
		@ls_address1	VARCHAR(30),
		@ls_address2	VARCHAR(30),
		@ls_state		VARCHAR(6),
		@ls_zip			VARCHAR(10),
		@ls_name		VARCHAR(90),
		@ls_city		VARCHAR(18),
		@ls_city_state  VARCHAR(24),
		@li_city		INTEGER,
		@li_ordnumber	VARCHAR(12),
		@v_last_asgn_id VARCHAR(13),
		@v_last_itemcode varchar(6),
		@v_last_pyt_itemcode varchar(6),
		@v_std_number	INT,
		@v_sdm_minusbalance CHAR(1),
		@v_pyh_number	INT,
		@v_terminal		VARCHAR(6),
		@v_redterm		VARCHAR(3)

Declare @PeriodforYTD char(1)
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
CREATE TABLE #YTDBAL (asgn_type	varchar (6) not null,
	asgn_id			varchar (13) not null,
	ytdcomp			money null,
	ytddeduct		money null,
	ytdreimbrs		money null,
	pyh_payperiod	datetime null,
	pyh_issuedate	datetime null)


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
	pyd_description		varchar(75) null, 
	pyr_ratecode		varchar(6) null, 
	pyd_quantity		float null,		--extension (BTC)
	pyd_rateunit		varchar(6) null,
	pyd_unit			varchar(6) null,
	pyd_pretax			char(1) null,
	pyd_status			varchar(6) null,
	pyh_payperiod		datetime null,
	lgh_startcity		int null,
	lgh_endcity			int null,
	pyd_minus			int null,
	pyd_workperiod		datetime null,
	pyd_sequence		int null,
	pyd_rate			money null,		--rate (BTC)
	pyd_amount			money null,
	pyd_payrevenue		money null,		
	mov_number			int null,
	lgh_number			int null,
	ord_hdrnumber		int null,
	pyd_transdate		datetime null,
	payperiodstart		datetime null,
	payperiodend		datetime null,
	pyd_loadstate		varchar(6) null,
	summary_code		varchar(6) null,
	name				varchar(64) null,
	terminal			varchar(6) null,
	type1				varchar(6) null,
	pyh_totalcomp		money null,
	pyh_totaldeduct		money null,
	pyh_totalreimbrs	money null,
	crd_cardnumber		char(20) null, /*pts 21137 cgk 7/19/2004, changed to 20 characters*/
	lgh_startdate		datetime null,
	std_balance			money null,
	itemsection			int null,
	ord_startdate		datetime null,
	ord_number			char(8) null,
	ref_number			varchar(30) null,
	stp_arrivaldate		datetime null,
	shipper_name		varchar(30) null,
	shipper_city		varchar(18) null,
	shipper_state		char(2) null,
	consignee_name		varchar(30) null,
	consignee_city		varchar(18) null,
	consignee_state		char(2) null,
	cmd_name			varchar(60) null,
	pyd_billedweight	int null,		--billed weight (BTC)
	adjusted_billed_rate money null,		--rate (BTC)
	cht_basis			varchar(6) null,
	cht_basisunit		varchar(6) null,
	cht_unit			varchar(6) null,
	cht_rateunit		varchar(6) null,
	std_number			int null,
	stp_number			int null,
	unc_factor			float null,
	stp_mfh_sequence	int null,
	pyt_description		varchar(30) null,
	cht_itemcode		varchar(6) null,
	userlabelname		varchar(20) null,
	label_name			varchar(20) null,
	otherid				varchar(8) null,
	trc_drv				varchar(8) null,
	psh_name			varchar(25) null,
	psd_id				int null,
	bal_gl2471			money	null,
	std_issueamount		money	null,
	pyh_issuedate 		datetime null,
	drv_name			varchar(90) null, -- 19-JUL-2006 SWJ - PTS 33302
	drv_address1		varchar(30) null,
	drv_address2		varchar(30) null,
	drv_city_state		varchar(18) null,
	drv_zip				varchar(10) null,
	ord_quantity		integer	null)

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
	pd.psd_id,
	0.0,
	null,
	null,
	-- 19-JUL-2006 SWJ - PTS 33646
	null,
	null,
	null,
	null,
	null,
	0
--	0.0,
--	0.0
FROM #temp_pay tp ,paydetail pd 
WHERE pd.pyd_number = tp.pyd_number


select @v_pyh_number = max(pyh_number), @v_terminal = max(terminal) from #temp_pd

select @v_last_asgn_id = min(asgn_id) --get first value @v_last_asgn_id
	from #temp_pd
while @v_last_asgn_id is not null begin
	select @v_last_itemcode = min(sdm_itemcode) --get first value @v_last_itemcode
		from stdmaster
		--where sdm_interestrate =.0001
	while @v_last_itemcode is not null begin

		if exists(select 1 from standingdeduction
			where sdm_itemcode = @v_last_itemcode
			and asgn_id = @v_last_asgn_id) begin

			select @v_last_pyt_itemcode = pyt_itemcode
				from stdmaster
				where sdm_itemcode = @v_last_itemcode


			select @v_std_number = s.std_number,
				@v_sdm_minusbalance = m.sdm_minusbalance,
				@v_redterm = m.sdm_reductionterm
				from standingdeduction s
				join stdmaster m on m.sdm_itemcode=s.sdm_itemcode
				where s.sdm_itemcode = @v_last_itemcode and asgn_id = @v_last_asgn_id

	
			insert into #temp_pd (pyh_number,
				pyd_number,
				pyh_payperiod,
				payperiodend,
				asgn_type,
				asgn_id,
				pyd_payto,
				name,
				terminal,
				pyd_description,
				pyd_amount,
				--stl_terminationdate,
				--stl_terminalcode,
				cht_itemcode,
				pyt_description,
				std_number
				--,	sdm_minusbalance
				) 
			select 	@v_pyh_number,
				-1,
				@payperiodend, 
				@payperiodend, 
				'TRC', 
				@v_last_asgn_id,
				case when trc_owner = 'UNKNOWN' then '' else trc_owner end, 
				case when trc_owner = 'UNKNOWN' then '' 
				     when len(payto.pto_companyname) > 0 then payto.pto_companyname 
				     when len(payto.pto_lastfirst) > 0 then payto.pto_lastfirst else '' end, 
				@v_terminal,
				paytype.pyt_description,
				0,
				--trc_retiredate,
				--trc_terminal,
				@v_last_itemcode,
				paytype.pyt_description,
				@v_std_number
				--, @v_sdm_minusbalance
			from tractorprofile , paytype, payto
				where trc_number = @v_last_asgn_id
				and paytype.pyt_itemcode = @v_last_pyt_itemcode
				and payto.pto_id = trc_owner
	
			if @v_redterm = 'NOT'
			  update #temp_pd -- put in YTD paid for this deduction
			     set std_balance = 
					isnull(-1 * (select sum(pyd_amount) from paydetail
					where asgn_type='TRC'
					and asgn_id = @v_last_asgn_id
					and pyh_payperiod between '1/1/' + cast(datepart(year,@payperiodend) as char(4)) and @payperiodend
					and paydetail.std_number = @v_std_number),0)
			  from standingdeduction s
				where #temp_pd.std_number = @v_std_number
			     and s.std_number = @v_std_number
			else If @v_sdm_minusbalance='N'
				-- vjh 34834 Bond needs to show as due payee
			  update #temp_pd
				 set std_balance = case cht_itemcode when 'BOND' then isnull(s.std_startbalance - s.std_balance,0) else -1 * (isnull(s.std_balance - s.std_endbalance,0)) end
			  from standingdeduction s
				where #temp_pd.std_number = @v_std_number
				 and s.std_number = @v_std_number
			else
				-- vjh 34834 Bond needs to show as due payee
			  update #temp_pd
			     set std_balance = case cht_itemcode when 'BOND' then isnull(s.std_balance,0) else isnull(-1 * s.std_balance,0) end
			  from standingdeduction s
			   where #temp_pd.std_number = @v_std_number
			     and s.std_number = @v_std_number	

		end 

		select @v_last_itemcode = min(sdm_itemcode) --get next value @v_last_itemcode
			from stdmaster
			where sdm_itemcode > @v_last_itemcode
	end

		--YTD Earnings
			insert into #temp_pd (pyh_number,
				pyd_number,
				pyh_payperiod,
				payperiodend,
				asgn_type,
				asgn_id,
				pyd_payto,
				name,
				terminal,
				pyd_description,
				pyd_amount,
				cht_itemcode,
				pyt_description,
				std_number,
				std_balance
				) 
			select 	@v_pyh_number,
				-1,
				@payperiodend, 
				@payperiodend, 
				'TRC', 
				@v_last_asgn_id,
				case when trc_owner = 'UNKNOWN' then '' else trc_owner end, 
				case when trc_owner = 'UNKNOWN' then '' 
				     when len(payto.pto_companyname) > 0 then payto.pto_companyname 
				     when len(payto.pto_lastfirst) > 0 then payto.pto_lastfirst else '' end, 
				@v_terminal,
				'YTD Earnings',
				0,
				@v_last_itemcode,
				'YTD Earnings',
				@v_std_number,
				(select sum(pyd_amount) from paydetail
					where asgn_type='TRC'
					and asgn_id = @v_last_asgn_id
					and pyh_payperiod between '1/1/' + cast(datepart(year,@payperiodend) as char(4)) and @payperiodend)
			from tractorprofile , payto
				where trc_number = @v_last_asgn_id
				and payto.pto_id = trc_owner

		--YTD miles
			insert into #temp_pd (pyh_number,
				pyd_number,
				pyh_payperiod,
				payperiodend,
				asgn_type,
				asgn_id,
				pyd_payto,
				name,
				terminal,
				pyd_description,
				pyd_amount,
				cht_itemcode,
				pyt_description,
				std_number,
				std_balance
				) 
			select 	@v_pyh_number,
				-1,
				@payperiodend, 
				@payperiodend, 
				'TRC', 
				@v_last_asgn_id,
				case when trc_owner = 'UNKNOWN' then '' else trc_owner end, 
				case when trc_owner = 'UNKNOWN' then '' 
				     when len(payto.pto_companyname) > 0 then payto.pto_companyname 
				     when len(payto.pto_lastfirst) > 0 then payto.pto_lastfirst else '' end, 
				@v_terminal,
				'YTD Miles',
				0,
				@v_last_itemcode,
				'YTD Miles',
				@v_std_number,
				(select sum(ord_quantity)
					from orderheader
					where ord_completiondate between '1/1/' + cast(datepart(year,@payperiodend) as char(4)) and @payperiodend
					and ord_tractor=@v_last_asgn_id)
			from tractorprofile , payto
				where trc_number = @v_last_asgn_id
				and payto.pto_id = trc_owner

	select @v_last_asgn_id = min(asgn_id) --get next value @v_last_asgn_id
		from #temp_pd
		where asgn_id > @v_last_asgn_id
end


-- 19-JUL-2006 SWJ - PTS 33464
IF @drv_yes != 'XXX'
BEGIN
	SELECT	@ls_drv_fname 	= CAST(mpp_firstname AS VARCHAR(40)),
		@ls_drv_minit 	= CAST(mpp_middlename AS VARCHAR(1)),
		@ls_drv_lname 	= CAST(mpp_lastname AS VARCHAR(40)),
		@ls_address1 	= CAST(mpp_address1 AS VARCHAR(30)),
		@ls_address2	= CAST(mpp_address2 AS VARCHAR(30)),
		@li_city 	= mpp_city,
		@ls_zip		= CAST(mpp_zip AS VARCHAR(10))
	FROM	manpowerprofile
	WHERE	mpp_id = @drv_id;
END	
IF @trc_yes != 'XXX' --vjh 34471
BEGIN
	SELECT	@ls_drv_fname 	= CAST(isnull(pto_fname,'') AS VARCHAR(40)),
		@ls_drv_minit 	= CAST(isnull(pto_mname,'') AS VARCHAR(1)),
		@ls_drv_lname 	= CAST(isnull(pto_lname,'') AS VARCHAR(40)),
		@ls_address1 	= CAST(isnull(pto_address1,'') AS VARCHAR(30)),
		@ls_address2	= CAST(isnull(pto_address2,'') AS VARCHAR(30)),
		@li_city 	= isnull(pto_city,0),
		@ls_zip		= CAST(isnull(pto_zip,'') AS VARCHAR(10))
	FROM	payto, tractorprofile
	WHERE	pto_id = trc_owner
			and trc_number = @trc_id;
END	
IF @drv_yes != 'XXX' or @trc_yes != 'XXX'
BEGIN

	-- Concatenate the driver name
	SET @ls_name = ''
	IF @ls_drv_fname IS NOT NULL AND RTRIM(LTRIM(@ls_drv_fname)) <> ''
		SET @ls_name = @ls_name + @ls_drv_fname
	IF @ls_drv_minit IS NOT NULL AND RTRIM(LTRIM(@ls_drv_minit)) <> ''
		SET @ls_name = @ls_name + ' ' + @ls_drv_minit
	IF @ls_drv_lname IS NOT NULL AND RTRIM(LTRIM(@ls_drv_lname)) <> ''
		SET @ls_name = @ls_name + ' ' + @ls_drv_lname
	
	IF @ls_name IS NOT NULL
		SET @ls_name = RTRIM(LTRIM(@ls_name))

	-- Get the city name
	IF @li_city > 0
		SELECT	@ls_city = CAST(cty_name AS VARCHAR(18)),
			@ls_state = CAST(cty_state AS VARCHAR(6))
		FROM	city
		WHERE	cty_code = @li_city

	IF @ls_city IS NOT NULL AND @ls_state IS NOT NULL
		SET @ls_city_state = @ls_city + ', ' + @ls_state
	ELSE IF @ls_city IS NOT NULL
		SET @ls_city_state = @ls_city
	ELSE IF @ls_state IS NOT NULL
		SET @ls_city_state = @ls_state

	UPDATE	#temp_pd
	SET	drv_name 	= @ls_name,
		drv_address1 	= @ls_address1,
		drv_address2 	= @ls_address2,
		drv_city_state 	= @ls_city_state,
		drv_zip 	= @ls_zip
END

SELECT	@li_ordnumber = MIN(ord_hdrnumber)
FROM	#temp_pd
WHERE	ord_hdrnumber IS NOT NULL

WHILE 1=1
BEGIN
	IF @li_ordnumber IS NULL
		BREAK

	UPDATE	#temp_pd
	SET	#temp_pd.ord_quantity = (SELECT orderheader.ord_quantity FROM orderheader WHERE	orderheader.ord_hdrnumber = @li_ordnumber)
	WHERE	#temp_pd.ord_hdrnumber = @li_ordnumber
	
	SELECT	@li_ordnumber = MIN(ord_hdrnumber)
	FROM	#temp_pd
	WHERE	ord_hdrnumber > @li_ordnumber
		AND ord_hdrnumber IS NOT NULL
END


--Update the temp pay details with legheader data
UPDATE 	#temp_pd
SET 	mov_number = lh.mov_number,
	lgh_number = lh.lgh_number,
	lgh_startdate = lh.lgh_startdate
FROM  	legheader lh
WHERE 	#temp_pd.lgh_number = lh.lgh_number

--Update the temp pay details with orderheader data
UPDATE 	#temp_pd
SET	ord_startdate = oh.ord_startdate,
	ord_number = oh.ord_number
FROM    orderheader oh
WHERE 	#temp_pd.ord_hdrnumber = oh.ord_hdrnumber

--Update the temp pay details with shipper data
UPDATE 	#temp_pd
SET 	shipper_name = co.cmp_name,
	shipper_city = ct.cty_name,
	shipper_state = ct.cty_state
FROM   	company co, city ct, orderheader oh
WHERE 	#temp_pd.ord_hdrnumber = oh.ord_hdrnumber
	AND oh.ord_shipper = co.cmp_id
	AND co.cmp_city = ct.cty_code

--Update the temp pay details with consignee data
UPDATE	#temp_pd
SET 	consignee_name = co.cmp_name,
	consignee_city = ct.cty_name,
	consignee_state = ct.cty_state
FROM  	company co, city ct, orderheader oh
WHERE 	#temp_pd.ord_hdrnumber = oh.ord_hdrnumber
	AND oh.ord_consignee = co.cmp_id
	AND co.cmp_city = ct.cty_code

--Update the temp pay details for summary code
UPDATE 	#temp_pd
SET 	summary_code = 'OTHER'
WHERE 	summary_code != 'MIL'

--Update the temp pay details for load status
UPDATE 	#temp_pd
SET 	pyd_loadstate = 'NA'
WHERE 	pyd_loadstate IS null

--Update the temp pay details with payheader data
UPDATE 	#temp_pd
SET 	crd_cardnumber = ph.crd_cardnumber,
	pyh_issuedate = IsNull(ph.pyh_issuedate,ph.pyh_payperiod)
FROM  	payheader ph
WHERE 	#temp_pd.pyh_number = ph.pyh_pyhnumber

--Update the temp pay details with paytype data
UPDATE 	#temp_pd
SET 	pyt_description = pt.pyt_description
FROM  	paytype pt
WHERE 	#temp_pd.pyt_itemcode = pt.pyt_itemcode

--Need to get the stop of the 1st delivery and find the commodity and arrival date
--associated with it.
--Update the temp pay details table with stop data for the 1st unload stop
UPDATE 	#temp_pd
SET 	stp_mfh_sequence = (SELECT 	MIN(st.stp_mfh_sequence)
				FROM 	stops st
				WHERE 	st.ord_hdrnumber = #temp_pd.ord_hdrnumber
				  	AND st.stp_event in ('DLUL', 'LUL', 'DUL', 'PUL')) 

UPDATE 	#temp_pd
SET 	stp_number = st.stp_number
FROM 	stops st 
WHERE 	st.ord_hdrnumber = #temp_pd.ord_hdrnumber
	AND st.stp_mfh_sequence = #temp_pd.stp_mfh_sequence

--Update the temp pay details with commodity data
UPDATE 	#temp_pd
SET 	cmd_name = cd.cmd_name,
	stp_arrivaldate = st.stp_arrivaldate
FROM  	freightdetail fd, commodity cd, stops st
WHERE 	st.stp_number = #temp_pd.stp_number
	AND fd.stp_number = st.stp_number
	AND cd.cmd_code = fd.cmd_code

--Need to get the bill-of-lading from the reference number table
--Update the temp pay details with reference number data
--LOR	SR 7095	Titus specific/Dispatch
UPDATE 	#temp_pd
SET 	ref_number = rn.ref_number
FROM 	referencenumber rn
WHERE 	rn.ref_tablekey = #temp_pd.ord_hdrnumber
	AND rn.ref_table = 'orderheader'
	AND rn.ref_type = 'DISPCH'

--Need to get revenue charge type data from the chargetype table
UPDATE 	#temp_pd
SET 	cht_basis =	ct.cht_basis,
	cht_basisunit = ct.cht_basisunit,
	cht_unit = ct.cht_unit,
	cht_rateunit = ct.cht_rateunit
FROM  	chargetype ct
WHERE 	#temp_pd.cht_itemcode = ct.cht_itemcode

UPDATE 	#temp_pd
SET 	unc_factor = uc.unc_factor
FROM  	unitconversion uc
WHERE 	uc.unc_from = #temp_pd.cht_basisunit
	AND uc.unc_to = #temp_pd.cht_rateunit
	AND uc.unc_convflag = 'R'

UPDATE 	#temp_pd
SET 	adjusted_billed_rate = ROUND(pyd_payrevenue / pyd_billedweight / unc_factor, 2)
WHERE 	pyd_billedweight > 0
	AND unc_factor > 0
	AND pyd_payrevenue > 0

--Insert into the temp YTD balances table the assets from the temp pay details table
INSERT INTO #YTDBAL
 SELECT DISTINCT asgn_type, asgn_id, 0, 0, 0, pyh_payperiod, pyh_issuedate
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
	  			AND tp.pyd_status <> 'HLD'), 0)
FROM #YTDBAL yb

UPDATE #YTDBAL
SET ytddeduct = ytddeduct + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2)) 
				FROM #temp_pd tp
				WHERE tp.asgn_id = yb.asgn_id
	  				AND tp.asgn_type = yb.asgn_type
	  				AND tp.pyd_pretax = 'N'
	  				AND tp.pyd_minus = -1
	  				AND tp.pyd_status <> 'HLD'), 0)
FROM #YTDBAL yb

UPDATE #YTDBAL
SET ytdreimbrs = ytdreimbrs + ISNULL((SELECT SUM(ROUND(tp.pyd_amount, 2))
				FROM #temp_pd tp
				WHERE tp.asgn_id = yb.asgn_id
	  				AND tp.asgn_type = yb.asgn_type
	  				AND tp.pyd_pretax = 'N'
	  				AND tp.pyd_minus = 1
	  				AND tp.pyd_status <> 'HLD'), 0)
FROM #YTDBAL yb

UPDATE 	#temp_pd
SET 	pyh_totalcomp = yb.ytdcomp,
	pyh_totaldeduct = yb.ytddeduct,
	pyh_totalreimbrs = yb.ytdreimbrs
FROM 	#YTDBAL yb 
WHERE 	#temp_pd.asgn_type = yb.asgn_type
  	AND #temp_pd.asgn_id = yb.asgn_id

UPDATE 	#temp_pd
SET 	itemsection = 2
WHERE 	pyd_pretax = 'N'
  	AND pyd_minus = 1

UPDATE 	#temp_pd
SET 	itemsection = 3
WHERE 	pyd_pretax = 'N'
  	AND pyd_minus = -1

UPDATE 	#temp_pd
SET 	itemsection = 4
WHERE 	pyt_itemcode = 'MN+'	/*minimum credit */
   	OR pyt_itemcode = 'MN-'	/*minimum debit */

--Update the temp pay details with labelfile data and drv alt id
UPDATE 	#temp_pd
SET 	#temp_pd.userlabelname = l.userlabelname,
	#temp_pd.label_name = l.name,
	#temp_pd.otherid = m.mpp_otherid
FROM   	labelfile l, manpowerprofile m
WHERE 	m.mpp_id = #temp_pd.asgn_id and
	l.labeldefinition = 'DrvType1' and
	m.mpp_type1 = l.abbr 

--LOR	SR 7095	Titus specific
--Update the temp pay details with weight
UPDATE 	#temp_pd
SET 	#temp_pd.pyd_billedweight = ih.ivh_totalweight
FROM 	invoiceheader ih
WHERE 	ih.ord_hdrnumber = #temp_pd.ord_hdrnumber

--Update the temp pay details with driver/tractor payto
UPDATE  #temp_pd
SET 	#temp_pd.pyd_payto = m.mpp_payto
FROM    manpowerprofile m
WHERE 	#temp_pd.asgn_type = 'DRV' and
	m.mpp_id = #temp_pd.asgn_id

UPDATE 	#temp_pd
SET 	#temp_pd.pyd_payto = t.trc_owner
FROM 	tractorprofile t
WHERE 	#temp_pd.asgn_type = 'TRC' and
	t.trc_number = #temp_pd.asgn_id

--Update the temp pay details with corresponding driver/tractor 
UPDATE 	#temp_pd
SET 	#temp_pd.trc_drv = t.trc_driver
FROM  	tractorprofile t
WHERE 	#temp_pd.asgn_type = 'TRC' and
	t.trc_number = #temp_pd.asgn_id

UPDATE 	#temp_pd
SET 	#temp_pd.trc_drv = m.mpp_tractornumber
FROM  	manpowerprofile m
WHERE 	#temp_pd.asgn_type = 'DRV' and
	m.mpp_id = #temp_pd.asgn_id
--LOR	SR 7095	Titus specific

--LOR	SR#7172(PTS#4936)
UPDATE 	#temp_pd
SET 	#temp_pd.psh_name = ph.psh_name
FROM  	payschedulesheader ph, payschedulesdetail pd
WHERE 	pd.psd_id = #temp_pd.psd_id and
	ph.psh_id = pd.psh_id

--LOR	SR#7189(PTS#5362)
UPDATE 	#temp_pd
SET 	bal_gl2471 = IsNull((SELECT SUM(ROUND(pd.pyd_amount, 2)) 
			FROM paydetail pd, payheader ph
			WHERE pd.asgn_id = #temp_pd.asgn_id
				AND pd.asgn_type = #temp_pd.asgn_type
				AND pd.pyd_status <> 'HLD'
				and pd.pyd_glnum like '2471%'
				and ph.pyh_pyhnumber = pd.pyh_number
				AND ph.pyh_paystatus <> 'HLD'
				and ph.asgn_id = pd.asgn_id
				and ph.asgn_type = pd.asgn_type
				and ph.pyh_payperiod >= '01/01/' + datename(yy, @payperiodstart)), 0)


SELECT 	pyd_number, 
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
	psh_name,
	bal_gl2471,
	std_issueamount,
	drv_name,
	drv_address1,
	drv_address2,
	drv_city_state,
	drv_zip,
	ord_quantity
FROM #temp_pd
GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_det_report_general64] TO [public]
GO
