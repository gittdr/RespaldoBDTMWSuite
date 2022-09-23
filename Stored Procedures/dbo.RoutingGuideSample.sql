SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[RoutingGuideSample] @freightOrderId bigint
as
/*
		Parcel, //no TMW consolidation needed the freight leg will be shipped Parcel
        LTL, //no TMW consolidation needed the freight leg will be shipped LTL
        Rail, //no TMW consolidation needed the freight leg will be shipped Rail
        Sea, // no TMW consolidation needed the freight leg will be shipped on a boat
        FullTruckload, // no TMW consolidation needed the freight leg is already a full truck load
        OptimizeTruckload, // TMW consolidation is needed and will be performed by an optimizer to build a TMW trip that includes multiple freight legs.
        ManualTruckload, // TMW consolidation is needed and will be performed by a dispatch/planner to build a TMW trip that includes multiple freight legs.
        OutboundParkAndHook, // This leg is park and hook and it will get created automatically containing the same freight orders as the next OptimizeTruckload or ManualTruckload trip.
        InboundParkAndHook // This leg is park and hook and it will get created automatically containing the same freight orders as the prior OptimizeTruckload or ManualTruckload trip.
*/
	declare @Found bit, @ShipperIsAltId bit, @ConsigneeIsAltId bit, @Shipper varchar(25), @Consignee varchar(25)		
	select @Found = 1,
		@ShipperIsAltId = ShipperIsAltId,
		@Shipper = ship.LocationKey,
		@ConsigneeIsAltId = ConsigneeIsAltId,
		@Consignee = cons.LocationKey
	from FreightOrder o join FreightOrderSource s on o.Source = s.Source
			join FreightOrderStop ship on ship.FreightOrderStopId = o.PickupStopId
			join FreightOrderStop cons on cons.FreightOrderStopId = o.DeliveryStopId
	where o.FreightOrderId = @freightOrderId
	
	if @ShipperIsAltId = 1
		select @Shipper = cmp_id from company where cmp_altid = @Shipper
	if @ConsigneeIsAltId = 1
		select @Consignee = cmp_id from company where cmp_altid = @Consignee

	declare @results as table(
	Sequence int identity,
	FreightOrderId bigint not null,
	OriginId varchar(8) not null,
	DestinationId varchar(8) not null,
	Mode varchar(25) not null
	)

	if (@found = 1)
		insert @results(FreightOrderId,	OriginId, DestinationId, Mode)
		values (@freightOrderId, @Shipper, @Consignee, 'OptimizeTruckload')

	select * from @results
GO
GRANT EXECUTE ON  [dbo].[RoutingGuideSample] TO [public]
GO
