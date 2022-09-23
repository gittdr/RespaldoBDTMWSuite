SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--select top 100 * from vMILEREPORTSTMW_FuelStops 

CREATE       View [dbo].[vMILEREPORTSTMW_FuelStops] 

 

As 

 
--Insert into #TempStops 

Select fp_city as 'Origin Location', 

       ' ' as [Origin Company ID], 

       OriginCityStateOrZip = IsNull((select 

                                                               case when (select count(*) from MR_generalinfo where gi_key = 'StateMileageAndFuelMileageInterface' and gi_value = 'RAND') > 0 and Len(rtrim(IsNull(rand_city,''))) > 0 then

                                                                              rtrim(IsNull(rand_city,'')) + ', ' + rtrim(IsNull(rand_state,'')) + Case When Len(IsNull(rand_county,'')) > 0 Then ', ' + IsNull(rand_county,'') Else '' End 

                                                                     ELSE

                                                                              Case When Len(RTRIM(IsNull(alk_city,''))) > 0 Then  

                                                                                          RTRIM(IsNull(alk_city,'')) + ', ' + IsNull(alk_state,'') + Case When Len(IsNull(alk_county,'')) > 0 Then ', ' + IsNull(alk_county,'') Else '' End 

                                                                              Else 

                                                                                           IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') + Case When Len(IsNull(cty_county,'')) > 0 Then ', ' + IsNull(cty_county,'') Else '' End 

 

                                                                              END

                      

                                           

                                              End 

                                   

                                   from city WITH (NOLOCK) where fp_city = cty_code),''),  

       OriginState = IsNull((select cty_state from city WITH (NOLOCK) where fp_city = cty_code),''), 

       fp_city as 'Destination Location', 

       ' ' as [Destination Company ID], 

       DestinationCityStateOrZip = IsNull((select 

                                                               case when (select count(*) from MR_generalinfo where gi_key = 'StateMileageAndFuelMileageInterface' and gi_value = 'RAND') > 0 and Len(rtrim(IsNull(rand_city,''))) > 0 then

                                                                              rtrim(IsNull(rand_city,'')) + ', ' + rtrim(IsNull(rand_state,'')) + Case When Len(IsNull(rand_county,'')) > 0 Then ', ' + IsNull(rand_county,'') Else '' End 

                                                                     ELSE

                                                                              Case When Len(RTRIM(IsNull(alk_city,''))) > 0 Then  

                                                                                          RTRIM(IsNull(alk_city,'')) + ', ' + IsNull(alk_state,'') + Case When Len(IsNull(alk_county,'')) > 0 Then ', ' + IsNull(alk_county,'') Else '' End 

                                                                              Else 

                                                                                           IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') + Case When Len(IsNull(cty_county,'')) > 0 Then ', ' + IsNull(cty_county,'') Else '' End 

 

                                                                              END

                      

                                           

                                              End 

                                   

                                   from city WITH (NOLOCK) where fp_city = cty_code),''), 

       '' as 'LoadStatus', 

       '' As TrueLoadStatus, 

       trc_number as 'Tractor', 

       mov_number, 

       lgh_number, 

       NULL as stp_mfh_sequence, 

       stp_number, 

       fp_date as [Arrival Date], 

       mpp_id as [Driver ID], 

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

       'CMP' as [Dispatch Status], 

       (select top 1 trc_type1 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType1,

 

       (select top 1 trc_type2 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType2,

 

       (select top 1 trc_type3 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType3,

 

       (select top 1 trc_type4 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType4,

 

       Null as [Bill Date], 

       Null as [Transfer Date], 

       0 as [Total Miles], 

       0 as [Toll Miles], 

       0 as [Non Toll Miles], 

        0 as [Unreach Miles], 

       ' ' as State, 

       'City To City' as [Leg Type], 

       ' ' as [Trailer ID], 

       IsNull(fp_fueltype,'') as [Fuel Type] 

  

 

From   fuelpurchased WITH (NOLOCK) 

where  fp_fueltype = 'DSL' 

 

Union 

 

Select fp_city as 'Origin Location', 

       ' ' as [Origin Company ID], 

       OriginCityStateOrZip = IsNull((select 

                                                               case when (select count(*) from MR_generalinfo where gi_key = 'StateMileageAndFuelMileageInterface' and gi_value = 'RAND') > 0 and Len(rtrim(IsNull(rand_city,''))) > 0 then

                                                                              rtrim(IsNull(rand_city,'')) + ', ' + rtrim(IsNull(rand_state,'')) + Case When Len(IsNull(rand_county,'')) > 0 Then ', ' + IsNull(rand_county,'') Else '' End 

                                                                     ELSE

                                                                              Case When Len(RTRIM(IsNull(alk_city,''))) > 0 Then  

                                                                                          RTRIM(IsNull(alk_city,'')) + ', ' + IsNull(alk_state,'') + Case When Len(IsNull(alk_county,'')) > 0 Then ', ' + IsNull(alk_county,'') Else '' End 

                                                                              Else 

                                                                                           IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') + Case When Len(IsNull(cty_county,'')) > 0 Then ', ' + IsNull(cty_county,'') Else '' End 

 

                                                                              END

                      

                                           

                                              End 

                                   

                                   from city WITH (NOLOCK) where fp_city = cty_code),''), 

       OriginState = IsNull((select cty_state from city WITH (NOLOCK) where fp_city = cty_code),''), 

       fp_city as 'Destination Location', 

       ' ' as [Destination Company ID], 

       DestinationCityStateOrZip = IsNull((select 

                                                               case when (select count(*) from MR_generalinfo where gi_key = 'StateMileageAndFuelMileageInterface' and gi_value = 'RAND') > 0 and Len(rtrim(IsNull(rand_city,''))) > 0 then

                                                                              rtrim(IsNull(rand_city,'')) + ', ' + rtrim(IsNull(rand_state,'')) + Case When Len(IsNull(rand_county,'')) > 0 Then ', ' + IsNull(rand_county,'') Else '' End 

                                                                     ELSE

                                                                              Case When Len(RTRIM(IsNull(alk_city,''))) > 0 Then  

                                                                                          RTRIM(IsNull(alk_city,'')) + ', ' + IsNull(alk_state,'') + Case When Len(IsNull(alk_county,'')) > 0 Then ', ' + IsNull(alk_county,'') Else '' End 

                                                                              Else 

                                                                                           IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') + Case When Len(IsNull(cty_county,'')) > 0 Then ', ' + IsNull(cty_county,'') Else '' End 

 

                                                                              END

                      

                                           

                                              End 

                                   

                                   from city WITH (NOLOCK) where fp_city = cty_code),''), 

       '' as 'LoadStatus', 

       '' As TrueLoadStatus, 

       trc_number as 'Tractor', 

       mov_number, 

       lgh_number, 

       NULL as stp_mfh_sequence, 

       stp_number, 

       fp_date as [Arrival Date], 

       mpp_id as [Driver ID], 

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

       'CMP' as [Dispatch Status], 

       (select top 1 trc_type1 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType1,

 

       (select top 1 trc_type2 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType2,

 

       (select top 1 trc_type3 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType3,

 

       (select top 1 trc_type4 from tractorprofile WITH (NOLOCK) where tractorprofile.trc_number = fuelpurchased.trc_number) as TrcType4,

 

       Null as [Bill Date], 

       Null as [Transfer Date], 

       0 as [Total Miles], 

       0 as [Toll Miles], 

       0 as [Non Toll Miles], 

        0 as [Unreach Miles], 

       ' ' as State, 

       'Zip To Zip' as [Leg Type], 

       ' ' as [Trailer ID], 

       IsNull(fp_fueltype,'') as [Fuel Type] 

  

 

From   fuelpurchased WITH (NOLOCK) 

where  fp_fueltype = 'DSL' 


 

 

 




GO
