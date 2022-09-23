SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[OperationsTripViewStopsWithDriverSeating]     
as       
      
select OperationsTripViewDetailsWithDriverSeating.*, stops.stp_number, stops.stp_mfh_sequence, stops.cmp_id, stops.cmp_name, city.cty_nmstct, city.cty_state, stops.stp_zipcode,      
  stops.stp_event, stops.stp_lgh_mileage, stops.stp_arrivaldate, stops.stp_departuredate, stops.stp_schdtearliest, stops.stp_schdtlatest,      
  stops.stp_status, stops.stp_departure_status, stops.ord_hdrnumber, stops.cmd_code, stops.stp_description,   
  IsNull(company.cmp_latseconds, 0)/3600.0 as Latitude, IsNull(company.cmp_longseconds, 0)/3600.0 as Longitude        
from OperationsTripViewDetailsWithDriverSeating join stops on OperationsTripViewDetailsWithDriverSeating.lgh_number = stops.lgh_number      
      join city on city.cty_code = stops.stp_city      
      join company on company.cmp_id = stops.cmp_id
GO
GRANT SELECT ON  [dbo].[OperationsTripViewStopsWithDriverSeating] TO [public]
GO
