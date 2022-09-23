SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[test_DeleteMonthOfBuckets] (
	@TheDate datetime
) as

-- Delete a month's worth of buckets
-- Monthly and daily commitments work on just "this-month" date restriction
-- Weekly commitments need to be adjusted to the week start/end
-- We'll move the weekly commitment dates earlier so beginning-of-month testing works properly

declare @WeeklyStartDate datetime
declare @NextWeeklyStartDate datetime

-- Get the month boundaries
set @WeeklyStartDate = cast(cast(year(@TheDate) as varchar)+'-'+cast(month(@TheDate) as varchar)+'-1' as datetime)
set @NextWeeklyStartDate = dateadd(month, 1, @WeeklyStartDate)
-- Adjust for week starts
set @WeeklyStartDate = dateadd(day, 1-datepart(dw, @WeeklyStartDate), @WeeklyStartDate)
set @NextWeeklyStartDate = dateadd(day, 7-datepart(dw, @NextWeeklyStartDate), @NextWeeklyStartDate)

delete
from core_carriercommitmentbuckets
where ccb_id in
(
	select
		ccb.ccb_id
	from core_carriercommitmentbuckets ccb
	inner join core_carrierlanecommitment clc
	on ccb.carrierlanecommitmentid = clc.carrierlanecommitmentid
	where
	(
		month(ccb.ccb_date) = month(@TheDate)
		and
		year(ccb.ccb_date) = year(@TheDate)
		and
		clc.commitmentperiod<>'W'
	)
	or
	(
		ccb.ccb_date >= @WeeklyStartDate
		and
		ccb.ccb_date < @NextWeeklyStartDate
		and
		clc.commitmentperiod='W'
	)
)
delete
from core_CarrierCapacityBuckets
where ccpb_id in
(
	select
		ccpb.ccpb_id
	from core_CarrierCapacityBuckets ccpb
	inner join core_carrierlanecommitment clc
	on ccpb.carrierlanecommitmentid = clc.carrierlanecommitmentid
	where
	(
		month(ccpb.ccpb_date) = month(@TheDate)
		and
		year(ccpb.ccpb_date) = year(@TheDate)
		and
		clc.commitment_cap_period<>'W'
	)
	or
	(
		ccpb.ccpb_date >= @WeeklyStartDate
		and
		ccpb.ccpb_date < @NextWeeklyStartDate
		and
		clc.commitment_cap_period='W'
	)
)

GRANT  EXECUTE  ON [dbo].[test_DeleteMonthOfBuckets]  TO [public]
GO
