SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[LoadBuilderOrderTripView]       
as       
      
select OperationsTripViewOrdDetails.*, 
	stops.stp_number, 
	stops.stp_mfh_sequence, 
	stops.cmp_id, 
	stops.cmp_name, 
	city.cty_nmstct, 
	city.cty_state, 
	stops.stp_zipcode,      
	stops.stp_event, 
	stops.stp_lgh_mileage, 
	stops.stp_arrivaldate, 
	stops.stp_departuredate, 
	stops.stp_schdtearliest, 
	stops.stp_schdtlatest,      
	stops.stp_status, 
	stops.stp_departure_status, 
	stops.ord_hdrnumber, 
	stops.cmd_code, 
	stops.stp_description,   
	IsNull(company.cmp_latseconds, 0)/3600.0 as Latitude, 
	IsNull(company.cmp_longseconds, 0)/3600.0 as Longitude , 
	(SELECT count(DISTINCT ord_hdrnumber) FROM stops (nolock) WHERE stops.lgh_number = OperationsTripViewOrdDetails.lgh_number AND ord_hdrnumber <> 0 ) 'OrdCnt',
	stops.stp_detstatus,
	(select ISNULL((select top 1 stp_schdtearliest from stops (nolock) where mov_number = OperationsTripViewOrdDetails.mov_number and stp_type = 'PUP' order by stp_mfh_sequence), '1950-01-01 00:00:00')) as PickupEarliest,
	(select ISNULL((select top 1 stp_schdtlatest from stops (nolock) where mov_number = OperationsTripViewOrdDetails.mov_number and stp_type = 'PUP' order by stp_mfh_sequence), '2049-12-31 23:59:59')) as PickupLatest,
	(Select isNull(DATEDIFF(minute,ord_origin_earliestdate, GETDATE()),0) from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber)/1440 DaysAvailable,
	(select count(Distinct ord_hdrnumber) from stops where stops.lgh_number = OperationsTripViewOrdDetails.lgh_number) ord_count,
	(Select isNull(ord_extrainfo1,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_extrainfo1,
	(Select isNull(ord_extrainfo2,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_extrainfo2,
	(Select isNull(ord_extrainfo3,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_extrainfo3,
	(Select isNull(ord_extrainfo4,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_extrainfo4,
	(Select isNull(ord_extrainfo5,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_extrainfo5,
	(Select isNull(ord_extrainfo6,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_extrainfo6,
	(Select isNull(ord_extrainfo7,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_extrainfo7,
	(Select isNull(ord_extrainfo8,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_extrainfo8,
	(Select isNull(ord_extrainfo9,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_extrainfo9,
	(Select isNull(ord_extrainfo10,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_extrainfo10,
	(select cmp_altid from company where cmp_id = OperationsTripViewOrdDetails.ConsigneeId) 'consignee_altid',
	(select cmp_name from company where cmp_id = OperationsTripViewOrdDetails.ConsigneeId) 'consignee_name',
	(select cty_nmstct from company where cmp_id = OperationsTripViewOrdDetails.ConsigneeId) 'consignee_cty_state',	
	(Select ord_availabledate from orderheader where orderheader.ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) ord_availabledate,
	(select cmp_altid from company where cmp_id = OperationsTripViewOrdDetails.PickupId) 'shipper_altid',
	(select cmp_name from company where cmp_id = OperationsTripViewOrdDetails.PickupId) 'shipper_name',	
	(select cty_nmstct from company where cmp_id = OperationsTripViewOrdDetails.PickupId) 'shipper_cty_state',
	(select ref_number from referencenumber where ref_type = 'MODEL' and ord_hdrnumber = OperationsTripViewOrdDetails.OrderHeaderNumber) 'Model'
from OperationsTripViewOrdDetails (nolock) join stops (nolock) on OperationsTripViewOrdDetails.OrderHeaderNumber = stops.ord_hdrnumber      
      join city on city.cty_code = stops.stp_city      
      join company on company.cmp_id = stops.cmp_id
GO
GRANT SELECT ON  [dbo].[LoadBuilderOrderTripView] TO [public]
GO
