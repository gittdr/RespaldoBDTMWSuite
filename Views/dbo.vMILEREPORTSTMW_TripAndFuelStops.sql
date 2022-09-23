SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   View [dbo].[vMILEREPORTSTMW_TripAndFuelStops]

As
Select
       stp_city as 'Location',
       IsNull((select cty_name from city WITH (NOLOCK) where a.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city WITH (NOLOCK) where a.stp_city = cty_code),'') as 'CityStateOrZip',
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
       trc_type1 as TrcType1,
       trc_type2 as TrcType2,
       trc_type3 as TrcType3,
       trc_type4 as TrcType4,
       (select ord_number from orderheader WITH (NOLOCK) where a.ord_hdrnumber = orderheader.ord_hdrnumber) as OrderNumber,
       lgh_startdate as [Segment Start Date],
       lgh_enddate as [Segment End Date],
       lgh_outstatus as [Dispatch Status],
       0 as [Gallons Purchased],
       0 as FuelCost,
       Null as [Fuel Purchase Date Only]
       
       

--into   #TempStops
from   legheader WITH (NOLOCK),stops a WITH (NOLOCK)
where  legheader.lgh_number = a.lgh_number
       and
       legheader.lgh_outstatus = 'CMP'

Union All

--Insert into #TempStops
Select fp_city as 'Location',
       IsNull((select cty_name from city WITH (NOLOCK) where fp_city = cty_code),'') + ', ' + IsNull((select cty_state from city WITH (NOLOCK) where fp_city = cty_code),'') as 'CityStateOrZip',
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
       (select mpp_type1 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType1,
       (select mpp_type2 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType2,
       (select mpp_type3 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType3,
       (select mpp_type4 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType4,
       (select top 1 trc_type1 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType1,
       (select top 1 trc_type2 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType2,
       (select top 1 trc_type3 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType3,
       (select top 1 trc_type4 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType4,
       ord_number as OrderNumber,
       fp_date as [Segment Start Date],
       fp_date as [Segment End Date],
       'CMP' as [Dispatch Status],
       fp_quantity as [Gallons Purchased],
       fp_amount as FuelCost,
       (Cast(Floor(Cast(fp_date as float))as smalldatetime)) as [Fuel Purchase Date Only]

From   fuelpurchased WITH (NOLOCK)
where  mov_number > 0 and fp_fueltype = 'DSL'
       And
       not exists (select * from MR_StateMileageInvalidCityCodes where fp_city = CityCode)





GO
GRANT SELECT ON  [dbo].[vMILEREPORTSTMW_TripAndFuelStops] TO [public]
GO
