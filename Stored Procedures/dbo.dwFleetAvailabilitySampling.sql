SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- Part 2

Create  PROCEDURE [dbo].[dwFleetAvailabilitySampling]

AS

SET NOCOUNT ON

declare @DateStart datetime
declare @SamplingDate datetime
declare @DateEnd datetime
declare @SamplingID int


set @SamplingDate = GETDATE()
--set @SamplingDate = '20110902 14:00:00.000'
set @DateStart = CONVERT(datetime,Floor(convert(float,@SamplingDate)))
set @DateEnd = DATEADD(d,1,@DateStart)

-- convert @SamplingDate to EXACTLY prior 15 minute mark for consistency in data warehouse time dimension
Set @SamplingDate = CONVERT(datetime,CONVERT(varchar(14),@SamplingDate,121) + 
Case
	when DATEPART(mi,@SamplingDate) < 15 then '00'
	when DATEPART(mi,@SamplingDate) < 30 then '15'
	when DATEPART(mi,@SamplingDate) < 45 then '30'
Else
	'45'
End)

Insert into dwFleetAvailabilitySamplingID (SamplingDate)
Select @SamplingDate

Select @SamplingID = SamplingID
From dwFleetAvailabilitySamplingID
Where SamplingDate = @SamplingDate


-- Start with Tractors
create table #TractorList 
	(
		SamplingID int
		,SamplingDate datetime
		,trc_number varchar(32)
		,Seated_Driver1 varchar(32)
		,Seated_Driver2 varchar(32)
		,Working_Driver1 varchar(32)
		,Working_Driver2 varchar(32)
		,Planned_Driver1 varchar(32)
		,Planned_Driver2 varchar(32)
		,Seated int
		,Unseated int
		,WorkingNow int
		,Planned int
		,Assigned int
		,Waiting int
		,OnExpiration int
		,LegOfRecord int
		,RevType1 varchar(12)
		,RevType2 varchar(12)
		,RevType3 varchar(12)
		,RevType4 varchar(12)
	)

-- get a definitive list of current tractors
insert into #TractorList
	(
		SamplingID,SamplingDate,trc_number,Seated_Driver1,Seated_Driver2,Working_Driver1,Working_Driver2,Planned_Driver1,Planned_Driver2
		,Seated,Unseated,WorkingNow,Planned,Assigned,Waiting,OnExpiration,LegOfRecord,RevType1,RevType2,RevType3,RevType4
	)
select SamplingID = @SamplingID
,SamplingDate = @SamplingDate
,trc_number
,Seated_Driver1 = IsNull(trc_driver,'UNKNOWN')
,Seated_Driver2 = IsNull(trc_driver2,'UNKNOWN')
,Working_Driver1 = 'UNKNOWN'
,Working_Driver2 = 'UNKNOWN'
,Planned_Driver1 = 'UNKNOWN'
,Planned_Driver2 = 'UNKNOWN'
,Seated = 0
,Unseated = 0 
,WorkingNow = 0
,Planned = 0
,Assigned = 0
,Waiting = 0
,OnExpiration = 0
,LegOfRecord = NULL
,RevType1 = NULL
,RevType2 = NULL
,RevType3 = NULL
,RevType4 = NULL
from tractorprofile TP
where trc_retiredate > @SamplingDate
AND trc_number <> 'UNKNOWN'

-- Update the Seated STATE Value
Update #TractorList set Seated = 1
where Seated_Driver1 <> 'UNKNOWN'

-- Update the Unseated STATE Value
Update #TractorList set Unseated = Case when Seated = 1 then 0 else 1 end

-- Update the WorkingNow STATE Value, and Driver ID's
Update #TractorList set WorkingNow = 1
,Working_Driver1 = lgh_driver1
,Working_Driver2 = lgh_driver2
,LegOfRecord = lgh_number
from legheader LH, #TractorList T1
where LH.lgh_tractor = T1.trc_number
AND LH.lgh_enddate >= @SamplingDate
AND LH.lgh_startdate < @SamplingDate

