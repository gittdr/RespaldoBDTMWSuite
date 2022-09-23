SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[gettimecalc_sp] (@ord_hdrnumber INTEGER,
                                 @lgh_number	INTEGER,
                                 @inside_hours	DECIMAL(8,2) OUTPUT,
                                 @outside_hours DECIMAL(8,2) OUTPUT)
AS

DECLARE @first_stop		INTEGER,
	@first_arrival		DATETIME,
	@first_departure	DATETIME,
        @last_stop		INTEGER,
	@last_arrival		DATETIME,
	@last_departure		DATETIME,
	@inside_seconds		INTEGER,
	@outside_seconds	INTEGER
	
-- PTS 71874 fix issue 1.start	
IF @lgh_number > 0
	BEGIN
	   SELECT @first_stop = legheader.stp_number_start,
			  @last_stop = legheader.stp_number_end
		 FROM legheader
		WHERE lgh_number = @lgh_number
	END
ELSE
	BEGIN
		IF @ord_hdrnumber > 0
		BEGIN
		   SELECT @first_stop = stp_number
			 FROM stops
			WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
				  stops.stp_sequence = (SELECT MIN(stp_sequence)
										  FROM stops
										 WHERE ord_hdrnumber = @ord_hdrnumber)
		   SELECT @last_stop = stp_number
			 FROM stops
			WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
				  stops.stp_sequence = (SELECT MAX(stp_sequence)
										  FROM stops
										 WHERE ord_hdrnumber = @ord_hdrnumber)
		END
	END	
	
--IF @ord_hdrnumber <> 0 AND @lgh_number = 0
--BEGIN
--   SELECT @first_stop = stp_number
--     FROM stops
--    WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
--          stops.stp_sequence = (SELECT MIN(stp_sequence)
--                                  FROM stops
--                                 WHERE ord_hdrnumber = @ord_hdrnumber)

--   SELECT @last_stop = stp_number
--     FROM stops
--    WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
--          stops.stp_sequence = (SELECT MAX(stp_sequence)
--                                  FROM stops
--                                 WHERE ord_hdrnumber = @ord_hdrnumber)
--END

--IF @ord_hdrnumber = 0 AND @lgh_number > 0
--BEGIN
--   SELECT @first_stop = legheader.stp_number_start,
--          @last_stop = legheader.stp_number_end
--     FROM legheader
--    WHERE lgh_number = @lgh_number
--END
-- PTS 71874 fix issue 1.end

SELECT @first_arrival = stp_arrivaldate,
       @first_departure = stp_departuredate
  FROM stops
 WHERE stp_number = @first_stop

SELECT @last_arrival = stp_arrivaldate,
       @last_departure = stp_departuredate
  FROM stops
 WHERE stp_number = @last_stop
 
 
-- PTS 71874 fix issue 2.start	
--SET @inside_seconds = DATEDIFF(ss, @first_departure, @last_arrival)
--SET @inside_hours = @inside_seconds/3600.0
--SET @outside_seconds = DATEDIFF(ss, @first_arrival, @last_departure)
--SET @outside_hours = @outside_seconds/3600.0

SET @inside_seconds = DATEDIFF(ss, @first_departure, @last_arrival)
SET @outside_seconds = DATEDIFF(ss, @first_arrival, @last_departure)

DECLARE @divisor		float
DECLARE @typesMustMatch	float
declare @seconds		float

set @divisor = 3600.00
set @seconds = Convert(float, @inside_seconds) 
set @typesMustMatch = ( @seconds / @divisor ) 
set @inside_hours = CONVERT(decimal(8,2), @typesMustMatch )

set @seconds = Convert(float, @outside_seconds) 
set @typesMustMatch = ( @seconds / @divisor ) 
SET @outside_hours = CONVERT(decimal(8,2), @typesMustMatch )
-- PTS 71874 fix issue 2.end



GO
GRANT EXECUTE ON  [dbo].[gettimecalc_sp] TO [public]
GO
