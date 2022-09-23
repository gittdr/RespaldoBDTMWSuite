SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--Exec TMWMR_GetLGHLegNoncachedMilleage '([Tractor] <> ''UNK'') And ([Tractor] <> ''UNKNOWN'') And ([Segment Start Date] Between ''20080701'' And ''20080706 23:59:59'') And [Leg Type] = ''City To City''' ,'','',''

CREATE          Procedure [dbo].[TMWMR_GetLGHLegNoncachedMilleage] (@RestrictionSQL varchar(4000),@MileageInterface varchar(150),@MileageInterfaceVersion varchar(150),@MileageType varchar(150))

As

Declare @SQL varchar(8000)
Declare @IncludeFuelStopsInRoute char(1)
Declare @TableName varchar(255)

Create Table #TempMILEREPORTSTMW_TripLegs
(
[Origin Location] int Not Null,
[OriginCityStateOrZip] varchar(255) Not Null,
OriginState varchar(255) Not Null,
[Destination Location] int Not Null,
DestinationCityStateOrZip varchar(255) Not Null,
[Leg Type] varchar(255) Not Null,
[lgh_number] int Not Null,
[stp_number] int Not Null

)


Set @IncludeFuelStopsInRoute = IsNull((select gi_value from MR_GeneralInfo WITH (NOLOCK) where gi_key = 'IncludeFuelStopsInRouteYN'),'N')


If @IncludeFuelStopsInRoute = 'Y'
Begin
	Set @TableName = 'vMILEREPORTSTMW_TripLegsIncludingFuelStops'


End
Else
Begin
	Set @TableName = 'vMILEREPORTSTMW_TripLegs'
End


Set @SQL = 'Insert into #TempMILEREPORTSTMW_TripLegs' +
	   ' Select [Origin Location],
		        [OriginCityStateOrZip],
                OriginState,
                [Destination Location],
                DestinationCityStateOrZip,
				[Leg Type],
				lgh_number,
				stp_number' + 
	   ' from ' + @TableName + 
	   ' Where ' + 
 	   @RestrictionSQL



Exec (@SQL)

--([Tractor] <> 'UNK') And ([Tractor] <> 'UNKNOWN') 
--And
--([Segment Start Date] Between @BeginDate And @EndDate) 
--And
--[Leg Type] = 'City To City'-- And 


Select distinct vMILEREPORTSTMW_TripLegs.[Origin Location],
vMILEREPORTSTMW_TripLegs.[OriginCityStateOrZip],
vMILEREPORTSTMW_TripLegs.[OriginState],vMILEREPORTSTMW_TripLegs.[Destination Location],
vMILEREPORTSTMW_TripLegs.[DestinationCityStateOrZip],
vMILEREPORTSTMW_TripLegs.[stp_number],
vMILEREPORTSTMW_TripLegs.[lgh_number]

from #TempMILEREPORTSTMW_TripLegs vMILEREPORTSTMW_TripLegs Left Join TMWStateMilesByLGHLeg On  
--vMILEREPORTSTMW_TripLegs.[Origin Location] = TMWStateMilesByLGHLeg.[stmlsleg_originlocation] 
--And vMILEREPORTSTMW_TripLegs.[Destination Location] = TMWStateMilesByLGHLeg.[stmlsleg_destinationlocation] 
vMILEREPORTSTMW_TripLegs.[Leg Type] = TMWStateMilesByLGHLeg.[stmlsleg_legtype] 
AND vMILEREPORTSTMW_TripLegs.[stp_number] = TMWStateMilesByLGHLeg.[stmlsleg_endstopnumber] 
And vMILEREPORTSTMW_TripLegs.[lgh_number] = TMWStateMilesByLGHLeg.[stmlsleg_lghnumber] 
AND TMWStateMilesByLGHLeg.stmlsleg_mileageinterface = @MileageInterface
And TMWStateMilesByLGHLeg.stmlsleg_mileageinterfaceversion = @MileageInterfaceVersion
And TMWStateMilesByLGHLeg.stmlsleg_mileagetype = @MileageType 

Where

(TMWStateMilesByLGHLeg.stmlsleg_originlocation Is Null)









GO
GRANT EXECUTE ON  [dbo].[TMWMR_GetLGHLegNoncachedMilleage] TO [public]
GO
