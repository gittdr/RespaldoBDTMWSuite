SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE  Proc [dbo].[WatchDog_DriverZoneLateLogic] 
 
( 
        @MinThreshold float = 1.25, 
        @MinsBack int=-20, 
        @TempTableName varchar(255) = '##WatchDogGlobalDriverZoneLateLogic', 
        @WatchName varchar(255) = 'DriverZoneLateLogic', 
        @ThresholdFieldName varchar(255) = 'DriverZoneLateLogic', 
        @ColumnNamesOnly bit = 0, 
        @ExecuteDirectly bit = 0, 
        @ColumnMode varchar (50) ='Selected' 
) 
 
AS 
 

--Reserved/Mandatory WatchDog Variables 
        Declare @SQL varchar(8000) 
        Declare @COLSQL varchar(4000) 
        --Reserved/Mandatory WatchDog Variables 
 

Declare @LastLogDate datetime
Declare @UserID varchar(255)
Declare @GroupID varchar(255)
Declare @ServerTimeZone int
Declare @TripDateType varchar(255) --Can be based off ScheduledArrival, ScheduledEarliest, ScheduledLatest

Declare @ExcludeEventsForOnTime Varchar(255)
Declare @IncludeBillableEventsOnly char(1)
Declare @IncludeEventsForOnTime Varchar(255)
Declare @UseCityProfileOnlyForLatLong char(1)
Declare @IncludeBreakTimeForETACalc char(1)
Declare @ExcludeDriverStatusList varchar(255)
Declare @UseDriverLogsForHoursOfService char(1)



Set @ExcludeEventsForOnTime = 'TRP,RTP'
Set @IncludeBillableEventsOnly = 'N'




select @LastLogDate =  (Cast(Floor(Cast(getdate() as float))as smalldatetime))-1
Set @TripDateType = (select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'TripDateType')
Set @ExcludeDriverStatusList = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'ExcludeDriverStatusList'),'OUT')
Set @IncludeBillableEventsOnly = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'IncludeBillableEventsOnly'),@IncludeBillableEventsOnly)
Set @ExcludeEventsForOnTime = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'ExcludeEventsForOnTime'),@ExcludeEventsForOnTime)
Set @UseCityProfileOnlyForLatLong = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'UseCityProfileOnlyForLatLong'),'N')
Set @IncludeBreakTimeForETACalc = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'IncludeBreakTimeForETACalc'),'N')
Set @IncludeEventsForOnTime = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'IncludeEventsForOnTime'),'')
Set @UseDriverLogsForHoursOfService = IsNull((select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'UseDriverLogsForHoursOfService'),'N')



SELECT @ExcludeEventsForOnTime = ',' + LTRIM(RTRIM(ISNULL(@ExcludeEventsForOnTime, ''))) + ',' 
SELECT @IncludeEventsForOnTime = ',' + LTRIM(RTRIM(ISNULL(@IncludeEventsForOnTime, ''))) + ',' 
SELECT @ExcludeDriverStatusList = ',' + LTRIM(RTRIM(ISNULL(@ExcludeDriverStatusList, ''))) + ','
 

 
--Assume Eastern Time Zone or eventually figure it out from 
--time zone that the sql server is on as the default if the general 
--info setting doesn't exist 
Set @ServerTimeZone = cast(IsNull((select cast(dsat_value as int) from DriverAwareSuite_GeneralInfo where dsat_type = 'TimeZone' and dsat_key = 'ServerTimeZone'),6) as int)
 
 
 
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
       mpp_gps_desc as LastGPS, 
       mpp_dailyhrsest   'DailyHrsEst', --quarter hour 
       mpp_weeklyhrsest   'WeeklyHrsEst', 
       mpp_lastlog_estdate 'LastLog_EstDate', 
       mpp_lastlog_cmp_name 'LastLogCompany', 
       mpp_gps_date         'LastGPSDt', 
       mpp_mile_day7        'Miles7Day', 
       cast(NULL as datetime) expirationdate, 
       cast(NULL as varchar(100)) ExpCode, 
       mpp_gps_latitude, 
       mpp_gps_longitude 
       
      
into   #DriverList 
from   manpowerProfile (NOLOCK) 
where Mpp_id<> 'UNKNOWN' 
      and 
      mpp_status Not In ('OUT','OP','OTPR') 
order by mpp_id 
 

