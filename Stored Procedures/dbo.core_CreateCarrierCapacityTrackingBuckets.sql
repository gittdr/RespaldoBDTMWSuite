SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[core_CreateCarrierCapacityTrackingBuckets] (
	@carrierlanecommitmentid int,
	@TheDate datetime
) as

declare @CommitmentNumber int
declare @EffectiveDate datetime
declare @ExpiresDate datetime
declare @CapStartDate datetime
declare @CapNextStartDate datetime
declare @car_commitment_cap int
declare @Commitment_Cap_Period varchar(50)

select
	@car_commitment_cap=clc.car_commitment_cap,
	@Commitment_Cap_Period=clc.Commitment_Cap_Period,
	@EffectiveDate=clc.effectivedate,
	@ExpiresDate=clc.expiresdate
from core_carrierlanecommitment as clc (NOLOCK)
where clc.carrierlanecommitmentid=@carrierlanecommitmentid

-- Get the start date of the period
-- The number produced by the weekday (dw) datepart depends on the value set by SET DATEFIRST, which sets the first day of the week.
-- See: http://msdn2.microsoft.com/en-us/library/aa258265(SQL.80).aspx

-- capacity period calculations
if (@Commitment_Cap_Period = 'D')
	set @CapStartDate = @TheDate
if (@Commitment_Cap_Period = 'W')
	set @CapStartDate = dateadd(day, 1-datepart(dw, @TheDate), @TheDate)
if (@Commitment_Cap_Period = 'M')
	set @CapStartDate = cast(cast(year(@TheDate) as varchar)+'-'+cast(month(@TheDate) as varchar)+'-1' as datetime)

-- Make sure we got a valid commitment period
if (@CapStartDate is null) or (IsNull(@car_commitment_cap,0) = 0)
begin
	-- raiserror ('Unknown carrier capacity period creating daily capacity-tracking buckets', 12, 1)
	goto EndProc
end

-- Get the start date of the next period
if (@Commitment_Cap_Period = 'D')
	set @CapNextStartDate = dateadd(day, 1, @CapstartDate)
if (@Commitment_Cap_Period = 'W')
	set @CapNextStartDate = dateadd(day, 7, @CapstartDate)
if (@Commitment_Cap_Period = 'M')
	set @CapNextStartDate = dateadd(month, 1, @CapstartDate)

-- First, just get enough rows to work with and assign an identity column
select top 31 identity(int,0,1) as RowId into #TempCounter
from city (nolock) -- any table that's large enough to produce the needed number of rows

-- capacity buckets

-- Add a date column
select
	dateadd(day, RowId, @CapStartDate) as BucketDate
into #TempDateBuckets
from #TempCounter
drop table #TempCounter

-- Now remove invalid days and create a count of actual buckets
select
	identity(int,0,1) as BucketNumber,
	cast(1 as int) as NeedsTarget, -- Use this line to include weekend days in target buckets
	--cast (case when ((datepart(weekday, BucketDate)=1 or datepart(weekday, BucketDate)=7)) then 0 else 1 end as int) as NeedsTarget,  -- Use this line to omit weekend days from target buckets
	*
into #TempCapacityBucket
from #TempDateBuckets
where
	BucketDate >= @CapStartDate
	and BucketDate < @CapNextStartDate
	and BucketDate >= @EffectiveDate
	and BucketDate <= @ExpiresDate
drop table #TempDateBuckets


--Ensure the buckets don't already exist
if exists (
	select * from core_carriercapacitybuckets (nolock)
	where
		carrierlanecommitmentid = @carrierlanecommitmentid
		and ccpb_date >= @CapStartDate
		and ccpb_date < @CapNextStartDate
)
begin
	raiserror ('Attempt to re-create daily commitment-tracking buckets', 12, 1)
	drop table #TempCapacityBucket
	goto EndProc
end

-- distribute the capacity to first day in period
	-- Add 'em to the bucket table
	insert into core_carriercapacitybuckets
	select
		@carrierlanecommitmentid as carrierlanecommitmentid,
		BucketDate as ccpb_date,
		case when BucketNumber = 0 then @car_commitment_cap else 0 end as ccpb_capacity
	from #TempCapacityBucket



EndProc:


GO
GRANT EXECUTE ON  [dbo].[core_CreateCarrierCapacityTrackingBuckets] TO [public]
GO
