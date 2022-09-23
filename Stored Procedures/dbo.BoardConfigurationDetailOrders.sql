SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[BoardConfigurationDetailOrders] @lgh_number int
as
SELECT DISTINCT  ord_number, ord_originpoint, ord_origincity, ord_destpoint, ord_destcity, ord_startdate, 
       ord_completiondate, orderheader.ord_billto, orderheader.ord_totalweight, cmp1.cmp_name origin_cmp_name, 
       cmp2.cmp_name dest_cmp_name, c1.cty_nmstct origin_city, c2.cty_nmstct destination_city, ord_extrainfo1, 
		 ord_extrainfo2, ord_extrainfo3, ord_extrainfo4, ord_extrainfo5, ord_extrainfo6, ord_extrainfo7, 
		 ord_extrainfo8, ord_extrainfo9, ord_extrainfo10, ord_extrainfo11, ord_extrainfo12, ord_extrainfo13,
		 ord_extrainfo14, ord_extrainfo15, ord_origin_earliestdate, ord_origin_latestdate, ord_dest_earliestdate, 
		 ord_dest_latestdate, xdock, ord_tareweight, legheader_active.lgh_number
  FROM legheader_active
		join stops on stops.lgh_number = legheader_active.lgh_number
		join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
		join company as cmp1 on orderheader.ord_originpoint = cmp1.cmp_id
		join company as cmp2 on orderheader.ord_destpoint = cmp2.cmp_id
		join city as c1 on orderheader.ord_origincity = c1.cty_code 
		join city as c2 on orderheader.ord_destcity = c2.cty_code 
	where legheader_active.lgh_number = @lgh_number
GO
GRANT EXECUTE ON  [dbo].[BoardConfigurationDetailOrders] TO [public]
GO
