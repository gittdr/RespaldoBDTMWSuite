SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[OperationsTripViewStopsShifts] 
as 
      
select OperationsTripViewShifts.*, stops.stp_number, stops.stp_mfh_sequence, stops.cmp_id, stops.cmp_name, city.cty_nmstct, city.cty_state, stops.stp_zipcode,      
  stops.stp_event, stops.stp_lgh_mileage, stops.stp_arrivaldate, stops.stp_departuredate, stops.stp_schdtearliest, stops.stp_schdtlatest,      
  stops.stp_status, stops.stp_departure_status, stops.ord_hdrnumber, stops.cmd_code, stops.stp_description,   
  IsNull(company.cmp_latseconds, 0)/3600.0 as Latitude, IsNull(company.cmp_longseconds, 0)/3600.0 as Longitude , 
  (SELECT count(DISTINCT ord_hdrnumber) FROM stops (nolock) WHERE stops.lgh_number = OperationsTripViewShifts.lgh_number AND ord_hdrnumber <> 0 ) 'OrdCnt',
  stops.stp_detstatus,
  (select ISNULL((select top 1 stp_schdtearliest from stops (nolock) where mov_number = OperationsTripViewShifts.mov_number and stp_type = 'PUP' order by stp_mfh_sequence), '1950-01-01 00:00:00')) as PickupEarliest,
  (select ISNULL((select top 1 stp_schdtlatest from stops (nolock) where mov_number = OperationsTripViewShifts.mov_number and stp_type = 'PUP' order by stp_mfh_sequence), '2049-12-31 23:59:59')) as PickupLatest
  
        
from OperationsTripViewShifts (nolock) join stops (nolock) on OperationsTripViewShifts.lgh_number = stops.lgh_number      
      join city on city.cty_code = stops.stp_city      
      join company on company.cmp_id = stops.cmp_id


GO
GRANT SELECT ON  [dbo].[OperationsTripViewStopsShifts] TO [public]
GO
