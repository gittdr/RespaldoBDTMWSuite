SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_BrokerageTrackingStatusOnly] (@lgh_number INT)
RETURNS VARCHAR(30)
AS
  BEGIN
      DECLARE @mov INT

      SELECT @mov = mov_number
      FROM   legheader
      WHERE  lgh_number = @lgh_number

      DECLARE @next_open_stop INT
      DECLARE @next_open_stop_type VARCHAR(10)
      DECLARE @next_open_stop_time DATETIME
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

      SELECT @CURRENT_ARRIVE_STATUS = stp_status,
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

      SELECT @ord_status = ord_status
      FROM   orderheader (nolock)
             INNER JOIN legheader (nolock)
                     ON orderheader.ord_hdrnumber = legheader.ord_hdrnumber
                        AND legheader.lgh_number = @lgh_number

      IF @lgh_outstatus = 'PLN'
        SELECT @tripstatus = 'Assigned'

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

      SELECT @returnval = CONVERT(VARCHAR, @tripstatus)

      RETURN @returnval
end

GO
GRANT EXECUTE ON  [dbo].[fn_BrokerageTrackingStatusOnly] TO [public]
GO
