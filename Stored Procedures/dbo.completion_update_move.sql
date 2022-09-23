SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[completion_update_move] (@mov int)
AS

/**
 * 
 * NAME:
 * completion_update_move
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: @mov		int		Move Number
 *
 * REVISION HISTORY:
 * 3/19/2007.01 ? PTS33397 - Dan Hudec/Frank Michels ? Created Procedure
 **/

DECLARE @minlgh 		int,
	@minseq 		smallint,
	@maxseq 		smallint,
	@ordnum 		int,
	@cmd 			varchar(8),
	@desc 			varchar(30),
	@pri 			varchar(6),
	@stat 			varchar(6),
	@instat 		varchar(6),
	@startdate 		datetime,
	@startcity 		int,
	@startcomp 		varchar(8),
	@startstop 		int,
	@enddate 		datetime,
	@oldenddate     	datetime,
	@endcity 		int,
	@endcomp 		varchar(8),
	@endstop 		int,
	@early 			datetime,
	@late 			datetime,
	@opn 			smallint,
	@cls 			smallint,
	@type 			char(6),
	@id 			char(13),
	@type1 			varchar(6),
	@type2 			varchar(6),
	@type3 			varchar(6),
	@type4 			varchar(6),
	@asgns 			tinyint,
	@trailer 		varchar(13),
	@trailer2 		varchar(13),
	@tractor 		varchar(8),
	@lghtractor 		varchar(8),
	@carrier 		varchar(8),
	@drvtrc 		varchar(8),
	@driver1 		varchar(8),
	@driver2 		varchar(8),
	@trcdriver1 		varchar(8),
	@trcdriver2 		varchar(8),
	@lgh 			int,
	@avlstat 		char(6),
	@avldate 		datetime,
	@avlcmp 		char(8),
	@avlcity 		int,
	@idx 			smallint,
	@minasgn 		int,
	@lghstring 		char(8),
	@trace 			varchar(64),
	@ret			int,
	@lgh_startregion1       varchar(6),
	@lgh_startregion2       varchar(6),
	@lgh_startregion3       varchar(6),
	@lgh_startregion4       varchar(6),
	@lgh_startstate		varchar(6),		
	@lgh_startcty_nmstct	varchar(25),
	@lgh_endregion1		varchar(6),
	@lgh_endregion2		varchar(6),
	@lgh_endregion3		varchar(6),
	@lgh_endregion4		varchar(6),
	@lgh_endstate		varchar(6),	
	@lgh_endcty_nmstct	varchar(25),
	@mpp_teamleader       	varchar(6),
	@mpp_fleet       	varchar(6),
	@mpp_division       	varchar(6),
	@mpp_domicile       	varchar(6),
	@mpp_company       	varchar(6),
	@mpp_terminal       	varchar(6),
	@mpp_type1       	varchar(6),
	@mpp_type2       	varchar(6),
	@mpp_type3       	varchar(6),
	@mpp_type4       	varchar(6),
	@trc_company       	varchar(6),
	@trc_division       	varchar(6),
	@trc_fleet       	varchar(6),
	@trc_terminal       	varchar(6),
	@trc_type1       	varchar(6),
	@trc_type2       	varchar(6),
	@trc_type3       	varchar(6),
	@trc_type4       	varchar(6),
	@trl_company       	varchar(6),
	@trl_fleet       	varchar(6),
	@trl_division       	varchar(6),
	@trl_terminal       	varchar(6),
	@trl_type1       	varchar(6),
	@trl_type2       	varchar(6),
	@trl_type3       	varchar(6),
	@trl_type4       	varchar(6),
	@lgh_active	        char(1),
	@check_active 		char(1),
	@check_instatus 	varchar(6),
	@check_outstatus 	varchar(6),
	@splitpup		char(1),
	@lgh_enddate_arrival	datetime,
	@mpn_count		smallint,
	@event_min_odometer	int,
	@event_max_odometer	int,
	@lgh_odometerstart	int,
	@lgh_odometerend	int,
	@minrevseq 		smallint,
	@maxrevseq 		smallint,
        @startlat               int,
        @startlon               int,
        @endlat                 int,
        @endlon                 int,
        @revstartlat            int,
        @revstartlon            int,
        @revendlat              int,
        @revendlon              int,
	@revstartdate 		datetime,
	@revstartcity 		int,
	@revstartcomp 		varchar(8),
	@revstartstop 		int,
	@revenddate 		datetime,
	@revendcity 		int,
	@revendcomp 		varchar(8),
	@revendstop 		int,
	@lgh_revstartregion1       varchar(6),
	@lgh_revstartregion2       varchar(6),
	@lgh_revstartregion3       varchar(6),
	@lgh_revstartregion4       varchar(6),
	@lgh_revstartstate		varchar(6),
	@lgh_revstartcty_nmstct	varchar(25),
	@lgh_revendregion1		varchar(6),
	@lgh_revendregion2		varchar(6),
	@lgh_revendregion3		varchar(6),
	@lgh_revendregion4		varchar(6),
	@lgh_revendstate		varchar(6),
	@lgh_revendcty_nmstct	varchar(25),
	@transfer_type		char(3),
	@active			char(1),
/* kpm 7/14/01 added to pass legheader miles to tmt*/  
	@lgh_miles 		float,
	@tmtserver		varchar(25),
	@tmtdb			varchar(25),
	@tmtuser		varchar(25),
	@tmtpassword		varchar(25),
	@sql			varchar(256),
	@metertype              varchar(12),
	@meterdate              datetime,
        	@shoplink               int,
	@lgh_mileage  		int,
	@lgh_linehaul		float,
	@lgh_ord_charge float,
	@lgh_act_weight float,
	@lgh_est_weight float,
	@lgh_tot_weight float,
	@updatemovepostprocessing	char(1),
	@lgh_manuallysettypeclass int,
	@lgh_hzd_cmd_class	varchar (8), /*PTS 23162*/
	@HazMatMileageLookups char (1), /*PTS 23162*/
	@originzip		varchar(10),
	@destzip		varchar(10),
	@route	varchar(15),
	@booked_revtype1	varchar(12),
	@DisplayPendingOrders	varchar(1),
	@pending_statuses	varchar(60),
    @vs_reset_permit_req char(1),
	@vs_fix_order_seq char(1),   /*DWG {31262)*/
	@tchrealtime_status	char(1), --DPH PTS 30006
	@tchrealtime_tractor	char(1), --DPH PTS 30006
	@tchrealtime_trailer	char(1), --DPH PTS 30006
	@tchrealtime_trip	char(1),  --DPH PTS 30006
	@chassis varchar(13),	--JLB PTS 49323
	@chassis2 varchar(13),	--JLB PTS 49323
	@dolly varchar(13),	--JLB PTS 49323
	@dolly2 varchar(13),	--JLB PTS 49323
	@trailer3 varchar(13),	--JLB PTS 49323
	@trailer4 varchar(13)	--JLB PTS 49323

