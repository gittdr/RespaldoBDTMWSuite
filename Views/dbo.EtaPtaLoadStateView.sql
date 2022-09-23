SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[EtaPtaLoadStateView]
AS
SELECT	lgh.lgh_number 'Leg',
		oh.ord_number 'Order',
		ls.hours_late 'Hours Late',
		ls.hours_until_pickup_late 'Hour Until PU Late',
		ls.is_late_for_any_stop 'Late Any Stop',
		ls.total_delay 'Total Delay',
		ISNULL(RTRIM(ls.first_pickup_city), 'UNKNOWN') + ', ' + ISNULL(RTRIM(ls.first_pickup_state), 'UNK') 'Pickup City',
		first_pickup_postal 'Pickup Postal',
		eta_to_first_pickup 'Pickup ETA',
		ISNULL(RTRIM(ls.last_delivery_city), 'UNKNOWN') + ', ' + ISNULL(RTRIM(ls.last_delivery_state), 'UNK') 'Delivery City',
		last_delivery_postal 'Delivery Postal',
		etd_from_last_delivery 'Delivery ETD',
		lgh.lgh_tractor 'Tractor',
		lgh.lgh_driver1 'Driver 1',
		lgh.lgh_driver2 'Driver 2',
		lgh.lgh_primary_trailer 'Trailer 1',
		lgh.lgh_primary_pup 'Trailer 2',
		lgh.lgh_carrier 'Carrier',
		ls.i_pta 'iPTA', 
		ISNULL(RTRIM(ls.i_pta_city), 'UNKNOWN') + ', ' + ISNULL(RTRIM(ls.i_pta_state), 'UNK') 'iPTA City',
		ls.i_pta_postal 'iPTA Postal',
		CASE WHEN lgh.lgh_driver1 = 'UNKNOWN' THEN NULL ELSE LTRIM(STR(ls.driver_1_hours_remaining_on_day_drive_at_i_pta, 4, 1)) + '/' + LTRIM(STR(ls.driver_1_hours_remaining_on_day_duty_at_i_pta, 4, 1)) + '/' + LTRIM(STR(ls.driver_1_hours_remaining_on_week_at_i_pta, 4, 1)) END 'Driver 1 Hours @ iPTA',
		CASE WHEN lgh.lgh_driver2 = 'UNKNOWN' THEN NULL ELSE LTRIM(STR(ls.driver_2_hours_remaining_on_day_drive_at_i_pta, 4, 1)) + '/' + LTRIM(STR(ls.driver_2_hours_remaining_on_day_duty_at_i_pta, 4, 1)) + '/' + LTRIM(STR(ls.driver_2_hours_remaining_on_week_at_i_pta, 4, 1)) END 'Driver 2 Hours @ iPTA',
		rule_set 'Hours Rule',
		ls.updated 'Last Updated'
  FROM	opt_eta_pta_load_state ls
			INNER JOIN legheader lgh ON lgh.lgh_number = ls.load_id
			LEFT OUTER JOIN orderheader oh ON oh.ord_hdrnumber = lgh.ord_hdrnumber
GO
GRANT SELECT ON  [dbo].[EtaPtaLoadStateView] TO [public]
GO
