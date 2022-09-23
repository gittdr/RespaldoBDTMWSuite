SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_Auto214Flag_sp]
(
  @inserted                   UtStopsConsolidated READONLY,
  @deleted                    UtStopsConsolidated READONLY,
  @SlackTime                  INTEGER,
  @EDI214ApptTrigger          CHAR(1),
  @EDINotificationProcessType SMALLINT,
  @tmwuser                    VARCHAR(255),
  @GETDATE                    DATETIME
)
AS
                        
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
                  
DECLARE @StpNumber                INTEGER,
        @OrdHdrNumber             INTEGER,
        @BillTo                   VARCHAR(8),
        @StpSequence              INTEGER,
        @EstArrival               DATETIME,
        @SchDepart                DATETIME,
        @StpLatest                DATETIME,
        @PsActivity               VARCHAR(6),
        @StopActivity             VARCHAR(6),
        @Level                    VARCHAR(6),
        @ArriveEarlyOrLate        CHAR(1),
        @DepartEarlyOrLate        CHAR(1),
        @StpType                  VARCHAR(6),
        @StpDepartureDate         DATETIME,
        @StpEvent                 VARCHAR(6),
        @FirstStopOfType          INTEGER,
        @LastStopOfType           INTEGER,
        @CkcInterval              INTEGER,
        @NextLocReport            DATETIME,
        @FirstLastFlags		        VARCHAR(20),
        @StopPosition             VARCHAR(6),
        @MatchCount               INTEGER,
        @ReplicateForEachDropFlag CHAR(1),
        @e214date                 DATETIME
                    
/* 3 only look at stops on orders */
DECLARE StopCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT  i.stp_number,
          i.ord_hdrnumber,
          oh.ord_billto,
          i.stp_sequence,
          i.stp_arrivaldate,
          d.stp_departuredate,
          i.stp_schdtlatest,
          CASE
            WHEN i.stp_status = 'DNE' AND d.stp_status <> 'DNE' AND
                 COALESCE(i.stp_departure_status , 'OPN') = 'DNE' AND
                 COALESCE(d.stp_departure_status , 'OPN') <> 'DNE' THEN 'ARVDEP'
            WHEN i.stp_status = 'DNE' AND d.stp_status <> 'DNE' THEN 'ARV'
            WHEN i.stp_status = 'OPN' AND 
                 ((i.stp_schdtearliest <> d.stp_schdtearliest AND
                   i.stp_schdtlatest <> d.stp_schdtlatest AND
                   i.stp_schdtearliest = i.stp_schdtlatest AND 
                   @EDI214ApptTrigger IN('T' , 'B')) OR
                  (i.stp_schdtlatest <> d.stp_schdtlatest AND
                   @EDI214ApptTrigger = 'L') OR
                  (i.stp_schdtearliest <> d.stp_schdtearliest AND
                    @EDI214ApptTrigger = 'E')) THEN 'APPT'
				    WHEN COALESCE(i.stp_departure_status , 'OPN') = 'DNE' AND
                 COALESCE(d.stp_departure_status , 'OPN') <> 'DNE' THEN 'DEP'
            WHEN i.stp_status = 'OPN' AND d.stp_status = 'OPN' AND i.stp_arrivaldate <> d.stp_arrivaldate THEN 'ESTA'
            ELSE ' '
          END,
          CASE i.stp_type
            WHEN 'PUP' THEN 'SH'
            WHEN 'DRP' THEN 'CN'
            ELSE 'NON'
          END,
          CASE
            WHEN i.stp_schdtlatest < '20491231' AND DATEDIFF(mi , i.stp_schdtlatest , i.stp_arrivaldate) > @SlackTime THEN 'L'
            WHEN i.stp_schdtearliest > '19500101' AND i.stp_arrivaldate < i.stp_schdtearliest THEN 'E'
            ELSE ' '
          END,
          CASE
            WHEN i.stp_schdtlatest < '20491231' AND DATEDIFF(mi , i.stp_schdtlatest , i.stp_departuredate) > @SlackTime THEN 'L'
            ELSE ' '
          END,
          i.stp_type,
          i.stp_departuredate,
          i.stp_event
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number 
            INNER JOIN orderheader oh WITH(NOLOCK) ON oh.ord_hdrnumber = i.ord_hdrnumber
   WHERE  i.ord_hdrnumber > 0
            
