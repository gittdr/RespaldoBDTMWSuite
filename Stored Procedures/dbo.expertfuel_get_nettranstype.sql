SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[expertfuel_get_nettranstype] (@leg int, @requestid int, @value char(1) OUTPUT)
AS

/*
	PTS 46324 - DJM - Created to get the value for the 'new' field in the ExpertFuel request string - Network Trans Type.
	Proc needs to return the appropriate value to the Trigger that sets the actual value on the Record.
*/

Declare
	@fleet	varchar(8),
	@trc	varchar(12)



-- Get the Tractor on the Request record
select @trc = isNull(gf_tractor,'') from geofuelrequest where gf_lgh_number = @leg and gf_requestid = @requestid


if @trc = '' 
	select @value = ' '
else
	begin
		select @fleet = Rtrim(isNull(trc_fleet, trc_type1)) from tractorprofile where trc_number = @trc

		-- Customer for PTS 46324 wants the value based on the trc_fleet value in the Tractorprofile for the Request record tractor.
		select @value = Case Ltrim(Rtrim(@fleet))
			when 'IC' then '2'
			else '1'
			end
		from tractorprofile

	end



Return @value





GO
GRANT EXECUTE ON  [dbo].[expertfuel_get_nettranstype] TO [public]
GO
