SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE VIEW [dbo].[TMWOptimization_LoadView] AS 
SELECT	CASE 
			WHEN ISNULL(c.car_id, 'UNKNOWN') <> 'UNKNOWN' THEN c.car_id + '|' + CAST(s.lgh_number as varchar(20))
			ELSE e.evt_tractor
		END AS ResourceID, 
		MAX(CASE
				WHEN ISNULL(l.lgh_optimizationdate, '19500101') > s.stp_optimizationdate THEN l.lgh_optimizationdate
				ELSE s.stp_optimizationdate
			END) AS OptimizationDate,
		s.lgh_number
  FROM	stops s WITH (NOLOCK)
			INNER JOIN event e WITH (NOLOCK) ON e.stp_number = s.stp_number AND e.evt_sequence = 1
			LEFT OUTER JOIN legheader l WITH (NOLOCK) ON l.lgh_number = s.lgh_number
			LEFT OUTER JOIN carrier c WITH (NOLOCK) ON  c.car_id = e.evt_carrier AND c.car_board = 'N'
 WHERE	s.stp_optimizationdate IS NOT NULL
GROUP BY s.lgh_number, CASE 
						   WHEN ISNULL(c.car_id, 'UNKNOWN') <> 'UNKNOWN' THEN c.car_id + '|' + CAST(s.lgh_number as varchar(20))
						   ELSE e.evt_tractor
					   END 
GO
GRANT SELECT ON  [dbo].[TMWOptimization_LoadView] TO [public]
GO
