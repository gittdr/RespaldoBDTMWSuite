SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[OperationsInboundViewWithEtaPta]      
AS      
SELECT	ib.*,
		(SELECT TOP 1 ss.hours_late
		   FROM	opt_eta_pta_stop_state ss
					INNER JOIN stops s ON s.stp_number = ss.stop_id
		  WHERE	s.lgh_number = ib.lgh_number
		    AND	(s.stp_type = 'DRP' OR s.stp_event IN ('DLT', 'XDU')) ORDER BY ss.sequence DESC) HoursLate,
		--ls.hours_late HoursLate,
		ls.is_late_for_any_stop LateForAny,
		ls.hours_until_pickup_late HoursUntilPickupLate,
		CASE 
			WHEN ISNULL(RTRIM(ls.first_pickup_city), '') = '' THEN 'UNKNOWN' 
			ELSE RTRIM(ls.first_pickup_city) 
		END + ', ' + 
		CASE 
			WHEN ISNULL(ls.first_pickup_state, '') = '' THEN 'UNK' 
			ELSE ls.first_pickup_state 
		END FirstPickupCity,
		ls.first_pickup_postal FirstPickupPostal,
		ls.eta_to_first_pickup FirstPickupETA,
		CASE 
			WHEN ISNULL(RTRIM(ls.last_delivery_city), '') = '' THEN 'UNKNOWN' 
			ELSE RTRIM(ls.last_delivery_city) 
		END + ', ' + 
		CASE 
			WHEN ISNULL(ls.last_delivery_state, '') = '' THEN 'UNK' 
			ELSE ls.last_delivery_state 
		END LastDeliveryCity,
		ls.last_delivery_postal LastDeliveryPostal,
		ls.etd_from_last_delivery LastDeliveryETD,
		CASE 
			WHEN ISNULL(RTRIM(ls.i_pta_city), '') = '' THEN 'UNKNOWN' 
			ELSE RTRIM(ls.i_pta_city) 
		END + ', ' + 
		CASE 
			WHEN ISNULL(ls.i_pta_state, '') = '' THEN 'UNK' 
			ELSE ls.i_pta_state 
		END iPTACity,
		ls.i_pta_postal iPTAPostal,
		ls.i_pta iPTA,
		CASE 
			WHEN ISNULL(ps.car_id, '') = '' THEN
				CASE 
					WHEN ISNULL(RTRIM(ps.pta_city), '') = '' THEN 'UNKNOWN' 
					ELSE RTRIM(ps.pta_city) 
				END + ', ' + 
				CASE 
					WHEN ISNULL(ps.pta_state, '') = '' THEN 'UNK' 
					ELSE ps.pta_state 
				END
			ELSE
				CASE 
					WHEN ISNULL(RTRIM(ls.i_pta_city), '') = '' THEN 'UNKNOWN' 
					ELSE RTRIM(ls.i_pta_city) 
				END + ', ' + 
				CASE 
					WHEN ISNULL(ls.i_pta_state, '') = '' THEN 'UNK' 
					ELSE ls.i_pta_state 
				END
		END PTACity,
		CASE 
			WHEN ISNULL(ps.car_id, '') = '' THEN ps.pta_postal
			ELSE ls.i_pta_postal	
		END PTAPostal,
		CASE 
			WHEN ISNULL(ps.car_id, '') = '' THEN ps.pta
			ELSE ls.i_pta
		END PTA,
		ls.total_delay TotalDelay,
		STR(ROUND(ls.driver_1_hours_remaining_on_day_drive_at_i_pta, 1), 4, 1) + '/' + STR(ROUND(ls.driver_1_hours_remaining_on_day_duty_at_i_pta, 1), 4, 1) + '/' + STR(ROUND(ls.driver_1_hours_remaining_on_week_at_i_pta, 1), 4, 1) Drv1HrsAtiPTA,
		STR(ROUND(ls.driver_2_hours_remaining_on_day_drive_at_i_pta, 1), 4, 1) + '/' + STR(ROUND(ls.driver_2_hours_remaining_on_day_duty_at_i_pta, 1), 4, 1) + '/' + STR(ROUND(ls.driver_2_hours_remaining_on_week_at_i_pta, 1), 4, 1) Drv2HrsAtiPTA,
		STR(ROUND(ps.driver_1_hours_remaining_on_day_drive, 1), 4, 1) + '/' + STR(ROUND(ps.driver_1_hours_remaining_on_day_duty, 1), 4, 1) + '/' + STR(ROUND(ps.driver_1_hours_remaining_on_week, 1), 4, 1) Drv1Hrs,
		STR(ROUND(ps.driver_2_hours_remaining_on_day_drive, 1), 4, 1) + '/' + STR(ROUND(ps.driver_2_hours_remaining_on_day_duty, 1), 4, 1) + '/' + STR(ROUND(ps.driver_2_hours_remaining_on_week, 1), 4, 1) Drv2Hrs,
		STR(ROUND(ps.driver_1_hours_remaining_day_drive_at_pta, 1), 4, 1) + '/' + STR(ROUND(ps.driver_1_hours_remaining_day_duty_at_pta, 1), 4, 1) + '/' + STR(ROUND(ps.driver_1_hours_remaining_week_at_pta, 1), 4, 1) Drv1HrsAtPTA,
		STR(ROUND(ps.driver_2_hours_remaining_day_drive_at_pta, 1), 4, 1) + '/' + STR(ROUND(ps.driver_2_hours_remaining_day_duty_at_pta, 1), 4, 1) + '/' + STR(ROUND(ps.driver_2_hours_remaining_week_at_pta, 1), 4, 1) Drv2HrsAtPTA,
		ls.driver_1_hours_remaining_on_day_drive_at_i_pta Drv1DriveHoursAtiPta,
		ls.driver_1_hours_remaining_on_day_duty_at_i_pta Drv1WorkHoursiPTA,
		ls.driver_1_hours_remaining_on_week_at_i_pta Drv1WeekHoursiPTA,
		ls.driver_2_hours_remaining_on_day_drive_at_i_pta Drv2DriveHoursiPTA,
		ls.driver_2_hours_remaining_on_day_duty_at_i_pta Drv2WorkHoursiPTA,
		ls.driver_2_hours_remaining_on_week_at_i_pta Drv2WeekHoursiPTA,
		ps.driver_1_hours_remaining_on_day_drive Drv1DriveHours,
		ps.driver_1_hours_remaining_on_day_duty Drv1WorkHours,
		ps.driver_1_hours_remaining_on_week Drv1WeekHours,
		ps.driver_2_hours_remaining_on_day_drive Drv2DriveHours,
		ps.driver_2_hours_remaining_on_day_duty Drv2WorkHours,
		ps.driver_2_hours_remaining_on_week Drv2WeekHours,
		ps.driver_1_hours_remaining_day_drive_at_pta Drv1DriveHoursAtPta,
		ps.driver_1_hours_remaining_day_duty_at_pta Drv1WorkHoursAtPta,
		ps.driver_1_hours_remaining_week_at_pta Drv1WeekHoursAtPta,
		ps.driver_2_hours_remaining_day_drive_at_pta Drv2DriveHoursAtPta,
		ps.driver_2_hours_remaining_day_duty_at_pta Drv2WorkHoursAtPta,
		ps.driver_2_hours_remaining_week_at_pta Drv2WeekHoursAtPta,
		(SELECT	COUNT(1)
		   FROM	opt_eta_pta_hos_segments hos
		  WHERE	hos.truck_id = ib.Tractor
		    AND	hos.work_status = 'OFFDUTY'
		    AND	hos.duration_in_hours = 10.0
		    AND	hos.begin_segment_time < (SELECT	TOP 1 ss.arrived_time
											FROM	opt_eta_pta_stop_state ss
										   WHERE	ss.load_id = ib.lgh_number ORDER BY ss.sequence DESC)
			AND	hos.begin_segment_time > (ISNULL((SELECT	MAX(hos2.begin_segment_time)
													FROM	opt_eta_pta_hos_segments hos2
																INNER JOIN opt_eta_pta_stop_state ss2 ON ss2.stop_id = hos2.stop_id
													 AND	hos2.truck_id = ib.Tractor
													 AND	hos2.begin_segment_time < (SELECT	TOP 1 ss3.arrived_time
																						 FROM	opt_eta_pta_stop_state ss3
																					    WHERE	ss3.load_id = ib.lgh_number ORDER BY ss3.sequence ASC)) , '19500101'))) Breaks,
		(SELECT	MAX(hos.end_of_last_break)
		   FROM	opt_eta_pta_hos_segments hos
					INNER JOIN opt_eta_pta_stop_state ss ON ss.stop_id = hos.stop_id
		  WHERE	ss.load_id = ib.lgh_number) 'LastBreakEnd'
  FROM	OperationsInboundView ib
			LEFT OUTER JOIN opt_eta_pta_load_state ls ON ls.load_id = ib.lgh_number
			LEFT OUTER JOIN opt_eta_pta_power_state ps on ps.power_id = ib.Tractor
GO
GRANT SELECT ON  [dbo].[OperationsInboundViewWithEtaPta] TO [public]
GO
