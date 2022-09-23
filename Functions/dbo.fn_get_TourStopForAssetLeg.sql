SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_get_TourStopForAssetLeg]
( @asgn_type                  VARCHAR(6)
, @asgn_id                    VARCHAR(13)
, @lgh_number                 INT
, @ShowCompanyStopOffSettings CHAR(1)
, @StopOffPayEvents           VARCHAR(1000)
, @IgnoreDuplicateStop        CHAR(1)
) RETURNS @Table TABLE (pyd_atd_id INT NULL, tourstops INT NULL)

AS
/**
 *
 * NAME:
 * dbo.fn_get_TourStopForAssetLeg
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure used for computing number of tour stops for a given leg and asset
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @asgn_type                   VARCHAR(6)
 * 002 @asgn_id                     VARCHAR(13)
 * 003 @lgh_number                  INT
 * 004 @ShowCompanyStopOffSettings  CHAR(1)
 * 005 @StopOffPayEvents            VARCHAR(1000)
 * 006 @IgnoreDuplicateStop         CHAR(1)
 *
 * REVISION HISTORY:
 * PTS 65914 SPN 12/07/12 - Initial Version Created
 * PTS 66382 SPN 01/03/13 - Added new Parm @IgnoreDuplicateStop
 * PTS 66454 SPN 01/08/13 - Tour can have just one leg and any and all Free Stop may be applied to it.  Return 0 when tour stop count is negetive.
 *
 **/

