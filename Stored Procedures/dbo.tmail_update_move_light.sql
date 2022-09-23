SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- JET - 3/8/99 - PTS #5237, made a copy of update_move and removed any calls/updates not 
--	necessary for dispatch.
-- JET, 9/24/99 - PTS #5762, looked for ways to reduce I/O
-- MZ 02/22/02 Made copy of update_move_light for TotalMail

CREATE PROCEDURE [dbo].[tmail_update_move_light] (@mov int)

AS 

SET NOCOUNT ON

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
	@startcomp 		varchar(25),--PTS 61189 CMP_ID INCREASE LENGTH TO 25
	@startstop 		int,
	@enddate 		datetime,
	@oldenddate     	datetime,
	@endcity 		int,
	@endcomp 		varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
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
	@revstartcomp 		varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
	@revstartstop 		int,
	@revenddate 		datetime,
	@revendcity 		int,
	@revendcomp 		varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
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
        @shoplink               int

CREATE TABLE #tmp (lgh_number int NULL)

/* make sure legheaders exists for actual stops */

SELECT @active = 'Y'

SELECT @minlgh = 0

SELECT @idx = 0

/* get the max order hdr on the move */
SELECT @ordnum = (SELECT MAX(ord_hdrnumber) 
                    FROM stops (NOLOCK)
                   WHERE mov_number = @mov)

/* get the lowest priority number on the orders on the move */
SELECT @pri = MIN(ord_priority) 
  FROM orderheader (NOLOCK)
 WHERE ord_hdrnumber in
	(SELECT ord_hdrnumber 
	FROM stops (NOLOCK)
	WHERE mov_number = @mov)

SET ROWCOUNT 1
/* get rev type1 to type4 from the orderheader on the move */
SELECT @type1 = ord_revtype1, 
       @type2 = ord_revtype2, 
       @type3 = ord_revtype3, 
       @type4 = ord_revtype4 
  FROM orderheader (NOLOCK)
 WHERE ord_hdrnumber = @ordnum 

/* get commodity code and description from the stops on the move */
SELECT @cmd = cmd_code,
       @desc = stp_description
  FROM stops (NOLOCK)
 WHERE mov_number = @mov  and ord_hdrnumber+0 > 0 
       AND stp_description <> 'UNKNOWN'
SET ROWCOUNT 0

IF @cmd IS NULL
BEGIN
     SELECT @cmd = 'UNK'
     SELECT @desc = 'UNKNOWN'
END

INSERT INTO #tmp 
     SELECT lgh_number 
       FROM stops (NOLOCK)
      WHERE mov_number = @mov 
            AND stp_status <> 'NON' /*option (keepfixed plan)*/

