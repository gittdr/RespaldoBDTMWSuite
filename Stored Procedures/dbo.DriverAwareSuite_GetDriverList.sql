SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO





































--DriverAwareSuite_GetDriverList @StartDate='5/10/2005',@Sort='HSLB/INACT',@IncludeBillableEventsOnly='Y',@StartRegion1='500'
CREATE                                                      Procedure [dbo].[DriverAwareSuite_GetDriverList] (@StartDate datetime,
					 @DrvType1 varchar(255)='',
					 @DrvType2 varchar(255)='',
					 @DrvType3 varchar(255)='',
					 @DrvType4 varchar(255)='',
					 @TeamLeader varchar(255)='',
					 @DrvTerminal varchar(255)='',
					 @DrvCompany varchar(255)='',
					 @DrvDivision varchar(255)='',
					 @DrvDomicile varchar(255)='',
					 @DrvFleet varchar(255)='',
					 @Sort varchar(255)='DrvId',
					 @ExcludeEventsForOnTime Varchar(255)='TRP,RTP',
					 @DriverID varchar(100)='',
					 @IncludeBillableEventsOnly char(1) = 'N',
					 @StartRegion1 varchar(255)='',
					 @EndRegion1 varchar(255)=''
					)

As

/**

 * 

 * NAME:

 * dbo.DriverAwareSuite_GetDriverList

 *

 * TYPE:

 * StoredProcedure

 *

 * DESCRIPTION:

 * This procedure returns a list of drivers and driver associated driver fields based on different criteria

 *

 * RETURNS:

 * [N/A] | [Values specified in the ?Return? statement]

 *

 * RESULT SETS: 

 * [None] | [See selection list] | [Actual list].

 *

 * PARAMETERS:

 *

 * REFERENCES: 

 *              

 * Calls001    ? DriverAwareSuite_GetDriverList @StartDate='5/10/2005',@Sort='HSLB/INACT',@IncludeBillableEventsOnly='Y',@StartRegion1='500'


 * 

 * REVISION HISTORY:

 * 

 *

 **/


Set NoCount On

Declare @LastLogDate datetime
Declare @SQL varchar(5000)
Declare @UserID varchar(255)
Declare @GroupID varchar(255)
Declare @ServerTimeZone int
Declare @TripDateType varchar(255) --Can be based off ScheduledArrival, ScheduledEarliest, ScheduledLatest
Declare @ExcludeDriverStatusList varchar(255) --Added 1.3 to filter out drivers that have certain driver statuses
Declare @TodaysDate datetime
Declare @UseCityProfileOnlyForLatLong char(1)
Declare @IncludeBreakTimeForETACalc char(1)
Declare @UserToSearch varchar(255)
Declare @IncludeEventsForOnTime varchar(255)
Declare @UseDriverLogsForHoursOfService char(1)

select @LastLogDate =  (Cast(Floor(Cast(getdate() as float))as smalldatetime))-1
Set @TripDateType = (select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'TripDateType')
Set @ExcludeDriverStatusList = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'ExcludeDriverStatusList'),'OUT')
Set @IncludeBillableEventsOnly = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'IncludeBillableEventsOnly'),@IncludeBillableEventsOnly)
Set @ExcludeEventsForOnTime = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'ExcludeEventsForOnTime'),@ExcludeEventsForOnTime)
Set @UseCityProfileOnlyForLatLong = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'UseCityProfileOnlyForLatLong'),'N')
Set @IncludeBreakTimeForETACalc = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'IncludeBreakTimeForETACalc'),'N')
Set @IncludeEventsForOnTime = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'IncludeEventsForOnTime'),'')
Set @UseDriverLogsForHoursOfService = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'UseDriverLogsForHoursOfService'),'N')


Set @TodaysDate = (Cast(Floor(Cast(getdate() as float))as smalldatetime))


