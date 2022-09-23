SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[update_loghours] @mpp_id varchar(8) as
--declare @mpp_id varchar(8)
--SELECT @mpp_id = 'HOL1'
declare @today		datetime
	,@todayend		datetime
	,@realtoday		datetime
	,@realtodayend	datetime
	,@startdate		datetime
	,@rulehrs		int
	,@ruledays		int
declare @hours1			float
	,@hours2		float
	,@hours3		float
	,@hours1_week	float
	,@checkhrs		float
	,@hours_today	float
	,@hours_total	float, 
	@temp1 float
	,@lastupdate	datetime
declare @addhours1	float
	,@addhours2		float
declare	@ls_service_rule	varchar(255)
	,@li_pos		int
	,@li_default_ruledays	int
	,@li_default_rulehrs	int
	,@ls_ruledays		varchar(255)
	,@ls_rulehrs		varchar(255)
	,@setting			varchar(20)
	,@gi_MaxDailyOnDutyHours	int
	,@full_range_startdate	datetime
	,@reset_date		datetime
	,@entrycount		int
	,@daysinrange		int
	,@entrytoday		int
--	,@debug char(1)
	,@skip_today char (1)	/* 12/20/2010 MDH PTS 54802: Added to properly check/calculate hours 1 week. */

SET NOCOUNT ON

--vmj1+	PTS 13682	04/23/2002	Replace hard-coded Service Rule..
select	@li_default_ruledays = 8
		,@li_default_rulehrs = 70
--		,@debug='N'		/* 12/20/2010 MDH PTS 54802: Set to Y to print out temporary results. DO NOT DO IN PRODUCTION ENVIRONMENT */
		,@skip_today='N'

select	@ls_service_rule = ltrim(rtrim(isnull(mpp_servicerule, '')))
  from	manpowerprofile 
  where	mpp_id = @mpp_id

select	@li_pos = charindex('/', @ls_service_rule)
if @li_pos <= 0
	begin
		--The value is either null, or doesn't fit the syntax, so use defaults..
		select	@ruledays = @li_default_ruledays
				,@rulehrs = @li_default_rulehrs
	end
else
begin
	--Rule Days precede the /..
	select	@ls_ruledays = ltrim(rtrim(left(@ls_service_rule, @li_pos - 1)))

	--Rule Hours follow the /..
	select	@ls_rulehrs = ltrim(rtrim(substring(@ls_service_rule, @li_pos + 1, 255)))

	if isnumeric(@ls_ruledays) = 1
		and isnumeric(@ls_rulehrs) = 1
	begin
		--Both tokens must be numeric to fit the syntax..
		select	@ruledays = convert(int, @ls_ruledays)
				,@rulehrs = convert(int, @ls_rulehrs)
	end
	else
	begin
		--Use defaults..
		select	@ruledays = @li_default_ruledays
				,@rulehrs = @li_default_rulehrs
	end
end

select @today = convert(datetime,convert(varchar(15),getdate(),101))
select @todayend = convert(datetime,convert(varchar(15),getdate(),101)+' 23:59:59:996')
select @realtoday = @today, @realtodayend = @todayend --vjh 25174
-- JET - 6/29/00 - PTS #8358, store the highest date <= today in the @lastupdate variable
SELECT @lastupdate = MAX(log_date) 
  FROM log_driverlogs 
 WHERE mpp_id = @mpp_id AND 
       log_date <= @todayend 

-- JET - 6/29/00 - PTS #8358, if no date was found, set the default to 1/1/1950
IF @lastupdate IS NULL
   SELECT @lastupdate = '19500101 00:00'

-- PTS 15414 - DJM - Use GeneralInfo setting to determine what date to use when determining
--	Available hours.
select @setting = isNull(Upper(gi_string1),'TODAY') from generalinfo where gi_name = 'AvailableHoursCalc'
if @@rowcount = 0 OR @setting = ''
	Set @setting = 'TODAY'

