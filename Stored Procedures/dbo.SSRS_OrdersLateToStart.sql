SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[SSRS_OrdersLateToStart]


(@DaysBack int,
 @Company varchar(6))

as

select 
 ord_hdrnumber 'order', 
 case ord_status when 'AVL' then 'Available' when 'PLN' then 'Planned' when  'DSP' then 'Dispatched' when 'STD' then 'Started' else ord_status end as 'status',
 ord_originpoint 'origin', 
 ord_origincity = (select cty_nmstct from city where cty_code = ord_origincity),
 (select cty_name from city where cty_code = ord_origincity) as 'Origin City',
 (select cty_state from city where cty_code = ord_origincity) as 'Origin State',
 ord_destpoint 'dest', 
 (select cty_name from city where cty_code = ord_destcity) as 'Dest City',
 (select cty_state from city where cty_code = ord_destcity) as 'Dest State',
 ord_billto 'bill to', 
 (select cmp_name from company where cmp_id = ord_billto) as 'Bill To Name',
 ord_startdate 'start date', 
 ord_completiondate 'end date', 
 -- datediff(hh,ord_startdate,Getdate()) 'Hours Late',
 datediff(hh,ord_origin_earliestdate,Getdate()) 'Hours Late',
 ord_revtype1 'revtype1', 
 ord_revtype2 'revtype2',
 ord_bookedby 'booked by',
 ord_origin_earliestdate 'earliest pick up',
 ord_origin_latestdate 'latest pick up',
 ord_dest_earliestdate 'earliest del',
 ord_dest_latestdate 'latest del',
 ord_bookdate 'Booked Date'
from orderheader
where ord_startdate <= GetDate()
-- and datediff(hh,ord_startdate,Getdate()) > @DaysBack
and datediff(hh,ord_origin_earliestdate,Getdate()) > @DaysBack
and ord_status in ('AVL', 'PLN', 'DSP') 
and ord_revtype1 = @Company

order by ord_startdate




GO
GRANT EXECUTE ON  [dbo].[SSRS_OrdersLateToStart] TO [public]
GO