SELECT @drvtype1 = ',' + LTRIM(RTRIM(ISNULL(@drvtype1, ''))) + ','
SELECT @drvtype2 = ',' + LTRIM(RTRIM(ISNULL(@drvtype2, ''))) + ','
SELECT @drvtype3 = ',' + LTRIM(RTRIM(ISNULL(@drvtype3, ''))) + ',' 
SELECT @drvtype4 = ',' + LTRIM(RTRIM(ISNULL(@drvtype4, ''))) + ',' 
SELECT @DriverID = ',' + LTRIM(RTRIM(ISNULL(@DriverID, ''))) + ',' 
SELECT @DrvTerminal = ',' + LTRIM(RTRIM(ISNULL(@DrvTerminal, ''))) + ',' 
SELECT @DrvCompany = ',' + LTRIM(RTRIM(ISNULL(@DrvCompany, ''))) + ',' 
SELECT @DrvDivision = ',' + LTRIM(RTRIM(ISNULL(@DrvDivision, ''))) + ',' 
SELECT @DrvDomicile = ',' + LTRIM(RTRIM(ISNULL(@DrvDomicile, ''))) + ',' 
SELECT @DrvFleet = ',' + LTRIM(RTRIM(ISNULL(@DrvFleet, ''))) + ',' 					
SELECT @TeamLeader = ',' + LTRIM(RTRIM(ISNULL(@TeamLeader, ''))) + ',' 
SELECT @ExcludeEventsForOnTime = ',' + LTRIM(RTRIM(ISNULL(@ExcludeEventsForOnTime, ''))) + ',' 
SELECT @IncludeEventsForOnTime = ',' + LTRIM(RTRIM(ISNULL(@IncludeEventsForOnTime, ''))) + ',' 
SELECT @StartRegion1 = ',' + LTRIM(RTRIM(ISNULL(@StartRegion1, ''))) + ','
SELECT @EndRegion1 = ',' + LTRIM(RTRIM(ISNULL(@EndRegion1, ''))) + ','
SELECT @ExcludeDriverStatusList = ',' + LTRIM(RTRIM(ISNULL(@ExcludeDriverStatusList, ''))) + ','

Select mpp_id 'DrvID',
       mpp_type1 as DrvType1,
       mpp_type2 as DrvType2,
       mpp_type3 as DrvType3,
       mpp_type4 as DrvType4,
       mpp_terminal as DrvTerminal,
       mpp_division as DrvDivision,
       mpp_company as DrvCompany,
       mpp_domicile as DrvDomicile,
       mpp_fleet as DrvFleet,
       mpp_lastfirst 'DriverName', 
       mpp_tractornumber as Tractor,
	--CASE WHEN ASC(Left(mpp_ID,1) % 5 = then 'MVING' else 'View' END      'Stat'," & vbCrLf
       /* CASE WHEN ASCii(Substring(mpp_ID,2,1)) % 6 = 0 then 'MVING' 
             WHEN ASCii(Substring(mpp_ID,2,1)) % 6 = 1 then 'UNVL'
             WHEN ASCii(Substring(mpp_ID,2,1)) % 6 = 2 then 'AVL'  
             WHEN ASCii(Substring(mpp_ID,2,1)) % 6 = 3 then 'MAIN' 
             WHEN ASCii(Substring(mpp_ID,2,1)) % 6 = 4 then 'VIEW' 
       	     WHEN ASCii(Substring(mpp_ID,2,1)) % 6 = 5 then 'SENT' 
             else 'View' END      'Stat',*/
       Replace(mpp_gps_desc,';','|') as LastGPS,
       mpp_dailyhrsest   'DailyHrsEst', --quarter hour 
       mpp_weeklyhrsest   'WeeklyHrsEst',
       mpp_lastlog_estdate 'LastLog_EstDate',
       mpp_lastlog_cmp_name 'LastLogCompany',
       /*mpp_estlog_datetime  'EstLogDt',*/
       mpp_gps_date         'LastGPSDt',
       mpp_mile_day7        'Miles7Day',
       [Day 1]= (select IsNull(on_duty_hrs,0)+ IsNull(driving_hrs,0) from log_driverlogs dh where dh.mpp_id = manpowerprofile.mpp_id and log_date =  @LastLogDate),
       [Day 2]= (select IsNull(on_duty_hrs,0)+ IsNull(driving_hrs,0) from log_driverlogs dh where dh.mpp_id = manpowerprofile.mpp_id and log_date =  @LastLogDate-1),
       [Day 3]= (select IsNull(on_duty_hrs,0)+ IsNull(driving_hrs,0) from log_driverlogs dh where dh.mpp_id = manpowerprofile.mpp_id and log_date =  @LastLogDate-2),
       [Day 4]= (select IsNull(on_duty_hrs,0)+ IsNull(driving_hrs,0) from log_driverlogs dh where dh.mpp_id = manpowerprofile.mpp_id and log_date =  @LastLogDate-3),
       [Day 5]= (select IsNull(on_duty_hrs,0)+ IsNull(driving_hrs,0) from log_driverlogs dh where dh.mpp_id = manpowerprofile.mpp_id and log_date =  @LastLogDate-4),
       [Day 6]= (select IsNull(on_duty_hrs,0)+ IsNull(driving_hrs,0) from log_driverlogs dh where dh.mpp_id = manpowerprofile.mpp_id and log_date =  @LastLogDate-5),
       [Day 7]= (select IsNull(on_duty_hrs,0)+ IsNull(driving_hrs,0) from log_driverlogs dh where dh.mpp_id = manpowerprofile.mpp_id and log_date =  @LastLogDate-6),
       [Day 8]= (select IsNull(on_duty_hrs,0)+ IsNull(driving_hrs,0) from log_driverlogs dh where dh.mpp_id = manpowerprofile.mpp_id and log_date =  @LastLogDate-7),
       cast(NULL as datetime) expirationdate,
       cast(NULL as varchar(100)) ExpCode,
       mpp_gps_latitude,
       mpp_gps_longitude,
       mpp_hiredate as HireDate,
       mpp_servicerule,
       mpp_avl_date as AvailableDate
       
      
into   #DriverList
from   manpowerProfile (NOLOCK)
where Mpp_id<> 'UNKNOWN' 
      and 
      (@ExcludeDriverStatusList = ',,' OR Not (CHARINDEX(',' + IsNull(mpp_status,'') + ',', @ExcludeDriverStatusList) > 0))
      AND 
      (@drvtype1 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type1 + ',', @drvtype1) > 0) 
      And
      (@drvtype2 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type2  + ',', @drvtype2) > 0) 
      And
      (@drvtype3 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type3  + ',', @drvtype3) > 0) 
      And
      (@drvtype4 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type4  + ',', @drvtype4) > 0)
      AND 
      (@TeamLeader = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_teamleader  + ',', @TeamLeader) > 0)
      And
      (@DrvTerminal = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_terminal  + ',', @DrvTerminal) > 0)
      and
      (@DriverID = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_id  + ',', @DriverID) > 0)
      and
      (@DrvCompany = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_company  + ',', @DrvCompany) > 0)
      and
      (@DrvDivision = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_division  + ',', @DrvDivision) > 0)
       and
      (@DrvDomicile = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_domicile  + ',', @DrvDomicile) > 0)
       and
      (@DrvFleet = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_fleet  + ',', @DrvFleet) > 0)