if @setting = 'STANDARD'
	-- This was the existing functionality before PTS 15414.
	Begin
		/* check if there are log entry for today?? 
			if so assume we are looking for tomorrows avl hrs*/
		if (select count(*)
			from log_driverlogs
			where mpp_id = @mpp_id and
				log_date between @today and @todayend) > 0 
		begin
			/* add one to today*/
			select @today = DATEADD(day, 1, @today), @skip_today = 'Y'
			
		end
	End
--IF @setting = 'TODAY'
	-- Do Nothing, it's aready looking at Today
if @setting = 'TOMORROW'
	-- Add a day to the Today variable
	-- 12/20/2010 MDH PTS 54802: Add one to realtoday and realtodayend
	select @today = DATEADD(day, 1, @today), 
			@realtoday = DATEADD(day, 1, @realtoday), 
			@realtodayend = DATEADD(day, 1, @realtodayend)
-- End PTS 15414

/*use rule days - 1 because it should not count today*/
select @startdate = DATEADD(day, 1 - @ruledays, @today)

/*set today equal to 23:59:59:996 (2 milliseconds was needed)*/
select @today = DATEADD(day, 1, @today)
select @today = DATEADD(ms, -2, @today)

--vmj5+  Find the last day in the range which has rule_reset_indc ON..
select	@full_range_startdate = @startdate
		,@reset_date = null

select	@reset_date = max(log_date)
  from	log_driverlogs
  where	mpp_id = @mpp_id
	and	log_date between @startdate and @today
	and	rule_reset_indc = 'Y'

if @reset_date is not null
begin
	select	@startdate = @reset_date

	--Change @ruledays value to just the days from the last reset until today.  From this point
	--on in the SP, @ruledays is ONLY used to check for NULL logs in the rule time range.  If 
	--there are NULL logs within the standard rule, but none after a reset has occurred, don't 
	--treat it as an error..
	select	@ruledays = datediff(dd, @reset_date, @today) + 1
end
--vmj5-

/*total avl hours for last 7 days*/
--vjh 25174 also get the number of entries to look for missing entries

--IF @debug='Y'
--	SELECT @ruledays [rule days],@rulehrs [rule hours], @realtoday [real today], @realtodayend [real today end]		--DEBUG

select @hours1 = @rulehrs - isnull(sum(driving_hrs+on_duty_hrs), 0),
	 @checkhrs = sum(isnull(off_duty_hrs,0)+isnull(sleeper_berth_hrs,0)
			+isnull(driving_hrs,0)+isnull(on_duty_hrs,0)),
	@entrycount = count(*)
from log_driverlogs
where mpp_id = @mpp_id and
	log_date between @startdate and @today

	
--JLB PTS 49670
select @checkhrs = @checkhrs + ((@ruledays - @entrycount)*24)
--end 49670

--IF @debug='Y'
--	SELECT @hours1 [hours1], @startdate [start date], @today [today], @checkhrs [check hours]   --DEBUG

--vjh 25174 check for an entry today (today is optional)
select	@entrytoday = count(*), @hours_today = ISNULL (sum (driving_hrs+on_duty_hrs), 0)
from	log_driverlogs
where	mpp_id = @mpp_id and
	log_date between @realtoday and @realtodayend
IF @setting='STANDARD'
	SET @hours_today = 0

--vjh 25174 compare number of days in the date range to the number of entries
-- if they are the same, or only today is missing, use the hours, otherwise
-- use -100 to indicate missing, required entries.
select @daysinrange = datediff(day,@startdate, @today) + 1
if (@daysinrange = @entrycount and @entrytoday=1) 
    or (@daysinrange-1 = @entrycount and @entrytoday=0)
    OR (@daysinrange-1 = @entrycount AND @entrytoday=1 AND @skip_today = 'Y')
	select	@hours1_week=@hours1
ELSE
	select @hours1_week=-100
--IF @debug='Y'
--	SELECT @daysinrange [days in range], @entrycount [entry count], @entrytoday [entry today], @hours1_week [hours week1] -- DEBUG

