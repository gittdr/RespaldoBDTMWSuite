SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



--select top 500 * from vMILEREPORTSTMW_FuelPurchasesAndLegMiles
CREATE                         View [dbo].[vMILEREPORTSTMW_FuelPurchasesAndLegMiles] As

Select Top 100 Percent
       TempAll.*

From

(


Select 
       TempLegs.*,
       0 As [Gallons Purchased],
       0 as FuelCost
       
From

(

Select  
	stp_city as 'Origin Location',
	IsNull((select cty_name from city where a.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city where a.stp_city = cty_code),'') as 'OriginCityStateOrZip',
	TempDestination.*,
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
       (select ord_number from orderheader where a.ord_hdrnumber = orderheader.ord_hdrnumber) as OrderNumber,
       Case When a.stp_loadstatus = 'LD' Then IsNull(a.stp_lgh_mileage,0) Else 0 End as [Loaded Miles],
       Case When a.stp_loadstatus <> 'LD' Then IsNull(a.stp_lgh_mileage,0) Else 0 End as [Empty Miles],
       IsNull(a.stp_lgh_mileage,0) as [Total Miles]

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
      

      
) As TempLegs


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
       mpp_id as [Driver ID],
       '' as RevType1,
       '' as RevType2,
       '' as RevType3,
       '' as RevType4,
       fp_date as [Segment Start Date],
       fp_date as [Segment End Date],
       '' as [Dispatch Status],
       (select mpp_type1 from manpowerprofile where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType1,
       (select mpp_type2 from manpowerprofile where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType2,
       (select mpp_type3 from manpowerprofile where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType3,
       (select mpp_type4 from manpowerprofile where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType4,
       '' as TrcType1,
       '' as TrcType2,
       '' as TrcType3,
       '' as TrcType4,
       ord_number as OrderNumber,
       0 as [Loaded Miles],
       0 as [Empty Miles],
       0 as [Total Miles],
       '' as [Trailer ID],
       fp_quantity as [Gallons Purchased],
       fp_amount as FuelCost

From fuelpurchased (NOLOCK)      
) as TempAll
order by mov_number,lgh_number,stp_mfh_sequence 


























GO
GRANT SELECT ON  [dbo].[vMILEREPORTSTMW_FuelPurchasesAndLegMiles] TO [public]
GO
