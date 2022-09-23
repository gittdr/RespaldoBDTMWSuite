SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO













--dbo.DriverAwareSuite_GetLoads  '5/1/2001','5/1/2002','','','','','','','','','','','','Y'
CREATE                        Proc [dbo].[DriverAwareSuite_GetLoads] 
        ( 
        @LowDt  datetime, 
        @HighDt         datetime, 
        @OnlyDriverTypes1       varchar(255) ='', 
        @OnlyDriverTypes2       varchar(255) ='', 
        @OnlyDriverTypes3       varchar(255)='', 
        @OnlyDriverTypes4       varchar(255)='', 
        @OnlyDriverTeamLeaders  varchar(255)='', 
        @OnlyDriverTerminals    varchar(255)='', 
        @onlyCompletedStatuses  Varchar(255)='', 
        @onlyPriorityCodes      Varchar(255)='', 
        @onlyExpCodes           Varchar(255)='', 
        @OnlyDriverIDs          varchar(4000)='', 
        @ExcludeExpCodes        varchar(255)='',
	@ExcludeBobTailSameLocationEmptyMoves char(1) = 'Y'         
        ) 
AS 
Declare @TripDateType varchar(150)
Declare @ServerTimeZone varchar(150)
Declare @EnableCustomBarText char(1)
Declare @IncludeEventsForDisplay varchar(255)

Set @TripDateType = (select dsat_value from DriverAwareSuite_generalinfo where dsat_key = 'TripDateType')

--Assume Eastern Time Zone or eventually figure it out from 
--time zone that the sql server is on as the default if the general
--info setting doesn't exist
Set @ServerTimeZone = cast(IsNull((select cast(dsat_value as int) from DriverAwareSuite_GeneralInfo where dsat_type = 'TimeZone' and dsat_key = 'ServerTimeZone'),6) as int)
Set @EnableCustomBarText = IsNull((select dsat_value  from DriverAwareSuite_GeneralInfo where dsat_type = 'EnableCustomBarText' and dsat_key = 'EnableCustomBarText'),'N')
Set @IncludeEventsForDisplay = IsNull((select dsat_value  from DriverAwareSuite_GeneralInfo where dsat_type = 'IncludeEventCodesForDisplay' and dsat_key = 'IncludeEventCodesForDisplay'),'')

Set @OnlyDriverTypes1= ',' + ISNULL(rtrim(@OnlyDriverTypes1),'') + ',' 
Set @OnlyDriverTypes2= ',' + ISNULL(rtrim(@OnlyDriverTypes2),'') + ',' 
Set @OnlyDriverTypes3= ',' + ISNULL(rtrim(@OnlyDriverTypes3),'') + ',' 
Set @OnlyDriverTypes4= ',' + ISNULL(rtrim(@OnlyDriverTypes4),'') + ',' 

