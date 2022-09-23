SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



create proc [dbo].[d_stlmnt_sheet_summary_dds]
		(@payperiodstart datetime
		,@payperiodend datetime
		,@drv_yes varchar(3)
		,@trc_yes varchar(3)
		,@trl_yes varchar(3)
		,@drv_id varchar(8)
		,@trc_id varchar(8)
		,@trl_id varchar(13)
		,@drv_type1 varchar(6)
		,@trc_type1 varchar(6)
		,@trl_type1 varchar(6)
		,@terminal varchar(8)
		,@name varchar(64)
		,@car_yes varchar(3)
		,@car_id varchar(8)
		,@car_type1 varchar(6)
		,@hld_yes varchar(3)
		,@pyhnumber int
		,@tpr_yes varchar(3)
		,@tpr_id	varchar(8)
		,@relcol varchar(3)
		,@relncol varchar(3)
		,@workperiodstart datetime
		,@workperiodend datetime)
as
/* Revision History:
	Date		Name			PTS #	Label	Description
	-----------	---------------	-------	-------	----------------------------------------------------------------------
	11/07/2001	Vern Jewett		11668	(none)	Original, copied from SP d_stlmnt_sheet_summary_tpr_new, and modified.
	01/14/2002	Vern Jewett		12963	vmj1	Don't get caught by PayDetails with PayPeriods or WorkPeriods that are 59 
												seconds after the Apocalypse!!!
	01/18/2002	Vern Jewett		13028	vmj2	Show ord_number, not ord_hdrnumber; remove "Express" from title; 
												description shows blank for some paydetails.
	05/21/2002	Vern Jewett		14411	vmj3	Duplicate rows are appearing in report.
	03/20/2003	Vern Jewett		17698	vmj4	Some paydetails with pyd_minus = 0 are showing up in the "Uncategorized"
												section, should be in "Other Pay and Reimbursements" section.
	08/08/2005	jguo			29148		Replace double quotes.
*/


declare	@ls_whats_left	varchar(255)
		,@ls_token		varchar(255)
		,@li_pos		smallint


--Create temp tables.
--#temp_pay stores the pyd_numbers which make up the "scope" of the settlement sheet report. 
CREATE TABLE #temp_pay
		(pyd_number 	int 		not null
		,pyh_number 	int 		not null
		,pyd_status 	varchar(6) 	null
		,asgn_type		varchar(6) 	null
		,asgn_id		varchar(12)	null
		,display_group	smallint 	null)

--#temp_pay_fnl eliminates duplicate rows from #temp_pay..
CREATE TABLE #temp_pay_fnl
		(pyd_number 	int 		not null
		,pyh_number 	int 		not null
		,pyd_status 	varchar(6) 	null
		,asgn_type		varchar(6) 	null
		,asgn_id		varchar(12)	null
		,display_group	smallint 	null)

--#ord_revenue collects revenue info which is displayed in section 1..
create table #ord_revenue
		(ord_hdrnumber		int			null
		,line_haul_charge	money		null
		,permit_charge		money		null
		,escort_charge		money		null
		,permit_cost		money		null
		,escort_cost		money		null)

--#orders collects the list of distinct Orders included in this Settlement Sheet.  It's used to produce #ord_revenue data..
create table #orders
		(ord_hdrnumber		int			null)

--#ord_rev_1 is an interim step in producing #ord_revenue data..
create table #ord_rev_1
		(ord_hdrnumber		int			null
		,col_indc			varchar(3)	null
		,amount				money		null)

--#escort_cht will contain the list of Charge/Backout Types that will appear in Escort columns on the report.  Data is taken
--from generalinfo's EscortItemCodeList..
create table #escort_cht
		(cht_itemcode		varchar(6)	null)

--#permit_cht contains list of Charge/Backout Types for Permit columns; taken from generalinfo PermitItemCodeList..
create table #permit_cht
		(cht_itemcode		varchar(6)	null)

