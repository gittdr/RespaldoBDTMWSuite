SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dwPrepResourceSnapshots0_ts]
	(
		@Datasource varchar(32)
		,@LastTimestamp timestamp
		,@ThisTimestamp timestamp
		,@LastSnapshotCycleTime datetime
		,@ThisSnapshotCycleTime datetime
	)

AS

set NOCOUNT ON

declare @NextCycleTime datetime
declare @SlushBuffer int
declare @TerminationBuffer int
declare @TrcWindowOpen datetime
declare @TrlWindowOpen datetime
declare @DrvWindowOpen datetime

--set @LastTimestamp = 0x0000000011BB1FBD
--set @LastSnapshotCycleTime = '20100715 01:00:00.000'
set @LastSnapshotCycleTime = CONVERT(datetime,Floor(convert(float,@LastSnapshotCycleTime)))
--set @ThisSnapshotCycleTime = '20100716 01:00:00.000'
set @ThisSnapshotCycleTime = CONVERT(datetime,Floor(convert(float,@ThisSnapshotCycleTime)))
set @NextCycleTime = DATEADD(d,1,@ThisSnapshotCycleTime)

set @SlushBuffer = -7
set @TerminationBuffer = -90

declare @WindowOpenTable table (asgn_type varchar(10),WindowOpen datetime)

insert into @WindowOpenTable (asgn_type,WindowOpen)
select asgn_type
,DateAdd(d,@SlushBuffer,MIN(asgn_date))
from assetassignment assetassignment with (NOLOCK)
where timestamp between @LastTimestamp AND @ThisTimestamp
group by asgn_type

insert into @WindowOpenTable (asgn_type,WindowOpen)
select exp_idtype
,DateAdd(d,@SlushBuffer,MIN(exp_expirationdate))
from expiration expiration with (NOLOCK)
where timestamp between @LastTimestamp AND @ThisTimestamp
group by exp_idtype

Set @TrcWindowOpen = (Select MIN(WindowOpen) from @WindowOpenTable where asgn_type = 'TRC')
Set @TrlWindowOpen = (Select MIN(WindowOpen) from @WindowOpenTable where asgn_type = 'TRL')
Set @DrvWindowOpen = (Select MIN(WindowOpen) from @WindowOpenTable where asgn_type = 'DRV')

--select @WindowOpen,@LastSnapshotCycleTime,@ThisSnapshotCycleTime

create table #assetassignment
	(
		lgh_number int
		,asgn_number int
		,asgn_type varchar(6)
		,asgn_id varchar(13)
		,asgn_date datetime
		,asgn_eventnumber int
		,asgn_controlling varchar(1)
		,asgn_status varchar(6)
		,asgn_dispdate datetime
		,asgn_enddate datetime
		,asgn_dispmethod varchar(6)
		,mov_number int
		,timestamp varbinary(16)
		,pyd_status varchar(6)
		,actg_type char(1)
		,evt_number int
		,asgn_trl_first_asgn int
		,asgn_trl_last_asgn int
		,last_evt_number int
		,last_dne_evt_number int
		,next_opn_evt_number int
	)

insert into #assetassignment
	(
		lgh_number,asgn_number,asgn_type,asgn_id,asgn_date,asgn_eventnumber,asgn_controlling,asgn_status,asgn_dispdate,asgn_enddate
		,asgn_dispmethod,mov_number,timestamp,pyd_status,actg_type,evt_number,asgn_trl_first_asgn,asgn_trl_last_asgn,last_evt_number
		,last_dne_evt_number,next_opn_evt_number			
	)
select lgh_number,asgn_number,asgn_type,asgn_id,asgn_date,asgn_eventnumber,asgn_controlling,asgn_status,asgn_dispdate,asgn_enddate
,asgn_dispmethod,mov_number,timestamp,pyd_status,actg_type,evt_number,asgn_trl_first_asgn,asgn_trl_last_asgn,last_evt_number
,last_dne_evt_number,next_opn_evt_number			
from assetassignment assetassignment with (NOLOCK)
where asgn_enddate > @TrcWindowOpen 
AND asgn_date <= @NextCycleTime 
AND asgn_type = 'TRC'