--CREATE TABLE #tmp (lgh_number int NULL)
-- KMM PTS 19907, use table vars instead of temp tables for SQL 2000 only
DECLARE @tmp TABLE (lgh_number int NULL)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
--FMM: exec gettmwuser @tmwuser output
select @tmwuser = left(suser_sname(),20)

/* make sure legheaders exists for actual stops */

--FMM: SELECT @active = 'Y'
select @active = 'N'

/* FMM begin
-- DPH, PTS 18902, support post update move processing
SELECT 	@updatemovepostprocessing = gi_string1
FROM	generalinfo
WHERE	gi_name = 'updatemovepostprocessing'
-- END DPH PTS 18902
FMM end */
SELECT @updatemovepostprocessing = 'N'

--DPH PTS 27213 - Support Displaying Pending Orders in Planning Worksheet
--	LOR	PTS# 28465	list pending statuses
/* FMM begin
SELECT	@DisplayPendingOrders = gi_string1,
		@pending_statuses = IsNull(Upper(RTRIM(LTRIM(gi_string2))), '')
FROM	generalinfo
WHERE	gi_name = 'DisplayPendingOrders'
FMM end*/
SELECT @DisplayPendingOrders = 'N'

/* FMM begin
If @DisplayPendingOrders = 'Y' and charindex('PND', @pending_statuses) = 0
	select @pending_statuses = @pending_statuses + ',PND' 
FMM end*/
--	LOR

--  PTS 23162 CGK 8/25/2004
/* FMM begin
SELECT 	@HazMatMileageLookups = Upper (gi_string1)
FROM	generalinfo
WHERE	gi_name = 'HazMatMileageLookups'
-- END PTS 23162
FMM end*/
SELECT @HazMatMileageLookups = 'N'

SELECT @minlgh = 0

SELECT @idx = 0

/* get the max order hdr on the move */
SELECT @ordnum = (SELECT MAX(ord_hdrnumber) 
                    FROM stops
                   WHERE mov_number = @mov)

/* get the lowest priority number on the orders on the move */
SELECT @pri = 'UNK'

SET ROWCOUNT 1
/* get rev type1 to type4 from the orderheader on the move */
SELECT @type1 = ord_revtype1, 
       @type2 = ord_revtype2, 
       @type3 = ord_revtype3, 
       @type4 = ord_revtype4,
		@route = IsNull(ord_route,'UNKNOWN'),
		@booked_revtype1 = IsNull(ord_booked_revtype1,'UNK')  
  FROM orderheader
 WHERE ord_hdrnumber = @ordnum 

Select @type1 = IsNull(@type1,'UNK')
Select @type2 = IsNull(@type2,'UNK')
Select @type3 = IsNull(@type3,'UNK')
Select @type4 = IsNull(@type4,'UNK')


/* get commodity code and description from the stops on the move */
SELECT @cmd = cmd_code,
       @desc = stp_description
  FROM stops
 WHERE mov_number = @mov  and ord_hdrnumber+0 > 0 
       AND stp_description <> 'UNKNOWN'
SET ROWCOUNT 0

IF @cmd IS NULL
BEGIN
     SELECT @cmd = 'UNK'
     SELECT @desc = 'UNKNOWN'
END

INSERT INTO @tmp 
     SELECT lgh_number 
       FROM stops
      WHERE mov_number = @mov 
            AND stp_status <> 'NON' /*option (keepfixed plan)*/

/* Loop for all legheaders which have all 'NON' stops, on the passed move */
WHILE 1=1
BEGIN
     SELECT @idx = @idx + 1

     SELECT @minlgh = MIN(lgh_number) 
       FROM @tmp
      WHERE lgh_number > @minlgh /*option (keepfixed plan)*/
            
     IF @minlgh IS NULL
        BREAK

     SELECT @lgh_hzd_cmd_class = ''


	/* FMM begin
     -- vjh get update lgh with start and end hub readings
     SELECT @event_max_odometer = MAX(evt_hubmiles ), @event_min_odometer = MIN(evt_hubmiles )
       FROM stops s, event e 
      WHERE s.mov_number = @mov
            AND s.lgh_number = @minlgh
            AND s.stp_number=e.stp_number
            AND ISNULL(evt_hubmiles, 0) <> 0

     select @lgh_odometerstart = lgh_odometerstart, @lgh_odometerend = lgh_odometerend
        from legheader where lgh_number = @minlgh

     if @lgh_odometerstart is null or @lgh_odometerend is null
     begin
        select @lgh_odometerstart = @event_min_odometer, @lgh_odometerend = @event_max_odometer
     end
     else
     begin
        if not @event_max_odometer is null and
           not @event_min_odometer is null and
           @event_max_odometer <> @event_min_odometer
        begin
           select @lgh_odometerstart = @event_min_odometer, @lgh_odometerend = @event_max_odometer
        end
     end
	FMM end */
	
     /* get the max & min stop mfh_sequence for the current leghdr */
     SELECT @maxseq = MAX(stp_mfh_sequence), @minseq = MIN(stp_mfh_sequence)
       FROM stops
      WHERE mov_number = @mov
            AND lgh_number = @minlgh

     /* vjh pts6798 get the max & min stop mfh_sequence for the current leghdr for revenue stops */
     SELECT @maxrevseq = @maxseq, @minrevseq = @minseq

     -- JET - 9/30/00 - PTS #8737, found asset assignments from the event table.  It has been updated by the time this procedure is
     -- run, the asset assignments have not been made/updated until the bottom of this procedure per Mark F's changes.
     /*MF removed AND a.asgn_controlling = 'Y' because even if it is not controlling it should be counted*/
     SELECT @asgns = COUNT(*) 
     --  FROM event e, assetassignment a, stops s
       FROM event e, stops s
      WHERE lgh_number = @minlgh 
            AND s.stp_number = e.stp_number 
            AND ((evt_tractor <> 'UNKNOWN' AND evt_tractor IS NOT NULL AND evt_tractor <> '') OR
                 (evt_driver1 <> 'UNKNOWN' AND evt_driver1 IS NOT NULL AND evt_driver1 <> '') OR
                 (evt_driver2 <> 'UNKNOWN' AND evt_driver2 IS NOT NULL AND evt_driver2 <> '') OR
                 (evt_carrier <> 'UNKNOWN' AND evt_carrier IS NOT NULL AND evt_CARRIER <> ''))
            --AND a.evt_number = e.evt_number 
            --AND a.asgn_type <> 'TRL'
            --AND a.asgn_status <> 'REF'
            --AND a.asgn_status <> 'DNR' 

     /* compute status.  if none opn, is complete */
     /* if none closed is avl,pln, or dsp	 */	
     /* if some of each, is std */
     /* compute leg status as 'AVL' if no open and done stops are found 
        else if only done stops are found then set the status to completed otherwise 
        set the status to started. 
        If status was 'AVL' and there were non-trailer assigns then set status to 'PLN'
     */

     SELECT @opn = 0 

     SELECT @stat = 'CMP'

	/* FMM begin
     -- KM PTS 7682 - MPN_COUNT is used to see if this load is actively multiplanned
     SELECT @mpn_count = count(*) 
     FROM preplan_assets
     WHERE ppa_lgh_number = @minlgh AND
    ppa_status = 'Active'

     IF @stat = 'AVL' AND (@asgns > 0 OR @mpn_count > 0)
     BEGIN
        /* if have asgnmnts, then is PLN  */
        /* check if @stat should be dsp or pln */
        /* only way to tell if is DSP is if it already was */ 
        IF (SELECT lgh_outstatus 
              FROM legheader 
             WHERE lgh_number = @minlgh) = 'DSP'
           SELECT @stat = 'DSP'
        ELSE
             IF @mpn_count > 0 
                  SELECT @stat = 'MPN'
            ELSE
                  SELECT @stat = 'PLN'
     END
	FMM end */

     /* Get the known tractor, driver1, driver2, carrier for the current leg and 
        primary events */
     SET ROWCOUNT 1
	
     SELECT @tractor = NULL
     SELECT @driver1 = NULL
     SELECT @driver2 = NULL
     SELECT @carrier = NULL