OPEN StopCursor;
FETCH NEXT FROM StopCursor INTO @StpNumber, @OrdHdrNumber, @BillTo, @StpSequence,
                                @EstArrival, @SchDepart, @StpLatest, @PsActivity,
                                @Level, @ArriveEarlyOrLate, @DepartEarlyOrLate, @StpType,
                                @StpDepartureDate, @StpEvent;
              
WHILE @@FETCH_STATUS = 0
BEGIN 
  IF @StpEvent IN('IEMT' , 'IBMT' , 'BCST')
    SET @level = CASE @StpEvent
                   WHEN 'IEMT' THEN 'EMT'
                   WHEN 'IBMT' THEN 'BMT'
                   WHEN 'BCST' THEN 'BCS'
                 END;
        
  IF @PsActivity > ' '
  BEGIN   
    SELECT  @FirstStopOfType = MIN(stp_sequence),
            @LastStopOfType = MAX(stp_sequence)
      FROM  dbo.stops WITH(NOLOCK)
     WHERE  ord_hdrnumber = @OrdHdrNumber
       AND  stops.stp_type = @StpType;
        
    IF @StpType = 'PUP' AND @StpSequence = @FirstStopOfType AND @PsActivity IN ('DEP', 'ARVDEP')
    BEGIN  
      IF EXISTS (SELECT TOP 1 1
                   FROM dbo.edi_214_profile
                  WHERE edi_214_profile.e214_cmp_id = @BillTo
                    AND edi_214_profile.e214_triggering_activity = 'CKCALL')
      BEGIN 
        SELECT  @ckcinterval = edi_trading_partner.trp_ckcall_interval
          FROM  dbo.edi_trading_partner WITH(NOLOCK)
         WHERE  edi_trading_partner.cmp_id = @BillTo;

        SET @CkcInterval = COALESCE(@CkcInterval , 60);
        SET @NextLocReport = DATEADD(mi , @CkcInterval , @StpDepartureDate);

        INSERT dbo.edi_214_locationtracking
          (
            ord_hdrnumber,
            eloc_nextlocreport,
            eloc_interval
          )
        VALUES
          (
            @OrdHdrNumber,
            @NextLocReport,
            @CkcInterval
          );
      END
    END
        
    IF @StpType = 'DRP' AND @StpSequence = @LastStopOfType AND  @PsActivity IN ('ARV', 'DEP', 'ARVDEP')
      DELETE  dbo.edi_214_locationtracking
       WHERE  ord_hdrnumber = @OrdHdrNumber
        
    SET @FirstLastFlags = '0';  
        
    IF @FirstStopOfType = @StpSequence
      SELECT  @FirstLastFlags = @FirstLastFlags + ',1', 
              @StopPosition = 'FIRST'; 
        
    IF @FirstStopOfType < @StpSequence
      SELECT  @FirstLastFlags = @FirstLastFlags + ',2',
              @StopPosition = CASE 
                                WHEN @StpSequence <> @LastStopOfType THEN 'MIDDLE' 
                                ELSE 'LAST' 
                              END;        
                
    IF @LastStopOfType = @StpSequence
      SELECT  @FirstLastFlags = @FirstLastFlags + ',99',
              @StopPosition = 'LAST';

    IF @LastStopOfType > @StpSequence
      SELECT  @FirstLastFlags = @FirstLastFlags + ',3',
              @StopPosition = CASE 
                                WHEN @StpSequence <> @FirstStopOfType THEN 'MIDDLE' 
                                ELSE 'FIRST' 
                              END;
            
    IF @EDINotificationProcessType = 1
    BEGIN 
      SELECT  @MatchCount = COUNT(1),
              @ReplicateForEachDropFlag = MAX(COALESCE(edi_214_profile.e214_ReplicateForEachDropFlag , 'N'))
        FROM  dbo.edi_214_profile WITH(NOLOCK)
       WHERE  e214_cmp_id = @BillTo
         AND  e214_level = @Level
         AND  CHARINDEX(e214_triggering_activity , @PsActivity) > 0
         AND  CHARINDEX(CAST(e214_stp_position AS VARCHAR(5)) , @FirstLastFlags) > 0;
            
      IF @MatchCount > 0
      BEGIN 
        SET @e214date = CASE @PsActivity
                          WHEN 'ARV' THEN @EstArrival
                          WHEN 'ARVDEP' THEN @EstArrival
                          WHEN 'APPT' THEN @StpLatest
                          WHEN 'DEP' THEN @SchDepart
                          ELSE @GETDATE
                        END;
              
        INSERT  dbo.edi_214_pending
          (
            e214p_ord_hdrnumber,
            e214p_billto,
            e214p_level,
            e214p_ps_status,
            e214p_stp_number,
            e214p_dttm,
            e214p_activity,
            e214p_arrive_earlyorlate,
            e214p_depart_earlyorlate,
            e214p_stpsequence,
            ckc_number,
            e214p_firstlastflags,
            e214p_created,
            e214p_ReplicateForEachDropFlag,
            e214p_source,
            e214p_user
          )
        VALUES
          (
            @OrdHdrNumber,
            @BillTo,
            @Level,
            ' ',
            @StpNumber,
            @e214date,
            CASE @PsActivity
              WHEN 'ARVDEP' THEN 'ARV'
              ELSE @PsActivity
            END,
            @ArriveEarlyOrLate,
            @DepartEarlyOrLate,
            @StpSequence,
            0,
            @FirstLastFlags,
            @GETDATE,
            @ReplicateForEachDropFlag,
            APP_NAME(),
            @tmwuser);
            
        IF @PsActivity = 'ARVDEP'
        BEGIN
          INSERT dbo.edi_214_pending
            (
              e214p_ord_hdrnumber,
              e214p_billto,
              e214p_level,
              e214p_ps_status,
              e214p_stp_number,
              e214p_dttm,
              e214p_activity,
              e214p_arrive_earlyorlate,
              e214p_depart_earlyorlate,
              e214p_stpsequence,
              ckc_number,
              e214p_firstlastflags,
              e214p_created,
              e214p_ReplicateForEachDropFlag,
              e214p_source,
              e214p_user)
          VALUES
            (
              @OrdHdrNumber,
              @Billto,
              @Level,
              ' ',
              @StpNumber,
              @SchDepart,
              'DEP',
              @ArriveEarlyOrLate,
              @DepartEarlyOrLate,
              @StpSequence,
              0,
              @FirstLastFlags,
              @GETDATE,
              @ReplicateForEachDropFlag,
              APP_NAME(),
              @tmwuser
            );
        END
      END
    END
            
    IF @EDINotificationProcessType = 2
    BEGIN 
      SET @e214date = CASE @PsActivity
                        WHEN 'ARV' THEN @EstArrival
                        WHEN 'ARVDEP' THEN @EstArrival
                        WHEN 'APPT' THEN @StpLatest
                        WHEN 'DEP' THEN @SchDepart
                        ELSE @GETDATE
                      END;
        
      SET @StopActivity = CASE 
                            WHEN @PsActivity = 'ARVDEP' THEN 'ARV' 
                            ELSE @PsActivity 
                          END;
                
      INSERT  dbo.edi_214_pending
        (
          e214p_ord_hdrnumber,
          e214p_billto,
          e214p_level,
          e214p_ps_status,
          e214p_stp_number,
          e214p_dttm,
          e214p_activity,
          e214p_arrive_earlyorlate,
          e214p_depart_earlyorlate,
          e214p_stpsequence,
          ckc_number,
          e214p_firstlastflags,
          e214p_created,
          e214p_ReplicateForEachDropFlag,
          e214p_source,
          e214p_user
        )
        SELECT  DISTINCT @OrdHdrNumber,
                edi_214_profile.e214_cmp_id,
                @Level,
                ' ',
                @StpNumber,
                @e214date,
                CASE @PsActivity
                  WHEN 'ARVDEP' THEN 'ARV'
                  ELSE @PsActivity
                END,
                @ArriveEarlyOrLate,
                @DepartEarlyOrLate,
                @StpSequence,
                0,
                @FirstLastFlags,
                @GETDATE,
                @ReplicateForEachDropFlag,
                APP_NAME(),
                @tmwuser
          FROM  dbo.edi_214_profile WITH(NOLOCK)
                  INNER JOIN dbo.stops WITH(NOLOCK) ON stops.cmp_id = edi_214_profile.e214_cmp_id
         WHERE  edi_214_profile.e214_level = @Level
           AND  stops.ord_hdrnumber = @OrdHdrNumber
           AND  (stops.stp_type = 'PUP' OR stops.stp_event IN ('IEMT' , 'IBMT' , 'BCST'))
           AND  edi_214_profile.shipper_role_flag = 'Y'
           AND  edi_214_profile.e214_triggering_activity = @StopActivity
           AND  (@StopPosition = 'FIRST' AND edi_214_profile.e214_stp_position IN (0 , 1 , 3)
            OR   @StopPosition = 'LAST' AND edi_214_profile.e214_stp_position IN (0 , 2 , 99)
            OR   @StopPosition = 'MIDDLE' AND edi_214_profile.e214_stp_position IN (0 , 2 , 3))
        UNION
        SELECT  DISTINCT @OrdHdrNumber,
                edi_214_profile.e214_cmp_id,
                @Level,
                ' ',
                @StpNumber,
                @e214date,
                CASE @PsActivity
                  WHEN 'ARVDEP' THEN 'ARV'
                  ELSE @PsActivity
                END,
                @ArriveEarlyOrLate,
                @DepartEarlyOrLate,
                @StpSequence,
                0,
                @FirstLastFlags,
                @GETDATE,
                @ReplicateForEachDropFlag,
                APP_NAME(),
                @tmwuser
          FROM  dbo.edi_214_profile WITH(NOLOCK)
                  INNER JOIN dbo.stops WITH(NOLOCK) ON stops.cmp_id = edi_214_profile.e214_cmp_id
         WHERE  edi_214_profile.e214_level = @Level
           AND  stops.ord_hdrnumber = @OrdHdrNumber
           AND  (stops.stp_type = 'DRP' OR stops.stp_event IN ('IEMT' , 'IBMT' , 'BCST'))
           AND  edi_214_profile.consignee_role_flag = 'Y'
           AND  edi_214_profile.e214_triggering_activity = @StopActivity
           AND  (@StopPosition = 'FIRST' AND edi_214_profile.e214_stp_position IN (0 , 1 , 3)
            OR   @StopPosition = 'LAST' AND edi_214_profile.e214_stp_position IN (0 , 2 , 99)
            OR   @StopPosition = 'MIDDLE' AND edi_214_profile.e214_stp_position IN (0 , 2 , 3))
        UNION
        SELECT  @OrdHdrNumber,
                edi_214_profile.e214_cmp_id,
                @Level,
                ' ',
                @StpNumber,
                @e214date,
                CASE @PsActivity
                  WHEN 'ARVDEP' THEN 'ARV'
                  ELSE @PsActivity
                END,
                @ArriveEarlyOrLate,
                @DepartEarlyOrLate,
                @StpSequence,
                0,
                @FirstLastFlags,
                @GETDATE,
                @ReplicateForEachDropFlag,
                APP_NAME(),
                @tmwuser
          FROM  dbo.edi_214_profile WITH(NOLOCK)
                  INNER JOIN dbo.orderheader WITH(NOLOCK) ON orderheader.ord_billto = edi_214_profile.e214_cmp_id
         WHERE  edi_214_profile.e214_level = @Level
           AND  orderheader.ord_hdrnumber = @OrdHdrNumber
           AND  edi_214_profile.e214_triggering_activity = @StopActivity
           AND  edi_214_profile.billto_role_flag = 'Y'
           AND  (@StopPosition = 'FIRST' AND edi_214_profile.e214_stp_position IN (0 , 1 , 3)
            OR   @StopPosition = 'LAST' AND edi_214_profile.e214_stp_position IN (0 , 2 , 99)
            OR   @StopPosition = 'MIDDLE' AND edi_214_profile.e214_stp_position IN (0 , 2 , 3))
        UNION
        SELECT  @OrdHdrNumber,
                edi_214_profile.e214_cmp_id,
                @Level,
                ' ',
                @StpNumber,
                @e214date,
                CASE @PsActivity
                  WHEN 'ARVDEP' THEN 'ARV'
                  ELSE @PsActivity
                END,
                @ArriveEarlyOrLate,
                @DepartEarlyOrLate,
                @StpSequence,
                0,
                @FirstLastFlags,
                @GETDATE,
                @ReplicateForEachDropFlag,
                APP_NAME(),
                @tmwuser
          FROM  dbo.edi_214_profile WITH(NOLOCK)
                  INNER JOIN dbo.orderheader WITH(NOLOCK) ON orderheader.ord_company = edi_214_profile.e214_cmp_id
         WHERE  edi_214_profile.e214_level = @Level
           AND  orderheader.ord_hdrnumber = @OrdHdrNumber
           AND  edi_214_profile.e214_triggering_activity = @StopActivity
           AND  edi_214_profile.orderby_role_flag = 'Y'
           AND  (@StopPosition = 'FIRST' AND edi_214_profile.e214_stp_position IN (0 , 1 , 3)
            OR   @StopPosition = 'LAST' AND edi_214_profile.e214_stp_position IN (0 , 2 , 99)
            OR   @StopPosition = 'MIDDLE' AND edi_214_profile.e214_stp_position IN (0 , 2 , 3));
          
      IF @PsActivity = 'ARVDEP'
      BEGIN 
        SET @StopActivity = 'DEP';
          
        INSERT  dbo.edi_214_pending
          (
            e214p_ord_hdrnumber,
            e214p_billto,
            e214p_level,
            e214p_ps_status,
            e214p_stp_number,
            e214p_dttm,
            e214p_activity,
            e214p_arrive_earlyorlate,
            e214p_depart_earlyorlate,
            e214p_stpsequence,
            ckc_number,
            e214p_firstlastflags,
            e214p_created,
            e214p_ReplicateForEachDropFlag,
            e214p_source,
            e214p_user
          )
          SELECT  DISTINCT @OrdHdrNumber,
                  edi_214_profile.e214_cmp_id,
                  @Level,
                  ' ',
                  @StpNumber,
                  @SchDepart,
                  'DEP',
                  @ArriveEarlyOrLate,
                  @DepartEarlyOrLate,
                  @StpSequence,
                  0,
                  @FirstLastFlags,
                  @GETDATE,
                  @ReplicateForEachDropFlag,
                  APP_NAME(),
                  @tmwuser
            FROM  dbo.edi_214_profile WITH(NOLOCK)
                    INNER JOIN dbo.stops WITH(NOLOCK) ON stops.cmp_id = edi_214_profile.e214_cmp_id
            WHERE  edi_214_profile.e214_level = @Level
              AND  stops.ord_hdrnumber = @OrdHdrNumber
              AND  (stops.stp_type = 'PUP' OR stops.stp_event IN ('IEMT' , 'IBMT' , 'BCST')) 
              AND  edi_214_profile.shipper_role_flag = 'Y'
              AND  edi_214_profile.e214_triggering_activity = @StopActivity
              AND  (@StopPosition = 'FIRST' AND edi_214_profile.e214_stp_position IN (0 , 1 , 3)
              OR   @StopPosition = 'LAST' AND edi_214_profile.e214_stp_position IN (0 , 2 , 99)
              OR   @StopPosition = 'MIDDLE' AND edi_214_profile.e214_stp_position IN (0 , 2 , 3))
          UNION
          SELECT  DISTINCT @OrdHdrNumber,
                  edi_214_profile.e214_cmp_id,
                  @Level,
                  ' ',
                  @StpNumber,
                  @SchDepart,
                  'DEP',
                  @ArriveEarlyOrLate,
                  @DepartEarlyOrLate,
                  @StpSequence,
                  0,
                  @FirstLastFlags,
                  @GETDATE,
                  @ReplicateForEachDropFlag,
                  APP_NAME(),
                  @tmwuser
            FROM  dbo.edi_214_profile WITH(NOLOCK)
                    INNER JOIN dbo.stops WITH(NOLOCK) ON stops.cmp_id = edi_214_profile.e214_cmp_id
            WHERE  edi_214_profile.e214_level = @Level
              AND  stops.ord_hdrnumber = @OrdHdrNumber
              AND  (stops.stp_type = 'DRP' OR stops.stp_event IN ('IEMT' , 'IBMT' , 'BCST'))
              AND  edi_214_profile.consignee_role_flag = 'Y'
              AND  edi_214_profile.e214_triggering_activity = @StopActivity
              AND  (@stopPosition = 'FIRST' AND edi_214_profile.e214_stp_position IN (0 , 1 , 3)
              OR   @StopPosition = 'LAST' AND edi_214_profile.e214_stp_position IN (0 , 2 , 99)
              OR   @StopPosition = 'MIDDLE' AND edi_214_profile.e214_stp_position IN (0 , 2 , 3))
          UNION
          SELECT  @OrdHdrNumber,
                  edi_214_profile.e214_cmp_id,
                  @Level,
                  ' ',
                  @StpNumber,
                  @SchDepart,
                  'DEP',
                  @ArriveEarlyOrLate,
                  @DepartEarlyOrLate,
                  @StpSequence,
                  0,
                  @FirstLastFlags,
                  @GETDATE,
                  @ReplicateForEachDropFlag,
                  APP_NAME(),
                  @tmwuser
            FROM  dbo.edi_214_profile WITH(NOLOCK)
                    INNER JOIN dbo.orderheader WITH(NOLOCK) ON orderheader.ord_billto = edi_214_profile.e214_cmp_id
            WHERE  edi_214_profile.e214_level = @Level
              AND  orderheader.ord_hdrnumber = @OrdHdrNumber
              AND  edi_214_profile.e214_triggering_activity = @StopActivity
              AND  edi_214_profile.billto_role_flag = 'Y'
              AND  (@StopPosition = 'FIRST' AND edi_214_profile.e214_stp_position IN (0 , 1 , 3)
              OR   @StopPosition = 'LAST' AND edi_214_profile.e214_stp_position IN (0 , 2 , 99)
              OR   @StopPosition = 'MIDDLE' AND edi_214_profile.e214_stp_position IN (0 , 2 , 3))
          UNION
          SELECT  @OrdHdrNumber,
                  edi_214_profile.e214_cmp_id,
                  @Level,
                  ' ',
                  @StpNumber,
                  @SchDepart,
                  'DEP',
                  @ArriveEarlyOrLate,
                  @DepartEarlyOrLate,
                  @StpSequence,
                  0,
                  @FirstLastFlags,
                  @GETDATE,
                  @ReplicateForEachDropFlag,
                  APP_NAME(),
                  @tmwuser
            FROM  dbo.edi_214_profile WITH(NOLOCK)
                    INNER JOIN dbo.orderheader WITH(NOLOCK) ON orderheader.ord_company = edi_214_profile.e214_cmp_id
            WHERE  edi_214_profile.e214_level = @Level
              AND  orderheader.ord_hdrnumber = @OrdHdrNumber
              AND  edi_214_profile.e214_triggering_activity = @StopActivity
              AND  edi_214_profile.orderby_role_flag = 'Y'
              AND  (@StopPosition = 'FIRST' AND edi_214_profile.e214_stp_position IN (0 , 1 , 3)
              OR   @StopPosition = 'LAST' AND edi_214_profile.e214_stp_position IN (0 , 2 , 99)
              OR   @StopPosition = 'MIDDLE' AND edi_214_profile.e214_stp_position IN (0 , 2 , 3));
      END
    END
  END
  FETCH NEXT FROM StopCursor INTO @StpNumber, @OrdHdrNumber, @BillTo, @StpSequence,
                                  @EstArrival, @SchDepart, @StpLatest, @PsActivity,
                                  @Level, @ArriveEarlyOrLate, @DepartEarlyOrLate, @StpType,
                                  @StpDepartureDate, @StpEvent;
END

CLOSE StopCursor;
DEALLOCATE StopCursor;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_Auto214Flag_sp] TO [public]
GO
