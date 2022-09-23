SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE                                    proc [dbo].[DriverAwareSuite_DrivingHourByGPS]

(
	@Driver Varchar(8)= '18329',
	--Set @Driver ='10459','10862','11783','14473'-- TEAM,'15602','16761','18329'   
	@MinCumulativeBreak float =9,
	@MaxCumulativeNonBreak float =11,
	@ShowDetailYN char(1) ='N',
	@LowCkcDate DateTime ='1/1/1950', -- If Left at default, it takes the last Log date -8 days
	@StaleLimitHours Float =2  -- How many hours ago last GPS is and should it be called stale
	--,
	--@HoursToday Float OUT,
	--@LastGPSDate Datetime out
)

AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/12/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/


--Declare @MinCumulativeBreak float
--Declare @MaxCumulativeNonBreak float
--Declare @Driver Varchar(8)

--Declare @HoursToday Float ,
--	@LastGPSDate Datetime 


Declare @LastLogDate datetime



Declare @NextID int
--Declare @StaleLimitHours Float

--Declare @LowCkcDate datetime
Declare @HighCkcDate datetime
--Declare @ShowDetailYN char(1)
Declare @tempDate datetime
Declare  @DtCounter int

Declare @loopCounter int

--Set @MinCumulativeBreak =7
--Set @MaxCumulativeNonBreak =10
--Set @StaleLimitHours =2
Set @loopCounter =0

Set @HighCkcDate =Getdate()



--Set @ShowDetailYN ='N'

set nocount on


Declare @GpsInfo table
(
	id int IDENTITY(1,1) PRIMARY KEY,
	dt datetime,
	Ign VarChar(6),
	CityName Varchar(25),
	LatSeconds int,
	LongSeconds int,
	Zip5 varchar(5),
	CityCode int,
	LghNumber int,
	tractor varchar(8),
	Driver varchar(8),
	AirMilesFromLast float,
	TimeDifMinutes int,
	MPH Decimal(8,1),
	DrivingPercentage Decimal(8,1),
	DrivingMinutes int,
	IsTeamYN char(1),
	BreakTimeMinutes int,
	CumulativeBreakMinutes int,
	CumulativeDrivingMinutes int,
	Comment	varchar(254)
)

Declare @GpsInfoCopy table
(
	MilesFromLast float,
	TimeDifFromLast int,
	CopyId int ,
	dt datetime,
	Ign VarChar(6),
	CityName Varchar(25),
	LatSeconds int,
	LongSeconds int,
	Zip5 varchar(5),
	CityCode int,
	LghNumber int,
	tractor varchar(8),
	Driver varchar(8),
	AirMilesFromLast float,
	TimeDifMinutes int,
	MPH Decimal(5,1),
	DrivingPercentage Decimal(5,1),
	DrivingMinutes int,
	IsTeamYN char(1),
	BreakTimeMinutes int,
	CumulativeBreakMinutes int,
	CumulativeDrivingMinutes int,
	Comment	varchar(254)
)
Declare @DaysInDateRange Table
	(dt datetime)

Declare @DetailReport Table
	(Miles 		decimal(6,1),
	TimeDif 	Int,
	AirMPH 		decimal(10,1),
	DrivingHrs 	decimal(6,2),
	BreakHrs	decimal(6,2),
	CumulativeBreakHrs decimal(6,2),
	CumulativeDrvHrs decimal(6,2),
	[Driving%]	decimal(6,2),
	Dt		Varchar(11),
	IsTeamYN	Char(1),
	FullDt		DateTime
	)
Declare @Temp Table
	(
	Dates 		Datetime,
	AirMilesPerDay	decimal(10,1),
	DriverHrsPerDay	decimal(10,1)
	)

Declare @DailySummary Table
(
	Dt	Datetime,
	AirMilesPerDay	decimal(10,1),
	DriverHrsPerDay decimal(10,1),
	LogtableEntryYN Char(1),

	LogTableOn_duty_hrs Float, 
	LogTableOff_duty_hrs float, 
	LogTableSleeper_berth_hrs Float, 
	LogTableDrvHrs Float,
	MaxCkcForDate DateTime,
	IsTeamYN Char(1)
	
)

