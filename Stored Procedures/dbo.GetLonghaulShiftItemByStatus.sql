SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Generates the fake shift record for longhaul equipment.  The exact shift characteristics are determined by the uncompleted activity in the equipment's last 30 trips.  The
-- shift will always encompass all such activity.  If the first uncompleted trip in that list is in Started status, then the shift will be considered to start at the time and 
-- place of that started trip.  If that trip is in Planned or Dispatched status, then the shift will start 1 minute after the last completed trip that ends before that 
-- planned or dispatched trip at the location that the completed trip ends at.
create proc [dbo].[GetLonghaulShiftItemByStatus] @eqptype varchar(6), @eqpid varchar(13)
as
declare @startlgh int, @startlghdate datetime, @startdrv varchar(8), @starttrc varchar(8), @starttrl varchar(13), @startpup varchar(13)
declare @startcar varchar(8), @terminal varchar(6), @updatedby varchar(128), @updatedon datetime, @startstatus varchar(6)
declare @fleet varchar(6), @enddate datetime, @startcmp varchar(8), @startdate datetime, @carriername varchar(64)
create table #LonghaulShiftItemLegs (lgh_number int, status varchar(6), start datetime, enddate datetime)
insert into #LonghaulShiftItemLegs (lgh_number, status, start, enddate)
select top 30 lgh_number, asgn_status, asgn_date, asgn_enddate from assetassignment where asgn_id = @eqpid and asgn_type = @eqptype order by asgn_date desc
select top 1 @startlgh = lgh_number, @startstatus = status, @startdate = start, @startlghdate = start from #LonghaulShiftItemLegs where status in ('STD', 'PLN', 'DSP') order by start

if @startlgh is null	-- All activity is completed.  Start and end are just after the last trip.
	select top 1 @startlgh = lgh_number, @startstatus = status, @startdate = start, @startlghdate = dateadd(minute, 1, enddate), @enddate = dateadd(minute, 1, enddate) from #LonghaulShiftItemLegs order by enddate desc
else	-- Some open activity.  End is at its end.
	select top 1 @enddate = enddate from #LonghaulShiftItemLegs order by enddate desc

if (@startstatus = 'PLN' or @startstatus = 'DSP') and exists (select * from #LonghaulShiftItemLegs where start < @startdate)	-- No partially completed trips, actual start is just after the last completed trip before the unstarted activity.
	begin
	select top 1 @startlgh = lgh_number, @startstatus = status, @startdate = start, @startlghdate = dateadd(minute, 1, enddate) from #LonghaulShiftItemLegs where start < @startdate order by start desc
	end

if @startlgh is not null
	begin
	select @startdrv = lgh_driver1, @starttrc = lgh_tractor, @starttrl = lgh_primary_trailer, @startpup = lgh_primary_pup, @startcar = lgh_carrier,
	@updatedby = lgh_updatedby, @updatedon = lgh_updatedon, @startcmp = case when @startstatus = 'CMP' then cmp_id_end else cmp_id_start end
	from legheader where lgh_number = @startlgh
	end
else	-- No pre-existing trips at all for the equipment.
	begin
	select @startdrv = 'UNKNOWN', @starttrc = 'UNKNOWN', @starttrl = 'UNKNOWN', @startpup = 'UNKNOWN', @startcar = 'UNKNOWN', @enddate = getdate(),
	@updatedby = '', @updatedon = getdate(), @startcmp = 'UNKNOWN', @startstatus = 'CMP', @startdate = getdate(), @startlghdate = getdate()
	end
if @startdrv = 'UNKNOWN' select @startdrv = null
if @starttrc = 'UNKNOWN' select @starttrc = null
if @startcmp = 'UNKNOWN' select @startcmp = null
if @eqptype = 'DRV'
	SELECT @startdrv = @eqpid, @terminal = mpp_terminal, @fleet = mpp_fleet, @starttrc = isnull(@starttrc, mpp_tractornumber) from manpowerprofile where mpp_id = @eqpid
if @eqptype = 'TRC' 
	SELECT @starttrc = @eqpid, @terminal = trc_terminal, @fleet = trc_fleet, @startdrv = isnull(@startdrv, trc_driver) from tractorprofile where trc_number = @eqpid
if @eqptype = 'TRL' 
	SELECT @starttrl = @eqpid, @terminal = trl_terminal, @fleet = trl_fleet from trailerprofile where trl_id = @eqpid
if @eqptype = 'CAR' 
	SELECT @startcar = @eqpid
SELECT  @startdrv = ISNULL(@startdrv, 'UNKNOWN'), 
	@starttrc = ISNULL(@starttrc, 'UNKNOWN'), 
	@starttrl = ISNULL(@starttrl, 'UNKNOWN'), 
	@startpup = ISNULL(@startpup, 'UNKNOWN'), 
	@startcar = ISNULL(@startcar, 'UNKNOWN'), 
	@updatedby = ISNULL(@updatedby, 'sa'),
	@updatedon = ISNULL(@updatedon, getdate()),
	@terminal = ISNULL(@terminal, 'UNK'),
	@fleet = ISNULL(@fleet, 'UNK'),
	@enddate = isnull(@enddate, @startlghdate)
	
select @carriername = car_name from carrier where car_id = @startcar

select -1 as ss_id, @starttrc as trc_number, @startdrv as mpp_id, @starttrl as trl_id, 'UNK' as ss_shift, 
	'ON' as ss_shiftstatus, convert(datetime, LEFT(convert(varchar(30), @startlghdate, 101), 10), 101) AS ss_date, 
	@startlghdate as ss_starttime, @enddate as ss_endtime, 
	@terminal as ss_terminal, @fleet as ss_fleet, 'Longhaul ' + @eqptype as ss_comment,
	@updatedby as ss_lastupdateby, @updatedon as ss_lastupdatedate, 
	startdrv.mpp_lastfirst, @startlghdate as ss_logindate, CONVERT(datetime, '20491231') as ss_logoutdate, 
	isnull(@startcmp, startdrv.mpp_athome_terminal) mpp_athome_terminal, @startcar as car_id, 
	dateadd(minute, -1, @startlghdate) as prevend, null as nextstart, @startpup as trl_id_2, 'UNKNOWN' as ss_HomeTerminal, @carriername as CarrierName,
	@startlghdate earliestplandate, @enddate latestplandate, 0 as shiftPriority, NULL as ss_timestamp,
	startdrv.mpp_dailyhrsest, startdrv.mpp_weeklyhrsest, startdrv.mpp_estlog_datetime,
	'UNK' as ss_ReturnEMTMode,'N' as ss_ivr_status,0 as ss_hoursplannedatlogin,0 as ss_hoursutilized,
	'01/01/1950 00:00' as ss_tripsumrpt_last_rundate
	from manpowerprofile as startdrv
	where startdrv.mpp_id = @startdrv
GO
GRANT EXECUTE ON  [dbo].[GetLonghaulShiftItemByStatus] TO [public]
GO