/*PTS11263 MBR 7/11/01 Removed tractor <> unknown or carrier <> unknown */
     SELECT @tractor = e.evt_tractor, 
            @driver1 = evt_driver1, 
            @driver2 = e.evt_driver2, 
            @carrier = evt_carrier
       FROM event e, stops s
      WHERE s.lgh_number = @minlgh   
            AND s.stp_number = e.stp_number
            AND e.evt_sequence = 1

     SET ROWCOUNT 0

     -- JET - PTS #5762 - 5/24/99, make sure NULL assets are stored as UNKNOWN
     IF @tractor IS NULL
        SELECT @tractor = 'UNKNOWN'
     IF @driver1 IS NULL
        SELECT @driver1 = 'UNKNOWN'
     IF @driver2 IS NULL
        SELECT @driver2 = 'UNKNOWN'
     IF @carrier IS NULL
        SELECT @carrier = 'UNKNOWN'

	/* FMM begin
     --mf 14236 speed up clone order by default instatus currently to prevent trigger fire	
      if exists( SELECT *
	      FROM assetassignment
	      WHERE asgn_status IN ('PLN', 'DSP') AND 
        	    asgn_type = 'TRC' AND 
	            asgn_id = @tractor)
                SELECT @instat = 'PLN'
       ELSE
	FMM end */
                SELECT @instat = 'HST'

     IF @idx = 1
        SELECT @trailer = '',
               @trailer2 = '' /* update_trlonlgh finds it */

     -- JET - PTS #5762 - 5/24/99, broke this into two separate selects. 
     --       Also made the end date for the leg, the departure date from the last leg
     /* get the startdate, enddate, startcity, endcity, startstop, endstop, startcompany, 
        endcompany, early & late dates from the min and max stops. */
     SELECT @startdate = stp_arrivaldate,
            @startcity = stp_city,
            @startstop = stp_number,
            @startcomp = cmp_id,
            @early = stp_schdtearliest,
            @late = stp_schdtlatest
       FROM stops
      WHERE lgh_number = @minlgh
            AND stp_mfh_sequence = @minseq

     SELECT @lgh_enddate_arrival = stp_arrivaldate,
            @enddate = stp_departuredate,
            @endcity = stp_city,
            @endstop = stp_number,
            @endcomp = cmp_id 
       FROM stops
      WHERE lgh_number = @minlgh
            AND stp_mfh_sequence = @maxseq

     --vjh pts6798 get values for revenue endpoints
     if @minrevseq is null
     begin
        SELECT @revstartdate = NULL,
               @revstartcity = NULL,
               @revstartstop = NULL,
               @revstartcomp = NULL,
               @revenddate = NULL,
               @revendcity = NULL,
               @revendstop = NULL,
               @revendcomp = NULL
     end
     else
     begin
        SELECT @revstartdate = stp_arrivaldate,
               @revstartcity = stp_city,
               @revstartstop = stp_number,
               @revstartcomp = cmp_id,
	       @originzip = stp_zipcode
          FROM stops
         WHERE lgh_number = @minlgh
               AND stp_mfh_sequence = @minrevseq
        
        SELECT @revenddate = stp_departuredate,
               @revendcity = stp_city,
               @revendstop = stp_number,
               @revendcomp = cmp_id,
	       @destzip = stp_zipcode 
          FROM stops
         WHERE lgh_number = @minlgh
               AND stp_mfh_sequence = @maxrevseq
     end

     SELECT @oldenddate = @enddate

     /* get the enddate from the max stop's primary event and if it is apocalypse then 
        retain the one from the previous select */
     SELECT @enddate = event.evt_enddate
       FROM stops, event
      WHERE stops.stp_number = event.stp_number
            AND stops.mov_number = @mov
            AND stops.lgh_number = @minlgh
            AND stops.stp_mfh_sequence = @maxseq
            AND event.evt_enddate < '20491231'
            AND event.evt_sequence = 1

      IF @enddate IS NULL
         SELECT @enddate = @oldenddate	

