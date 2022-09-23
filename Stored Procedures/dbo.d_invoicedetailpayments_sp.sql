SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*

exec d_invoicedetailpayments_sp 4679

*/
create PROC [dbo].[d_invoicedetailpayments_sp] (@ivh_hdrnumber int)
AS  


select ivdpymt_check_number, ivdpymt_amount_pd, ivdpymt_check_date, ivh_currency, ivh_totalcharge
from invoicedetailpayments, invoiceheader
where ivdpymt_ivhnumber = @ivh_hdrnumber
and ivdpymt_ivhnumber = ivh_hdrnumber
order by ivdpymt_check_date desc

GO
GRANT EXECUTE ON  [dbo].[d_invoicedetailpayments_sp] TO [public]
GO
