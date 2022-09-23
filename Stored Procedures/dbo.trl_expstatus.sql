SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*******************************************************************************************************************************************************
 ** NAME: trl_expstatus
 **
 ** Parameters: 
 **    @trlid VARCHAR(8) - Trailer ID for which status should be set.
 **    @debug INTEGER    - Optional defaults to 0, when zero updates are performed, when anything else select statement with changes instead of update.
 **
 ** General Info Settings
 **    ExpTimeBuffer 
 **        Number of minutes (+ or -) that are added to the current time when looking for active expirations
 **    TrlExpLogic
 **        When Set to Y completed expirations must have a location to be used for available cmp_id and available city
 **        When set to N completed expirations can have no location and will set available cmp_id and avalable city to UNKOWN
 **    ENHANCEDTRAILERPLANNING & ENHANCEDTRAILERPLNSTATUS
 **       When ENHANCEDTRAILERPLANNING set to Y
 **         - looks at all assignments for trailer with statuses in ENHANCEDTRAILERPLNSTATUS and uses the one with the latest assign date 
 **         - status and available based on last assignment with status in list trailer status now AVL, PLN, DSP, STD
 **         - Other special statuses PLNLD, HAV, SPU, SPL
 **       When set to anything else
 **         - only valid trailer status AVL, PLN, USE and is based on current activity only
 **    HookAvailable & hookavailableevents
 **       When HookAvailable set to Y and trailer should be AVL it will be HAV if the last event is in the hookavailableevents
 **    ENHANCEDTRAILERPLNCOMMODITY
 **       When set to Y will get last commodity from the latest assignment with status in ENHANCEDTRAILERPLNSTATUS that has a PUP or DRP stop
 **    USE_EVT_DEPART_FOR_TRL_STATUS
 **       This setting is obsolete now as the asgn_status will look at the departure if you want it to, making it unnecessary to change status here
 **    ExpDontOverwriteWithUnknown
 **       When set to Y will not overwrite available location information that has actual location with unkown information.
 ** Revisions History:
 **   INT-106020 - RJE 03/31/2017 - Rewrote procedure for performance
 **
 *******************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[trl_expstatus]
(
  @trlid  VARCHAR(13),
  @debug  INTEGER = 0
)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @ExpTimeBuffer              INTEGER,
        @CompareDate                DATETIME,
        @TrailerPlanMode            CHAR(1),
        @TrailerPlanStatus          VARCHAR(254),
        @TrailerPlanCommodity       CHAR(1),
        @UseDepartureStatus         CHAR(1),
        @EDOWU                      VARCHAR(254),
        @EDOWU_Condition_Met        CHAR(1),
        @HookAvailable              CHAR(1),
        @HookAvailableEvents        VARCHAR(254),
        @NewTrlExpLogic             CHAR(1),
        @TrailerPlanStatusCodes     TMWTable_char6,
        @CmpStdStatusCodes          TMWTable_char6,
        @PlnDspStatusCodes          TMWTable_char6,
				@PlnDspStdCmpStatusCodes		TMWTable_char6,
        @avllgh                     INTEGER,
        @avlmov                     INTEGER,
        @SplitTrip                  CHAR(1),
        @expcode                    INTEGER,
        @expavldate                 DATETIME,
        @expdate                    DATETIME,
        @expavlcmp                  VARCHAR(8),
        @expavlcity                 INTEGER,
        @expstat                    VARCHAR(6),
        @expabbr                    VARCHAR(6),
        @avlstat                    VARCHAR(6),
        @avldate                    DATETIME,
        @avlcompany                 VARCHAR(8),
        @avlcity                    INTEGER,
        @nextevent                  VARCHAR(6),
        @nextcompany                VARCHAR(8),
        @nextcity                   INTEGER,
        @nextstate                  VARCHAR(6),
        @nextregion1                VARCHAR(6),
        @nextregion2                VARCHAR(6),
        @nextregion3                VARCHAR(6),
        @nextregion4                VARCHAR(6),
        @nextcompanyothertype1      VARCHAR(6),
        @priorevent                  VARCHAR(6),
        @priorcompany                VARCHAR(8),
        @priorcity                   INTEGER,
        @priorstate                  VARCHAR(6),
        @priorregion1                VARCHAR(6),
        @priorregion2                VARCHAR(6),
        @priorregion3                VARCHAR(6),
        @priorregion4                VARCHAR(6),
        @priorcompanyothertype1      VARCHAR(6),
        @trlcmdmove                  INTEGER,
        @trlcmd                      VARCHAR(8),
        @trlcmdord                   INTEGER,
        @trlcmddate                  DATETIME,
        @schdate                     DATETIME,
        @schstat                     VARCHAR(6),
        @schcompany                  VARCHAR(8),
        @schcity                     INTEGER