-- RE - 11/19/02 - PTS #16261 
--      SELECT @type = a.asgn_type,
--             @id = a.asgn_id
--        FROM event e, assetassignment a, stops s
--       WHERE s.lgh_number = @minlgh
--             AND s.stp_number = e.stp_number
--             AND a.evt_number = e.evt_number
--            AND a.asgn_controlling = 'Y'

      /* 11/5/97 MF Load denormalized columns for legheader table */
      SELECT @lgh_startregion1 = cty_region1,
             @lgh_startregion2 = cty_region2, 
             @lgh_startregion3 = cty_region3, 
             @lgh_startregion4 = cty_region4, 
             @lgh_startstate = cty_state,
             @lgh_startcty_nmstct = cty_nmstct,
             @startlat = round(cty_latitude,0),
             @startlon = round(cty_longitude,0)
       FROM city
       WHERE cty_code = @startcity

      SELECT @lgh_endregion1 = cty_region1, 
             @lgh_endregion2 = cty_region2, 
             @lgh_endregion3 = cty_region3, 
             @lgh_endregion4 = cty_region4, 
             @lgh_endstate = cty_state,
             @lgh_endcty_nmstct = cty_nmstct,	
             @endlat = round(cty_latitude,0),
             @endlon = round(cty_longitude,0)	
       FROM city
       WHERE cty_code = @endcity

      --vjh pts6798
      if @minrevseq is null
      begin
         SELECT @lgh_revstartregion1 = NULL,
                @lgh_revstartregion2 = NULL,
                @lgh_revstartregion3 = NULL,
                @lgh_revstartregion4 = NULL,
                @lgh_revstartstate = NULL,
                @lgh_revstartcty_nmstct = NULL,
                @revstartlat = NULL,
                @revstartlon = NULL,
                @lgh_revendregion1 = NULL,
                @lgh_revendregion2 = NULL,
                @lgh_revendregion3 = NULL,
                @lgh_revendregion4 = NULL,
                @lgh_revendstate = NULL,
                @lgh_revendcty_nmstct = NULL,
                @revendlat = NULL,
                @revendlon = NULL
      end
      else
      begin
         SELECT @lgh_revstartregion1 = cty_region1,
                @lgh_revstartregion2 = cty_region2, 
                @lgh_revstartregion3 = cty_region3, 
                @lgh_revstartregion4 = cty_region4, 
                @lgh_revstartstate = cty_state,
                @lgh_revstartcty_nmstct = cty_nmstct,
                @revstartlat = round(cty_latitude,0),
                @revstartlon = round(cty_longitude,0)
         FROM city
         WHERE cty_code = @revstartcity
      
         SELECT @lgh_revendregion1 = cty_region1, 
                @lgh_revendregion2 = cty_region2, 
                @lgh_revendregion3 = cty_region3, 
                @lgh_revendregion4 = cty_region4, 
                @lgh_revendstate = cty_state,
                @lgh_revendcty_nmstct = cty_nmstct, 
                @revendlat = round(cty_latitude,0),
                @revendlon = round(cty_longitude,0)	
         FROM city
         WHERE cty_code = @revendcity
      end

/*Recommented in for PTS 27482 CGK 3/25/2004*/
  SELECT @transfer_type = stp_transfer_type
        FROM stops
      WHERE lgh_number = @minlgh
            AND stp_mfh_sequence = @minseq
     IF @transfer_type = 'SIT'
     BEGIN
          SELECT @stat = 'SIT'
          SELECT @instat = 'HST'
          SELECT @active = 'N'
     END
/*Commented out for PTS 24458 CGK 12/7/2004*/
     /*PTS10130 MBR 4/17/01 Set outstatus to SIT when stp_transfer_type = 'SIT'  */
--     SELECT @transfer_type = stp_transfer_type
--        FROM stops
--      WHERE lgh_number = @minlgh
--            AND stp_mfh_sequence = @minseq
--     IF @transfer_type = 'SIT'
--     BEGIN
--          SELECT @stat = 'SIT'
--          SELECT @instat = 'HST'
--          SELECT @active = 'N'
--     END

