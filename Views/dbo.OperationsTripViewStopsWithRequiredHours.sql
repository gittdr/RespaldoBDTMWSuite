SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[OperationsTripViewStopsWithRequiredHours]     
AS       
      
SELECT	OperationsTripViewDetailsWithRequiredHours.*, stops.stp_number, stops.stp_mfh_sequence, stops.cmp_id, stops.cmp_name, city.cty_nmstct, city.cty_state, stops.stp_zipcode,      
		stops.stp_event, stops.stp_lgh_mileage, stops.stp_arrivaldate, stops.stp_departuredate, stops.stp_schdtearliest, stops.stp_schdtlatest,      
		stops.stp_status, stops.stp_departure_status, stops.ord_hdrnumber, stops.cmd_code, stops.stp_description,   
		IsNull(company.cmp_latseconds, 0)/3600.0 as Latitude, IsNull(company.cmp_longseconds, 0)/3600.0 as Longitude , 
		(SELECT count(DISTINCT ord_hdrnumber) FROM stops (nolock) WHERE stops.lgh_number = OperationsTripViewDetailsWithRequiredHours.lgh_number AND ord_hdrnumber <> 0 ) 'OrdCnt',
		stops.stp_detstatus        
  FROM	OperationsTripViewDetailsWithRequiredHours (nolock) join stops (nolock) on OperationsTripViewDetailsWithRequiredHours.lgh_number = stops.lgh_number      
			INNER JOIN city WITH(NOLOCK) ON city.cty_code = stops.stp_city      
			INNER JOIN company WITH(NOLOCK) ON company.cmp_id = stops.cmp_id
GO
GRANT SELECT ON  [dbo].[OperationsTripViewStopsWithRequiredHours] TO [public]
GO
