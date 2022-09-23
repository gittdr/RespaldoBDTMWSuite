SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[EtaPtaHosSegmentsView]
AS
SELECT	hos.truck_id 'Tractor',
		hos.driver_id 'Driver',
		CASE
			WHEN hos.work_status = 'Ext STATUS_FULL_RESET' THEN 'Reset'
			ELSE hos.work_status 
		END 'Work Status',
		hos.begin_segment_time 'Begin Time',
		hos.end_segment_time 'End Time',
		hos.duration_in_hours 'Duration',
		LTRIM(STR(hos.hours_remaining_on_day_drive, 4, 1)) + '/' + LTRIM(STR(hos.hours_remaining_on_day_duty, 4, 1)) + '/' + LTRIM(STR(hos.hours_remaining_on_week, 4, 1)) 'Hours Remaining',
		hos.rule_set 'Rule Set',
		hos.end_of_last_break 'Break End',
		hos.hours_driven_since_last_break 'Drive Hrs Since Break',
		hos.end_of_last_reset 'Reset End',
		hos.hours_driver_since_last_reset 'Drive Hrs Since Reset',
		hos.weekly_hrs_worked_since_last_break_or_reset 'Work Hours Since Reset',
		oh.ord_number 'Order',
		s.stp_event 'Event',
		s.cmp_id 'Company ID',
		s.cmp_name 'Company Name',
		ci.cty_nmstct 'City',
		s.stp_zipcode 'Postal',
		s.stp_schdtearliest 'Earliest',
		s.stp_schdtlatest 'Latest',
		hos.segment_id 
  FROM	opt_eta_pta_hos_segments hos
			LEFT OUTER JOIN stops s ON s.stp_number = hos.stop_id
			LEFT OUTER JOIN city ci ON ci.cty_code = s.stp_city
			LEFT OUTER JOIN orderheader oh ON oh.ord_hdrnumber = s.ord_hdrnumber
GO
GRANT SELECT ON  [dbo].[EtaPtaHosSegmentsView] TO [public]
GO