--#asset_addr contains the address to send the settlement sheet to, for each unique asset included..
create table #asset_addr
		(asgn_type	varchar(6)		null
		,asgn_id	varchar(8)		null
		,asset_name	varchar(255)	null
		,address1	varchar(64)		null
		,address2	varchar(64)		null
		,city		varchar(18)		null
		,state		varchar(6)		null
		,zip		varchar(10)		null)


--vmj1+
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
			pyd_status,
			asgn_type,
			asgn_id,
			0				--display_group default
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
			asgn_type,
			asgn_id,
			0				--display_group default
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
			asgn_type,
			asgn_id,
			0				--display_group default
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
			asgn_type,
			asgn_id,
			0				--display_group default
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
			asgn_type,
			asgn_id,
			0				--display_group default
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
			asgn_type,
			asgn_id,
			0				--display_group default
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
			asgn_type,
			asgn_id,
			0				--display_group default
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
			asgn_type,
			asgn_id,
			0				--display_group default
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
			asgn_type,
			asgn_id,
			0				--display_group default
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
			asgn_type,
			asgn_id,
			0				--display_group default
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
			pd.asgn_type,
			pd.asgn_id,
			0				--display_group default
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
			pd.asgn_type,
			pd.asgn_id,
			0				--display_group default
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
			pd.asgn_type,
			pd.asgn_id,
			0				--display_group default
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
			pd.asgn_type,
			pd.asgn_id,
			0				--display_group default
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
			pd.asgn_type,
			pd.asgn_id,
			0				--display_group default
		FROM paydetail pd, payheader ph
		WHERE ph.asgn_type = 'TPR'
			AND ph.pyh_payperiod BETWEEN @payperiodstart and @payperiodend
			AND pd.pyh_number = ph.pyh_pyhnumber
			AND @tpr_id = ph.asgn_id
		-- LOR	select paydetails for the given payheader only
		AND pyh_number = @pyhnumber
		-- LOR
END


--At this point, #temp_pay contains the scope of all PayDetails to be included in the Settlement Sheet.  The original code
--which defines what data to pull in surrounding those PayDetails has been replaced, since this settlement sheet is so 
--unique..

--vmj3+	Weed out all duplicate rows from "scope".  All subsequent references to #temp_pay have
--been replaced by #temp_pay_fnl, with no additional revision comments..
insert into #temp_pay_fnl
  select distinct pyd_number
		,pyh_number
		,pyd_status
		,asgn_type
		,asgn_id
		,display_group
  from	#temp_pay
--vmj3-


--Get a list of distinct ord_hdrnumber's to be reported..
insert into #orders
  select distinct ord_hdrnumber
  from	#temp_pay_fnl tp
		,paydetail pyd
  where	pyd.pyd_number = tp.pyd_number


--Get the list of Permit Charge/Pay/Backout Types from generalinfo, and parse into #permit_cht table..
select	@ls_whats_left = ltrim(rtrim(gi_string1))
  from	generalinfo gi1
  where	gi_name = 'PermitItemCodeList'
	and	exists
		(select 'x'
		  from	generalinfo gi2
		  where	gi2.gi_name = gi1.gi_name
			and	gi2.gi_datein <= getdate()
		  group by gi2.gi_name
		  having gi1.gi_datein = max(gi2.gi_datein))

--Find the 1st comma..		
select	@li_pos = charindex(',', @ls_whats_left)
while @li_pos > 0
begin
	select	@ls_token = ltrim(rtrim(left(@ls_whats_left, @li_pos - 1)))
	if @ls_token <> ''
		insert into #permit_cht
				(cht_itemcode)
		  values (@ls_token)

	select	@ls_whats_left = ltrim(rtrim(substring(@ls_whats_left, @li_pos + 1, 255)))
	select	@li_pos = charindex(',', @ls_whats_left)
end

--Store the last token..
if @ls_whats_left <> ''
	insert into #permit_cht
			(cht_itemcode)
	  values (@ls_whats_left)


