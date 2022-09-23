SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE          Procedure [dbo].[TMWMR_GetUniqueFuelStopCities] (@RestrictionSQL varchar(4000),@MileageInterface varchar(150),@MileageInterfaceVersion varchar(150),@MileageType varchar(150))

As
Declare @SQL varchar(8000)
Declare @IncludeFuelStopsInRoute char(1)
Declare @TableName varchar(255)

Create Table #TempMILEREPORTSTMW_FuelStops
([Location] int Not Null,
 --[Origin Company ID] varchar(255) Null,
 CityStateOrZip varchar(255) Not Null,
 --[OriginState] varchar(255) Not Null,
 --[Destination Location] int Not Null,
 --[Destination Company ID] varchar(255) Null,
 --[DestinationCityStateOrZip] varchar(255) Not Null,
 --[LoadStatus] varchar(255) Null,
 --[TrueLoadStatus] varchar(255) Null,
 --[Tractor] varchar(255) Null,
 --mov_number int Null,
 --lgh_number int Not Null,
 --stp_mfh_sequence int Null,
 --stp_number int Not Null,
 --[Arrival Date] datetime NULL,
 --[Driver ID] varchar(255) Null,
 --[RevType1] varchar(255) Null,
 --[RevType2] varchar(255) Null,
 --[RevType3] varchar(255) Null,
 --RevType4 varchar(255) Null,
 --[DrvType1] varchar(255) Null,
 --[DrvType2] varchar(255) Null,
 --[DrvType3] varchar(255) Null,
 --DrvType4 varchar(255) Null,
 --[OrderNumber] char(255) Null,
 --[Segment Start Date] datetime Null,
 --[Segment End Date] datetime Null,
 --[Dispatch Status] varchar(255) Null,
 --[TrcType1] varchar(255) Null,
 --[TrcType2] varchar(255) Null,
 --[TrcType3] varchar(255) Null,
 --[TrcType4] varchar(255) Null,
 --[Bill Date] datetime NULL,
 --[Transfer Date] datetime NULL,
 --[Total Miles] float Null,
 --[Toll Miles] float Null,
 --[Non Toll Miles] float Null,
 --[Unreach Miles] float Null,
 --State varchar(255) Null,
 --[Leg Type] varchar(255) Not Null,
 --[Trailer ID] varchar(255) Null,
 --[Fuel Type] varchar(255) Null
 )



Set @SQL = 'Insert into #TempMILEREPORTSTMW_FuelStops (Location,CityStateOrZip)' +
	   ' Select [Origin Location],[OriginCityStateOrZip] ' + 
	   ' from vMILEREPORTSTMW_FuelStops ' + 
	   ' Where' + 
 	   @RestrictionSQL



Exec (@SQL)


Select Distinct [Location],CityStateOrZip
from #TempMILEREPORTSTMW_FuelStops




GO
GRANT EXECUTE ON  [dbo].[TMWMR_GetUniqueFuelStopCities] TO [public]
GO
