SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dwPrepResourceSnapshots1_ts]
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

select Datasource = @Datasource
,lgh_number
,asgn_number
,asgn_type
,asgn_id
,asgn_date
,asgn_enddate
,timestamp 
from #assetassignment 
order by asgn_type,asgn_id,asgn_date

drop table #assetassignment

GO
GRANT EXECUTE ON  [dbo].[dwPrepResourceSnapshots1_ts] TO [public]
GO
