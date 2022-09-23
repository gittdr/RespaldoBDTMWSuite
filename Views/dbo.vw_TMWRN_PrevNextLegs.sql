SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create view [dbo].[vw_TMWRN_PrevNextLegs]
as

/*
This view creates a double-linked list of sequential leg assignments
for tractors.  It is used by the Round Trip stored procedures in the
identification of round trips.
*/

select	lgh_number,
		L.lgh_startdate,
		NextLeg = (
						select 	max(lgh_number)
						from 	legheader L2 with (NOLOCK)
						where 	lgh_startdate  =
									(SELECT	min(L3.lgh_startDate)
									From	Legheader L3 with (NOLOCK)
									where	L3.lgh_tractor= L.lgh_tractor and
											L3.lgh_tractor = L2.lgh_tractor and
											L3.LGH_startdate > L.lgh_startdate AND
											L3.lgh_number <> L.lgh_number AND
											L3.lgh_outstatus in ('STD','CMP')
									)
					),
		PrevLeg = (	select 	min(lgh_number)
						from 	legheader L2 with (NOLOCK) 
						where 	lgh_startdate  =
									(SELECT	max(L3.lgh_startDate)
									From	Legheader L3 with (NOLOCK)
									where	L3.lgh_tractor= L.lgh_tractor and
											L3.lgh_tractor = L2.lgh_tractor and
											L3.LGH_startdate < L.lgh_startdate AND
											L3.lgh_number <> L.lgh_number AND
											L3.lgh_outstatus = 'CMP'
									)
					)
from	legheader L with (NOLOCK)
where 	--lgh_enddate between '20000701' and '20000801' AND
		lgh_outstatus IN ('CMP','STD')
		and lgh_tractor != 'UNKNOWN'
GO
GRANT DELETE ON  [dbo].[vw_TMWRN_PrevNextLegs] TO [public]
GO
GRANT INSERT ON  [dbo].[vw_TMWRN_PrevNextLegs] TO [public]
GO
GRANT SELECT ON  [dbo].[vw_TMWRN_PrevNextLegs] TO [public]
GO
GRANT UPDATE ON  [dbo].[vw_TMWRN_PrevNextLegs] TO [public]
GO
