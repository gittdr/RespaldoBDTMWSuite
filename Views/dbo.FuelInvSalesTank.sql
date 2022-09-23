SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[FuelInvSalesTank] as
select cmp_id,  1 as forecast_bucket, inv_date, sales1 as sales
from FuelInvSales
union select cmp_id, 2 as forecast_bucket, inv_date, sales2 as sales
from FuelInvSales
union select cmp_id, 3 as forecast_bucket, inv_date, sales3 as sales
from FuelInvSales
union select cmp_id, 4 as forecast_bucket, inv_date, sales4 as sales
from FuelInvSales
union select cmp_id, 5 as forecast_bucket, inv_date, sales5 as sales
from FuelInvSales
union select cmp_id, 6 as forecast_bucket, inv_date, sales6 as sales
from FuelInvSales
GO
GRANT SELECT ON  [dbo].[FuelInvSalesTank] TO [public]
GO
