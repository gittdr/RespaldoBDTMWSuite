SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMSOrderSearchPopUpView]
AS
SELECT 
o.OrderNumber 'Order Number',
o.Status1 'Status',
CAST(ROUND(dbo.tmw_airdistance_fn(pc.cty_latitude, pc.cty_longitude, dc.cty_latitude, dc.cty_longitude),2,2) as float(2)) 'Order Miles',
ps.LocationId 'Pickup Company',
pc.cty_nmstct 'Pickup City State',
ps.WindowDateEarliest 'Pickup Date Earliest', 
ds.LocationId 'Delivery Company',
dc.cty_nmstct 'Delivery City State',
ds.WindowDateLatest 'Delivery Date Latest', 
o.Branch 'Line of Business',
o.ReferenceValue1 'Reference Nbr 1',
o.ReferenceValue2 'Reference Nbr 2',
o.Referencevalue3 'Reference Nbr 3',
o.OrderId 'OrderId'

FROM TMSOrder o 
LEFT JOIN TMSStops as ps on ps.OrderId = o.OrderId and ps.StopType = 'PUP'
LEFT JOIN TMSStops as ds on ds.OrderId = o.OrderId and ds.StopType = 'DRP'
LEFT JOIN city pc on pc.cty_code = ps.LocationCityCode
LEFT JOIN city dc on dc.cty_code = ds.LocationCityCode
GO
GRANT SELECT ON  [dbo].[TMSOrderSearchPopUpView] TO [public]
GO