/* Loop for all legheaders which have all 'NON' stops, on the passed move */
WHILE 1=1
BEGIN
     SELECT @idx = @idx + 1

     SELECT @minlgh = MIN(lgh_number) 
       FROM #tmp
      WHERE lgh_number > @minlgh /*option (keepfixed plan)*/
            
     IF @minlgh IS NULL
        BREAK

     -- vjh get update lgh with start and end hub readings
     SELECT @event_max_odometer = MAX(evt_hubmiles ), @event_min_odometer = MIN(evt_hubmiles )
       FROM stops s (NOLOCK), event e (NOLOCK)
      WHERE s.mov_number = @mov
            AND s.lgh_number = @minlgh
            AND s.stp_number=e.stp_number
            AND ISNULL(evt_hubmiles, 0) <> 0

     select @lgh_odometerstart = lgh_odometerstart, @lgh_odometerend = lgh_odometerend
        from legheader (NOLOCK)
        where lgh_number = @minlgh

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

     /* get the max & min stop mfh_sequence for the current leghdr */
     SELECT @maxseq = MAX(stp_mfh_sequence), @minseq = MIN(stp_mfh_sequence)
       FROM stops (NOLOCK)
      WHERE mov_number = @mov
            AND lgh_number = @minlgh

     /* vjh pts6798 get the max & min stop mfh_sequence for the current leghdr for revenue stops */
     SELECT @maxrevseq = MAX(stp_mfh_sequence), @minrevseq = MIN(stp_mfh_sequence)
       FROM stops (NOLOCK)
      WHERE mov_number = @mov
            AND lgh_number = @minlgh
            AND ord_hdrnumber <> 0

     -- JET - 9/30/00 - PTS #8737, found asset assignments from the event table.  It has been updated by the time this procedure is
     -- run, the asset assignments have not been made/updated until the bottom of this procedure per Mark F's changes.
     /*MF removed AND a.asgn_controlling = 'Y' because even if it is not controlling it should be counted*/
     SELECT @asgns = COUNT(*) 
     --  FROM event e, assetassignment a, stops s
       FROM event e (NOLOCK), stops s (NOLOCK)
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

     SELECT @opn = COUNT(*) 
       FROM stops (NOLOCK)
      WHERE lgh_number = @minlgh 
            AND stp_status = 'OPN' 

     IF @opn = 0 
        SELECT @stat = 'CMP'
     ELSE
     BEGIN
        SELECT @cls = COUNT(*) 
          FROM stops (NOLOCK)
         WHERE lgh_number = @minlgh 
               AND stp_status = 'DNE'

        IF @cls = 0
           SELECT @stat = 'AVL'
        ELSE
           SELECT @stat = 'STD'
     END

     -- KM PTS 7682 - MPN_COUNT is used to see if this load is actively multiplanned
     SELECT @mpn_count = count(*) 
     FROM preplan_assets (NOLOCK)
     WHERE ppa_lgh_number = @minlgh AND
    ppa_status = 'Active'

     IF @stat = 'AVL' AND (@asgns > 0 OR @mpn_count > 0)
     BEGIN
        /* if have asgnmnts, then is PLN  */
        /* check if @stat should be dsp or pln */
        /* only way to tell if is DSP is if it already was */ 
        IF (SELECT lgh_outstatus 
              FROM legheader (NOLOCK)
             WHERE lgh_number = @minlgh) = 'DSP'
           SELECT @stat = 'DSP'
        ELSE
             IF @mpn_count > 0 
                  SELECT @stat = 'MPN'
            ELSE
                  SELECT @stat = 'PLN'
     END

     SELECT @instat = 'UNP'

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
       FROM event e (NOLOCK), stops s (NOLOCK)
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
       FROM stops (NOLOCK)
      WHERE lgh_number = @minlgh
            AND stp_mfh_sequence = @minseq

     SELECT @lgh_enddate_arrival = stp_departuredate,
            @enddate = stp_departuredate,
            @endcity = stp_city,
            @endstop = stp_number,
            @endcomp = cmp_id 
       FROM stops (NOLOCK)
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
               @revstartcomp = cmp_id
          FROM stops (NOLOCK)
         WHERE lgh_number = @minlgh
               AND stp_mfh_sequence = @minrevseq
        
        SELECT @revenddate = stp_departuredate,
               @revendcity = stp_city,
               @revendstop = stp_number,
               @revendcomp = cmp_id
          FROM stops (NOLOCK)
         WHERE lgh_number = @minlgh
               AND stp_mfh_sequence = @maxrevseq
     end

     SELECT @oldenddate = @enddate

     /* get the enddate from the max stop's primary event and if it is apocalypse then 
        retain the one from the previous select */
     SELECT @enddate = event.evt_enddate
       FROM stops (NOLOCK), event (NOLOCK)
      WHERE stops.stp_number = event.stp_number
            AND stops.mov_number = @mov
            AND stops.lgh_number = @minlgh
            AND stops.stp_mfh_sequence = @maxseq
            AND event.evt_enddate < '20491231'
            AND event.evt_sequence = 1

      IF @enddate IS NULL
         SELECT @enddate = @oldenddate	

      SELECT @type = a.asgn_type,
             @id = a.asgn_id
        FROM event e  (NOLOCK), assetassignment a  (NOLOCK), stops s  (NOLOCK)
       WHERE s.lgh_number = @minlgh
             AND s.stp_number = e.stp_number
             AND a.evt_number = e.evt_number
             AND a.asgn_controlling = 'Y'

      /* 11/5/97 MF Load denormalized columns for legheader table */
      SELECT @lgh_startregion1 = cty_region1,
             @lgh_startregion2 = cty_region2, 
             @lgh_startregion3 = cty_region3, 
             @lgh_startregion4 = cty_region4, 
             @lgh_startstate = cty_state,
             @lgh_startcty_nmstct = cty_nmstct,
             @startlat = round(cty_latitude,0),
             @startlon = round(cty_longitude,0)
       FROM city (NOLOCK)
       WHERE cty_code = @startcity

      SELECT @lgh_endregion1 = cty_region1, 
             @lgh_endregion2 = cty_region2, 
             @lgh_endregion3 = cty_region3, 
             @lgh_endregion4 = cty_region4, 
             @lgh_endstate = cty_state,
             @lgh_endcty_nmstct = cty_nmstct,	
             @endlat = round(cty_latitude,0),
             @endlon = round(cty_longitude,0)	
       FROM city (NOLOCK)
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
         FROM city (NOLOCK)
         WHERE cty_code = @revstartcity
      
         SELECT @lgh_revendregion1 = cty_region1, 
                @lgh_revendregion2 = cty_region2, 
                @lgh_revendregion3 = cty_region3, 
                @lgh_revendregion4 = cty_region4, 
                @lgh_revendstate = cty_state,
                @lgh_revendcty_nmstct = cty_nmstct, 
                @revendlat = round(cty_latitude,0),
                @revendlon = round(cty_longitude,0)	
         FROM city (NOLOCK)
         WHERE cty_code = @revendcity
      end

     /*PTS10130 MBR 4/17/01 Set outstatus to SIT when stp_transfer_type = 'SIT'  */
     SELECT @transfer_type = stp_transfer_type
         FROM stops (NOLOCK)
      WHERE lgh_number = @minlgh
            AND stp_mfh_sequence = @minseq
     IF @transfer_type = 'SIT'
     BEGIN
          SELECT @stat = 'SIT'
          SELECT @instat = 'HST'
          SELECT @active = 'N'
     END
               

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
       FROM tractorprofile (NOLOCK)
      WHERE trc_number = @tractor

     BEGIN TRAN updmove
     -- DSK 9/26/2000 -- 8990 put it back, lgh_primary_trailer not getting set in dispatch
     -- JET - 9/15/2000 - 8935, removed update_trlonlgh stored proc, code done in dispatch before save.
     -- dsk split pups 4.0  3/5/98 added @splitpup arg
     EXECUTE @ret = dbo.update_trlonlgh @minlgh, @trailer OUT, @trailer2 OUT, @splitpup OUT

     IF @ret != 0 GOTO ERROR_EXIT
     IF @trailer IS NULL
        SELECT @trailer = 'UNKNOWN'
     IF @trailer2 IS NULL
        SELECT @trailer2 = 'UNKNOWN'

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
       FROM trailerprofile (NOLOCK)
      WHERE trl_id = @trailer

     /* insert lgh if nof, update if exists */

     /* Find if this legheader exists in the legheader table. */
     IF (SELECT COUNT(*) 
			FROM legheader  (NOLOCK)
			WHERE legheader.lgh_number = @minlgh) = 0
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
lgh_rendstate, lgh_rendcty_nmstct)
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
                  @carrier, system_user, getdate(), app_name(),
                  system_user, getdate(), app_name(), @lgh_odometerstart, @lgh_odometerend,