IF @trlid = 'UNKNOWN'
  RETURN

SELECT  @ExpTimeBuffer = CASE WHEN gi_name = 'ExpTimeBuffer' THEN COALESCE(gi_integer1, 0) ELSE @ExpTimeBuffer END,
        @TrailerPlanMode = CASE WHEN gi_name = 'ENHANCEDTRAILERPLANNING' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @TrailerPlanMode END,
        @TrailerPlanStatus = CASE WHEN gi_name = 'ENHANCEDTRAILERPLNSTATUS' THEN gi_string1 ELSE @TrailerPlanStatus END,
        @UseDepartureStatus = CASE WHEN gi_name = 'USE_EVT_DEPART_FOR_TRL_STATUS' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @UseDepartureStatus END,
        @TrailerPlanCommodity = CASE WHEN gi_name = 'ENHANCEDTRAILERPLNCOMMODITY' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @TrailerPlanCommodity END,
        @EDOWU = CASE WHEN gi_name = 'ExpDontOverwriteWithUnknown' THEN gi_string1 ELSE @EDOWU END,
        @HookAvailable = CASE WHEN gi_name = 'HookAvailable' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @HookAvailable END,
        @HookAvailableEvents = CASE WHEN gi_name = 'hookavailableevents' THEN gi_string1 ELSE @HookAvailableEvents END,
        @NewTrlExpLogic = CASE WHEN gi_name = 'TrlExpLogic' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @NewTrlExpLogic END
  FROM  generalinfo
 WHERE  gi_name IN ('ExpTimeBuffer', 'ENHANCEDTRAILERPLANNING', 'ENHANCEDTRAILERPLNSTATUS', 
                    'TRL_AVL_on_DRL_wout_PUL', 'USE_EVT_DEPART_FOR_TRL_STATUS', 'ENHANCEDTRAILERPLNCOMMODITY', 
                    'ExpDontOverwriteWithUnknown', 'HookAvailable', 'hookavailableevents', 'TrlExpLogic')

INSERT INTO @TrailerPlanStatusCodes 
  SELECT LEFT(value, 6) FROM CSVStringsToTable_fn(COALESCE(@TrailerPlanStatus, ''))  

INSERT INTO @CmpStdStatusCodes 
  SELECT LEFT(value, 6) FROM CSVStringsToTable_fn('CMP,STD')

INSERT INTO @PlnDspStatusCodes 
  SELECT LEFT(value, 6) FROM CSVStringsToTable_fn('PLN,DSP')

INSERT INTO @PlnDspStdCmpStatusCodes 
  SELECT LEFT(value, 6) FROM CSVStringsToTable_fn('PLN,DSP,STD,CMP')

SELECT  @CompareDate = DATEADD(MINUTE, COALESCE(@ExpTimeBuffer, 0), GETDATE()),
        @TrailerPlanMode = COALESCE(@TrailerPlanMode, 'N'),
        @UseDepartureStatus = COALESCE(@UseDepartureStatus, 'N'),
        @TrailerPlanCommodity = COALESCE(@TrailerPlanCommodity, 'N'),
        @EDOWU = ',' + @EDOWU + ',',
        @EDOWU_Condition_Met = 'N',
        @HookAvailable = COALESCE(@HookAvailable, 'N'),
        @HookAvailableEvents = ',' + @HookAvailableEvents + ',',
        @NewTrlExpLogic = COALESCE(@NewTrlExpLogic, 'N')

