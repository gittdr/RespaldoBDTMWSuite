SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create view [dbo].[TMWScrollTractorViewMPH] AS
SELECT 
trc_number, 
trc_type1,
trc_driver,
trc_status,
trc_company,
trc_terminal,
trc_division,
trc_owner,
trc_fleet,
ISNULL(trc_licstate, '') as trc_licstate,
ISNULL(trc_licnum, '') as trc_licnum,
ISNULL(trc_serial, '') as trc_serial,
ISNULL(trc_model, '') as trc_model,  
ISNULL(trc_make, '') as trc_make, 
ISNULL(trc_year, 0) as trc_year, 
trc_type2,
trc_type3,
trc_type4,
trc_misc1,
trc_misc2,
trc_misc3,
trc_misc4,
PlannedCity.cty_nmstct, 
AvailableCity.cty_state,
AvailableCity.cty_zip, 
AvailableCity.cty_county, 
trc_avl_cmp_id,
trc_prior_region1,
trc_prior_region2,
trc_prior_region3,
trc_prior_region4,
trc_gps_latitude,
trc_gps_longitude,
trc_gps_date,
trc_gps_desc,
ISNULL(trc_exp1_date,'12/31/49') as 'trc_exp1_date',
ISNULL(trc_exp2_date,'12/31/49') as 'trc_exp2_date',

CASE trc_status
	WHEN 'USE' THEN
			(SELECT CONVERT(Decimal(10,2), SUM(CASE
						    WHEN s1.stp_departure_status = 'OPN' THEN s2.stp_lgh_mileage
							WHEN s1.stp_departure_status = 'DNE' AND s2.stp_status = 'OPN' THEN CASE 
							WHEN co.cmp_id <> 'UNKNOWN' AND ISNULL(co.cmp_latseconds, -1) > 0 AND ISNULL(co.cmp_longseconds, -1) > 0 AND trc_number <> 'UNKNOWN' AND ISNULL(tp.trc_gps_latitude, -1) > 0 AND ISNULL(tp.trc_gps_longitude, -1) > 0 THEN dbo.fnc_AirMilesBetweenLatLongSeconds(tp.trc_gps_latitude, co.cmp_latseconds, tp.trc_gps_longitude, co.cmp_longseconds)
						    WHEN ci.cty_name <> 'UNKNOWN' AND ISNULL(ci.cty_latitude, -1) > 0 AND ISNULL(ci.cty_longitude, -1) > 0 AND trc_number <> 'UNKNOWN' AND ISNULL(tp.trc_gps_latitude, -1) > 0 AND ISNULL(tp.trc_gps_longitude, -1) > 0 THEN dbo.fnc_AirMilesBetweenLatLongSeconds(tp.trc_gps_latitude, ci.cty_latitude * 3600, tp.trc_gps_longitude, ci.cty_longitude * 3600)
                        ELSE s2.stp_lgh_mileage
					        END
                        ELSE 0
                  END))  
			FROM      legheader lgh
                  INNER JOIN stops s1 ON s1.lgh_number = lgh.lgh_number
                  INNER JOIN stops s2 ON s2.lgh_number = lgh.lgh_number AND s2.stp_mfh_sequence = s1.stp_mfh_sequence + 1
                  INNER JOIN company co ON co.cmp_id = s2.cmp_id
                  INNER JOIN city ci ON ci.cty_code = s2.stp_city
                  INNER JOIN tractorprofile tp ON tp.trc_number = lgh.lgh_tractor
			WHERE      lgh.lgh_number = tractorprofile.trc_pln_lgh
				AND s2.stp_mfh_sequence <= (select top 1 stp_mfh_sequence from stops where stops.lgh_number = lgh.lgh_number and stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))))
	ELSE 0
END AS MilesToNextBillableStop,

CASE trc_status
	WHEN 'USE' THEN --sub mileage calc
				(SELECT CONVERT(DECIMAL(10,2), SUM(CASE
						    WHEN s1.stp_departure_status = 'OPN' THEN s2.stp_lgh_mileage
							WHEN s1.stp_departure_status = 'DNE' AND s2.stp_status = 'OPN' THEN CASE 
							WHEN co.cmp_id <> 'UNKNOWN' AND ISNULL(co.cmp_latseconds, -1) > 0 AND ISNULL(co.cmp_longseconds, -1) > 0 AND tp.trc_number <> 'UNKNOWN' AND ISNULL(tp.trc_gps_latitude, -1) > 0 AND ISNULL(tp.trc_gps_longitude, -1) > 0 THEN dbo.fnc_AirMilesBetweenLatLongSeconds(tp.trc_gps_latitude, co.cmp_latseconds, tp.trc_gps_longitude, co.cmp_longseconds)
						    WHEN ci.cty_name <> 'UNKNOWN' AND ISNULL(ci.cty_latitude, -1) > 0 AND ISNULL(ci.cty_longitude, -1) > 0 AND tp.trc_number <> 'UNKNOWN' AND ISNULL(tp.trc_gps_latitude, -1) > 0 AND ISNULL(tp.trc_gps_longitude, -1) > 0 THEN dbo.fnc_AirMilesBetweenLatLongSeconds(tp.trc_gps_latitude, ci.cty_latitude * 3600, tp.trc_gps_longitude, ci.cty_longitude * 3600)
                        ELSE s2.stp_lgh_mileage
					        END
                        ELSE 0
                  END) /  ((select top 1 DATEDIFF(MI, tractorprofile.trc_gps_date, stp_schdtearliest ) from stops where lgh_number = tractorprofile.trc_pln_lgh and stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))) / 60.00 ))
			FROM      legheader lgh
                  INNER JOIN stops s1 ON s1.lgh_number = lgh.lgh_number
                  INNER JOIN stops s2 ON s2.lgh_number = lgh.lgh_number AND s2.stp_mfh_sequence = s1.stp_mfh_sequence + 1
                  INNER JOIN company co ON co.cmp_id = s2.cmp_id
                  INNER JOIN city ci ON ci.cty_code = s2.stp_city
                  INNER JOIN tractorprofile tp ON tp.trc_number = lgh.lgh_tractor
			WHERE      lgh.lgh_number = tractorprofile.trc_pln_lgh
				AND s2.stp_mfh_sequence <= (select top 1 stp_mfh_sequence from stops where lgh_number = lgh.lgh_number and stp_status = 'OPN' AND (stp_type in ('PUP', 'DRP') or stp_event in ('HLT', 'HCT', 'DLT', 'XDU', 'XDL'))))
		ELSE 0
	END AS MPH 


FROM dbo.tractorprofile (NOLOCK) LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON dbo.tractorprofile.trc_avl_city = AvailableCity.cty_code 
					    LEFT OUTER JOIN dbo.city PlannedCity (NOLOCK) ON dbo.tractorprofile.trc_pln_city = PlannedCity.cty_code 
						

GO
GRANT SELECT ON  [dbo].[TMWScrollTractorViewMPH] TO [public]
GO