@startlat, @startlon, @endlat, @endlon,
@revstartlat, @revstartlon, @revendlat, @revendlon,
@revstartdate, @revstartcity, @revstartcomp, @revstartstop,
@revenddate, @revendcity, @revendcomp, @revendstop,
@lgh_revstartregion1, @lgh_revstartregion2, @lgh_revstartregion3, @lgh_revstartregion4,
@lgh_revstartstate, @lgh_revstartcty_nmstct,
@lgh_revendregion1, @lgh_revendregion2, @lgh_revendregion3, @lgh_revendregion4,
@lgh_revendstate, @lgh_revendcty_nmstct)
          IF @@error != 0 GOTO ERROR_EXIT
     END 
     ELSE
     BEGIN
          -- JET - 8/18/99 - PTS #6222, store the last tractor used on this segment
	  SELECT @lghtractor = lgh_tractor 
            FROM legheader (NOLOCK)
           WHERE lgh_number = @minlgh
          -- JET - 8/18/99 - PTS #6222

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
 lgh_rendcty_nmstct = @lgh_revendcty_nmstct

           WHERE lgh_number = @minlgh
               
          IF @@error != 0 GOTO ERROR_EXIT
     END

     /* PTS # 4283 change order of calls to update assign and instatus */
     /* compute instatus */
     IF @tractor <> 'UNKNOWN'
     BEGIN
          EXECUTE @ret = dbo.instatus @tractor 	
          IF @ret != 0 GOTO ERROR_EXIT
     END

     -- JET - 8/18/99 - PTS #6222, added code to run instatus on the old tractor
     -- assigned to this legheader (if any)
     IF @lghtractor IS NULL
        SELECT @lghtractor = 'UNKNOWN'

     IF @tractor <> @lghtractor AND @lghtractor <> 'UNKNOWN'
     BEGIN
          EXECUTE @ret = dbo.instatus @lghtractor
          IF @ret != 0 GOTO ERROR_EXIT
     END
     -- JET - 8/18/99 - PTS #6222

     /* set the instatus of the current legheader to HST if any non-board carriers exist on 
        the events. */
     IF (SELECT COUNT(*) 
           FROM event e (NOLOCK), stops s (NOLOCK), carrier c  (NOLOCK)
          WHERE s.stp_number = e.stp_number 
                AND s.lgh_number = @minlgh
                AND e.evt_carrier = c.car_id
                AND c.car_board = 'N') > 0
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
          EXECUTE @ret = dbo.drv_expstatus @driver1
          IF @ret != 0 GOTO ERROR_EXIT
     END

     /* set current activity info on the driver2  */
     IF @driver2 IS NOT NULL
     BEGIN
          EXECUTE @ret = dbo.drv_expstatus @driver2
          IF @ret != 0 GOTO ERROR_EXIT
     END

     /* set current activity info on the tractor  */
     IF @tractor IS NOT NULL
     BEGIN
          EXECUTE @ret = dbo.trc_expstatus @tractor
          IF @ret != 0 GOTO ERROR_EXIT
     END

     EXECUTE @ret = dbo.update_trlstatus @minlgh
     IF @ret != 0 GOTO ERROR_EXIT

     -- Set the lgh_updatedby fields
     EXECUTE dbo.tmail_lghUpdatedBy @minlgh

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
     SELECT @shoplink = COUNT(*) FROM generalinfo (NOLOCK) where gi_name = 'Shoplink' and gi_integer1 = 1
     IF @shoplink > 0
     BEGIN
        select @lgh_miles = sum (stp_lgh_mileage) from stops where lgh_number = @minlgh
     
        IF @lgh_miles is null
            select @lgh_miles = 0
     
        select @tmtserver = '[' + gi_string1 + ']' from generalinfo where gi_name = 'Shoplink'
        select @tmtdb = '[' + gi_string2 + ']' from generalinfo (NOLOCK) where gi_name = 'Shoplink'
        SET @METERTYPE = 'DISPATCH'
        SET @METERDATE = CONVERT(varchar(10), GetDate(), 101)
        SET @SQL= 'declare @P integer   EXEC ' + @tmtserver + '.' + @tmtdb + '.DBO.SP_METERMAID_INSERT  ''' + @tractor + ''',''' + @METERTYPE + ''',' + CAST(@lgh_miles AS VARCHAR(20)) 
                           + ',''' + CONVERT(VARCHAR(24),@METERDATE) + ''''
        EXEC (@SQL)
     END	*/
END
TRUNCATE TABLE #tmp

/* Now make sure any legheaders that no longer have valid stops are deleted */

SELECT @minlgh = 0

INSERT INTO #tmp 
	SELECT lgh_number 
	  FROM stops (NOLOCK)
	 WHERE mov_number = @mov 
	       AND stp_status = 'NON' /*option (keepfixed plan)*/

WHILE 2=2
BEGIN
     /* Delete all legheaders on the move which have atleast 1 stop as NON */
     SELECT @minlgh = MIN(lgh_number) 
       FROM #tmp
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

/*MF pts 8060 removed asset assignment code now handled by update_assetassignment*/
--mf EXECUTE consolidate_trl_assns @mov	-- TD 11/25/98 Handle trailer consolidations.

EXECUTE dbo.set_split_flag @mov	-- LOR 12/22/99 

EXECUTE dbo.reset_loadrequirements_sp  @mov -- dpete pts6419 5/03/00 

EXECUTE dbo.checkfreightdetails @mov -- tdigi pts11428 7/10/01

RETURN 

GO
GRANT EXECUTE ON  [dbo].[tmail_update_move_light] TO [public]
GO
