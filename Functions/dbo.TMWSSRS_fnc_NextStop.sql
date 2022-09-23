SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create function [dbo].[TMWSSRS_fnc_NextStop]
      (@stp_number as int)
returns int
as


begin

	declare @trl_number as varchar(20)
	declare @leg_date as datetime
	declare @stp_date as datetime
	declare @next_stop as int


    set @trl_number = (select top 1 evt_trailer1 
					   from stops  with(nolock) 
							inner join event  with(nolock)  on event.stp_number = stops.stp_number and evt_sequence = 1
					   where stops.stp_number = @stp_number)
	
    set @stp_date = (select top 1 stp_arrivaldate
					 from stops  with(nolock) 
					 where stops.stp_number = @stp_number)
	
	set @leg_date = (select lgh_startdate
						from stops  with(nolock) 
							inner join legheader  with(nolock)  on legheader.lgh_number = stops.lgh_number 
						where stops.stp_number = @stp_number)


	set @next_stop = (select top 1 stops.stp_number from stops  with(nolock) 
						inner join event  with(nolock)  on event.stp_number = stops.stp_number and evt_sequence = 1
					  where stops.stp_arrivaldate > @stp_date and 
							lgh_number in (select lgh_number from assetassignment  with(nolock) 
								 		   where	asgn_id =  @trl_number and asgn_type = 'TRL'
													and asgn_date >= @leg_date)
							and evt_trailer1 = @trl_number		
					  order by stp_arrivaldate)

    return @next_stop 
end


GO
