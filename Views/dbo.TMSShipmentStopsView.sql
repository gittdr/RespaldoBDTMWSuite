SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create VIEW [dbo].[TMSShipmentStopsView]
AS
SELECT
 ShipId 'ShipID',
 ShipstopId 'Shipment Stop', 
 Sequence   'Sequence',
 LocationId 'Company ID',
 cmp.cmp_name 'Company Name', 
    PlannedArrival 'Planned Arrival',
    PlannedDeparture 'Planned Departure',
 LocationCityState 'City/State',
 LocationZip 'Zip',
 Distance 'Miles',
 'ModePlanner_ShipmentStop' as 'ModePlanner_ShipmentStop'
FROM TMSShipmentStops
     join company cmp on cmp.cmp_id=LocationId
GO
GRANT SELECT ON  [dbo].[TMSShipmentStopsView] TO [public]
GO
