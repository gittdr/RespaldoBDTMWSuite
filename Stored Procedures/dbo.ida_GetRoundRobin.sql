SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ida_GetRoundRobin] (
	@lgh_number int,
	@TheDate datetime
) as
-- ida_GetRoundRobin 18056, '07/20/07'

declare @CurrentClcId int

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

-- Get the lane for each carrier with the most specificity and a declared round robin
select
	clc.car_id,
	max(l.Specificity) as Specificity
into #comtemp
from core_carrierlanecommitment as clc (NOLOCK)
inner join #lanes as l
on clc.laneid = l.laneid
where
	clc.roundrobin_percent > 0
	and clc.effectivedate <= @TheDate
	and clc.expiresdate >= @TheDate
	and clc.laneid in (select LaneId from #lanes)
group by car_id
-- select * from #comtemp -- display the results for debugging

-- Go back and get the round robin info for each carrier that has one
select
	clc.carrierlanecommitmentid,
	c.car_id,
	clc.roundrobin_percent,
	l.laneid,
	c.specificity
into #commitments
from #comtemp as c
inner join #lanes as l
on c.specificity=l.specificity
inner join core_carrierlanecommitment as clc (NOLOCK)
on
	c.car_id=clc.car_id
	and l.laneid=clc.laneid
where
	clc.roundrobin_percent > 0
	and clc.effectivedate <= @TheDate
	and clc.expiresdate >= @TheDate

select * from #commitments

-- Clean up our temporary tables
--drop table #BucketsToCreate
drop table #lanes
drop table #comtemp
drop table #commitments


GO
GRANT EXECUTE ON  [dbo].[ida_GetRoundRobin] TO [public]
GO
