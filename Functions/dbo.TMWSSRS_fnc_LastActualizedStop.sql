SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create function [dbo].[TMWSSRS_fnc_LastActualizedStop]
      (@trl_number as varchar(13))
returns int
as

begin

      declare @stp_number as int 

            
      set @stp_number = isnull((
            select top 1 stops.stp_number 
            from  assetassignment ass  with(nolock) 
                  inner join stops  with(nolock)  on ass.lgh_number = stops.lgh_number 
                  inner join event  with(nolock)  on event.stp_number = stops.stp_number and evt_sequence = 1
            where event.evt_trailer1 = @trl_number and ass.asgn_type = 'TRL'
                        and stp_status = 'DNE'
                        and stops.lgh_number in 
                  (select top 10 lgh_number  
				   from assetassignment ass  with(nolock) 
				   where ass.asgn_type = 'TRL'                                
                         and ass.asgn_id = @trl_number
                   order by asgn_date desc)
            order by stp_arrivaldate desc
            ),0)


      return @stp_number
end


GO
