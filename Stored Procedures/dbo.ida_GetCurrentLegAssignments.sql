SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





create proc [dbo].[ida_GetCurrentLegAssignments] (
@lgh_number int
) as
	
select
	lgh_number,
	lgh_outstatus,
	lgh_tractor,
	lgh_driver1,
	lgh_driver2,
	lgh_carrier
from legheader_active  (NOLOCK)
where lgh_number=@lgh_number



GO
GRANT EXECUTE ON  [dbo].[ida_GetCurrentLegAssignments] TO [public]
GO
