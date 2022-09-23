SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--select * from vMILEREPORTSTMW_LGHFuelPurchasesAndTripLegsStateMiles where ([Arrival Date] Between '20000921' And '20050929 23:59:59') And (CHARINDEX(',' + [Leg Type] + ',' , ',City To City,') > 0)

CREATE                                     View [dbo].[vMILEREPORTSTMW_LGHFuelPurchasesAndTripLegsStateMiles] As

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
       Case When TrueLoadStatus = 'Loaded' Then TMWStateMilesByLeg.stmlsleg_statetotalmiles Else 0 End as [State Total Loaded Miles],
       Case When TrueLoadStatus = 'Empty' Then TMWStateMilesByLeg.stmlsleg_statetotalmiles Else 0 End as [State Total Empty Miles],
       Case When TrueLoadStatus = 'Loaded' Then TMWStateMilesByLeg.stmlsleg_statefreemiles Else 0 End as [State Free Loaded Miles],
       Case When TrueLoadStatus = 'Empty' Then TMWStateMilesByLeg.stmlsleg_statefreemiles Else 0 End as [State Free Empty Miles],
       Case When TrueLoadStatus = 'Loaded' Then TMWStateMilesByLeg.stmlsleg_statetollmiles Else 0 End as [State Toll Loaded Miles],
       Case When TrueLoadStatus = 'Empty' Then TMWStateMilesByLeg.stmlsleg_statetollmiles Else 0 End as [State Toll Empty Miles],
       TMWStateMilesByLeg.stmlsleg_lookupstatus as [Lookup Status],
       TMWStateMilesByLeg.stmlsleg_errdescription as [Error Description],
       0 As [Gallons Purchased],
       ' ' as [Fuel Type],
       NULL as [Fuel Purchase Date Only],
       NULL as [Vendor Name],
       NULL as [Fuel Cost]
       
From

