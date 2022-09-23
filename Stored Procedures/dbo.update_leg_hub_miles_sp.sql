SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[update_leg_hub_miles_sp] (@mov_number INT)
AS

declare @lgh_number int

BEGIN

select @lgh_number = min(lgh_number) 
	from legheader 
	where mov_number = @mov_number

while @lgh_number is not null begin

	update legheader set 
		lgh_odometerstart = (select min(evt_hubmiles) from event where stp_number in (
				select stp_number from stops where lgh_number = @lgh_number)
			),
		lgh_odometerend = (select max(evt_hubmiles) from event where stp_number in (
				select stp_number from stops where lgh_number = @lgh_number)
			)
	where lgh_number = @lgh_number

	select @lgh_number = min(lgh_number) 
		from legheader 
		where mov_number = @mov_number
			and lgh_number > @lgh_number
			
	end -- while

END -- 	proc

GO
GRANT EXECUTE ON  [dbo].[update_leg_hub_miles_sp] TO [public]
GO
