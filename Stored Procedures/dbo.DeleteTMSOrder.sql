SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[DeleteTMSOrder]
      @orderNumber varchar(20)
as
 declare @id int
 select @id = orderid from TMSOrder 
 where OrderNumber = @orderNumber

 select Distinct shipid 
 into #del
 from TMSShipmentStopDetail where OrderId = @id

 declare @mov int
 select @mov = 0
 while exists (select * from TMSShipment join #del on TMSShipment.shipid =  #del.ShipId
     where DispatchNumber > @mov)
 begin
  select @mov = min(DispatchNumber) from TMSShipment join #del on TMSShipment.shipid =  #del.ShipId
     where DispatchNumber > @mov
  exec purge_delete @mov, 0 
 end

 delete TMSShipmentStopReferenceNumber
 from TMSShipmentStopReferenceNumber join #del on TMSShipmentStopReferenceNumber.shipid =  #del.ShipId

 delete TMSShipmentReferenceNumber
 from TMSShipmentReferenceNumber join #del on TMSShipmentReferenceNumber.shipid =  #del.ShipId

 delete TMSShipmentStopDetail 
 from TMSShipmentStopDetail join #del on TMSShipmentStopDetail.shipid =  #del.ShipId

 delete TMSShipmentStops 
 from TMSShipmentStops join #del on TMSShipmentStops.shipid =  #del.ShipId

 delete TMSShipment 
 from TMSShipment join #del on TMSShipment.shipid =  #del.ShipId

 drop table #del
 delete from TMSOrderRating where OrderId = @id
 delete from TMSTransitRatingDetail 
 from TMSTransitRatingDetail join TMSTransitRating on TMSTransitRatingDetail.RateId =  TMSTransitRating.RateId
 where OrderId = @id

 delete from TMSTransitRating where OrderId = @id
 delete from TMSOrderLineItemReferenceNumbers where OrderId = @id
 delete from TMSStopReferenceNumbers where OrderId = @id
 delete from TMSOrderReferenceNumbers where OrderId = @id
 delete from TMSOrderLineItems where OrderId = @id
 delete from TMSStops where OrderId = @id
 delete from TMSOrder where OrderId = @id
GO
GRANT EXECUTE ON  [dbo].[DeleteTMSOrder] TO [public]
GO
