SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE      Proc [dbo].[DriverAwareSuite_ProcessDrivingHourByGPS]


As

Declare @LoopCounter INT
Declare @NextDrivid Varchar(8)
Declare @maxLoop   INT
Set @maxLoop  =1100
Declare @SQL varchar(500)

Set NoCount On


if exists (select * from sysobjects where id = object_id('DriverAwareSuite_DrivingHourByGPSResults') and sysstat & 0xf = 3)
	drop table DriverAwareSuite_DrivingHourByGPSResults


CREATE TABLE DriverAwareSuite_DrivingHourByGPSResults (
	DriverID varchar (8) NULL ,
	GPSInfoStale varchar (3) NOT NULL ,
	IsTeam char (1) NOT NULL ,
	GPSLastFullBreakEndDt datetime NULL ,
	HoursOnBreakCurrently decimal(6, 2) NULL ,
	CurrentBreakStart datetime NULL ,
	BreakCouldEndCurrentlyHrs float NULL ,
	BreakCouldEndCurrentlyDt datetime NULL ,
	DrivingOrNonBreakHrsSinceLastFullBreak float NULL ,
	MaxDrvHrsTillBreak float NULL ,
	DrivingMustStopByDT datetime NULL ,
	ContiniousDrvHrsSinceLastStop decimal(6, 2) NULL ,
	LastGPSFound datetime NULL ,
	GPSCalculatedDriverHrsForMaxGPSDt decimal(10, 1) NULL ,
	GPSCalculatedAirMilesForMaxGPSDt decimal(10, 1) NULL ,
	GPSCalculatedDriverHrsForMaxGPSDtMinus1Day decimal(10, 1) NULL ,
	GPSCalculatedAirMilesForMaxGPSDtMinus1Day decimal(10, 1) NULL ,
	GPSCalculatedDriverHrsForMaxGPSDtMinus2Day decimal(10, 1) NULL ,
	GPSCalculatedAirMilesForMaxGPSDtMinus2Day decimal(10, 1) NULL 
) ON [PRIMARY]


Declare @BeginDate datetime
Declare @EndDate datetime
Declare @CurrentDate datetime

Set @BeginDate = getdate() - 7
Set @EndDate = getdate() + 7
Set @CurrentDate = getdate()

Declare @AllDrivers Table
	(mpp_id varchar(8)
	)


Set @SQL = 'If Not OBJECT_ID(' + '''' + 'tempdb..' + '##CheckCall' + '''' + ', ' + '''' + 'U' + '''' + ') IS NULL' + ' Drop Table ' + '##CheckCall'

Exec (@SQL)

Create Table ##CheckCall
(ckc_date datetime,
 ckc_vehicleignition char(1),
 ckc_cityname varchar(16),
 ckc_state varchar(6),
 ckc_latseconds int,
 ckc_longSeconds int,
 ckc_zip varchar(10),
 ckc_city int ,
 ckc_lghnumber int,
 ckc_tractor char(8),
 ckc_asgnid char(8),
 ckc_comment char(254),
 ckc_asgntype char(6)
)




CREATE INDEX idxTempCheckCall ON ##CheckCall(ckc_asgnid, ckc_date) WITH  FILLFACTOR = 90 ON [PRIMARY]


Insert into  @AllDrivers 
Select 
	mpp_id 
From 	manpowerProfile (NOLOCK),
	(select distinct ckc_asgnid DriverID
	from Checkcall (NOLOCK)
	where ckc_asgntype='DRV' and ckc_date between @BeginDate and @EndDate
	) DriversWithCheckCalls

where 	mpp_terminationdt>Getdate()
	and 
	mpp_id= DriversWithCheckCalls.DriverID
	and
        mpp_type3 <> 'TM'

Insert into ##CheckCall
Select ckc_date,
       ckc_vehicleignition,
       ckc_cityname ,
       ckc_state ,
       ckc_latseconds,
       ckc_longSeconds,
       ckc_zip,
       ckc_city,
       ckc_lghnumber,
       ckc_tractor,
       ckc_asgnid,
       ckc_comment,
       ckc_asgntype

From   checkcall (NOLOCK),@AllDrivers AllDrivers
where  ckc_date between DateAdd(day,-12,@CurrentDate) and @EndDate
       and 
       ckc_asgnid = AllDrivers.mpp_id
       And 
       ckc_latseconds>0
       AND
       ckc_asgntype='DRV'

Select count(*) from @AllDrivers 
Set @NextDrivid =''

Set @LoopCounter=0 
While 1=1
Begin
	Set @NextDrivid = (select min(mpp_id) from @AllDrivers where mpp_id>@NextDrivid)
	IF  @NextDrivid IS NULL BREAK
	Insert into DriverAwareSuite_DrivingHourByGPSResults
	Exec DriverAwareSuite_DrivingHourByGPS @Driver= @NextDrivid
	Set @LoopCounter = @LoopCounter +1
	IF @LoopCounter >@maxLoop  BREAK
END

Drop Table ##CheckCall






GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_ProcessDrivingHourByGPS] TO [public]
GO
