SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[EtaPtaStopStateView]
AS
SELECT	s.stp_event 'Event',
		s.cmp_id 'Company ID',
		s.cmp_name 'Company Name',
		ci.cty_nmstct 'City',
		s.stp_zipcode 'Postal',
		CASE 
			WHEN ISNULL(ss.stop_id, -1) = -1 THEN s.stp_arrivaldate
			ELSE ss.eta
		END 'Arrival',
		CASE 
			WHEN ISNULL(ss.stop_id, -1) = -1 THEN s.stp_departuredate
			ELSE ss.etd
		END 'Departure',
		s.stp_schdtearliest 'Earliest',
		s.stp_schdtlatest 'Latest',
		ss.is_late 'Late',
		ss.hours_late 'Hours Late',
		ss.delay 'Delay',
		s.stp_mfh_sequence 'Sequence',
		CASE
			WHEN s.cmp_id = 'UNKNOWN' THEN CASE WHEN ci.cty_latitude > 180 THEN ci.cty_latitude / 3600.0 ELSE ci.cty_latitude END
			ELSE co.cmp_latseconds / 3600.0
		END 'Latitude',
		CASE
			WHEN s.cmp_id = 'UNKNOWN' THEN CASE WHEN ci.cty_longitude > 180 THEN ci.cty_longitude / 3600.0 ELSE ci.cty_longitude END
			ELSE co.cmp_longseconds / 3600.0
		END 'Longitude',
		s.stp_number,
		s.lgh_number,
		s.mov_number,
		oh.ord_number
  FROM	stops s
			LEFT OUTER JOIN opt_eta_pta_stop_state ss ON ss.stop_id = s.stp_number
			LEFT OUTER JOIN city ci ON ci.cty_code = s.stp_city
			LEFT OUTER JOIN company co ON co.cmp_id = s.cmp_id
			LEFT OUTER JOIN orderheader oh ON oh.ord_hdrnumber = s.ord_hdrnumber
GO
GRANT SELECT ON  [dbo].[EtaPtaStopStateView] TO [public]
GO