SELECT  @expcode = ExpirationCode,
        @expavldate = ExpirationEndDate,
        @expdate = ExpirationStartDate,
        @expavlcmp = ExpirationCompany,
        @expavlcity = ExpirationCity,
        @expstat = ExpirationStatus
  FROM  dbo.ExpStatus_GetActiveExpiration_fn('TRL', @trlid, @comparedate, 200, 'TrlExp', 'TrlStatus')

SELECT @expcode = COALESCE(@expcode, 0)

-- Termination (code = 900) takes precedence over everything else
IF @expcode = 900
BEGIN
  IF @debug = 0
    UPDATE  trailerprofile
       SET  trl_status = @expstat,
            trl_avail_date = @expavldate,
            trl_retiredate = @expdate
     WHERE  trl_id = @trlid
       AND  (COALESCE(trl_status, '-98765') <> COALESCE(@expstat, '-98765')
        OR   COALESCE(trl_avail_date, '00000000 00:00') <> COALESCE(@expavldate, '00000000 00:00')
        OR   COALESCE(trl_retiredate, '00000000 00:00') <> COALESCE(@expdate, '00000000 00:00'))
  ELSE
    SELECT  trl_id,
            @expstat trl_status,
            @expavldate trl_avail_date,
			      trl_avail_cmp_id,
			      trl_avail_city,
            trl_last_cmd,
            trl_last_cmd_ord,
            trl_last_cmd_date,
            @expdate trl_retiredate,
			      trl_next_event,
			      trl_next_cmp_id,
			      trl_next_city,
			      trl_next_state,
			      trl_next_region1,
			      trl_next_region2,
			      trl_next_region3,
			      trl_next_region4,
			      trl_next_cmp_othertype1,	
			      trl_prior_event,
			      trl_prior_cmp_id,
			      trl_prior_city,
			      trl_prior_state,
			      trl_prior_region1,
			      trl_prior_region2,
			      trl_prior_region3,
			      trl_prior_region4,
			      trl_prior_cmp_othertype1,
            trl_sch_cmp_id,
            trl_sch_city,
            trl_sch_date,
            trl_sch_status
      FROM  trailerprofile
     WHERE  trl_id = @trlid

  RETURN
END

