SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[InvServiceGetCompanyReadingAlert] @cmp_id varchar(8)
AS

create table #MinutesBetweenReadings (
 cmp_id varchar(8),
 minutesBetween integer
)

declare @daysToLookBack datetime 
set @daysToLookBack = DATEADD(d, -7, getdate())

insert into #MinutesBetweenReadings
select @cmp_id, 
ISNULL(DATEDIFF(MINUTE, f1.inv_readingdate, ( select top 1 f2.inv_readingdate 
            from FuelInvAmountNormalized f2 
            where f2.cmp_id = @cmp_id and               
              f1.inv_date >= @daysToLookBack and 
              f2.inv_readingdate > f1.inv_readingdate and 
              f1.forecast_bucket = f2.forecast_bucket 
              order by f2.inv_readingdate asc)), 0) as MinutesBetweenReadings 
from FuelInvAmountNormalized f1
where f1.inv_date >= @daysToLookBack
and f1.cmp_id = @cmp_id and f1.value > 0 and f1.inv_type = 'READ' and f1.inv_readingDate is not null and f1.inv_readingdate > @daysToLookBack
and ISNULL(DATEDIFF(MINUTE, f1.inv_readingdate, ( select top 1 f2.inv_readingdate 
            from FuelInvAmountNormalized f2 
            where f2.cmp_id = @cmp_id and 
              f1.inv_date >= @daysToLookBack and 
              f2.inv_readingdate > f1.inv_readingdate and 
              f1.forecast_bucket = f2.forecast_bucket 
              order by f2.inv_readingdate asc)), 0) > 0

declare @avg int
declare @stddev decimal (18,4)
declare @lastReadingDate datetime
declare @minutesFromLastReading int 

select @avg = ISNULL(AVG(minutesBetween), 0), @stddev = ISNULL(STDEV(minutesBetween),0) from #MinutesBetweenReadings

select @lastReadingDate = MAX(inv_readingdate) 
       from  FuelInvAmountNormalized f1 
       where f1.cmp_id = @cmp_id and 
         f1.value > 0 and 
         f1.inv_type = 'READ' and 
         f1.inv_readingDate is not null
         
select @minutesFromLastReading = DateDiff(MINUTE, @lastReadingDate, getDate())

--select CAST(@avg as decimal)/60 as AverageHoursBetweenReadings
--select CAST(@minutesFromLastReading as decimal)/60 as HoursFromLastReading
--select ((CAST(@minutesFromLastReading as decimal)/60) - (CAST(@avg as decimal)/60)) as HoursLate

if @minutesFromLastReading > @avg + 60
begin
 select inv_id, 
   cmp_id as CompanyID, 
   forecast_bucket as ForecastBucket, 
   inv_date as InventoryDate, 
   inv_readingdate as LastReadingDate, 
   inv_sequence as Sequence, 
   value as LastReading, 
   [source] as Source,  
   CAST(@minutesFromLastReading as decimal)/60 as HoursFromLastReading, 
   CAST(@avg as decimal)/60 as AverageHoursBetweenReadings,
   ((CAST(@minutesFromLastReading as decimal)/60) - (CAST(@avg as decimal)/60)) as HoursLate
 from FuelInvAmountNormalized 
 where cmp_id = @cmp_id and 
   inv_readingdate = @lastReadingDate and
   value > 0 and 
   inv_type = 'READ' and 
   inv_readingDate is not null
end

drop table #MinutesBetweenReadings
GO
GRANT EXECUTE ON  [dbo].[InvServiceGetCompanyReadingAlert] TO [public]
GO
