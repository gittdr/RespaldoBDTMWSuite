SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[FuelInvSales] as
select CurrentReading.cmp_id, CurrentReading.inv_date, 
 PriorReading.inv_value1 + isnull(PriorDelivery.inv_value1,0) - CurrentReading.inv_value1 as Sales1,
 PriorDelivery.inv_value1 'del1', PriorReading.inv_value1 'prior', CurrentReading.inv_value1 'cur',
 PriorReading.inv_value2 + isnull(PriorDelivery.inv_value2,0) - CurrentReading.inv_value2 as Sales2,
 PriorReading.inv_value3 + isnull(PriorDelivery.inv_value3,0) - CurrentReading.inv_value3 as Sales3,
 PriorReading.inv_value4 + isnull(PriorDelivery.inv_value4,0) - CurrentReading.inv_value4 as Sales4,
 PriorReading.inv_value5 + isnull(PriorDelivery.inv_value5,0) - CurrentReading.inv_value5 as Sales5,
 PriorReading.inv_value6 + isnull(PriorDelivery.inv_value6,0) - CurrentReading.inv_value6 as Sales6
from 
 (select cmp_id, inv_date, min(inv_value1) as inv_value1, min(inv_value2) as inv_value2, min(inv_value3) as inv_value3, min(inv_value4) as inv_value4, min(inv_value5) as inv_value5, min(inv_value6) as inv_value6 from FuelInvAmounts
  where inv_type = 'READ' group by cmp_id, inv_date) as CurrentReading join 
  (select cmp_id, dateadd(d, 1, inv_date) as inv_date, min(inv_value1) as inv_value1, min(inv_value2) as inv_value2, min(inv_value3) as inv_value3, min(inv_value4) as inv_value4, min(inv_value5) as inv_value5, min(inv_value6) as inv_value6 from FuelInvAmounts
   where inv_type = 'READ' group by cmp_id, dateadd(d, 1, inv_date)) as PriorReading 
 on CurrentReading.cmp_id = PriorReading.cmp_id and CurrentReading.inv_date = PriorReading.inv_date 
   left outer join (select cmp_id, dateadd(d, 1, inv_date) as inv_date, sum(inv_value1) as inv_value1, sum(inv_value2) as inv_value2, sum(inv_value3) as inv_value3, sum(inv_value4) as inv_value4, sum(inv_value5) as inv_value5, sum(inv_value6) as inv_value6 from FuelInvAmounts
  where inv_type = 'SHIP' group by cmp_id, dateadd(d, 1, inv_date)) as PriorDelivery
 on CurrentReading.cmp_id = PriorDelivery.cmp_id and CurrentReading.inv_date = PriorDelivery.inv_date
GO
GRANT SELECT ON  [dbo].[FuelInvSales] TO [public]
GO
