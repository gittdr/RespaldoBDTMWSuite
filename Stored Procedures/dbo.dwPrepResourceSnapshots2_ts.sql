SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dwPrepResourceSnapshots2_ts]
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

select Datasource = @Datasource
,exp_key
,exp_idtype
,exp_id
,exp_expirationdate
,exp_compldate
,exp_priority
,exp_code
,exp_updateon
,exp_completed
,timestamp 
from #expiration 
order by exp_idtype,exp_id,exp_expirationdate

drop table #expiration

GO
GRANT EXECUTE ON  [dbo].[dwPrepResourceSnapshots2_ts] TO [public]
GO
