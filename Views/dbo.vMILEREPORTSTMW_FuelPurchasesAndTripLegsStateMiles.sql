SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO













--select * from vMILEREPORTSTMW_FuelPurchasesAndTripLegsStateMiles where ([Arrival Date] Between '20000921' And '20000929 23:59:59') And (CHARINDEX(',' + [Leg Type] + ',' , ',City To City,') > 0)


CREATE                               View [dbo].[vMILEREPORTSTMW_FuelPurchasesAndTripLegsStateMiles] As

Select Top 100 Percent
       TempAll.*

From

(


Select 
       TempLegs.*,
       TMWStateMilesByLeg.stmlsleg_mileageinterface as MileageInterface,
       TMWStateMilesByLeg.stmlsleg_mileageinterfaceversion as MileageInterfaceVersion,
       TMWStateMilesByLeg.stmlsleg_mileagetype as MileageType,
       TMWStateMilesByLeg.stmlsleg_state as State,
       TMWStateMilesByLeg.stmlsleg_statetotalmiles as [State Total Miles],
       TMWStateMilesByLeg.stmlsleg_statetollmiles as [State Toll Miles],
       TMWStateMilesByLeg.stmlsleg_statefreemiles as [State Free Miles],
       TMWStateMilesByLeg.stmlsleg_lookupstatus as [Lookup Status],
       TMWStateMilesByLeg.stmlsleg_errdescription as [Error Description],
       0 As [Gallons Purchased],
       ' ' as [Fuel Type]
       
From

(

Select  
	stp_city as 'Origin Location',
	IsNull((select cty_name from city where a.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city where a.stp_city = cty_code),'') as 'OriginCityStateOrZip',
	TempDestination.*,
        'City To City' as [Leg Type],
	event.evt_trailer1 as [Trailer ID]
from   stops a,event,
	(
       select 
       stp_city as 'Destination Location',	
       IsNull((select cty_name from city where a.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city where a.stp_city = cty_code),'') as 'DestinationCityStateOrZip',
       convert(varchar(5),IsNull(a.stp_loadstatus,'')) as 'LoadStatus',
       case When a.stp_loadstatus = 'LD' Then 'Loaded' Else 'Empty' End As TrueLoadStatus,
       lgh_tractor as 'Tractor',
       legheader.mov_number,
       legheader.lgh_number,
       a.stp_mfh_sequence,
       a.stp_number,
       a.stp_arrivaldate as [Arrival Date],
       lgh_driver1 as [Driver ID],
       lgh_class1 as RevType1,
       lgh_class2 as RevType2,
       lgh_class3 as RevType3,
       lgh_class4 as RevType4,
       lgh_startdate as [Segment Start Date],
       lgh_enddate as [Segment End Date],
       lgh_outstatus as [Dispatch Status],
       mpp_type1 as DrvType1,
       mpp_type2 as DrvType2,
       mpp_type3 as DrvType3,
       mpp_type4 as DrvType4,
       trc_type1 as TrcType1,
       trc_type2 as TrcType2,
       trc_type3 as TrcType3,
       trc_type4 as TrcType4,
       (select ord_number from orderheader where a.ord_hdrnumber = orderheader.ord_hdrnumber) as OrderNumber 

from   legheader,stops a
where  legheader.lgh_number = a.lgh_number
       and
       legheader.lgh_outstatus = 'CMP'
       and
       (
	a.lgh_number = (select min(b.lgh_number) from legheader b where b.mov_number = a.mov_number and legheader.lgh_outstatus = 'CMP') and a.stp_mfh_sequence > (select min(b.stp_mfh_sequence) from stops b where b.lgh_number = a.lgh_number)
	 OR
	a.lgh_number > (select min(b.lgh_number) from legheader b where b.mov_number = a.mov_number and legheader.lgh_outstatus = 'CMP') and a.stp_mfh_sequence >= (select min(b.stp_mfh_sequence) from stops b where b.lgh_number = a.lgh_number)
	)
       ) as TempDestination


where  a.stp_mfh_sequence = (select max(b.stp_mfh_sequence) from stops b where b.stp_mfh_sequence < TempDestination.stp_mfh_sequence and b.mov_number = TempDestination.mov_number)
       and
       a.mov_number = TempDestination.mov_number
       and
       event.stp_number = a.stp_number
       and
       event.evt_sequence = 1
      

      
      


Union

Select  
	stp_city as 'Origin Location',
        IsNull((select cty_zip from city where a.stp_city = cty_code),'') as 'OriginCityStateOrZip',
	TempDestination.*,
        'Zip To Zip' as [Leg Type],
	event.evt_trailer1 as [Trailer ID]

from   stops a,event,
	(
       Select
       stp_city as 'Destination Location',
       IsNull((select cty_zip from city where a.stp_city = cty_code),'') as 'DestinationCityStateOrZip',
       convert(varchar(5),IsNull(a.stp_loadstatus,'')) as 'LoadStatus',
       case When a.stp_loadstatus = 'LD' Then 'Loaded' Else 'Empty' End As TrueLoadStatus,
       lgh_tractor as 'Tractor',
       legheader.mov_number,
       legheader.lgh_number,
       a.stp_mfh_sequence,
       a.stp_number,
       a.stp_arrivaldate as [Arrival Date],
       lgh_driver1 as [Driver ID],
       lgh_class1 as RevType1,
       lgh_class2 as RevType2,
       lgh_class3 as RevType3,
       lgh_class4 as RevType4,
       lgh_startdate as [Segment Start Date],
       lgh_enddate as [Segment End Date],
       lgh_outstatus as [Dispatch Status],
       mpp_type1 as DrvType1,
       mpp_type2 as DrvType2,
       mpp_type3 as DrvType3,
       mpp_type4 as DrvType4,
       trc_type1 as TrcType1,
       trc_type2 as TrcType2,
       trc_type3 as TrcType3,
       trc_type4 as TrcType4,
       (select ord_number from orderheader where a.ord_hdrnumber = orderheader.ord_hdrnumber) as OrderNumber 

from   legheader,stops a
where  legheader.lgh_number = a.lgh_number
       and
       legheader.lgh_outstatus = 'CMP'
       and
       (
	a.lgh_number = (select min(b.lgh_number) from legheader b where b.mov_number = a.mov_number and legheader.lgh_outstatus = 'CMP') and a.stp_mfh_sequence > (select min(b.stp_mfh_sequence) from stops b where b.lgh_number = a.lgh_number)
	 OR
	a.lgh_number > (select min(b.lgh_number) from legheader b where b.mov_number = a.mov_number and legheader.lgh_outstatus = 'CMP') and a.stp_mfh_sequence >= (select min(b.stp_mfh_sequence) from stops b where b.lgh_number = a.lgh_number)
	)
       ) as TempDestination


where  a.stp_mfh_sequence = (select max(b.stp_mfh_sequence) from stops b where b.stp_mfh_sequence < TempDestination.stp_mfh_sequence and b.mov_number = TempDestination.mov_number)
       and
       a.mov_number = TempDestination.mov_number
       And
       event.stp_number = a.stp_number
       and
       event.evt_sequence = 1
      

) As TempLegs,TMWStateMilesByLeg

Where TempLegs.[Origin Location] = TMWStateMilesByLeg.stmlsleg_originlocation
      And
      TempLegs.[Destination Location] = TMWStateMilesByLeg.stmlsleg_destinationlocation
      And
      TempLegs.[Leg Type] = TMWStateMilesByLeg.stmlsleg_legtype
       
  
Union

Select  top 100 percent       
        '' as 'Origin Location',
        '' as 'OriginCityStateOrZip',
	 0 as 'Destination Location',
       '' as 'DestinationCityStateOrZip',
       '' as 'LoadStatus',
       '' As TrueLoadStatus,
       trc_number as 'Tractor',
       mov_number,
       lgh_number,
       NULL as stp_mfh_sequence,
       stp_number,
       fp_date as [Arrival Date],
       '' as [Driver ID],
       '' as RevType1,
       '' as RevType2,
       '' as RevType3,
       '' as RevType4,
       fp_date as [Segment Start Date],
       fp_date as [Segment End Date],
       '' as [Dispatch Status],
       '' as DrvType1,
       '' as DrvType2,
       '' as DrvType3,
       '' as DrvType4,
       '' as TrcType1,
       '' as TrcType2,
       '' as TrcType3,
       '' as TrcType4,
       ord_number as OrderNumber,
       'City To City' as [Leg Type],
       '' as [Trailer ID],
       'FUELPURCHASE' as  MileageInterface,
       -1 as MileageInterfaceVersion,
       'FUELPURCHASE' as MileageType,
       fp_state as State,
       0 as [State Total Miles],
       NULL as [State Toll Miles],
       NULL as [State Free Miles],
       '' as [Lookup Status],
       '' as [Error Description],
       Case When fp_uom <> 'GAL' Then
		round(cast(fp_quantity * (select unc_factor from unitconversion (NOLOCK) where unc_from = fp_uom and unc_to = 'GAL' and unc_convflag = 'Q') as float),2)
       Else
		round(cast(fp_quantity as float),2)
       End as [Gallons Purchased],
       fp_fueltype as [Fuel Type]
	--fp_quantity as [Gallons Purchased]


From fuelpurchased (NOLOCK)      

Union 

Select  top 100 percent       
        '' as 'Origin Location',
        '' as 'OriginCityStateOrZip',
	 0 as 'Destination Location',
       '' as 'DestinationCityStateOrZip',
       '' as 'LoadStatus',
       '' As TrueLoadStatus,
       trc_number as 'Tractor',
       mov_number,
       lgh_number,
       NULL as stp_mfh_sequence,
       stp_number,
       fp_date as [Arrival Date],
       '' as [Driver ID],
       '' as RevType1,
       '' as RevType2,
       '' as RevType3,
       '' as RevType4,
       fp_date as [Segment Start Date],
       fp_date as [Segment End Date],
       '' as [Dispatch Status],
       '' as DrvType1,
       '' as DrvType2,
       '' as DrvType3,
       '' as DrvType4,
       '' as TrcType1,
       '' as TrcType2,
       '' as TrcType3,
       '' as TrcType4,
       ord_number as OrderNumber,
       'Zip To Zip' as [Leg Type],
       '' as [Trailer ID],
       'FUELPURCHASE' as  MileageInterface,
       -1 as MileageInterfaceVersion,
       'FUELPURCHASE' as MileageType,
       fp_state as State,
       0 as [State Total Miles],
       NULL as [State Toll Miles],
       NULL as [State Free Miles],
       '' as [Lookup Status],
       '' as [Error Description],
       Case When fp_uom <> 'GAL' Then
		round(cast(fp_quantity * (select unc_factor from unitconversion (NOLOCK) where unc_from = fp_uom and unc_to = 'GAL' and unc_convflag = 'Q') as float),2)
       Else
		round(cast(fp_quantity as float),2)
       End as [Gallons Purchased],
       fp_fueltype as [Fuel Type]
	--fp_quantity as [Gallons Purchased]


From fuelpurchased (NOLOCK)  
) as TempAll
order by [Leg Type],mov_number,lgh_number,stp_mfh_sequence 




































GO
GRANT SELECT ON  [dbo].[vMILEREPORTSTMW_FuelPurchasesAndTripLegsStateMiles] TO [public]
GO
