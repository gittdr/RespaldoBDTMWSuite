SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ida_GetCurrentLegOrigDest] (
@lgh_number int
) as
--ida_GetCurrentLegOrigDest 27181	
select
	l.lgh_number,
	FirstStop.cmp_id as FirstStop,
	FirstStop.stp_city as FirstCity,
	LastStop.cmp_id as LastStop,
	LastStop.stp_city as LastCity
from legheader_active l (NOLOCK),
			Stops FirstStop (NOLOCK),
			Stops LastStop (NOLOCK)

where l.lgh_number=@lgh_number
and	  FirstStop.lgh_number= l.lgh_number
and	  FirstStop.stp_mfh_sequence = (select min(stp_mfh_sequence) from stops s where s.lgh_number = @lgh_number)
and	  LastStop.lgh_number= l.lgh_number
and	  LastStop.stp_mfh_sequence = (select max(stp_mfh_sequence) from stops s where s.lgh_number = @lgh_number)


GO
GRANT EXECUTE ON  [dbo].[ida_GetCurrentLegOrigDest] TO [public]
GO
