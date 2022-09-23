SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[FuelInvAmountNormalized] 
as
select inv_id, cmp_id,  1 as forecast_bucket, inv_date, inv_readingdate, inv_type, inv_sequence, inv_value1 as value, inv_source1 as source
from fuelinvamounts
union select inv_id, cmp_id,  2 as forecast_bucket, inv_date, inv_readingdate,inv_type, inv_sequence, inv_value2 as value, inv_source2 as source
from fuelinvamounts
union select inv_id, cmp_id,  3 as forecast_bucket, inv_date, inv_readingdate, inv_type, inv_sequence, inv_value3 as value, inv_source3 as source
from fuelinvamounts
union select inv_id, cmp_id,  4 as forecast_bucket, inv_date, inv_readingdate, inv_type, inv_sequence, inv_value4 as value, inv_source4 as source
from fuelinvamounts
union select inv_id, cmp_id,  5 as forecast_bucket, inv_date, inv_readingdate, inv_type, inv_sequence, inv_value5 as value, inv_source5 as source
from fuelinvamounts
union select inv_id, cmp_id,  6 as forecast_bucket, inv_date, inv_readingdate, inv_type, inv_sequence, inv_value6 as value, inv_source6 as source
from fuelinvamounts
union select inv_id, cmp_id,  7 as forecast_bucket, inv_date, inv_readingdate, inv_type, inv_sequence, inv_value7 as value, inv_source7 as source
from fuelinvamounts
union select inv_id, cmp_id,  8 as forecast_bucket, inv_date, inv_readingdate, inv_type, inv_sequence, inv_value8 as value, inv_source8 as source
from fuelinvamounts
union select inv_id, cmp_id,  9 as forecast_bucket, inv_date, inv_readingdate, inv_type, inv_sequence, inv_value9 as value, inv_source9 as source
from fuelinvamounts
union select inv_id, cmp_id,  10 as forecast_bucket, inv_date, inv_readingdate, inv_type, inv_sequence, inv_value10 as value, inv_source10 as source
from fuelinvamounts
GO
GRANT SELECT ON  [dbo].[FuelInvAmountNormalized] TO [public]
GO