--vmj3+	PTS 19246	11/05/2003	Get GeneralInfo.MaxDailyOnDutyHours to replace the hard-coded 
--15 maximum on-duty hours for a single day..
select	@gi_MaxDailyOnDutyHours = convert(int, gi_string1)
  from	generalinfo
  where	gi_name = 'MaxDailyOnDutyHours'

--The default is 14..
if @gi_MaxDailyOnDutyHours is null
		or @gi_MaxDailyOnDutyHours <= 0
	select	@gi_MaxDailyOnDutyHours = 14

-- 12/20/2010 MDH PTS 54802: 
-- At this point, @hours1 is the total hours remaining that can be worked.
-- The code prior to this was assuming that it was also the hours that 
-- could be worked today, which it isn't; I added code to get the sum of 
-- hours worked for each day in @hours_today. Old code moved to end of 
-- proc.
if @checkhrs >= (@ruledays - 1) * 24
begin
	SELECT @hours_total = @hours1
	SELECT @hours1 = @gi_MaxDailyOnDutyHours - @hours_today
	if @hours1 > 0
	BEGIN
		IF @hours1 > @hours_total
			SELECT @hours1 = @hours_total
	END
	--IF @debug='Y'
	--	select @hours1 [hours 1], @hours_total [hours total], @hours_today [hours today], @startdate  -- DEBUG
	
	/*PTS10716 MBR 7/18/01 When @hours1 is negative it is actually getting added like a positive in the @hours2 calculatin.
                Do the same for @hours2.*/
	select @addhours1 = @hours1
	if @addhours1 < 0 select @addhours1 = 0

	/*total avl hours for last 6 days + day1*/
	--select @startdate = DATEADD(day, 1, @startdate) 
	-- KMM 23738 for Matt Ruth
	select @startdate = case when @Reset_date is null then DATEADD(day, 1, @startdate) else @Reset_date end

	select @hours_total = @rulehrs - (isnull(sum(driving_hrs+on_duty_hrs),0) + @addhours1),
			@hours2 = @gi_MaxDailyOnDutyHours 
		from log_driverlogs
		where mpp_id = @mpp_id  
		and log_date between @startdate and @today
	IF @hours2 > @hours_total
		SELECT @hours2 = @hours_total
	--IF @debug='Y'
	--	select @hours2 [hours 2], @hours_total [hours total], @addhours1 [add 1],  @startdate  -- DEBUG

	select @addhours2 = @hours2
	if @addhours2 < 0 select @addhours2 = 0

	/*total avl hours for last 5 days + day1 + day2*/
	--select @startdate = DATEADD(day, 1, @startdate) 
	-- KMM 23738 for Matt Ruth
	select @startdate = case when @Reset_date is null then DATEADD(day, 1, @startdate) else @Reset_date end
	select @hours_total = @rulehrs - (isnull(sum(driving_hrs+on_duty_hrs),0) + @addhours1 + @addhours2),
		@hours3 = @gi_MaxDailyOnDutyHours
	from log_driverlogs
	where mpp_id = @mpp_id 
	and log_date between @startdate and @today

	IF @hours3 > @hours_total
		SELECT @hours3 = @hours_total
	--IF @debug='Y'
	--	select @hours3 [hours 3], @hours_total [hours total], @addhours2 [add 2], @startdate -- DEBUG
end
else
begin
	select @hours1=null, @hours2=null, @hours3=null
end

update manpowerprofile 
-- JET - 6/29/00 - PTS #8358, changed the last log date to new variable
--set mpp_last_log_date = @today,
set mpp_last_log_date = @lastupdate,
	mpp_hours1 = @hours1,
	mpp_hours2 = @hours2,
	mpp_hours3 = @hours3,
	mpp_hours1_week = @hours1_week
where mpp_id = @mpp_id

GO
GRANT EXECUTE ON  [dbo].[update_loghours] TO [public]
GO
