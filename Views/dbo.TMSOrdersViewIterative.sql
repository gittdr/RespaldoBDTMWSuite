SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMSOrdersViewIterative]
AS
SELECT 
 i.OrderId, 
 OrderNumber,
 (select MIN(shipid) from TMSShipmentStopDetail where TMSShipmentStopDetail.OrderId = i.OrderId)  CurrentShipment,
 (select count(*)
  from TMSShipmentStopDetail join TMSOrder on TMSShipmentStopDetail.OrderId = TMSOrder.OrderId
  where TMSShipmentStopDetail.EventType = 'PUP' and
   TMSShipmentStopDetail.ShipId = (select MIN(shipid) from TMSShipmentStopDetail where TMSShipmentStopDetail.OrderId = i.OrderId))  OrderCount,
 (select isnull(sum(TotalQuantity1), i.TotalQuantity1)
  from TMSShipmentStopDetail join TMSOrder on TMSShipmentStopDetail.OrderId = TMSOrder.OrderId
  where TMSShipmentStopDetail.EventType = 'PUP' and
   TMSShipmentStopDetail.ShipId = (select MIN(shipid) from TMSShipmentStopDetail where TMSShipmentStopDetail.OrderId = i.OrderId))  TotalQty1,
 (select isnull(sum(TotalQuantity2), i.TotalQuantity2)
  from TMSShipmentStopDetail join TMSOrder on TMSShipmentStopDetail.OrderId = TMSOrder.OrderId
  where TMSShipmentStopDetail.EventType = 'PUP' and
   TMSShipmentStopDetail.ShipId = (select MIN(shipid) from TMSShipmentStopDetail where TMSShipmentStopDetail.OrderId = i.OrderId))  TotalQty2,
 (select isnull(sum(TotalQuantity3), i.TotalQuantity3)
  from TMSShipmentStopDetail join TMSOrder on TMSShipmentStopDetail.OrderId = TMSOrder.OrderId
  where TMSShipmentStopDetail.EventType = 'PUP' and
   TMSShipmentStopDetail.ShipId = (select MIN(shipid) from TMSShipmentStopDetail where TMSShipmentStopDetail.OrderId = i.OrderId))  TotalQty3,
 s1.WindowDateEarliest PickupDateEarliest, 
 s1.WindowDateLatest PickupDateLatest,  
 s2.WindowDateEarliest DeliveryDateEarliest, 
 s2.WindowDateLatest DeliveryDateLatest, 
 ISNULL(delv_city.cty_name, '') 'Delivery City',
 ISNULL(delv_city.cty_state, '') 'Delivery State',
 s2.LocationId DeliveryId, 
 ISNULL(delv.cmp_name, '') 'Delivery',
 Commodity,
 FreightClass,
 TotalQuantity1,
 TotalQuantity1Unit,
 TotalQuantity2,
 TotalQuantity2Unit,
 TotalQuantity3,
 TotalQuantity3Unit,
 ISNULL(pick_city.cty_name, '') 'Pickup City',
 ISNULL(pick_city.cty_state, '') 'Pickup State',
 s1.LocationId PickupId, 
 ISNULL(pick.cmp_name, '') 'Pickup',
 delv_city.cty_nmstct DeliveryCityState,
 pick_city.cty_nmstct PickupCityState,
 Branch
FROM TMSOrder i left join TMSStops as s1 on s1.OrderId = i.OrderId and s1.StopType = 'PUP'
left join TMSStops as s2 on s2.OrderId = i.OrderId and s2.StopType = 'DRP'
LEFT JOIN company pick on pick.cmp_id = s1.LocationId
LEFT JOIN city pick_city on pick_city.cty_code = s1.LocationCityCode
LEFT JOIN company delv on delv.cmp_id = s2.LocationId 
LEFT JOIN city delv_city on delv_city.cty_code = s2.LocationCityCode
WHERE ISNULL(i.Status1,'UNP') <> 'CAN'
GO
GRANT SELECT ON  [dbo].[TMSOrdersViewIterative] TO [public]
GO
