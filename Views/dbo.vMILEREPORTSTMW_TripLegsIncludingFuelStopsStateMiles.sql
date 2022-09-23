SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE                            View [dbo].[vMILEREPORTSTMW_TripLegsIncludingFuelStopsStateMiles] As


Select Top 100 Percent
       TempLegs.*,
       TMWStateMilesByLeg.stmlsleg_mileageinterface as MileageInterface,
       TMWStateMilesByLeg.stmlsleg_mileageinterfaceversion as MileageInterfaceVersion,
       TMWStateMilesByLeg.stmlsleg_mileagetype as MileageType,
       TMWStateMilesByLeg.stmlsleg_state as State,
       TMWStateMilesByLeg.stmlsleg_statetotalmiles as [State Total Miles],
       TMWStateMilesByLeg.stmlsleg_statetollmiles as [State Toll Miles],
       TMWStateMilesByLeg.stmlsleg_statefreemiles as [State Free Miles],
       TMWStateMilesByLeg.stmlsleg_lookupstatus as [Lookup Status],
       TMWStateMilesByLeg.stmlsleg_errdescription as [Error Description]


From

(


Select Top 100 Percent
       TempStops.Location as 'Origin Location',
       isnull(TempStops.[Company ID],'unknown') as [Origin Company ID],
       TempStops.CityStateOrZip as OriginCityStateOrZip,       
       TempStops.TripState as OriginState,
       TempStops2.Location as 'Destination Location',
       ISNULL(TempStops2.[Company ID],'UNKNOWN') as [Destination Company ID],
       TempStops2.CityStateOrZip as DestinationCityStateOrZip,
       TempStops2.TripState as DestState,
       TempStops2.LoadStatus,
       TempStops2.TrueLoadStatus,
	TempStops2.[Tractor],
	TempStops2.mov_number,
	TempStops2.lgh_number,
	TempStops2.stp_mfh_sequence,
	TempStops2.stp_number,
	TempStops2.[Arrival Date],
	TempStops2.[Driver ID],
	TempStops2.RevType1,
	TempStops2.RevType2,
	TempStops2.RevType3,
	TempStops2.RevType4,
	TempStops2.DrvType1,
	TempStops2.DrvType2,
	TempStops2.DrvType3,
	TempStops2.DrvType4,
	TempStops2.OrderNumber,
	TempStops2.[Segment Start Date],
	TempStops2.[Segment End Date],
	TempStops2.[Dispatch Status],
	TempStops2.TrcType1,
	TempStops2.TrcType2,
	TempStops2.TrcType3,
	TempStops2.TrcType4,
	TempStops2.[Bill Date],
	TempStops2.[Transfer Date],
 
       'City To City' as [Leg Type],
       '' as [Trailer ID],
       '' as [Fuel Type]


From

	(
       select 
       
       StopID = 1,--identity(int,1,1),
       stp_city as 'Location',
       cmp_id as [Company ID], 	
       'CityStateOrZip' = IsNull((select  case when (select count(*) from MR_generalinfo where gi_key = 'StateMileageAndFuelMileageInterface' and gi_value = 'RAND') > 0 and Len(rtrim(IsNull(rand_city,''))) > 0 then

                                                                              rtrim(IsNull(rand_city,'')) + ', ' + rtrim(IsNull(rand_state,'')) + Case When Len(IsNull(rand_county,'')) > 0 Then ', ' + IsNull(rand_county,'') Else '' End 

                                                                     ELSE

                                                                              Case When Len(RTRIM(IsNull(alk_city,''))) > 0 Then  

                                                                                          RTRIM(IsNull(alk_city,'')) + ', ' + IsNull(alk_state,'') + Case When Len(IsNull(alk_county,'')) > 0 Then ', ' + IsNull(alk_county,'') Else '' End 

                                                                              Else 

                                                                                           IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') + Case When Len(IsNull(cty_county,'')) > 0 Then ', ' + IsNull(cty_county,'') Else '' End 

 

                                                                              END

                      

                                           

                                              End 
				   from city WITH (NOLOCK) where a.stp_city = cty_code),''), 
       	IsNull((select cty_state from city WITH (NOLOCK) where a.stp_city = cty_code),'') as 'TripState',
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
       (select ord_number from orderheader WITH (NOLOCK) where a.ord_hdrnumber = orderheader.ord_hdrnumber) as OrderNumber,
       lgh_startdate as [Segment Start Date],
       lgh_enddate as [Segment End Date],
       lgh_outstatus as [Dispatch Status],
       trc_type1 as TrcType1,
       trc_type2 as TrcType2,
       trc_type3 as TrcType3,
       trc_type4 as TrcType4,
       (select min(ivh_billdate) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber =a.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Bill Date',
       (select min(ivh_xferdate) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = a.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Transfer Date'
       

from   legheader WITH (NOLOCK),stops a WITH (NOLOCK)
where  legheader.lgh_number = a.lgh_number
       and
       legheader.lgh_outstatus = 'CMP'

Union All

       select 
       
       StopID = 1,--identity(int,1,1),
       fp_city as 'Location',
       Null as [Company ID], 	
       'CityStateOrZip' = IsNull((select  case when (select count(*) from MR_generalinfo where gi_key = 'StateMileageAndFuelMileageInterface' and gi_value = 'RAND') > 0 and Len(rtrim(IsNull(rand_city,''))) > 0 then

                                                                              rtrim(IsNull(rand_city,'')) + ', ' + rtrim(IsNull(rand_state,'')) + Case When Len(IsNull(rand_county,'')) > 0 Then ', ' + IsNull(rand_county,'') Else '' End 

                                                                     ELSE

                                                                              Case When Len(RTRIM(IsNull(alk_city,''))) > 0 Then  

                                                                                          RTRIM(IsNull(alk_city,'')) + ', ' + IsNull(alk_state,'') + Case When Len(IsNull(alk_county,'')) > 0 Then ', ' + IsNull(alk_county,'') Else '' End 

                                                                              Else 

                                                                                           IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') + Case When Len(IsNull(cty_county,'')) > 0 Then ', ' + IsNull(cty_county,'') Else '' End 

 

                                                                              END

                      

                                           

                                              End 
				   from city WITH (NOLOCK) where fp_city = cty_code),''), 
       IsNull((select cty_state from city WITH (NOLOCK) where fp_city = cty_code),'') as 'TripState',
       Null as 'LoadStatus',
       Null As TrueLoadStatus,
       trc_number as 'Tractor',
       mov_number,
       lgh_number,
       Null,
       fp_sequence,
       fp_date as [Arrival Date],
       Null as [Driver ID],
       (select lgh_class1 from legheader WITH (NOLOCK) where legheader.lgh_number = fuelpurchased.lgh_number) as RevType1,
       Null as RevType2,
       Null as RevType3,
       Null as RevType4,
       (select mpp_type1 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType1,
       (select mpp_type2 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType2,
       (select mpp_type3 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType3,
       (select mpp_type4 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType4,
       ord_number as OrderNumber,
       fp_date as [Segment Start Date],
       fp_date as [Segment End Date],
       'CMP'as [Dispatch Status],
       (select top 1 trc_type1 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType1,
       (select top 1 trc_type2 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType2,
       (select top 1 trc_type3 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType3,
       (select top 1 trc_type4 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType4,
      (select min(ivh_billdate) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_number =fuelpurchased.ord_number and invoiceheader.ord_hdrnumber <> 0) as 'Bill Date',
       (select min(ivh_xferdate) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_number = fuelpurchased.ord_number and invoiceheader.ord_hdrnumber <> 0) as 'Transfer Date'
       

from   fuelpurchased WITH (NOLOCK)
where mov_number >0 and fp_fueltype = 'DSL'
       And
       not exists (select * from MR_StateMileageInvalidCityCodes where fp_city = CityCode)



     
     ) as TempStops,

    
	( select 
       
       StopID = 1,--identity(int,1,1),
       stp_city as 'Location',
       cmp_id as [Company ID], 	
       'CityStateOrZip' = IsNull((select  case when (select count(*) from MR_generalinfo where gi_key = 'StateMileageAndFuelMileageInterface' and gi_value = 'RAND') > 0 and Len(rtrim(IsNull(rand_city,''))) > 0 then

                                                                              rtrim(IsNull(rand_city,'')) + ', ' + rtrim(IsNull(rand_state,'')) + Case When Len(IsNull(rand_county,'')) > 0 Then ', ' + IsNull(rand_county,'') Else '' End 

                                                                     ELSE

                                                                              Case When Len(RTRIM(IsNull(alk_city,''))) > 0 Then  

                                                                                          RTRIM(IsNull(alk_city,'')) + ', ' + IsNull(alk_state,'') + Case When Len(IsNull(alk_county,'')) > 0 Then ', ' + IsNull(alk_county,'') Else '' End 

                                                                              Else 

                                                                                           IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') + Case When Len(IsNull(cty_county,'')) > 0 Then ', ' + IsNull(cty_county,'') Else '' End 

 

                                                                              END

                      

                                           

                                              End 
				   from city WITH (NOLOCK) where a.stp_city = cty_code),''), 
       IsNull((select cty_state from city WITH (NOLOCK) where a.stp_city = cty_code),'') as 'TripState',
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
       (select ord_number from orderheader WITH (NOLOCK) where a.ord_hdrnumber = orderheader.ord_hdrnumber) as OrderNumber,
       lgh_startdate as [Segment Start Date],
       lgh_enddate as [Segment End Date],
       lgh_outstatus as [Dispatch Status],
       trc_type1 as TrcType1,
       trc_type2 as TrcType2,
       trc_type3 as TrcType3,
       trc_type4 as TrcType4,
      (select min(ivh_billdate) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber =a.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Bill Date',
      (select min(ivh_xferdate) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = a.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Transfer Date'
       

from   legheader WITH (NOLOCK),stops a WITH (NOLOCK)
where  legheader.lgh_number = a.lgh_number
       and
       legheader.lgh_outstatus = 'CMP'

Union All

       select 
       
       StopID = 1,--identity(int,1,1),
       fp_city as 'Location',
       Null as [Company ID], 	
       'CityStateOrZip' = IsNull((select  case when (select count(*) from MR_generalinfo where gi_key = 'StateMileageAndFuelMileageInterface' and gi_value = 'RAND') > 0 and Len(rtrim(IsNull(rand_city,''))) > 0 then

                                                                              rtrim(IsNull(rand_city,'')) + ', ' + rtrim(IsNull(rand_state,'')) + Case When Len(IsNull(rand_county,'')) > 0 Then ', ' + IsNull(rand_county,'') Else '' End 

                                                                     ELSE

                                                                              Case When Len(RTRIM(IsNull(alk_city,''))) > 0 Then  

                                                                                          RTRIM(IsNull(alk_city,'')) + ', ' + IsNull(alk_state,'') + Case When Len(IsNull(alk_county,'')) > 0 Then ', ' + IsNull(alk_county,'') Else '' End 

                                                                              Else 

                                                                                           IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') + Case When Len(IsNull(cty_county,'')) > 0 Then ', ' + IsNull(cty_county,'') Else '' End 

 

                                                                              END

                      

                                           

                                              End  
				   from city WITH (NOLOCK) where fp_city = cty_code),''), 
       IsNull((select cty_state from city WITH (NOLOCK) where fp_city = cty_code),'') as 'TripState',
       Null as 'LoadStatus',
       Null As TrueLoadStatus,
       trc_number as 'Tractor',
       mov_number,
       lgh_number,
       Null,
       fp_sequence,
       fp_date as [Arrival Date],
       Null as [Driver ID],
       (select lgh_class1 from legheader WITH (NOLOCK) where legheader.lgh_number = fuelpurchased.lgh_number) as RevType1,
       Null as RevType2,
       Null as RevType3,
       Null as RevType4,
       (select mpp_type1 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType1,
       (select mpp_type2 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType2,
       (select mpp_type3 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType3,
       (select mpp_type4 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType4,
       ord_number as OrderNumber,
       fp_date as [Segment Start Date],
       fp_date as [Segment End Date],
       'CMP'as [Dispatch Status],
       (select top 1 trc_type1 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType1,
       (select top 1 trc_type2 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType2,
       (select top 1 trc_type3 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType3,
       (select top 1 trc_type4 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType4,
       (select min(ivh_billdate) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_number =fuelpurchased.ord_number and invoiceheader.ord_hdrnumber <> 0) as 'Bill Date',
       (select min(ivh_xferdate) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_number = fuelpurchased.ord_number and invoiceheader.ord_hdrnumber <> 0) as 'Transfer Date'
       

from   fuelpurchased WITH (NOLOCK)
where  mov_number >0 and fp_fueltype = 'DSL'
       And
       not exists (select * from MR_StateMileageInvalidCityCodes where fp_city = CityCode)


     
     ) as TempStops2


       

     
      


where  TempStops2.[Arrival Date] =  
      

	(select min(b.[Arrival Date])
	 From vMILEREPORTSTMW_TripAndFuelStops b
	 Where b.[Arrival Date] > TempStops.[Arrival Date]
	       and
               b.[mov_number] = TempStops.[mov_number]
	       and
	       b.Tractor = TempStops.Tractor
	 )
       
      And
 
      TempStops2.Tractor = TempStops.Tractor
      And
      TempStops2.mov_number = TempStops.mov_number


     
      



	
      
		
      

) As TempLegs,TMWStateMilesByLeg

Where TempLegs.[Origin Location] = TMWStateMilesByLeg.stmlsleg_originlocation
      And
      TempLegs.[Destination Location] = TMWStateMilesByLeg.stmlsleg_destinationlocation
      And
      TempLegs.[Leg Type] = TMWStateMilesByLeg.stmlsleg_legtype
      


order by [Leg Type],mov_number,lgh_number,stp_mfh_sequence








GO
GRANT SELECT ON  [dbo].[vMILEREPORTSTMW_TripLegsIncludingFuelStopsStateMiles] TO [public]
GO