IF @TrailerPlanMode = 'Y'
BEGIN
  SELECT TOP 1 
          @avlstat = CASE
                       WHEN asgn_status = 'STD' THEN 
                         CASE 
                           WHEN Preload = 'Y' AND PreloadStopStatus = 'DNE' AND PreloadEventStatus = 'OPN' THEN 'SPL'
                           WHEN LastEventEvent = 'PUL' AND LastStopEvent = 'DRL' AND LastEventDepartureStatus = 'OPN' AND LastStopDepartureStatus = 'DNE' THEN 'SPU'
                           ELSE'STD'
                         END
                       WHEN asgn_status = 'CMP' THEN
                         CASE 
                           WHEN @UseDepartureStatus = 'Y' THEN
                             CASE
                               WHEN LastStopDepartureStatus = 'OPN' THEN 'STD'
                               WHEN SplitTrip = 'Y' AND LastAssignment <> 'Y' THEN 'PLNLD'
                               WHEN LastStopEvent = 'DRL' THEN
                                 CASE
                                   WHEN LastEventEvent = 'PUL' AND LastEventDepartureStatus = 'OPN' THEN 'SPU'
                                   ELSE 'AVL'
                                 END
                               WHEN @HookAvailable = 'Y' AND CHARINDEX(',' + LastStopEvent + ',', @HookAvailableEvents) > 0 THEN 'HAV'
                               ELSE 'AVL'
                             END
                           ELSE
                             CASE 
                               WHEN SplitTrip = 'Y' AND LastAssignment <> 'Y' THEN 'PLNLD'
                               WHEN LastStopEvent = 'DRL' THEN
                                 CASE
                                   WHEN LastEventEvent = 'PUL' AND LastEventStatus = 'OPN' THEN 'SPU'
                                   ELSE 'AVL'
                                 END
                               WHEN @HookAvailable = 'Y' AND CHARINDEX(',' + LastStopEvent + ',', @HookAvailableEvents) > 0 THEN 'HAV'
                               ELSE 'AVL'
                             END
                         END
                       ELSE 
                        CASE 
                          WHEN SplitTrip = 'Y' THEN
                            CASE
                              WHEN FistSplitFirstStopStatus = 'DNE' THEN 'PLNLD'
                              ELSE asgn_status
                            END
                          ELSE asgn_status
                        END
                     END
		FROM  TrlExpStatus_GetActivity_fn(@trlid, @PlnDspStdCmpStatusCodes)

  SELECT TOP 1 
          @avldate = CASE WHEN SplitTrip = 'Y' THEN LastSplitAvailableDate ELSE asgn_enddate END,
          @avlcompany = CASE WHEN SplitTrip = 'Y' THEN LastSplitLastStopCompany ELSE AvailableCompany END,
          @avlcity = CASE WHEN SplitTrip = 'Y' THEN LastSplitLastStopCity ELSE AvailableCity END,
          @nextevent = NextEvent,
          @nextcompany = NextCompany,
          @nextcity = NextCity,
          @nextstate = NextState,
          @nextregion1 = NextRegion1,     
          @nextregion2 = NextRegion2,
          @nextregion3 = NextRegion3,
          @nextregion4 = NextRegion4,
          @nextcompanyothertype1 = NextCompanyOtherType1,
          @priorevent = PriorEvent,
          @priorcompany = PriorCompany,
          @priorcity = PriorCity,
          @priorstate = PriorState,
          @priorregion1 = PriorRegion1,     
          @priorregion2 = PriorRegion2,
          @priorregion3 = PriorRegion3,
          @priorregion4 = PriorRegion4,
          @priorcompanyothertype1 = PriorCompanyOtherType1,
          @SplitTrip = SplitTrip,
          @avllgh = lgh_number,
          @avlmov = mov_number
    FROM  TrlExpStatus_GetActivity_fn(@trlid, @TrailerPlanStatusCodes)

  IF @SplitTrip = 'Y'
  BEGIN
    IF 'DNE' = (SELECT TOP 1 
                        stp_status
                  FROM  stops 
                 WHERE  stops.stp_mfh_sequence < (SELECT  stops.stp_mfh_sequence
                                                    FROM  stops
                                                            INNER JOIN event ON event.stp_number = stops.stp_number AND event.evt_sequence = 1 
                                                   WHERE  stops.lgh_number = @avllgh
                                                     AND  stops.stp_event = 'HCT'
                                                     AND  event.evt_trailer1 = @trlid)
                   AND  stops.stp_event = 'HLT'
                ORDER BY stp_mfh_sequence DESC)
    BEGIN
      SET @avlstat = 'PLNLD'
    END
  END

  IF COALESCE(@priorevent, '') = ''
  BEGIN
    SELECT TOP 1 
            @priorevent = PriorEvent,
            @priorcompany = PriorCompany,
            @priorcity = PriorCity,
            @priorstate = PriorState,
            @priorregion1 = PriorRegion1,     
            @priorregion2 = PriorRegion2,
            @priorregion3 = PriorRegion3,
            @priorregion4 = PriorRegion4,
            @priorcompanyothertype1 = PriorCompanyOtherType1
      FROM  TrlExpStatus_GetActivity_fn(@trlid, @CmpStdStatusCodes)
  END
