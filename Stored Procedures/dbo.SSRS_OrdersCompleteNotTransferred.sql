SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[SSRS_OrdersCompleteNotTransferred]

(@DaysBack int,
 @Company varchar(6))

as


select 
 o.ord_hdrnumber 'order', 
 'Not Transferred' 'status',
 ord_originpoint 'origin', 
 ord_origincity = (select cty_nmstct from city where cty_code = ord_origincity),
 ord_destpoint 'dest',
 ord_destcity = (select cty_nmstct from city where cty_code = ord_destcity),
 ord_billto 'bill to', 
 (select cmp_name from company where cmp_id = ord_billto) as 'Customer Name',
  ord_startdate 'start date', 
 ord_completiondate 'end date', 
 ord_revtype1 'revtype1', 
 ord_revtype2 'revtype2',
 ord_bookedby 'booked by',
 ord_billto 'bill to',
 ord_origin_earliestdate 'earliest pick up',
 ord_origin_latestdate 'latest pick up',
 ord_dest_earliestdate 'earliest del',
 ord_dest_latestdate 'latest del',
 ivh_driver 'Driver',
 (select mpp_firstname from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver) as 'First Name',
 (select mpp_lastname from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver) as 'Last Name', 
 ivh_carrier 'Carrier'
from orderheader o WITH (NOLOCK), invoiceheader i WITH (NOLOCK)
where o.ord_hdrnumber = i.ord_hdrnumber
and ivh_invoicestatus <> 'XFR' 
and ivh_mbstatus <> 'XFR'
and ord_status in ('CMP', 'ICO')
and ivh_invoicestatus <> 'XIN'
and ord_completiondate <= GetDate()
and datediff(dd,ord_completiondate,Getdate()) > @DaysBack
and ord_revtype1 = @Company
order by status, ord_completiondate



GO
GRANT EXECUTE ON  [dbo].[SSRS_OrdersCompleteNotTransferred] TO [public]
GO