/*PTS 24458 CGK 12/7/2004*/
/*JLB PTS 26528 re-worked if statement for performance
     IF Exists (SELECT *
		FROM
			(SELECT 
			   count1 = (SELECT count (*) FROM stops WHERE lgh_number = @minlgh AND ord_hdrnumber = A.ord_hdrnumber AND stp_event IN ('XDL', 'XDU')),
			   count2 = (SELECT count (*) FROM stops WHERE lgh_number = @minlgh AND ord_hdrnumber = A.ord_hdrnumber AND stp_transfer_type = 'SIT'),
			   count3 = (SELECT count (*) FROM stops WHERE lgh_number = @minlgh AND ord_hdrnumber = A.ord_hdrnumber AND stp_status = 'OPN' AND ord_hdrnumber > 0 AND stp_event NOT IN ('LLD', 'LUL', 'XDU', 'XDL')),
			   count4 = (SELECT count (*) FROM stops WHERE lgh_number = @minlgh AND ord_hdrnumber = A.ord_hdrnumber AND stp_status = 'DNE' AND stp_event IN ('XDU'))
			FROM stops A
			WHERE mov_number = @mov) B
		WHERE count1 > 0 
		AND count2 > 0 
		AND count3 = 0
		AND count4 > 0)
*/
/*  Commented out for PTS 27482, reverted back to what it was before.
    IF Exists (SELECT *
	FROM (SELECT * FROM stops 
		WHERE mov_number = @mov
			and lgh_number = @minlgh) B
	WHERE exists (SELECT * FROM Stops WHERE Stops.lgh_number = b.lgh_number AND Stops.ord_hdrnumber = b.ord_hdrnumber AND Stops.stp_event IN ('XDL', 'XDU')) 
		AND exists (SELECT * FROM Stops WHERE Stops.lgh_number = b.lgh_number AND Stops.ord_hdrnumber = b.ord_hdrnumber AND Stops.stp_transfer_type = 'SIT')
		AND not exists (SELECT * FROM Stops WHERE Stops.lgh_number = b.lgh_number AND Stops.ord_hdrnumber = b.ord_hdrnumber AND Stops.stp_status = 'OPN' AND Stops.ord_hdrnumber > 0 AND Stops.stp_event NOT IN ('LLD', 'LUL', 'XDU', 'XDL'))
		AND exists (SELECT * FROM Stops WHERE Stops.lgh_number = b.lgh_number AND Stops.ord_hdrnumber = b.ord_hdrnumber AND Stops.stp_status = 'DNE' AND Stops.stp_event IN ('XDU')) )
-- PTS 26849 -- BL (start)
    BEGIN
        SELECT @stat = 'SIT'
        SELECT @instat = 'HST'
        SELECT @active = 'N'
    END               
-- PTS 26849 -- BL (end)
--end 26528
*/              
     /* Now lets get the driver information */
     SELECT @mpp_teamleader = mpp_teamleader,
            @mpp_fleet = mpp_fleet,
            @mpp_division = mpp_division,
            @mpp_domicile = mpp_domicile,
            @mpp_company = mpp_company,
            @mpp_terminal = mpp_terminal,
            @mpp_type1 = mpp_type1,
            @mpp_type2 = mpp_type2,
            @mpp_type3 = mpp_type3,
            @mpp_type4 = mpp_type4
       FROM manpowerprofile
      WHERE mpp_id = @driver1

     /* Now lets get tractor information */
     SELECT @trc_company = trc_company,
            @trc_division = trc_division,
            @trc_fleet = trc_fleet,
            @trc_terminal = trc_terminal,
            @trc_type1 = trc_type1,
            @trc_type2 = trc_type2,
            @trc_type3 = trc_type3,
            @trc_type4 = trc_type4
       FROM tractorprofile
      WHERE trc_number = @tractor

     BEGIN TRAN updmove
     -- DSK 9/26/2000 -- 8990 put it back, lgh_primary_trailer not getting set in dispatch
     -- JET - 9/15/2000 - 8935, removed update_trlonlgh stored proc, code done in dispatch before save.
     -- dsk split pups 4.0  3/5/98 added @splitpup arg

     --EXECUTE @ret = update_trlonlgh @minlgh, @trailer OUT, @trailer2 OUT, @splitpup OUT
		EXECUTE @ret = update_trlonlgh @minlgh, @trailer OUT, @trailer2 OUT, @splitpup OUT, @chassis OUT, @chassis2 OUT, @dolly OUT, @dolly2 OUT, @trailer3 OUT, @trailer4 OUT

     IF @ret != 0 GOTO ERROR_EXIT
     IF @trailer IS NULL
        SELECT @trailer = 'UNKNOWN'
     IF @trailer2 IS NULL
        SELECT @trailer2 = 'UNKNOWN'
     --JLB PTS 49323
     IF @chassis IS NULL
        SELECT @chassis = 'UNKNOWN'
     IF @chassis2 IS NULL
        SELECT @chassis2 = 'UNKNOWN'
     IF @dolly IS NULL
        SELECT @dolly = 'UNKNOWN'
     IF @dolly2 IS NULL
        SELECT @dolly2 = 'UNKNOWN'
     IF @trailer3 IS NULL
        SELECT @trailer3 = 'UNKNOWN'
     IF @trailer4 IS NULL
        SELECT @trailer4 = 'UNKNOWN'
     --end 49323

     -- dsk split pups 4.0  3/5/98  if splitting, setting idx to 0 resets
     -- for finding the primary trailer for subsequent legheaders
     IF @splitpup = 'Y'
        SELECT @idx = 0

     /* Now lets get trailer information*/
     SELECT @trl_company = trl_company,
            @trl_fleet = trl_fleet,
            @trl_division = trl_division,
            @trl_terminal = trl_terminal,
            @trl_type1 = trl_type1,
            @trl_type2 = trl_type2,
            @trl_type3 = trl_type3,
            @trl_type4 = trl_type4
       FROM trailerprofile
      WHERE trl_id = @trailer

      /*PTS15337 MBR 8/28/02*/
	-- KMM PTS 19907, isnull the stp_glh_meilage to avoid null aggregate
     SELECT @lgh_mileage = Sum(isnull(stp_lgh_mileage,0))
         FROM stops
       WHERE lgh_number = @minlgh

      /*PTS15375 MBR 8/30/02*/
     /*PTS17024 MBR 2/06/03*/
     /*PTS19375 MBR 08/13/03*/
     SELECT @lgh_linehaul = Sum(ISNULL(ord_totalcharge,0)),
	    @lgh_ord_charge = Sum(ISNULL(ord_charge,0)),
	    @lgh_est_weight = SUM(ISNULL(ord_totalweight,0)),
	    @lgh_act_weight = SUM(ISNULL(ord_tareweight,0)),
	    @lgh_tot_weight = SUM(ISNULL(NULLIF(ord_tareweight, 0), ord_totalweight))
          FROM orderheader
      WHERE ord_hdrnumber = @mov

     /* insert lgh if nof, update if exists */

     /* Find if this legheader exists in the legheader table. */
     IF (SELECT COUNT(*) FROM legheader WHERE legheader.lgh_number = @minlgh) = 0
     BEGIN
          /* If it does not then insert one with the above found values and instatus as 
             UNP and fueltaxstatus as NPD and lgh_type1 as UNK. */
          INSERT INTO legheader 
		(lgh_number, ord_hdrnumber, mov_number, lgh_priority, 
		lgh_schdtearliest, lgh_schdtlatest, cmd_code, fgt_description, 
		lgh_outstatus, lgh_instatus, lgh_fueltaxstatus, lgh_active, 
		lgh_class1, lgh_class2, lgh_class3, lgh_class4, lgh_type1,
		cmp_id_start, lgh_startcty_nmstct, lgh_startcity, stp_number_start, 
		lgh_startstate, lgh_startdate, 
		lgh_startregion1, lgh_startregion2, lgh_startregion3, lgh_startregion4,
		cmp_id_end, lgh_endcty_nmstct, lgh_endcity, stp_number_end,
		lgh_endstate, lgh_enddate, lgh_enddate_arrival,
		lgh_endregion1, lgh_endregion2, lgh_endregion3, lgh_endregion4,
		lgh_driver1, lgh_driver2, mpp_teamleader, mpp_fleet, 
		mpp_division, mpp_domicile, mpp_company, mpp_terminal, 
		mpp_type1, mpp_type2, mpp_type3, mpp_type4,
		lgh_tractor, trc_company, trc_division, trc_fleet, trc_terminal,
		trc_type1, trc_type2, trc_type3, trc_type4,
		lgh_primary_trailer, lgh_primary_pup, 
		trl_company, trl_fleet, trl_division, trl_terminal, 
		trl_type1, trl_type2, trl_type3, trl_type4, 
		lgh_carrier, lgh_createdby, lgh_createdon, lgh_createapp,
		lgh_updatedby, lgh_updatedon, lgh_updateapp, lgh_odometerstart, lgh_odometerend,
		lgh_startlat, lgh_startlong, lgh_endlat, lgh_endlong,
		lgh_rstartlat, lgh_rstartlong, lgh_rendlat, lgh_rendlong,
		lgh_rstartdate, lgh_rstartcity, cmp_id_rstart, stp_number_rstart,
		lgh_renddate, lgh_rendcity, cmp_id_rend, stp_number_rend,
		lgh_rstartregion1, lgh_rstartregion2, lgh_rstartregion3, lgh_rstartregion4,
		lgh_rstartstate, lgh_rstartcty_nmstct,
		lgh_rendregion1, lgh_rendregion2, lgh_rendregion3, lgh_rendregion4,
		lgh_rendstate, lgh_rendcty_nmstct, lgh_split_flag, lgh_miles, lgh_linehaul, lgh_ord_charge,
		lgh_act_weight, lgh_est_weight, lgh_tot_weight, lgh_hzd_cmd_class, /*PTS 23162*/
		lgh_originzip, lgh_destzip, lgh_route, lgh_booked_revtype1,
		lgh_chassis, lgh_chassis2, lgh_dolly, lgh_dolly2, lgh_trailer3, lgh_trailer4)
          VALUES (@minlgh, @ordnum, @mov, @pri, 
		@early, @late, @cmd, @desc, 
		@stat, @instat, 'NPD', @active, 
		@type1, @type2, @type3, @type4, 'UNK', 
		@startcomp, @lgh_startcty_nmstct, @startcity, @startstop, 
		@lgh_startstate, @startdate, 
		@lgh_startregion1, @lgh_startregion2, @lgh_startregion3, @lgh_startregion4,
		@endcomp, @lgh_endcty_nmstct, @endcity, @endstop,
		@lgh_endstate, @enddate, @lgh_enddate_arrival,
		@lgh_endregion1, @lgh_endregion2, @lgh_endregion3, @lgh_endregion4, 
		@driver1, @driver2, @mpp_teamleader, @mpp_fleet, 
		@mpp_division, @mpp_domicile, @mpp_company, @mpp_terminal, 
		@mpp_type1, @mpp_type2, @mpp_type3, @mpp_type4,
		@tractor, @trc_company, @trc_division, @trc_fleet, @trc_terminal, 
		@trc_type1, @trc_type2, @trc_type3, @trc_type4,
		@trailer, @trailer2, 
		@trl_company, @trl_fleet, @trl_division, @trl_terminal, 
		@trl_type1, @trl_type2, @trl_type3, @trl_type4, 
		@carrier, @tmwuser, getdate(), app_name(),
		@tmwuser, getdate(), app_name(), @lgh_odometerstart, @lgh_odometerend,
		@startlat, @startlon, @endlat, @endlon,
		@revstartlat, @revstartlon, @revendlat, @revendlon,
		@revstartdate, @revstartcity, @revstartcomp, @revstartstop,
		@revenddate, @revendcity, @revendcomp, @revendstop,
		@lgh_revstartregion1, @lgh_revstartregion2, @lgh_revstartregion3, @lgh_revstartregion4,
		@lgh_revstartstate, @lgh_revstartcty_nmstct,
		@lgh_revendregion1, @lgh_revendregion2, @lgh_revendregion3, @lgh_revendregion4,
		@lgh_revendstate, @lgh_revendcty_nmstct, 'N', @lgh_mileage, @lgh_linehaul, @lgh_ord_charge,
		@lgh_act_weight, @lgh_est_weight, @lgh_tot_weight, @lgh_hzd_cmd_class, /*PTS 23162*/  --added split flag to remove lgh active call
		@originzip, @destzip, @route, @booked_revtype1,@chassis, @chassis2, @dolly, @dolly2, @trailer3, @trailer4)
          IF @@error != 0 GOTO ERROR_EXIT
     END 
     ELSE
     BEGIN
          -- JET - 8/18/99 - PTS #6222, store the last tractor used on this segment
	  SELECT @lghtractor = lgh_tractor 
            FROM legheader
           WHERE lgh_number = @minlgh
          -- JET - 8/18/99 - PTS #6222

	  /* PTS15115 MBR 8/08/02 Atlas change that will let the user manually set the class types of the legheader
              instead of using the order rev_types.  If they have done this, lgh_manuallysettypeclass will be set to 1 */
          SELECT @lgh_manuallysettypeclass = lgh_manuallysettypeclass
            FROM legheader
           WHERE lgh_number = @minlgh
          IF @lgh_manuallysettypeclass = 1 
          BEGIN
               SELECT @type1 = lgh_class1,
                      @type2 = lgh_class2,
                      @type3 = lgh_class3,
                      @type4 = lgh_class4
                 FROM legheader
                WHERE lgh_number = @minlgh
          END
		--	LOR	PTS# 28194(27341)
			SELECT @booked_revtype1 = lgh_booked_revtype1
            FROM legheader
            WHERE lgh_number = @minlgh
		--	LOR
          /* lgh on file, so update it */
          UPDATE legheader 
             SET ord_hdrnumber = @ordnum, 
		lgh_priority = @pri, 
		lgh_schdtearliest = @early, 
		lgh_schdtlatest = @late, 
		cmd_code = @cmd, 
		fgt_description = @desc, 
		lgh_outstatus = @stat, 
		lgh_instatus = @instat, 
		lgh_class1 = @type1, 
		lgh_class2 = @type2, 
		lgh_class3 = @type3,
		lgh_class4 = @type4,
		cmp_id_start = @startcomp, 
		lgh_startcty_nmstct = @lgh_startcty_nmstct, 
		lgh_startcity = @startcity, 
		stp_number_start = @startstop, 
		lgh_startstate = @lgh_startstate, 
		lgh_startdate = @startdate, 
		lgh_startregion1 = @lgh_startregion1, 
		lgh_startregion2 = @lgh_startregion2, 
		lgh_startregion3 = @lgh_startregion3, 
		lgh_startregion4 = @lgh_startregion4, 
		cmp_id_end = @endcomp, 
		lgh_endcty_nmstct = @lgh_endcty_nmstct, 
		lgh_endcity = @endcity, 
		stp_number_end = @endstop, 
		lgh_endstate = @lgh_endstate, 
		lgh_enddate = @enddate, 
		lgh_enddate_arrival = @lgh_enddate_arrival, 
		lgh_endregion1 = @lgh_endregion1, 
		lgh_endregion2 = @lgh_endregion2, 
		lgh_endregion3 = @lgh_endregion3, 
		lgh_endregion4 = @lgh_endregion4, 
		lgh_driver1 = @driver1, 		
		lgh_driver2 = @driver2, 
		mpp_teamleader = @mpp_teamleader, 
		mpp_fleet = @mpp_fleet, 
		mpp_division = @mpp_division, 
		mpp_domicile = @mpp_domicile, 
		mpp_company = @mpp_company, 
		mpp_terminal = @mpp_terminal, 
		mpp_type1 = @mpp_type1, 
		mpp_type2 = @mpp_type2, 
		mpp_type3 = @mpp_type3, 
		mpp_type4 = @mpp_type4, 
		lgh_tractor = @tractor, 
		trc_company = @trc_company, 
		trc_division = @trc_division, 
		trc_fleet = @trc_fleet, 
		trc_terminal = @trc_terminal, 
		trc_type1 = @trc_type1, 
		trc_type2 = @trc_type2, 
		trc_type3 = @trc_type3, 
		trc_type4 = @trc_type4, 
		lgh_primary_trailer = @trailer, 
		lgh_primary_pup = @trailer2, 
		trl_company = @trl_company, 
		trl_fleet = @trl_fleet, 
		trl_division = @trl_division, 
		trl_terminal = @trl_terminal, 
		trl_type1 = @trl_type1, 
		trl_type2 = @trl_type2, 
		trl_type3 = @trl_type3, 
		trl_type4 = @trl_type4, 
		lgh_carrier = @carrier,
		lgh_odometerstart  = @lgh_odometerstart,
		lgh_odometerend = @lgh_odometerend,
		lgh_startlat = @startlat,
		lgh_startlong = @startlon,
		lgh_endlat = @endlat,
		lgh_endlong = @endlon,
		lgh_rstartlat = @revstartlat,
		lgh_rstartlong = @revstartlon,
		lgh_rendlat = @revendlat,
		lgh_rendlong = @revendlon,
		lgh_rstartdate = @revstartdate,
		lgh_rstartcity = @revstartcity,
		cmp_id_rstart = @revstartcomp,
		stp_number_rstart = @revstartstop,
		lgh_renddate = @revenddate,
		lgh_rendcity = @revendcity,
		cmp_id_rend = @revendcomp,
		stp_number_rend = @revendstop,
		lgh_rstartregion1 = @lgh_revstartregion1,
		lgh_rstartregion2 = @lgh_revstartregion2,
		lgh_rstartregion3 = @lgh_revstartregion3,
		lgh_rstartregion4 = @lgh_revstartregion4,
		lgh_rstartstate = @lgh_revstartstate,
		lgh_rstartcty_nmstct = @lgh_revstartcty_nmstct,
		lgh_rendregion1 = @lgh_revendregion1,
		lgh_rendregion2 = @lgh_revendregion2,
		lgh_rendregion3 = @lgh_revendregion3,
		lgh_rendregion4 = @lgh_revendregion4,
		lgh_rendstate = @lgh_revendstate,
		lgh_rendcty_nmstct = @lgh_revendcty_nmstct,
		lgh_miles = @lgh_mileage,
		lgh_linehaul = @lgh_linehaul,
		lgh_ord_charge = @lgh_ord_charge,
		lgh_act_weight = @lgh_act_weight,
		lgh_est_weight = @lgh_est_weight,
		lgh_tot_weight = @lgh_tot_weight,
		lgh_hzd_cmd_class = @lgh_hzd_cmd_class, /*PTS 23162*/
		lgh_originzip = @originzip,
		lgh_destzip = @destzip,
		lgh_route = @route,
		lgh_booked_revtype1 = @booked_revtype1,
		lgh_chassis = @chassis,
		lgh_chassis2 = @chassis2,
		lgh_dolly = @dolly,
		lgh_dolly2 = @dolly2,
		lgh_trailer3 = @trailer3,
		lgh_trailer4 = @trailer4
           WHERE lgh_number = @minlgh
               
          IF @@error != 0 GOTO ERROR_EXIT
     END

	 /*FMM begin
     /* PTS # 4283 change order of calls to update assign and instatus */
     /* compute instatus */
     IF @tractor <> 'UNKNOWN'
     BEGIN
          EXECUTE @ret = instatus @tractor 	
          IF @ret != 0 GOTO ERROR_EXIT
     END

     -- JET - 8/18/99 - PTS #6222, added code to run instatus on the old tractor
     -- assigned to this legheader (if any)
     IF @lghtractor IS NULL
        SELECT @lghtractor = 'UNKNOWN'

     IF @tractor <> @lghtractor AND @lghtractor <> 'UNKNOWN'
     BEGIN
          EXECUTE @ret = instatus @lghtractor
          IF @ret != 0 GOTO ERROR_EXIT
     END
     -- JET - 8/18/99 - PTS #6222

     /* set the instatus of the current legheader to HST if any non-board carriers exist on 
        the events. */
