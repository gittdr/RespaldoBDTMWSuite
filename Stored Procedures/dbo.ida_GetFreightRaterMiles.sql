SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ida_GetFreightRaterMiles] (
@lgh_number int
) as
--ida_GetFreightRaterMiles 27181	
select
	IsNull(l.lgh_externalrating_miles,0)
from legheader l (NOLOCK)
where l.lgh_number=@lgh_number

GO
GRANT EXECUTE ON  [dbo].[ida_GetFreightRaterMiles] TO [public]
GO
