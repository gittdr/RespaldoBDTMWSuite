SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

		CREATE VIEW [dbo].[HVLISummaryManagementDetailView]
		AS
    SELECT DISTINCT
      /*** The following columns MUST be present in view. Column names must be identical and are case-sensitive ***/
	  ord.ord_billto 'BillToId'
	  , ord.ord_billto +'-' + ord.ord_shipper 'BillToShipper'
	  /*** END required fields ***/
	  , ord.ord_status 'Status'
	  , ord.ord_hdrnumber 'Order'
	  , ord.ord_consignee 'Landfill'
	  , ord.ord_driver1 'Driver'
	  , ord.ord_tractor 'Tractor'
	  , ord.ord_trailer 'TrailerId'
	  , etapta.eta  'Eta'
	  , etapta.etd  'Pta'
		,   CASE ord.ord_status
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
					WHERE   lgh.ord_hdrnumber   = ord.ord_hdrnumber
						AND s2.stp_mfh_sequence <= (select top 1 stp_mfh_sequence from stops (nolock) where lgh_number = lgh.lgh_number and stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))))
				ELSE 0
			END AS Distance
    FROM orderheader ord (nolock) 
	inner join legheader lgh (nolock) on lgh.ord_hdrnumber   = ord.ord_hdrnumber
	left join opt_eta_pta_stop_state etapta (nolock) on etapta.stop_id = lgh.stp_number_rend    
	inner join company cmp (nolock)on cmp.cmp_id=ord.ord_shipper
	inner join company bt (nolock)on bt.cmp_id=ord.ord_billto	
    where ord.ord_billto in (select ord6.ord_billto from orderheader ord6 where not ord_status in ('job','mst')) 
      and ord_startdate between DATEADD(hour,-18,getDate()) and DATEADD(hour,18,getDate())
		
GO
GRANT INSERT ON  [dbo].[HVLISummaryManagementDetailView] TO [public]
GO
GRANT SELECT ON  [dbo].[HVLISummaryManagementDetailView] TO [public]
GO
GRANT UPDATE ON  [dbo].[HVLISummaryManagementDetailView] TO [public]
GO
