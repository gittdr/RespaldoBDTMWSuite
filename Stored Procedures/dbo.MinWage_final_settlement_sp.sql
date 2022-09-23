SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[MinWage_final_settlement_sp]
( @pyh_number	INT
, @msg			VARCHAR(255) OUTPUT
)
AS

/*
*
*
* NAME:
* dbo.MinWage_final_settlement_sp
*
* TYPE:
* StoredProcedure
*
* SAMPLE EXECUTION:
*
	declare @pyh integer
	declare @msg varchar(255)
	select @pyh=7064, @msg=''
	exec MinWage_final_settlement_sp @pyh, @msg output
	select @msg
*
* DESCRIPTION:
* Customized Stored Procedure to insert/update/delete paydetail for Minimum Wage
STL_StateMinimumWage gi_string1 must be Y to anable feature
STL_StateMinimumWageConfig gi_string3=paytype for adjustment detail
STL_StateMinimumWageConfig gi_integer2 = hours determination method
	0 log entries dated <= pay period end and > pay period end from previous period
	1 log entries only from dates covered by trips completed during this period
STL_StateMinimumWageConfig gi_integer4 state location 0=mppstate, 1=mpp_terminal
*
* RETURNS:
*
* NOTHING:
*
* 20140226 PTS73004 vjh - Created Initial Version
* 20140717 PTS80461 vjh - write intermediate numbers to new table for reporting purposes
* 20150119 PTS86139 vjh - better handle missing log data
*
*/

BEGIN

DECLARE @pyt_itemcode				VARCHAR(6)
DECLARE @TMW_pyd_number				INT
DECLARE @TMW_pyt_description		VARCHAR(30)
DECLARE @TMW_pyt_rateunit			VARCHAR(6)
DECLARE @TMW_pyt_unit				VARCHAR(6)
DECLARE @TMW_pyd_minus				INT
DECLARE @TMW_pyt_pretax				VARCHAR(1)
DECLARE @TMW_pyt_ap_glnum			VARCHAR(66)
DECLARE @TMW_pay_period_start		DATETIME
DECLARE @TMW_pay_period				DATETIME
DECLARE @TMW_asgn_type				VARCHAR(6)
DECLARE @TMW_asgn_id				VARCHAR(13)
DECLARE @TMW_asgn_number			INT

DECLARE @PeriodMinWage				MONEY
DECLARE @PeriodPay					MONEY
DECLARE @PeriodPayTrip				MONEY
DECLARE @PeriodPayNonTrip			MONEY
DECLARE @PeriodMinWageAdjustAmount	MONEY
DECLARE @PeriodHours				FLOAT
DECLARE @StateMinWage				DECIMAL(10,4)
DECLARE @DriverState				varchar(6)
DECLARE @psd_id						INT
DECLARE @psh_id						INT
DECLARE @statelocation				INT
DECLARE @grossmethod				INT
DECLARE @hoursmethod				INT
DECLARE @thisasgn					INT
DECLARE @begdate					DATETIME
DECLARE @enddate					DATETIME
DECLARE @thisdate					DATETIME

DECLARE @intermediate_pyd_number	int
DECLARE @intermediate_pyh_number	int
DECLARE @intermediate_mwc_hours		decimal(10,4)
DECLARE @intermediate_mwc_minrate	decimal(10,4)
DECLARE @intermediate_mwc_pay		money
DECLARE @intermediate_mwc_minpay	money
DECLARE @intermediate_mwc_adjf		money

declare @legs table (lgh_number int, asgn_number int)
declare @dates table (dateinclude datetime)

select @msg = ''
SELECT @pyt_itemcode = RTRIM(LTRIM(gi_string3)), @grossmethod = gi_integer1, @hoursmethod = gi_integer2, @statelocation = gi_integer4
FROM generalinfo
WHERE gi_name = 'STL_StateMinimumWageConfig' 


----Validate GI
IF @pyt_itemcode IS NULL OR @pyt_itemcode = ''
BEGIN
	RETURN 0
