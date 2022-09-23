SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[OperationsTripViewStops_WithSplitSequence]       
as       
      
select OperationsTripViewDetails.*, stops.stp_number, stops.stp_mfh_sequence, stops.cmp_id, 
      stops.cmp_name, city.cty_nmstct, city.cty_state, stops.stp_zipcode, stops.stp_event, 
      stops.stp_lgh_mileage, stops.stp_arrivaldate, stops.stp_departuredate, stops.stp_schdtearliest, 
      stops.stp_schdtlatest, stops.stp_status, stops.stp_departure_status, stops.ord_hdrnumber, 
      stops.cmd_code, stops.stp_description, IsNull(company.cmp_latseconds, 0)/3600.0 as Latitude, 
      IsNull(company.cmp_longseconds, 0)/3600.0 as Longitude, 
      (SELECT count(DISTINCT ord_hdrnumber) FROM stops (nolock) 
            WHERE stops.lgh_number = OperationsTripViewDetails.lgh_number AND ord_hdrnumber <> 0 ) 'OrdCnt',
      stops.stp_detstatus,
      (select ISNULL((select top 1 stp_schdtearliest from stops (nolock) 
            where mov_number = OperationsTripViewDetails.mov_number 
            and stp_type = 'PUP' order by stp_mfh_sequence), '1950-01-01 00:00:00')) as PickupEarliest,
      (select ISNULL((select top 1 stp_schdtlatest from stops (nolock) 
            where mov_number = OperationsTripViewDetails.mov_number 
            and stp_type = 'PUP' order by stp_mfh_sequence), '2049-12-31 23:59:59')) as PickupLatest,
      OperationsTripViewDetails.OrderNumber + CASE WHEN OperationsTripViewDetails.OrderNumber LIKE '%-S' 
            THEN CAST((SELECT COUNT(Distinct(lgh_number)) 
            FROM OperationsTripViewDetails WHERE OperationsTripViewDetails.mov_number = stops.mov_number 
            AND startdate <= ( SELECT TOP 1 StartDate FROM OperationsTripViewDetails 
            WHERE OperationsTripViewDetails.lgh_number = stops.lgh_number ORDER BY StartDate)) AS VARCHAR(3)) ELSE '' END AS OrderNumberSplit 
        
from OperationsTripViewDetails (nolock) join stops (nolock) on OperationsTripViewDetails.lgh_number = stops.lgh_number      
      join city on city.cty_code = stops.stp_city      
      join company on company.cmp_id = stops.cmp_id
GO
GRANT SELECT ON  [dbo].[OperationsTripViewStops_WithSplitSequence] TO [public]
GO