Set @LastLogDate = (Select max(log_date) from log_driverlogs (NOLOCK) where mpp_id = @Driver)

Set @HighCkcDate = GetDate()

-- Set to Next Day after Last Logdate minus 8 days (if default passed in)
IF ( IsNull( @LowCkcDate,'1/1/1950' ) ='1/1/1950')
BEGIN
	Set @LowCkcDate =  
		
		Convert(dateTime,
			Floor(convert(float,IsNull(@LastLogDate,GETDATE()))  ) + 1
		)
	-- Go back 8 days
	Set @LowCkcDate =DateAdd(d,-15,@LowCkcDate)


	-- Go 4 days past eh Lastlog date -- 	
	--Set @HighCkcDate 
		--=  
		
		--Convert(dateTime,
			--Floor(convert(float, IsNull(  @LastLogDate,GETDATE())  )  ) + 4
		--)
	
END 




insert into @GpsInfo
Select 
	ckc_date,
	ckc_vehicleignition Ign,
	ckc_cityname +',' + ckc_state City,
	
	ckc_latseconds,
	ckc_longSeconds,
	left(ckc_zip,5) zip,
	ckc_city,
	ckc_lghnumber, 
	ckc_tractor,
	ckc_asgnid,
	0 TimeDifMinutes ,
	0 MPH ,

	0 MilesFromlast,


	0 DrivingPercentage ,



	0 DrivingMinutes, 

	IsTeamYN =cASE WHEN EXISTS(sELECT * FROM LEGHEADER l (nolock) where l.lgh_number=ckc_lghnumber and lgh_driver2<>'UNKNOWN')
			THEN 'Y'
			Else 'N'
		End,
	0 BreakTimeMinutes,
	0 CumulativeBreakMinutes, 
	0 CumulativeDrivingMinutes,
	ckc_comment
from ##checkcall (nolock)
where 	ckc_date 	between @LowCkcDate and @HighCkcDate
	and ckc_asgnid= @Driver
	And ckc_latseconds>0
order by ckc_date

Insert @GpsInfoCopy 
Select 
	MilesFromLast
		= dbo.fnc_AirMilesBetweenLatLongSeconds
				(Prev.LatSeconds, Nxt.LatSeconds, Prev.LongSeconds , Nxt.LongSeconds),
	TimeDifFromLast
		=DateDiff(n,nxt.dt,Prev.dt),
	--Nxt.* 

	Nxt.iD,
	Nxt.dt ,
	Nxt.Ign ,
	Nxt.CityName ,
	Nxt.LatSeconds,
	Nxt.LongSeconds,
	Nxt.Zip5 ,
	Nxt.CityCode ,
	Nxt.LghNumber,
	Nxt.tractor ,
	Nxt.Driver ,
	Nxt.AirMilesFromLast ,
	Nxt.TimeDifMinutes ,
	Nxt.MPH ,
	Nxt.DrivingPercentage ,
	Nxt.DrivingMinutes ,
	Nxt.IsTeamYN ,
	Nxt.BreakTimeMinutes ,
	Nxt.CumulativeBreakMinutes ,
	Nxt.CumulativeDrivingMinutes ,
	Nxt.Comment	


from 	@GpsInfo Nxt,
	@GpsInfo Prev
where 
	Nxt.id =Prev.ID-1		


Update @GpsInfo 
	Set AirMilesFromLast = MilesFromLast,
		TimeDifMinutes =TimeDifFromLast
	From @GpsInfoCopy 
	where
		Copyid + 1 = ID

Update @GpsInfo
	Set MPH
		=AirMilesFromLast/ (convert(float,TimeDifMinutes)/60.0)
	where TimeDifMinutes>0

Update @GpsInfo 
	Set DrivingPercentage
		=Case When MPH> 35 then 1.0
			When MPH < 10 then 0.0
			ELSe MPH/35.0 END
Update @GpsInfo
	Set DrivingMinutes
	= DrivingPercentage * TimeDifMinutes

