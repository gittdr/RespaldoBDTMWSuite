SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWOrderSearchPopUpView]
AS

SELECT
ord_number 'Order Number',
ord_status 'Status',
CAST(ROUND(dbo.tmw_airdistance_fn(pc.cty_latitude, pc.cty_longitude, dc.cty_latitude, dc.cty_longitude),2,2) as float(2)) 'Order Miles',
ord_shipper 'Pickup Company',
ord_consignee 'Delivery Company',
ord_origin_earliestdate 'Pickup Date Earliest', 
ord_dest_latestdate 'Delivery Date Latest', 
pc.cty_nmstct 'Pickup City State',
dc.cty_nmstct 'Delivery City State',
ord_booked_revtype1 'Line of Business',
ord_refnum 'Reference Nbr',
ord_hdrnumber 'OrderId'

FROM OrderHeader 
LEFT JOIN city pc on pc.cty_code = ord_origincity
LEFT JOIN city dc on dc.cty_code = ord_destcity

GO
GRANT SELECT ON  [dbo].[TMWOrderSearchPopUpView] TO [public]
GO