SELECT          DateAdd(hour,(@ServerTimeZone - IsNull(cty_GMTDelta,@ServerTimeZone)),LastGPSDt) as GPSDateTime, 
                t4.cty_nmstct as Destination, 
                Case When (t2.cmp_id In ('UNKNOWN','UNK',Null) OR comp.cmp_latseconds Is Null or @UseCityProfileOnlyForLatLong = 'Y') Then
 
                        Convert(float,ISNULL(   
                                        -- Convert values from degrees to radians 
                        ( 
                        Select 
                        Acos( 
                                cos(    ( 
                                                Convert(decimal(6,2),(convert(float,mpp_gps_latitude)/3600.0)) 
                                                * 3.14159265358979 / 180.0)  )  * 
                                cos(    (t4.cty_latitude * 3.14159265358979 / 180.0)  )  * 
                                cos (  
                                        ( 
                                                Convert(decimal(6,2),(convert(float,mpp_gps_longitude)/3600.0)) 
                                        * 3.14159265358979 / 180.0) - 
                                        (t4.cty_longitude * 3.14159265358979 / 180.0) 
                                    )   + 
                                Sin (   ( 
                                                Convert(decimal(6,2),(convert(float, mpp_gps_latitude)/3600.0)) 
                                        * 3.14159265358979 / 180.0) ) * 
                                Sin (   (t4.cty_latitude * 3.14159265358979 / 180.0) )  
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
                                cos(    ( 
                                                Convert(decimal(6,2),(convert(float,mpp_gps_latitude)/3600.0)) 
                                                * 3.14159265358979 / 180.0)  )  * 
                                cos(    ((isnull(comp.cmp_latseconds,0.0000)/3600.000) * 3.14159265358979 / 180.0)  )  *
 
                                cos (  
                                        ( 
                                                Convert(decimal(6,2),(convert(float,mpp_gps_longitude)/3600.0)) 
                                        * 3.14159265358979 / 180.0) - 
                                        ((isnull(comp.cmp_longseconds,0.0000)/3600.000) * 3.14159265358979 / 180.0) 
                                    )   + 
                                Sin (   ( 
                                                Convert(decimal(6,2),(convert(float, mpp_gps_latitude)/3600.0)) 
                                        * 3.14159265358979 / 180.0) ) * 
                                Sin (   ((isnull(comp.cmp_latseconds,0.0000)/3600.000) * 3.14159265358979 / 180.0) )    
 
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
 
 
 
--              t2.stp_arrivaldate, 
                lgh_driver1 as [Driver ID], 
            t2.stp_number, 
                lgh_driver2 as [Driver2 ID], 
                lgh_comment as ActiveTripComment, 
                OrderNumber = (select ord_number from orderheader (NOLOCK) where orderheader.ord_hdrnumber = t1.ord_hdrnumber),
 
                TeamLeader = mpp_teamleader 
                
                
        INTO #TempFinal 
        FROM    legheader_active t1 (NOLOCK) Inner Join stops t2 (NOLOCK) On t1.lgh_number = t2.lgh_number 
                                             Inner Join #DriverList t3 (NOLOCK) On t1.lgh_driver1 = t3.[DrvID] 
                                             Inner Join city t4 (NOLOCK) On t2.stp_city = t4.cty_code 
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
 
UPDATE #TempFinal SET  EstimatedMilesToGo = AirMilesToGo, --* (1 + @AirMilesAdjustmentPct), 
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
 
 
 
        UPDATE #TempFinal SET  EstimatedMilesToGo = AirMilesToGo, --* (1 + @AirMilesAdjustmentPct), 
                ETA = DATEADD(hour, (AirMilesToGo )/ 45, GPSDateTime) 
        
        
End 
 
 
 
UPDATE #TempFinal SET OrderStatus = CASE WHEN ETA > ScheduledLatest THEN 'LATE' ELSE 'On-Time' END, 
                PlusMinus = Case When EstimatedMilesToGo = 9999 Then 9999 Else -1 * (DATEDIFF(minute, ScheduledLatest, ETA) / 60.0) End
 
Select * , 
               stp_arrivaldate as NextOpenEventDate 
        into   #TempDriverOnTime 
        from #TempFinal 
        Where  stp_number = (select min(a.stp_number) from #TempFinal a where a.LegHeaderNumber = #TempFinal.LegHeaderNumber and a.stp_arrivaldate = 
 
                                                                                                                                        (select min(b.stp_arrivaldate) from #TempFinal b where b.LegHeaderNumber = #TempFinal.LegHeaderNumber))
 
                   And 
                   StartDate = (Select min(b.startdate) from #TempFinal b where b.[Driver ID] = #TempFinal.[Driver ID]) 
 
        Order By Tractor,stp_arrivaldate 
 
 
 

Select PlusMinus,OrderNumber,[Driver ID],TeamLeader,Destination as DestinationCompany 
into #TempResults 
From #TempFinal 
Where PlusMinus < 0 
 

--Commits the results to be used in the wrapper 
        If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1 
        Begin 
                Set @SQL = 'Select * from #TempResults' 
        End 
        Else 
        Begin 
                Set @COLSQL = '' 
                Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
 
                Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
 
        End 
        
        Exec (@SQL) 
        
 
 
 
 
 
 
 

GO
