SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[OperationsTripViewStopsMPH]       
as       
      
select OperationsTripViewDetailsMPH.*, stops.stp_number, stops.stp_mfh_sequence, stops.cmp_id, stops.cmp_name, city.cty_nmstct, city.cty_state, stops.stp_zipcode,      
  stops.stp_event, stops.stp_lgh_mileage, stops.stp_arrivaldate, stops.stp_departuredate, stops.stp_schdtearliest, stops.stp_schdtlatest,      
  stops.stp_status, stops.stp_departure_status, stops.ord_hdrnumber, stops.cmd_code, stops.stp_description,   
  IsNull(company.cmp_latseconds, 0)/3600.0 as Latitude, IsNull(company.cmp_longseconds, 0)/3600.0 as Longitude , 
  (SELECT count(DISTINCT ord_hdrnumber) FROM stops (nolock) WHERE stops.lgh_number = OperationsTripViewDetailsMPH.lgh_number AND ord_hdrnumber <> 0 ) 'OrdCnt',
  stops.stp_detstatus,
  (select ISNULL((select top 1 stp_schdtearliest from stops (nolock) where mov_number = OperationsTripViewDetailsMPH.mov_number and stp_type = 'PUP' order by stp_mfh_sequence), '1950-01-01 00:00:00')) as PickupEarliest,
  (select ISNULL((select top 1 stp_schdtlatest from stops (nolock) where mov_number = OperationsTripViewDetailsMPH.mov_number and stp_type = 'PUP' order by stp_mfh_sequence), '2049-12-31 23:59:59')) as PickupLatest,
  
  CASE OperationsTripViewDetailsMPH.DispStatus
		WHEN 'STD' THEN --sub mileage calc
				(SELECT CONVERT(Decimal(10,2), SUM(CASE
						    WHEN s1.stp_departure_status = 'OPN' THEN s2.stp_lgh_mileage
							WHEN s1.stp_departure_status = 'DNE' AND s2.stp_status = 'OPN' THEN CASE 
							WHEN co.cmp_id <> 'UNKNOWN' AND ISNULL(co.cmp_latseconds, -1) > 0 AND ISNULL(co.cmp_longseconds, -1) > 0 AND tp.trc_number <> 'UNKNOWN' AND ISNULL(tp.trc_gps_latitude, -1) > 0 AND ISNULL(tp.trc_gps_longitude, -1) > 0 THEN dbo.fnc_AirMilesBetweenLatLongSeconds(tp.trc_gps_latitude, co.cmp_latseconds, tp.trc_gps_longitude, co.cmp_longseconds)
						    WHEN ci.cty_name <> 'UNKNOWN' AND ISNULL(ci.cty_latitude, -1) > 0 AND ISNULL(ci.cty_longitude, -1) > 0 AND tp.trc_number <> 'UNKNOWN' AND ISNULL(tp.trc_gps_latitude, -1) > 0 AND ISNULL(tp.trc_gps_longitude, -1) > 0 THEN dbo.fnc_AirMilesBetweenLatLongSeconds(tp.trc_gps_latitude, ci.cty_latitude * 3600, tp.trc_gps_longitude, ci.cty_longitude * 3600)
                        ELSE s2.stp_lgh_mileage
					        END
                        ELSE 0
                  END))  
			FROM      legheader lgh (nolock)
                  INNER JOIN stops s1 (nolock) ON s1.lgh_number = lgh.lgh_number
                  INNER JOIN stops s2 (nolock) ON s2.lgh_number = lgh.lgh_number AND s2.stp_mfh_sequence = s1.stp_mfh_sequence + 1
                  INNER JOIN company co (nolock) ON co.cmp_id = s2.cmp_id
                  INNER JOIN city ci (nolock) ON ci.cty_code = s2.stp_city
                  INNER JOIN tractorprofile tp (nolock) ON tp.trc_number = lgh.lgh_tractor
			WHERE      lgh.lgh_number = OperationsTripViewDetailsMPH.lgh_number
				AND s2.stp_mfh_sequence <= (select top 1 stp_mfh_sequence from stops (nolock) where lgh_number = lgh.lgh_number and stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))))
		ELSE 0
	END AS AirMiles ,
  
	CASE OperationsTripViewDetailsMPH.DispStatus
		WHEN 'STD' THEN --sub mileage calc
				(SELECT CONVERT(DECIMAL(10,2), SUM(CASE
						    WHEN s1.stp_departure_status = 'OPN' THEN s2.stp_lgh_mileage
							WHEN s1.stp_departure_status = 'DNE' AND s2.stp_status = 'OPN' THEN CASE 
							WHEN co.cmp_id <> 'UNKNOWN' AND ISNULL(co.cmp_latseconds, -1) > 0 AND ISNULL(co.cmp_longseconds, -1) > 0 AND tp.trc_number <> 'UNKNOWN' AND ISNULL(tp.trc_gps_latitude, -1) > 0 AND ISNULL(tp.trc_gps_longitude, -1) > 0 THEN dbo.fnc_AirMilesBetweenLatLongSeconds(tp.trc_gps_latitude, co.cmp_latseconds, tp.trc_gps_longitude, co.cmp_longseconds)
						    WHEN ci.cty_name <> 'UNKNOWN' AND ISNULL(ci.cty_latitude, -1) > 0 AND ISNULL(ci.cty_longitude, -1) > 0 AND tp.trc_number <> 'UNKNOWN' AND ISNULL(tp.trc_gps_latitude, -1) > 0 AND ISNULL(tp.trc_gps_longitude, -1) > 0 THEN dbo.fnc_AirMilesBetweenLatLongSeconds(tp.trc_gps_latitude, ci.cty_latitude * 3600, tp.trc_gps_longitude, ci.cty_longitude * 3600)
                        ELSE s2.stp_lgh_mileage
					        END
                        ELSE 0
                  END) /  ISNULL(NULLIF(((select top 1 DATEDIFF(MI, OperationsTripViewDetailsMPH.GpsLastUpdate, stp_schdtlatest ) from stops (nolock) 
							where lgh_number = OperationsTripViewDetailsMPH.lgh_number and stp_status = 'OPN' 
							AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))) / 60.00 ),0),1))
			FROM      legheader lgh (nolock)
                  INNER JOIN stops s1 (nolock) ON s1.lgh_number = lgh.lgh_number
                  INNER JOIN stops s2 (nolock) ON s2.lgh_number = lgh.lgh_number AND s2.stp_mfh_sequence = s1.stp_mfh_sequence + 1
                  INNER JOIN company co (nolock) ON co.cmp_id = s2.cmp_id
                  INNER JOIN city ci (nolock) ON ci.cty_code = s2.stp_city
                  INNER JOIN tractorprofile tp (nolock) ON tp.trc_number = lgh.lgh_tractor
			WHERE      lgh.lgh_number = OperationsTripViewDetailsMPH.lgh_number
				AND s2.stp_mfh_sequence <= (select top 1 stp_mfh_sequence from stops (nolock) where lgh_number = lgh.lgh_number and stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))))
		ELSE 0
	END AS MPH ,
	
	CASE  OperationsTripViewDetailsMPH.DispStatus
		WHEN 'STD' THEN CONVERT(VARCHAR, (select top 1 DATEDIFF( HOUR, OperationsTripViewDetailsMPH.GpsLastUpdate, stp_schdtlatest ) from stops (nolock) where lgh_number = OperationsTripViewDetailsMPH.lgh_number and stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))) ) + 'H ' +
						CONVERT(VARCHAR, (select top 1 DATEDIFF( MINUTE, OperationsTripViewDetailsMPH.GpsLastUpdate, stp_schdtlatest ) % 60 from stops (nolock) where lgh_number = OperationsTripViewDetailsMPH.lgh_number and stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))) ) + 'M'
		ELSE '0'
	END AS  TimeRemaining,
	
	CASE  OperationsTripViewDetailsMPH.DispStatus
	
		WHEN 'STD' THEN 
		
		CONVERT(VARCHAR, (select top 1 DATEDIFF(HOUR, stops_eta.ste_updated, stops2.stp_schdtlatest) from stops as stops2 (nolock)
		INNER JOIN stops_eta (nolock) ON stops2.stp_number = stops_eta.stp_number
		WHERE stops_eta.ste_updated IS NOT NULL AND stops2.lgh_number = OperationsTripViewDetailsMPH.lgh_number  
		AND stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))))
		 + 'H ' +
		CONVERT(VARCHAR, (select top 1 DATEDIFF( MINUTE, stops_eta.ste_updated, stops2.stp_schdtlatest) % 60 from stops as stops2 (nolock)
		INNER JOIN stops_eta (nolock) ON stops2.stp_number = stops_eta.stp_number
		WHERE stops_eta.ste_updated IS NOT NULL AND stops2.lgh_number = OperationsTripViewDetailsMPH.lgh_number  
		AND stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))))
		+ 'M'
						
		ELSE '0'
	END AS  Delta
  

from OperationsTripViewDetailsMPH (nolock) join stops (nolock) on OperationsTripViewDetailsMPH.lgh_number = stops.lgh_number      
      join city (nolock) on city.cty_code = stops.stp_city      
      join company (nolock) on company.cmp_id = stops.cmp_id
GO
GRANT SELECT ON  [dbo].[OperationsTripViewStopsMPH] TO [public]
GO
