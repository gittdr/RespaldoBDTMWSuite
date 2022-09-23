SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[GetLTLServiceTime]
	@car_id varchar(8),
	@OriginZip varchar(6),
	@DestinationZip varchar(6)
as
	declare @MatchOriginZip varchar(6),	@MatchDestinationZip varchar(6)
	select @MatchOriginZip  = null, @MatchDestinationZip = null
	
	select @MatchOriginZip = Zip from CarrierLTLServiceZone where car_id = @car_id and Zip = @OriginZip
	if @MatchOriginZip is null
	begin
		select @MatchOriginZip = Zip from CarrierLTLServiceZone where car_id = @car_id and Zip = left(@OriginZip, DATALENGTH(Zip))
	end
	select @MatchDestinationZip = Zip from CarrierLTLServiceZone where car_id = @car_id and Zip = @DestinationZip
	if @MatchDestinationZip is null
	begin
		select @MatchDestinationZip = Zip from CarrierLTLServiceZone where car_id = @car_id and Zip = left(@DestinationZip, DATALENGTH(Zip))
	end
	select m.Days + isnull(origin.OriginExtraDays,0) + isnull(destination.DestinationExtraDays,0) as Days,
		origin.ServiceZone as OriginTerminalZone,
		origin.OriginServiceLevel as OriginService,
		destination.ServiceZone as DestinationTerminalZone,
		destination.destinationServiceLevel as DestinationService
		
	from CarrierLTLServiceMatrix as m
		join CarrierLTLServiceZone as origin on m.OriginServiceZone = origin.ServiceZone and origin.car_id = @car_id 
		join CarrierLTLServiceZone as destination on m.DestinationServiceZone = destination.ServiceZone and destination.car_id = @car_id 
	where m.car_id = @car_id and 
		origin.Zip = @MatchOriginZip and
		destination.Zip = @MatchDestinationZip
GO
GRANT EXECUTE ON  [dbo].[GetLTLServiceTime] TO [public]
GO
