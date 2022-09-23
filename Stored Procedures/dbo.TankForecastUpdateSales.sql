SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[TankForecastUpdateSales]
as
declare @StartDate datetime
select @StartDate = dateadd(d, -1, convert(datetime,convert(varchar(8), getdate(),1),1))

create table #AverageTankUsage
(cmp_id varchar(8),
 forecast_bucket int,
 Usage int)

SET ANSI_WARNINGS off
insert #AverageTankUsage
select CurrentReading.cmp_id, CurrentReading.forecast_bucket,
 avg(case when PriorReading.inv_value > CurrentReading.inv_value then PriorReading.inv_value - CurrentReading.inv_value else null end) as Usage
from (select cmp_id, forecast_bucket, inv_date, min(value) as inv_value from FuelInvAmountRows
  where inv_type = 'READ' group by cmp_id, forecast_bucket, inv_date) as CurrentReading join 
  (select cmp_id, forecast_bucket, dateadd(d, 1, inv_date) as inv_date, min(value) as inv_value from FuelInvAmountRows
   where inv_type = 'READ' group by cmp_id, forecast_bucket, dateadd(d, 1, inv_date)) as PriorReading 
 on CurrentReading.cmp_id = PriorReading.cmp_id and CurrentReading.inv_date = PriorReading.inv_date and CurrentReading.forecast_bucket = PriorReading.forecast_bucket
where CurrentReading.inv_date between dateadd(d, -29, @startdate) and @startdate and
  PriorReading.inv_value > 0 and CurrentReading.inv_value > 0 
group by CurrentReading.cmp_id, CurrentReading.forecast_bucket
SET ANSI_WARNINGS on   


update company_tankdetail
set PercentOfForecast = case when TotalUsage.usage > 0 then convert(float, #AverageTankUsage.usage)/ TotalUsage.usage * 100 else 0 end
from  company_tankdetail join (select #AverageTankUsage.cmp_id, ForecastID, sum(usage) usage from company_tankdetail 
        join #AverageTankUsage on company_tankdetail.cmp_id = #AverageTankUsage.cmp_id and company_tankdetail.forecast_bucket = #AverageTankUsage.forecast_bucket 
        where ForecastID > 0 
        group by #AverageTankUsage.cmp_id, ForecastID) 
     as TotalUsage on company_tankdetail.cmp_id = TotalUsage.cmp_id and company_tankdetail.ForecastID  = TotalUsage.ForecastID
 join #AverageTankUsage on company_tankdetail.cmp_id = #AverageTankUsage.cmp_id and company_tankdetail.forecast_bucket = #AverageTankUsage.forecast_bucket 


create table #DailyDeliveries(
 ForecastID int,
 cmp_id varchar(8),
 inv_date datetime,
 delivery int,
 ordercount int)

create table #GetInventoryCommodityDeliverySummaryOutput
 (inv_date datetime,
 cmd_class2 varchar(8),
 cmd_code varchar(8),
 fgt_volume int)

declare @ForecastID int
select @ForecastID = 0

while exists (select * from tankforecast where ForecastID > @ForecastID)
begin
 select @ForecastID = min(ForecastID) from tankforecast where ForecastID > @ForecastID

 declare @cmp_id varchar(8),
  @ForecastType varchar(6),
  @CommodityString varchar(8),
  @WeeksInAverage int
 select @cmp_id = cmp_id,
  @ForecastType = ForecastType,
  @CommodityString = CommodityString,
  @WeeksInAverage = WeeksInAverage
 from tankforecast where ForecastID = @ForecastID

 delete from #GetInventoryCommodityDeliverySummaryoutput
 declare @enddate datetime
 select @enddate = dateadd(d, (-7 * @WeeksInAverage) + 1, @StartDate)

 insert #GetInventoryCommodityDeliverySummaryoutput
 exec GetInventoryCommodityDeliverySummary @cmp_id, @enddate,  @startdate

 insert #DailyDeliveries
  select @ForecastID, @cmp_id, inv_date, sum(fgt_volume), count(*)
  from #GetInventoryCommodityDeliverySummaryoutput
  where (@ForecastType = 'CMD' and cmd_code = @CommodityString) or
   (@ForecastType = 'CLASS' and cmd_class2 = @CommodityString)
  group by inv_date
end


create table #SalesData(
 cmp_id varchar(8),
 inv_date datetime,
 ForecastID int,
 reading int,
 priorreading int,
 priordelivery int)

