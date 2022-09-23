SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[EstatLTLQuotesView]
AS select	
	oh.ord_hdrnumber 'QuoteID', 
	oh.ord_origin_earliestdate 'Pickup',
	oh.ord_cmdvalue 'Value',
	isnull(cmp_bill.cmp_name, oh.ord_billto) 'BillTo',
	isnull(cmp_ship.cmp_name, oh.ord_shipper) 'Shipper', 
	isnull(cty_ship.cty_nmstct, '') 'Shipper City', 
	oh.ord_origin_zip 'Shipper Zip',
	isnull(cmp_cons.cmp_name, oh.ord_consignee) 'Consignee',
	isnull(cty_cons.cty_nmstct, '') as 'Consignee City',
	oh.ord_dest_zip 'Consignee Zip',
	oh.ord_bookedby 'Created By',
	oh.ord_bookdate 'Created On'
from orderheader oh
left join company cmp_bill on cmp_bill.cmp_id = oh.ord_billto
left join company cmp_ship on cmp_ship.cmp_id = oh.ord_shipper
left join company cmp_cons on cmp_cons.cmp_id = oh.ord_consignee
left join city cty_ship on cty_ship.cty_code = oh.ord_origincity
left join city cty_cons on cty_cons.cty_code = oh.ord_destcity
where ord_status = 'QTE'

GO
GRANT INSERT ON  [dbo].[EstatLTLQuotesView] TO [public]
GO
GRANT SELECT ON  [dbo].[EstatLTLQuotesView] TO [public]
GO
GRANT UPDATE ON  [dbo].[EstatLTLQuotesView] TO [public]
GO