--Get the list of Escort Charge/Pay/Backout Types from generalinfo, and parse into #escort_cht table..
select	@ls_whats_left = ltrim(rtrim(gi_string1))
  from	generalinfo gi1
  where	gi_name = 'EscortItemCodeList'
	and	exists
		(select 'x'
		  from	generalinfo gi2
		  where	gi2.gi_name = gi1.gi_name
			and	gi2.gi_datein <= getdate()
		  group by gi2.gi_name
		  having gi1.gi_datein = max(gi2.gi_datein))

--Find the 1st comma..		
select	@li_pos = charindex(',', @ls_whats_left)
while @li_pos > 0
begin
	select	@ls_token = ltrim(rtrim(left(@ls_whats_left, @li_pos - 1)))
	if @ls_token <> ''
		insert into #escort_cht
				(cht_itemcode)
		  values (@ls_token)

	select	@ls_whats_left = ltrim(rtrim(substring(@ls_whats_left, @li_pos + 1, 255)))
	select	@li_pos = charindex(',', @ls_whats_left)
end

--Store the last token..
if @ls_whats_left <> ''
	insert into #escort_cht
			(cht_itemcode)
	  values (@ls_whats_left)


--Insert order revenue for LineHaul charges..
insert into #ord_rev_1
		(ord_hdrnumber
		,col_indc
		,amount)
  select ivd.ord_hdrnumber
		,'L'
		,ivd.ivd_charge
  from	#orders o
		,invoicedetail ivd
		,chargetype cht
  where	ivd.ord_hdrnumber = o.ord_hdrnumber
	and	cht.cht_itemcode = ivd.cht_itemcode
	and	cht.cht_primary = 'Y'
	and	cht.cht_basis = 'SHP'

--Insert order revenue for Permit charges..
insert into #ord_rev_1
		(ord_hdrnumber
		,col_indc
		,amount)
  select ivd.ord_hdrnumber
		,'P'
		,ivd.ivd_charge
  from	#orders o
		,invoicedetail ivd
		,#permit_cht pc
  where	ivd.ord_hdrnumber = o.ord_hdrnumber
	and	pc.cht_itemcode = ivd.cht_itemcode

--Insert order revenue for Escort charges..
insert into #ord_rev_1
		(ord_hdrnumber
		,col_indc
		,amount)
  select ivd.ord_hdrnumber
		,'E'
		,ivd.ivd_charge
  from	#orders o
		,invoicedetail ivd
		,#escort_cht ec
  where	ivd.ord_hdrnumber = o.ord_hdrnumber
	and	ec.cht_itemcode = ivd.cht_itemcode

--Insert Permit cost/backout; let 'Q' represent Permits Actual..
insert into #ord_rev_1
		(ord_hdrnumber
		,col_indc
		,amount)
  select ibo.ord_hdrnumber
		,'Q'
		,ibo.ibo_backoutamt
  from	#orders o
		,invoicebackouts ibo
		,#permit_cht pc
  where	ibo.ord_hdrnumber = o.ord_hdrnumber
	and	pc.cht_itemcode = ibo.boc_itemcode

--Insert Escort cost/backout; let 'F' represent Escorts Actual..
insert into #ord_rev_1
		(ord_hdrnumber
		,col_indc
		,amount)
  select ibo.ord_hdrnumber
		,'F'
		,ibo.ibo_backoutamt
  from	#orders o
		,invoicebackouts ibo
		,#escort_cht ec
  where	ibo.ord_hdrnumber = o.ord_hdrnumber
	and	ec.cht_itemcode = ibo.boc_itemcode


--Pivot the data..
insert into #ord_revenue
		(ord_hdrnumber
		,line_haul_charge
		,permit_charge
		,escort_charge
		,permit_cost
		,escort_cost)
  select ord_hdrnumber
		,sum(amount * charindex('L', col_indc))
		,sum(amount * charindex('P', col_indc))
		,sum(amount * charindex('E', col_indc))
		,sum(amount * charindex('Q', col_indc))
		,sum(amount * charindex('F', col_indc))
  from	#ord_rev_1
  group by ord_hdrnumber		  