Update @GpsInfo 
        Set BreakTimeMinutes 
        = Case  When AirMilesFromLast > 5 and IsNull((select b.AirMilesFromLast from @GpsInfo b where b.ID = a.ID-1),0) < 6 Then

                        Case When convert(float,TimeDifMinutes) - ((cast(AirMilesFromLast as float)/cast(45 as float)) * 60) < 0 Then

                                cast(0 as float) 
                        Else 
                                convert(float,TimeDifMinutes) - ((cast(AirMilesFromLast as float)/cast(45 as float)) * 60)

                        End 
                When AirMilesFromLast < 6 Then 
                        TimeDifMinutes 
                Else 
                        --Even if there is > 5 miles on the previous check call
			--and > 5 miles on this checkcall 
			--see if there was at least a 9 hour break if so
			--give him/here credit toward the break
			Case When (convert(float,TimeDifMinutes) - ((cast(AirMilesFromLast as float)/cast(45 as float)) * 60))/60.0 >= 9.0 Then--IsNull((select b.AirMilesFromLast from @GpsInfo b where b.ID = a.ID-1),0) > 5 Then 
				convert(float,TimeDifMinutes) - ((cast(AirMilesFromLast as float)/cast(45 as float)) * 60)
			Else
				0
			End
			
          End 

From  @GPSInfo a 


Set @NextID =1 -- first is 
While 1=1
BEGIN
	Set @NextID =(select min(id) from @GpsInfo where id>@NextID)
	If @NextID is null BREAK

	-- If the current record has driving Minutes, then set cumulativeBreakMinuts to 0 for current record
	IF EXISTS(Select * from @GpsInfo G where G.id=@NextID and AirMilesFromLast > 5 and BreakTimeMinutes=0)--MPH>5) --DrivingMinutes>0
	BEGIN 
		Update @GpsInfo Set CumulativeBreakMinutes =0 where id=@NextID 
	END
	ELSE
	BEGIN
			If IsNull((select b.AirMilesFromLast from @GpsInfo b where b.ID = @NextID -1),0) > 5
			Begin
				Update @GpsInfo Set CumulativeBreakMinutes = BreakTimeMinutes
				Where id=@NextID 
			End
			Else
			Begin
				Update @GpsInfo Set CumulativeBreakMinutes = BreakTimeMinutes
					+ 
					(select CumulativeBreakMinutes  from @GpsInfo Prev
					where PRev.id=@NextID -1
					)
				Where id=@NextID 

			End
	END 
	IF EXISTS(Select * from @GpsInfo G where G.id=@NextID and AirMilesFromLast <=5) --MPH<=5) --DrivingMinutes=0
	BEGIN 
		Update @GpsInfo Set CumulativeDrivingMinutes =0 where id=@NextID 
	END
	ELSE
	BEGIN
		Update @GpsInfo Set CumulativeDrivingMinutes = DrivingMinutes


			+ 
			(select CumulativeDrivingMinutes  from @GpsInfo Prev
			where PRev.id=@NextID -1
			)
		Where id=@NextID 
	END 




END



insert into @DetailReport
Select 
	convert(decimal(6,1),AirMilesFromLast) Miles,
	TimeDifMinutes TimeDif,
	MPH AirMPH,
	Convert(decimal(6,2),DrivingMinutes/60.0) DrivingHrs,
	Convert(decimal(6,2),BreakTimeMinutes/60.0) BreakHrs,
	Convert(decimal(6,2),CumulativeBreakMinutes/60.0) CumulativeBreakHrs,
	Convert(decimal(6,2),CumulativeDrivingMinutes/60.0) CumulativeDrvHrs,	
	DrivingPercentage [Driving%],	
	convert(varchar(5),dt,1) +' ' + convert(varchar(5),dt,8) Dt,
	IsTeamYN,
	dt FullDt
from @GpsInfo	


IF @ShowDetailYN ='Y' 
BEGIN
	--Select * from @DetailReport
	Select * from @DetailReport Order By FullDt
END


