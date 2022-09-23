SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


























CREATE                    View [dbo].[vMILEREPORTSTMW_TripLegs] As

Select Top 100 Percent
       TempLegs.*

From

(

Select  
	stp_city as 'Origin Location',
	cmp_id as [Origin Company ID], 
	IsNull((select cty_name from city where a.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city where a.stp_city = cty_code),'') as 'OriginCityStateOrZip',
	IsNull((select cty_state from city where a.stp_city = cty_code),'') as 'OriginState',
	TempDestination.*,
        convert(float,0) as 'Total Miles',
        convert(float,0) as 'Toll Miles',
        convert(float,0) as 'Non Toll Miles',
        convert(float,0) as 'Unreach Miles',
	convert(varchar(20),'') as State,
	'City To City' as [Leg Type],
	event.evt_trailer1 as [Trailer ID],
	'' as [Fuel Type]
from   stops a,event,
	(
       select 
       stp_city as 'Destination Location',
       cmp_id as [Destination Company ID], 	
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
       mpp_type1 as DrvType1,
       mpp_type2 as DrvType2,
       mpp_type3 as DrvType3,
       mpp_type4 as DrvType4,
       (select ord_number from orderheader where a.ord_hdrnumber = orderheader.ord_hdrnumber) as OrderNumber,
       lgh_startdate as [Segment Start Date],
       lgh_enddate as [Segment End Date],
       lgh_outstatus as [Dispatch Status],
       trc_type1 as TrcType1,
       trc_type2 as TrcType2,
       trc_type3 as TrcType3,
       trc_type4 as TrcType4,
       (select min(ivh_billdate) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber =a.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Bill Date',
       (select min(ivh_xferdate) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = a.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Transfer Date'
       

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
       a.stp_number = event.stp_number
       and
       event.evt_sequence = 1
      
      

      
      


Union

Select  
	stp_city as 'Origin Location',
	cmp_id as [Origin Company ID],
        IsNull((select cty_zip from city where a.stp_city = cty_code),'') as 'OriginCityStateOrZip',
	IsNull((select cty_state from city where a.stp_city = cty_code),'') as 'OriginState',
	TempDestination.*,
        convert(float,0) as 'Total Miles',
        convert(float,0) as 'Toll Miles',
        convert(float,0) as 'Non Toll Miles',
        convert(float,0) as 'Unreach Miles',
	convert(varchar(20),'') as State,
	'Zip To Zip' as [Leg Type],
	event.evt_trailer1 as [Trailer ID],
	'' as [Fuel Type]
	
from   stops a,event,
	(
       Select
       stp_city as 'Destination Location',
       cmp_id as [Destination Company ID],
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
       mpp_type1 as DrvType1,
       mpp_type2 as DrvType2,
       mpp_type3 as DrvType3,
       mpp_type4 as DrvType4,
       (select ord_number from orderheader where a.ord_hdrnumber = orderheader.ord_hdrnumber) as OrderNumber,
       lgh_startdate as [Segment Start Date],
       lgh_enddate as [Segment End Date],
       lgh_outstatus as [Dispatch Status],
       trc_type1 as TrcType1,
       trc_type2 as TrcType2,
       trc_type3 as TrcType3,
       trc_type4 as TrcType4,
       (select min(ivh_billdate) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber =a.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Bill Date',
       (select min(ivh_xferdate) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = a.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Transfer Date'
       

       

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
       a.stp_number = event.stp_number
       and
       event.evt_sequence = 1
      

) As TempLegs
  
order by [Leg Type],mov_number,lgh_number,stp_mfh_sequence    
              
              

--Top 100 Percent
--



























GO
GRANT SELECT ON  [dbo].[vMILEREPORTSTMW_TripLegs] TO [public]
GO