--Assign a "display_group" value which will define the different sub-sections of the Settlement Sheet.  1st group is for 
--LineHaul pay..
update	#temp_pay_fnl
  set	display_group = 1
  from	#temp_pay_fnl tp
		,paydetail pyd
		,paytype pyt
  where	tp.display_group = 0
	and	pyd.pyd_number = tp.pyd_number
	and	pyt.pyt_itemcode = pyd.pyt_itemcode
	and	pyt.pyt_basis = 'LGH'

--Other Revenue & Reimbursements..
update	#temp_pay_fnl
  set	display_group = 2
  from	#temp_pay_fnl tp
		,paydetail pyd
  where	tp.display_group = 0
	and	pyd.pyd_number = tp.pyd_number
	--vmj4+
	and isnull(pyd.pyd_minus, 0) >= 0
--	and	pyd.pyd_minus = 1
	--vmj4-

--Deductions..
update	#temp_pay_fnl
  set	display_group = 3
  from	#temp_pay_fnl tp
		,paydetail pyd
  where	tp.display_group = 0
	and	pyd.pyd_number = tp.pyd_number
	and	pyd.pyd_minus = -1

--If there are any rows that don't fit into any of the above categories, assign 99 rather than leaving it to 0, so it will
--sort at the end..
update	#temp_pay_fnl
  set	display_group = 99
  where	display_group = 0


--Supply addresses..
insert into #asset_addr
		(asgn_type
		,asgn_id
		,asset_name
		,address1
		,address2
		,city
		,state
		,zip)
  select distinct asgn_type
		,asgn_id
		,''
		,''
		,''
		,''
		,''
		,''
  from	#temp_pay_fnl


--Get Drivers' addresses..
update	#asset_addr
  set	asset_name = isnull(mpp.mpp_firstname + ' ', '') + isnull(mpp.mpp_middlename + ' ', '') + isnull(mpp.mpp_lastname, '')
		,address1 = isnull(mpp.mpp_address1, '')
		,address2 = isnull(mpp.mpp_address2, '')
		,city = isnull(cty.cty_name, '')
		,state = isnull(cty.cty_state, '')
		,zip = isnull(mpp.mpp_zip, '')
  from	#asset_addr aa
			inner join manpowerprofile mpp on mpp.mpp_id = aa.asgn_id
			left outer join city cty on mpp.mpp_city = cty.cty_code
  where	aa.asgn_type = 'DRV'
	
--Get Tractors' addresses.  First find PayTo's that match the Tractor's trc_owner..
update	#asset_addr
  set	asset_name = isnull(pto.pto_fname + ' ', '') + isnull(pto.pto_mname + ' ', '') + isnull(pto.pto_lname, '')
		,address1 = isnull(pto.pto_address1, '')
		,address2 = isnull(pto.pto_address2, '')
		,city = isnull(cty.cty_name, '')
		,state = isnull(cty.cty_state, '')
		,zip = isnull(pto.pto_zip, '')
  from	#asset_addr aa
			inner join tractorprofile trc on trc.trc_number = aa.asgn_id
			inner join payto pto on pto.pto_id = trc.trc_owner
			left outer join city cty on pto.pto_city = cty.cty_code
  where	aa.asgn_type = 'TRC'
	