insert into #assetassignment
	(
		lgh_number,asgn_number,asgn_type,asgn_id,asgn_date,asgn_eventnumber,asgn_controlling,asgn_status,asgn_dispdate,asgn_enddate
		,asgn_dispmethod,mov_number,timestamp,pyd_status,actg_type,evt_number,asgn_trl_first_asgn,asgn_trl_last_asgn,last_evt_number
		,last_dne_evt_number,next_opn_evt_number			
	)
select lgh_number,asgn_number,asgn_type,asgn_id,asgn_date,asgn_eventnumber,asgn_controlling,asgn_status,asgn_dispdate,asgn_enddate
,asgn_dispmethod,mov_number,timestamp,pyd_status,actg_type,evt_number,asgn_trl_first_asgn,asgn_trl_last_asgn,last_evt_number
,last_dne_evt_number,next_opn_evt_number			
from assetassignment assetassignment with (NOLOCK)
where asgn_enddate > @TrlWindowOpen 
AND asgn_date <= @NextCycleTime 
AND asgn_type = 'TRL'

insert into #assetassignment
	(
		lgh_number,asgn_number,asgn_type,asgn_id,asgn_date,asgn_eventnumber,asgn_controlling,asgn_status,asgn_dispdate,asgn_enddate
		,asgn_dispmethod,mov_number,timestamp,pyd_status,actg_type,evt_number,asgn_trl_first_asgn,asgn_trl_last_asgn,last_evt_number
		,last_dne_evt_number,next_opn_evt_number			
	)
select lgh_number,asgn_number,asgn_type,asgn_id,asgn_date,asgn_eventnumber,asgn_controlling,asgn_status,asgn_dispdate,asgn_enddate
,asgn_dispmethod,mov_number,timestamp,pyd_status,actg_type,evt_number,asgn_trl_first_asgn,asgn_trl_last_asgn,last_evt_number
,last_dne_evt_number,next_opn_evt_number			
from assetassignment assetassignment with (NOLOCK)
where asgn_enddate > @DrvWindowOpen 
AND asgn_date <= @NextCycleTime 
AND asgn_type = 'DRV'

create table #expiration
	(		
		exp_idtype char(3)
		,exp_id varchar(13)
		,exp_code varchar(6)
		,exp_lastdate datetime
		,exp_expirationdate datetime
		,exp_routeto varchar(12)
		,exp_completed char(1)
		,exp_priority varchar(6)
		,exp_compldate datetime
		,timestamp varbinary(16)
		,exp_updateby varchar(20)
		,exp_creatdate datetime
		,exp_updateon datetime
		,exp_description varchar(100)
		,exp_milestoexp int
		,exp_key int
		,exp_city int
		,mov_number int
		,exp_control_avl_date char(1)
		,skip_trigger tinyint
		--,exp_auto_created char(1)
		--,exp_source varchar(30)
		--,cai_id int
	)

Insert into #expiration
	(
		exp_idtype,exp_id,exp_code,exp_lastdate,exp_expirationdate,exp_routeto,exp_completed,exp_priority,exp_compldate,timestamp
		,exp_updateby,exp_creatdate,exp_updateon,exp_description,exp_milestoexp,exp_key,exp_city,mov_number,exp_control_avl_date
		,skip_trigger--,exp_auto_created,exp_source,cai_id
	)
select exp_idtype,exp_id,exp_code,exp_lastdate,exp_expirationdate,exp_routeto,exp_completed,exp_priority,exp_compldate,timestamp
,exp_updateby,exp_creatdate,exp_updateon,exp_description,exp_milestoexp,exp_key,exp_city,mov_number,exp_control_avl_date
,skip_trigger--,exp_auto_created,exp_source,cai_id
from expiration expiration with (NOLOCK)
where exp_compldate >= '20491231' AND timestamp between @LastTimestamp AND @ThisTimestamp
AND exp_expirationdate <= @NextCycleTime 
AND exp_idtype = 'TRC'
AND exp_code <> 'OUT'
AND exp_id <> 'UNKNOWN'
AND exp_priority = '1'