END
ELSE
BEGIN
  SELECT  @avlstat = CASE
                       WHEN asgn_status = 'CMP' THEN
                         CASE 
                           WHEN SplitTrip = 'Y' AND LastAssignment <> 'Y' THEN 'USE'
                           ELSE 'AVL'
                         END
                       ELSE asgn_status
                     END,
          @avldate = CASE WHEN SplitTrip = 'Y' THEN LastSplitAvailableDate ELSE asgn_enddate END,
          @avlcompany = CASE WHEN SplitTrip = 'Y' THEN LastSplitLastStopCompany ELSE AvailableCompany END,
          @avlcity = CASE WHEN SplitTrip = 'Y' THEN LastSplitLastStopCity ELSE AvailableCity END,
          @nextevent = NextEvent,
          @nextcompany = NextCompany,
          @nextcity = NextCity,
          @nextstate = NextState,
          @nextregion1 = NextRegion1,     
          @nextregion2 = NextRegion2,
          @nextregion3 = NextRegion3,
          @nextregion4 = NextRegion4,
          @nextcompanyothertype1 = NextCompanyOtherType1,
          @priorevent = PriorEvent,
          @priorcompany = PriorCompany,
          @priorcity = PriorCity,
          @priorstate = PriorState,
          @priorregion1 = PriorRegion1,     
          @priorregion2 = PriorRegion2,
          @priorregion3 = PriorRegion3,
          @priorregion4 = PriorRegion4,
          @priorcompanyothertype1 = PriorCompanyOtherType1,
          @avllgh = lgh_number,
          @avlmov = mov_number
    FROM  TrlExpStatus_GetActivity_fn(@trlid, @CmpStdStatusCodes)

  SELECT  @schdate = asgn_enddate,
          @schcompany = AvailableCompany,
          @schcity = AvailableCity,
          @schstat = asgn_status
    FROM  TrlExpStatus_GetActivity_fn(@trlid, @PlnDspStatusCodes)
END

IF @TrailerPlanCommodity = 'Y'
BEGIN
  SELECT TOP 1
          @trlcmdmove = aa.mov_number
    FROM  assetassignment aa
            INNER JOIN stops s ON s.mov_number = aa.mov_number
            INNER JOIN event e ON e.stp_number = s.stp_number AND e.evt_sequence = 1 AND e.evt_trailer1 = aa.asgn_id
   WHERE  aa.asgn_type = 'TRL'
     AND  aa.asgn_id = @trlid
     AND  s.stp_type IN ('PUP','DRP')
     AND  aa.asgn_status IN (SELECT * FROM @TrailerPlanStatusCodes)
  ORDER BY aa.asgn_date DESC
END
ELSE
BEGIN
  SET @trlcmdmove = @avlmov
END

IF COALESCE(@trlcmdmove, 0) <> 0
BEGIN
  SELECT TOP 1
          @trlcmd = s.cmd_code,
          @trlcmdord = s.ord_hdrnumber,
          @trlcmddate = s.stp_departuredate
    FROM  stops s
            INNER JOIN event e ON e.stp_number = s.stp_number AND e.evt_sequence = 1
   WHERE  s.mov_number = @avlmov
     AND  s.ord_hdrnumber <> 0
     AND  s.cmd_code <> 'UNKNOWN'
     AND  e.evt_trailer1 = @trlid
  ORDER BY s.stp_mfh_sequence DESC

  IF COALESCE(@trlcmd, 'UNKNOWN') = 'UNKNOWN'
  BEGIN
    SELECT TOP 1
            @trlcmd = oh.cmd_code,
            @trlcmdord = oh.ord_hdrnumber,
            @trlcmddate = s.stp_departuredate
      FROM  stops s
              INNER JOIN event e ON e.stp_number = s.stp_number AND e.evt_sequence = 1
              INNER JOIN orderheader oh ON oh.ord_hdrnumber = s.ord_hdrnumber
     WHERE  s.mov_number = @avlmov
       AND  s.ord_hdrnumber <> 0
       AND  e.evt_trailer1 = @trlid
    ORDER BY s.stp_mfh_sequence DESC    
  END
END
ELSE
BEGIN
  SELECT  @trlcmd = NULL,
          @trlcmdord = NULL,
          @trlcmddate = NULL
END

IF @expcode = 0 
BEGIN
IF @NewTrlExpLogic = 'Y'
    SELECT  @expcode = ExpirationCode,
            @expavldate = ExpirationEndDate,
            @expdate = ExpirationStartDate,
            @expavlcmp = ExpirationCompany,
            @expavlcity = ExpirationCity,
            @expstat = ExpirationStatus,
            @expabbr = ExpirationAbbr
      FROM  dbo.Expstatus_GetCompletedExpirationNew_fn('TRL', @trlid, @comparedate, 200, 'TrlExp') Active
  ELSE
    SELECT  @expcode = ExpirationCode,
            @expavldate = ExpirationEndDate,
            @expdate = ExpirationStartDate,
            @expavlcmp = ExpirationCompany,
            @expavlcity = ExpirationCity,
            @expstat = ExpirationStatus,
            @expabbr = ExpirationAbbr
      FROM  dbo.Expstatus_GetCompletedExpiration_fn('TRL', @trlid, @comparedate, 200, 'TrlExp') Active