Set @OnlyDriverTeamLeaders= ',' + ISNULL(rtrim(@OnlyDriverTeamLeaders),'') + ',' 
Set @OnlyDriverTerminals= ',' + ISNULL(rtrim(@OnlyDriverTerminals),'') + ',' 
Set @onlyCompletedStatuses = ',' + ISNULL(rtrim(@onlyCompletedStatuses),'') + ',' 
Set @onlyPriorityCodes = ',' + ISNULL(rtrim(@onlyPriorityCodes),'') + ',' 
Set @onlyExpCodes = ',' + ISNULL(rtrim(@onlyExpCodes),'') + ',' 
Set @OnlyDriverIDs = ',' + ISNULL(rtrim(@OnlyDriverIDs),'') + ',' 
Set @ExcludeExpCodes = ',' + ISNULL(rtrim(@ExcludeExpCodes),'') + ',' 
Set @IncludeEventsForDisplay = ',' + ISNULL(rtrim(@IncludeEventsForDisplay),'') + ',' 

        
Select 
        Lgh_number, 
        lgh_driver1 DriverID, 
	Lgh_startdate = Case When @TripDateType = 'Earliest' Then
			  Case When lgh_outstatus = 'CMP' or lgh_outstatus = 'STD' Then
				Case When @IncludeEventsForDisplay <> ',,' Then
					IsNull((select min(b.stp_arrivaldate) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_startdate)
				Else
					lgh_startdate --Use The Actual
				End
                          Else
				Case When @IncludeEventsForDisplay <> ',,' Then
					IsNull((select min(b.stp_schdtearliest) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_schdtearliest)
				Else
					lgh_schdtearliest --Use the Estimated
				End	   	
		

				
			  End
		     	When @TripDateType = 'Latest' Then
			  Case When lgh_outstatus = 'CMP' or lgh_outstatus = 'STD' Then
				Case When @IncludeEventsForDisplay <> ',,' Then
					IsNull((select min(b.stp_arrivaldate) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_startdate)
				Else
					lgh_startdate --Use The Actual
				End
		     	  Else
				Case When @IncludeEventsForDisplay <> ',,' Then
					IsNull((select min(b.stp_schdtlatest) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_schdtlatest)
				Else
					lgh_schdtlatest --Use the Estimated
				End	   					

				
			  End
		        Else
			 	Case When @IncludeEventsForDisplay <> ',,' Then
					IsNull((select min(b.stp_arrivaldate) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_startdate)
				Else
					lgh_startdate --Use The Actual
				End
		        End,



        lgh_enddate  = Case When @TripDateType = 'Earliest' Then
			  Case When lgh_outstatus = 'CMP' Then
				Case When @IncludeEventsForDisplay <> ',,' Then
					IsNull((select max(b.stp_arrivaldate) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_enddate)
				Else
					lgh_enddate --Use The Actual
				End
                          Else
				Case When @IncludeEventsForDisplay <> ',,' Then
					IsNull((select max(b.stp_arrivaldate) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_enddate)
				Else
			   		(select stp_schdtearliest from stops (NOLOCK) where legheader.stp_number_end = stops.stp_number) --Use the Estimated
				End
			  End
		     	When @TripDateType = 'Latest' Then
			  Case When lgh_outstatus = 'CMP' Then
				Case When @IncludeEventsForDisplay <> ',,' Then
					IsNull((select max(b.stp_arrivaldate) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_enddate)
				Else
					lgh_enddate --Use The Actual
				End
		     	  Else
				Case When @IncludeEventsForDisplay <> ',,' Then
					IsNull((select max(b.stp_schdtlatest) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_enddate)
				Else
					(select stp_schdtlatest from stops (NOLOCK) where legheader.stp_number_end = stops.stp_number) --Use the Estimated
	
				End
			  End
		         Else
			        lgh_enddate --Use the actual
		         End,

        TripID =CASE WHEN ISNULL(Ord_hdrnumber,0) =0 THEN '[' +convert(varchar(8),mov_number)+ ']' 
                ELSE convert(varchar(8), Ord_hdrnumber) END, 
        RouteInfo60 =' ',--Left(dbo.fnc_StopsListForLghNumberShort(lgh_number,5,60,'N','Y'),60), 
        IsTeam =Case when lgh_driver2 <>'UNKNOWN' then 'TEAM' ELSE 'SOLO' END, 
        lgh_outstatus Status, 
        Case When IsNull(lgh_tm_status,'') IN ('READ','OK','ERROR') Then 'READ' Else IsNull(lgh_tm_status,'unsent') End lgh_tm_status,
        RouteInfo200 =' ',--Left(dbo.fnc_StopsListForLghNumberShort(lgh_number,15,200,'Y','Y'),200), 
        

	
	NonCompletedTripStatus=	Case When DateAdd(hour,(@ServerTimeZone - IsNull((select cty_GMTDelta from city (NOLOCK) where lgh_endcity = cty_code),@ServerTimeZone)),GetDate())
				     > --greater then	
				     Case When @TripDateType = 'Earliest' Then 
					Case When @IncludeEventsForDisplay <> ',,' Then
						IsNull((select max(b.stp_arrivaldate) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_enddate)
					Else
			   			(select stp_schdtearliest from stops (NOLOCK) where legheader.stp_number_end = stops.stp_number) --Use the Estimated
					End
			     
				     When @TripDateType = 'Latest' Then
					Case When @IncludeEventsForDisplay <> ',,' Then
						IsNull((select max(b.stp_schdtlatest) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_enddate)
					Else
						(select stp_schdtlatest from stops (NOLOCK) where legheader.stp_number_end = stops.stp_number) --Use the Estimated
	
					End

			      	     Else
				   	 Case When @IncludeEventsForDisplay <> ',,' Then
						IsNull((select max(b.stp_arrivaldate) from stops b (NOLOCK) where b.lgh_number = LegHeader.lgh_number AND (@IncludeEventsForDisplay =',,' or CHARINDEX(',' + RTrim(IsNull(b.stp_event,'')) + ',', @IncludeEventsForDisplay) >0)),lgh_enddate)
					 Else
						lgh_enddate --Use The Actual
					 End
			      	     End		
					
				     and lgh_outstatus Not In ('CAN','CMP') Then 'Late' 
				Else 
					'NA' 
				End,
        ord_hdrnumber, 
        mov_number, 
        TipText = 'Driver: ' + lgh_driver1 + ' ' + Case When ord_hdrnumber = 0 Then ' Move: ' + cast(mov_number as varchar(25)) Else ' Order: ' + cast(ord_hdrnumber as varchar(25)) End,
	BarText = cast(NULL as varchar(255))
into #LegHeader
from Legheader (NOLOCK) 
where 
	lgh_startdate< DateAdd(day,1,@HighDt)  and
		lgh_enddate>=@LowDt 
        And lgh_driver1<>'UNKNOWN' 
        AND lgh_outstatus <>'CAN' 
        AND (@OnlyDriverTypes1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @OnlyDriverTypes1) >0) 
        AND (@OnlyDriverTypes2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @OnlyDriverTypes2) >0) 
        AND (@OnlyDriverTypes3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @OnlyDriverTypes3) >0) 
        AND (@OnlyDriverTypes4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @OnlyDriverTypes4) >0) 
        AND (@OnlyDriverTeamLeaders =',,' or CHARINDEX(',' + mpp_teamleader + ',', @OnlyDriverTeamLeaders) >0) 
        AND (@OnlyDriverTerminals =',,' or CHARINDEX(',' + mpp_terminal + ',', @OnlyDriverTerminals) >0) 
        --AND (@onlyCompletedStatuses =',,' or CHARINDEX(',' + exp_completed + ',', @onlyCompletedStatuses) >0) 
        --AND (@onlyPriorityCodes =',,' or CHARINDEX(',' + exp_priority + ',', @onlyPriorityCodes) >0) 
        --AND (@onlyExpCodes =',,' or CHARINDEX(',' + exp_code + ',', @onlyExpCodes) >0) 
        AND (@OnlyDriverIDs =',,' or CHARINDEX(',' + lgh_driver1 + ',', @OnlyDriverIDs) >0) 
    	AND Legheader.mov_number Is Not Null
	--AND IsNull((select count(*) from stops (NOLOCK) 
		--	Where stops.lgh_number = legheader.lgh_number and cmp_id_start = cmp_id_end and legheader.ord_hdrnumber=0 
		--),0) <> 2
    

If @EnableCustomBarText = 'Y'
Begin

Create Table #BarText(lgh_number int,[BarText] varchar(255))

Declare @ObjectName varchar(255)
Declare @SQL varchar(1000)
Declare @FieldName varchar(255)
Declare @FieldID int
Declare @PresName varchar(255)
Declare @Feature varchar(255)

Set @Feature = 'LoadBarText'

Set @ObjectName = (select top 1 ObjectName from DriverAwareSuite_LabelText where Feature = @Feature)

Create Table #Labels

( FieldID int identity,
  FieldName varchar(255),
  [PresName] varchar (255),
  [SortOrder] int
)


Insert into #Labels (FieldName,PresName,SortOrder)
select FieldName,
       PresName,
       SortOrder
From   DriverAwareSuite_LabelText
Where  Feature = @Feature
Order By SortOrder


--select * from #Labels

Set @FieldID = (select min(FieldID) from #Labels)

Set @SQL = 'Select [Leg Header Number], '

While @FieldID Is Not Null
Begin
	Set @FieldName = (select top 1 FieldName from #Labels where FieldID = @FieldID)
	Set @PresName = (select top 1 PresName from #Labels where FieldID = @FieldID)

	Set @SQL = @SQL + case when Len(@PresName) > 0 Then @PresName + ': ' + 'IsNull(cast(' + '[' + @FieldName + ']' + ' as varchar(255)),'  + '''' + '''' + ')' + ' ' Else 'IsNull(cast(' + '[' + @FieldName + ']' + ' as varchar(255)),'  + '''' + '''' + ')' + ' + ' End 

	Set @FieldID = (select min(FieldID) from #Labels where FieldID > @FieldID)

End

Set @SQL = Left(@SQL,Len(@SQL)-2)

Set @SQL = @SQL + ' From ' + @ObjectName + ' Where [Leg Header Number] In (select lgh_number from #LegHeader)'

--print @SQL

Insert into #BarText(lgh_number,BarText)
Exec (@SQL)

--select * from #BarText

Update #LegHeader Set BarText = (select BarText from #BarText where #BarText.lgh_number = #LegHeader.lgh_number)
End


select * from  #LegHeader



































GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetLoads] TO [public]
GO
