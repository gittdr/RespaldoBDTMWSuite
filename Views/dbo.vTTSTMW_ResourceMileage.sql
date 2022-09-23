SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE                             VIEW [dbo].[vTTSTMW_ResourceMileage]

AS

--Revision History
--1. Added Pay Period Date to report tying highest pay period date for that trip segment
     --Ver 5.1
--2. Added names for all company ID's
--   MRUTH Ver 5.4

Select TripSegment.*,
       
       Case When [Total Miles] = 0 or [Total Miles] Is Null Then
		0
       Else
	        Convert(float,(IsNull([Empty Miles],0)/convert(float,[Total Miles])))
       End as [Percent Empty],

       (SELECT cmp_othertype1 from company (NoLock) where [Bill To ID] = cmp_id) 
	 As [Other Type 1],   

       (SELECT cmp_othertype2 from company (NoLock) where [Bill To ID] = cmp_id) 
	 As [Other Type 2]    
 
          
from

(

Select 
	Lgh_number	'Leg Header Number',
	l.mov_number 	'Move Number',
	l.ord_hdrnumber 'Order Header Number',

	
	NumberOfSplitsOnMove= 
		(Select count(distinct L2.lgh_number) 
		From legheader  L2 (NOLOCK) where L2.Mov_number=L.Mov_number
		),

	NumberOfOrdersOnLeg= 
		(Select count(distinct ord_hdrnumber) 
		From Orderheader (NOLOCK) where L.ord_hdrnumber=Orderheader.ord_hdrnumber
		),
        
	--'CountOfLegHeadersNoMiles' = (select count(distinct CountLegHeadersNoMiles.lgh_number)

	--from (

		--select   lgh_number
		--from     stops 
		---where    l.mov_number = stops.mov_number
		--group by stops.lgh_number
		--having   sum(stp_lgh_mileage) = 0 


     	      --) as CountLegHeadersNoMiles),

	--IsNull(dbo.fnc_AllocatedLoadCount(lgh_number),0) as 'Allocated Load Count',					   
        --dbo.fnc_AllocateRevForLegByPayPerc(lgh_number) AllocatedTotRevenueByPayPerc,
	
      
	
	'Total Miles' = IsNull((select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = l.lgh_number),0),
 	'Empty Miles' = IsNull((select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = l.lgh_number and stp_loadstatus <> 'LD'),0),
        'Loaded Miles' = IsNull((select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = l.lgh_number and stp_loadstatus = 'LD'),0),

        --dbo.fnc_LoadedMilesForLegheader(lgh_number) LoadedMilesSegment,
	--dbo.fnc_EmptyMilesForLegheader(lgh_number) EmptyMilesSegment,
	--dbo.fnc_TravelMilesForLegheader(lgh_number) TotalMilesSegment,
	--dbo.fnc_BillableMilesForLegheader(lgh_number) BillableMilesSegment,	
	--dbo.fnc_TravelMilesForMove(l.mov_number)	TravelMilesForMOVE,
	
	
	--dbo.fnc_PayForMove(l.mov_number) TotalCompensationForMove,	
	
	--dbo.fnc_UnallocatedTotOrdRevForLegheader(lgh_number) UnallocatedOrderTotRevenue,
	--dbo.fnc_UnallocatedTotInvRevForLegheader(lgh_number) UnallocatedInvTotRevenue,

	lgh_tractor	'Tractor ID',
	lgh_driver1	'Driver1 ID',
	'Driver1 Name' = IsNull((select mpp_lastfirst from manpowerprofile (NOLOCK)  where mpp_id = lgh_driver1),''),
	lgh_driver2	'Driver2 ID',
	'Driver2 Name' = IsNull((select mpp_lastfirst from manpowerprofile (NOLOCK)  where mpp_id = lgh_driver2),''),
	lgh_carrier	'Carrier ID',
        'Carrier Name' = IsNull((select car_name from carrier (NOLOCK)  where car_id = lgh_carrier),''),
	lgh_primary_trailer 'Primary Trailer ID',
	lgh_startDate	'Segment Start Date',
	lgh_EndDate	'Segment End Date',
	lgh_startcty_nmstct  'Segment Start City',
	lgh_endcty_nmstct    'Segment End City',
	lgh_startstate 		'Segment Start State',
	lgh_endstate 		'Segment End State',
	lgh_startregion1 	'Segment Start Region1',
	lgh_endregion1 		'Segment End Region1',
	lgh_outstatus		'Segment Status',
	lgh_class1	'RevType1',
	lgh_class2	'RevType2',
	lgh_class3	'RevType3',
	lgh_class4	'RevType4',
	mpp_teamleader 'Team Leader ID', 
	mpp_fleet 'Fleet', 
	mpp_type1 'DrvType1', 
	mpp_type2 'DrvType2', 
	mpp_type3 'DrvType3', 
	mpp_type4 'DrvType4', 
	trc_type1 'TrcType1', 
	trc_type2 'TrcType2', 
	trc_type3 'TrcType3', 
	trc_type4 'TrcType4',
	l.trl_type1 'TrlType1', 
	trl_type2 'TrlType2', 
	trl_type3 'TrlType3', 
	trl_type4 'TrlType4', 

	l.cmd_code 'Commodity Code', 
	fgt_description 'Freight Description',                
	cmp_id_start 	'Segment Start CmpID', 
	cmp_id_end 	'Segment End CmpID'	,  
	'Segment Start CmpName' 	= 
		(Select	c.cmp_name
		 From	company c (NOLOCK)
		 where	l.cmp_id_start = c.cmp_id
	  	 	AND
			l.ord_hdrnumber>0),
	
	
	'Segment End CmpName' 	= 
		(Select	c.cmp_name
		 From	company c (NOLOCK)
		 where	l.cmp_id_end = c.cmp_id
	  	 	AND
			l.ord_hdrnumber>0),	

	'Order Ship Date'	=
		ISNULL(
		(Select ord_startdate
		From 	orderheader o (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,lgh_StartDate)
	,
	'Order Delivery Date' =
		ISNULL(
		(Select ord_CompletionDate
		From 	orderheader o (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,lgh_endDate),
	
	'Shipper ID' =
		ISNULL(
		(Select ord_shipper
		From 	orderheader o (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,''),

	'Consignee ID' =
		ISNULL(
		(Select ord_consignee
		From 	orderheader o (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,''),

	'Ordered By ID' =
		ISNULL(
		(Select ord_company
		From 	orderheader o (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,''),

	'Bill To ID' =
		ISNULL(
		(Select ord_billto
		From 	orderheader o (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,''),

	'Revenue Date' = 
                 (Select min(ivh_revenue_date)
                 From   invoiceheader I (NOLOCK) 
                 where  I.ord_hdrnumber = l.ord_hdrnumber
                        And
                        l.ord_hdrnumber > 0 
                  ),
      
        'Transfer Date' = 
                 (Select min(ivh_xferdate)
                 From   invoiceheader I (NOLOCK)
                 where  I.ord_hdrnumber = l.ord_hdrnumber
                        And
                        l.ord_hdrnumber > 0 
                  ),
        
        'Bill Date' = 
                 (Select min(ivh_billdate)
                 From   invoiceheader I (NOLOCK)
                 where  I.ord_hdrnumber = l.ord_hdrnumber
                        And
                        l.ord_hdrnumber > 0 
                  ),	
	
	 'Pay Period Date' = 
                 (Select min(pyh_payperiod)
                  From   paydetail (NOLOCK)
                  where  L.lgh_number = paydetail.lgh_number
                  ),	

        lgh_odometerstart as 'Odometer Start',
        lgh_odometerend as 'Odometer End',
        (lgh_odometerend - lgh_odometerstart) as 'Hub Miles',
	lgh_outstatus as 'Dispatch Status',
	--<TTS!*!TMW><Begin><FeaturePack=Other>
        '' as 'Booked RevType1',
        --<TTS!*!TMW><End><FeaturePack=Other>
        --<TTS!*!TMW><Begin><FeaturePack=Euro>
        --lgh_booked_revtype1 as 'Booked RevType1',
        --<TTS!*!TMW><End><FeaturePack=Euro> 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other> 
	'' as [204 Status],
	--<TTS!*!TMW><End><FeaturePack=Other> 
	--<TTS!*!TMW><Begin><FeaturePack=Euro> 
	--lgh_204status as [204 Status], 
	--<TTS!*!TMW><End><FeaturePack=Euro> 
  
	--<TTS!*!TMW><Begin><FeaturePack=Other> 
	'' as [Comment],
	--<TTS!*!TMW><End><FeaturePack=Other> 
	--<TTS!*!TMW><Begin><FeaturePack=Euro> 
	--lgh_comment as [Comment], 
	--<TTS!*!TMW><End><FeaturePack=Euro> 
  
	--<TTS!*!TMW><Begin><FeaturePack=Other> 
	'' as [CrossDock Inbound],
	--<TTS!*!TMW><End><FeaturePack=Other> 
	--<TTS!*!TMW><Begin><FeaturePack=Euro> 
	--lgh_crossdock_inbound as [CrossDock Inbound],
	--<TTS!*!TMW><End><FeaturePack=Euro> 
  
	--<TTS!*!TMW><Begin><FeaturePack=Other> 
	'' as [CrossDock Outbound],
	--<TTS!*!TMW><End><FeaturePack=Other> 
	--<TTS!*!TMW><Begin><FeaturePack=Euro> 
	--lgh_crossdock_outbound as [CrossDock Outbound],
	--<TTS!*!TMW><End><FeaturePack=Euro> 
 
	--<TTS!*!TMW><Begin><FeaturePack=Other> 
        '' as [Trip Origin Country],
	--<TTS!*!TMW><End><FeaturePack=Other> 
	--<TTS!*!TMW><Begin><FeaturePack=Euro> 
	--(select cty_country from city (NOLOCK) where cty_code = lgh_startcity) as 'Trip Origin Country',
	--<TTS!*!TMW><End><FeaturePack=Euro> 

	--<TTS!*!TMW><Begin><FeaturePack=Other> 
	'' as [Trip Destination Country],
	--<TTS!*!TMW><End><FeaturePack=Other> 
	--<TTS!*!TMW><Begin><FeaturePack=Euro> 
	--(select cty_country from city (NOLOCK) where cty_code = lgh_endcity) as 'Trip Destination Country',
	--<TTS!*!TMW><End><FeaturePack=Euro> 	 

	
	IsNull((select cty_zip from city (NOLOCK) where cty_code = lgh_startcity),'') as 'Trip Origin Zip Code',
	IsNull((select cty_zip from city (NOLOCK) where cty_code = lgh_endcity),'') as 'Trip Destination Zip Code',

	--<TTS!*!TMW><Begin><FeaturePack=Other> 
	'' as [LegHeader LineHaul]
	--<TTS!*!TMW><End><FeaturePack=Other> 
	--<TTS!*!TMW><Begin><FeaturePack=Euro> 
	--lgh_linehaul as [LegHeader LineHaul]
	--<TTS!*!TMW><End><FeaturePack=Euro>	

	--(select count(distinct(stops.ord_hdrnumber)) from stops (NOLOCK) where stops.lgh_number = l.lgh_number and stops.ord_hdrnumber <> 0) as 'Segment Load Count'
		
From 
	Legheader l (NOLOCK)
	

) as TripSegment




























GO
GRANT SELECT ON  [dbo].[vTTSTMW_ResourceMileage] TO [public]
GO