-- Update the Planned STATE Value, and Driver ID's
Update #TractorList set Planned = 1
,Planned_Driver1 = lgh_driver1
,Planned_Driver2 = lgh_driver2
,LegOfRecord = Case when LegOfRecord is NULL then LH.lgh_number else LegOfRecord End
from legheader LH, #TractorList T1
where LH.lgh_tractor = T1.trc_number
AND LH.lgh_startdate = 
	(
		Select MIN(T2.lgh_startdate)
		from legheader T2
		where T2.lgh_tractor = LH.lgh_tractor
		AND T2.lgh_startdate >= @SamplingDate
		AND T2.lgh_startdate < @DateEnd
	)		

-- Update the Assigned STATE Value
Update #TractorList set Assigned = 
	Case
		when WorkingNow = 1 then 1
		when Planned = 1 then 1
	Else
		0
	End

-- Update the OnExpiration STATE Value
Update #TractorList set OnExpiration = 1
from expiration EX, #TractorList T1
where EX.exp_idtype = 'TRC'
AND EX.exp_compldate > @SamplingDate
AND EX.exp_expirationdate < @SamplingDate
AND EX.exp_id = T1.trc_number
AND EX.exp_priority = '1'
AND T1.WorkingNow <> 1

-- Update the Waiting STATE Value
Update #TractorList set Waiting = 1
where WorkingNow = 0 
AND Assigned = 0
AND OnExpiration = 0

-- Update missing LegOfRecord
Update #TractorList set LegOfRecord = 
	(
		select top 1 lgh_number
		from legheader LH
		where LH.lgh_tractor = #TractorList.trc_number
		AND LH.lgh_enddate = 
			(
				select MAX(lgh_enddate)
				from legheader L2
				where L2.lgh_tractor = LH.lgh_tractor
				AND L2.lgh_enddate < #TractorList.SamplingDate
			)
	)
where #TractorList.LegOfRecord is NULL

Update #TractorList set Working_Driver1 = lgh_driver1
,Working_Driver2 = lgh_driver2
from legheader LH
where LH.lgh_number = #TractorList.LegOfRecord
AND Working_Driver1 = 'UNKNOWN'

Update #TractorList set RevType1 = lgh_class1
,RevType2 = lgh_class2
,RevType3 = lgh_class3
,RevType4 = lgh_class4
from legheader LH
where LH.lgh_number = #TractorList.LegOfRecord

insert into dwTractorAvailabilitySamplingData
	(
		SamplingID,SamplingDate,trc_number,Seated_Driver1,Seated_Driver2,Working_Driver1,Working_Driver2,Planned_Driver1,Planned_Driver2
		,Seated,Unseated,WorkingNow,Planned,Assigned,Waiting,OnExpiration,LegOfRecord,RevType1,RevType2,RevType3,RevType4
	)
select SamplingID
,SamplingDate
,trc_number
,Seated_Driver1
,Seated_Driver2
,Working_Driver1
,Working_Driver2
,Planned_Driver1
,Planned_Driver2
,Seated
,Unseated
,WorkingNow
,Planned
,Assigned
,Waiting
,OnExpiration
,LegOfRecord
,RevType1
,RevType2
,RevType3
,RevType4
from #TractorList 
order by trc_number


-- Now do Drivers
declare @DriverList table
	(
		SamplingID int
		,SamplingDate datetime
		,mpp_id varchar(32)
		,Seated_Tractor varchar(32)
		,Working_Tractor varchar(32)
		,Planned_Tractor varchar(32)
		,Seated int
		,Unseated int
		,WorkingNow int
		,Planned int
		,Assigned int
		,Waiting int
		,OnExpiration int
	)

-- get a definitive list of current drivers
insert into @DriverList
	(
		SamplingID,SamplingDate,mpp_id,Seated_Tractor,Working_Tractor,Planned_Tractor
		,Seated,Unseated,WorkingNow,Planned,Assigned,Waiting,OnExpiration
	)