-- RE - 11/19/02 - PTS #16261 Start
--     IF (SELECT COUNT(*) 
--           FROM event e, stops s, carrier c 
--          WHERE s.stp_number = e.stp_number 
--                AND s.lgh_number = @minlgh
--                AND e.evt_carrier = c.car_id
--                AND c.car_board = 'N') > 0
     IF EXISTS(SELECT c.car_id
           FROM event e, stops s, carrier c 
          WHERE s.stp_number = e.stp_number 
                AND s.lgh_number = @minlgh
                AND e.evt_carrier = c.car_id
                AND c.car_board = 'N'
				AND	c.car_id <> 'UNKNOWN')
-- RE - 11/19/02 - PTS #16261 End
     BEGIN
          UPDATE legheader 
             SET lgh_instatus = 'HST' 
           WHERE lgh_number = @minlgh 
	
          IF @@error != 0 GOTO ERROR_EXIT
     END

     /*mf 11/12/97 set active flag for legheader*/
     SELECT @check_instatus = lgh_instatus, 
            @check_outstatus = lgh_outstatus,
            @check_active = lgh_active
       FROM legheader
      WHERE lgh_number = @minlgh
     /*always set flag*/
     IF @check_instatus = 'HST' AND (@check_outstatus = 'CMP' OR @check_outstatus = 'SIT')
        SELECT @lgh_active = 'N'
     ELSE
        SELECT @lgh_active = 'Y'
	
     IF ISNULL(@check_active,'X') <> @lgh_active 
     /*only update if flag is different*/
     UPDATE legheader
        SET lgh_active = @lgh_active 
      WHERE lgh_number = @minlgh
     /*END mf 11/12/97 set active flag for legheader*/

     /* set current activity info on the driver  */
     IF @driver1 IS NOT NULL
     BEGIN
          EXECUTE @ret = drv_expstatus @driver1
          IF @ret != 0 GOTO ERROR_EXIT
     END

     /* set current activity info on the driver2  */
     IF @driver2 IS NOT NULL
     BEGIN
          EXECUTE @ret = drv_expstatus @driver2
          IF @ret != 0 GOTO ERROR_EXIT
     END

     /* set current activity info on the tractor  */
     IF @tractor IS NOT NULL
     BEGIN
          EXECUTE @ret = trc_expstatus @tractor
          IF @ret != 0 GOTO ERROR_EXIT
     END

     EXECUTE @ret = update_trlstatus @minlgh
     IF @ret != 0 GOTO ERROR_EXIT
	 FMM end */

