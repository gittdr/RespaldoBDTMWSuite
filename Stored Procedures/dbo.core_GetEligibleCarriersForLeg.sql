SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[core_GetEligibleCarriersForLeg] (
	@lgh_number int,
	@activedate datetime
) as


-- Get the lanes
create table #lanes
   (
	LaneId		int,
	LaneName	varchar(50),
	Specificity	int,
	Radius int
   )
insert into #lanes
select * from core_fncGetLanesForLeg (@lgh_number) 
-- select * from #lanes -- display the results for debugging

-- Get the lane-eligibility for each carrier with the most specificity and a declared eligible/not eligible flag
select
	clc.car_id,
	max(l.Specificity) as Specificity
into #eligibility
from core_carrierlanecommitment as clc (NOLOCK)
inner join #lanes as l
on clc.laneid = l.laneid
where
	clc.IsEligible is not null
	and clc.IsEligible <> ''
	and clc.effectivedate <= @activedate
	and clc.expiresdate >= @activedate
	and clc.laneid in (select LaneId from #lanes)
group by car_id
-- select * from #eligibility -- display the results for debugging

-- Go back and get the complete details for that eligible lane for each carrier that is eligible
select
	e.car_id,
	l.laneid,
	e.specificity,
	clc.IsEligible
from #eligibility as e
inner join #lanes as l
on e.specificity=l.specificity
inner join core_carrierlanecommitment as clc (NOLOCK)
on
	e.car_id=clc.car_id
	and l.laneid=clc.laneid
where
	clc.IsEligible='Y'
	and clc.effectivedate <= @activedate
	and clc.expiresdate >= @activedate

-- Clean up our temporary tables
drop table #lanes
drop table #eligibility



GO
GRANT EXECUTE ON  [dbo].[core_GetEligibleCarriersForLeg] TO [public]
GO