END

SELECT  @expcode = COALESCE(@expcode, 0),
        @avllgh = COALESCE(@avllgh, 0)

IF @avllgh > 0 AND @expcode > 0
BEGIN
  IF @avlstat NOT IN ('USE', 'STD', 'PLNLD')
  BEGIN
    IF @expavldate > @avldate OR @expstat <> 'AVL'
    BEGIN
      SELECT  @avlstat = @expstat,
              @avldate = @expavldate,
              @avlcompany = @expavlcmp,
              @avlcity = @expavlcity

      IF CHARINDEX(',' + @expabbr + ',', @EDOWU) > 0 AND COALESCE(@avlcompany, '') = '' AND COALESCE(@avlcity, 0) = 0
      BEGIN
        SET @EDOWU_Condition_Met = 'Y' 
      END
    END
  END
END
ELSE IF @expcode > 0
BEGIN
  SELECT  @avlstat = @expstat,
          @avldate = @expavldate,
          @avlcompany = @expavlcmp,
          @avlcity = @expavlcity

  IF CHARINDEX(',' + @expabbr + ',', @EDOWU) > 0 AND COALESCE(@avlcompany, '') = '' AND COALESCE(@avlcity, 0) = 0
  BEGIN
    SET @EDOWU_Condition_Met = 'Y' 
  END  
END
ELSE IF @expcode = 0 AND @avllgh = 0
BEGIN
  SELECT  @avlstat = CASE WHEN @TrailerPlanMode = 'Y' AND COALESCE(@avlstat, 'AVL') <> 'AVL' THEN @avlStat ELSE 'AVL' END,
          @avldate = '19500101',
          @avlcompany = 'UNKNOWN',
          @avlcity = 0
END

