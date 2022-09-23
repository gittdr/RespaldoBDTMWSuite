SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[EstatLTLQuotesPollerView]
AS select	
	qh.QuoteID, 
	qd.PickupDate 'Pickup', 
	qd.DeclaredValue 'Value', 
	isnull(cmp_bill.cmp_name, qd.BillTo) 'BillTo',
	isnull(cmp_ship.cmp_name, qd.Shipper) 'Shipper', 
	isnull(cty_ship.cty_nmstct, '') 'Shipper City', 
	qd.ShipperZipCode 'Shipper Zip',
	isnull(cmp_cons.cmp_name, qd.Consignee) 'Consignee',
	isnull(cty_cons.cty_nmstct, '') as 'Consignee City',
	qd.ConsigneeZipCode 'Consignee Zip',
	qh.UserName 'Created By',
	qh.RequestDate 'Created On'
from LTLQuote_RequestHeader qh
inner join LTLQuote_RequestDetails qd on qd.QuoteID=qh.QuoteID
left join company cmp_bill on cmp_bill.cmp_id = qd.BillTo
left join company cmp_ship on cmp_ship.cmp_id = qd.Shipper
left join company cmp_cons on cmp_cons.cmp_id = qd.Consignee
left join city cty_ship on cty_ship.cty_code = qd.ShipperCtyCode
left join city cty_cons on cty_cons.cty_code = qd.ConsigneeCtyCode

GO
GRANT INSERT ON  [dbo].[EstatLTLQuotesPollerView] TO [public]
GO
GRANT SELECT ON  [dbo].[EstatLTLQuotesPollerView] TO [public]
GO
GRANT UPDATE ON  [dbo].[EstatLTLQuotesPollerView] TO [public]
GO
