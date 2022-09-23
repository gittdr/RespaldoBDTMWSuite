SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[gettimecalc_new_sp]
      ( @ord_hdrnumber  INT
      , @lgh_number     INT
      , @BMTIN          DECIMAL(8,2)   OUTPUT
      , @BMTOUT         DECIMAL(8,2)   OUTPUT
      , @DPARLD         DECIMAL(8,2)   OUTPUT
      , @ARPLD          DECIMAL(8,2)   OUTPUT
      , @MISCIN         DECIMAL(8,2)   OUTPUT
      , @MISCOUT        DECIMAL(8,2)   OUTPUT
      , @EMTIN          DECIMAL(8,2)   OUTPUT
      , @EMTOUT         DECIMAL(8,2)   OUTPUT
      , @TOTMTI         DECIMAL(8,2)   OUTPUT
      , @TOTMTO         DECIMAL(8,2)   OUTPUT
      , @BMTAA          DECIMAL(8,2)   OUTPUT
      , @EMTDD          DECIMAL(8,2)   OUTPUT
      )
AS

/*
*
*
* NAME:
* dbo.gettimecalc_new_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to return different lapse times from stops
*
* RETURNS:
*
* NOTHING:
*
* 04/11/2011 PTS55879 SPN - Created Initial Version
* 04/02/2012 PTS61849 SPN - Introduced BMTAA and EMTDD
* 03/08/2013 PTS67994 SPN - Removed cursor for possible performance issue in SQL2005
*
*/

SET NOCOUNT ON

DECLARE @debug_ind         CHAR(1)

DECLARE @mov_number        INT
DECLARE @start_datetime    DATETIME
DECLARE @end_datetime      DATETIME
DECLARE @rowcnt            INT
DECLARE @cnt               INT
DECLARE @stp_type          VARCHAR(6)
DECLARE @stp_event         VARCHAR(6)
DECLARE @stp_arrivaldate   DATETIME
DECLARE @stp_departuredate DATETIME

DECLARE @BMT_Ignore        INT
DECLARE @BMTIN_Date_From   DATETIME
DECLARE @BMTOUT_Date_From  DATETIME
DECLARE @BMTAA_Date_From   DATETIME
DECLARE @BMTIN_Date_To     DATETIME
DECLARE @BMTOUT_Date_To    DATETIME
DECLARE @BMTAA_Date_To     DATETIME
DECLARE @BMT_MISCIN        DECIMAL(8,2)
DECLARE @BMT_MISCOUT       DECIMAL(8,2)
DECLARE @BMT_MISCAA        DECIMAL(8,2)

DECLARE @EMT_Ignore        INT
DECLARE @EMTIN_Date_From   DATETIME
DECLARE @EMTOUT_Date_From  DATETIME
DECLARE @EMTDD_Date_From   DATETIME
DECLARE @EMTIN_Date_To     DATETIME
DECLARE @EMTOUT_Date_To    DATETIME
DECLARE @EMTDD_Date_To     DATETIME
DECLARE @EMT_MISCIN        DECIMAL(8,2)
DECLARE @EMT_MISCOUT       DECIMAL(8,2)
DECLARE @EMT_MISCDD        DECIMAL(8,2)

DECLARE @MisCtr            INT
DECLARE @MisOpenCtr        INT
DECLARE @PUPDRP_Ignore     INT
DECLARE @PUPIN_Date_From   DATETIME
DECLARE @PUPOUT_Date_From  DATETIME
DECLARE @DRPIN_Date_To     DATETIME
DECLARE @DRPOUT_Date_To    DATETIME
DECLARE @MISCIN_Date_From  DATETIME
DECLARE @MISCOUT_Date_From DATETIME
DECLARE @MISCIN_Date_To    DATETIME
DECLARE @MISCOUT_Date_To   DATETIME
DECLARE @FirstEvent        VARCHAR(6)
DECLARE @LastEvent         VARCHAR(6)

