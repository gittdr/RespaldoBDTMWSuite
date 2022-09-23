SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.update_stops    Script Date: 8/20/97 1:59:53 PM ******/
create PROCEDURE [dbo].[update_stops] @mov int AS 
                                            

DECLARE @minstp 		int,
	@stat 			char(6),
	@departurestatus 	varchar(6),
	@early			datetime,
	@late			datetime,
	@arrival		datetime,
	@departure		datetime,
	@completeondeparture	Char(1)

SELECT @minstp = 0

--PTS35785 MBR 01/15/07
SELECT @completeondeparture = ISNULL(LEFT(UPPER(gi_string1), 1), 'N')
  FROM generalinfo
 WHERE gi_name = 'CompleteOnDeparture'

WHILE ( SELECT COUNT(*) 
FROM stops
WHERE stp_number > @minstp AND
    mov_number = @mov ) > 0
BEGIN
    /* pts 6137 added plus 0 to make sure inde never picked*/	
    SELECT @minstp = MIN ( stp_number )
	FROM stops 
   	WHERE stp_number + 0  > @minstp AND
	    mov_number = @mov 

    SELECT	@stat = evt_status,
		@early = evt_earlydate,
		@late = evt_latedate,
		@arrival = evt_startdate,
		@departure = evt_enddate,
		@departurestatus = ISNULL(evt_departure_status, 'OPN')
	FROM event
	WHERE stp_number = @minstp AND
	    evt_sequence = 1

    --PTS35785 MBR 01/15/07
    IF @completeondeparture = 'N'
       UPDATE stops
          SET stp_status = @stat,
	      stp_schdtearliest = @early,
	      stp_schdtlatest = @late,
	      stp_arrivaldate = @arrival,
	      stp_departuredate = @departure
        WHERE stp_number = @minstp

    IF @completeondeparture = 'Y'
       UPDATE stops
          SET stp_status = @stat,
              stp_departure_status = @departurestatus,
	      stp_schdtearliest = @early,
	      stp_schdtlatest = @late,
	      stp_arrivaldate = @arrival,
	      stp_departuredate = @departure
        WHERE stp_number = @minstp
END
                                         
GO
GRANT EXECUTE ON  [dbo].[update_stops] TO [public]
GO
