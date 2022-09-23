SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[InvServiceGetEstimatedReadingCalculation] @cmp_id varchar(8), @Debug char(1) = 'N'
as
set nocount on

declare @GetDateValue datetime
select @GetDateValue = GETDATE()

if (select count(*) from TankForecastSnapshot 
   where cmp_id = @cmp_id and UpdatedDate >= dateadd(mi, -15, @GetDateValue)) = 
   (select count(*) from tankforecastcompanysetupdetail where cmp_id = @cmp_id)
begin
 select * from TankForecastSnapshot where cmp_id = @cmp_id
 return
end
   
create table #ReadingDates(
 forecast_bucket int,
 LastReadingDate datetime null,
 PriorReadingDate datetime null)
 

Insert #ReadingDates
select  MaxDates.forecast_bucket, MaxDates.ReadingDate, max(FuelInvAmountNormalized.inv_readingdate) as PriorReadingDate
from (select  f1.forecast_bucket, max(f1.inv_readingdate) as ReadingDate from FuelInvAmountNormalized f1
    where f1.value > 0 and f1.inv_type = 'READ' and f1.cmp_id = @cmp_id and f1.source <>'E' and f1.inv_readingdate > dateadd(dd, -10, @GetDateValue) and f1.inv_readingdate < @GetDateValue
    group by forecast_bucket) as MaxDates, FuelInvAmountNormalized
where FuelInvAmountNormalized.value > 0 and FuelInvAmountNormalized.inv_type = 'READ' and 
 FuelInvAmountNormalized.cmp_id = @cmp_id and FuelInvAmountNormalized.forecast_bucket = MaxDates.forecast_bucket and 
  FuelInvAmountNormalized.inv_readingdate > dateadd(dd, -10, @GetDateValue) and FuelInvAmountNormalized.inv_readingdate <= dateadd(hh, -12, MaxDates.ReadingDate)
group by MaxDates.forecast_bucket, MaxDates.ReadingDate

declare @currentdate datetime 
select @currentdate = CONVERT(varchar(15), dateadd(DD, -1, MIN(LastReadingDate)), 101)
from #ReadingDates



if @Debug = 'Y'
begin 
 select * from #ReadingDates
 
 select * from TankForecast
 where cmp_id = @cmp_id 

 select * from company_tankdetail
 where cmp_id = @cmp_id 
end 

if (select count(*) from #ReadingDates) = 0
begin
 select * from TankForecastSnapshot where cmp_id = @cmp_id
 return
end

create table #TankKeyAllocation
(Bucket int, TankKey varchar(15), cmd_code varchar(8), PercentOfForecast decimal(10,2), ForecastId int)

insert #TankKeyAllocation
select forecast_bucket, TankKey, company_tankdetail.cmd_code, PercentOfForecast, 
 (select MIN(ForecastID) from TankForecast where cmp_id = @cmp_id and TankForecast.CommodityString = company_tankdetail.cmd_code)
 
from company_tankdetail join tankforecastcompanysetupdetail on company_tankdetail.cmp_id = tankforecastcompanysetupdetail.cmp_id
where company_tankdetail.cmp_id = @cmp_id 
 and charindex(',' + rtrim(convert(varchar(10), forecast_bucket)) + ',', ',' + SUBSTRING(TankKey, charindex( '(', TankKey, 1) + 1, charindex( ')', TankKey, 1) - charindex( '(', TankKey, 1) - 1) + ',') > 0

update #TankKeyAllocation
set PercentOfForecast = 100/SubTotal.Count
from #TankKeyAllocation join (select cmd_Code, SUM(isnull(PercentOfForecast,0)) as PercentTotal, count(*) as Count from #TankKeyAllocation
        group by cmd_Code
        having SUM(isnull(PercentOfForecast,0)) <> 100) as SubTotal on #TankKeyAllocation.cmd_Code = SubTotal.cmd_Code
