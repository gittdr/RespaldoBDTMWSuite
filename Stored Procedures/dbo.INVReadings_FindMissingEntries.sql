SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



Create PROC [dbo].[INVReadings_FindMissingEntries]
(
	@Startdate datetime,
	@Enddate datetime)
	as
--- exec INVReadings_FindMissingEntries '08/01/2014','09/01/2014'
---grant exec on INVReadings_FindMissingEntries to public
--declare @startdate datetime
--declare @enddate datetime
declare @startrange datetime
declare @endrange datetime


--set @startdate = '07/23/2014'
--set @enddate = '08/05/2014'
set @startrange = @startdate
set @endrange = @enddate

declare @tempdates  table
(
TheDate datetime
)
while (@StartDate<=@EndDate)
begin
insert into @tempdates
values (@StartDate )
select @StartDate=DATEADD(d,1,@StartDate)
end

--select * from @tempdates
select distinct fivc.cmp_Id 
into #tempcompany
from  fuelinvamounts fivc with (nolock)
left outer join company c with (nolock) on c.cmp_id = fivc.cmp_id
where inv_sequence = 1
and cmp_InvSrvMode = 'FRCST'
and fivc.inv_date >= @startrange 
and fivc.inv_date <= @endrange
--order by #tempcompany.cmp_id
--select * from #tempcompany

select cmp_id,
TheDate
into #fullist
from @tempdates
join #tempcompany on 1 = 1

select * ,
(select top 1 inv_date from fuelinvamounts with (nolock) where cmp_id = #fullist.cmp_id and #fullist.TheDate = inv_date) as [readingdate]
from #fullist 
order by #fullist.cmp_id, thedate


drop table #tempcompany
drop table #fullist

GO
GRANT EXECUTE ON  [dbo].[INVReadings_FindMissingEntries] TO [public]
GO
