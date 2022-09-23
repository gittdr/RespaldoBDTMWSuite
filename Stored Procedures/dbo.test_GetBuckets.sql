SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[test_GetBuckets] (
	@Lane int,
	@Date datetime
) as

select
	clc.laneid as LaneNum,
	clc.car_id as Carrier,
	clc.commitmentnumber as Commitment,
	clc.commitmentperiod as Period,
	IsNull(clc.car_commitment_cap,0) as CapNum,
	IsNull(clc.commitment_cap_period,'M') as CapPer,
	IsNull(clc.IsFrontLoadedCommitment,0) as FrontLoad,
	IsNull(clc.ExclusivePriority,0) as ExcPri,
	IsNull(clc.roundrobin_percent,0) as RndRbn
from core_carrierlanecommitment as clc (NOLOCK)
where
	clc.laneid = @Lane
	and clc.commitmentnumber > 0
order by clc.car_id asc

select
	clc.laneid as LaneNum,
	clc.car_id as Carrier,
	ccb.ccb_date as [Date],
	ccb.ccb_target as Target,
	ccb.ccb_recommended as Recommended,
	ccb.ccb_assigned as Assigned
from core_carrierlanecommitment as clc (NOLOCK)
left join core_carriercommitmentbuckets as ccb (NOLOCK)
on clc.carrierlanecommitmentid = ccb.carrierlanecommitmentid
where
	clc.laneid = @Lane
	and ccb_date = @Date
	and clc.commitmentnumber > 0
order by clc.car_id asc

select
	clc.laneid as LaneNum,
	clc.car_id as Carrier,
	ccpb.ccpb_date as [Date],
	ccpb.ccpb_capacity as Capacity,
	ccb.ccb_recommended as Recommended,
	ccb.ccb_assigned as Assigned
from core_carriercapacitybuckets as ccpb (NOLOCK)
left join core_carrierlanecommitment as clc (NOLOCK)
on clc.carrierlanecommitmentid = ccpb.carrierlanecommitmentid
left join core_carriercommitmentbuckets as ccb (NOLOCK)
on ccpb.carrierlanecommitmentid = ccb.carrierlanecommitmentid
and ccpb.ccpb_date = ccb.ccb_date
where
	clc.laneid = @Lane
order by clc.car_id asc


GRANT  EXECUTE  ON [dbo].[test_GetBuckets]  TO [public]
GO
