SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create VIEW [dbo].[TMSShipmentOrderView]
AS
SELECT   
    ORd.OrderId,
 ORD.OrderNumber,
 ORD.NotifyDate,
 Ord.PONumber,  
 PUP.LocationId 'Pickup',
 PUP.LocationCityState 'Pickup City/State',
 PUP.WindowDateEarliest 'Pickup Earliest',
 PUP.WindowDateLatest 'Pickup Latest',
    DRP.LocationId 'Delivery',
 DRP.LocationCityState 'Delivery City/State',
 DRP.WindowDateEarliest 'Delivery Earliest',
 DRP.WindowDateLatest 'Delivery Latest',
 TSDPUP.ShipId 'ShipID',
 'ModePlanner_ShipmentOrder' as 'ModePlanner_ShipmentOrder' 
FROM  TMSorder ORD
join  TMSShipmentStopDetail as TSDPUP on TSDPUP.OrderID = ORD.OrderId and TSDPUP.EventType = 'PUP'  
join  TMSShipmentStopDetail as TSDDRP on TSDDRP.OrderID = ORD.OrderId and TSDDRP.EventType = 'DRP' 
join  TMSShipmentStops as PUP on TSDPUP.ShipId = PUP.ShipId and PUP.Sequence=1
join  TMSShipmentStops as DRP on TSDDRP.ShipId = DRP.ShipId and Drp.Sequence = (select MAX(sequence) from TMSShipmentStops where ShipId=drp.ShipId )
GO
GRANT SELECT ON  [dbo].[TMSShipmentOrderView] TO [public]
GO