/* Deleted due to print results of the query
This query currently doesn't return results
Set @DtCounter =0
While 1=1
Begin
	Set @tempDate =@LowCkcDate + @DtCounter
	IF @tempDate >@HighCkcDate BREAK

	insert into @DaysInDateRange (Dt) Values (@tempDate)
	Set @DtCounter = @DtCounter+1
	IF @DtCounter >300 
	BEGIN
		Select @Driver,@LowCkcDate,@HighCkcDate,@tempDate
		Break
	END
END
*/

Insert into @Temp
Select 
	convert(datetime, (floor(convert(float,dt)) )) Dates,
	Sum(AirMilesFromLast) AirMilesPerDay,
	Sum(DrivingMinutes)/60.0 DriverHrsPerDay

from 
	@GpsInfo
group by  convert(datetime, (floor(convert(float,dt)) )) 
order by convert(datetime, (floor(convert(float,dt)) ))




insert into @DailySummary 
Select
	Dt,
	IsNull(AirMilesPerDay,0) AirMilesPerDay,
	IsNull(DriverHrsPerDay,0) DriverHrsPerDay,
	LogtableEntryYN= Case when exists (Select on_duty_hrs from log_driverlogs (NOLOCK)
		where mpp_id=@Driver and log_date = convert(datetime, (floor(convert(float,dt)) )) ) 
		THEN 'Y'
		ELSE 'N' END,

	LogTableOn_duty_hrs= 
		ISNULL(
		(Select top 1 on_duty_hrs from log_driverlogs (NOLOCK) 
		where mpp_id=@Driver and log_date = convert(datetime, (floor(convert(float,dt)) )) ) 
		,0),
	LogTableOff_duty_hrs= 
		ISNULL(
		(Select top 1 off_duty_hrs from log_driverlogs (NOLOCK)
		where mpp_id=@Driver and log_date = convert(datetime, (floor(convert(float,dt)) )) ) 
		,0),
	LogTableSleeper_berth_hrs= 
		ISNULL(
		(Select top 1 sleeper_berth_hrs from log_driverlogs (NOLOCK)
		where mpp_id=@Driver and log_date = convert(datetime, (floor(convert(float,dt)) )) ) 
		,0),
	LogTableDrvHrs= 
		ISNULL(
		(Select top 1 driving_hrs from log_driverlogs (NOLOCK)
		where mpp_id=@Driver and log_date = convert(datetime, (floor(convert(float,dt)) )) )
		,0),
	MaxCkcForDate =
		(select max(ckc_date) from ##checkcall (NOLOCK)
		where  	ckc_date between convert(datetime, (floor(convert(float,dt)) )) and convert(datetime, 1+ (Floor(convert(float,dt)) ))
			And ckc_asgntype='DRV' and ckc_asgnid =@Driver),
	IsTeamYN =
		ISNULL(
		(
		Select max(IsTeamYN) from @GpsInfo g 
		where g.dt between convert(datetime, (floor(convert(float,Dts.dt)) )) and convert(datetime, 1+ (Floor(convert(float,Dts.dt)) ))
		)
		,'N')
--pts40187 outer join conversion
From @DaysInDateRange Dts LEFT OUTER JOIN @Temp TempT ON Dts.dt =TempT.Dates
Order by Dt 


IF @ShowDetailYN ='Y'
BEGIN
	Select * From @DailySummary
	order by Dt asc
END