END
IF NOT EXISTS (SELECT 1
	FROM paytype
	WHERE pyt_itemcode = @pyt_itemcode
	)
BEGIN
	SELECT @msg = 'Pay Type <<' + @pyt_itemcode + '>> does not exist'
	RETURN -1
END
if @grossmethod is null select @grossmethod = 0
if @hoursmethod is null select @hoursmethod = 0
if @statelocation is null select @statelocation = 0

----Get Paytype details
SELECT @TMW_pyt_description = pyt_description
	, @TMW_pyt_rateunit    = pyt_rateunit
	, @TMW_pyt_unit        = pyt_unit
	, @TMW_pyd_minus       = (CASE WHEN pyt_minus = 'Y' THEN -1 ELSE 1 END)
	, @TMW_pyt_pretax      = pyt_pretax
	, @TMW_pyt_ap_glnum    = pyt_ap_glnum
FROM paytype
WHERE pyt_itemcode = @pyt_itemcode

--Get Asset Info etc from Payheader
SELECT @TMW_pay_period = p.pyh_payperiod
	, @TMW_asgn_type  = p.asgn_type
	, @TMW_asgn_id    = p.asgn_id
FROM payheader p
WHERE p.pyh_pyhnumber = @pyh_number
IF @TMW_asgn_type <> 'DRV'
RETURN 0

--Asset Assignment info
SELECT @TMW_asgn_number = MAX(asgn_number)
FROM assetassignment
WHERE asgn_type = @TMW_asgn_type
	AND asgn_id = @TMW_asgn_id

--Get Min Wage from state min wage table
select @DriverState = case @statelocation when 1 then mpp_terminal else mpp_state end
from manpowerprofile
where mpp_id = @TMW_asgn_id
select @StateMinWage = min(s.hourly_rate)
from stateminimumwage s
where s.country = 'USA' and s.state = @DriverState

if @StateMinWage is null
select @StateMinWage = min(s.hourly_rate)
from stateminimumwage s
where s.state = @DriverState

if @StateMinWage is null begin
	SELECT @msg = 'Minimum wage for <<' + @DriverState + '>> does not exist'
	RETURN -1
end

set @intermediate_mwc_minrate = @StateMinWage

--Get period start and end dates

select @psd_id = (select max(psd_id) from paydetail where pyh_number = @pyh_number)

select @TMW_pay_period = psd_date, @psh_id = psh_id
from payschedulesdetail
where psd_id = @psd_id
select @TMW_pay_period_start = max(psd_date) from payschedulesdetail where psh_id = @psh_id and psd_date < @TMW_pay_period
if @TMW_pay_period_start is null select @TMW_pay_period_start = @TMW_pay_period
select @TMW_pay_period = CONVERT(VARCHAR(10), @TMW_pay_period, 101) + ' 23:59:59'
select @TMW_pay_period_start = CONVERT(VARCHAR(10), @TMW_pay_period_start, 101) + ' 23:59:59'

if @hoursmethod = 1 or @grossmethod = 1 begin
	--need to populate @legs with trips completed during this period
	insert @legs (lgh_number, asgn_number)
	select  lgh_number, asgn_number 
	from assetassignment 
	where asgn_type='DRV' 
	and asgn_id = @TMW_asgn_id
	and asgn_enddate <= @TMW_pay_period
	and asgn_enddate > @TMW_pay_period_start

	if not exists (select * from @legs) begin
		--if trip based, and no trips this pay, then no min wage adjustment needed
		return 0
	end

	--make list of dates for use in hours calculation
	select @thisasgn = min(asgn_number) from @legs
	while @thisasgn is not null begin
		--funcky way to strip time
		select
			@begdate = dateadd(day, 0, datediff(day,0, asgn_date)),
			@enddate = dateadd(day, 0, datediff(day,0, asgn_enddate))
		from assetassignment 
		where asgn_number = @thisasgn

		select @thisdate = @begdate
		while 1=1 begin
			if not exists(select * from @dates where dateinclude = @thisdate) begin
				insert @dates (dateinclude) values (@thisdate)
			end
			select @thisdate = dateadd(day,1,@thisdate)
			if @thisdate > @enddate break
		end
		select @thisasgn = min(asgn_number) from @legs where asgn_number > @thisasgn
	end