--If there are any cases where the Tractor Owner/PayTo didn't return anything, get the Driver info..
update	#asset_addr
  set	asset_name = isnull(mpp.mpp_firstname + ' ', '') + isnull(mpp.mpp_middlename + ' ', '') + isnull(mpp.mpp_lastname, '')
		,address1 = isnull(mpp.mpp_address1, '')
		,address2 = isnull(mpp.mpp_address2, '')
		,city = isnull(cty.cty_name, '')
		,state = isnull(cty.cty_state, '')
		,zip = isnull(mpp.mpp_zip, '')
  from	#asset_addr aa
			inner join tractorprofile trc on trc.trc_number = aa.asgn_id
			inner join manpowerprofile mpp on mpp.mpp_id = trc.trc_driver
			left outer join city cty on mpp.mpp_city = cty.cty_code
  where	aa.asgn_type = 'TRC'
	and	aa.asset_name = ''

--Get Trailers' addresses..
update	#asset_addr
  set	asset_name = isnull(pto.pto_fname + ' ', '') + isnull(pto.pto_mname + ' ', '') + isnull(pto.pto_lname, '')
		,address1 = isnull(pto.pto_address1, '')
		,address2 = isnull(pto.pto_address2, '')
		,city = isnull(cty.cty_name, '')
		,state = isnull(cty.cty_state, '')
		,zip = isnull(pto.pto_zip, '')
  from	#asset_addr aa
			inner join trailerprofile trl on trl.trl_number = aa.asgn_id
			inner join payto pto on pto.pto_id = trl.trl_owner
			left outer join city cty on pto.pto_city = cty.cty_code
  where	aa.asgn_type = 'TRL'

--Get Carriers' addresses..
update	#asset_addr
  set	asset_name = isnull(car.car_name, '')
		,address1 = isnull(car.car_address1, '')
		,address2 = isnull(car.car_address2, '')
		,city = isnull(cty.cty_name, '')
		,state = isnull(cty.cty_state, '')
		,zip = isnull(car.car_zip, '')
  from	#asset_addr aa
			inner join carrier car on car.car_id = aa.asgn_id
			left outer join city cty on car.cty_code = cty.cty_code
  where	aa.asgn_type = 'CAR'

--Get Third Parties' addresses..
update	#asset_addr
  set	asset_name = isnull(tpr.tpr_name, '')
		,address1 = isnull(tpr.tpr_address1, '')
		,address2 = isnull(tpr.tpr_address2, '')
		,city = isnull(cty.cty_name, '')
		,state = isnull(cty.cty_state, '')
		,zip = isnull(tpr.tpr_zip, '')
  from	#asset_addr aa
			inner join thirdpartyprofile tpr on tpr.tpr_id = aa.asgn_id
			left outer join city cty on tpr.tpr_city = cty.cty_code
  where	aa.asgn_type = 'TPR'

--Select final result set..
select	pyd.asgn_type
		,pyd.asgn_id
		,tp.display_group

		--vmj2+	We don't need the expression any more, because we want to sort on ord_number instead of ord_hdrnumber..
		,pyd.ord_hdrnumber
--		--The characteristic expression below returns 999999999 if ord_hdrnumber is 0 or NULL, the true value otherwise.  
--		--This is done so the PayDetails without Order #'s sort last..
--		,999999999 * (1 - abs(sign(isnull(pyd.ord_hdrnumber, 0)))) + isnull(pyd.ord_hdrnumber, 0) as ord_hdrnumber

		,isnull(pyd.pyd_description, '') as pyd_description
--		,pyd.pyd_description
		--vmj2-

		,pyd.pyd_number
		,pyd.pyh_number
		,orv.line_haul_charge
		,orv.permit_charge
		,orv.escort_charge
		,orv.permit_cost
		,orv.escort_cost
		,pyd.pyd_quantity
		,pyd.pyd_rate
		,pyd.pyd_amount
		,aa.asset_name
		,aa.address1
		,aa.address2
		,aa.city
		,aa.state
		,aa.zip

		--If the PayDetail description contains the PayType description (as is frequently the case), return empty string..
		--vmj2+	Fix prob where description is blank by adding an isnull call.
		,replicate(pyt.pyt_description, 1 - sign(charindex(pyt.pyt_description, isnull(pyd.pyd_description, '')))) 
			as pyt_description