create table #HourlySales
(ForecastID int, ForecastDate datetime not null,
 Sales int)
 
 --create table #CmdAllocation
 --(cmd_code varchar(8),
 
 
 create table #hr
 (ForecastID int, Sequence int,
 Hours decimal(10,2),
 Total decimal(10,2),
 PercentOfSales decimal(10,2),
 TotalHours decimal(10,2))

create table #hrchart
(ForecastID int, hour int,
 PercentOfSales decimal(10,2))
 
declare @Total decimal(10,2)
Select @Total = 0

insert #hr
select tankforecast.ForecastID, Sequence, Hours, (select sum(PercentOfSales) from TankForecastDaysegments as s2 
       where s2.ForecastID = TankForecastDaysegments.forecastid and s2.sequence <= TankForecastDaysegments.sequence), 
  PercentOfSales,
  (select sum(Hours) from TankForecastDaysegments as s2 
     where s2.ForecastID = TankForecastDaysegments.forecastid and s2.sequence <= TankForecastDaysegments.sequence)  - 1 
  from tankforecast join TankForecastDaysegments on TankForecast.ForecastID = TankForecastDaysegments.ForecastID where cmp_id = @cmp_id


declare @day int
declare @hr int

select @hr = 0
while @hr < 24
begin
 insert #hrchart
 select hr1.forecastid, @hr, hr1.PercentOfSales / hr1.Hours
 from #hr as hr1 where Sequence = (select MAX(sequence) from #hr as hr2 where hr2.forecastid = hr1.forecastid and 
    hr2.TotalHours <= (select min(hr3.totalhours) from #hr as hr3 where hr3.forecastid = hr2.forecastid and hr3.totalhours >= @hr) )
 
 select @hr = @hr + 1
end

if @Debug = 'Y'
begin
 select * from #hr 
 select * from #hrchart
end


 select @day = 0
 while @day < 15
 begin
 select @hr = 0
 while @hr < 24
 begin
  declare @sales int
  insert #HourlySales (ForecastID, ForecastDate , Sales )
  select TankForecast.forecastid, DATEADD(hh, @hr, DATEADD(dd, @day, @currentdate)), 
    TankForecast.AverageWeeklySales * TankForecastDay.PercentOfSales/100 * #hrchart.PercentOfSales/100
  from TankForecast join TankForecastDay on TankForecast.ForecastID = TankForecastDay.ForecastID
    join #hrchart on #hrchart.ForecastID = TankForecast.ForecastID and hour = DATEPART(HH, DATEADD(hh, @hr, DATEADD(dd, @day, @currentdate)))
  where TankForecast.cmp_id = @cmp_id and TankForecastDay.DayNumber = DATEPART(DW, DATEADD(dd, @day, @currentdate)) - 1
    
  select @hr = @hr + 1
 end
 select @day = @day + 1 
 end
 
if @Debug = 'Y'
begin 
 select * from #TankKeyAllocation

 select *  from #HourlySales
 select Bucket, round(Sales * PercentOfForecast/100.0,0) TankSales, TankKey
 from #TankKeyAllocation join #HourlySales on #TankKeyAllocation.ForecastId = #HourlySales.ForecastID
end

create table #Deliveries
(ord_hdrnumber int,
ord_number varchar(12),
cmd_code varchar(8),
ArrivalDate datetime,
Status varchar(6),
Volume int,
Bucket1 int, Bucket2 int,Bucket3 int,Bucket4 int,Bucket5 int,Bucket6 int,Bucket7 int,Bucket8 int,Bucket9 int,Bucket10 int)


insert #Deliveries 
 select stops.ord_hdrnumber, ord_number,  
 coalesce( 
 (select min(company_tankdetail.cmd_code) from company_tankdetail where company_tankdetail.cmp_id = stops.cmp_id and company_tankdetail.ActiveCommodityCode  = freightdetail.cmd_code ),
 (select min(company_tankdetail.cmd_code) from company_tankdetail where company_tankdetail.cmp_id = stops.cmp_id and charindex(rtrim(',' + freightdetail.cmd_code) + ',', + ',' + Rtrim(ltrim(ValidCommodityList))  + ',') > 0),
 (select min(commodity_equivalent.cmd_code) from tankforecast join commodity_equivalent on Commodity_eqid = commodity_equivalent.Eqid
  join commodity_equivalentdetails on commodity_equivalent.Eqid = commodity_equivalentdetails.eqid
  where tankforecast.cmp_id = stops.cmp_id and commodity_equivalentdetails.cmd_code = freightdetail.cmd_code),
  freightdetail.cmd_code) as cmd_code, 
 stops.stp_arrivaldate, ord_status, fgt_volume,  fgt_deliverytank1, fgt_deliverytank2,fgt_deliverytank3,fgt_deliverytank4,fgt_deliverytank5,fgt_deliverytank6,fgt_deliverytank7,fgt_deliverytank8,fgt_deliverytank9,fgt_deliverytank10
from stops join freightdetail on stops.stp_number = freightdetail.stp_number
   join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
   join commodity on freightdetail.cmd_code = commodity.cmd_code
   left outer join tankforecast on tankforecast.cmp_id = stops.cmp_id and commoditystring = freightdetail.cmd_code
where stops.cmp_id = @cmp_id and stops.stp_type = 'DRP' and stops.stp_arrivaldate between @currentdate and dateadd(dd, 12, @currentdate) and stops.ord_hdrnumber > 0
  and ord_status in ('AVL','DSP','PLN','STD','CMP') and freightdetail.cmd_code <> 'UNKNOWN'


create table #DeliveriesNormalized
(ord_hdrnumber int,
ord_number varchar(12),
cmd_code varchar(8),
ArrivalDate datetime,
Status varchar(6),
forecast_bucket int, 
Volume int)

insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, cmd_code, ArrivalDate, Status, 1, isnull(Bucket1,0)
 from #Deliveries where isnull(Bucket1,0) > 0 and Volume = isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)
 
 insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, cmd_code, ArrivalDate, Status, 2, isnull(Bucket2,0)
 from #Deliveries where isnull(Bucket2,0) > 0 and Volume = isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)
 
 insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, cmd_code, ArrivalDate, Status, 3, isnull(Bucket3,0)
 from #Deliveries where isnull(Bucket3,0) > 0 and Volume = isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)
 
 insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, cmd_code, ArrivalDate, Status, 4, isnull(Bucket4,0)
 from #Deliveries  where isnull(Bucket4,0) > 0 and Volume = isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)
 
 insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, cmd_code, ArrivalDate, Status, 5, isnull(Bucket5,0)
 from #Deliveries  where isnull(Bucket5,0) > 0 and Volume = isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)
 
 insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, cmd_code, ArrivalDate, Status, 6, isnull(Bucket6,0)
 from #Deliveries  where isnull(Bucket6,0) > 0 and Volume = isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)
 
 insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, cmd_code, ArrivalDate, Status, 7, isnull(Bucket7,0)
 from #Deliveries  where isnull(Bucket7,0) > 0 and Volume = isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)
 
 insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, cmd_code, ArrivalDate, Status, 8, isnull(Bucket8,0)
 from #Deliveries  where isnull(Bucket8,0) > 0 and Volume = isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)
 
 insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, cmd_code, ArrivalDate, Status, 9, isnull(Bucket9,0)
 from #Deliveries  where isnull(Bucket9,0) > 0 and Volume = isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)
 
 insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, cmd_code, ArrivalDate, Status, 10, isnull(Bucket10,0)
 from #Deliveries  where isnull(Bucket10,0) > 0 and Volume = isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)
 
 
 insert #DeliveriesNormalized
 select ord_hdrnumber, ord_number, #Deliveries.cmd_code, ArrivalDate, Status, #TankKeyAllocation.Bucket, 
 round(Volume * #TankKeyAllocation.PercentOfForecast/100,0)
 from #Deliveries join #TankKeyAllocation on #Deliveries.cmd_code = #TankKeyAllocation.cmd_code
 where Volume <> isnull(Bucket1,0) + isnull(Bucket2,0) + isnull(Bucket3,0) + isnull(Bucket4,0) + isnull(Bucket5,0) + isnull(Bucket6,0) + isnull(Bucket7,0) + isnull(Bucket8,0) + isnull(Bucket9,0) + isnull(Bucket10,0)

if @Debug ='Y' 
begin
 select * from #Deliveries

 select * from #DeliveriesNormalized
 order by ArrivalDate
 
 select * from #ReadingDates
end 

Create table #readings
(cmp_id varchar(8),
forecast_bucket int, 
cmd_code varchar(8),
SafeFill int,
[ShutDown] int,
PriorReadingDate datetime,
PriorReading int,
LastReadingDate datetime,
LastReading int,
LastReadingEstSales int,
LastReadingDeliveries int,
NowReadingDate datetime,
NowReading int,
NowReadingEstSales int,
NowDeliveries int,
NowDeliveriesExcluded int,
Reading12HoursDate datetime,
Reading12Hours int,
Reading12HoursEstSales int,
Deliveries12Hours int,
Deliveries12HoursExcluded int,
Questionable char(1) null,
Status varchar(100) null,
RunOutDate datetime null)



insert #readings
select f1.cmp_id, f1.forecast_bucket, 
 cmd_code, ullage, ShutDownGallons,
 f2.inv_readingdate as PriorReadingDate, f2.value as PriorReading,
 f1.inv_readingdate as LastReadingDate, f1.value as LastReading, 
 (select sum(round(Sales * PercentOfForecast/100.0,0)) from #TankKeyAllocation join #HourlySales on #TankKeyAllocation.ForecastId = #HourlySales.ForecastID
  where ForecastDate between f2.inv_readingdate and f1.inv_readingdate and Bucket = f2.forecast_bucket) as EstSales,
 isnull((select SUM(Volume) from #DeliveriesNormalized where ArrivalDate >= f2.inv_readingdate and 
   ArrivalDate < f1.inv_readingdate and #DeliveriesNormalized.forecast_bucket = f2.forecast_bucket),0)  as Deliveries, 
 @GetDateValue, 0, 
 --Sales now
 (select sum(round(Sales * PercentOfForecast/100.0,0)) from #TankKeyAllocation join #HourlySales on #TankKeyAllocation.ForecastId = #HourlySales.ForecastID
  where ForecastDate between f1.inv_readingdate and @GetDateValue and Bucket = f1.forecast_bucket) as NowEstSales,
 --NowDeliveries
 isnull((select SUM(Volume) from #DeliveriesNormalized where ArrivalDate >= f1.inv_readingdate and 
   ArrivalDate < @GetDateValue and #DeliveriesNormalized.forecast_bucket = f2.forecast_bucket
   and Status = 'CMP'),0)  as NowDeliveries, 
 --NowDeliveriesExcluded - Non-complete loads before now
 isnull((select SUM(Volume) from #DeliveriesNormalized where ArrivalDate >= f1.inv_readingdate and 
   ArrivalDate < @GetDateValue and #DeliveriesNormalized.forecast_bucket = f2.forecast_bucket
   and Status <> 'CMP'),0)  as NowDeliveries, 
 --12 Hour section
 dateadd(hh, 12, @GetDateValue), 0, 
 --sales in 12 hrs
 (select sum(round(Sales * PercentOfForecast/100.0,0)) from #TankKeyAllocation join #HourlySales on #TankKeyAllocation.ForecastId = #HourlySales.ForecastID
  where ForecastDate between @GetDateValue and dateadd(hh, 12, @GetDateValue) and Bucket = f1.forecast_bucket) as Now12EstSales,
 --Deliveries12Hours <> AVL Loads
 isnull((select SUM(Volume) from #DeliveriesNormalized where ArrivalDate >= @GetDateValue and 
   ArrivalDate < dateadd(hh, 12, @GetDateValue) and #DeliveriesNormalized.forecast_bucket = f2.forecast_bucket
   and Status <> 'AVL'),0)  as Deliveries12Hours, 
 --Deliveries12HoursExcluded - AVL Loads
 isnull((select SUM(Volume) from #DeliveriesNormalized where ArrivalDate >= @GetDateValue and 
   ArrivalDate < dateadd(hh, 12, @GetDateValue) and #DeliveriesNormalized.forecast_bucket = f2.forecast_bucket
   and Status = 'AVL'),0)  as Deliveries12HoursExcluded,
   null,null,null
 from #ReadingDates join FuelInvAmountNormalized as f1 on #ReadingDates.forecast_bucket = f1.forecast_bucket
  join FuelInvAmountNormalized as f2 on #ReadingDates.forecast_bucket = f2.forecast_bucket
  join company_tankdetail on company_tankdetail.cmp_id = @cmp_id and f1.forecast_bucket = company_tankdetail.forecast_bucket
where f1.value > 0 and f1.inv_type = 'READ' and f1.cmp_id = @cmp_id and f1.source <>'E' and f1.inv_readingdate = LastReadingDate and
 f2.value > 0 and f2.inv_type = 'READ' and f2.cmp_id = @cmp_id and f2.source <>'E' and f2.inv_readingdate = priorReadingDate
   
update #readings
set NowReading = LastReading - NowReadingEstSales + NowDeliveries

update #readings
set
 Reading12Hours = NowReading - Reading12HoursEstSales + Deliveries12Hours
 
update #readings
set
 RunOutDate = @GetDateValue
where NowReading <= [ShutDown]

declare @MaxLoopCount int, @count int, @TestDate datetime
select @count = 0, @MaxLoopCount = 168 --never loop more than one week


Create table #NewTanks(forecast_bucket int)

while @count < @MaxLoopCount and exists(select * from #readings where RunOutDate is null)
begin
 select @count = @count + 1
 select @TestDate = dateadd(hh, @count, @GetDateValue)  
 
 delete #NewTanks
 insert #NewTanks
 select forecast_bucket from #readings where 
   RunOutDate is null 
   and NowReading -
   isnull((select sum(round(Sales * PercentOfForecast/100.0,0)) from #TankKeyAllocation join #HourlySales on #TankKeyAllocation.ForecastId = #HourlySales.ForecastID
    where ForecastDate between @GetDateValue and @TestDate and Bucket = #readings.forecast_bucket),0) +
   isnull((select SUM(Volume) from #DeliveriesNormalized where ArrivalDate >= @GetDateValue and 
      ArrivalDate < @TestDate and #DeliveriesNormalized.forecast_bucket = #readings.forecast_bucket
      and Status <> 'AVL'),0) < [ShutDown]

 update #readings
 set
  RunOutDate = @TestDate 
 where exists (select * from #NewTanks where #readings.forecast_bucket = #NewTanks.forecast_bucket)
end

--default everything else to 12/31/2049
update #readings
set
 RunOutDate = '12/31/2049'
where RunOutDate is null

update #readings
set Questionable = 'Y'
where not (PriorReading + LastReadingDeliveries - LastReading between (LastReadingEstSales - LastReadingEstSales/2) and (LastReadingEstSales + LastReadingEstSales/2)) and
  abs((PriorReading + LastReadingDeliveries - LastReading) - LastReadingEstSales) > 250
  
update #readings
set Questionable = 'N'
where Questionable is null


update #readings
set Status = 'Complete order > NOW'
where Status is null and 
 isnull((select SUM(Volume) from #DeliveriesNormalized where ArrivalDate >= NowReadingDate and 
   ArrivalDate < Reading12HoursDate and #DeliveriesNormalized.forecast_bucket = #readings.forecast_bucket
   and Status = 'CMP'),0) > 0
 
update #readings
set Status = 'AVL order between NOW and NOW + 12'
where Status is null and Deliveries12HoursExcluded > 0

update #readings
set Status = 'Open order < NOW'
where Status is null and NowDeliveriesExcluded > 0

update #readings
set Status = 'OK'
where Status is null 

delete TankForecastSnapshot 
where TankForecastSnapshot.cmp_id = @cmp_id and 
  not exists(select * from company_tankdetail where company_tankdetail.cmp_id = TankForecastSnapshot.cmp_id and 
      company_tankdetail.forecast_bucket = TankForecastSnapshot.forecast_bucket)
      

insert TankForecastSnapshot (cmp_id,forecast_bucket,UpdatedDate,UpdatedBy)
select cmp_id, forecast_bucket, getdate(), suser_sname()
from #readings 
where not exists(select * from TankForecastSnapshot where 
   TankForecastSnapshot.cmp_id = #readings.cmp_id and TankForecastSnapshot.forecast_bucket = #readings.forecast_bucket)
   
update TankForecastSnapshot
set
 UpdatedDate = getdate(),
 UpdatedBy = suser_sname(),
 cmd_code  = #readings.cmd_code,
 SafeFill  = #readings.SafeFill,
 [ShutDown]  = #readings.[ShutDown],
 PriorReadingDate  = #readings.PriorReadingDate,
 PriorReading  = #readings.PriorReading,
 LastReadingDate  = #readings.LastReadingDate,
 LastReading  = #readings.LastReading,
 LastReadingEstSales  = #readings.LastReadingEstSales,
 LastReadingDeliveries  = #readings.LastReadingDeliveries,
 NowReadingDate  = #readings.NowReadingDate,
 NowReading  = #readings.NowReading,
 NowReadingEstSales  = #readings.NowReadingEstSales,
 NowDeliveries  = #readings.NowDeliveries,
 NowDeliveriesExcluded  = #readings.NowDeliveriesExcluded,
 Reading12HoursDate  = #readings.Reading12HoursDate,
 Reading12Hours  = #readings.Reading12Hours,
 Reading12HoursEstSales  = #readings.Reading12HoursEstSales,
 Deliveries12Hours  = #readings.Deliveries12Hours,
 Deliveries12HoursExcluded  = #readings.Deliveries12HoursExcluded,
 Questionable  = #readings.Questionable,
 Status = #readings.Status ,
 RunOutDate  = #readings.RunOutDate
from TankForecastSnapshot join #readings on 
  TankForecastSnapshot.cmp_id = #readings.cmp_id and TankForecastSnapshot.forecast_bucket = #readings.forecast_bucket

select * from TankForecastSnapshot where cmp_id = @cmp_id

drop table #Deliveries 
drop table #DeliveriesNormalized
drop table #HourlySales
drop table #hr 
drop table #hrchart
drop table #TankKeyAllocation
drop table #ReadingDates
drop table #readings
drop table #NewTanks
GO
GRANT EXECUTE ON  [dbo].[InvServiceGetEstimatedReadingCalculation] TO [public]
GO