end

--Get hours
if @hoursmethod= 0 begin
	--hours from logs in pay period
	select @PeriodHours = sum(driving_hrs + on_duty_hrs)
	from log_driverlogs
	where mpp_id = @TMW_asgn_id
		and log_date <= @TMW_pay_period
		and log_date > @TMW_pay_period_start
	select @PeriodHours = round(@PeriodHours, 3)
end else if @hoursmethod= 1 begin
	--hours from logs on dates covered by trips completed in period
	--may include logs from outside period
	--may exclude logs from inside period
	select @PeriodHours = sum(driving_hrs + on_duty_hrs)
	from log_driverlogs
	where mpp_id = @TMW_asgn_id
		and log_date in (select dateinclude from @dates)
	select @PeriodHours = round(@PeriodHours, 3)
end

set @PeriodHours = isnull(@PeriodHours,0)

set @intermediate_mwc_hours = @PeriodHours

----Gross Pay
 if @grossmethod = 0 begin
	--use pay from this pay header
	SELECT @PeriodPay = SUM(d.pyd_amount)
	  FROM paydetail d
	  JOIN paytype t ON d.pyt_itemcode = t.pyt_itemcode
	 WHERE d.pyh_number = @pyh_number
	   AND d.pyt_itemcode <> @pyt_itemcode
	   and t.pyt_minus = 'N'
	   and t.pyt_pretax = 'Y'
	IF @PeriodPay IS NULL
	   SELECT @PeriodPay = 0
end else if @grossmethod = 1 begin
	--only use pay from trips completed this period
	--if no trips completed this period, return with not adjustment

	--first look at pay for trips completed in period
	SELECT @PeriodPayTrip = SUM(d.pyd_amount)
	  FROM paydetail d
	  JOIN paytype t ON d.pyt_itemcode = t.pyt_itemcode
	 WHERE d.pyh_number = @pyh_number
	   AND d.pyt_itemcode <> @pyt_itemcode
	   and t.pyt_minus = 'N'
	   and t.pyt_pretax = 'Y'
	   and d.lgh_number in (select lgh_number from @legs)
	IF @PeriodPayTrip IS NULL
	   SELECT @PeriodPayTrip = 0

	if @PeriodPayTrip = 0 begin
		--for trip based method, trip pay is requirement
		return 0
	end

	--them get non-trip pay from pay period
	SELECT @PeriodPayNonTrip = SUM(d.pyd_amount)
	  FROM paydetail d
	  JOIN paytype t ON d.pyt_itemcode = t.pyt_itemcode
	 WHERE d.pyh_number = @pyh_number
	   AND d.pyt_itemcode <> @pyt_itemcode
	   and t.pyt_minus = 'N'
	   and t.pyt_pretax = 'Y'
	   and d.lgh_number  =0
	IF @PeriodPayNonTrip IS NULL
	   SELECT @PeriodPayNonTrip = 0

	select @PeriodPay = @PeriodPayTrip + @PeriodPayNonTrip

end

set @intermediate_mwc_pay = @PeriodPay

----state  Minimum pay
select @PeriodMinWage = @PeriodHours * @StateMinWage
select @PeriodMinWage = round(@PeriodMinWage, 2)

set @intermediate_mwc_minpay = @PeriodMinWage

----Adjust Amount
IF @PeriodMinWage = 0
   SELECT @PeriodMinWageAdjustAmount = 0
ELSE
   BEGIN
      SELECT @PeriodMinWageAdjustAmount = @PeriodMinWage - @PeriodPay
      IF @PeriodMinWageAdjustAmount < 0
         SELECT @PeriodMinWageAdjustAmount = 0
   END
