SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMSOrdersView]
AS
SELECT 
 i.OrderId, 
 OrderNumber,
 TransitStatus = (select distinct top 1 orderheader.ord_status from orderheader 
       inner join TMSShipment on TMSShipment.DispatchNumber = orderheader.mov_number  
       inner join TMSShipmentStopDetail on TMSShipmentStopDetail.ShipId = TMSShipment.ShipId and TMSShipmentStopDetail.OrderId = i.OrderId),
    DispatchNumber = (select distinct top 1 TMSShipment.DispatchNumber from TMSShipment 
       inner join TMSShipmentStopDetail on TMSShipmentStopDetail.ShipId = TMSShipment.ShipId and TMSShipmentStopDetail.OrderId = i.OrderId),
 (case when (select count(*) from TMSOrderRating
  where OrderId = i.OrderID
   and RateMode in ('TL','LTL') and RateType = 'LH') >= 2 then 'Y' else 'N' end) as IsRated,
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
  and not exists (select * from TMSShipmentStopDetail where TMSShipmentStopDetail.OrderId = i.OrderId )
GO
GRANT SELECT ON  [dbo].[TMSOrdersView] TO [public]
GO
