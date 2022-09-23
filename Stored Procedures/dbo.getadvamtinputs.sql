SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getadvamtinputs] 
	@mpp_id				varchar(8),
	@pyt_itemcode		varchar(6),
	@mpp_otherid		varchar(25)	output,
	@mpp_status			varchar(6)	output,
	@trc_number			varchar(8)	output,
	@trc_status			varchar(6)	output,
	@ttl_advd_midnight	money		output,
	@ttl_advd_last24hrs	money		output,
	@ttl_advd_monday	money		output
	
AS

DECLARE
	@MondayDate			datetime	
		
BEGIN
	select	@mpp_otherid = mpp_otherid, 
			@mpp_status = mpp_status
	from	manpowerprofile
	where	mpp_id = @mpp_id

	select	@trc_number = ds_trc_id,
			@trc_status = trc_status
	from	driverseating
			join tractorprofile on trc_number = ds_trc_id
	where	(ds_driver1 = @mpp_id or ds_driver2 = @mpp_id)
	and		ds_seated_dt <= GETDATE()
	and		ds_unseated_dt >= GETDATE()

	-- Total Advanced since midnight
	select	@ttl_advd_midnight = abs(sum(isnull(pyd_amount,0) + ISNULL(pyt_fee1, 0)))
	from	paydetail
	where	asgn_type = 'DRV'
	and		asgn_id = @mpp_id
	and		pyt_itemcode = @pyt_itemcode
	and		DATEDIFF(day, pyd_transdate, getdate()) = 0

	-- Total advanced within last 24 hours
	select	@ttl_advd_last24hrs = abs(sum(isnull(pyd_amount, 0) + ISNULL(pyt_fee1, 0)))
	from	paydetail
	where	asgn_type = 'DRV'
	and		asgn_id = @mpp_id
	and		pyt_itemcode = @pyt_itemcode
	and		DATEDIFF(hour, pyd_transdate, getdate()) <= 24
	
	-- Total advanced since Monday
	declare @Sample				TABLE
	(
		theDate DATETIME,
		theWeekDay	varchar(10)
	)	
	insert	@Sample select getdate(), DATEname(weekday, getdate())
	insert	@Sample select DATEADD(day, -1, getdate()), DATEname(weekday, DATEADD(day, -1, getdate()))
	insert	@Sample select DATEADD(day, -2, getdate()), DATEname(weekday, DATEADD(day, -2, getdate()))
	insert	@Sample select DATEADD(day, -3, getdate()), DATEname(weekday, DATEADD(day, -3, getdate()))
	insert	@Sample select DATEADD(day, -4, getdate()), DATEname(weekday, DATEADD(day, -4, getdate()))
	insert	@Sample select DATEADD(day, -5, getdate()), DATEname(weekday, DATEADD(day, -5, getdate()))
	insert	@Sample select DATEADD(day, -6, getdate()), DATEname(weekday, DATEADD(day, -6, getdate()))
	
	select	@MondayDate = DATEADD(dd, DATEDIFF(dd,0,theDate), 0) 
	from	@sample
	where	theWeekDay = 'Monday'


	select	@ttl_advd_monday = abs(sum(isnull(pyd_amount, 0) + ISNULL(pyt_fee1, 0)))
	from	paydetail
	where	asgn_type = 'DRV'
	and		asgn_id = @mpp_id
	and		pyt_itemcode = @pyt_itemcode
	and		pyd_transdate >= @MondayDate

END

GO
GRANT EXECUTE ON  [dbo].[getadvamtinputs] TO [public]
GO