UNION

select exp_idtype,exp_id,exp_code,exp_lastdate,exp_expirationdate,exp_routeto,exp_completed,exp_priority,exp_compldate,timestamp
,exp_updateby,exp_creatdate,exp_updateon,exp_description,exp_milestoexp,exp_key,exp_city,mov_number,exp_control_avl_date
,skip_trigger--,exp_auto_created,exp_source,cai_id
from expiration expiration with (NOLOCK)
where exp_compldate < '20491231' AND exp_compldate > @DrvWindowOpen
AND exp_expirationdate <= @NextCycleTime 
AND exp_idtype = 'TRC'
AND exp_code <> 'OUT'
AND exp_id <> 'UNKNOWN'
AND exp_priority = '1'

Insert into #expiration
	(
		exp_idtype,exp_id,exp_code,exp_lastdate,exp_expirationdate,exp_routeto,exp_completed,exp_priority,exp_compldate,timestamp
		,exp_updateby,exp_creatdate,exp_updateon,exp_description,exp_milestoexp,exp_key,exp_city,mov_number,exp_control_avl_date
		,skip_trigger--,exp_auto_created,exp_source,cai_id
	)
select exp_idtype,exp_id,exp_code,exp_lastdate,exp_expirationdate,exp_routeto,exp_completed,exp_priority,exp_compldate,timestamp
,exp_updateby,exp_creatdate,exp_updateon,exp_description,exp_milestoexp,exp_key,exp_city,mov_number,exp_control_avl_date
,skip_trigger--,exp_auto_created,exp_source,cai_id
from expiration expiration with (NOLOCK)
where exp_compldate >= '20491231' AND timestamp between @LastTimestamp AND @ThisTimestamp
AND exp_expirationdate <= @NextCycleTime 
AND exp_idtype = 'TRL'
AND exp_code <> 'OUT'
AND exp_id <> 'UNKNOWN'
AND exp_priority = '1'

UNION

select exp_idtype,exp_id,exp_code,exp_lastdate,exp_expirationdate,exp_routeto,exp_completed,exp_priority,exp_compldate,timestamp
,exp_updateby,exp_creatdate,exp_updateon,exp_description,exp_milestoexp,exp_key,exp_city,mov_number,exp_control_avl_date
,skip_trigger--,exp_auto_created,exp_source,cai_id
from expiration expiration with (NOLOCK)
where exp_compldate < '20491231' AND exp_compldate > @DrvWindowOpen
AND exp_expirationdate <= @NextCycleTime 
AND exp_idtype = 'TRL'
AND exp_code <> 'OUT'
AND exp_id <> 'UNKNOWN'
AND exp_priority = '1'

Insert into #expiration
	(
		exp_idtype,exp_id,exp_code,exp_lastdate,exp_expirationdate,exp_routeto,exp_completed,exp_priority,exp_compldate,timestamp
		,exp_updateby,exp_creatdate,exp_updateon,exp_description,exp_milestoexp,exp_key,exp_city,mov_number,exp_control_avl_date
		,skip_trigger--,exp_auto_created,exp_source,cai_id
	)
select exp_idtype,exp_id,exp_code,exp_lastdate,exp_expirationdate,exp_routeto,exp_completed,exp_priority,exp_compldate,expiration.timestamp
,exp_updateby,exp_creatdate,exp_updateon,exp_description,exp_milestoexp,exp_key,exp_city,mov_number,exp_control_avl_date
,skip_trigger--,exp_auto_created,exp_source,cai_id
from expiration expiration with (NOLOCK) inner join manpowerprofile MPP with (NOLOCK) on expiration.exp_id = MPP.mpp_id
where exp_compldate >= '20491231' AND expiration.timestamp between @LastTimestamp AND @ThisTimestamp
AND exp_expirationdate between ISNULL(mpp_hiredate,mpp_createdate) AND @NextCycleTime 
AND exp_idtype = 'DRV'
AND exp_code <> 'OUT'
AND exp_id <> 'UNKNOWN'
AND exp_priority = '1'

