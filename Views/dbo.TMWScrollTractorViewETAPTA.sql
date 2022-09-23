SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollTractorViewETAPTA] AS
SELECT	ISNULL(tp.trc_number, 'UNKNOWN') trc_number, 
		CASE WHEN PowerState.Driver_1_ID = '' THEN 'UNKNOWN' ELSE ISNULL(PowerState.Driver_1_ID, 'UNKNOWN') END trc_driver,
		CASE WHEN PowerState.Driver_2_ID = '' THEN 'UNKNOWN' ELSE ISNULL(PowerState.Driver_2_ID, 'UNKNOWN') END trc_driver2,
		ISNULL(lgh.lgh_carrier, 'UNKNOWN') Carrier,
		lgh.lgh_number 'Leg',
		lgh.mov_number 'Move',
		oh.ord_number 'Order',
		ISNULL(CASE
				   WHEN ISNULL(PowerState.current_dispatched_load_id, 0) > 0 THEN CONVERT(BIT, 1)
				   ELSE CONVERT(BIT, 0)
			   END, CONVERT(BIT, 0)) 'Dispatched',
		PowerState.hours_late 'Hrs Late',
		PowerState.is_late_for_any_stop 'Late Any',
		PowerState.pta 'PTA',
		CASE 
			WHEN ISNULL(RTRIM(PowerState.pta_city), '') = '' THEN 'UNKNOWN' 
			ELSE RTRIM(PowerState.pta_city) 
		END + ', ' + 
		CASE 
			WHEN ISNULL(PowerState.pta_state, '') = '' THEN 'UNK' 
			ELSE PowerState.pta_state 
		END 'PTA City',
		PowerState.pta_postal 'PTA Postal',
		CASE WHEN ISNULL(PowerState.Driver_1_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_1_ID = ''  THEN NULL ELSE LTRIM(STR(PowerState.driver_1_hours_remaining_on_day_drive, 4, 1)) + '/' + LTRIM(STR(PowerState.driver_1_hours_remaining_on_day_duty, 4, 1)) + '/' + LTRIM(STR(PowerState.driver_1_hours_remaining_on_week, 4, 1)) END 'D1 Hrs',
		CASE WHEN ISNULL(PowerState.Driver_2_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_1_ID = ''  THEN NULL ELSE LTRIM(STR(PowerState.driver_2_hours_remaining_on_day_drive, 4, 1)) + '/' + LTRIM(STR(PowerState.driver_2_hours_remaining_on_day_duty, 4, 1)) + '/' + LTRIM(STR(PowerState.driver_2_hours_remaining_on_week, 4, 1)) END 'D2 Hrs',
		CASE WHEN ISNULL(PowerState.Driver_1_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_1_ID = ''  THEN NULL ELSE LTRIM(STR(PowerState.driver_1_hours_remaining_day_drive_at_pta, 4, 1)) + '/' + LTRIM(STR(PowerState.driver_1_hours_remaining_day_duty_at_pta, 4, 1)) + '/' + LTRIM(STR(PowerState.driver_1_hours_remaining_week_at_pta, 4, 1)) END 'D1 Hrs @PTA',
		CASE WHEN ISNULL(PowerState.Driver_2_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_1_ID = ''  THEN NULL ELSE LTRIM(STR(PowerState.driver_2_hours_remaining_day_drive_at_pta, 4, 1)) + '/' + LTRIM(STR(PowerState.driver_2_hours_remaining_day_duty_at_pta, 4, 1)) + '/' + LTRIM(STR(PowerState.driver_2_hours_remaining_week_at_pta, 4, 1)) END 'D2 Hrs @PTA',
		CASE WHEN ISNULL(PowerState.Driver_1_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_1_ID = ''  THEN NULL ELSE PowerState.driver_1_is_home END 'D1 Home',
		CASE WHEN ISNULL(PowerState.Driver_1_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_1_ID = ''  THEN NULL ELSE PowerState.driver_1_miles_to_home END 'D1 Miles Home',
		CASE WHEN ISNULL(PowerState.Driver_1_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_1_ID = ''  THEN NULL ELSE PowerState.driver_1_is_home_at_pta END 'D1 Home @PTA',
		CASE WHEN ISNULL(PowerState.Driver_1_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_1_ID = ''  THEN NULL ELSE PowerState.driver_1_miles_to_home_at_pta END 'D1 Miles Home @PTA',
		CASE WHEN ISNULL(PowerState.Driver_2_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_2_ID = ''  THEN NULL ELSE PowerState.driver_2_is_home END 'D2 Home',
		CASE WHEN ISNULL(PowerState.Driver_2_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_2_ID = ''  THEN NULL ELSE PowerState.driver_2_miles_to_home END 'D2 Miles Home',
		CASE WHEN ISNULL(PowerState.Driver_2_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_2_ID = ''  THEN NULL ELSE PowerState.driver_2_is_home_at_pta END 'D2 Home @PTA',
		CASE WHEN ISNULL(PowerState.Driver_2_ID, 'UNKNOWN') = 'UNKNOWN' OR PowerState.Driver_2_ID = ''  THEN NULL ELSE PowerState.driver_2_miles_to_home_at_pta END 'D2 Miles Home @PTA',
		ISNULL(tp.trc_gps_latitude, CASE WHEN AvailableCity.cty_latitude < 180 THEN AvailableCity.cty_latitude * 3600.0 ELSE AvailableCity.cty_latitude END)/3600.0 trc_gps_latitude,
		ISNULL(tp.trc_gps_longitude, CASE WHEN AvailableCity.cty_longitude < 180 THEN AvailableCity.cty_longitude * 3600.0 ELSE AvailableCity.cty_longitude END)/3600.0 trc_gps_longitude,
		CASE 
			WHEN ISNULL(PowerState.hours_late, 0.0) > 0.0 THEN 'MEDIUM_TRACTOR_RED' 
			WHEN ISNULL(PowerState.is_late_for_any_stop, 0) = 1 THEN 'MEDIUM_TRACTOR_YELLOW' 
			WHEN ISNULL(PowerState.current_dispatched_load_id, 0) = 0 THEN 'MEDIUM_TRACTOR_BLUE' 
			ELSE 'MEDIUM_TRACTOR_GREEN' 
		END As trc_icon,
		tp.trc_number power_name,
		'Tractor: ' + tp.trc_number + '    ' +
				CASE
					WHEN ISNULL(lgh.lgh_number, 0) = 0 THEN '' 
					WHEN ISNULL(oh.ord_number, '') = '' THEN 'Leg #: ' + CAST(lgh.lgh_number AS VARCHAR(10))
					ELSE 'Order #: ' + oh.ord_number
				END + 
				CASE 
					WHEN ISNULL(PowerState.Driver_1_ID, '') <> '' THEN CASE 
																		   WHEN ISNULL(PowerState.Driver_2_ID, '') <> '' THEN '</br>' + 'Driver 1: ' + PowerState.Driver_1_ID + '    Driver 2: ' + PowerState.Driver_2_ID
																		   ELSE '</br>' + 'Driver 1: ' + PowerState.Driver_1_ID
																	   END
					ELSE ''
				END +
				CASE 
					WHEN ISNULL(lgh.lgh_number, 0) = 0 THEN ''
					ELSE '</br>' + 'Hours Late: ' + STR(PowerState.hours_late, 4, 1) + '    Late Any:' + CASE WHEN ISNULL(PowerState.is_late_for_any_stop, 0) = 0 THEN  'N' ELSE 'Y' END
				END	power_info,
		PowerState.last_ping_date,
		tp.trc_type1,
		tp.trc_status,
		tp.trc_company,
		tp.trc_terminal,
		tp.trc_division,
		tp.trc_owner,
		tp.trc_fleet,
		tp.trc_licstate,
		tp.trc_licnum,
		tp.trc_serial,
		tp.trc_model,  
		tp.trc_make, 
		tp.trc_year, 
		tp.trc_type2,
		tp.trc_type3,
		tp.trc_type4,
		tp.trc_misc1,
		tp.trc_misc2,
		tp.trc_misc3,
		tp.trc_misc4,
		AvailableCity.cty_nmstct, 
		AvailableCity.cty_state,
		AvailableCity.cty_zip, 
		AvailableCity.cty_county, 
		tp.trc_avl_cmp_id,
		tp.trc_prior_region1,
		tp.trc_prior_region2,
		tp.trc_prior_region3,
		tp.trc_prior_region4,
		tp.trc_exp1_date,
		tp.trc_exp2_date,
		PowerState.hos_source
  FROM	tractorprofile tp WITH(NOLOCK)
			LEFT OUTER JOIN opt_eta_pta_power_state PowerState WITH(NOLOCK) ON PowerState.power_id = tp.trc_number
			LEFT OUTER JOIN dbo.city AvailableCity WITH(NOLOCK) ON AvailableCity.cty_code = tp.trc_avl_city
			LEFT OUTER JOIN dbo.city PlannedCity WITH(NOLOCK) ON PlannedCity.cty_code = tp.trc_pln_city
			LEFT OUTER JOIN dbo.legheader lgh WITH(NOLOCK) ON lgh.lgh_number = PowerState.current_dispatched_load_id 
			LEFT OUTER JOIN dbo.orderheader oh WITH(NOLOCK) ON oh.ord_hdrnumber = lgh.ord_hdrnumber
			LEFT OUTER JOIN carrier car ON car.car_id = PowerState.car_id
 WHERE	tp.trc_retiredate > GETDATE()			
UNION
SELECT	'UNKNOWN' trc_number, 
		'UNKNOWN' trc_driver,
		'UNKNOWN' trc_driver2,
		lgh.lgh_carrier Carrier,
		lgh.lgh_number 'Leg',
		lgh.mov_number 'Move',
		oh.ord_number 'Order',
		PowerState.is_dispatched 'Dispatched',
		PowerState.hours_late 'Hrs Late',
		PowerState.is_late_for_any_stop 'Late Any',
		PowerState.pta 'PTA',
		CASE 
			WHEN ISNULL(RTRIM(PowerState.pta_city), '') = '' THEN 'UNKNOWN' 
			ELSE RTRIM(PowerState.pta_city) 
		END + ', ' + 
		CASE 
			WHEN ISNULL(PowerState.pta_state, '') = '' THEN 'UNK' 
			ELSE PowerState.pta_state 
		END 'PTA City',
		PowerState.pta_postal 'PTA Postal',
		NULL 'D1 Hrs',
		NULL 'D2 Hrs',
		NULL 'D1 Hrs @PTA',
		NULL 'D2 Hrs @PTA',
		NULL 'D1 Home',
		NULL 'D1 Miles Home',
		NULL 'D1 Home @PTA',
		NULL 'D1 Miles Home @PTA',
		NULL 'D2 Home',
		NULL 'D2 Miles Home',
		NULL 'D2 Home @PTA',
		NULL 'D2 Miles Home @PTA',
		(SELECT TOP 1 ckc_latseconds/3600.0 FROM checkcall WHERE lgh_number = PowerState.current_dispatched_load_id order by ckc_date desc) trc_gps_latitude,
		(SELECT TOP 1 ckc_longseconds/3600.0 FROM checkcall WHERE lgh_number = PowerState.current_dispatched_load_id order by ckc_date desc) trc_gps_longitude,
		CASE 
			WHEN PowerState.hours_late > 0.0 THEN 'MEDIUM_TRACTOR_RED' 
			WHEN PowerState.is_late_for_any_stop = 1 THEN 'MEDIUM_TRACTOR_YELLOW' 
			WHEN PowerState.is_dispatched = 0 THEN 'MEDIUM_TRACTOR_BLUE' 
			ELSE 'MEDIUM_TRACTOR_GREEN' 
		END As trc_icon,
		lgh.lgh_carrier + CASE 
							  WHEN ISNULL(oh.ord_number, '') = '' THEN CAST(lgh.lgh_number AS VARCHAR(10))
							  ELSE oh.ord_number
						  END power_name,
		'Carrier: ' + lgh.lgh_carrier + '    ' + 
				CASE 
					WHEN ISNULL(lgh.lgh_number, 0) = 0 THEN ''
					WHEN ISNULL(oh.ord_number, '') = '' THEN 'Leg #: ' + CAST(lgh.lgh_number AS VARCHAR(10))
					ELSE 'Order #: ' + oh.ord_number
				END + 
				CASE 
					WHEN ISNULL(lgh.lgh_number, 0) = 0 THEN ''
					ELSE '</br>' + 'Hours Late: ' + STR(PowerState.hours_late, 4, 1) + '    Late Any:' + CASE WHEN ISNULL(PowerState.is_late_for_any_stop, 0) = 0 THEN  'N' ELSE 'Y' END
				END	power_info,
		PowerState.last_ping_date,
		car.car_type1 trc_type1,
		'PLN' trc_status,
		NULL trc_company,
		NULL trc_terminal,
		NULL trc_division,
		NULL trc_owner,
		NULL trc_fleet,
		NULL trc_licstate,
		NULL trc_licnum,
		NULL trc_serial,
		NULL trc_model,  
		NULL trc_make, 
		NULL trc_year, 
		car.car_type2 trc_type2,
		car.car_type3 trc_type3,
		car.car_type4 trc_type4,
		car.car_misc1 trc_misc1,
		car.car_misc2 trc_misc2,
		car.car_misc3 trc_misc3,
		car.car_misc4 trc_misc4,
		NULL cty_nmstct, 
		NULL cty_state,
		NULL cty_zip, 
		NULL cty_county, 
		NULL trc_avl_cmp_id,
		NULL trc_prior_region1,
		NULL trc_prior_region2,
		NULL trc_prior_region3,
		NULL trc_prior_region4,
		car.car_exp1_date trc_exp1_date,
		car.car_exp2_date trc_exp2_date,
		PowerState.hos_source
  FROM	opt_eta_pta_power_state PowerState WITH(NOLOCK)
			INNER JOIN carrier car ON car.car_id = PowerState.car_id
			LEFT OUTER JOIN dbo.legheader lgh WITH(NOLOCK) ON lgh.lgh_number = PowerState.current_dispatched_load_id 
			LEFT OUTER JOIN dbo.orderheader oh WITH(NOLOCK) ON oh.ord_hdrnumber = lgh.ord_hdrnumber
 WHERE	car.car_id <> 'UNKNOWN' AND car.car_board = 'N'
   AND	EXISTS(SELECT 1 FROM checkcall WHERE lgh_number = PowerState.current_dispatched_load_id)
   AND	PowerState.power_id LIKE '%|%'
GO
GRANT DELETE ON  [dbo].[TMWScrollTractorViewETAPTA] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollTractorViewETAPTA] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollTractorViewETAPTA] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollTractorViewETAPTA] TO [public]
GO
