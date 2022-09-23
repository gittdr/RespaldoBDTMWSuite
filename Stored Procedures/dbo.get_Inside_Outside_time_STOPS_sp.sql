SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_Inside_Outside_time_STOPS_sp] (  @lgh_number	INTEGER,
										 @stp_arrivaldate datetime,
										 @stp_departuredate datetime,
										 @inside_hours	DECIMAL(8,2) OUTPUT,
										 @outside_hours DECIMAL(8,2) OUTPUT )
AS

set nocount on 

-- Proc created for:  PTS 71874
-- the math will fail due to data type mismatch; do math as float, convert to dec for output.
-- 7-14-2014:  move into CORE vss

DECLARE @first_arrival		DATETIME,
	    @first_departure	DATETIME,  
		@last_arrival		DATETIME,
		@last_departure		DATETIME,
		@inside_seconds		INTEGER,
		@outside_seconds	INTEGER,
		@divisor			float,
		@typesMustMatch		float,
		@seconds			float	

select @first_arrival =  @stp_arrivaldate
select @last_departure = @stp_departuredate

select	    @first_departure = MIN(stp_departuredate)
			,@last_arrival = Max(stp_arrivaldate) 			
from		stops
where		lgh_number = @lgh_number
AND			stp_arrivaldate >=	@stp_arrivaldate
AND			stp_departuredate <= @stp_departuredate
group by	lgh_number

SET @inside_seconds = DATEDIFF(ss, @first_departure, @last_arrival)
SET @outside_seconds = DATEDIFF(ss, @first_arrival, @last_departure)

set @divisor = 3600.00
set @seconds = Convert(float, @inside_seconds) 
set @typesMustMatch = ( @seconds / @divisor ) 
set @inside_hours = CONVERT(decimal(8,2), @typesMustMatch )

set @seconds = Convert(float, @outside_seconds) 
set @typesMustMatch = ( @seconds / @divisor ) 
SET @outside_hours = CONVERT(decimal(8,2), @typesMustMatch )



GO
GRANT EXECUTE ON  [dbo].[get_Inside_Outside_time_STOPS_sp] TO [public]
GO