IF @debug = 0
  UPDATE  trailerprofile
	    SET  trl_status = @avlstat,
		      trl_avail_date = @avldate,
		      trl_avail_cmp_id = CASE
			                          WHEN @EDOWU_Condition_Met = 'Y' THEN trl_avail_cmp_id
			                          ELSE @avlcompany 
                              END,
		      trl_avail_city = CASE
			                        WHEN @EDOWU_Condition_Met = 'Y' THEN trl_avail_city
			                        ELSE @avlcity 
                            END,
		      trl_last_cmd = CASE WHEN COALESCE(@trlcmd, 'UNKNOWN') = 'UNKNOWN' THEN trl_last_cmd ELSE @trlcmd END,
		      trl_last_cmd_ord = CASE WHEN COALESCE(@trlcmd, 'UNKNOWN') = 'UNKNOWN' THEN trl_last_cmd_ord ELSE @trlcmdord END,
		      trl_last_cmd_date = CASE WHEN COALESCE(@trlcmd, 'UNKNOWN') = 'UNKNOWN' THEN trl_last_cmd_date ELSE @trlcmddate END,
		      trl_retiredate 		= '20491231 23:59',
		      trl_next_event 		= COALESCE(@nextevent, 'UNK'),
		      trl_next_cmp_id 	= COALESCE(@nextcompany, 'UNKNOWN'),
		      trl_next_city 		= COALESCE(@nextcity, 0),
		      trl_next_state		= COALESCE(@nextstate, 'XX'),
		      trl_next_region1 	= COALESCE(@nextregion1, 'UNK'),
		      trl_next_region2 	= COALESCE(@nextregion2, 'UNK'),
		      trl_next_region3 	= COALESCE(@nextregion3, 'UNK'),
		      trl_next_region4 	= COALESCE(@nextregion4, 'UNK'),
		      trl_next_cmp_othertype1 = COALESCE(@nextcompanyothertype1, 'UNK'),
		      trl_prior_event 	= COALESCE(@priorevent, trl_prior_event),
		      trl_prior_cmp_id 	= COALESCE(@priorcompany, trl_prior_cmp_id),
		      trl_prior_city 		= COALESCE(@priorcity, trl_prior_city),
		      trl_prior_state 	= COALESCE(@priorstate, trl_prior_state),
		      trl_prior_region1 	= COALESCE(@priorregion1, trl_prior_region1),
		      trl_prior_region2 	= COALESCE(@priorregion2, trl_prior_region2),
		      trl_prior_region3 	= COALESCE(@priorregion3, trl_prior_region3),
		      trl_prior_region4 	= COALESCE(@priorregion4, trl_prior_region4),
		      trl_prior_cmp_othertype1 = COALESCE (@priorcompanyothertype1, 'UNK'),	
          trl_sch_cmp_id = COALESCE(@schcompany, 'UNKNOWN'),
          trl_sch_city   = COALESCE(@schcity, 0),
          trl_sch_date = @schdate,
          trl_sch_status = COALESCE(@schstat, 'AVL')
	  WHERE  trl_id = @trlid 
		  AND  (COALESCE(trl_status, '-98765') <> COALESCE(@avlstat, '-98765')
      OR   COALESCE(trl_avail_date, '19010101') <> COALESCE(@avldate, '19010101')
		  OR   COALESCE(trl_avail_cmp_id, '-9876543') <> IsNull(@avlcompany,	'-9876543')
		  OR   COALESCE(trl_avail_city, -987654) <> COALESCE(@avlcity, -987654)
		  OR   COALESCE(trl_last_cmd,	'-9876543') <> COALESCE(CASE WHEN COALESCE(@trlcmd, 'UNKNOWN') = 'UNKNOWN' THEN trl_last_cmd ELSE @trlcmd END, '-9876543')
		  OR   COALESCE(trl_last_cmd_ord, -987654) <> COALESCE(CASE WHEN COALESCE(@trlcmd, 'UNKNOWN') = 'UNKNOWN' THEN trl_last_cmd_ord  ELSE @trlcmdord END, -987654)
		  OR   COALESCE(trl_last_cmd_date, '19491231 23:59') <> COALESCE(CASE WHEN COALESCE(@trlcmd, 'UNKNOWN') = 'UNKNOWN' THEN trl_last_cmd_date ELSE @trlcmddate END, '19491231 23:59')
		  OR   COALESCE(trl_retiredate, '19491231 23:59') <> '20491231 23:59'
		  OR   COALESCE(trl_next_event, '-98765') <> COALESCE(@nextevent, 'UNK')
		  OR   COALESCE(trl_next_cmp_id, '-9876543') <> COALESCE(@nextcompany, 'UNKNOWN')
		  OR   COALESCE(trl_next_city, -987654)	<> COALESCE(@nextcity, 0)
		  OR   COALESCE(trl_next_state, '-98765') <> COALESCE(@nextstate,	'XX')
		  OR   COALESCE(trl_next_region1, '-98765') <> COALESCE(@nextregion1, 'UNK')
		  OR   COALESCE(trl_next_region2,	'-98765') <> COALESCE(@nextregion2, 'UNK')
		  OR   COALESCE(trl_next_region3,	'-98765') <> COALESCE(@nextregion3, 'UNK')
		  OR   COALESCE(trl_next_region4,	'-98765') <> COALESCE(@nextregion4, 'UNK')
		  OR   COALESCE(trl_next_cmp_othertype1, '-98765') <> COALESCE(@nextcompanyothertype1,'UNK')
		  OR   COALESCE(trl_prior_event, '-98765') <> COALESCE(@priorevent, 'UNK')
		  OR   COALESCE(trl_prior_cmp_id,	'-9876543') <> COALESCE(@priorcompany, 'UNKNOWN')
		  OR   COALESCE(trl_prior_city, -987654) <> COALESCE(@priorcity, 0)
		  OR   COALESCE(trl_prior_state, '-98765') <> COALESCE(@priorstate, 'XX')
		  OR   COALESCE(trl_prior_region1, '-98765') <> COALESCE(@priorregion1, 'UNK')
		  OR   COALESCE(trl_prior_region2, '-98765') <> COALESCE(@priorregion2, 'UNK')
		  OR   COALESCE(trl_prior_region3, '-98765') <> COALESCE(@priorregion3, 'UNK')
		  OR   COALESCE(trl_prior_region4, '-98765') <> COALESCE(@priorregion4, 'UNK')
		  OR   COALESCE(trl_prior_cmp_othertype1, '-98765') <> COALESCE(@priorcompanyothertype1,'UNK')
      OR   COALESCE(trl_sch_cmp_id, '-9876543') <> COALESCE(@schcompany, 'UNKNOWN')
		  OR   COALESCE(trl_sch_city, -987654) <> COALESCE(@schcity, 0)
      OR   COALESCE(trl_sch_date, '190101') <> COALESCE(@schdate, '190101')
      OR   COALESCE(trl_sch_status, '-98765') <> COALESCE(@schstat, '-98765'))
