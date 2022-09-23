SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[GetLonghaulShiftLegNumbers] @eqptype varchar(6), @eqpid varchar(13)
as
declare @firstplan datetime, @firstplanstatus varchar(6), @shiftstart datetime
create table #LonghaulLegs (lgh_number int, status varchar(6), start datetime)
insert into #LonghaulLegs (lgh_number, status, start)
select top 30 lgh_number, asgn_status, asgn_date from assetassignment where asgn_id = @eqpid and asgn_type = @eqptype order by asgn_date desc
select top 1 @firstplan = start, @firstplanstatus = status from #LonghaulLegs where status in ('STD', 'PLN', 'DSP') order by start
if @firstplanstatus is null
	select @shiftstart = max(start) from #LonghaulLegs
else if @firstplanstatus = 'STD' or @eqptype = 'CAR'
	select @shiftstart = @firstplan
else
	select @shiftstart = isnull(max(start), @firstplan) from #LonghaulLegs where start < @firstplan
select lgh_number from #LonghaulLegs where start >= @shiftstart order by start
GO
GRANT EXECUTE ON  [dbo].[GetLonghaulShiftLegNumbers] TO [public]
GO
