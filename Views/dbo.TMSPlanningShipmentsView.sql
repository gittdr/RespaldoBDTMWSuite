SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMSPlanningShipmentsView]
AS
SELECT
 s.ShipId 'Id', 
 'Ship' 'Type',
 s.Mode,
 (SELECT COUNT(*) FROM TMSShipmentStops WHERE ShipId=s.ShipId) AS 'Stops',
 s.Carrier,
 delv_city.cty_nmstct 'Delivery',
 s2.PlannedArrival DeliveryDateEarliest, 
 s2.PlannedDeparture DeliveryDateLatest,
 (select TOP 1 Commodity
  from TMSShipmentStopDetail stopdetail
   join TMSOrder o on o.OrderId = stopdetail.OrderId
   left join commodity c on c.cmd_code = o.Commodity
  where stopdetail.ShipId = s.ShipId) 'Commodity',
 (select SUM(o.TotalQuantity1)
  from TMSShipmentStopDetail stopdetail
   join TMSOrder o on o.OrderId = stopdetail.OrderId
  where stopdetail.ShipId = s.ShipId) 'Pallet', 
 (select SUM(o.TotalQuantity2)
  from TMSShipmentStopDetail stopdetail
   join TMSOrder o on o.OrderId = stopdetail.OrderId
  where stopdetail.ShipId = s.ShipId) 'Cube',
 (select SUM(o.TotalQuantity3)
  from TMSShipmentStopDetail stopdetail
   join TMSOrder o on o.OrderId = stopdetail.OrderId 
  where stopdetail.ShipId = s.ShipId) 'Weight',
 pick_city.cty_nmstct 'Pickup',
 s1.PlannedArrival PickupDateEarliest, 
 s1.PlannedDeparture PickupDateLatest,  
 (SELECT COUNT(*) FROM TMSShipmentStops WHERE ShipId=s.ShipId AND 
  exists (select * from TMSShipmentStopDetail 
    where TMSShipmentStops.ShipStopId = TMSShipmentStopDetail.ShipStopId and EventType='PUP')) AS 'Pickups',
 (SELECT COUNT(*) FROM TMSShipmentStops WHERE ShipId=s.ShipId AND 
  exists (select * from TMSShipmentStopDetail 
    where TMSShipmentStops.ShipStopId = TMSShipmentStopDetail.ShipStopId and EventType='DRP')) AS 'Deliveries'
FROM TMSShipment s
 LEFT JOIN TMSShipmentStops s1 on s1.ShipId = s.ShipId and s1.ShipStopId = (select dbo.TMSGetShipmentPickupStopId(s.ShipId)) 
 LEFT JOIN TMSShipmentStops s2 on s2.ShipId = s.ShipId and s2.ShipStopId = (select dbo.TMSGetShipmentDeliveryStopId(s.ShipId)) 
 LEFT JOIN company pick on pick.cmp_id = s1.LocationId
 LEFT JOIN city pick_city on pick_city.cty_code = s1.LocationCityCode
 LEFT JOIN company delv on delv.cmp_id = s2.LocationId 
 LEFT JOIN city delv_city on delv_city.cty_code = s2.LocationCityCode
GO
GRANT SELECT ON  [dbo].[TMSPlanningShipmentsView] TO [public]
GO
