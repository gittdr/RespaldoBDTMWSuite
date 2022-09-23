SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ida_GetCarrierLaneServiceRating] (
	@lgh_number int,
	@TheDate datetime
) as
-- ida_GetCarrierLaneServiceRating  18023, '07/20/07'


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

-- Get the lane for each carrier with the most specificity and a declared commitment
select
	clc.car_id,
	max(l.Specificity) as Specificity
into #comtemp
from core_carrierlanecommitment as clc (NOLOCK)
inner join #lanes as l
on clc.laneid = l.laneid
where
	clc.commitmentnumber > 0
	and clc.effectivedate <= @TheDate
	and clc.expiresdate >= @TheDate
	and clc.laneid in (select LaneId from #lanes)
group by car_id
-- select * from #comtemp -- display the results for debugging

-- Go back and get the commitment info for each carrier that has one
select
	clc.carrierlanecommitmentid,
	c.car_id,
	lf.code as CarrierRatingCode,
	clc.car_rating,
	l.laneid,
	c.specificity
into #commitments
from #comtemp as c
inner join #lanes as l
on c.specificity=l.specificity
inner join core_carrierlanecommitment as clc (NOLOCK)
left join labelfile lf (NOLOCK)
on clc.car_rating = lf.abbr and lf.labeldefinition = 'CarrierServiceRating'

on
	c.car_id=clc.car_id
	and l.laneid=clc.laneid
where
	clc.commitmentnumber > 0
	and clc.effectivedate <= @TheDate
	and clc.expiresdate >= @TheDate

select * from #commitments


GO
GRANT EXECUTE ON  [dbo].[ida_GetCarrierLaneServiceRating] TO [public]
GO
