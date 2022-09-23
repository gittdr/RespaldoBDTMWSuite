SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[actg_prorate_delivery_line_sp]
	@p_ivh_number int          -- The invoiceheader number to use in the resultset.
	
as
set nocount on 


delete from REVENUEALLOCATION 
where IVH_NUMBER = @p_ivh_number
and cht_itemcode = 'DEL'

 insert into revenueallocation (ivh_number, ivd_number, lgh_number,  ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode,  ral_converted_rate, ral_converted_amount, ral_glnum)
select invoiceheader.ivh_hdrnumber, ivd_number, lgh_number, ivd_distance, ivd_quantity, 0, 0, cur_code, 1, invoicedetail.cht_itemcode,  0, 0, ivd_glnum
from invoicedetail, invoiceheader, stops
where invoiceheader.IVH_HDRNUMBER = @p_ivh_number
and invoiceheader.IVH_HDRNUMBER  = invoicedetail.ivh_hdrnumber
and invoicedetail.stp_number = stops.stp_number
and invoicedetail.cht_itemcode = 'DEL'


-- Done
RETURN
set nocount off
GO
GRANT EXECUTE ON  [dbo].[actg_prorate_delivery_line_sp] TO [public]
GO
