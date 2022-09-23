SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.return_scheduledate    Script Date: 6/1/99 11:54:38 AM ******/
create procedure [dbo].[return_scheduledate]

as
declare
	@rowcounter int,
	@rows_affected int

create table #tmp1scroll
(view_id		integer,
process_ind	integer		null,
override_ind	char(1)		null,
fromdate		datetime	null,
todate			datetime	null,
weekendind	char(1)		null,
holidayind		char(1)		null,
schedule_date datetime	null)


insert into #tmp1scroll
select scv_id,
	scp_processind,
	scp_overrideind,
	scp_fromdate,
	scp_todate,
	scp_weekendind,
	scp_holidayind,
	null
from scheduleparms

update #tmp1scroll
set schedule_date = Convert(datetime,Convert(char,getdate(),101))
where process_ind = 1 and
	override_ind = 'N'

update #tmp1scroll
set schedule_date = dateadd(day,1,Convert(datetime,Convert(char,getdate(),101)))
where process_ind = 2 and
	override_ind = 'N'

update #tmp1scroll
set schedule_date = fromdate
where override_ind = 'Y' and
	Convert(datetime,Convert(char,getdate(),101)) between fromdate and todate

update #tmp1scroll
set schedule_date = dateadd(day,1,schedule_date)
where weekendind  = 'N' and
	Upper(datename(weekday,schedule_date)) in ('SATURDAY','SUNDAY')

select @rows_affected = @@rowcount

while @rows_affected > 0 
	BEGIN
	update #tmp1scroll
	set schedule_date = dateadd(day,1,schedule_date)
	where weekendind  = 'N' and
		Upper(datename(weekday,schedule_date)) in ('SATURDAY','SUNDAY')

	select @rows_affected = @@rowcount
	END

select  * from #tmp1scroll


GO
GRANT EXECUTE ON  [dbo].[return_scheduledate] TO [public]
GO