UNION

select exp_idtype,exp_id,exp_code,exp_lastdate,exp_expirationdate,exp_routeto,exp_completed,exp_priority,exp_compldate,expiration.timestamp
,exp_updateby,exp_creatdate,exp_updateon,exp_description,exp_milestoexp,exp_key,exp_city,mov_number,exp_control_avl_date
,skip_trigger--,exp_auto_created,exp_source,cai_id
from expiration expiration with (NOLOCK) inner join manpowerprofile MPP with (NOLOCK) on expiration.exp_id = MPP.mpp_id
where exp_compldate < '20491231' AND exp_compldate > @DrvWindowOpen
AND exp_expirationdate between ISNULL(mpp_hiredate,mpp_createdate) AND @NextCycleTime 
AND exp_idtype = 'DRV'
AND exp_code <> 'OUT'
AND exp_id <> 'UNKNOWN'
AND exp_priority = '1'


-- TRACTOR SECTION	*********************************************************************************************************************************************
-- this grabs Resources with assignment modification since last ETL
select asgn_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(asgn_date))
,SitType = 'AAT'
into #TRCList_Both
from #assetassignment
where asgn_type = 'TRC'
AND timestamp between @LastTimestamp AND @ThisTimestamp
group by asgn_id
order by asgn_id

-- this grabs remaining Resources with ACTIVE ASSIGNMENT in current period 
insert into #TRCList_Both (asgn_id,WindowOpen,SitType)
select asgn_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(asgn_date))
,SitType = 'AAT'
from #assetassignment
where asgn_type = 'TRC'
AND Not Exists
	(
		select asgn_id
		from #TRCList_Both T1
		where #assetassignment.asgn_id = T1.asgn_id
		AND T1.SitType = 'AAT'
	)
AND asgn_enddate >= @LastSnapshotCycleTime
group by asgn_id
order by asgn_id

-- this grabs Resources with expiration modification since last ETL
insert into #TRCList_Both (asgn_id,WindowOpen,SitType)
select exp_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(exp_expirationdate))
,SitType = 'EXP'
from #expiration
where exp_idtype = 'TRC'
AND timestamp between @LastTimestamp AND @ThisTimestamp
group by exp_id
order by exp_id

-- this grabs remaining Resources with ACTIVE Expiration in current period 
insert into #TRCList_Both (asgn_id,WindowOpen,SitType)
select exp_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(exp_expirationdate))
,SitType = 'EXP'
from #expiration
where exp_idtype = 'TRC'
AND Not Exists
	(
		select asgn_id
		from #TRCList_Both T1
		where #expiration.exp_id = T1.asgn_id
		AND T1.SitType = 'EXP'
	)
AND exp_compldate >= @LastSnapshotCycleTime
group by exp_id
order by exp_id

-- get FINAL Tractor List
select asgn_id
,WindowOpen = MIN(WindowOpen)
,WindowClose = CONVERT(datetime,'20501231')
into #TRCList
from #TRCList_Both
group by asgn_id
order by asgn_id

-- set an appropriate WindowClose date for each Resource
Update #TRCList set WindowClose = Case when @NextCycleTime < ISNULL(TP.trc_retiredate,'20501231') then @NextCycleTime else ISNULL(TP.trc_retiredate,'20501231') end
from tractorprofile TP with (NOLOCK)
where #TRCList.asgn_id = TP.trc_number

-- remove any Resources terminated for more than @TerminationBuffer days (probable false positive on timestamp changes)
delete from #TRCList where WindowClose < DATEADD(d,@TerminationBuffer,@LastSnapshotCycleTime)