select SamplingID = @SamplingID
,SamplingDate = @SamplingDate
,mpp_id
,Seated_Tractor = IsNull(mpp_tractornumber,'UNKNOWN')
,Working_Tractor = 'UNKNOWN'
,Planned_Tractor = 'UNKNOWN'
,Seated = 0
,Unseated = 0
,WorkingNow = 0
,Planned = 0
,Assigned = 0
,Waiting = 0
,OnExpiration = 0
from manpowerprofile MPP
where mpp_terminationdt > @SamplingDate
AND mpp_id <> 'UNKNOWN'

-- Update the Seated STATE Value
Update @DriverList set Seated = 1
where Seated_Tractor <> 'UNKNOWN'

-- Update the Unseated STATE Value
Update @DriverList set Unseated = Case when Seated = 1 then 0 else 1 end

-- Update the WorkingNow STATE Value, and Tractor ID's
Update @DriverList set WorkingNow = 1
,Working_Tractor = lgh_tractor
from legheader LH, @DriverList T1
where LH.lgh_driver1 = T1.mpp_id
AND LH.lgh_enddate >= @SamplingDate
AND LH.lgh_startdate < @SamplingDate

Update @DriverList set WorkingNow = 1
,Working_Tractor = lgh_tractor
from legheader LH, @DriverList T1
where LH.lgh_driver2 = T1.mpp_id
AND LH.lgh_enddate >= @SamplingDate
AND LH.lgh_startdate < @SamplingDate

-- Update the Planned STATE Value, and Tractor ID's
Update @DriverList set Planned = 1
,Planned_Tractor = lgh_tractor
from legheader LH, @DriverList T1
where LH.lgh_driver1 = T1.mpp_id
AND LH.lgh_startdate = 
	(
		Select MIN(T2.lgh_startdate)
		from legheader T2
		where T2.lgh_driver1 = LH.lgh_driver1
		AND T2.lgh_startdate >= @SamplingDate
		AND T2.lgh_startdate < @DateEnd
	)		

Update @DriverList set Planned = 1
,Planned_Tractor = lgh_tractor
from legheader LH, @DriverList T1
where LH.lgh_driver2 = T1.mpp_id
AND LH.lgh_startdate = 
	(
		Select MIN(T2.lgh_startdate)
		from legheader T2
		where T2.lgh_driver2 = LH.lgh_driver2
		AND T2.lgh_startdate >= @SamplingDate
		AND T2.lgh_startdate < @DateEnd
	)

-- Update the Assigned STATE Value
Update @DriverList set Assigned = 
	Case
		when WorkingNow = 1 then 1
		when Planned = 1 then 1
	Else
		0
	End

-- Update the OnExpiration STATE Value
Update @DriverList set OnExpiration = 1
from expiration EX, @DriverList T1
where EX.exp_idtype = 'DRV'
AND EX.exp_compldate > @SamplingDate
AND EX.exp_expirationdate < @SamplingDate
AND EX.exp_id = T1.mpp_id
AND EX.exp_priority = '1'
AND T1.WorkingNow <> 1

-- Update the Waiting STATE Value
Update @DriverList set Waiting = 1
where WorkingNow = 0 
AND Assigned = 0
AND OnExpiration = 0

insert into dwDriverAvailabilitySamplingData
	(
		SamplingID,SamplingDate,mpp_id,Seated_Tractor,Working_Tractor,Planned_Tractor
		,Seated,Unseated,WorkingNow,Planned,Assigned,Waiting,OnExpiration
	)
select SamplingID
,SamplingDate
,mpp_id
,Seated_Tractor
,Working_Tractor
,Planned_Tractor
,Seated
,Unseated
,WorkingNow
,Planned
,Assigned
,Waiting
,OnExpiration
from @DriverList 
order by mpp_id

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[dwFleetAvailabilitySampling] TO [public]
GO