ERROR_EXIT:
     IF @@error != 0 
     BEGIN
          ROLLBACK TRAN updmove
          RETURN (@@error)
     END
     ELSE
     BEGIN
          COMMIT TRAN updmove 
          IF @@error != 0
          BEGIN
               ROLLBACK TRAN updmove
               RETURN (@@error)
          END
     END

     /* kpm 7/14/01 added to pass legheader miles to tmt*/
/* MRH No longer done here now done in an external proc
     SELECT @shoplink = COUNT(*) FROM generalinfo where gi_name = 'Shoplink' and gi_integer1 = 1
     IF @shoplink > 0
     BEGIN
        select @lgh_miles = sum (stp_lgh_mileage) from stops where lgh_number = @minlgh
     
        IF @lgh_miles is null
            select @lgh_miles = 0
     
        select @tmtserver = '[' + gi_string1 + ']' from generalinfo where gi_name = 'Shoplink'
        select @tmtdb = '[' + gi_string2 + ']' from generalinfo where gi_name = 'Shoplink'
        SET @METERTYPE = 'DISPATCH'
        SET @METERDATE = CONVERT(varchar(10), GetDate(), 101)
        SET @SQL= 'declare @P integer   EXEC ' + @tmtserver + '.' + @tmtdb + '.DBO.SP_METERMAID_INSERT  ''' + @tractor + ''',''' + @METERTYPE + ''',' + CAST(@lgh_miles AS VARCHAR(20)) 
                           + ',''' + CONVERT(VARCHAR(24),@METERDATE) + ''''
        EXEC (@SQL)
     END	*/
END
--TRUNCATE TABLE #tmp
-- KMM PTS 19907, delete table var instead of truncate temp table
DELETE @tmp

EXEC update_assetassignment @mov
/* FMM begin
/* Now make sure any legheaders that no longer have valid stops are deleted */

SELECT @minlgh = 0

INSERT INTO @tmp 
	SELECT lgh_number 
	  FROM stops 
	 WHERE mov_number = @mov 
	       AND stp_status = 'NON' /*option (keepfixed plan)*/