ELSE
	SELECT  @avlstat trl_status,
		      @avldate trl_avail_date,
		      CASE
			      WHEN @EDOWU_Condition_Met = 'Y' THEN trl_avail_cmp_id
			      ELSE @avlcompany 
          END trl_avail_cmp_id,
		      CASE
			      WHEN @EDOWU_Condition_Met = 'Y' THEN trl_avail_city
			      ELSE @avlcity 
          END trl_avail_city,
		      CASE WHEN COALESCE(@trlcmd, 'UNKNOWN') = 'UNKNOWN' THEN trl_last_cmd ELSE @trlcmd END trl_last_cmd,
		      CASE WHEN COALESCE(@trlcmd, 'UNKNOWN') = 'UNKNOWN' THEN trl_last_cmd_ord ELSE @trlcmdord END trl_last_cmd_ord,
		      CASE WHEN COALESCE(@trlcmd, 'UNKNOWN') = 'UNKNOWN' THEN trl_last_cmd_date ELSE @trlcmddate END trl_last_cmd_date,
		      '20491231 23:59' trl_retiredate,
		      COALESCE(@nextevent, 'UNK') trl_next_event,
		      COALESCE(@nextcompany, 'UNKNOWN') trl_next_cmp_id,
		      COALESCE(@nextcity, 0) trl_next_city,
		      COALESCE(@nextstate, 'XX') trl_next_state,
		      COALESCE(@nextregion1, 'UNK') trl_next_region1,
		      COALESCE(@nextregion2, 'UNK') trl_next_region2,
		      COALESCE(@nextregion3, 'UNK') trl_next_region3,
		      COALESCE(@nextregion4, 'UNK') trl_next_region4,
		      COALESCE(@nextcompanyothertype1, 'UNK') trl_next_cmp_othertype1,
		      COALESCE(@priorevent, trl_prior_event) trl_prior_event,
		      COALESCE(@priorcompany, trl_prior_cmp_id) trl_prior_cmp_id,
		      COALESCE(@priorcity, trl_prior_city) trl_prior_city,
		      COALESCE(@priorstate, trl_prior_state) trl_prior_state, 
		      COALESCE(@priorregion1, trl_prior_region1) trl_prior_region1,
		      COALESCE(@priorregion2, trl_prior_region2) trl_prior_region2,
		      COALESCE(@priorregion3, trl_prior_region3) trl_prior_region3,
		      COALESCE(@priorregion4, trl_prior_region4) trl_prior_region4,
		      COALESCE (@priorcompanyothertype1, 'UNK') trl_prior_cmp_othertype1,	
          COALESCE(@schcompany, 'UNKNOWN') trl_sch_cmp_id,
          COALESCE(@schcity, 0) trl_sch_city,
          @schdate trl_sch_date,
          COALESCE(@schstat, 'AVL') trl_sch_status
    FROM  trailerprofile
	 WHERE  trl_id = @trlid 
GO
GRANT EXECUTE ON  [dbo].[trl_expstatus] TO [public]
GO