--		,replicate(pyt.pyt_description, 1 - sign(charindex(pyt.pyt_description, pyd.pyd_description))) as pyt_description
		--vmj2-

		--vmj2+	Return ord_number, with blank rows sorted last ('ZZZZZZZZZZZZ')..
		,isnull(ltrim(rtrim(ord.ord_number)), 'ZZZZZZZZZZZZ') as ord_number
		--vmj2-

  from	#temp_pay_fnl tp
			inner join paydetail pyd on pyd.pyd_number = tp.pyd_number
			left outer join orderheader ord on pyd.ord_hdrnumber = ord.ord_hdrnumber
			left outer join #ord_revenue orv on pyd.ord_hdrnumber = orv.ord_hdrnumber
			inner join #asset_addr aa on aa.asgn_type = tp.asgn_type and aa.asgn_id = tp.asgn_id
			inner join paytype pyt on pyt.pyt_itemcode = pyd.pyt_itemcode
  order by pyd.asgn_type
		,pyd.asgn_id
		,tp.display_group
		,ord_number
		,pyd_description

--Cleanup temp tables..
drop table #temp_pay
--vmj3+
drop table #temp_pay_fnl
--vmj3-
drop table #ord_revenue
drop table #orders
drop table #ord_rev_1
drop table #escort_cht
drop table #permit_cht


