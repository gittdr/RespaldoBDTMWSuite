SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE	VIEW [dbo].[CarrierHubCrudeLoadDetailsStopsView] AS
WITH StopGroup AS (
			SELECT	A.mov_number, B.stp_number  [MinStpNumber], C.stp_number  [MaxStpNumber]
			FROM	(
					SELECT		mov_number, cmp_id, MinSeq = MIN(stp_mfh_sequence), MaxSeq = MAX(stp_mfh_sequence)
					FROM		stops
					GROUP BY	mov_number, cmp_id
					) A INNER JOIN
					stops B ON A.mov_number = B.mov_number AND A.MinSeq = B.stp_mfh_sequence INNER JOIN
					stops C ON A.mov_number = C.mov_number AND A.MaxSeq = C.stp_mfh_sequence
			)
select  s1.mov_number [Move Number],
		l.lgh_carrier [Carrier],
		o.ord_number [Order Number],
		l.ord_hdrnumber [Order Header Number],
				s1.stp_number [Stop Number],
              RTRIM(LTRIM(s1.cmp_id)) [Company Id],
              RTRIM(LTRIM(c.cmp_altid)) [Company AltId],
              RTRIM(LTRIM(c.cmp_name)) [Name],
              RTRIM(LTRIM(cty.cty_nmstct)) [City],
              s1.stp_event [Event],
              e1.evt_earlydate [Earliest Date],
              e2.evt_latedate [Latest Date],
              e1.evt_startdate [Arrival Date],
              case when s1.stp_status = 'DNE' then 'Y' else 'N' end [Arrived],
              e2.evt_enddate [Departure Date],
              case when s1.stp_departure_status = 'DNE' then 'Y' else 'N' end [Departed],
			  e2.evt_hubmiles [Hub Miles]
from StopGroup join stops as s1 on s1.stp_number = StopGroup.MinStpNumber
                           join event as e1 on e1.stp_number = StopGroup.MinStpNumber and e1.evt_sequence = 1
                           join stops as s2 on s2.stp_number = StopGroup.MaxStpNumber
                           join event as e2 on e2.stp_number = StopGroup.MinStpNumber and e2.evt_sequence = 1
                           join company as c on c.cmp_id = s1.cmp_id                     
                           join city as cty on cty.cty_code = s1.stp_city 
						   join legheader as l on l.lgh_number = s1.lgh_number
						   join orderheader as o on o.ord_hdrnumber = l.ord_hdrnumber
GO
GRANT SELECT ON  [dbo].[CarrierHubCrudeLoadDetailsStopsView] TO [public]
GO
