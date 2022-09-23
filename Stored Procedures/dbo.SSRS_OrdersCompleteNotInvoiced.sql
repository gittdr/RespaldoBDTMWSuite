SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[SSRS_OrdersCompleteNotInvoiced]

(@DaysBack int,
 @Company varchar(6))

as


/* completed orders not invoiced/transferred */
select 
 ord_hdrnumber 'Order', 
 'Not Invoiced' 'Status',
 ord_originpoint 'Origin',
 ord_origincity = (select cty_nmstct from city where cty_code = ord_origincity),
 ord_destpoint 'Dest',
 ord_destcity = (select cty_nmstct from city where cty_code = ord_destcity), 
 ord_billto 'Bill To', 
 (select cmp_name from company where cmp_id = ord_billto) as 'Customer Name',
 ord_startdate 'Start Date', 
 ord_completiondate 'End Date', 
 ord_revtype1 'revtype1', 
 ord_revtype2 'revtype2',
 ord_bookedby 'Booked By',
 ord_origin_earliestdate 'Earliest Pick Up',
 ord_origin_latestdate 'Latest Pick Up',
 ord_dest_earliestdate 'Earliest Delivery',
 ord_dest_latestdate 'Latest Delivery',
 ord_driver1 'Driver ID',
 (select mpp_firstname from manpowerprofile WITH (NOLOCK) where mpp_id = ord_driver1) as 'First Name',
 (select mpp_lastname from manpowerprofile WITH (NOLOCK) where mpp_id = ord_driver1) as 'Last Name', 
 ord_carrier 'Carrier'
from orderheader WITH (NOLOCK)
where ord_completiondate <= GetDate()
and datediff(dd,ord_completiondate,Getdate()) > @DaysBack
and ord_status in ('CMP', 'ICO')
and ord_revtype1 = @Company
and not exists (select ord_hdrnumber from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)

order by status, ord_completiondate




GO
GRANT EXECUTE ON  [dbo].[SSRS_OrdersCompleteNotInvoiced] TO [public]
GO
