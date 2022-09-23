SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TMSGetShipmentDeliveryStopId](@shipmentId int)
RETURNS  int
AS
BEGIN
 DECLARE @stopId AS int
 
 select top 1 @stopId = TMSShipmentStops.ShipStopId from TMSShipmentStops 
     join TMSShipmentStopDetail on TMSShipmentStops.ShipStopId  = TMSShipmentStopDetail.ShipStopId and TMSShipmentStopDetail.EventType = 'DRP'
 where TMSShipmentStops.ShipId = @shipmentId
 order by TMSShipmentStops.Sequence, OrderId
     
 RETURN @stopId
END
GO
GRANT EXECUTE ON  [dbo].[TMSGetShipmentDeliveryStopId] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMSGetShipmentDeliveryStopId] TO [public]
GO