order by mpp_id 


--Find out drivers that are starting or ending in a region
If (@StartRegion1 <> ',,' Or @EndRegion1 <> ',,')
Begin

	Create Table #DriversInRegions (DriverID varchar(100))

	select lgh_driver1,lgh_driver2
	into   #LegHeadersInRegions
	from   legheader_active (NOLOCK)
	Where  (@StartRegion1 = ',,' OR CHARINDEX(',' + legheader_active.lgh_startregion1 + ',', @StartRegion1) > 0) 
      		And
      	       (@EndRegion1 = ',,' OR CHARINDEX(',' + legheader_active.lgh_endregion1  + ',', @EndRegion1) > 0) 
	       
	      
	Insert into #DriversInRegions
	select distinct lgh_driver1
	From #LegHeadersInRegions
	Where lgh_driver1 <> 'UNK' and lgh_driver1 <> 'UNKNOWN'

	Insert into #DriversInRegions
	select distinct lgh_driver2
	From #LegHeadersInRegions
	Where lgh_driver2 <> 'UNK' and lgh_driver2 <> 'UNKNOWN'

	Delete from #DriverList
	Where not exists (select DriverID from #DriversInRegions where #DriverList.DrvID = #DriversInRegions.DriverID)
	      
		
End

		
update 	#DriverList
set 	expirationdate=(select min(e.exp_expirationdate)
from 	expiration e(nolock)  
where 	e.exp_expirationdate > getdate()
		and
		e.exp_id=#DriverList.DrvId
        and 
        e.exp_idtype = 'DRV'
 )

update  #DriverList
set 	Expcode=e.exp_code
from 	expiration e(nolock) 
where	#DriverList.expirationdate=e.exp_expirationdate
		and
		e.exp_id=#DriverList.DrvId
        and 
        e.exp_idtype = 'DRV'

/*On Time Logic For Driver*/

/****************************************************************************
	Create temp table #TempResults where the following conditions are met:
	
	The load is already late (not arrived, past latest scheduled arrival)

	The load is going to be late (based on shortest distance at average miles per hour
			will still be late)
	The load might be late (based on shortest distance at average miles per hour
			might be late)

*****************************************************************************/

--Assume Eastern Time Zone or eventually figure it out from 
--time zone that the sql server is on as the default if the general
--info setting doesn't exist
Set @ServerTimeZone = cast(IsNull((select cast(dsat_value as int) from DriverAwareSuite_GeneralInfo where dsat_type = 'TimeZone' and dsat_key = 'ServerTimeZone'),6) as int)

SELECT 	        DateAdd(hour,(@ServerTimeZone - IsNull(cty_GMTDelta,@ServerTimeZone)),LastGPSDt) as GPSDateTime, 
		t4.cty_nmstct as Destination,
		Case When (t2.cmp_id In ('UNKNOWN','UNK',Null) OR comp.cmp_latseconds Is Null or @UseCityProfileOnlyForLatLong = 'Y') Then
			Convert(float,ISNULL(	
					-- Convert values from degrees to radians 
			(
			Select 
			Acos(
				cos(	(
						Convert(decimal(6,2),(convert(float,mpp_gps_latitude)/3600.0))
						* 3.14159265358979 / 180.0)  )  *
				cos(	(t4.cty_latitude * 3.14159265358979 / 180.0)  )  *
		                cos (  
					(
						Convert(decimal(6,2),(convert(float,mpp_gps_longitude)/3600.0))
					* 3.14159265358979 / 180.0) - 
					(t4.cty_longitude * 3.14159265358979 / 180.0)
				    )	+
				Sin (	(
						Convert(decimal(6,2),(convert(float, mpp_gps_latitude)/3600.0))
					* 3.14159265358979 / 180.0) ) *
				Sin (	(t4.cty_latitude * 3.14159265358979 / 180.0) ) 	
			    ) * 3956.5
			)
		,9999) -- ISNULL
		)			
		Else
			Convert(float,ISNULL(	
					-- Convert values from degrees to radians 
			(
			Select 
			Acos(
				cos(	(
						Convert(decimal(6,2),(convert(float,mpp_gps_latitude)/3600.0))
						* 3.14159265358979 / 180.0)  )  *
				cos(	((isnull(comp.cmp_latseconds,0.0000)/3600.000) * 3.14159265358979 / 180.0)  )  *
		                cos (  
					(
						Convert(decimal(6,2),(convert(float,mpp_gps_longitude)/3600.0))
					* 3.14159265358979 / 180.0) - 
					((isnull(comp.cmp_longseconds,0.0000)/3600.000) * 3.14159265358979 / 180.0)
				    )	+
				Sin (	(
						Convert(decimal(6,2),(convert(float, mpp_gps_latitude)/3600.0))
					* 3.14159265358979 / 180.0) ) *
				Sin (	((isnull(comp.cmp_latseconds,0.0000)/3600.000) * 3.14159265358979 / 180.0) ) 	
			    ) * 3956.5
			)
		,9999) -- ISNULL
		)	
		End AS AirMilesToGo ,
		0 EstimatedMilesToGo, 
		GETDATE() AS Now, 
		
	    Case When @TripDateType = 'Earliest' Then
			  Case When stp_status = 'DNE' Then
				t2.stp_arrivaldate --Use The Actual
                          Else
			   	t2.stp_schdtearliest --Use the Estimated
			  End
		     When @TripDateType = 'Latest' Then
			   Case When stp_status = 'DNE' Then
				t2.stp_arrivaldate --Use The Actual
		     	  Else
				t2.stp_schdtlatest --Use the Estimated
			  End
		     Else
			  t2.stp_arrivaldate --Use the actual
		End AS ScheduledLatest, 

		GETDATE() AS ETA,
		
		'**********' AS OrderStatus,
		CONVERT(decimal(20, 5), 0) AS PlusMinus,
		Case When @TripDateType = 'Earliest' Then
			  Case When lgh_outstatus = 'CMP' or lgh_outstatus = 'STD' Then
				lgh_startdate --Use The Actual
                          Else
			   	lgh_schdtearliest --Use the Estimated
			  End
		     When @TripDateType = 'Latest' Then
			  Case When lgh_outstatus = 'CMP' or lgh_outstatus = 'STD' Then
				lgh_startdate --Use The Actual
		     	  Else
				lgh_schdtlatest --Use the Estimated
			  End
		     Else
			  lgh_startdate --Use the actual
		End as StartDate,		
		--lgh_startdate as StartDate, 
		t1.lgh_number as LegHeaderNumber, 
		t1.lgh_tractor as Tractor, 
			
	        Case When @TripDateType = 'Earliest' Then
			  Case When stp_status = 'DNE' Then
				t2.stp_arrivaldate --Use The Actual
                          Else
			   	t2.stp_schdtearliest --Use the Estimated
			  End
		     When @TripDateType = 'Latest' Then
			   Case When stp_status = 'DNE' Then
				t2.stp_arrivaldate --Use The Actual
		     	  Else
				t2.stp_schdtlatest --Use the Estimated
			  End
		     Else
			  t2.stp_arrivaldate --Use the actual
		End stp_arrivaldate,


--		t2.stp_arrivaldate,
		lgh_driver1 as [Driver ID],
	    t2.stp_number,
		lgh_driver2 as [Driver2 ID],
		lgh_comment as ActiveTripComment
		
		
	INTO #TempResults
	FROM    legheader_active t1 (NOLOCK) Inner Join stops t2 (NOLOCK) On t1.lgh_number = t2.lgh_number
					     Inner Join #DriverList t3 (NOLOCK) On t1.lgh_driver1 = t3.[DrvID]
					     Inner Join	city t4 (NOLOCK) On t2.stp_city = t4.cty_code
					     Left Join company comp (NOLOCK) On comp.cmp_id = t2.cmp_id
	WHERE   					
		stp_status = 'OPN' AND lgh_outstatus <> 'CMP' AND lgh_outstatus <> 'AVL'
		AND ISNULL(t1.lgh_driver1, 'UNKNOWN') <> 'UNKNOWN'
		And t3.LastGPSDt Is Not Null
		and not exists (select b.lgh_number from legheader_active b where  b.cmp_id_start = b.cmp_id_end and b.ord_hdrnumber=0 and b.ord_stopcount < 2 and b.lgh_number = t1.lgh_number)
		and (@ExcludeEventsForOnTime = ',,' OR Not (CHARINDEX(',' + rtrim(stp_event) + ',', @ExcludeEventsForOnTime) > 0)) 
		and (@IncludeEventsForOnTime = ',,' OR CHARINDEX(',' + rtrim(stp_event)  + ',', @IncludeEventsForOnTime) > 0) 
		and (
		     (@IncludeBillableEventsOnly = 'N')
		     Or
		     (@IncludeBillableEventsOnly = 'Y' And t2.ord_hdrnumber > 0)
		    )
		
		
		
		--AND IsNull((select count(*) from stops (NOLOCK) 
			--Where stops.lgh_number = legheader_active.lgh_number and cmp_id_start = cmp_id_end and legheader_active.ord_hdrnumber=0 
		--),0) <> 2

If @IncludeBreakTimeForETACalc = 'Y'
Begin

	select identity(int,1,1) as id,
	       ckc_asgnid,
	       Null as HoursDriven,
	       ckc_date,
	       ckc_mileage
	into   #TempCheckCalls
	From   checkcall a (NOLOCK),
	       #DriverList
	Where  a.ckc_date >= (Cast(Floor(Cast(getdate() as float))as smalldatetime))
	       And
	       a.ckc_date < (Cast(Floor(Cast(getdate()+1 as float))as smalldatetime))
	       And
	       a.ckc_asgntype = 'DRV'
	       And
	       #DriverList.DrvId = a.ckc_asgnid
	       
	order by ckc_asgnid,ckc_date
        	
	Create Table #TempHoursDrivenByDriver
		(
			HoursDriven int,
			asgn_id varchar(255)
		)


	
	
	Insert into #TempHoursDrivenByDriver
	Select 
	       --cast(IsNull(datediff(n,Prev.ckc_date,Nxt.ckc_date),0) as float) as HoursDriven,
	       cast(sum(IsNull(datediff(n,Prev.ckc_date,Nxt.ckc_date),0)) as float)/cast(60 as float) as HoursDriven,
	       --cast(sum(IsNull(datediff(n,Prev.ckc_date,Nxt.ckc_date),0)) as float) HoursDriven, --/--cast(60 as float) as HoursDriven,
	       Nxt.ckc_asgnid
	       --Prev.ckc_date as PreviousDate,
	       --Nxt.ckc_date as NextDate,
		
	       --Nxt.ckc_mileage 
	       
	From   #TempCheckCalls Nxt,
	       #TempCheckCalls Prev

	Where  Nxt.id =Prev.ID+1 And Nxt.ckc_asgnid = Prev.ckc_asgnid
	       And
	       Nxt.ckc_mileage > 5	
	group by Nxt.ckc_asgnid
	order by Nxt.ckc_asgnid

UPDATE #TempResults SET  EstimatedMilesToGo = AirMilesToGo, --* (1 + @AirMilesAdjustmentPct), 
	ETA =
			--Driver can't make his destination because he has to take a break
		
	Case When IsNull([Driver2 ID],'') <> 'UNK' and IsNull([Driver2 ID],'') <> 'UNKNOWN' and [Driver2 ID] Is Not Null And (11-(select HoursDriven from #TempHoursDrivenByDriver where #TempHoursDrivenByDriver.asgn_id = [Driver ID])) < ((AirMilesToGo)/45) Then
		DateAdd(hour,
	(
		IsNull((
		cast((
		 (
	     ((AirMilesToGo)/45)  - 
			(11 - (select HoursDriven from #TempHoursDrivenByDriver where #TempHoursDrivenByDriver.asgn_id = [Driver ID]))
		 )
		/11) as int)
	*10),0) + 10
	+
	       ((AirMilesToGo )/ 45) 
		)
		 ,GPSDateTime)


	Else
			DATEADD(hour, ((AirMilesToGo)/45), GPSDateTime) 
	
	End

End
Else
Begin


	UPDATE #TempResults SET  EstimatedMilesToGo = AirMilesToGo, --* (1 + @AirMilesAdjustmentPct), 
		ETA = DATEADD(hour, (AirMilesToGo )/ 45, GPSDateTime)
	
	
End


UPDATE #tempresults SET OrderStatus = CASE WHEN ETA > ScheduledLatest THEN 'LATE' ELSE 'On-Time' END,
		PlusMinus = Case When EstimatedMilesToGo = 9999 Then 9999 Else -1 * (DATEDIFF(minute, ScheduledLatest, ETA) / 60.0) End

Select * ,
	       stp_arrivaldate as NextOpenEventDate
	into   #TempDriverOnTime
	from #TempResults
	Where  stp_number = (select min(a.stp_number) from #TempResults a where a.LegHeaderNumber = #TempResults.LegHeaderNumber and a.stp_arrivaldate = 
																	(select min(b.stp_arrivaldate) from #TempResults b where b.LegHeaderNumber = #TempResults.LegHeaderNumber))
		   And
		   StartDate = (Select min(b.startdate) from #TempResults b where b.[Driver ID] = #TempResults.[Driver ID])

	Order By Tractor,stp_arrivaldate

Select 
       #DriverList.DrvID,
       #DriverList.DriverName, 
       #DriverList.[Tractor],
       Notes = case When Len(IsNull(Info.Misc1,'')) > 0 Or Len(IsNull(Info.ExtendedOpsNotes,'')) > 0 Then 1 Else 0 End ,
       INFO.misc1date as [Misc Date],
       INFO.misc1 as [Misc],
       case when len(cast(cast(DrivingOrNonBreakHrsSinceLastFullBreak as int)as varchar(50))) < 2 Then '0' + cast(cast(DrivingOrNonBreakHrsSinceLastFullBreak as int) as varchar(50)) Else cast(cast(DrivingOrNonBreakHrsSinceLastFullBreak as int) as varchar(50)) End + '/' + Case When len(cast(cast(HoursOnBreakCurrently as int) as varchar(50))) < 2 Then '0' + cast(cast(HoursOnBreakCurrently as int) as varchar(50)) Else cast(cast(HoursOnBreakCurrently as int) as varchar(50)) End as [HSLB/INACT],
       cast(PlusMinus as decimal(15,2)) as OnTime,
       NextOpenEventDate,
       #DriverList.LastGPS,
       #DriverList.LastGPSDt,
       Case When @UseDriverLogsForHoursOfService = 'Y' Then 
		Case When IsNull((select sum(IsNull(driving_hrs,0) + IsNull(on_duty_hrs,0)) from log_driverlogs (NOLOCK) where log_driverlogs.mpp_id = DrvID and log_date = Cast(Floor(Cast(getdate() as float))as smalldatetime)-1),0) > 0 Then 
			'Yes' 
		Else
			'No'
		End 
       Else
		@UseDriverLogsForHoursOfService
       End as HoursOfService,
       #DriverList.DailyHrsEst as [DailyHrsEst],
       IsNull(#DriverList.WeeklyHrsEst,
	case When charindex(RTrim(IsNull(mpp_servicerule,0)),'/')=0 Then--mpp_servicerule Is Null or RTrim(mpp_servicerule) = '' Then
	  	Null
         Else
  		convert(int,(Substring([mpp_servicerule],charindex('/',[mpp_servicerule])+1,5))) - 
          (select sum(b.driving_hrs + b.on_duty_hrs) from log_driverlogs b where #DriverList.DrvID = b.mpp_id and b.log_date >= 
                IsNull((select max(b.log_date) from log_driverlogs b where b.log_date >= (@TodaysDate -((convert(int,(Left([mpp_servicerule],charindex('/',[mpp_servicerule],1)-1))))-1)) and b.log_date <= @TodaysDate and b.rule_reset_indc = 'Y' and  b.mpp_id = #DriverList.DrvID and @TodaysDate >= b.log_date),   --else just go back the # days of the rule
                                                     (@TodaysDate - ((convert(int,(Left([mpp_servicerule],charindex('/',[mpp_servicerule],1)-1))))-1))) 
            and 
            b.log_date <= @TodaysDate)
	 End
 	) as [WeeklyHrsEst],
       #DriverList.LastLogCompany,
       #DriverList.LastLog_EstDate,
       #DriverList.[Day 8],
       #DriverList.[Day 7],
       #DriverList.[Day 6],
       #DriverList.[Day 5],
       #DriverList.[Day 4],
       #DriverList.[Day 3],
       #DriverList.[Day 2],
       #DriverList.[Day 1],   
    
       --#DriverList.EstLogDt,
       #DriverList.Miles7Day,
       ExpCode + ' ' + convert(varchar(50),expirationdate) as NextExpDt,
       HSLBHoursLastBreak=cast(DrivingOrNonBreakHrsSinceLastFullBreak as int), --case when cast(DrivingOrNonBreakHrsSinceLastFullBreak as int) = 0 Then Null Else cast(DrivingOrNonBreakHrsSinceLastFullBreak as int) End,
       HSLBHoursNotMoving = cast(HoursOnBreakCurrently as int),--case when cast(HoursOnBreakCurrently as int) = 0 Then Null Else cast(HoursOnBreakCurrently as int) End,
       extdopsnotesdate as [ExtendedOpsNotes Date],
       ExtendedOpsNotes,
       ' ' as [OT/NOED],
       DrvType1,
       DrvType2,
       DrvType3,
       DrvType4,
       DrvTerminal,
       DrvDivision,
       DrvCompany,
       DrvDomicile,
       DrvFleet,
       HireDate,
       Destination as NextOpenCityState,
       ActiveTripComment,
       ExpCode as NextExpCode,
       expirationdate as NextExpDateOnly,
       AvailableDate       

       --LastViolationDate as LastSASAViolationDate
       --INFO.CompletedForDay 
       	

into   #TempHolder       
From   #DriverList --Left Join #Temp On #DriverList.[DrvID] = #temp.mpp_id
		   Left Join #TempDriverOnTime On #TempDriverOnTime.[Driver ID]=#DriverList.[DrvID]
		   Left Join DriverAwareSuite_DrivingHourByGPSResults DrvGPS On DrvGPS.DriverID = #DriverList.DrvId
		   Left Join DriverAwareSuite_MAC17 On DriverAwareSuite_MAC17.trc_driver = #DriverList.DrvID
		   Left Join DriverAwareSuite_Information INFO on INFO.mpp_id = #DriverList.[DrvID]


   
Set @SQL=''

Set @UserToSearch = IsNull((select usr_userid from ttsusers (NOLOCK) where IsNull(usr_windows_userid,'') = system_user and system_user <> IsNull(usr_userid,'') ),system_user)

--Determine if the user has a user specific
--column configuration
Select Top 1
       @UserID = UserID
From   DriverAwareSuite_ColumnConfiguration
Where  (UserID = @UserToSearch
       ) 




If Len(@UserID) > 0 
Begin
	Select @SQL = @SQL + '[' + ColumnName + ']' + ','
	From   DriverAwareSuite_ColumnConfiguration
	Where  userid = @UserToSearch
	Order By ColumnOrder
End
Else

Begin
	--Find the group the user belongs to	
	Select @GroupID = grp_id
	From   ttsgroupasgn
	Where  usr_userid = @UserToSearch

	

	If @GroupID Is Null
	Begin
		Set @GroupID = 'ALL'
	End

	Select @SQL = @SQL + '[' + ColumnName + ']' + ','
	From   DriverAwareSuite_ColumnConfiguration
	Where  groupid = @GroupID
	Order By ColumnOrder

End




If @SQL Is Null Or RTrim(@SQL )=''
Begin

	Select *    
	From   #TempHolder
	Order By
       case when @sort = 'DrvId' then DrvId end,
       case when @sort = 'DriverName' then DriverName end,
       case when @sort = 'Tractor' then Tractor end,
       case when @sort = 'Misc' then Misc end,
       case when @sort= 'OnTime' then OnTime end,
       case when @sort = 'LastGPS' then LastGPS end,
       case when @sort = 'LastGPSDt' then LastGPSDt end,
       case when @sort = 'HoursOfService' then HoursOfService end,
       case when @sort = 'DailyHrsEst' then [DailyHrsEst] end,
       case when @sort = 'WeeklyHrsEst' then [WeeklyHrsEst] end,
       case when @sort = 'LastLogCompany' then LastLogCompany end,
       case when @sort = 'LastLog_EstDate' then LastLog_EstDate end,
       case when @sort = 'Day 1' then [Day 1] end,
       case when @sort = 'Day 2' then [Day 2] end,
       case when @sort = 'Day 3' then [Day 3] end,
       case when @sort = 'Day 4' then [Day 4] end,
       case when @sort = 'Day 5' then [Day 5] end,
       case when @sort = 'Day 6' then [Day 6] end,
       case when @sort = 'Day 7' then [Day 7] end,
       case when @sort = 'Day 8' then [Day 8] end,
       case when @sort = 'Miles7Day' then [Miles7Day] end,
       case when @sort = 'NextExpDt' then [NextExpDt] end,
       case when @sort = 'HSLB/INACT' then HSLBHoursLastBreak end DESC,
       case when @sort = 'NextOpenEventDate' then [NextOpenEventDate] end,
       case when @sort = 'OT/NOED' then case when OnTime >= 0 Then Null Else NextOpenEventDate end end desc,
       case when @sort =  'OT/NOED' then OnTime end ASC	,
       --case when @sort = 'LastSASAViolationDate' Then LastSASAViolationDate End,
       case when @sort = 'DrvType1' Then DrvType1 End,
       case when @sort = 'DrvType2' Then DrvType2 End,	
       case when @sort = 'DrvType3' Then DrvType3 End,
       case when @sort = 'DrvType4' Then DrvType4 End,
       case when @sort = 'DrvTerminal' Then DrvTerminal End,
       case when @sort = 'DrvCompany' Then DrvCompany End,
       case when @sort = 'DrvDivision' Then DrvDivision End,
       case when @sort = 'DrvFleet' Then DrvFleet End,
       case when @sort = 'DrvDomicile' Then DrvDomicile End,
       case when @sort = 'Misc Date' then [Misc Date] end DESC,
       case when @sort = 'ExtendedOpsNotes Date' then [ExtendedOpsNotes Date] end DESC,
       case when @sort = 'HireDate' then HireDate end ASC,
       case when @sort = 'NextOpenCityState' then NextOpenCityState end ASC,
       case when @sort = 'ActiveTripComment' then ActiveTripComment end ASC,
       case when @sort = 'NextExpCode' then NextExpCode end ASC,
       case when @sort = 'NextExpDateOnly' then NextExpDateOnly end ASC,
       case when @sort = 'AvailableDate' then AvailableDate end ASC
 
End
Else
Begin
	
	select * into #TempFinal from #TempHolder where 1=2

	Insert Into #TempFinal
	Select * From #TempHolder
	Order By
       case when @sort = 'DrvId' then DrvId end,
       case when @sort = 'DriverName' then DriverName end,
       case when @sort = 'Tractor' then Tractor end,
       case when @sort = 'Misc' then Misc end,
       case when @sort= 'OnTime' then OnTime end,
       case when @sort = 'LastGPS' then LastGPS end,
       case when @sort = 'LastGPSDt' then LastGPSDt end,
       case when @sort = 'HoursOfService' then HoursOfService end,
       case when @sort = 'DailyHrsEst' then [DailyHrsEst] end,
       case when @sort = 'WeeklyHrsEst' then [WeeklyHrsEst] end,
       case when @sort = 'LastLogCompany' then LastLogCompany end,
       case when @sort = 'LastLog_EstDate' then LastLog_EstDate end,
       case when @sort = 'Day 1' then [Day 1] end,
       case when @sort = 'Day 2' then [Day 2] end,
       case when @sort = 'Day 3' then [Day 3] end,
       case when @sort = 'Day 4' then [Day 4] end,
       case when @sort = 'Day 5' then [Day 5] end,
       case when @sort = 'Day 6' then [Day 6] end,
       case when @sort = 'Day 7' then [Day 7] end,
       case when @sort = 'Day 8' then [Day 8] end,
       case when @sort = 'Miles7Day' then [Miles7Day] end,
       case when @sort = 'NextExpDt' then [NextExpDt] end,
       case when @sort = 'HSLB/INACT' then HSLBHoursLastBreak end DESC,

       case when @sort = 'NextOpenEventDate' then [NextOpenEventDate] end,
       case when @sort = 'OT/NOED' then case when OnTime >= 0 Then Null Else NextOpenEventDate end end desc,
       case when @sort =  'OT/NOED' then OnTime end ASC	,
       --case when @sort = 'LastSASAViolationDate' Then LastSASAViolationDate End,
       case when @sort = 'DrvType1' Then DrvType1 End,
       case when @sort = 'DrvType2' Then DrvType2 End,	
       case when @sort = 'DrvType3' Then DrvType3 End,
       case when @sort = 'DrvType4' Then DrvType4 End,
       case when @sort = 'DrvTerminal' Then DrvTerminal End,
       case when @sort = 'DrvCompany' Then DrvCompany End,
       case when @sort = 'DrvDivision' Then DrvDivision End,
       case when @sort = 'DrvFleet' Then DrvFleet End,
       case when @sort = 'DrvDomicile' Then DrvDomicile End,
       case when @sort = 'Misc Date' then [Misc Date] end DESC,
       case when @sort = 'ExtendedOpsNotes Date' then [ExtendedOpsNotes Date] end DESC,
       case when @sort = 'HireDate' then HireDate end ASC,
       case when @sort = 'NextOpenCityState' then NextOpenCityState end ASC,
       case when @sort = 'ActiveTripComment' then ActiveTripComment end ASC,
       case when @sort = 'NextExpCode' then NextExpCode end ASC,
       case when @sort = 'NextExpDateOnly' then NextExpDateOnly end ASC,
       case when @sort = 'AvailableDate' then AvailableDate end ASC
      
	Set @SQL = 'Select ' + Left(@SQL,Len(@SQL)-1) + ' From #TempFinal'
	
	Exec (@SQL)

End





















































































GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetDriverList] TO [public]
GO
