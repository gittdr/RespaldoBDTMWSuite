SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[gettimecalc_shift_sp]
      ( @ord_or_lgh_number CHAR(1)
      , @the_number        INT
      )
AS

/*
*
*
* NAME:
* dbo.gettimecalc_shift_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to return times based upon shift schedule logs data
*
* RETURNS:
*
* RESULTSET
*
* 10/05/2011 PTS58399 SPN - Created Initial Version
* 05/07/2013 PTS69317 SPN - Last Stop Departure should always be Driver's Logout Time
* 06/03/2013 PTS69856 SPN - LogIn and LogOut defines the day.  Ignore Stop Time.
* 07/24/2013 PTS69824 SPN - Keep the total hours of settle and/or invoice within Shift-LogIn and LogOut by adjusting the first row with any diff
* 05/23/2014 PTS77529 SPN - Rounding: for Billing round each Order Shift hour to nearest Quarter hour; for Settlement allocate rounded (ceiling qtr hour) shift hour to the first leg
* 11/22/2014 PTS84769 SPN - Rounding: Round once per order -> moved to the wrapper.
*
*/

SET NOCOUNT ON

BEGIN

   DECLARE @debug_ind                  CHAR(1)

   DECLARE @mov_number                 INT
   DECLARE @ord_hdrnumber              INT
   DECLARE @lgh_number                 INT
   DECLARE @stp_number                 INT
   DECLARE @stp_event                  VARCHAR(6)
   DECLARE @stp_location               VARCHAR(100)
   DECLARE @stp_arrivaldate            DATETIME
   DECLARE @stp_departuredate          DATETIME
   DECLARE @ssl_activitydate_start     DATETIME
   DECLARE @ssl_activitydate_end       DATETIME
   DECLARE @afactor                    INT
   DECLARE @allocation_factor          INT

   DECLARE @cur_seqno                  INT
   DECLARE @seqno                      INT
   DECLARE @seqno_login                INT
   DECLARE @seqno_logout               INT
   DECLARE @shift_ss_id                INT
   DECLARE @msg                        VARCHAR(1000)
   DECLARE @order_count                INT
   DECLARE @ldt_login                  DATETIME
   DECLARE @ldt_logout                 DATETIME

   DECLARE @prev_mov_number            INT
   DECLARE @prev_ord_hdrnumber         INT
   DECLARE @prev_stp_location          VARCHAR(100)
   DECLARE @prev_stp_event             VARCHAR(6)
   DECLARE @prev_ssl_activitydate_end  DATETIME

   DECLARE @max_ssl_activitydate_end   DATETIME
   DECLARE @min_ssl_activitydate_start DATETIME

   DECLARE @BreakType                  CHAR(2)
   DECLARE @ssl_Break                  DATETIME
   DECLARE @prev_ssl_Break             DATETIME
   DECLARE @ssl_Break_LO               DATETIME
   DECLARE @ssl_Break_LI               DATETIME
   DECLARE @ssl_Break_SeqBegin         INT
   DECLARE @ssl_Break_SeqEnd           INT
   DECLARE @break_hours                DECIMAL(5,2)
   DECLARE @break_hours_adjusted       DECIMAL(5,2)

   DECLARE @sechour                    DECIMAL(6,2)
   DECLARE @diff                       DECIMAL(5,2)
   DECLARE @ect_billable               CHAR(1)
   DECLARE @LogInOut_Hours             DECIMAL(5,2)
   DECLARE @tot_settle_hours           DECIMAL(5,2)
   DECLARE @tot_invoice_hours          DECIMAL(5,2)

   --BEGIN PTS 77529 SPN
   DECLARE @ShiftTimeRounding          CHAR(1)
   --END PTS 77529 SPN

   DECLARE @stop_activity TABLE
   ( seqno                    INT            IDENTITY
   , shift_ss_id              INT            NULL
   , mov_number               INT            NULL
   , ord_hdrnumber            INT            NULL
   , lgh_number               INT            NULL
   , stp_number               INT            NULL
   , stp_event                VARCHAR(6)     NULL
   , stp_location             VARCHAR(100)   NULL
   , stp_arrivaldate          DATETIME       NULL
   , stp_departuredate        DATETIME       NULL
   , ssl_activitydate_start   DATETIME       NULL
   , ssl_activitydate_end     DATETIME       NULL
   , allocation_factor        INT            NULL
   , ssl_activity_hrs         DECIMAL(5,2)   NULL
   , break_hours              DECIMAL(5,2)   NULL
   , settle_hours             DECIMAL(5,2)   NULL
   , invoice_hours            DECIMAL(5,2)   NULL
   )

   DECLARE @LEGS TABLE (lgh_number INT)

   --Initialize
   SELECT @sechour = 3600
   SELECT @debug_ind = 'N'
   --BEGIN PTS 77529 SPN
   SELECT @ShiftTimeRounding = gi_string1 FROM generalinfo WHERE gi_name = 'ShiftTimeRounding'
   --END PTS 77529 SPN

   --Legs for the Order or use the passed in leg
   If @ord_or_lgh_number = 'O'
      BEGIN
         INSERT INTO @LEGS (lgh_number)
         SELECT DISTINCT lgh_number
           FROM stops
          WHERE ord_hdrnumber = @the_number
      END
   Else
      BEGIN
         INSERT INTO @LEGS (lgh_number)
         VALUES (@the_number)
      END

   --Get the Shift# from the legs
   BEGIN
      SELECT @shift_ss_id = MAX(l.shift_ss_id)
        FROM legheader l
        JOIN @LEGS lt ON l.lgh_number = lt.lgh_number
       WHERE l.shift_ss_id IS NOT NULL
   END

   IF @debug_ind = 'Y'
   BEGIN
      SELECT @msg = '*** Begin ' + @ord_or_lgh_number + Convert(varchar,@the_number) + ' Shift#=' + Convert(varchar,@shift_ss_id)
      RAISERROR(@msg,10,1) WITH NOWAIT
   END

   --Get Stops
   INSERT INTO @stop_activity
   ( shift_ss_id
   , mov_number
   , ord_hdrnumber
   , lgh_number
   , stp_number
   , stp_event
   , stp_location
   , stp_arrivaldate
   , stp_departuredate
   )
   SELECT l.shift_ss_id
        , l.mov_number
        , l.ord_hdrnumber
        , l.lgh_number
        , s.stp_number
        , s.stp_event
        , s.cmp_id + ' - ' + CONVERT(varchar,s.stp_city) AS stp_location
        , s.stp_arrivaldate
        , s.stp_departuredate
     FROM legheader l
     JOIN stops s ON l.lgh_number = s.lgh_number
    WHERE l.shift_ss_id = @shift_ss_id
   ORDER BY s.stp_arrivaldate
          , l.mov_number
          , l.ord_hdrnumber
          , l.lgh_number

   --Check for multiple order at the same location with same event; if found then the hours need to be allocated
   SELECT @prev_stp_location  = ' '
   SELECT @prev_stp_event     = ' '
   SELECT @cur_seqno = 0
   WHILE 1 = 1
   BEGIN
      SELECT @seqno = 0
      SELECT @seqno = MIN(seqno) FROM @stop_activity WHERE seqno > @cur_seqno
      IF @seqno IS NULL OR @seqno = 0 BREAK
      SELECT @cur_seqno = @seqno
      SELECT @seqno                   = seqno
           , @mov_number              = mov_number
           , @ord_hdrnumber           = ord_hdrnumber
           , @lgh_number              = lgh_number
           , @stp_number              = stp_number
           , @stp_event               = stp_event
           , @stp_location            = stp_location
           , @stp_arrivaldate         = stp_arrivaldate
           , @stp_departuredate       = stp_departuredate
           , @ssl_activitydate_start  = ssl_activitydate_start
           , @ssl_activitydate_end    = ssl_activitydate_end
           , @allocation_factor       = allocation_factor
        FROM @stop_activity
       WHERE seqno = @seqno

      IF @stp_location = @prev_stp_location AND @stp_event = @prev_stp_event
         BEGIN
            SELECT @afactor = @afactor + 1
            UPDATE @stop_activity
               SET allocation_factor = @afactor
             WHERE mov_number    = @prev_mov_number
               AND ord_hdrnumber = @prev_ord_hdrnumber
               AND stp_location  = @prev_stp_location
               AND stp_event     = @prev_stp_event
         END
      ELSE
         BEGIN
            SELECT @afactor = 1
            UPDATE @stop_activity
               SET allocation_factor = @afactor
             WHERE seqno = @seqno
         END

      SELECT @prev_mov_number    = @mov_number
      SELECT @prev_ord_hdrnumber = @ord_hdrnumber
      SELECT @prev_stp_location  = @stp_location
      SELECT @prev_stp_event     = @stp_event
   END

   --Get First LogIn
   SELECT @ldt_login = MIN(ssl_activitydate)
     FROM shiftschedules_log
    WHERE ss_id = @shift_ss_id
      AND ssl_activity = 'LI'
   IF @ldt_login IS NULL
   BEGIN
      SELECT @msg = @ord_or_lgh_number + Convert(varchar,@the_number) + ' No Shift Login found'
      RAISERROR(@msg,11,1)
   END

   --If the first move is a consolidated move then the First Billable stop is the LogIn otherwise it is the first stop
   SELECT @order_count = Count(1)
     FROM orderheader
    WHERE mov_number = (SELECT MIN(mov_number)
                          FROM @stop_activity
                         WHERE stp_arrivaldate = (SELECT MIN(stp_arrivaldate)
                                                    FROM @stop_activity
                                                 )
                       )
   BEGIN
   IF @debug_ind = 'Y'
   BEGIN
      SELECT @msg = 'Order Count=' + Convert(varchar,@order_count)
      RAISERROR(@msg,10,1) WITH NOWAIT
   END
   If @order_count > 1
      SELECT @seqno_login = MIN(seqno)
        FROM @stop_activity
       WHERE stp_event IN (SELECT abbr
                             FROM eventcodetable
                            WHERE ect_billable = 'Y'
                          )
   Else
      SELECT @seqno_login = 1
   END

   SELECT @seqno_login = IsNull(@seqno_login,1)

   SELECT @ssl_activitydate_start = stp_arrivaldate
     FROM @stop_activity
    WHERE seqno = @seqno_login

   UPDATE @stop_activity
      SET ssl_activitydate_start = @ldt_login
    WHERE seqno = @seqno_login
   --All prior stops should begin and end with 0 hours
   UPDATE @stop_activity
      SET ssl_activitydate_start = @ldt_login
        , ssl_activitydate_end   = @ldt_login
    WHERE seqno < @seqno_login

   --Get Last LogOut
   SELECT @ldt_logout = MAX(ssl_activitydate)
     FROM shiftschedules_log
    WHERE ss_id = @shift_ss_id
      AND ssl_activity = 'LO'
   IF @ldt_logout IS NULL
   BEGIN
      SELECT @msg = @ord_or_lgh_number + Convert(varchar,@the_number) + ' No Shift Logout found'
      RAISERROR(@msg,11,1)
   END

   --BEGIN PTS 69317 SPN
   --Last Stop is always the drivers LogOut
   BEGIN
      SELECT @seqno_logout = MAX(seqno)
        FROM @stop_activity
   END

   SELECT @seqno_logout = IsNull(@seqno_logout,1)

   SELECT @ssl_activitydate_end = stp_departuredate
     FROM @stop_activity
    WHERE seqno = @seqno_logout

   UPDATE @stop_activity
      SET ssl_activitydate_end = @ldt_logout
    WHERE seqno = @seqno_logout
   --All next stops should begin and end with 0 hours
   UPDATE @stop_activity
      SET ssl_activitydate_start = @ldt_logout
        , ssl_activitydate_end   = @ldt_logout
    WHERE seqno > @seqno_logout

   IF @debug_ind = 'Y'
   BEGIN
      SELECT @msg = 'LogIn: ' + Convert(Varchar,@ldt_login) + ' Stop Seq# ' + Convert(Varchar,@seqno_login)
      RAISERROR(@msg,10,1) WITH NOWAIT
      SELECT @msg = 'LogOut: ' + Convert(Varchar,@ldt_logout) + ' Stop Seq# ' + Convert(Varchar,@seqno_logout)
      RAISERROR(@msg,10,1) WITH NOWAIT
   END

   --SetUp Start and End of Stops
   SELECT @prev_stp_location         = ' '
   SELECT @prev_stp_event            = ' '
   SELECT @prev_ssl_activitydate_end = @ldt_login
   SELECT @cur_seqno = 0
   WHILE 1 = 1
   BEGIN
      SELECT @seqno = 0
      SELECT @seqno = MIN(seqno) FROM @stop_activity WHERE seqno > @cur_seqno
      IF @seqno IS NULL OR @seqno = 0 BREAK
      SELECT @cur_seqno = @seqno
      SELECT @seqno                   = seqno
           , @mov_number              = mov_number
           , @ord_hdrnumber           = ord_hdrnumber
           , @lgh_number              = lgh_number
           , @stp_number              = stp_number
           , @stp_event               = stp_event
           , @stp_location            = stp_location
           , @stp_arrivaldate         = stp_arrivaldate
           , @stp_departuredate       = stp_departuredate
           , @ssl_activitydate_start  = ssl_activitydate_start
           , @ssl_activitydate_end    = ssl_activitydate_end
           , @allocation_factor       = allocation_factor
        FROM @stop_activity
       WHERE seqno = @seqno

      IF @seqno < @seqno_login CONTINUE
      IF @seqno > @seqno_logout CONTINUE

      IF @debug_ind = 'Y'
      BEGIN
         SELECT @msg = 'seqno/mov_number/stp_event/stp_location/allocation_factor ' + Convert(varchar,@seqno) + '/' + Convert(varchar,@mov_number) + '/' + @stp_event + '/' + @stp_location + '/' + Convert(varchar,@allocation_factor)
         RAISERROR(@msg,10,1) WITH NOWAIT
      END

      IF @stp_location <> @prev_stp_location OR @stp_event <> @prev_stp_event
      BEGIN
         SELECT @min_ssl_activitydate_start = @prev_ssl_activitydate_end
         SELECT @max_ssl_activitydate_end = MAX(ssl_activitydate_end)
           FROM @stop_activity
          WHERE mov_number      = @mov_number
            AND stp_event       = @stp_event
            AND stp_location    = @stp_location
            AND ssl_activitydate_end IS NOT NULL
         IF @max_ssl_activitydate_end IS NULL
         BEGIN
            SELECT @max_ssl_activitydate_end = MAX(stp_departuredate)
              FROM @stop_activity
             WHERE mov_number      = @mov_number
               AND stp_event       = @stp_event
               AND stp_location    = @stp_location
         END

         IF @debug_ind = 'Y'
         BEGIN
            SELECT @msg = 'min_ssl_activitydate_start ' + Convert(varchar,@min_ssl_activitydate_start)
            RAISERROR(@msg,10,1) WITH NOWAIT
            SELECT @msg = 'max_ssl_activitydate_end ' + Convert(varchar,@max_ssl_activitydate_end)
            RAISERROR(@msg,10,1) WITH NOWAIT
         END
      END

      IF @allocation_factor <> 1
      BEGIN
         --Allocate
         SELECT @stp_departuredate = DATEADD(ss, (DATEDIFF(ss, @min_ssl_activitydate_start, @max_ssl_activitydate_end) / @allocation_factor), @prev_ssl_activitydate_end )
      END

      --BEGIN PTS 69317 SPN
      IF @seqno = @seqno_logout
         SELECT @stp_departuredate = @max_ssl_activitydate_end
      --END PTS 69317 SPN

      UPDATE @stop_activity
         SET ssl_activitydate_start = @prev_ssl_activitydate_end
           , ssl_activitydate_end = case seqno when @seqno_logout then ssl_activitydate_end else @stp_departuredate end
       WHERE seqno = @seqno

      SELECT @prev_stp_location         = @stp_location
      SELECT @prev_stp_event            = @stp_event
      SELECT @prev_ssl_activitydate_end = @stp_departuredate
   END

   --Look for multiple LogOut and LogBackIn while in shift to compute any break hours
   SELECT @BreakType = 'LO'
   SELECT @prev_ssl_Break = @ldt_login
   SELECT @ssl_Break_LO = NULL
   SELECT @ssl_Break_LI = NULL
   SELECT @ssl_Break_SeqBegin = 0
   SELECT @ssl_Break_SeqEnd   = 0
   SELECT @cur_seqno = 0
   WHILE 1 = 1
   BEGIN
      SELECT @seqno = 0
      SELECT @seqno = MIN(seqno) FROM @stop_activity WHERE seqno > @cur_seqno
      IF @seqno IS NULL OR @seqno = 0 BREAK
      SELECT @cur_seqno = @seqno
      SELECT @seqno                   = seqno
           , @mov_number              = mov_number
           , @ord_hdrnumber           = ord_hdrnumber
           , @lgh_number              = lgh_number
           , @stp_number              = stp_number
           , @stp_event               = stp_event
           , @stp_location            = stp_location
           , @stp_arrivaldate         = stp_arrivaldate
           , @stp_departuredate       = stp_departuredate
           , @ssl_activitydate_start  = ssl_activitydate_start
           , @ssl_activitydate_end    = ssl_activitydate_end
           , @allocation_factor       = allocation_factor
        FROM @stop_activity
       WHERE seqno = @seqno

      WHILE 2 = 2
      BEGIN
         SELECT @ssl_Break = NULL
         SELECT @ssl_Break = MIN(ssl_activitydate)
           FROM shiftschedules_log
          WHERE ss_id = @shift_ss_id
            AND ssl_activity = @BreakType
            AND ssl_activitydate >= @ssl_activitydate_start
            AND ssl_activitydate <= @ssl_activitydate_end
            AND ssl_activitydate > @prev_ssl_Break

         IF @ssl_Break IS NULL BREAK

         SELECT @prev_ssl_Break = @ssl_Break

         IF @BreakType = 'LO'
            BEGIN
               SELECT @ssl_Break_LO = @ssl_Break
               SELECT @ssl_Break_SeqBegin = @seqno
               SELECT @BreakType = 'LI'
            END
         ELSE
            BEGIN
               SELECT @ssl_Break_LI = @ssl_Break
               SELECT @ssl_Break_SeqEnd = @seqno
               SELECT @BreakType = 'LO'
            END
      END

      --Allocate Break Hours between @ssl_Break_SeqBegin and @ssl_Break_SeqEnd
      IF @ssl_Break_LO IS NOT NULL AND @ssl_Break_LI IS NOT NULL
      BEGIN
         SELECT @break_hours = DATEDIFF(ss, @ssl_Break_LO, @ssl_Break_LI) / @sechour

         IF @debug_ind = 'Y'
         BEGIN
            SELECT @msg = 'Seq# ' + Convert(varchar,IsNull(@ssl_Break_SeqBegin,0)) + ' To ' + Convert(varchar,IsNull(@ssl_Break_SeqEnd,0)) + ' Adjusts Break Hours of ' + Convert(Varchar,@break_hours)
            RAISERROR(@msg,10,1) WITH NOWAIT
         END

         WHILE @ssl_Break_SeqBegin <= @ssl_Break_SeqEnd
         BEGIN
            SELECT @ssl_activitydate_start = ssl_activitydate_start
                 , @ssl_activitydate_end = ssl_activitydate_end
              FROM @stop_activity
             WHERE seqno = @ssl_Break_SeqBegin

            IF @ssl_Break_LO > @ssl_activitydate_start
               SELECT @ssl_activitydate_start = @ssl_Break_LO

            IF @ssl_Break_LI < @ssl_activitydate_end
               SELECT @ssl_activitydate_end = @ssl_Break_LI

            SELECT @break_hours_adjusted = DATEDIFF(ss, @ssl_activitydate_start, @ssl_activitydate_end) / @sechour
            IF @break_hours_adjusted > @break_hours
               SELECT @break_hours_adjusted = @break_hours

            SELECT @break_hours = @break_hours - @break_hours_adjusted

            UPDATE @stop_activity
               SET break_hours = IsNull(break_hours,0) + @break_hours_adjusted
             WHERE seqno = @ssl_Break_SeqBegin

            SELECT @ssl_Break_SeqBegin = @ssl_Break_SeqBegin + 1
            IF @break_hours = 0 BREAK
         END

         SELECT @ssl_Break_LO = NULL
         SELECT @ssl_Break_LI = NULL
         SELECT @ssl_Break_SeqBegin = 0
         SELECT @ssl_Break_SeqEnd   = 0
      END

   END

   --Compute Hours
   SELECT @cur_seqno = 0
   WHILE 1 = 1
   BEGIN
      SELECT @seqno = 0
      SELECT @seqno = MIN(seqno) FROM @stop_activity WHERE seqno > @cur_seqno
      IF @seqno IS NULL OR @seqno = 0 BREAK
      SELECT @cur_seqno = @seqno
      SELECT @seqno                   = seqno
           , @mov_number              = mov_number
           , @ord_hdrnumber           = ord_hdrnumber
           , @lgh_number              = lgh_number
           , @stp_number              = stp_number
           , @stp_event               = stp_event
           , @stp_location            = stp_location
           , @stp_arrivaldate         = stp_arrivaldate
           , @stp_departuredate       = stp_departuredate
           , @ssl_activitydate_start  = ssl_activitydate_start
           , @ssl_activitydate_end    = ssl_activitydate_end
           , @allocation_factor       = allocation_factor
        FROM @stop_activity
       WHERE seqno = @seqno

      SELECT @ect_billable = ect_billable
        FROM eventcodetable
       WHERE abbr = @stp_event

      --BEGIN PTS 77529 SPN
      SELECT @diff = DATEDIFF(ss, @ssl_activitydate_start, @ssl_activitydate_end) / @sechour
      --END PTS 77529 SPN

      BEGIN
         UPDATE @stop_activity
            SET ssl_activity_hrs = @diff
              , settle_hours = @diff - IsNull(break_hours,0)
              , invoice_hours = (CASE WHEN IsNull(@ect_billable,'N') = 'Y' AND IsNull(@ord_hdrnumber,0) <> 0 THEN (@diff - IsNull(break_hours,0)) ELSE 0 END)
          WHERE seqno = @seqno
      END
   END

   UPDATE @stop_activity
      SET break_hours = IsNull(break_hours,0)
        , settle_hours = IsNull(settle_hours,0)
        , invoice_hours = IsNull(invoice_hours,0)

   --BEGIN PTS 77529 SPN
   IF @ShiftTimeRounding <> 'Y'
   BEGIN
      --BEGIN PTS 69824 SPN (fix rounding of hours issue by allocating the difference in the first row with enough hours)
      SELECT @LogInOut_Hours = DATEDIFF(ss, @ldt_login, @ldt_logout) / @sechour
      SELECT @tot_settle_hours  = SUM(settle_hours)
           , @tot_invoice_hours = SUM(invoice_hours)
        FROM @stop_activity
      IF (@tot_invoice_hours <> @LogInOut_Hours)
      BEGIN
         UPDATE @stop_activity
            SET invoice_hours = invoice_hours + (@LogInOut_Hours - @tot_invoice_hours)
          WHERE seqno = (SELECT MIN(seqno)
                           FROM @stop_activity
                          WHERE invoice_hours > (-1 * (@LogInOut_Hours - @tot_invoice_hours))
                        )
      END
      IF (@tot_settle_hours <> @LogInOut_Hours)
      BEGIN
         UPDATE @stop_activity
            SET settle_hours = settle_hours + (@LogInOut_Hours - @tot_settle_hours)
          WHERE seqno = (SELECT MIN(seqno)
                           FROM @stop_activity
                          WHERE settle_hours > (-1 * (@LogInOut_Hours - @tot_settle_hours))
                        )
      END
      --END PTS 69824 SPN
   END
   --END PTS 77529 SPN

   --BEGIN PTS 77529 SPN -- Apply the Shift Ceiling Quarter Hours to the first row
   IF @ShiftTimeRounding = 'Y'
   BEGIN
      SELECT @LogInOut_Hours = dbo.fnc_QuarterRound((DATEDIFF(ss, @ldt_login, @ldt_logout) / @sechour),'CEILING')
      SELECT @tot_settle_hours  = SUM(settle_hours)
        FROM @stop_activity
      IF (@tot_settle_hours <> @LogInOut_Hours)
      BEGIN
         UPDATE @stop_activity
            SET settle_hours = settle_hours + (@LogInOut_Hours - @tot_settle_hours)
          WHERE seqno = (SELECT MIN(seqno)
                           FROM @stop_activity
                          WHERE settle_hours > (-1 * (@LogInOut_Hours - @tot_settle_hours))
                        )
      END
   END
   --END PTS 77529 SPN

   IF @debug_ind = 'Y'
   BEGIN
      SELECT @msg = '*** End ' + @ord_or_lgh_number + Convert(varchar,@the_number)
      RAISERROR(@msg,10,1) WITH NOWAIT
   END

   --Result
   If @ord_or_lgh_number = 'O'
      IF @debug_ind = 'Y'
         SELECT *
           FROM @stop_activity
          WHERE ord_hdrnumber = @the_number
         ORDER BY ssl_activitydate_start
      ELSE
         SELECT mov_number
              , ord_hdrnumber
              , lgh_number
              , stp_event
              , ssl_activitydate_start
              , ssl_activitydate_end
              , ssl_activity_hrs
              , break_hours
              , settle_hours
              , invoice_hours
           FROM @stop_activity
          WHERE ord_hdrnumber = @the_number
         ORDER BY ssl_activitydate_start
   Else
      IF @debug_ind = 'Y'
         SELECT *
           FROM @stop_activity
          WHERE lgh_number = @the_number
         ORDER BY ssl_activitydate_start
      ELSE
         SELECT mov_number
              , ord_hdrnumber
              , lgh_number
              , stp_event
              , ssl_activitydate_start
              , ssl_activitydate_end
              , ssl_activity_hrs
              , break_hours
              , settle_hours
              , invoice_hours
           FROM @stop_activity
          WHERE lgh_number = @the_number
         ORDER BY ssl_activitydate_start

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[gettimecalc_shift_sp] TO [public]
GO