Insert into DriverAwareSuite_DrivingHourByGPSResults
Select 
	@Driver DriverID,
	GPSInfoStale = 
	Case when
		(
		Convert(float,GetDate() )
		-
		 Convert(float,
				IsNull( (Select max(g2.FullDt) from @DetailReport g2),'1/1/1950')
			) /24.0
		)
		>
		@StaleLimitHours then 'Yes' Else 'No' 
	End,
		
	IsTeam = 
		ISNULL(
		(
		Select max(IsTeamYN) from @GpsInfo g 
		where g.dt between DateAdd(d,-1, (Select max(g2.FullDt) from @DetailReport g2)  )
				AND
				(Select max(g2.FullDt) from @DetailReport g2)
		)
		,'N'),

   
	GPSLastFullBreakEndDt =
	(
	Select 	Top 1 FullDt LastFullBreak
	From 	@DetailReport
	Where 	FullDt = (Select 	max(g2.FullDt)
			From 	@DetailReport g2
			where 	CumulativeBreakHrs >@MinCumulativeBreak
			)
	),
	HoursOnBreakCurrently= 
	IsNull((Select Top 1 CumulativeBreakHrs
	From 	@DetailReport
	where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
		and
		miles < 6
	),0),
	CurrentBreakStart=
	CASE WHEN
		(Select Top 1 CumulativeBreakHrs
		From 	@DetailReport
		where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
		      And
		      Miles < 6
		)>0
	THEN 
		Dateadd(
			hh,
			-(Select Top 1 CumulativeBreakHrs
			From 	@DetailReport
			where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
			),
			(Select max(g2.FullDt) from @DetailReport g2)
			)
	ELSE NULL END,

	BreakCouldEndCurrentlyHrs =
	CASE WHEN
		(Select Top 1 CumulativeBreakHrs
		From 	@DetailReport
		where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
		) >0
	THEN
		@MinCumulativeBreak -
		(Select Top 1 CumulativeBreakHrs
		From 	@DetailReport
		where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
		)
	ELSE 0 END,

	BreakCouldEndCurrentlyDt= 
	CASE WHEN
		(Select Top 1 CumulativeBreakHrs
		From 	@DetailReport
		where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
		) >0
	THEN
		DateAdd(hh, 

			@MinCumulativeBreak -
			(Select Top 1 CumulativeBreakHrs
			From 	@DetailReport
			where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
			),
			(Select max(g2.FullDt) from @DetailReport g2)
	
		)
	ELSE NULL END,
	
	

	DrivingOrNonBreakHrsSinceLastFullBreak =
	CASE WHEN
	(Select Top 1 CumulativeBreakHrs
	From 	@DetailReport
	where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
	      And
	      Miles < 6
	) >= @MinCumulativeBreak THEN 0
	ELSE
	(

		Convert(Float,
			(Select max(g2.FullDt) from @DetailReport g2) -- 07/04 20:36 - 07/04 15:22

		)

		-

		Convert(float,

			(
			Select 	Top 1 --FullDt LastFullBreak
					Case When BreakHrs > 0 Then
							DateAdd(mi,-((TimeDif-(BreakHrs*60.0))),FullDt) 
					Else
							FullDt
					End LastFullBreak
			From 	@DetailReport
			Where 	FullDt = (Select 	max(g2.FullDt)
					From 	@DetailReport g2
					where 	CumulativeBreakHrs >=@MinCumulativeBreak
					)
			)
		)
	)
	*
	24.0

	END,
	MaxDrvHrsTillBreak =
	CASE WHEN
	(Select Top 1 CumulativeBreakHrs
	From 	@DetailReport
	where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
	) >0 THEN 0	
	ELSE
		@MaxCumulativeNonBreak
		-
	(
		Convert(Float,
			(Select max(g2.FullDt) from @DetailReport g2) -- 07/04 20:36 - 07/04 15:22
		)
		-
		Convert(float,
			(
			Select 	Top 1 FullDt LastFullBreak
			From 	@DetailReport
			Where 	FullDt = (Select 	max(g2.FullDt)
					From 	@DetailReport g2
					where 	CumulativeBreakHrs >@MinCumulativeBreak
					)
			)
		)
	)
	*
	24.0
	END,
	DrivingMustStopByDT =
	Case WHEN 
	(Select Top 1 CumulativeBreakHrs
	From 	@DetailReport
	where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
	) >0 THEN NULL
	ELSE
	DATEADD
	(hh,
		@MaxCumulativeNonBreak
			-
		(
			Convert(Float,
				(Select max(g2.FullDt) from @DetailReport g2) -- 07/04 20:36 - 07/04 15:22
			)
			-
			Convert(float,
				(
				Select 	Top 1 FullDt LastFullBreak
				From 	@DetailReport
				Where 	FullDt = (Select 	max(g2.FullDt)
						From 	@DetailReport g2
						where 	CumulativeBreakHrs >@MinCumulativeBreak
						)
				)
			)
		)
		*
		24.0,
	
		(Select max(g2.FullDt) from @DetailReport g2)		
	)

	
	END,	


	ContiniousDrvHrsSinceLastStop=
	(Select Top 1 CumulativeDrvHrs
	From 	@DetailReport
	where FullDt= (Select max(g2.FullDt) from @DetailReport g2)
	),
	LastGPSFound  = (Select max(g2.FullDt) from @DetailReport g2),
	GPSCalculatedDriverHrsForMaxGPSDt =
	(Select Top 1 DriverHrsPerDay From @DailySummary DS
		where DS.Dt =(Select Convert(dateTime,Floor(Convert(Float,max(g2.FullDt)))) from @DetailReport g2)
	),
	GPSCalculatedAirMilesForMaxGPSDt =
	(Select Top 1 AirMilesPerDay From @DailySummary DS
		where DS.Dt =(Select Convert(dateTime,Floor(Convert(Float,max(g2.FullDt)))) from @DetailReport g2)
	),
		
	GPSCalculatedDriverHrsForMaxGPSDtMinus1Day =
	(Select Top 1 DriverHrsPerDay From @DailySummary DS
		where DS.Dt =(Select DateAdd(D,-1,Convert(dateTime,Floor(Convert(Float,max(g2.FullDt))))) from @DetailReport g2)
	),
	
	GPSCalculatedAirMilesForMaxGPSDtMinus1Day =
	(Select Top 1 AirMilesPerDay From @DailySummary DS
		where DS.Dt =(Select DateAdd(D,-1,Convert(dateTime,Floor(Convert(Float,max(g2.FullDt))))) from @DetailReport g2)
	),
	
	GPSCalculatedDriverHrsForMaxGPSDtMinus2Day =
	(Select Top 1 DriverHrsPerDay From @DailySummary DS
		where DS.Dt =(Select DateAdd(D,-2,Convert(dateTime,Floor(Convert(Float,max(g2.FullDt))))) from @DetailReport g2)
	),
	
	GPSCalculatedAirMilesForMaxGPSDtMinus2Day =
	(Select Top 1 AirMilesPerDay From @DailySummary DS
		where DS.Dt =(Select DateAdd(D,-2,Convert(dateTime,Floor(Convert(Float,max(g2.FullDt))))) from @DetailReport g2)
	)
	