(

Select  
	
	TempOrigin.stp_city as 'Origin Location',
	Case When (select gi_value from MR_GeneralInfo WITH (NOLOCK) where gi_key = 'StateMileageAndFuelMileageInterface') = 'ALKPCMILER' Then
		Case When RTrim(IsNull((select alk_city from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'')) = '' Then
			IsNull((select cty_name from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') + Case When RTrim(IsNull((select cty_county from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'')) = '' Then '' Else ', ' + IsNull((select cty_county from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') End
		Else
			IsNull((select alk_city from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') + ', ' + IsNull((select alk_state from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') + Case When RTrim(IsNull((select alk_county from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'')) = '' Then '' Else ', ' + IsNull((select alk_county from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') End
		End
	     When (select gi_value from MR_GeneralInfo WITH (NOLOCK) where gi_key = 'StateMileageAndFuelMileageInterface') = 'RAND' Then
		Case When RTrim(IsNull((select rand_city from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'')) = '' Then
			IsNull((select cty_name from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') + Case When RTrim(IsNull((select cty_county from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'')) = '' Then '' Else ', ' + IsNull((select cty_county from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') End
		Else
			IsNull((select rand_city from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') + ', ' + IsNull((select rand_state from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') + Case When RTrim(IsNull((select rand_county from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'')) = '' Then '' Else ', ' + IsNull((select rand_county from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') End
		End
		
	Else
			IsNull((select cty_name from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') + Case When RTrim(IsNull((select cty_county from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'')) = '' Then '' Else ', ' + IsNull((select cty_county from city WITH (NOLOCK) where TempOrigin.stp_city = cty_code),'') End
	End as 'OriginCityStateOrZip',
       TempDestination.stp_city as 'Destination Location',
       Case When (select gi_value from MR_GeneralInfo WITH (NOLOCK) where gi_key = 'StateMileageAndFuelMileageInterface') = 'ALKPCMILER' Then
		Case When RTrim(IsNull((select alk_city from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'')) = '' Then
			IsNull((select cty_name from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') + Case When RTrim(IsNull((select cty_county from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'')) = '' Then '' Else ', ' + IsNull((select cty_county from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') End
		Else
			IsNull((select alk_city from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') + ', ' + IsNull((select alk_state from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') + Case When RTrim(IsNull((select alk_county from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'')) = '' Then '' Else ', ' + IsNull((select alk_county from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') End
		End
	     When (select gi_value from MR_GeneralInfo WITH (NOLOCK) where gi_key = 'StateMileageAndFuelMileageInterface') = 'RAND' Then
		Case When RTrim(IsNull((select rand_city from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'')) = '' Then
			IsNull((select cty_name from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') + Case When RTrim(IsNull((select cty_county from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'')) = '' Then '' Else ', ' + IsNull((select cty_county from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') End
		Else
			IsNull((select rand_city from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') + ', ' + IsNull((select rand_state from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') + Case When RTrim(IsNull((select rand_county from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'')) = '' Then '' Else ', ' + IsNull((select rand_county from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') End
		End
		
	Else
			IsNull((select cty_name from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') + ', ' + IsNull((select cty_state from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') + Case When RTrim(IsNull((select cty_county from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'')) = '' Then '' Else ', ' + IsNull((select cty_county from city WITH (NOLOCK) where TempDestination.stp_city = cty_code),'') End
	End as 'DestinationCityStateOrZip',
       convert(varchar(5),IsNull(TempDestination.stp_loadstatus,'')) as 'LoadStatus',
       case When TempDestination.stp_loadstatus = 'LD' Then 'Loaded' Else 'Empty' End As TrueLoadStatus,
       lgh_tractor as 'Tractor',
       legheader.mov_number,
       legheader.lgh_number,
       TempDestination.stp_mfh_sequence,
       TempDestination.stp_number,
       TempDestination.stp_arrivaldate as [Arrival Date],
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
       trc_fleet as Fleet,
       (select ord_number from orderheader WITH (NOLOCK) where TempDestination.ord_hdrnumber = orderheader.ord_hdrnumber) as OrderNumber, 
	   'City To City' as [Leg Type],
	   event.evt_trailer1 as [Trailer ID]

from   legheader WITH (NOLOCK),stops TempDestination WITH (NOLOCK), stops TempOrigin WITH (NOLOCK),event WITH (NOLOCK)
where  legheader.lgh_number = TempDestination.lgh_number
       and
       legheader.lgh_outstatus = 'CMP'
       and
       TempDestination.stp_mfh_sequence = TempOrigin.stp_mfh_sequence + 1 -- = (select max(b.stp_mfh_sequence) from stops b WITH (NOLOCK) where b.stp_mfh_sequence < TempDestination.stp_mfh_sequence and b.mov_number = TempDestination.mov_number)
       and
       TempOrigin.mov_number = TempDestination.mov_number
       and
       TempOrigin.stp_number = event.stp_number
       and
       event.evt_sequence = 1
       and 
       legheader.lgh_tractor = event.evt_tractor
      

      
      


Union

Select  
	    TempOrigin.stp_city as 'Origin Location',
        case when Len(RTrim(IsNull((select cmp_zip from company (NOLOCK) where TempOrigin.cmp_id = company.cmp_id),''))) > 0 Then IsNull((select cmp_zip from company (NOLOCK) where TempOrigin.cmp_id = company.cmp_id),'') Else  IsNull((select cty_zip from city (NOLOCK) where TempOrigin.stp_city = cty_code),'') End as 'OriginCityStateOrZip',
        TempDestination.stp_city as 'Destination Location',    
		case when Len(RTrim(IsNull((select cmp_zip from company (NOLOCK) where TempDestination.cmp_id = company.cmp_id),''))) > 0 Then IsNull((select cmp_zip from company (NOLOCK) where TempDestination.cmp_id = company.cmp_id),'') Else  IsNull((select cty_zip from city (NOLOCK) where TempDestination.stp_city = cty_code),'') End as 'DestinationCityStateOrZip',
        convert(varchar(5),IsNull(TempDestination.stp_loadstatus,'')) as 'LoadStatus',
        case When TempDestination.stp_loadstatus = 'LD' Then 'Loaded' Else 'Empty' End As TrueLoadStatus,
        lgh_tractor as 'Tractor',
        legheader.mov_number,
        legheader.lgh_number,
        TempDestination.stp_mfh_sequence,
        TempDestination.stp_number,
        TempDestination.stp_arrivaldate as [Arrival Date],
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
        trc_fleet as Fleet,
        (select ord_number from orderheader WITH (NOLOCK) where TempDestination.ord_hdrnumber = orderheader.ord_hdrnumber) as OrderNumber, 
	    'Zip To Zip' as [Leg Type],
	    event.evt_trailer1 as [Trailer ID]

from   legheader WITH (NOLOCK),stops TempDestination WITH (NOLOCK), stops TempOrigin WITH (NOLOCK),event WITH (NOLOCK)
where  legheader.lgh_number = TempDestination.lgh_number
       and
       legheader.lgh_outstatus = 'CMP'
       and
       TempDestination.stp_mfh_sequence = TempOrigin.stp_mfh_sequence + 1 -- = (select max(b.stp_mfh_sequence) from stops b WITH (NOLOCK) where b.stp_mfh_sequence < TempDestination.stp_mfh_sequence and b.mov_number = TempDestination.mov_number)
       and
       TempOrigin.mov_number = TempDestination.mov_number
       and
       TempOrigin.stp_number = event.stp_number
       and
       event.evt_sequence = 1
       and 
       legheader.lgh_tractor = event.evt_tractor

) As TempLegs,TMWStateMilesByLGHLeg TMWStateMilesByLeg

Where TempLegs.[Leg Type] = TMWStateMilesByLeg.stmlsleg_legtype
      And
      TempLegs.[stp_number]  = TMWStateMilesByLeg.stmlsleg_endstopnumber
      And
      TempLegs.[lgh_number]  = TMWStateMilesByLeg.stmlsleg_lghnumber
       
  
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
       (select mpp_type1 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType1,
       (select mpp_type2 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType2,
       (select mpp_type3 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType3,
       (select mpp_type4 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType4,
       (select top 1 trc_type1 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType1,
       (select top 1 trc_type2 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType2,
       (select top 1 trc_type3 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType3,
       (select top 1 trc_type4 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType4,
       (select top 1 trc_fleet from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as Fleet,
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
       0 as [State Total Loaded Miles],
       0 as [State Total Empty Miles],
       0 as [State Free Loaded Miles],
       0 as [State Free Empty Miles],
       0 as [State Toll Loaded Miles],
       0 as [State Toll Empty Miles],
       '' as [Lookup Status],
       '' as [Error Description],
       Case When fp_uom <> 'GAL' Then
		round(cast(fp_quantity * (select unc_factor from unitconversion WITH (NOLOCK) where unc_from = fp_uom and unc_to = 'GAL' and unc_convflag = 'Q') as float),2)
       Else
		round(cast(fp_quantity as float),2)
       End as [Gallons Purchased],
       fp_fueltype as [Fuel Type],
       (Cast(Floor(Cast(fp_date as float))as smalldatetime)) as [Fuel Purchase Date Only],
       fp_vendorname as [Vendor Name],
       IsNull(fp_amount,0) as [Fuel Cost]
	--fp_quantity as [Gallons Purchased]

From fuelpurchased WITH (NOLOCK)      

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
       'CMP' as [Dispatch Status],
       (select mpp_type1 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType1,
       (select mpp_type2 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType2,
       (select mpp_type3 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType3,
       (select mpp_type4 from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = fuelpurchased.mpp_id) as DrvType4,
       (select top 1 trc_type1 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType1,
       (select top 1 trc_type2 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType2,
       (select top 1 trc_type3 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType3,
       (select top 1 trc_type4 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType4,
       (select top 1 trc_fleet from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as Fleet,
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
       0 as [State Total Loaded Miles],
       0 as [State Total Empty Miles],
       0 as [State Free Loaded Miles],
       0 as [State Free Empty Miles],
       0 as [State Toll Loaded Miles],
       0 as [State Toll Empty Miles],
       '' as [Lookup Status],
       '' as [Error Description],
       Case When fp_uom <> 'GAL' Then
		round(cast(fp_quantity * (select unc_factor from unitconversion WITH (NOLOCK) where unc_from = fp_uom and unc_to = 'GAL' and unc_convflag = 'Q') as float),2)
       Else
		round(cast(fp_quantity as float),2)
       End as [Gallons Purchased],
       fp_fueltype as [Fuel Type],
       (Cast(Floor(Cast(fp_date as float))as smalldatetime)) as [Fuel Purchase Date Only],
       fp_vendorname as [Vendor Name],
       IsNull(fp_amount,0) as [Fuel Cost]
	--fp_quantity as [Gallons Purchased]

From fuelpurchased WITH (NOLOCK)  
) as TempAll
order by [Leg Type],mov_number,lgh_number,stp_mfh_sequence












































GO
