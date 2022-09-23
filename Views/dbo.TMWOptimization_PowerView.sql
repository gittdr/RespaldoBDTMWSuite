SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE VIEW [dbo].[TMWOptimization_PowerView] AS 

SELECT	trc_number AS ResourceID,
		trc_avl_lgh AS lgh_number,
		trc_avl_date AS AvlDate,
		trc_avl_city AS AvlCity,
		tractorprofile.trc_fleet AS Fleet,
		tractorprofile.trc_division AS Division,
		trc_mpg AS MPG,
		trc_driver AS Driver1,
		trc_driver2 AS Driver2,
		trc_tank_capacity AS TankCapacity,
		trc_gal_in_tank AS GalInTank,
		trc_tareweight AS Tareweight,
		trc_gps_latitude AS Latitude,
		trc_gps_longitude AS Longitude,
		trc_gps_desc AS GPSDesc,
		trc_gps_date AS GPSDate,
		trc_make AS Make,
		tractorprofile.trc_terminal AS Terminal,
		trc_retiredate AS RetireDate,
		trc_optimizationdate AS OptimizationDate
  FROM	tractorprofile WITH (NOLOCK) 
 WHERE	trc_number <> 'UNKNOWN'
   AND	trc_optimizationdate IS NOT NULL

UNION ALL

SELECT	lgh.lgh_carrier + '|' + CAST(lgh.lgh_number AS varchar(20)) AS ResourceID,
		lgh.lgh_number,
		AvlDate = lgh.lgh_enddate,
		AvlCity = lgh.lgh_endcity,
		NULL AS Fleet,
		NULL AS Division,
		NULL AS MPG,
		NULL AS Driver1,
		NULL AS Driver2,
		NULL AS TankCapacity,
		NULL AS GalInTank,
		NULL AS Tareweight,
		ckc_latseconds AS Latitude,
		ckc_longseconds AS Longitude,
		ckc_comment AS GPSDesc,
		ckc_date AS GPSDate,
		NULL AS Make,
		NULL AS Terminal,
		NULL AS RetireDate,
		CASE
			WHEN lgh.lgh_optimizationdate > ISNULL(ckc_updatedon, '19500101') AND lgh.lgh_optimizationdate > ISNULL(stop.stp_optimizationdate, '19500101')  THEN lgh.lgh_optimizationdate
			WHEN stop.stp_optimizationdate > ISNULL(ckc_updatedon, '19500101') AND stop.stp_optimizationdate > ISNULL(lgh.lgh_optimizationdate, '19500101') THEN stop.stp_optimizationdate
			ELSE ISNULL(ckc_updatedon, '19500101')
		END AS OptimizationDate
  FROM	carrier WITH (NOLOCK)
			INNER JOIN legheader_active lgha WITH (NOLOCK) ON lgha.lgh_carrier = carrier.car_id
			INNER JOIN legheader lgh WITH (NOLOCK) ON lgh.lgh_number = lgha.lgh_number
			OUTER APPLY (SELECT	TOP 1 
								ckc_latseconds, 
								ckc_longseconds, 
								ckc_comment, 
								ckc_date,
								ckc_updatedon 
						   FROM	checkcall WITH (NOLOCK) 
						  WHERE	ckc_lghnumber = lgha.lgh_number ORDER BY ckc_updatedon DESC) checkcall
			OUTER APPLY (SELECT MAX(stp_optimizationdate) stp_optimizationdate
						   FROM	stops WITH (NOLOCK)
						  WHERE lgh_number = lgha.lgh_number) stop
 WHERE	car_id <> 'UNKNOWN'
   AND	lgha.lgh_outstatus IN ('PLN','STD')
   AND	carrier.car_board = 'N'
   AND	lgh.lgh_optimizationdate IS NOT NULL

GO
GRANT SELECT ON  [dbo].[TMWOptimization_PowerView] TO [public]
GO