/* Original data-gathering code, COMMENTED OUT..
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
	pyd_payto		varchar(12) null, 
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
	crd_cardnumber		char(10) null,
	lgh_startdate		datetime null,
	std_balance		money null,
	itemsection		int null,
	ord_startdate		datetime null,
	ord_number		char(10) null,
	ref_number		varchar(20) null,
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
	lgh_count		int null)

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
	null,
	null,
	null,
	null,
	null,
	null,
	0
FROM paydetail pd, #temp_pay tp
WHERE pd.pyd_number = tp.pyd_number

--Update the temp pay details with legheader data
UPDATE #temp_pd
SET mov_number = lh.mov_number,
	lgh_number = lh.lgh_number,
	lgh_startdate = lh.lgh_startdate
FROM #temp_pd tp, legheader lh
WHERE tp.lgh_number = lh.lgh_number

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
FROM #temp_pd tp, orderheader oh
WHERE tp.ord_hdrnumber = oh.ord_hdrnumber

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
FROM #temp_pd tp, company co, city ct, orderheader oh
WHERE tp.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_shipper = co.cmp_id
  AND co.cmp_city = ct.cty_code

--Update the temp pay details with consignee data
UPDATE #temp_pd
SET consignee_name = co.cmp_name,
	consignee_city = ct.cty_name,
	consignee_state = ct.cty_state
FROM #temp_pd tp, company co, city ct, orderheader oh
WHERE tp.ord_hdrnumber = oh.ord_hdrnumber
  AND oh.ord_consignee = co.cmp_id
  AND co.cmp_city = ct.cty_code

--Update the temp pay details with standingdeduction data
UPDATE #temp_pd
SET std_balance = sd.std_balance
FROM #temp_pd tp, standingdeduction sd

WHERE tp.std_number = sd.std_number

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
SET crd_cardnumber = ph.crd_cardnumber
FROM #temp_pd tp, payheader ph
WHERE tp.pyh_number = ph.pyh_pyhnumber

--Update the temp pay details with paytype data
--LOR	PTS#4339 - add fee1, fee2
UPDATE #temp_pd
SET pyt_description = pt.pyt_description,
    pyt_fee1 = pt.pyt_fee1,
    pyt_fee2 = pt.pyt_fee2
FROM #temp_pd tp, paytype pt
WHERE tp.pyt_itemcode = pt.pyt_itemcode

--Need to get the stop of the 1st delivery and find the commodity and arrival date
--associated with it.
--Update the temp pay details table with stop data for the 1st unload stop
UPDATE #temp_pd
SET stp_mfh_sequence = (SELECT MIN(st.stp_mfh_sequence)
	FROM stops st

	WHERE st.ord_hdrnumber = tp.ord_hdrnumber
	  AND st.stp_event in ('DLUL', 'LUL', 'DUL', 'PUL')) 
FROM #temp_pd tp

UPDATE #temp_pd
SET stp_number = st.stp_number
FROM stops st, #temp_pd tp
WHERE st.ord_hdrnumber = tp.ord_hdrnumber
  AND st.stp_mfh_sequence = tp.stp_mfh_sequence

--Update the temp pay details with commodity data
UPDATE #temp_pd
SET cmd_name = cd.cmd_name,
	stp_arrivaldate = st.stp_arrivaldate
FROM #temp_pd tp, freightdetail fd, commodity cd, stops st
WHERE st.stp_number = tp.stp_number
 AND fd.stp_number = st.stp_number
 AND cd.cmd_code = fd.cmd_code

--Need to get the bill-of-lading from the reference number table
--Update the temp pay details with reference number data
UPDATE #temp_pd
SET ref_number = rn.ref_number
FROM #temp_pd tp, referencenumber rn
WHERE rn.ref_tablekey = tp.ord_hdrnumber
  AND rn.ref_table = 'orderheader'
  AND rn.ref_type = 'SID'

--Need to get revenue charge type data from the chargetype table
UPDATE #temp_pd
SET cht_basis =	ct.cht_basis,
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
CREATE TABLE #YTDBAL (asgn_type	varchar (6) not null,
	asgn_id			varchar (13) not null,
	ytdcomp			money null,
	ytddeduct		money null,
	ytdreimbrs		money null)

--Insert into the temp YTD balances table the assets from the temp pay details table
INSERT INTO #YTDBAL
SELECT asgn_type, asgn_id, 0, 0, 0
FROM #temp_pd

--Compute the YTD balances for each assets
--LOR	fixed null problem SR 7095
UPDATE #YTDBAL
SET ytdcomp = ISNULL((SELECT SUM(ROUND(ph.pyh_totalcomp, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0),
   ytddeduct = ISNULL((SELECT SUM(ROUND(ph.pyh_totaldeduct, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0),
   ytdreimbrs = ISNULL((SELECT SUM(ROUND(ph.pyh_totalreimbrs, 2))
		FROM payheader ph
		WHERE ph.asgn_id = yb.asgn_id
	  		AND ph.asgn_type = yb.asgn_type
	  		AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) >= '01/01/' + datename(yy, @payperiodend)
                        AND isnull(ph.pyh_issuedate,ph.pyh_payperiod) < @payperiodend
                        AND ph.pyh_paystatus <> 'HLD'), 0)
FROM #YTDBAL yb

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
FROM #YTDBAL yb, #temp_pd tp
WHERE tp.asgn_type = yb.asgn_type
  AND tp.asgn_id = yb.asgn_id

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
SET 	userlabelname = l.userlabelname,
	label_name = l.name,
	otherid = m.mpp_otherid
FROM #temp_pd tp, labelfile l, manpowerprofile m
WHERE 	m.mpp_id = tp.asgn_id and
	l.labeldefinition = 'DrvType1' and
	m.mpp_type1 = l.abbr 

--Update the temp pay details with start/end city/state data - LOR PTS# 4457
UPDATE #temp_pd
SET 	start_city = ct.cty_name,
	start_state = ct.cty_state
FROM #temp_pd tp, city ct
WHERE  ct.cty_code = tp.lgh_startcity

UPDATE #temp_pd
SET 	end_city = ct.cty_name,
	end_state = ct.cty_state
FROM #temp_pd tp, city ct
WHERE  ct.cty_code = tp.lgh_endcity

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
	pyt_fee1,
	pyt_fee2,
	start_city,
	start_state,
	end_city,
	end_state
FROM #temp_pd
*/
GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_sheet_summary_dds] TO [public]
GO
