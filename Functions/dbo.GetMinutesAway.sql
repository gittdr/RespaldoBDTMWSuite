SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE function [dbo].[GetMinutesAway](@mov_number int) returns int
as 
begin
DECLARE @latemode varchar(25);
DECLARE @currentdate as datetime;
DECLARE @minutesAway as int;
--declare @stp_number int;
declare @earliestmin as int; declare @arrivalmin as int; declare @depaturemin as int; declare @latestmin as int;

select @latemode = ISNULL((select top 1 gi_string1 from generalinfo where gi_name = 'PlnWrkshtLateWarnMode'),'PUPDRP')
select @currentdate = GETDATE()
if (@latemode = 'PUPDRP')
	BEGIN	
		--check pup
		select @arrivalmin = datediff(minute,@currentDate ,(select min(stp_arrivaldate) from stops where mov_number = @mov_number and stp_type = 'PUP' and stp_arrivaldate > @currentdate)) 	
		--check drp
		select @depaturemin = datediff(minute,@currentDate ,(select max(stp_departuredate) from stops where mov_number = @mov_number and stp_type = 'DRP' and stp_departuredate > @currentdate))
		select @minutesAway = isnull(@arrivalmin,3000000)		
		if (isnull(@depaturemin,3000000) < @minutesAway) select @minutesAway = isnull(@depaturemin,3000000)	
	return @minutesAway
	END
	
ELSE IF (@latemode = 'EVENT')
	BEGIN			
		select @arrivalmin = ISNULL( (select min(datediff(minute,@currentDate,stp_arrivaldate)) from stops where mov_number = @mov_number and stp_arrivaldate > @currentDate),3000000)		
		select @depaturemin = ISNULL( (select min(datediff(minute,@currentDate,stp_departuredate)) from stops where mov_number = @mov_number and stp_departuredate > @currentDate),3000000)		
		select @minutesAway = (@arrivalmin)		
		if (@depaturemin < @minutesAway) select @minutesAway = @depaturemin					 	
    return @minutesAway
	END
	
ELSE IF (@latemode = 'ARRIVALDEPARTURE')
	BEGIN
	    select @earliestmin = ISNULL( (select min(datediff(minute,@currentDate,stp_schdtearliest)) from stops where mov_number = @mov_number and stp_schdtearliest > @currentDate),3000000)
	    select @arrivalmin = ISNULL( (select min(datediff(minute,@currentDate,stp_arrivaldate)) from stops where mov_number = @mov_number and stp_arrivaldate > @currentDate),3000000)	
		select @depaturemin = ISNULL( (select min(datediff(minute,@currentDate,stp_departuredate)) from stops where mov_number = @mov_number and stp_departuredate > @currentDate),3000000)		
		select @latestmin = ISNULL( (select min(datediff(minute,@currentDate,stp_schdtlatest)) from stops where mov_number = @mov_number and stp_schdtlatest > @currentDate),3000000)		
		select @minutesAway = (@earliestmin)		
		if (@arrivalmin < @minutesAway) select @minutesAway = @arrivalmin
		if (@depaturemin < @minutesAway) select @minutesAway = @depaturemin
		if (@latestmin < @minutesAway) select @minutesAway = @latestmin				 	
	return @minutesAway
	END
return 3000000
end
GO
GRANT EXECUTE ON  [dbo].[GetMinutesAway] TO [public]
GO
