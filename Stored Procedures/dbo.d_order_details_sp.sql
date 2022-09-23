SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_order_details_sp] @ord int 
as
select ord_number, compa.cmp_name, citya.cty_nmstct, compb.cmp_name, cityb.cty_nmstct,
	ord_cod_amount, ord_origin_earliestdate, ord_origin_latestdate, ord_dest_earliestdate, ord_dest_latestdate
from orderheader , company compa , company compb , city citya , city cityb 
where ord_originpoint =compa.cmp_id and ord_destpoint =compb.cmp_id and 
	ord_origincity =citya.cty_code and 
	ord_destcity =cityb.cty_code and ord_hdrnumber = @ord 
GO
GRANT EXECUTE ON  [dbo].[d_order_details_sp] TO [public]
GO