-- now add in any Resources that are current and NOT in the activity list
insert into #TRCList (asgn_id,WindowOpen,WindowClose)
select trc_number
,DateAdd(d,@SlushBuffer,@LastSnapshotCycleTime)
,@NextCycleTime
from tractorprofile tractorprofile with (NOLOCK)
where trc_number <> 'UNKNOWN'
AND IsNull(trc_retiredate,'20501231') >= @NextCycleTime
AND IsNull(trc_startdate,trc_createdate) < @NextCycleTime
AND NOT Exists
	(
		select asgn_id
		from #TRCList T2
		where tractorprofile.trc_number = T2.asgn_id
	)				


-- TRAILER SECTION	*********************************************************************************************************************************************
-- this grabs Resources with assignment modification since last ETL
select asgn_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(asgn_date))
,SitType = 'AAT'
into #TRLList_Both
from #assetassignment
where asgn_type = 'TRL'
AND timestamp between @LastTimestamp AND @ThisTimestamp
group by asgn_id
order by asgn_id

-- this grabs remaining Resources with ACTIVE ASSIGNMENT in current period 
insert into #TRLList_Both (asgn_id,WindowOpen,SitType)
select asgn_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(asgn_date))
,SitType = 'AAT'
from #assetassignment
where asgn_type = 'TRL'
AND Not Exists
	(
		select asgn_id
		from #TRCList_Both T1
		where #assetassignment.asgn_id = T1.asgn_id
		AND T1.SitType = 'AAT'
	)
AND asgn_enddate >= @LastSnapshotCycleTime
group by asgn_id
order by asgn_id

-- this grabs Resources with expiration modification since last ETL
insert into #TRLList_Both (asgn_id,WindowOpen,SitType)
select exp_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(exp_expirationdate))
,SitType = 'EXP'
from #expiration
where exp_idtype = 'TRL'
AND timestamp between @LastTimestamp AND @ThisTimestamp
group by exp_id
order by exp_id

-- this grabs remaining Resources with ACTIVE Expiration in current period 
insert into #TRLList_Both (asgn_id,WindowOpen,SitType)
select exp_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(exp_expirationdate))
,SitType = 'EXP'
from #expiration
where exp_idtype = 'TRL'
AND Not Exists
	(
		select asgn_id
		from #TRCList_Both T1
		where #expiration.exp_id = T1.asgn_id
		AND T1.SitType = 'EXP'
	)
AND exp_compldate >= @LastSnapshotCycleTime
group by exp_id
order by exp_id

-- get FINAL Trailer List
select asgn_id
,WindowOpen = MIN(WindowOpen)
,WindowClose = CONVERT(datetime,'20501231')
into #TRLList
from #TRLList_Both
group by asgn_id
order by asgn_id

-- set an appropriate WindowClose date for each Resource
Update #TRLList set WindowClose = Case when @NextCycleTime < ISNULL(TP.trl_retiredate,'20501231') then @NextCycleTime else ISNULL(TP.trl_retiredate,'20501231') end
from trailerprofile TP with (NOLOCK)
where #TRLList.asgn_id = TP.trl_id

-- remove any Resources terminated for more than @TerminationBuffer days (probable false positive on timestamp changes)
delete from #TRLList where WindowClose < DATEADD(d,@TerminationBuffer,@LastSnapshotCycleTime)		

-- now add in any Resources that are current and NOT in the activity list
insert into #TRLList (asgn_id,WindowOpen,WindowClose)
select trl_id
,DateAdd(d,@SlushBuffer,@LastSnapshotCycleTime)
,@NextCycleTime
from trailerprofile trailerprofile with (NOLOCK)
where trl_id <> 'UNKNOWN'
AND IsNull(trl_retiredate,'20501231') >= @NextCycleTime
AND IsNull(trl_startdate,trl_createdate) < @NextCycleTime
AND NOT Exists
	(
		select asgn_id
		from #TRLList T2
		where trailerprofile.trl_id = T2.asgn_id
	)				


-- DRIVER SECTION	*********************************************************************************************************************************************
-- this grabs Resources with assignment modification since last ETL
select asgn_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(asgn_date))
,SitType = 'AAT'
into #DRVList_Both
from #assetassignment
where asgn_type = 'DRV'
AND timestamp between @LastTimestamp AND @ThisTimestamp
group by asgn_id
order by asgn_id

