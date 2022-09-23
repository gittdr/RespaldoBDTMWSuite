SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[TMW_BrokerageTrackingStatus] (@lgh_number INT,
                                          @value      VARCHAR(25))
returns VARCHAR(30)
AS
  BEGIN
      DECLARE @mov INT

      SELECT @mov = mov_number
      FROM   legheader
      WHERE  lgh_number = @lgh_number

      DECLARE @next_open_stop INT
      DECLARE @next_open_stop_type VARCHAR(10)
      DECLARE @next_billable_stop INT
      DECLARE @next_billable_stop_type VARCHAR(10)
      DECLARE @next_open_stop_time DATETIME
      DECLARE @next_billable_stop_move INT
      DECLARE @next_billable_stop_type_move VARCHAR(10)
      DECLARE @next_sequence INT
      DECLARE @next_event VARCHAR(10)
      DECLARE @laststp_number INT
      DECLARE @returnval VARCHAR(100)
      DECLARE @lastdonedatetime DATETIME
      DECLARE @nextlatestdatetime DATETIME
      DECLARE @nextearliestdatetime DATETIME
      DECLARE @stp_mileage DECIMAL (8, 2)
      DECLARE @mphtonext DECIMAL (8, 2)
      DECLARE @tractorid VARCHAR(8)
      DECLARE @truckspeed INT
      DECLARE @etatonext DATETIME
      DECLARE @stp_schdtlatest DATETIME
      DECLARE @hrsaheadbehind DECIMAL(8, 2)
      DECLARE @truckspeed_varchar VARCHAR(3)
      DECLARE @lgh_outstatus VARCHAR(8)
      DECLARE @truckstatus VARCHAR(30)
      DECLARE @ord_status VARCHAR(6)
      DECLARE @loadsplancount INT
      DECLARE @tripstatus VARCHAR(30)
      DECLARE @car_or_truck VARCHAR(10)
      DECLARE @trailer VARCHAR(10)
      DECLARE @next_open_gmt INT
      DECLARE @CURRENT_ARRIVE_STATUS VARCHAR(5)
      DECLARE @CURRENT_DEPART_STATUS VARCHAR(5)
      DECLARE @CURRENT_EVENT VARCHAR(5)
      DECLARE @NEXT_OPEN_ARRIVAL DATETIME
      DECLARE @last_checkcall DATETIME
      DECLARE @rev4 VARCHAR(6)
      DECLARE @LAST_CKC_id INT
      DECLARE @ckc_confirmed INT

      SELECT @LAST_CKC_id = Isnull(ckc_number, -99)
      FROM   checkcall (nolock)
      WHERE  ckc_lghnumber = @lgh_number
             AND ckc_date = (SELECT Max(ckc_date)
                             FROM   checkcall (nolock)
                             WHERE  ckc_lghnumber = @lgh_number)

      SELECT @ckc_confirmed = CONVERT(VARCHAR, Count(*))
      FROM   checkcall (nolock)
      WHERE  ckc_lghnumber = @lgh_number
             AND ckc_event = 'CONF'

      SELECT @next_open_stop = stp_number,
             @next_open_stop_type = stp_type,
             @next_sequence = stp_sequence,
             @next_event = stp_event,
             @next_open_stop_time = stp_departuredate,
             @next_open_gmt = Isnull(cty_gmtdelta, Datediff(hh, Getdate(),
                                                   Getutcdate()))
             --assume server time if no GMT exists
             ,
             @NEXT_OPEN_ARRIVAL = stp_arrivaldate
      FROM   stops (nolock)
             JOIN city
               ON cty_code = stp_city
      WHERE  stp_number IN (SELECT Min(stp_number)
                            FROM   stops s1 (nolock)
                            WHERE  lgh_number = @lgh_number
                                   AND stp_mfh_sequence = (SELECT
                                       Min(stp_mfh_sequence)
                                                           FROM
                                       stops s2 (nolock)
                                                           WHERE
                                       s1.lgh_number = s2.lgh_number
                                       AND stp_departure_status = 'OPN'))

      SELECT @next_billable_stop = stp_number,
             @next_billable_stop_type = stp_type
      FROM   stops (nolock)
      WHERE  stp_number IN (SELECT Min(stp_number)
                            FROM   stops s1 (nolock)
                            WHERE  lgh_number = @lgh_number
                                   AND stp_mfh_sequence = (SELECT
                                       Min(stp_mfh_sequence)
                FROM
                                       stops s2 (nolock)
                                                           WHERE
                                       s1.lgh_number = s2.lgh_number
                                       AND stp_status = 'OPN'
                                       AND stp_type != 'NONE'))

      SELECT @next_billable_stop_move = stp_number,
             @next_billable_stop_type_move = stp_type
      FROM   stops (nolock)
      WHERE  stp_number IN (SELECT Min(stp_number)
                            FROM   stops s1 (nolock)
                            WHERE  mov_number = @mov
                                   AND stp_mfh_sequence = (SELECT
                                       Min(stp_mfh_sequence)
                                                           FROM
                                       stops s2 (nolock)
                                                           WHERE
                                       s1.mov_number = s2.mov_number
                                       AND stp_status = 'OPN'
                                       AND stp_type != 'NONE'))

      SELECT @laststp_number = Isnull(stp_number, 0),
             @lastdonedatetime = stp_departuredate,
             @CURRENT_ARRIVE_STATUS = stp_status,
             @CURRENT_DEPART_STATUS = stp_departure_status,
             @CURRENT_EVENT = stp_event
      FROM   stops (nolock)
      WHERE  stp_number IN (SELECT Min(stp_number)
                            FROM   stops s1 (nolock)
                            WHERE  lgh_number = @lgh_number
                                   AND stp_mfh_sequence = (SELECT
                                       Max(stp_mfh_sequence)
                                                           FROM
                                       stops s2 (nolock)
                                                           WHERE
                                       s1.lgh_number = s2.lgh_number
                                       AND stp_status = 'DNE'))

      SELECT @lgh_outstatus = lgh_outstatus,
             @car_or_truck = CASE
                               WHEN lgh_carrier = 'UNKNOWN' THEN lgh_tractor
                               ELSE lgh_carrier
                             END,
             @trailer = lgh_primary_trailer
      FROM   legheader_active (nolock)
      WHERE  lgh_number = @lgh_number

      SELECT @ord_status = ord_status,
			 @last_checkcall = CASE 
									WHEN ISDATE(ord_extrainfo13) = 1 THEN 
									CONVERT(DateTime, ord_extrainfo13) 
									ELSE NULL 
								END,
             @rev4 = ord_revtype4
      FROM   orderheader (nolock)
             INNER JOIN legheader (nolock)
                     ON orderheader.ord_hdrnumber = legheader.ord_hdrnumber
                        AND legheader.lgh_number = @lgh_number

      SELECT @nextlatestdatetime = CASE
                                     WHEN @next_event IN ( 'DLT', 'HLT' ) THEN
                                     stp_arrivaldate
                                     ELSE stp_schdtlatest
                                   END,
             @nextearliestdatetime = CASE
                                       WHEN @next_event IN ( 'DLT', 'HLT' ) THEN
                                       stp_arrivaldate
                                       ELSE stp_schdtearliest
                                     END,
             @stp_mileage = CONVERT(DECIMAL (8, 2), stp_lgh_mileage),
             @stp_schdtlatest = CASE
                                  WHEN @next_event IN ( 'DLT', 'HLT' ) THEN
                                  stp_arrivaldate
                                  ELSE stp_schdtlatest
                                END
      FROM   stops sp (nolock)
      WHERE  sp.stp_number = @next_open_stop

      IF (SELECT Count(*)
          FROM   tractorprofile (nolock)
          WHERE  trc_number = @car_or_truck
                 AND trc_number <> 'UNKNOWN') > 0
        BEGIN
            SELECT @truckspeed_varchar = CASE
                                           WHEN Isnumeric(trc_misc4) = 1 THEN
                                           CAST(trc_misc4 AS DECIMAL)
                                           ELSE '55'
                                         END
            FROM   tractorprofile (nolock)
            WHERE  trc_number = @car_or_truck
        END

      IF (SELECT Count(*)
          FROM   carrier (nolock)
          WHERE  car_id = @car_or_truck
                 AND car_id <> 'UNKNOWN') > 0
        SELECT @truckspeed_varchar = '55'

      SELECT @loadsplancount = Count(*)
      FROM   legheader_active nolock
      WHERE  lgh_tractor = @car_or_truck
             AND lgh_outstatus IN( 'PLN', 'DSP' )
             AND @tractorid <> 'UNKNOWN'

      SELECT @truckspeed = @truckspeed_varchar

      IF @truckspeed > 0
        BEGIN
            SELECT @etatonext = Dateadd(mi, ( @stp_mileage / @truckspeed ) * 60,
                                @lastdonedatetime)

            SELECT @hrsaheadbehind = CONVERT(DECIMAL (8, 2),
                                     Datediff (mi, @etatonext,
                                            @stp_schdtlatest)
                                     /
                                     60.00)
        END

      IF @lgh_outstatus = 'STD'
         AND @ord_status = 'PLN'
        SELECT @tripstatus = 'Deadheading' + ' to ' + @next_open_stop_type
                             + ' (' + @next_event + ') ' + ' #'
                             + CONVERT(VARCHAR, @next_sequence)
      ELSE IF @lgh_outstatus = 'PLN'
         AND @ord_status = 'PLN'
        SELECT @tripstatus = 'Just Planned'

      IF @lgh_outstatus = 'STD'
         AND @ord_status = 'STD'
         AND @next_event IN ( 'DLT', 'HLT' )
        SELECT @tripstatus = 'STD' + ' to ' + @next_event + ' (SPLIT)'

      IF @lgh_outstatus = 'STD'
         AND @ord_status = 'STD'
         AND @next_event NOT IN ( 'DLT', 'HLT' )
        SELECT @tripstatus = 'STD' + ' to ' + @next_open_stop_type + ' ('
                             + @next_event + ') ' + ' #'
                             + CONVERT(VARCHAR, @next_sequence)

      IF @lgh_outstatus = 'AVL'
         AND @ord_status = 'AVL'
        SELECT @tripstatus = 'AVL' + ' w/Trailer: ' + @trailer

      IF @lgh_outstatus = 'AVL'
         AND @ord_status IN ( 'PLN', 'DSP', 'STD' )
        SELECT @tripstatus = 'LEG ' + @lgh_outstatus + ' w/Trailer: '
                             + @trailer

      IF @lgh_outstatus = 'PLN'
         AND @ord_status IN ( 'PLN', 'DSP', 'STD' )
        SELECT @tripstatus = 'LEG ' + @lgh_outstatus + ' w/Trailer: '
                             + @trailer

      IF @lgh_outstatus = 'AVL'
         AND @ord_status = 'PND'
        SELECT @tripstatus = 'Pending EDI'

      IF @lgh_outstatus IN ( 'PLN', 'STD' )
         AND @ord_status IN ( 'PLN', 'DSP', 'STD' )
         AND Datediff(mi, Getdate(), @nextearliestdatetime) < 120
         AND @next_event NOT IN ( 'BMT', 'BBT' )
        SELECT @tripstatus = 'NEED CHECKCALL < 2 HRS TO PUP'

      IF @lgh_outstatus = 'PLN'
         AND @ord_status IN ( 'PLN', 'DSP', 'STD' )
         AND Datediff(mi, Getdate(), @nextearliestdatetime) < 360
         AND @next_event NOT IN ( 'BMT', 'BBT' )
        SELECT @tripstatus = 'NEED PRE-DISPATCH'

      IF @lgh_outstatus = 'STD'
         AND @ord_status = 'STD'
         AND Datediff(mi, @last_checkcall, Getdate()) > 480
         AND @rev4 != 'HV'
        SELECT @tripstatus = 'AT RISK / CHECKCALL MISSING'

      IF @lgh_outstatus = 'STD'
         AND @ord_status = 'STD'
         AND Datediff(mi, @last_checkcall, Getdate()) > 360
         AND @rev4 = 'HV'
        SELECT @tripstatus = '*HV* AT RISK / CHECKCALL MISSING'

      IF @lgh_outstatus = 'PLN'
         AND @ckc_confirmed = 0
        SELECT @tripstatus = 'Assigned'

      IF @lgh_outstatus = 'PLN'
         AND @ckc_confirmed > 0
        SELECT @tripstatus = 'Dispatched'

      IF @lgh_outstatus = 'STD'
         AND @ord_status = 'PLN'
        SELECT @tripstatus = 'Deadheading' + ' to ' + @next_open_stop_type
                             + ' (' + @next_event + ') ' + ' #'
                             + CONVERT(VARCHAR, @next_sequence)

      IF @lgh_outstatus = 'STD'
         AND @CURRENT_DEPART_STATUS = 'OPN'
         AND @CURRENT_EVENT IN ( 'LLD', 'HPL' )
        SELECT @tripstatus = 'Loading'

      IF @lgh_outstatus = 'STD'
         AND @CURRENT_DEPART_STATUS = 'DNE'
         AND @CURRENT_EVENT IN ( 'LLD', 'HPL' )
        SELECT @tripstatus = 'Loaded'

      IF @lgh_outstatus IN ( 'STD' )
         AND @CURRENT_DEPART_STATUS = 'OPN'
         AND @CURRENT_EVENT IN ( 'LUL', 'DRL' )
        SELECT @tripstatus = 'Emptying'

      SELECT @returnval = CASE
                            WHEN @value = 'CMPID' THEN
                            CONVERT(VARCHAR, company.cmp_id)
                            
                            WHEN @value = 'CMPNAME' THEN company.cmp_name
                            
                            WHEN @value = 'CMPCITY' THEN city.cty_nmstct
                            
                            --when @value = 'STPEARLY' then convert(varchar,stp_schdtearliest,10) + ' ' + left(convert(varchar,stp_schdtearliest,8),5)
                            
                            WHEN @value = 'STPLATE' THEN
                            CONVERT(VARCHAR, @nextlatestdatetime
                            , 10)
                            + ' '
                            + LEFT(CONVERT(VARCHAR, @nextlatestdatetime, 8),
                            5)
                            
                            WHEN @value = 'DISTANCE' THEN
                            CONVERT(VARCHAR, @stp_mileage)
                            
                            WHEN @value = 'LASTDNETIME' THEN (SELECT
                            CONVERT(VARCHAR, @lastdonedatetime, 10) + ' '
                            + LEFT(CONVERT(VARCHAR, @lastdonedatetime, 8), 5 )
                                                              FROM   stops sp
                                                              WHERE
                            sp.stp_number = @laststp_number)
                            
                            WHEN @value = 'MPHTONEXT' THEN LEFT(
                            CONVERT(VARCHAR, @mphtonext),
                            Charindex('.', CONVERT(VARCHAR,
                                           @mphtonext))
                                            - 1)
                            --convert(varchar,@mphtonext)
                            
                            WHEN @value = 'HRSAHEADBEHIND' THEN
                            CONVERT(VARCHAR, @hrsaheadbehind)
                            
                            WHEN @value = 'ETATONEXT' THEN
                            CONVERT(VARCHAR, @etatonext, 10) +
                            ' '
                            + LEFT(CONVERT(VARCHAR, @etatonext
                            , 8), 5)
                            
                            --when @value = 'DROPCOUNT' then convert(varchar, (select count(*) from stops s3 inner join legheader on s3.lgh_number = legheader.lgh_number where s3.lgh_number = @lgh_number and stp_type = 'DRP'))
                            
                            WHEN @value = 'TRIPSTATUS' THEN
                            CONVERT(VARCHAR, @tripstatus)
                            
                            WHEN @value = 'LOADSPLNCOUNT' THEN
                            CONVERT(VARCHAR, @loadsplancount)
                            
                            WHEN @value = 'STATUS' THEN
                            @lgh_outstatus + @ord_status
                            
                            WHEN @value = 'LAST_CKC' THEN (SELECT
                            CONVERT(VARCHAR, ckc_date, 10) + ' '
              				+ LEFT(CONVERT(VARCHAR, ckc_date, 8), 5)
                                                           FROM
                            checkcall (nolock)
                                                           WHERE
                            ckc_number = @LAST_CKC_id)
							--bcy start
							WHEN @value = 'last_ckc_city' THEN (SELECT
                            ckc_cityname
                                                           FROM
                            checkcall (nolock)
                                                           WHERE
                            ckc_number = @LAST_CKC_id)
                            --bcy end
                            WHEN @value = 'LAST_CKC_COMMENT' THEN (SELECT
                            ckc_comment
                                                                   FROM
                            checkcall (nolock)
                                                                   WHERE
                            ckc_number = @LAST_CKC_id)
                            
                            WHEN @value = 'CKC_CONFIRMED' THEN
                            CONVERT(VARCHAR, @ckc_confirmed)
                            
                            WHEN @value = 'NEXT_OPEN_EVENT' THEN @next_event
                            
                            WHEN @value = 'NEXT_OPEN_TIME' THEN
                            CONVERT(VARCHAR, @next_open_stop_time, 10)
                            + ' '
                            + LEFT(CONVERT(VARCHAR, @next_open_stop_time, 8), 5)
                            
                            WHEN @value = 'NEXT_OPEN_GMT' THEN
                            CONVERT(VARCHAR, @NEXT_OPEN_GMT)
                            
                            WHEN @value = 'NEXT_OPEN_ARV' THEN
                            CONVERT(VARCHAR, @NEXT_OPEN_ARRIVAL, 10)
                            + ' '
                            + LEFT(CONVERT(VARCHAR, @NEXT_OPEN_ARRIVAL,
                            8), 5)
                            
                            WHEN @value = 'CURRENT_STOP' THEN @lgh_outstatus
                          -- CONVERT(VARCHAR,@laststp_number) + @CURRENT_ARRIVE_STATUS + @CURRENT_DEPART_STATUS
                          END
      FROM   stops (nolock)
             JOIN company
               ON stops.cmp_id = company.cmp_id
             JOIN city
               ON city.cty_code = stops.stp_city
      WHERE  stp_number = @next_open_stop

      IF @value = 'OFFER_INFO'
        SELECT @returnval = CASE
                              WHEN ord_status IN ( 'avl', 'PND' )
                                   AND Isnull(tar_number, 0) > 0 THEN
                              'PUBLISHED OFFER'
                              WHEN ord_status IN ( 'avl', 'PND' )
                                   AND Isnull(tar_number, 0) = 0 THEN
                              'SPOT OFFER'
                              ELSE ''
                            END
        FROM   orderheader
        WHERE  ord_hdrnumber = @lgh_number

      IF @value = 'OSD_INFO'
        BEGIN
            SELECT @returnval = CASE
                                  WHEN (SELECT Count(*)
                                        FROM   freightdetail
                                        WHERE  stp_number IN (SELECT stp_number
                                                              FROM   stops
                                                              WHERE
                                               lgh_number = @lgh_number)
                                               AND Isnull(fgt_osdquantity, 0) >
                                                   0)
                                       > 0
                                THEN
                                  'OSD'
                                  ELSE ''
                                END
        END

      RETURN @returnval
  END

GO
GRANT EXECUTE ON  [dbo].[TMW_BrokerageTrackingStatus] TO [public]
GO
