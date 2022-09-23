SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.dw_mov_events    Script Date: 8/20/97 1:58:52 PM ******/
CREATE PROCEDURE [dbo].[dw_mov_events] @lgh int

AS

DECLARE @trailer_options	varchar(6), 
	@orig_cityname		varchar(30), 
	@enddate 		datetime,
	@paid 			smallint,
	@drv1_paid 		varchar(6),
	@drv2_paid 		varchar(6),
	@trc_paid		varchar(6),
	@trl1_paid		varchar(6),
	@trl2_paid		varchar(6),
	@car_paid		varchar(6),
	@int			int,
	@paydetails		int,
	@dec                    float(2)


SELECT @paydetails = (SELECT COUNT (*)
			FROM paydetail p, event e, assetassignment a
			WHERE a.lgh_number = @lgh
			  AND	e.evt_number = a.evt_number
			  AND	a.asgn_number = p.asgn_number
			  AND	a.asgn_type = 'DRV'
			  AND	a.asgn_id = e.evt_driver1)

IF @paydetails > 0
	SELECT @drv1_paid = 'PPD'
ELSE
	SELECT @drv1_paid = 'NPD'

SELECT @paydetails = (SELECT COUNT (*)
			FROM paydetail p, event e, assetassignment a
			WHERE a.lgh_number = @lgh
			  AND	e.evt_number = a.evt_number
			  AND	a.asgn_number = p.asgn_number
			  AND	a.asgn_type = 'DRV'
			  AND	a.asgn_id = e.evt_driver2)

IF @paydetails > 0
	SELECT @drv2_paid = 'PPD'
ELSE
	SELECT @drv2_paid = 'NPD'

SELECT @paydetails = (SELECT COUNT (*)
			FROM paydetail p, event e, assetassignment a
			WHERE a.lgh_number = @lgh
			  AND	e.evt_number = a.evt_number
			  AND	a.asgn_number = p.asgn_number
			  AND	a.asgn_type = 'TRC'
			  AND	a.asgn_id = e.evt_tractor)

IF @paydetails > 0
	SELECT @trc_paid = 'PPD'
ELSE
	SELECT @trc_paid = 'NPD'

SELECT @paydetails = (SELECT COUNT (*)
			FROM paydetail p, event e, assetassignment a
			WHERE a.lgh_number = @lgh
			  AND	e.evt_number = a.evt_number
			  AND	a.asgn_number = p.asgn_number
			  AND	a.asgn_type = 'CAR'
			  AND	a.asgn_id = e.evt_carrier)

IF @paydetails > 0
	SELECT @car_paid = 'PPD'
ELSE
	SELECT @car_paid = 'NPD'


SELECT @paydetails = (SELECT COUNT (*)
			FROM paydetail p, event e, assetassignment a
			WHERE a.lgh_number = @lgh
			  AND	e.evt_number = a.evt_number
			  AND	a.asgn_number = p.asgn_number
			  AND	a.asgn_type = 'TRL'
			  AND	a.asgn_id = e.evt_Trailer1)

IF @paydetails > 0
	SELECT @trl1_paid = 'PPD'
ELSE
	SELECT @trl1_paid = 'NPD'

SELECT @paydetails = (SELECT COUNT (*)
			FROM paydetail p, event e, assetassignment a
			WHERE a.lgh_number = @lgh
			  AND	e.evt_number = a.evt_number
			  AND	a.asgn_number = p.asgn_number
			  AND	a.asgn_type = 'TRL'
			  AND	a.asgn_id = e.evt_Trailer2)

IF @paydetails > 0
	SELECT @trl2_paid = 'PPD'
ELSE
	SELECT @trl2_paid = 'NPD'
/*
SELECT @drv1_paid = (SELECT MAX( pyd_status ) 
			FROM assetassignment, event
			WHERE 	assetassignment.lgh_number = @lgh  AND
				event.evt_number  = assetassignment.evt_number  and
				asgn_type = 'DRV' AND
				asgn_id = event.evt_driver1) 

SELECT @drv2_paid = (SELECT MAX( pyd_status ) 
			FROM assetassignment, event
			WHERE assetassignment.lgh_number = @lgh AND 
				assetassignment.evt_number = event.evt_number and
				asgn_type = 'DRV' AND
				asgn_id = event.evt_driver2 )

SELECT @trc_paid = (SELECT MAX( pyd_status ) 
			FROM assetassignment, event
			WHERE assetassignment.lgh_number = @lgh AND 
				assetassignment.evt_number = event.evt_number and
				asgn_type = 'TRC' AND
				asgn_id = event.evt_tractor )
*/

SELECT @trl1_paid = ''	/* MAX ( pyd_status ) FROM assetassignment
					WHERE assetassignment.lgh_number = @lgh AND 
					assetassignment.evt_number = event.evt_number and
					asgn_type = 'TRL' AND
					asgn_id = event.evt_trailer1*/

SELECT @trl2_paid = '' /* MAX ( pyd_status ) FROM assetassignment
					WHERE assetassignment.lgh_number = @lgh AND 
					assetassignment.evt_number = event.evt_number and
					asgn_type = 'TRL' AND
					asgn_id = event.evt_trailer2 */

/*
SELECT @car_paid = (SELECT MAX( pyd_status ) 
			FROM assetassignment, event
			WHERE assetassignment.lgh_number = @lgh AND 
				assetassignment.evt_number = event.evt_number and
				asgn_type = 'CAR' AND
				asgn_id = event.evt_carrier )

*/
SELECT	event.evt_number, 
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
	legheader.ord_hdrnumber legheader_ord_hdrnumber, 
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
	'LghType1' lghtype1,
	@drv1_paid drv1_paid,
	@drv2_paid drv2_paid,
	@trc_paid  trc_paid,
	@trl1_paid trl1_paid, 
	@trl2_paid trl2_paid, 
	@car_paid car_paid,
	event.evt_hubmiles,
	@int routed_mileage,
	@int total_mileage,
	@dec total_charge,
	@dec epm,
	city.cty_state,
	city.cty_name, 
        stops.stp_zipcode,
	legheader.lgh_dispatchdate
INTO	#temp
FROM	event, stops, eventcodetable, legheader, city 
WHERE	( stops.stp_number = event.stp_number ) and 
	( eventcodetable.abbr = event.evt_eventcode ) and 
	( stops.lgh_number = legheader.lgh_number ) and 
	( city.cty_code = stops.stp_city ) and 
	( ( stops.lgh_number = @lgh ) AND 
	( eventcodetable.primary_event = 'Y' ) )

UPDATE	#temp
SET	routed_mileage = (SELECT	SUM(stops.stp_lgh_mileage)
			FROM	stops
			WHERE	stops.mov_number = #temp.mov_number AND
				stops.stp_lgh_mileage IS NOT NULL)
FROM	#temp

UPDATE	#temp
SET	total_charge = (SELECT SUM(orderheader.ord_totalcharge)
			FROM	orderheader
			WHERE	orderheader.mov_number = #temp.mov_number AND
				orderheader.ord_totalcharge IS NOT NULL)
FROM	#temp

SELECT	*	FROM	#temp
GO
GRANT EXECUTE ON  [dbo].[dw_mov_events] TO [public]
GO
