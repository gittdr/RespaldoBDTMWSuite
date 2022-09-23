SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMSShipmentsView]
AS

SELECT
 s.ShipId,
 s.ShipmentNumber,
 Mode,
 Carrier,
 ServiceLevel,
 ServiceDays,
 (SELECT COUNT(*) FROM TMSShipmentStops WHERE ShipId=s.ShipId) AS 'Stops',
 s1.PlannedArrival PickupDateEarliest, 
 s1.PlannedDeparture PickupDateLatest,  
 s2.PlannedArrival DeliveryDateEarliest, 
 s2.PlannedDeparture DeliveryDateLatest, 
 (SELECT COUNT(*) FROM TMSShipmentStops WHERE ShipId=s.ShipId AND 
   exists (select * from TMSShipmentStopDetail 
     where TMSShipmentStops.ShipStopId = TMSShipmentStopDetail.ShipStopId and EventType='PUP')) AS 'Pickups',
 ISNULL(pick_city.cty_name, '') 'Pickup City',
 ISNULL(pick_city.cty_state, '') 'Pickup State',
 s1.LocationId PickupId, 
 ISNULL(pick.cmp_name, '') 'Pickup',
 (SELECT COUNT(*) FROM TMSShipmentStops WHERE ShipId=s.ShipId AND 
   exists (select * from TMSShipmentStopDetail 
     where TMSShipmentStops.ShipStopId = TMSShipmentStopDetail.ShipStopId and EventType='DRP')) AS 'Deliveries',
 ISNULL(delv_city.cty_name, '') 'Delivery City',
 ISNULL(delv_city.cty_state, '') 'Delivery State',
 s2.LocationId DeliveryId, 
 ISNULL(delv.cmp_name, '') 'Delivery',
 delv_city.cty_nmstct DeliveryCityState,
 pick_city.cty_nmstct PickupCityState
FROM TMSShipment s
 LEFT JOIN TMSShipmentStops s1 on s1.ShipId = s.ShipId and s1.ShipStopId = (select dbo.TMSGetShipmentPickupStopId(s.ShipId)) 
 LEFT JOIN TMSShipmentStops s2 on s2.ShipId = s.ShipId and s2.ShipStopId = (select dbo.TMSGetShipmentDeliveryStopId(s.ShipId)) 
 LEFT JOIN company pick on pick.cmp_id = s1.LocationId
 LEFT JOIN city pick_city on pick_city.cty_code = s1.LocationCityCode
 LEFT JOIN company delv on delv.cmp_id = s2.LocationId 
 LEFT JOIN city delv_city on delv_city.cty_code = s2.LocationCityCode
WHERE s.DispatchNumber IS NULL
GO
GRANT SELECT ON  [dbo].[TMSShipmentsView] TO [public]
GO