BEGIN

   DECLARE @fst_FIRSTLAST        VARCHAR(30)
   DECLARE @fst_FIRST            VARCHAR(30)
   DECLARE @fst_LAST             VARCHAR(30)

   DECLARE @maxseqno             INT
   DECLARE @seqno                INT
   DECLARE @temp_lgh_number      INT

   DECLARE @stop_location        VARCHAR(100)
   DECLARE @prev_stop_location   VARCHAR(100)

   DECLARE @pyd_atd_id           INT
   DECLARE @tourstops            INT

   DECLARE @temp TABLE
   ( seqno              INT IDENTITY
   , free_stop_type     VARCHAR(30)
   , atd_id             INT
   , lgh_number         INT
   , stp_number         INT
   , billto             VARCHAR(8)
   , payable_stopevents VARCHAR(1000)
   , stp_event          VARCHAR(8)
   , stp_departuredate  DATETIME
   , stp_count          INT
   , free_stop          INT
   , stop_location      VARCHAR(100)
   , duplicate_stop_ind INT
   )

   --Free Stop Types
   SELECT @fst_FIRSTLAST  = 'FIRST+LAST'
   SELECT @fst_FIRST      = 'FIRST'
   SELECT @fst_LAST       = 'LAST'

   --Get Tour Info
   INSERT INTO @temp
   ( free_stop_type
   , atd_id
   , lgh_number
   , stp_number
   , billto
   , payable_stopevents
   , stp_event
   , stp_departuredate
   , stp_count
   , free_stop
   , stop_location
   , duplicate_stop_ind
   )
   SELECT h.free_stop_type
        , d.atd_id
        , d.lgh_number
        , s.stp_number
        , 'UNKNOWN'
        , NULL
        , s.stp_event
        , s.stp_departuredate
        , 0
        , 0
        , IsNull(cmp_id,'UNKNOWN') + IsNull(stp_address,'UNKNOWN') + IsNull(stp_address2,'UNKNOWN') + Convert(VARCHAR,IsNull(stp_city,0)) + IsNull(stp_state,'XX') + IsNull(stp_zipcode,'UNKNOWN')
        , 0
     FROM assetassignment_tour_hdr h
     JOIN assetassignment_tour_dtl d on h.ath_id = d.ath_id
     JOIN stops s on d.lgh_number = s.lgh_number
    WHERE h.asgn_type = @asgn_type
      AND h.asgn_id   = @asgn_id
      AND h.ath_id = (SELECT MAX(ath_id) FROM assetassignment_tour_dtl WHERE lgh_number = @lgh_number)
   ORDER BY s.stp_departuredate

   SELECT @maxseqno = MAX(seqno)
     FROM @temp

   --Check duplicate stop
   SELECT @seqno = 0
   SELECT @prev_stop_location = '-None-'
   WHILE @seqno < @maxseqno
   BEGIN
      SELECT @seqno = @seqno + 1
      SELECT @stop_location = stop_location
        FROM @temp
       WHERE seqno = @seqno
      IF @stop_location = @prev_stop_location
      BEGIN
         UPDATE @temp
            SET duplicate_stop_ind = 1
          WHERE seqno = @seqno
      END
      SELECT @prev_stop_location = @stop_location
   END

   --When ShowCompanyStopOffSettings is ON Get BillTo Profile cmp_stopevents_pay
   If @ShowCompanyStopOffSettings = 'Y'
   BEGIN
      SELECT @seqno = 0
      WHILE @seqno < @maxseqno
      BEGIN
         SELECT @seqno = @seqno + 1
         SELECT @temp_lgh_number = lgh_number
           FROM @temp
          WHERE seqno = @seqno
         IF 1 <= (SELECT COUNT(DISTINCT o.ord_billto)
                    FROM legheader l
                    JOIN orderheader o ON l.mov_number = o.mov_number
                   WHERE l.lgh_number = @temp_lgh_number
                 )
            UPDATE @temp
               SET billto = (SELECT MAX(o.ord_billto)
                               FROM legheader l
                               JOIN orderheader o ON l.mov_number = o.mov_number
                              WHERE l.lgh_number = @temp_lgh_number
                            )
      END
      UPDATE @temp
         SET payable_stopevents = cmp.cmp_stopevents_pay
        FROM @temp t1
        JOIN (SELECT cmp_id
                   , cmp_stopevents_pay
                FROM company
               WHERE cmp_stopevents_pay IS NOT NULL
                 AND cmp_stopevents_pay <> ''
             ) cmp ON t1.billto = cmp.cmp_id
   END

   --Fill missing payable_stopevents with tts50 setting @StopOffPayEvents
   UPDATE @temp
      SET payable_stopevents = @StopOffPayEvents
    WHERE payable_stopevents IS NULL
       OR payable_stopevents = ''
   --If payable_stopevents is still NULL then the stp_event must be counted
   UPDATE @temp
      SET payable_stopevents = stp_event
    WHERE payable_stopevents IS NULL
       OR payable_stopevents = ''

   --If IgnoreDuplicateStop is ON then Mark duplicate stops a Non-Payable
   If @IgnoreDuplicateStop = 'Y'
      BEGIN
         UPDATE @temp
            SET stp_event = '*' + stp_event + '*'
          WHERE duplicate_stop_ind = 1
      END

   --Stop Count per leg
   UPDATE @temp
      SET stp_count = t.stp_count
     FROM @temp t1
     JOIN (SELECT lgh_number  AS lgh_number
                , COUNT(1)    AS stp_count
             FROM @temp
            WHERE CHARINDEX(',' + stp_event + ',',',' + payable_stopevents + ',') > 0
           GROUP BY lgh_number
          ) t on t1.lgh_number = t.lgh_number

   --First and the Last leg has 1 free stop
   UPDATE @temp
      SET free_stop = 1
    WHERE free_stop_type IN (@fst_FIRSTLAST, @fst_FIRST)
      AND seqno = 1

   UPDATE @temp
      SET free_stop = free_stop + 1
    WHERE free_stop_type IN (@fst_FIRSTLAST, @fst_LAST)
      AND lgh_number = (SELECT lgh_number
                          FROM @temp
                         WHERE seqno = (SELECT MAX(seqno) FROM @temp)
                       )

   --Return the Tour Detail ID and Applicable Stop Count for the Trip segment
   SELECT TOP 1
          @pyd_atd_id = atd_id
        , @tourstops  = stp_count - free_stop
     FROM @temp
    WHERE lgh_number = @lgh_number

   IF IsNull(@tourstops,-1) < 0
      SELECT @tourstops = 0

   INSERT INTO @Table(pyd_atd_id,tourstops)
   VALUES (@pyd_atd_id, @tourstops)

   RETURN

END
GO
GRANT REFERENCES ON  [dbo].[fn_get_TourStopForAssetLeg] TO [public]
GO
GRANT SELECT ON  [dbo].[fn_get_TourStopForAssetLeg] TO [public]
GO
