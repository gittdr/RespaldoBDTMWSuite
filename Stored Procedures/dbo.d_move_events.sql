SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[d_move_events]
   @lgh int
AS
BEGIN

-- LOR   PTS# 35719  add LghType2

DECLARE @trailer_options   varchar(6),
   @orig_cityname varchar(30),
   @paid       smallint,
   @drv1_paid  varchar(6),
   @drv2_paid  varchar(6),
   @trc_paid   varchar(6),
   @trl1_paid  varchar(6),
   @trl2_paid  varchar(6),
   @car_paid   varchar(6),
   @int     int,
   @dec     float(2)

--BEGIN PTS 64373 SPN
DECLARE @CalculateLegMiles CHAR(1)
--END PTS 64373 SPN

--BEGIN PTS 64373 SPN
SELECT @CalculateLegMiles = dbo.fn_GetSetting('CalculateLegMiles','C1')
--END PTS 64373 SPN

SELECT   @drv1_paid = CASE WHEN COUNT(*) > 0 THEN 'PPD' ELSE 'NPD' END
FROM  paydetail p, event e, assetassignment a
WHERE a.lgh_number = @lgh AND
   e.evt_number = a.evt_number AND
   a.asgn_number = p.asgn_number AND
   a.asgn_type = 'DRV' AND
   a.asgn_id = e.evt_driver1

SELECT   @drv2_paid = CASE WHEN COUNT(*) > 0 THEN 'PPD' ELSE 'NPD' END
FROM  paydetail p, event e, assetassignment a
WHERE a.lgh_number = @lgh AND
   e.evt_number = a.evt_number AND
   a.asgn_number = p.asgn_number AND
   a.asgn_type = 'DRV' AND
   a.asgn_id = e.evt_driver2

SELECT   @trc_paid = CASE WHEN COUNT(*) > 0 THEN 'PPD' ELSE 'NPD' END
FROM  paydetail p, event e, assetassignment a
WHERE a.lgh_number = @lgh AND
   e.evt_number = a.evt_number AND
   a.asgn_number = p.asgn_number AND
   a.asgn_type = 'TRC' AND
   a.asgn_id = e.evt_tractor

SELECT   @car_paid = CASE WHEN COUNT(*) > 0 THEN 'PPD' ELSE 'NPD' END
FROM  paydetail p, event e, assetassignment a
WHERE a.lgh_number = @lgh AND
   e.evt_number = a.evt_number AND
   a.asgn_number = p.asgn_number AND
   a.asgn_type = 'CAR' AND
   a.asgn_id = e.evt_carrier

SELECT   @trl1_paid = CASE WHEN COUNT(*) > 0 THEN 'PPD' ELSE 'NPD' END
FROM  paydetail p, event e, assetassignment a
WHERE a.lgh_number = @lgh AND
   e.evt_number = a.evt_number AND
   a.asgn_number = p.asgn_number AND
   a.asgn_type = 'TRL' AND
   a.asgn_id = e.evt_Trailer1

SELECT   @trl2_paid = CASE WHEN COUNT(*) > 0 THEN 'PPD' ELSE 'NPD' END
FROM  paydetail p, event e, assetassignment a
WHERE a.lgh_number = @lgh AND
   e.evt_number = a.evt_number AND
   a.asgn_number = p.asgn_number AND
   a.asgn_type = 'TRL' AND
   a.asgn_id = e.evt_Trailer2

SELECT   event.evt_number,
   event.evt_eventcode,
   event.evt_startdate,
   event.evt_enddate,
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
   legheader.lgh_dispatchdate,
        stops.stp_lgh_mileage_mtid,
        legheader.lgh_number,
   ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,
   labelfile_headers.LghPermitStatus lgh_permit_status_t,
   event.evt_departure_status,
   legheader.lgh_type2,
   'LghType2' lghtype2,
   stp_lgh_mileage = IsNull((CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage ELSE stops.stp_lgh_mileage END),0), --40259
   stp_loadstatus                       --40259
INTO  #temp
FROM  event, stops, eventcodetable, legheader, city, labelfile_headers
WHERE ( stops.stp_number = event.stp_number ) and
   ( eventcodetable.abbr = event.evt_eventcode ) and
   ( stops.lgh_number = legheader.lgh_number ) and
   ( city.cty_code = stops.stp_city ) and
   ( ( stops.lgh_number = @lgh ) AND
   ( eventcodetable.primary_event = 'Y' ) )

UPDATE   #temp
SET   routed_mileage = (SELECT   SUM((CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage ELSE stops.stp_lgh_mileage END))
         FROM  stops
         WHERE stops.mov_number = #temp.mov_number AND
            (CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage ELSE stops.stp_lgh_mileage END) IS NOT NULL)
FROM  #temp

UPDATE   #temp
SET   total_charge = (SELECT SUM(orderheader.ord_totalcharge)
         FROM  orderheader
         WHERE orderheader.mov_number = #temp.mov_number AND
            orderheader.ord_totalcharge IS NOT NULL)
FROM  #temp

SELECT   *
FROM  #temp

END
GO
GRANT EXECUTE ON  [dbo].[d_move_events] TO [public]
GO