insert #SalesData
select FuelInvAmountRows.cmp_id, FuelInvAmountRows.inv_date, tankforecast.ForecastID, sum(value), sum(priorvalue), 0
  from FuelInvAmountRows join company_tankdetail on FuelInvAmountRows.cmp_id = company_tankdetail.cmp_id and FuelInvAmountRows.forecast_bucket = company_tankdetail.forecast_bucket 
  join TankForecast on company_tankdetail.forecastid = TankForecast.forecastid
where inv_sequence =1 and inv_type = 'READ'  and value > 0
  and FuelInvAmountRows.inv_date between dateadd(d, (-7 * TankForecast.WeeksInAverage) + 1, @StartDate) and @StartDate
group by FuelInvAmountRows.inv_date, tankforecast.ForecastID, FuelInvAmountRows.cmp_id

update #SalesData
set priordelivery = delivery
from #SalesData join #DailyDeliveries on #SalesData.cmp_id = #DailyDeliveries.cmp_id and #SalesData.forecastid = #DailyDeliveries.forecastid and #SalesData.inv_date = dateadd(d, 1, #DailyDeliveries.inv_date)

create table #DayPercent(
 ForecastID int,
 cmp_id varchar(8),
 dayid int,
 daysales int,
 totalsales int,
 salespercent decimal(9,1))

insert #DayPercent
select #SalesData.ForecastID, #SalesData.cmp_id, datepart(dw, #SalesData.inv_date), 
 sum(case when priorreading + priordelivery - reading < 0 then 0 else priorreading + priordelivery - reading end), totalsales, 
 (case when totalsales = 0 then 0 else (sum(case when priorreading + priordelivery - reading < 0 then 0 else priorreading + priordelivery - reading end) * 1.0 / totalsales ) * 100 end) as DayPercent 
from #SalesData join (select cmp_id, forecastID, sum(case when priorreading + priordelivery - reading > 0 then priorreading + priordelivery - reading else 0 end) as totalsales
      from #SalesData
      group by cmp_id, forecastID) as TotalSales on #SalesData.cmp_id = TotalSales.cmp_id and #SalesData.forecastid = TotalSales.forecastid
group by #SalesData.ForecastID, #SalesData.cmp_id, datepart(dw, #SalesData.inv_date), totalsales


create table #Last7Sales(
 ForecastID int,
 cmp_id varchar(8),
 totalsales int,
 recordcount int)

insert #Last7Sales
select #SalesData.ForecastID, #SalesData.cmp_id, sum(case when priorreading + priordelivery - reading < 0 then 0 else priorreading + priordelivery - reading end), count(*) 
from #SalesData 
where #SalesData.inv_date between dateadd(d, -6, @StartDate) and @StartDate
group by #SalesData.ForecastID, #SalesData.cmp_id


update #DayPercent
set salespercent = 14.3
where totalsales = 0

update #DayPercent
set #DayPercent.salespercent = #DayPercent.salespercent +  adjust
from #DayPercent join (select cmp_id, forecastid, 100 - sum(salespercent) as adjust from #DayPercent group by cmp_id, forecastid) as TotalPercent
  on #DayPercent.cmp_id = TotalPercent.cmp_id and #DayPercent.forecastid = TotalPercent.forecastid 
where #DayPercent.dayid = 2  --update monday

update tankforecastday
set PercentOfSales = salespercent
from tankforecastday join #DayPercent on tankforecastday.ForecastId = #DayPercent.ForecastId and tankforecastday.DayNumber = #DayPercent.dayid - 1


update tankforecast
set AverageWeeklySales = (TotalSales.totalsales *1.0) / tankforecast.weeksinaverage,
 Last7DaySales = (#Last7Sales.totalsales *1.0) / tankforecast.weeksinaverage,
 autoadjustlastrundate = getdate()
from tankforecast join (select cmp_id, forecastID, sum(case when priorreading + priordelivery - reading >0 then priorreading + priordelivery - reading else 0 end) as totalsales
      from #SalesData
      group by cmp_id, forecastID) as TotalSales on tankforecast.ForecastId = TotalSales.ForecastId
  join #Last7Sales on tankforecast.ForecastId = #Last7Sales.ForecastId and autoadjustlastrundate <> '1/1/1900'

drop table #DailyDeliveries
drop table #GetInventoryCommodityDeliverySummaryOutput
drop table #AverageTankUsage
drop table #DayPercent
drop table #Last7Sales
GO
GRANT EXECUTE ON  [dbo].[TankForecastUpdateSales] TO [public]
GO