BEGIN

   CREATE TABLE #stops
   ( id                 INT         IDENTITY
   , stp_type           VARCHAR(6)  NULL
   , stp_event          VARCHAR(6)  NULL
   , stp_arrivaldate    DATETIME    NULL
   , stp_departuredate  DATETIME    NULL
   )

   SELECT @mov_number = mov_number
     FROM orderheader
    WHERE ord_hdrnumber = @ord_hdrnumber

   IF @ord_hdrnumber IS NOT NULL AND @ord_hdrnumber <> 0
      BEGIN
         SELECT @start_datetime = MIN(stp_arrivaldate)
              , @end_datetime = MAX(stp_departuredate)
           FROM stops
          WHERE ord_hdrnumber = @ord_hdrnumber
         INSERT INTO #stops (stp_type,stp_event,stp_arrivaldate,stp_departuredate)
         SELECT stp_type,stp_event,stp_arrivaldate,stp_departuredate
           FROM stops
          WHERE mov_number = @mov_number
			--PTS79314 JJF 20140806 add IDMT, IHMT
            AND (ord_hdrnumber = @ord_hdrnumber OR stp_event IN ('DMT','HMT','DLT','HLT', 'IDMT', 'IHMT'))
            AND stp_arrivaldate >= @start_datetime
            AND stp_departuredate <= @end_datetime
         ORDER BY stp_arrivaldate
      END
   ELSE
      BEGIN
         SELECT @start_datetime = MIN(stp_arrivaldate)
              , @end_datetime = MAX(stp_departuredate)
           FROM stops
          WHERE lgh_number = @lgh_number
         INSERT INTO #stops (stp_type,stp_event,stp_arrivaldate,stp_departuredate)
         SELECT stp_type,stp_event,stp_arrivaldate,stp_departuredate
           FROM stops
          WHERE lgh_number = @lgh_number
            AND stp_arrivaldate >= @start_datetime
            AND stp_departuredate <= @end_datetime
         ORDER BY stp_arrivaldate
      END

   SELECT @debug_ind = 'N'

   SELECT @BMT_Ignore      = 1
   SELECT @BMT_MISCIN      = 0
   SELECT @BMT_MISCOUT     = 0
   SELECT @BMT_MISCAA      = 0
   SELECT @EMT_Ignore      = 1
   SELECT @EMT_MISCIN      = 0
   SELECT @EMT_MISCOUT     = 0
   SELECT @EMT_MISCDD      = 0
   SELECT @PUPDRP_Ignore   = 1
   SELECT @MisCtr          = 0
   SELECT @MISCIN          = 0
   SELECT @MISCOUT         = 0
   SELECT @cnt             = 0

   SELECT @rowcnt = COUNT(1)
     FROM #stops

   IF @debug_ind = 'Y'
   BEGIN
      Print '### Type   Event    Arrival               Departure          '
      Print '-------------------------------------------------------------'
   END

   --PTS73598 MBR 12/31/13 Check to see if this is a billable empty move and return the total time if so in the BMTAA variable
   IF @rowcnt = 2
   BEGIN
      SELECT @FirstEvent = stp_event
        FROM #stops
       WHERE id = 1
      SELECT @LastEvent = stp_event
        FROM #stops
       WHERE id = 2
      
      IF (@FirstEvent = 'IBMT' OR @FirstEvent = 'BMT') AND
         (@LastEvent = 'IEMT' OR @LastEvent = 'EMT') 
      BEGIN
         SET @BMTIN = 0
      	 SET @BMTOUT = 0
         SET @DPARLD = 0
         SET @ARPLD = 0
         SET @MISCIN = 0
         SET @MISCOUT = 0
         SET @EMTIN = 0
         SET @EMTOUT = 0
         SET @TOTMTI = 0
         SET @TOTMTO = 0
         SET @BMTAA = DATEDIFF(ss, @start_datetime, @end_datetime)/3600.0
         SET @EMTDD = 0

         RETURN
      END
   END
	

   WHILE @cnt < @rowcnt
   BEGIN
      SELECT @cnt = @cnt +1

      SELECT @stp_type = stp_type
           , @stp_event = stp_event
           , @stp_arrivaldate = stp_arrivaldate
           , @stp_departuredate = stp_departuredate
        FROM #stops
       WHERE id = @cnt

      --1st PUP
      If (@stp_type = 'PUP') AND (@PUPIN_Date_From IS NULL AND @PUPOUT_Date_From IS NULL)
      BEGIN
         SELECT @PUPIN_Date_From  = @stp_departuredate
         SELECT @PUPOUT_Date_From = @stp_arrivaldate
      END
      --Last DRP
      If (@stp_type = 'DRP') AND (@PUPIN_Date_From IS NOT NULL AND @PUPOUT_Date_From IS NOT NULL)
      BEGIN
         SELECT @PUPDRP_Ignore    = 0
         SELECT @DRPIN_Date_To    = @stp_arrivaldate
         SELECT @DRPOUT_Date_To   = @stp_departuredate
      END

      --Begin Empty Times
      IF @cnt = 1
         If (@stp_type = 'PUP')
            SELECT @BMT_Ignore = 1
         Else
            BEGIN
               SELECT @BMT_Ignore = 0
               SELECT @BMTIN_Date_From  = @stp_departuredate
               SELECT @BMTOUT_Date_From = @stp_arrivaldate
            END
      ELSE
         If (@stp_type = 'PUP')
            If @BMTIN_Date_To IS NULL AND @BMTOUT_Date_To IS NULL
               BEGIN
                  SELECT @BMTIN_Date_To    = @stp_arrivaldate
                  SELECT @BMTOUT_Date_To   = @stp_departuredate
               END

      --End Empty Times
      IF @cnt = @rowcnt
         If (@stp_type = 'DRP')
            SELECT @EMT_Ignore = 1
         Else
            BEGIN
               SELECT @EMT_Ignore = 0
               SELECT @EMTIN_Date_To  = @stp_arrivaldate
               SELECT @EMTOUT_Date_To = @stp_departuredate
            END
      ELSE
         If (@stp_type = 'DRP')
            BEGIN
               SELECT @EMTIN_Date_From  = @stp_departuredate
               SELECT @EMTOUT_Date_From = @stp_arrivaldate
            END

      --Miscellaneous Empty Times
	  --PTS79314 JJF 20140806 add IDMT
      IF (@stp_event = 'DMT' OR @stp_event = 'DLT' or @stp_event = 'IDMT')
         If @MISCIN_Date_From IS NULL AND @MISCOUT_Date_From IS NULL AND @BMTAA_Date_From IS NULL AND @EMTDD_Date_From IS NULL
         BEGIN
            IF @debug_ind = 'Y'
               Print 'Begin Break'
            SELECT @MISCIN_Date_From  = @stp_departuredate
            SELECT @MISCOUT_Date_From = @stp_arrivaldate
            SELECT @BMTAA_Date_From   = @stp_arrivaldate
            SELECT @EMTDD_Date_From   = @stp_departuredate
            SELECT @MisOpenCtr = 1
         END
         Else
            SELECT @MisOpenCtr = @MisOpenCtr + 1

      IF @debug_ind = 'Y'
         Print Left(convert(varchar,@cnt) + Space(3),3) + ' ' + Left(@stp_type + Space(6),6) + ' ' + Left(@stp_event + Space(6),6) + '   ' + Convert(varchar,@stp_arrivaldate) + '   ' + Convert(varchar,@stp_departuredate)

      IF (@stp_event = 'HMT' OR @stp_event = 'HLT' OR @stp_event = 'IHMT')  --PTS79314 JJF 20140806 add IHMT
         If @MISCIN_Date_From IS NOT NULL AND @MISCOUT_Date_From IS NOT NULL AND @BMTAA_Date_From IS NOT NULL AND @EMTDD_Date_From IS NOT NULL
            If @MisOpenCtr = 1
            BEGIN
               SELECT @MISCIN_Date_To  = @stp_arrivaldate
               SELECT @MISCOUT_Date_To = @stp_departuredate
               SELECT @BMTAA_Date_To   = @stp_arrivaldate
               SELECT @EMTDD_Date_To   = @stp_departuredate
               IF (@BMTIN_Date_From  IS NOT NULL AND @BMTIN_Date_To IS NULL)
               OR (@BMTOUT_Date_From IS NOT NULL AND @BMTOUT_Date_To IS NULL)
                  BEGIN
                     --Begin Empty in process.  Give credit to BegMT for this MiscTime
                     SELECT @BMT_MISCIN    = @BMT_MISCIN  + (DATEDIFF(ss, @MISCIN_Date_From, @MISCIN_Date_To) / 3600.0)
                     SELECT @BMT_MISCOUT   = @BMT_MISCOUT + (DATEDIFF(ss, @MISCOUT_Date_From, @MISCOUT_Date_To) / 3600.0)
                     SELECT @BMT_MISCAA    = @BMT_MISCAA  + (DATEDIFF(ss, @BMTAA_Date_From, @BMTAA_Date_To) / 3600.0)
                  END
               ELSE IF (@EMTIN_Date_From  IS NOT NULL AND @EMTIN_Date_To IS NULL)
                    OR (@EMTOUT_Date_From IS NOT NULL AND @EMTOUT_Date_To IS NULL)
                  BEGIN
                     --End Empty in process.  Give credit to BegMT for this MiscTime
                     SELECT @EMT_MISCIN  = @EMT_MISCIN  + (DATEDIFF(ss, @MISCIN_Date_From, @MISCIN_Date_To) / 3600.0)
                     SELECT @EMT_MISCOUT = @EMT_MISCOUT + (DATEDIFF(ss, @MISCOUT_Date_From, @MISCOUT_Date_To) / 3600.0)
                     SELECT @EMT_MISCDD  = @EMT_MISCDD  + (DATEDIFF(ss, @EMTDD_Date_From, @EMTDD_Date_To) / 3600.0)
                  END
               ELSE
                  BEGIN
                     --Misc Breakdown etc while PUP-DRP
                     SELECT @MISCIN  = @MISCIN + (DATEDIFF(ss, @MISCIN_Date_From, @MISCIN_Date_To) / 3600.0)
                     SELECT @MISCOUT = @MISCOUT + (DATEDIFF(ss, @MISCOUT_Date_From, @MISCOUT_Date_To) / 3600.0)
                  END
               SELECT @MisCtr = @MisCtr + 1
               SELECT @MISCIN_Date_From   = NULL
               SELECT @MISCOUT_Date_From  = NULL
               SELECT @BMTAA_Date_From    = NULL
               SELECT @EMTDD_Date_From    = NULL
               SELECT @MISCIN_Date_To     = NULL
               SELECT @MISCOUT_Date_To    = NULL
               SELECT @BMTAA_Date_To      = NULL
               SELECT @EMTDD_Date_To      = NULL
               IF @debug_ind = 'Y'
                  Print 'End Break'
            END
            Else
               SELECT @MisOpenCtr = @MisOpenCtr -1

      IF @debug_ind = 'Y' AND @cnt = @rowcnt
         Print '-------------------------------------------------------------'

   END
   DROP TABLE #stops

   --Begin Empty Hrs
   IF @BMT_Ignore = 1
   BEGIN
      SELECT @BMTIN  = 0
      SELECT @BMTOUT = 0
      SELECT @BMTAA  = 0
   END
   ELSE
   BEGIN
      SET @BMTIN  = (DATEDIFF(ss, @BMTIN_Date_From, @BMTIN_Date_To) / 3600.0) + @BMT_MISCIN
      SET @BMTOUT = (DATEDIFF(ss, @BMTOUT_Date_From, @BMTOUT_Date_To) / 3600.0) + @BMT_MISCOUT
      SET @BMTAA  = (DATEDIFF(ss, @BMTOUT_Date_From, @BMTIN_Date_To) / 3600.0) + @BMT_MISCAA
   END

   --DPARLD and ARPLD Hrs
   IF @PUPDRP_Ignore = 1
   BEGIN
      SELECT @DPARLD = 0
      SELECT @ARPLD  = 0
   END
   ELSE
   BEGIN
      SELECT @DPARLD = (DATEDIFF(ss, @PUPIN_Date_From, @DRPIN_Date_To) / 3600.0) - @MISCIN
      SELECT @ARPLD  = (DATEDIFF(ss, @PUPOUT_Date_From, @DRPOUT_Date_To) / 3600.0) - @MISCOUT
   END

   --End Empty Hrs
   IF @EMT_Ignore = 1
   BEGIN
      SELECT @EMTIN  = 0
      SELECT @EMTOUT = 0
      SELECT @EMTDD  = 0
   END
   ELSE
   BEGIN
      SET @EMTIN  = (DATEDIFF(ss, @EMTIN_Date_From, @EMTIN_Date_To) / 3600.0) + @EMT_MISCIN
      SET @EMTOUT = (DATEDIFF(ss, @EMTOUT_Date_From, @EMTOUT_Date_To) / 3600.0) + @EMT_MISCOUT
      SET @EMTDD  = (DATEDIFF(ss, @EMTIN_Date_From, @EMTOUT_Date_To) / 3600.0) + @EMT_MISCDD
   END

   --Total Empty
   BEGIN
      SET @TOTMTI = @BMTIN  + @MISCIN  + @EMTIN
      SET @TOTMTO = @BMTOUT + @MISCOUT + @EMTOUT
   END

   IF @debug_ind = 'Y'
   BEGIN
      Print 'BMTIN   = ' + convert(varchar,@BMTIN)
      Print 'BMTOUT  = ' + convert(varchar,@BMTOUT)
      Print 'BMTAA   = ' + convert(varchar,@BMTAA)
      Print ''
      Print 'DPARLD  = ' + convert(varchar,@DPARLD)
      Print 'ARPLD   = ' + convert(varchar,@ARPLD)
      Print ''
      Print 'MISCIN  = ' + convert(varchar,@MISCIN)
      Print 'MISCOUT = ' + convert(varchar,@MISCOUT)
      Print ''
      Print 'EMTIN   = ' + convert(varchar,@EMTIN)
      Print 'EMTOUT  = ' + convert(varchar,@EMTOUT)
      Print 'EMTDD   = ' + convert(varchar,@EMTDD)
      Print ''
      Print 'TOTMTI  = ' + convert(varchar,@TOTMTI)
      Print 'TOTMTO  = ' + convert(varchar,@TOTMTO)
   END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[gettimecalc_new_sp] TO [public]
GO
