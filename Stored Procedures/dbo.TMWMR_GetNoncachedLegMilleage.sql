SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO










--Exec TMWMR_GetNoncachedLegMilleage '([Tractor] <> ''UNK'') And ([Tractor] <> ''UNKNOWN'') And ([Segment Start Date] Between ''20041001'' And ''20041002 23:59:59'') And [Leg Type] = ''City To City''' 


CREATE     Procedure [dbo].[TMWMR_GetNoncachedLegMilleage] (@RestrictionSQL varchar(4000),@MileageInterface varchar(150),@MileageInterfaceVersion varchar(150),@MileageType varchar(150))

As

Declare @SQL varchar(8000)


Create Table #TempMILEREPORTSTMW_TripLegs
([Origin Location] int Not Null,
 [Origin Company ID] varchar(255) Not Null,
 [OriginCityStateOrZip] varchar(255) Not Null,
 [OriginState] varchar(255) Not Null,
 [Destination Location] int Not Null,
 [Destination Company ID] varchar(255) Not Null,
 [DestinationCityStateOrZip] varchar(255) Not Null,
 [LoadStatus] varchar(255) Null,
 [TrueLoadStatus] varchar(255) Null,
 [Tractor] varchar(255) Null,
 mov_number int Null,
 lgh_number int Not Null,
 stp_mfh_sequence int Null,
 stp_number int Not Null,
 [Arrival Date] datetime NULL,
 [Driver ID] varchar(255) Null,
 [RevType1] varchar(255) Null,
 [RevType2] varchar(255) Null,
 [RevType3] varchar(255) Null,
 RevType4 varchar(255) Null,
 [DrvType1] varchar(255) Null,
 [DrvType2] varchar(255) Null,
 [DrvType3] varchar(255) Null,
 DrvType4 varchar(255) Null,
 [OrderNumber] char(255) Null,
 [Segment Start Date] datetime Null,
 [Segment End Date] datetime Null,
 [Dispatch Status] varchar(255) Null,
 [TrcType1] varchar(255) Null,
 [TrcType2] varchar(255) Null,
 [TrcType3] varchar(255) Null,
 [TrcType4] varchar(255) Null,
 [Bill Date] datetime NULL,
 [Transfer Date] datetime NULL,
 [Total Miles] float Null,
 [Toll Miles] float Null,
 [Non Toll Miles] float Null,
 [Unreach Miles] float Null,
 State varchar(255) Null,
 [Leg Type] varchar(255) Not Null,
 [Trailer ID] varchar(255) Null,
 [Fuel Type] varchar(255) Null
 )



Set @SQL = 'Insert into #TempMILEREPORTSTMW_TripLegs' +
	   ' Select * ' + 
	   ' from vMILEREPORTSTMW_TripLegs' + 
	   ' Where' + 
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
vMILEREPORTSTMW_TripLegs.[DestinationCityStateOrZip] 

from #TempMILEREPORTSTMW_TripLegs vMILEREPORTSTMW_TripLegs Left Join TMWStateMilesByLeg On  
vMILEREPORTSTMW_TripLegs.[Origin Location] = TMWStateMilesByLeg.[stmlsleg_originlocation] 
And vMILEREPORTSTMW_TripLegs.[Destination Location] = TMWStateMilesByLeg.[stmlsleg_destinationlocation] 
And vMILEREPORTSTMW_TripLegs.[Leg Type] = TMWStateMilesByLeg.[stmlsleg_legtype] 
AND TMWStateMilesByLeg.stmlsleg_mileageinterface = @MileageInterface
And TMWStateMilesByLeg.stmlsleg_mileageinterfaceversion = @MileageInterfaceVersion
And TMWStateMilesByLeg.stmlsleg_mileagetype = @MileageType 
Where

(TMWStateMilesByLeg.stmlsleg_originlocation Is Null)












GO
GRANT EXECUTE ON  [dbo].[TMWMR_GetNoncachedLegMilleage] TO [public]
GO