-- this grabs remaining Resources with ACTIVE ASSIGNMENT in current period 
insert into #DRVList_Both (asgn_id,WindowOpen,SitType)
select asgn_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(asgn_date))
,SitType = 'AAT'
from #assetassignment
where asgn_type = 'DRV'
AND Not Exists
	(
		select asgn_id
		from #DRVList_Both T1
		where #assetassignment.asgn_id = T1.asgn_id
		AND T1.SitType = 'AAT'
	)
AND asgn_enddate >= @LastSnapshotCycleTime
group by asgn_id
order by asgn_id

-- this grabs Resources with expiration modification since last ETL
insert into #DRVList_Both (asgn_id,WindowOpen,SitType)
select exp_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(exp_expirationdate))
,SitType = 'EXP'
from #expiration
where exp_idtype = 'DRV'
AND timestamp between @LastTimestamp AND @ThisTimestamp
group by exp_id
order by exp_id

-- this grabs remaining Resources with ACTIVE Expiration in current period 
insert into #DRVList_Both (asgn_id,WindowOpen,SitType)
select exp_id
,WindowOpen = DateAdd(d,@SlushBuffer,MIN(exp_expirationdate))
,SitType = 'EXP'
from #expiration
where exp_idtype = 'DRV'
AND Not Exists
	(
		select asgn_id
		from #DRVList_Both T1
		where #expiration.exp_id = T1.asgn_id
		AND T1.SitType = 'EXP'
	)
AND exp_compldate >= @LastSnapshotCycleTime
group by exp_id
order by exp_id

-- get FINAL Driver List
select asgn_id
,WindowOpen = MIN(WindowOpen)
,WindowClose = CONVERT(datetime,'20501231')
into #DRVList
from #DRVList_Both
group by asgn_id
order by asgn_id

-- set an appropriate WindowClose date for each Resource
Update #DRVList set WindowClose = Case when @NextCycleTime < ISNULL(MPP.mpp_terminationdt,'20501231') then @NextCycleTime else ISNULL(MPP.mpp_terminationdt,'20501231') end
from manpowerprofile MPP with (NOLOCK)
where #DRVList.asgn_id = MPP.mpp_id

-- remove any Resources terminated for more than @TerminationBuffer days (probable false positive on timestamp changes)
delete from #DRVList where WindowClose < DATEADD(d,@TerminationBuffer,@LastSnapshotCycleTime)		

-- now add in any Resources that are current and NOT in the activity list
insert into #DRVList (asgn_id,WindowOpen,WindowClose)
select mpp_id
,DateAdd(d,@SlushBuffer,@LastSnapshotCycleTime)
,@NextCycleTime
from manpowerprofile manpowerprofile with (NOLOCK)
where mpp_id <> 'UNKNOWN'
AND IsNull(mpp_terminationdt,'20501231') >= @NextCycleTime
AND IsNull(mpp_hiredate,mpp_createdate) < @NextCycleTime
AND NOT Exists
	(
		select asgn_id
		from #DRVList T2
		where manpowerprofile.mpp_id = T2.asgn_id
	)				

-- Insert into 5 queuing tables here
select Datasource = @Datasource
,ResourceType = 'TRC'
,ResourceID = asgn_id
,WindowOpen
,WindowClose 
from #TRCList

UNION

select Datasource = @Datasource
,ResourceType = 'TRL'
,ResourceID = asgn_id
,WindowOpen
,WindowClose 
from #TRLList

UNION

select Datasource = @Datasource
,ResourceType = 'DRV'
,ResourceID = asgn_id
,WindowOpen
,WindowClose 
from #DRVList
order by ResourceType,ResourceID


drop table #assetassignment
drop table #expiration
drop table #TRCList_Both
drop table #TRCList
drop table #TRLList_Both
drop table #TRLList
drop table #DRVList_Both
drop table #DRVList

GO
GRANT EXECUTE ON  [dbo].[dwPrepResourceSnapshots0_ts] TO [public]
GO
