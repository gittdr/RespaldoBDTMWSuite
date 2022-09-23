SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.dw_move_events    Script Date: 6/1/99 11:55:00 AM ******/
CREATE PROCEDURE [dbo].[dw_move_events] @lgh int

AS

DECLARE @trailer_options varchar(6), 
	@orig_cityname varchar (30), 
	@enddate datetime,
	@paid smallint

SELECT event.evt_number, 
event.evt_eventcode, 
event.evt_startdate, 
@enddate enddate, 
event.evt_status, 
event.evt_driver1, 
event.evt_driver2, 
event.evt_tractor, 
event.evt_trailer1, 
event.evt_carrier, 
stops.cmp_id, 
stops.cmp_name, 
stops.stp_mfh_sequence, 
eventcodetable.mile_typ_from_stop, 
event.evt_sequence, 
stops.mov_number, 
legheader.lgh_outstatus, 
legheader.ord_hdrnumber, 
stops.stp_city, 
city.cty_nmstct, 
legheader.lgh_revenue, 
legheader.lgh_milesshortest, 
legheader.lgh_cost, 
legheader.lgh_mtmiles, 
0 orig_city, 
@orig_cityname orig_cityname, 
event.stp_number, 
event.evt_pu_dr, 
event.evt_earlydate, 
event.evt_latedate, 
event.ord_hdrnumber, 
event.evt_dolly, 
event.evt_chassis, 
event.evt_trailer2, 
@trailer_options trailer_options, 
legheader.lgh_type1, 
"LghType1" lghtype1,
drv1_paid = ( SELECT pyd_status FROM assetassignment
		WHERE assetassignment.evt_number = event.evt_number AND 
			asgn_type = 'DRV' AND
			asgn_id = event.evt_driver1 ),
drv2_paid = ( SELECT pyd_status FROM assetassignment
		WHERE assetassignment.evt_number = event.evt_number AND 
			asgn_type = 'DRV' AND
			asgn_id = event.evt_driver1 ),
trc_paid = ( SELECT pyd_status FROM assetassignment
		WHERE assetassignment.evt_number = event.evt_number AND 
			asgn_type = 'TRC' AND
			asgn_id = event.evt_tractor ),
trl1_paid = null, /*( SELECT pyd_status FROM assetassignment
		WHERE assetassignment.evt_number = event.evt_number AND 
			asgn_type = 'TRL' AND
			asgn_id = event.evt_trailer1 ),*/
trl2_paid = null, /*( SELECT pyd_status FROM assetassignment
		WHERE assetassignment.evt_number = event.evt_number AND 
			asgn_type = 'TRL' AND
			asgn_id = event.evt_trailer2 ),*/
car_paid = ( SELECT pyd_status FROM assetassignment
		WHERE assetassignment.evt_number = event.evt_number AND 
			asgn_type = 'CAR' AND
			asgn_id = event.evt_carrier )

FROM event, stops, eventcodetable, legheader, city 
WHERE ( stops.stp_number = event.stp_number ) and 
	( eventcodetable.abbr = event.evt_eventcode ) and 
	( stops.lgh_number = legheader.lgh_number ) and 
	( city.cty_code = stops.stp_city ) and 
	( ( stops.lgh_number = @lgh ) AND 
	( eventcodetable.primary_event = 'Y' ) ) 





GO
GRANT EXECUTE ON  [dbo].[dw_move_events] TO [public]
GO
