SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[ida_GetCarrierCommitmentStatus] (
	@lgh_number int,
	@TheDate datetime
) as
 --ida_GetCarrierCommitmentStatus 18050, '06/26/07'

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
--select * from #lanes -- display the results for debugging

select
	clc.car_id,
	l.lanename as Lane,
	l.specificity as Spec,
	clc.commitmentnumber as ComNum,
	clc.commitmentperiod as ComPer,
	IsNull(clc.car_commitment_cap,0) as CapNum,
	IsNull(clc.commitment_cap_period,'M') as CapPer,
	IsNull(clc.IsFrontLoadedCommitment,0) as FrontLoad,
	IsNull(clc.ExclusivePriority,0) as ExcPri,
	IsNull(clc.roundrobin_percent,0) as RndRbn,
	l.laneid,
	clc.carrierlanecommitmentid
into #commitments
from core_carrierlanecommitment as clc (NOLOCK)
inner join #lanes as l
on clc.laneid = l.laneid
where
	clc.effectivedate <= @TheDate
	and clc.expiresdate >= @TheDate
	and clc.laneid in (select LaneId from #lanes)
order by clc.car_id, l.lanename 


select * from #commitments

-- Make sure commitment and capacity buckets exist for carrierlanes/date
select @CurrentClcId = min(carrierlanecommitmentid) from #commitments
while (not @CurrentClcId is null)
begin
	exec core_AssertBuckets @CurrentClcId, @TheDate
	select @CurrentClcId = min(carrierlanecommitmentid) from #commitments where carrierlanecommitmentid>@CurrentClcId
end

--Get previous commitment bucket totals (some or none of the previous buckets may exist)
select
	c.car_id,
	laneid,
	isnull(sum(ccb.ccb_target), 0) as Target,
	isnull(sum(ccb.ccb_assigned), 0) as Assigned,
	isnull(sum(ccb.ccb_recommended), 0) as Recommended,
	isnull(count(ccb.ccb_id), 0) as BucketCount
from core_carriercommitmentbuckets as ccb (NOLOCK)
inner join #commitments as c
	on ccb.carrierlanecommitmentid = c.carrierlanecommitmentid
where
	ccb.ccb_date >=
	(
		case when c.ComPer='W' then
			-- The number produced by the weekday (dw) datepart depends on the value set by SET DATEFIRST, which sets the first day of the week.
			-- See: http://msdn2.microsoft.com/en-us/library/aa258265(SQL.80).aspx
			dateadd(day, 1-datepart(dw, @TheDate), @TheDate)
		else
			cast(cast(year(@TheDate) as varchar)+'-'+cast(month(@TheDate) as varchar)+'-1' as datetime)
		end
	)
	and ccb.ccb_date < @TheDate
group by c.car_id, laneid
order by c.car_id, laneid

--Get current commitment bucket totals (this bucket must exist)
select
	c.car_id,
	laneid,
	sum(ccb.ccb_target) as Target,
	sum(ccb.ccb_assigned) as Assigned,
	sum(ccb.ccb_recommended) as Recommended,
	count(ccb.ccb_id) as BucketCount
from core_carriercommitmentbuckets as ccb (NOLOCK)
inner join #commitments as c
on ccb.carrierlanecommitmentid = c.carrierlanecommitmentid
where
	ccb.ccb_date = @TheDate
group by c.car_id, laneid
order by c.car_id, laneid



--Get commitment bucket totals until the end of the period (some or none of the future buckets may exist)
select
	c.car_id,
	laneid,
	sum(isnull(ccb.ccb_target, 0)) as Target,
	sum(isnull(ccb.ccb_assigned, 0)) as Assigned,
	sum(isnull(ccb.ccb_recommended, 0)) as Recommended,
	count(ccb.ccb_id) as BucketCount
from core_carriercommitmentbuckets as ccb (NOLOCK)
inner join #commitments as c
	on ccb.carrierlanecommitmentid = c.carrierlanecommitmentid
where
	ccb.ccb_date <=
	(
		case when c.ComPer='W' then
			-- The number produced by the weekday (dw) datepart depends on the value set by SET DATEFIRST, which sets the first day of the week.
			-- See: http://msdn2.microsoft.com/en-us/library/aa258265(SQL.80).aspx
			dateadd(day, 7-datepart(dw, @TheDate), @TheDate)
		else
				dateadd(day, -1, 
				dateadd(month, 1,
				cast(cast(year(@TheDate) as varchar)+'-'+cast(month(@TheDate) as varchar)+'-1' as datetime)
				)
				)
		end
	)
	and ccb.ccb_date > @TheDate
group by c.car_id, laneid
order by c.car_id, laneid

-- get capacity buckets
select
	c.car_id,
	laneid,
	sum(isnull(ccpb.ccpb_capacity, 0)) as Capacity,
	sum(isnull(ccb.ccb_assigned, 0)) as Assigned,
	sum(isnull(ccb.ccb_recommended, 0)) as Recommended,
	count(ccpb.ccpb_id) as BucketCount
from core_carriercapacitybuckets ccpb (nolock)
inner join #commitments as c
	on ccpb.carrierlanecommitmentid = c.carrierlanecommitmentid
left join core_carriercommitmentbuckets as ccb (NOLOCK)
	on ccb.carrierlanecommitmentid = c.carrierlanecommitmentid
	and ccb.ccb_date = ccpb.ccpb_date 

where	ccpb.ccpb_date >=
	(
		case when c.CapPer='D' then
				@TheDate
		     when c.CapPer='W' then
			-- The number produced by the weekday (dw) datepart depends on the value set by SET DATEFIRST, which sets the first day of the week.
			-- See: http://msdn2.microsoft.com/en-us/library/aa258265(SQL.80).aspx
				dateadd(day, 1-datepart(dw, @TheDate), @TheDate)
			else
				cast(cast(year(@TheDate) as varchar)+'-'+cast(month(@TheDate) as varchar)+'-1' as datetime)
			end
	)
and ccpb.ccpb_date <= 
	(
		case when c.CapPer='D' then
				@TheDate
		     when c.CapPer='W' then
			-- The number produced by the weekday (dw) datepart depends on the value set by SET DATEFIRST, which sets the first day of the week.
			-- See: http://msdn2.microsoft.com/en-us/library/aa258265(SQL.80).aspx
				dateadd(day, 7-datepart(dw, @TheDate), @TheDate)
			else
				dateadd(day, -1, 
				dateadd(month, 1,
				cast(cast(year(@TheDate) as varchar)+'-'+cast(month(@TheDate) as varchar)+'-1' as datetime)
				)
				)
			end
	)
group by c.car_id, laneid
order by c.car_id, laneid



-- Clean up our temporary tables
--drop table #BucketsToCreate
drop table #lanes
drop table #commitments

GO
GRANT EXECUTE ON  [dbo].[ida_GetCarrierCommitmentStatus] TO [public]
GO
