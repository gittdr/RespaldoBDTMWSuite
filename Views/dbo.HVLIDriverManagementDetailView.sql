SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

		CREATE VIEW [dbo].[HVLIDriverManagementDetailView]
		AS
		SELECT distinct mpp.mpp_id 'DriverId'
			, ord.ord_status 'OrderStatus'
			, ord.ord_hdrnumber 'OrderNumber'
			, ord.ord_shipper 'Shipper'
			, ord.ord_consignee 'Consignee'
			, lgh.lgh_tractor 'Tractor'
			, lgh.lgh_primary_trailer 'Trailer'
			, etapta.eta  'ETA'
			, etapta.etd  'PTA'
			, CASE ord.ord_status
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
					WHERE lgh.ord_hdrnumber   = ord.ord_hdrnumber
					  AND s2.stp_mfh_sequence <= (select top 1 stp_mfh_sequence from stops (nolock) where lgh_number = lgh.lgh_number and stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))))
				ELSE 0
			END AS Distance

		FROM legheader lgh
		join manpowerprofile mpp (nolock) on mpp.mpp_id = lgh.lgh_driver1
		left join opt_eta_pta_stop_state etapta (nolock) on etapta.stop_id = lgh.stp_number_rend
		left join orderheader ord (nolock) on ord.mov_number=lgh.mov_number
		WHERE ((mpp.mpp_status <> 'OUT' and mpp.mpp_id <> 'UNKNOWN')) 
	      and lgh_outstatus <> 'CMP' and ord_startdate between DATEADD(hour,-18,getDate()) and DATEADD(hour,18,getDate())
		
GO
GRANT INSERT ON  [dbo].[HVLIDriverManagementDetailView] TO [public]
GO
GRANT SELECT ON  [dbo].[HVLIDriverManagementDetailView] TO [public]
GO
GRANT UPDATE ON  [dbo].[HVLIDriverManagementDetailView] TO [public]
GO
