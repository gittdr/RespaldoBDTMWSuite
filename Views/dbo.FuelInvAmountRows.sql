SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[FuelInvAmountRows] as
select inv_id, cmp_id,  1 as forecast_bucket, inv_date, inv_type, inv_sequence, inv_value1 as value, 
 (select min(inv_value1) from fuelinvamounts as f2 
  where f2.cmp_id = fuelinvamounts.cmp_id and f2.inv_date= dateadd(d, -1, fuelinvamounts.inv_date) and fuelinvamounts.inv_type = f2.inv_type and fuelinvamounts.inv_sequence = f2.inv_sequence and
    inv_id in (select max(inv_id) from fuelinvamounts as f4 where f4.cmp_id = f2.cmp_id and f4.inv_date= f2.inv_date and f2.inv_type = f4.inv_type and f2.inv_sequence = f4.inv_sequence)) as PriorValue
from fuelinvamounts
where inv_sequence = 1 and inv_id in (select max(inv_id) from fuelinvamounts as f3 where f3.cmp_id = fuelinvamounts.cmp_id and f3.inv_date= fuelinvamounts.inv_date and fuelinvamounts.inv_type = f3.inv_type and fuelinvamounts.inv_sequence = f3.inv_sequence)
union select inv_id, cmp_id,  2 as forecast_bucket, inv_date, inv_type, inv_sequence, inv_value2 as value, 
 (select min(inv_value2) from fuelinvamounts as f2 
   where f2.cmp_id = fuelinvamounts.cmp_id and f2.inv_date= dateadd(d, -1, fuelinvamounts.inv_date) and fuelinvamounts.inv_type = f2.inv_type and fuelinvamounts.inv_sequence = f2.inv_sequence and
    inv_id in (select max(inv_id) from fuelinvamounts as f4 where f4.cmp_id = f2.cmp_id and f4.inv_date= f2.inv_date and f2.inv_type = f4.inv_type and f2.inv_sequence = f4.inv_sequence)) as PriorValue
from fuelinvamounts
where inv_sequence = 1 and inv_id in (select max(inv_id) from fuelinvamounts as f3 where f3.cmp_id = fuelinvamounts.cmp_id and f3.inv_date= fuelinvamounts.inv_date and fuelinvamounts.inv_type = f3.inv_type and fuelinvamounts.inv_sequence = f3.inv_sequence)
union select inv_id, cmp_id,  3 as forecast_bucket, inv_date, inv_type, inv_sequence, inv_value3 as value, 
 (select min(inv_value3) from fuelinvamounts as f2 
   where f2.cmp_id = fuelinvamounts.cmp_id and f2.inv_date= dateadd(d, -1, fuelinvamounts.inv_date) and fuelinvamounts.inv_type = f2.inv_type and fuelinvamounts.inv_sequence = f2.inv_sequence and
    inv_id in (select max(inv_id) from fuelinvamounts as f4 where f4.cmp_id = f2.cmp_id and f4.inv_date= f2.inv_date and f2.inv_type = f4.inv_type and f2.inv_sequence = f4.inv_sequence)) as PriorValue
from fuelinvamounts
where inv_sequence = 1 and inv_id in (select max(inv_id) from fuelinvamounts as f3 where f3.cmp_id = fuelinvamounts.cmp_id and f3.inv_date= fuelinvamounts.inv_date and fuelinvamounts.inv_type = f3.inv_type and fuelinvamounts.inv_sequence = f3.inv_sequence)
union select inv_id, cmp_id,  4 as forecast_bucket, inv_date, inv_type, inv_sequence, inv_value4 as value, 
 (select min(inv_value4) from fuelinvamounts as f2 
   where f2.cmp_id = fuelinvamounts.cmp_id and f2.inv_date= dateadd(d, -1, fuelinvamounts.inv_date) and fuelinvamounts.inv_type = f2.inv_type and fuelinvamounts.inv_sequence = f2.inv_sequence and
    inv_id in (select max(inv_id) from fuelinvamounts as f4 where f4.cmp_id = f2.cmp_id and f4.inv_date= f2.inv_date and f2.inv_type = f4.inv_type and f2.inv_sequence = f4.inv_sequence)) as PriorValue
from fuelinvamounts
where inv_sequence = 1 and inv_id in (select max(inv_id) from fuelinvamounts as f3 where f3.cmp_id = fuelinvamounts.cmp_id and f3.inv_date= fuelinvamounts.inv_date and fuelinvamounts.inv_type = f3.inv_type and fuelinvamounts.inv_sequence = f3.inv_sequence)
union select inv_id, cmp_id,  5 as forecast_bucket, inv_date, inv_type, inv_sequence, inv_value5 as value, 
 (select min(inv_value5) from fuelinvamounts as f2 
   where f2.cmp_id = fuelinvamounts.cmp_id and f2.inv_date= dateadd(d, -1, fuelinvamounts.inv_date) and fuelinvamounts.inv_type = f2.inv_type and fuelinvamounts.inv_sequence = f2.inv_sequence and
    inv_id in (select max(inv_id) from fuelinvamounts as f4 where f4.cmp_id = f2.cmp_id and f4.inv_date= f2.inv_date and f2.inv_type = f4.inv_type and f2.inv_sequence = f4.inv_sequence)) as PriorValue
from fuelinvamounts
where inv_sequence = 1 and inv_id in (select max(inv_id) from fuelinvamounts as f3 where f3.cmp_id = fuelinvamounts.cmp_id and f3.inv_date= fuelinvamounts.inv_date and fuelinvamounts.inv_type = f3.inv_type and fuelinvamounts.inv_sequence = f3.inv_sequence)
union select inv_id, cmp_id,  6 as forecast_bucket, inv_date, inv_type, inv_sequence, inv_value6 as value, 
 (select inv_value6 from fuelinvamounts as f2 
   where f2.cmp_id = fuelinvamounts.cmp_id and f2.inv_date= dateadd(d, -1, fuelinvamounts.inv_date) and fuelinvamounts.inv_type = f2.inv_type and fuelinvamounts.inv_sequence = f2.inv_sequence and
    inv_id in (select max(inv_id) from fuelinvamounts as f4 where f4.cmp_id = f2.cmp_id and f4.inv_date= f2.inv_date and f2.inv_type = f4.inv_type and f2.inv_sequence = f4.inv_sequence)) as PriorValue
from fuelinvamounts
where inv_sequence = 1 and inv_id in (select max(inv_id) from fuelinvamounts as f3 where f3.cmp_id = fuelinvamounts.cmp_id and f3.inv_date= fuelinvamounts.inv_date and fuelinvamounts.inv_type = f3.inv_type and fuelinvamounts.inv_sequence = f3.inv_sequence)
GO
GRANT SELECT ON  [dbo].[FuelInvAmountRows] TO [public]
GO