SELECT @PeriodMinWageAdjustAmount = @PeriodMinWage - @PeriodPay
if @PeriodMinWageAdjustAmount <= 0 return 0

set @intermediate_mwc_adjf = @PeriodMinWageAdjustAmount

--If exists Update(when not zero) / Delete (when zero) else Insert paydetail
IF EXISTS (SELECT 1
	FROM paydetail
	WHERE pyh_number = @pyh_number
		AND pyt_itemcode = @pyt_itemcode
)
BEGIN
	IF @PeriodMinWageAdjustAmount = 0
	BEGIN
		DELETE
		FROM paydetail
		WHERE pyh_number = @pyh_number
			AND pyt_itemcode = @pyt_itemcode
	END
	ELSE
	BEGIN
		UPDATE paydetail
		SET pyd_rate = @PeriodMinWageAdjustAmount
		, pyd_amount = @PeriodMinWageAdjustAmount
		WHERE pyh_number = @pyh_number
			AND pyt_itemcode = @pyt_itemcode

		SELECT @intermediate_pyd_number = min(pyd_number)
		FROM paydetail
		WHERE pyh_number = @pyh_number
		AND pyt_itemcode = @pyt_itemcode

		set @intermediate_pyh_number = @pyh_number

		UPDATE minwagecalculations
		SET mwc_hours = @intermediate_mwc_hours
			, mwc_minrate = @intermediate_mwc_minrate
			, mwc_pay = @intermediate_mwc_pay
			, mwc_minpay = @intermediate_mwc_minpay
			, mwc_adjf = @intermediate_mwc_adjf
		WHERE pyd_number = @intermediate_pyd_number and pyh_number = @intermediate_pyh_number
	END
END
ELSE
BEGIN
	IF @PeriodMinWageAdjustAmount <> 0
	BEGIN
		EXECUTE @TMW_pyd_number = dbo.getsystemnumber 'PYDNUM', ''
		set @intermediate_pyd_number = @TMW_pyd_number
		set @intermediate_pyh_number = @pyh_number

		INSERT INTO paydetail
			( pyh_number
			, pyd_number
			, pyd_sequence
			, mov_number
			, ord_hdrnumber
			, lgh_number
			, pyd_workperiod
			, asgn_type
			, asgn_id
			, asgn_number
			, pyt_itemcode
			, pyd_description
			, pyd_quantity
			, pyd_rateunit
			, pyd_unit
			, pyd_rate
			, pyd_amount
			, pyd_minus
			, pyd_pretax
			, pyd_glnum
			, pyd_remarks
			, pyd_status
			, pyd_vendortopay
			)
		VALUES
			( @pyh_number
			, @TMW_pyd_number
			, 1
			, 0
			, 0
			, 0
			, @TMW_pay_period
			, @TMW_asgn_type
			, @TMW_asgn_id
			, @TMW_asgn_number
			, @pyt_itemcode
			, @TMW_pyt_description
			, 1
			, @TMW_pyt_rateunit
			, @TMW_pyt_unit
			, @PeriodMinWageAdjustAmount
			, @PeriodMinWageAdjustAmount
			, @TMW_pyd_minus
			, @TMW_pyt_pretax
			, @TMW_pyt_ap_glnum
			, 'Auto generated Minimum Wage Pay'
			, 'PND'
			, 'UNKNOWN'
			)

		INSERT minwagecalculations
			( pyd_number
			, pyh_number
			, mwc_hours
			, mwc_minrate
			, mwc_pay
			, mwc_minpay
			, mwc_adjf
			)
		VALUES
			( @intermediate_pyd_number
			, @intermediate_pyh_number
			, @intermediate_mwc_hours
			, @intermediate_mwc_minrate
			, @intermediate_mwc_pay
			, @intermediate_mwc_minpay
			, @intermediate_mwc_adjf
			)
	END
END
select @msg = ''
RETURN 1

END
GO
GRANT EXECUTE ON  [dbo].[MinWage_final_settlement_sp] TO [public]
GO