WHILE 2=2
BEGIN
     /* Delete all legheaders on the move which have atleast 1 stop as NON */
     SELECT @minlgh = MIN(lgh_number) 
       FROM @tmp
      WHERE lgh_number > @minlgh /*option (keepfixed plan)*/

     IF @minlgh IS NULL
        BREAK

     DELETE legheader
      WHERE lgh_number = @minlgh
     IF @@error != 0 GOTO ERROR_EXIT

     /* set assets to UNKNOWN for all primary events on stops which are NON */
     UPDATE event
        SET evt_driver1 = 'UNKNOWN',
            evt_driver2 = 'UNKNOWN',
            evt_tractor = 'UNKNOWN',
            evt_trailer1 = 'UNKNOWN',
            evt_trailer2 = 'UNKNOWN',
            evt_carrier = 'UNKNOWN'
       FROM stops s, event e
      WHERE s.stp_number = e.stp_number
            AND s.lgh_number = @minlgh
     IF @@error != 0 GOTO ERROR_EXIT
END

/* Now delete those legheaders on the move  which are not referenced by stops that are on the 
   move */
DELETE legheader 
 WHERE mov_number = @mov
       AND lgh_number NOT IN (SELECT lgh_number 
				FROM stops 
                               WHERE mov_number = @mov)
IF @@error != 0 GOTO ERROR_EXIT


-- MRH 30923
-- Third party default assignments
Declare
@ord_number char(12),
@ord_billto char(8)
Select @lgh = min(lgh_number) from stops where ord_hdrnumber = (SELECT MIN(ord_hdrnumber) FROM stops WHERE mov_number = @mov and ord_hdrnumber <> 0)
select @ord_number = ord_number, @ord_billto = ord_billto from orderheader where ord_hdrnumber = (SELECT MIN(ord_hdrnumber) FROM stops WHERE mov_number = @mov and ord_hdrnumber <> 0)
if (select count(0) from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto) > 0
begin
	if (select count(0) from thirdpartyassignment where ord_number = @ord_number) = 0
	begin
		insert into thirdpartyassignment
		(tpr_id, lgh_number, mov_number, tpa_status, pyd_status, tpr_type, ord_number)
		select tpr_id, @lgh, @mov, 'AUTO', NULL, tpr_type, @ord_number from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto;
	end 
	else -- Check to see if it should be updated
	begin
		if (select count(0) from thirdpartyassignment where ord_number = @ord_number and tpr_id in (select tpr_id from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto)) = 0
		begin
			-- No matches found the billto probably changed.
			-- Delete the existing that were not manually added and add the default
			delete from thirdpartyassignment where ord_number = @ord_number and tpa_status <> 'DEL'
			insert into thirdpartyassignment
			(tpr_id, lgh_number, mov_number, tpa_status, pyd_status, tpr_type, ord_number)
			select tpr_id, @lgh, @mov, 'AUTO', NULL, tpr_type, @ord_number from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto;
		end
	end
end

/*MF pts 8060 removed asset assignment code now handled by update_assetassignment*/
--mf EXECUTE consolidate_trl_assns @mov	-- TD 11/25/98 Handle trailer consolidations.

FMM end */
EXECUTE set_split_flag @mov	-- LOR 12/22/99 

/*FMM begin
EXECUTE reset_loadrequirements_sp  @mov -- dpete pts6419 5/03/00 

--JLB PTS 31744 only run the permit reset if the feature is turned on
select @vs_reset_permit_req = isnull(left(rtrim(ltrim(gi_string1)),1), 'N')
  from generalinfo
 where gi_name = 'CheckPermitRequirementsOnSave'
if isnull(@vs_reset_permit_req, 'N') = 'Y'
begin
   EXECUTE reset_permitrequirements_sp @mov  --JLB pts28373
end
FMM end */

EXECUTE checkfreightdetails @mov -- tdigi pts11428 7/10/01

/*FMM begin
--DWG {31262) Fix order sequences (stp_sequence) on stops for move.
select @vs_fix_order_seq = isnull(left(rtrim(ltrim(gi_string1)),1), 'N')
  from generalinfo
 where gi_name = 'FixOrderSequences'
if isnull(@vs_fix_order_seq, 'N') = 'Y'
begin
   EXECUTE Fix_Order_Sequences @mov  --DWG pts31262
end

-- DPH, 7/29/03, added postprocessing call to support export of orders upon save,
-- in standard TMW Code update_move_postprocessing has 1 line of code:  RETURN
-- PTS 18902
if @updatemovepostprocessing = 'Y'
	execute update_move_postprocessing @mov

--DPH PTS 27213 6/9/05
--	LOR	PTS# 28465	list of pending statuses
If @DisplayPendingOrders = 'Y'
 BEGIN
	DECLARE @temp TABLE (ord_hdrnumber int NULL,
						ord_status	varchar(6) null)
	INSERT INTO @temp 
	SELECT DISTINCT ord_hdrnumber, ord_status
	FROM 	orderheader
	WHERE mov_number = @mov AND	
		charindex(ord_status, @pending_statuses) > 0
	
	If (select count(*) from @temp) > 0
		UPDATE 	legheader
		SET lgh_outstatus = t.ord_status
		From @temp t
		WHERE	legheader.ord_hdrnumber = t.ord_hdrnumber
	
--	UPDATE 	legheader
--	SET 	lgh_outstatus = 'PND'
--	WHERE	ord_hdrnumber in (SELECT DISTINCT(ord_hdrnumber)
--				  FROM 	orderheader
--				  WHERE mov_number = @mov
--				  AND	ord_status = 'PND')
 END
--	LOR
	
--PTS 26575	JZ	6/20/2005	Add to the transaction queue when Fuel Interface is installed
IF (SELECT UPPER(SUBSTRING(gi_string1, 1, 1)) FROM generalinfo
    WHERE gi_name = 'CDI') = 'Y'
	exec fuel_transaction_queue @mov	

--PTS 30006 DPH 4/17/06  Add to the tch trancaction queue when the TCH Real-Time Interface is installed
SELECT 	@tchrealtime_status = UPPER(gi_string1),
		@tchrealtime_tractor = UPPER(gi_string2),
		@tchrealtime_trailer = UPPER(gi_string3),
		@tchrealtime_trip = UPPER(gi_string4)
FROM 		generalinfo
WHERE	gi_name = 'TCHRealTime'
   
IF @tchrealtime_status = 'Y' or @tchrealtime_tractor = 'Y' or @tchrealtime_trailer = 'Y' or @tchrealtime_trip = 'Y'
 BEGIN
	exec tch_transaction_queue @mov, @tchrealtime_status, @tchrealtime_tractor, @tchrealtime_trailer, @tchrealtime_trip
 END
--PTS 30006 DPH 4/17/06 
FMM end */

RETURN
GO
GRANT EXECUTE ON  [dbo].[completion_update_move] TO [public]
GO