Update  DriverAwareSuite_DrivingHourByGPSResults
Set     DrivingOrNonBreakHrsSinceLastFullBreak = 0,
	HoursOnBreakCurrently = Case When CurrentBreakStart Is Not Null Then (convert(float,DateDiff(mi,CurrentBreakStart,GetDate()))/60.0)  Else (convert(float,DateDiff(mi,LastGPSFound,GetDate()))/60.0)  End 	
Where   DateDiff(hour,LastGPSFound,GetDate()) >= 13

--Select * From @DailySummary
Declare @RunningHotDriverID varchar(150)
Declare @LastGPSDate datetime

Select @RunningHotDriverID = DriverID,@LastGPSDate=LastGPSFound
      From   DriverAwareSuite_DrivingHourBYGPSResults (NOLOCK)
      Where  DriverID = @Driver  
             And
             cast(DrivingOrNonBreakHrsSinceLastFullBreak as int) = 15
             And 
             cast(HoursOnBreakCurrently as int) = 0  



If @RunningHotDriverID Is Not Null
Begin
if not exists (select mpp_id from DriverAwareSuite_Information where mpp_id = @Driver)
Begin

      INSERT INTO DriverAwareSuite_Information (mpp_id,lastviolationdate) Values (@RunningHotDriverID,@LastGPSDate)
       
End
Else
Begin
      Update DriverAwareSuite_Information Set lastviolationdate = @LastGPSDate
      Where mpp_id = @RunningHotDriverID 
     

End


End

GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_DrivingHourByGPS] TO [public]
GO
