SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[GetCarrierLonghaulShiftItemByDate] @eqpid varchar(13), @plandate datetime
as
declare @startlgh int, @logindate datetime, @startdrv varchar(8), @starttrc varchar(8), @starttrl varchar(13), @startpup varchar(13)
declare @startcar varchar(8), @terminal varchar(6), @updatedby varchar(128), @updatedon datetime, @startstatus varchar(6)
declare @fleet varchar(6), @startcmp varchar(8), @logoutdate datetime, @endstatus varchar(6), @keystop int, @endlgh int
declare @startdate datetime, @enddate datetime, @carriername as varchar(64)
select top 1 @startlgh = assetassignment.lgh_number, @startstatus = asgn_status, @startdate = asgn_date, @logindate = asgn_date from assetassignment 
 inner join legheader on assetassignment.lgh_number = legheader.lgh_number
 where asgn_id = @eqpid and asgn_type = 'CAR' and legheader.lgh_plandate = @plandate
 and asgn_enddate > dateadd(d, -7, @plandate) and asgn_date < dateadd(d, 7, @plandate)
 order by asgn_date

if @startlgh is not null -- Some activity during period.  Use it to define "shift."
 begin
 if @startstatus in ('PLN', 'DSP', 'AVL') select @logindate = convert(datetime, '19500101')
 select top 1 @endstatus = asgn_status, @logoutdate = asgn_enddate, @enddate = asgn_enddate from assetassignment 
  inner join legheader on assetassignment.lgh_number = legheader.lgh_number
  where asgn_id = @eqpid and asgn_type = 'CAR' and legheader.lgh_plandate = @plandate
  and asgn_enddate > dateadd(d, -7, @plandate) and asgn_date < dateadd(d, 7, @plandate)
  order by asgn_enddate desc
 if @endstatus <> 'CMP' select @logoutdate = convert(datetime, '20491231')

 select @startdrv = lgh_driver1, @starttrc = lgh_tractor, @starttrl = lgh_primary_trailer, @startpup = lgh_primary_pup, 
  @startcar = lgh_carrier, @updatedby = lgh_updatedby, @updatedon = lgh_updatedon, @startcmp = cmp_id_start 
  from legheader where lgh_number = @startlgh
 end
else -- No activity during the specified period, get info from surrounding trips.
 begin
 select @startdate = @plandate, @enddate = @plandate
 select top 1 @startlgh = assetassignment.lgh_number from assetassignment 
  inner join legheader on assetassignment.lgh_number = legheader.lgh_number
  where asgn_id = @eqpid and asgn_type = 'CAR' and lgh_plandate < @plandate 
  and asgn_enddate > dateadd(d, -7, @plandate) and asgn_date < dateadd(d, 7, @plandate)
  order by asgn_enddate desc
 select top 1 @endlgh = assetassignment.lgh_number, @endstatus = asgn_status from assetassignment 
  inner join legheader on assetassignment.lgh_number = legheader.lgh_number
  where asgn_id = @eqpid and asgn_type = 'CAR' and lgh_plandate > @plandate 
  and asgn_enddate > dateadd(d, -7, @plandate) and asgn_date < dateadd(d, 7, @plandate)
  order by asgn_date

 if @endstatus in ('STD', 'CMP') 
  select @logindate = @plandate, @logoutdate = @plandate
 else
  select @logindate = convert(datetime, '19500101'), @logoutdate = convert(datetime, '20491231')

 if @startlgh is not null
  select @startdrv = lgh_driver1, @starttrc = lgh_tractor, @starttrl = lgh_primary_trailer, @startpup = lgh_primary_pup, 
   @startcar = lgh_carrier, @updatedby = lgh_updatedby, @updatedon = lgh_updatedon, @startcmp = cmp_id_end
   from legheader where lgh_number = @startlgh
 else if @endlgh is not null
  select @startdrv = lgh_driver1, @starttrc = lgh_tractor, @starttrl = lgh_primary_trailer, @startpup = lgh_primary_pup, 
   @startcar = lgh_carrier, @updatedby = lgh_updatedby, @updatedon = lgh_updatedon, @startcmp = cmp_id_start
   from legheader where lgh_number = @endlgh
 else
  select @startdrv = 'UNKNOWN', @starttrc = 'UNKNOWN', @starttrl = 'UNKNOWN', @startpup = 'UNKNOWN', @startcar = 'UNKNOWN', 
   @updatedby = '', @updatedon = getdate(), @startcmp = 'UNKNOWN'
 end

if @startdrv = 'UNKNOWN' select @startdrv = null
if @starttrc = 'UNKNOWN' select @starttrc = null
if @startcmp = 'UNKNOWN' select @startcmp = null
SELECT @startcar = @eqpid
SELECT  @startdrv = ISNULL(@startdrv, 'UNKNOWN'), 
 @starttrc = ISNULL(@starttrc, 'UNKNOWN'), 
 @starttrl = ISNULL(@starttrl, 'UNKNOWN'), 
 @startpup = ISNULL(@startpup, 'UNKNOWN'), 
 @startcar = ISNULL(@startcar, 'UNKNOWN'), 
 @updatedby = ISNULL(@updatedby, 'sa'),
 @updatedon = ISNULL(@updatedon, getdate()),
 @terminal = ISNULL(@terminal, 'UNK'),
 @fleet = ISNULL(@fleet, 'UNK')
 
select @carriername = car_name from carrier where car_id = @startcar

select -1 as ss_id, @starttrc as trc_number, @startdrv as mpp_id, @starttrl as trl_id, 'UNK' as ss_shift, 
 'ON' as ss_shiftstatus, convert(datetime, LEFT(convert(varchar(30), @startdate, 101), 10), 101) AS ss_date, 
 @startdate as ss_starttime, @enddate as ss_endtime, 
 @terminal as ss_terminal, @fleet as ss_fleet, 'Longhaul CAR' as ss_comment,
 @updatedby as ss_lastupdateby, @updatedon as ss_lastupdatedate, 
 startdrv.mpp_lastfirst, @logindate as ss_logindate, @logoutdate as ss_logoutdate, 
 isnull(@startcmp, startdrv.mpp_athome_terminal) mpp_athome_terminal, @startcar as car_id, 
 dateadd(minute, -1, @startdate) as prevend, dateadd(minute, 1, @enddate) as nextstart, @startpup as trl_id_2, 'UNKNOWN' as ss_HomeTerminal, @carriername as CarrierName,
 @startdate earliestplandate, @enddate latestplandate, 0 as shiftPriority, NULL as ss_timestamp,
 startdrv.mpp_dailyhrsest, startdrv.mpp_weeklyhrsest, startdrv.mpp_estlog_datetime
 from manpowerprofile as startdrv
 where startdrv.mpp_id = @startdrv
GO
GRANT EXECUTE ON  [dbo].[GetCarrierLonghaulShiftItemByDate] TO [public]
GO
