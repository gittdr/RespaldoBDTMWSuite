SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO











CREATE                                                                         VIEW [dbo].[vTTSTMW_RevVsPay]

AS

--Revision History
--1. Added Pay Period Date to report tying highest pay period date for that trip segment
     --Ver 5.1 LBK
--2. Changed the way Primary Trailers are being tied to legheader
     --lgh_primarytrailer ties to ord_trailer on orderheader if 
     --an order number is stamped on the legheader
     --In past versions the Primary Trailer from the legheader table 
     --was being used on the report. That didn't necessarily mean
     --that is truly the Primarly Trailer for the entire movement
     --that actually picked up the load and was primary in the fact
     --that it carried the load
     --Some LegHeaders show trailers that are empty because they are 
     --parking them and moving them around probably for future loads
     --In order to get a true load count for the trailer
     --(the trailer involved in the LLD and LUD) needs 
     --to get credit even for the legheader that it wasn't on
     --So when the user adds up the load count for all segments
     --on the trip 
     --they will more then likely add up to 1 load for that trailer
     --Ver 5.1 LBK
--3. The primary trailer on the segment will still remain on the report
   --Meaning primary just for that segment not for the entire move
   --like the trailer that is mentioned above LBK  

--4. Addition of the hard coded trailer types company,fleet,division
--   LBK Ver 5.3 

--5  Changed the way Dates are handled when there could be multiple dates
--   that relate to that trip or order(bill date, pay period date, transfer date,
--   etc. Prior to Ver 5.4 all of the trips linked up to invoicing, or settlement
--   to get things like Bill Date, Pay Period Date, etc. All of these links
--   can have multiple entries(Such as Order can be re-billed or credited,
--   an order then could re-transferred because it was re-billed. Since there
--   are possibilities of multiple dates related to these trips, it is best
--   to use the first date because that was initially when it was billed, trans
--   paid, etc. The user can go to one of the other reports to break out
--   the dates to the exact penny. This report assumes for each trip segment
--   the first date associated will be used. Prior to version 5.4 the last date
--   was assumed.
--   LBK Ver 5.4 

--6. Addition of Hard-Coded Driver Tractor Types
--   LBK Ver 5.4

--7. Added names for all company ID's
--   MRUTH Ver 5.4

--8. Changed count of orders to look at distinct orders on stop level detail
--   BKEET Ver 5.4

--9. Added count of drops and pickups for each legheader

--10. Added DateParts Year,Month, and Day for dates
--  Bkeet Ver 5.42

--11 Added OrderHeader Reference Number
--  Bkeet Ver 5.42

Select TripSegment.*,
       
       Case When [Total Miles] = 0 or [Total Miles] Is Null Then
		0
       Else
		Convert(money,(Revenue/[Total Miles]))
       End As RevenuePerTravelMile,

       Case When [Loaded Miles] = 0 or [Loaded Miles] Is Null Then
		0
       Else
		Convert(money,([LineHaul Revenue]/[Loaded Miles]))
       End As LineHaulRevenuePerLoadedMile,

       Case When [Loaded Miles] = 0 or [Loaded Miles] Is Null Then
		0
       Else
		Convert(money,(Revenue/[Loaded Miles]))
       End As RevenuePerLoadedMile,

       Case When [Total Miles] = 0 or [Total Miles] Is Null Then
		0
       Else
		round((IsNull([Empty Miles],0)/convert(float,[Total Miles])),2)
       End as [Percent Empty],

       Case When [Revenue] = 0 or [Revenue] Is Null Then
		0
       Else
	        Convert(float,(IsNull([Fuel Surcharge],0)/convert(float,[Revenue])))
       End as [FuelSurchargePercentofRevenue],

       (Revenue-Pay) As Net,
       ([Revenue] - [LineHaul Revenue]) As 'Accessorial Revenue',
       
       Case When NumberOfSplitsOnMove = 0 Then
		0

       Else
	        convert(money,[Revenue] * convert(float,1/convert(float,NumberOfSplitsOnMove)))
       End as 'Revenue Per Load',       

       Case When [Hub Miles] = 0 Then
		0
       Else
       		 convert(money,([Revenue]/[Hub Miles]))
       End as 'RevenuePerHubMile',  	
       
       Case When [Hub Miles] = 0 Then
		0
       Else
       		 convert(money,([LineHaul Revenue]/[Hub Miles]))

       End as 'LineHaulRevenuePerHubMile',  	

       Case When NumberOfSplitsOnMove = 0 Then
		0
       Else
	        convert(float,1/convert(float,NumberOfSplitsOnMove))
       End as 'Allocated Consolidated Load Count' ,

       (SELECT cmp_othertype1 from company (NoLock) where [Bill To ID] = cmp_id) 
	 As [Other Type 1],   

       (SELECT cmp_othertype2 from company (NoLock) where [Bill To ID] = cmp_id) 
	 As [Other Type 2],

	(SELECT cmp_othertype1 from company (NoLock) where [Shipper ID] = cmp_id) 
	 As [Shipper OtherType1],   

       (SELECT cmp_othertype2 from company (NoLock) where [Shipper ID] = cmp_id) 
	 As [Shipper OtherType2],

	'Trailer Company' = (select min(trl_company) from trailerprofile (NOLOCK) where trl_id = [Segment Trailer ID]),    
	'Trailer Fleet' = (select min(trl_fleet) from trailerprofile (NOLOCK) where trl_id = [Segment Trailer ID]),    
	'Trailer Terminal' = (select min(trl_terminal) from trailerprofile (NOLOCK) where trl_id = [Segment Trailer ID]),    
	'Trailer Division' = (select min(trl_division) from trailerprofile (NOLOCK) where trl_id = [Segment Trailer ID]),    
	
	'Driver Division' = IsNull([TRIP Driver Division],(select mpp_division from manpowerprofile (NOLOCK) where mpp_id = [Driver1 ID])),    
	'Driver Domicile' = IsNull([TRIP Driver Domicile],(select mpp_domicile from manpowerprofile (NOLOCK) where mpp_id = [Driver1 ID])),  
	'Driver Fleet' = IsNull([TRIP Driver Fleet],(select mpp_fleet from manpowerprofile (NOLOCK) where mpp_id = [Driver1 ID])),  
	'Driver Terminal' = IsNull([TRIP Driver Terminal],(select mpp_terminal from manpowerprofile (NOLOCK) where mpp_id = [Driver1 ID])),  
	'Driver Company' = IsNull([TRIP Driver Company],(select mpp_company from manpowerprofile (NOLOCK) where mpp_id = [Driver1 ID])),          

	
	'Tractor Company' = IsNull([TRIP Tractor Company],(select trc_company from tractorprofile (NOLOCK) where trc_number = [Tractor ID])),          
	'Tractor Division' = IsNull([TRIP Tractor Division],(select trc_division from tractorprofile (NOLOCK) where trc_number = [Tractor ID])),          
	'Tractor Terminal' = IsNull([TRIP Tractor Terminal],(select trc_terminal from tractorprofile (NOLOCK) where trc_number = [Tractor ID])),          
	'Tractor Fleet' = IsNull([TRIP Tractor Fleet],(select trc_fleet from tractorprofile (NOLOCK) where trc_number = [Tractor ID])),
	Cast(DatePart(mm,[Pay Period Date]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[Pay Period Date]) as varchar(4)) as [Pay Period Month],
 	DatePart(mm,[Pay Period Date]) as [Pay Period Month Only],
	--**Order Ship Date**
	--Day
        (Cast(Floor(Cast([Order Ship Date] as float))as smalldatetime)) as [Order Ship Date Only], 
        Cast(DatePart(yyyy,[Order Ship Date]) as varchar(4)) +  '-' + Cast(DatePart(mm,[Order Ship Date]) as varchar(2)) + '-' + Cast(DatePart(dd,[Order Ship Date]) as varchar(2)) as [Order Ship Day],
        --Month
        Cast(DatePart(mm,[Order Ship Date]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[Order Ship Date]) as varchar(4)) as [Order Ship Month],
        DatePart(mm,[Order Ship Date]) as [Order Ship Month Only],
        --Year
        DatePart(yyyy,[Order Ship Date]) as [Order Ship Year],
	--Ship Day Of Week
	CASE DatePart(dw,[Order Ship Date]) WHEN 1 THEN 'Sunday'
                 			    WHEN 2 THEN 'Monday'
                 			    WHEN 3 THEN 'Tuesday'
                 			    WHEN 4 THEN 'Wednesday'
                 			    WHEN 5 THEN 'Thursday'
                 			    WHEN 6 THEN 'Friday'
                 			    WHEN 7 THEN 'Saturday'
                 			    ELSE SPACE(0)
        END as [Order Ship DayOfWeek],
	--**Order Delivery Date**
	--Day
        (Cast(Floor(Cast([Order Delivery Date] as float))as smalldatetime)) as [Delivery Date Only], 
        Cast(DatePart(yyyy,[Order Delivery Date]) as varchar(4)) +  '-' + Cast(DatePart(mm,[Order Delivery Date]) as varchar(2)) + '-' + Cast(DatePart(dd,[Order Delivery Date]) as varchar(2)) as [Delivery Day],
        --Month
        Cast(DatePart(mm,[Order Delivery Date]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[Order Delivery Date]) as varchar(4)) as [Delivery Month],
        DatePart(mm,[Order Delivery Date]) as [Delivery Month Only],
        --Year
        DatePart(yyyy,[Order Delivery Date]) as [Delivery Year],  
	--**Bill Date**
	--Day
        (Cast(Floor(Cast([Bill Date] as float))as smalldatetime)) as [Bill Date Only], 
        Cast(DatePart(yyyy,[Bill Date]) as varchar(4)) +  '-' + Cast(DatePart(mm,[Bill Date]) as varchar(2)) + '-' + Cast(DatePart(dd,[Bill Date]) as varchar(2)) as [Bill Day],
        --Month
        Cast(DatePart(mm,[Bill Date]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[Bill Date]) as varchar(4)) as [Bill Month],
        DatePart(mm,[Bill Date]) as [Bill Month Only],
        --Year
        DatePart(yyyy,[Bill Date]) as [Bill Year],               
	--**Transfer Date**
	--Day
        (Cast(Floor(Cast([Transfer Date] as float))as smalldatetime)) as [Transfer Date Only], 
        Cast(DatePart(yyyy,[Transfer Date]) as varchar(4)) +  '-' + Cast(DatePart(mm,[Transfer Date]) as varchar(2)) + '-' + Cast(DatePart(dd,[Transfer Date]) as varchar(2)) as [Transfer Day],
        --Month
        Cast(DatePart(mm,[Transfer Date]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[Transfer Date]) as varchar(4)) as [Transfer Month],
        DatePart(mm,[Transfer Date]) as [Transfer Month Only],
        --Year
        DatePart(yyyy,[Transfer Date]) as [Transfer Year],
	'Shipper' = (select cmp_name from company (NOLOCK) where cmp_id = [Shipper ID]),
 	'Consignee' = (select cmp_name from company (NOLOCK) where cmp_id = [Consignee ID]),
	'Bill To' = (select cmp_name from company (NOLOCK) where cmp_id = [Bill To ID]),
	'Master Bill To' = (select cmp_mastercompany from company (NOLOCK) where cmp_id = [Bill To ID]),
	Case When [Segment Start City] = [Segment End City] Then
		'Y'
	Else
		'N'
	End as [SameSegmentCityYN],
	[Order Origin City] = (select min(cty_name) from orderheader (NOLOCK),city (NOLOCK) where orderheader.ord_hdrnumber = [Order Header Number] and cty_code = ord_origincity),
	[Order Origin State] = (select min(cty_state) from orderheader (NOLOCK),city (NOLOCK) where orderheader.ord_hdrnumber = [Order Header Number] and cty_code = ord_origincity),
	[Order Dest City] = (select min(cty_name) from orderheader (NOLOCK),city (NOLOCK) where orderheader.ord_hdrnumber = [Order Header Number] and cty_code = ord_destcity),
	[Order Dest State] = (select min(cty_state) from orderheader (NOLOCK),city (NOLOCK) where orderheader.ord_hdrnumber = [Order Header Number] and cty_code = ord_destcity),
	[Last GPS Location] = (select top 1 ckc_comment from checkcall (NOLOCK) where [Leg Header Number] = ckc_lghnumber and ckc_date = [Last GPS Date]),
	SecondPickupCityState = (select Top 1 IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') from city (NOLOCK),stops (NOLOCK) where stp_city = cty_code and stops.lgh_number = [Leg Header Number] and stops.stp_mfh_sequence = SecondPickUpSequence),
	SecondDropCityState = (select Top 1 IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') from city (NOLOCK),stops (NOLOCK) where stp_city = cty_code and stops.lgh_number = [Leg Header Number] and stops.stp_mfh_sequence = SecondDropSequence)

from

(

Select 
	Lgh_number	'Leg Header Number',
	l.mov_number 	'Move Number',
	l.ord_hdrnumber 'Order Header Number',
	(select ord_refnum from orderheader (NOLOCK) where orderheader.ord_hdrnumber = l.ord_hdrnumber) as 'Reference Number',

	--Added Tractor 
	Case When (select 'Y' from tractorprofile (NOLOCK)  where trc_number = lgh_tractor and trc_retiredate > GetDate()) = 'Y' Then
		'Y'
	Else
	        'N'
	End as 'TractorActiveYN',


	convert(money,IsNull(dbo.fnc_allocatedTotOrdRevByMiles(lgh_number),0.00)) as 'Revenue',
	IsNull(dbo.fnc_allocatedTotOrdLineHaulRevByMiles(lgh_number),0.00) as 'LineHaul Revenue',	
        Pay = IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) from paydetail (NOLOCK) where lgh_number=l.lgh_number and pyd_minus = 1),0.00) ,
	[TaxableCompensationPay]=
			IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
				from   paydetail (NOLOCK) 
				where  paydetail.lgh_number=l.lgh_number
		       		       and 
		      	 	       pyd_pretax = 'Y'),0.00),
	[ReleasedTaxableCompensationPay]=
			IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
				from   paydetail (NOLOCK) 
				where  paydetail.lgh_number=l.lgh_number
				       and
				       paydetail.pyd_status = 'REL'
		       		       and 
		      	 	       pyd_pretax = 'Y'),0.00),
	[Driver Pay]=
			IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
				from   paydetail (NOLOCK) 
				where  paydetail.lgh_number=l.lgh_number
				       and
				       asgn_type = 'DRV'
		       		       and 
		      	 	       pyd_pretax = 'Y'),0.00),
	[Tractor Pay]=
			IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
				from   paydetail (NOLOCK) 
				where  paydetail.lgh_number=l.lgh_number
				       and
				       asgn_type = 'TRC'
		       		       and 
		      	 	       pyd_pretax = 'Y'),0.00),
	[Carrier Pay]=
			IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
				from   paydetail (NOLOCK) 
				where  paydetail.lgh_number=l.lgh_number
				       and
				       asgn_type = 'CAR'
		       		       and 
		      	 	       pyd_pretax = 'Y'),0.00),
	IsNull(dbo.fnc_allocatedTotFuelRevByMiles(lgh_number),0.00) as 'Fuel Surcharge',        
	trc_company as 'TRIP Tractor Company',
	trc_division as 'TRIP Tractor Division',
	trc_fleet as 'TRIP Tractor Fleet',
	trc_terminal as 'TRIP Tractor Terminal',
	
	mpp_fleet as 'TRIP Driver Fleet',
	mpp_division as 'TRIP Driver Division',
	mpp_domicile as 'TRIP Driver Domicile',
	mpp_company as 'TRIP Driver Company',
	mpp_terminal as 'TRIP Driver Terminal',

	OrderTrailerType1=
	(Select trl_type1 
	 from   orderheader (NOLOCK)
	 Where  l.ord_hdrnumber = orderheader.ord_hdrnumber
	),

	[Driver Hire Date] = (select mpp_hiredate from manpowerprofile (NOLOCK) where manpowerprofile.mpp_id = lgh_driver1), 

	'CarType1' = IsNull((Select car_type1 from carrier (NOLOCK) where car_id = lgh_carrier),'NA'),
        'CarType2' = IsNull((Select car_type2 from carrier (NOLOCK) where car_id = lgh_carrier),'NA'),
        'CarType3' = IsNull((Select car_type3 from carrier (NOLOCK) where car_id = lgh_carrier),'NA'),
        'CarType4' = IsNull((Select car_type4 from carrier (NOLOCK) where car_id = lgh_carrier),'NA'),

        NumberOfSplitsOnMove= 
		(Select count(distinct L2.lgh_number) 
		From legheader  L2 (NOLOCK) where L2.Mov_number=L.Mov_number
		),

	NumberOfOrdersOnLeg= 
		(Select count(distinct ord_hdrnumber) 
		From stops (NOLOCK) where stops.lgh_number=L.lgh_number and stops.ord_hdrnumber <> 0
		),
        
	NumberOfDropsOnLeg= 
		(Select count(stp_type) 
		From stops (NOLOCK) where stops.lgh_number=L.lgh_number and stops.ord_hdrnumber <> 0 and stops.stp_type = 'DRP'
		),
	
	NumberOfPickUpsOnLeg= 
		(Select count(stp_type) 
		From stops (NOLOCK) where stops.lgh_number=L.lgh_number and stops.ord_hdrnumber <> 0 and stops.stp_type = 'PUP'
		),

	NumberOfOrderStopsOnLeg= 
		(Select count(stp_type) 
		From stops (NOLOCK) where stops.lgh_number=L.lgh_number and stops.ord_hdrnumber <> 0
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
	'Driver1 Other ID' = IsNull((select mpp_otherid from manpowerprofile (NOLOCK) where mpp_id = lgh_driver1),''),
	lgh_driver2	'Driver2 ID',
	'Driver2 Name' = IsNull((select mpp_lastfirst from manpowerprofile (NOLOCK)  where mpp_id = lgh_driver2),''),
	lgh_carrier	'Carrier ID',
        'Carrier Name' = IsNull((select car_name from carrier (NOLOCK)  where car_id = lgh_carrier),''),
	IsNull((select ord_trailer from orderheader (NOLOCK) where orderheader.ord_hdrnumber = L.ord_hdrnumber),lgh_primary_trailer) as 'Primary Trailer ID',
	lgh_primary_trailer as 'Segment Trailer ID',
	--**Segment Start Date**
	lgh_startDate	'Segment Start Date',
	--Day
        (Cast(Floor(Cast([lgh_startDate] as float))as smalldatetime)) as [Segment Start Date Only], 
        Cast(DatePart(yyyy,[lgh_startDate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[lgh_startDate]) as varchar(2)) + '-' + Cast(DatePart(dd,[lgh_startDate]) as varchar(2)) as [Segment Start Day],
        --Month
        Cast(DatePart(mm,[lgh_startDate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[lgh_startDate]) as varchar(4)) as [Segment Start Month],
        DatePart(mm,[lgh_startDate]) as [Segment Start Month Only],
        --Year
        DatePart(yyyy,[lgh_startDate]) as [Segment Start Year],
	--**Segment End Date**
	lgh_EndDate	'Segment End Date',
	--Day
        (Cast(Floor(Cast([lgh_EndDate] as float))as smalldatetime)) as [Segment End Date Only], 
        Cast(DatePart(yyyy,[lgh_EndDate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[lgh_endDate]) as varchar(2)) + '-' + Cast(DatePart(dd,[lgh_endDate]) as varchar(2)) as [End Day],
        --Month
        Cast(DatePart(mm,[lgh_EndDate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[lgh_endDate]) as varchar(4)) as [End Month],
        DatePart(mm,[lgh_EndDate]) as [End Month Only],
        --Year
        DatePart(yyyy,[lgh_EndDate]) as [End Year],
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
	
	'Order Book Date' =
		
		(Select ord_bookdate
		From 	orderheader o (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		),
		

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
		(Select min(ivh_billto)
		 From   invoiceheader I (NOLOCK)
                 where  I.ord_hdrnumber = l.ord_hdrnumber
                        And
                        l.ord_hdrnumber > 0)
		 ,ISNULL(
		  (Select ord_billto
		   From   orderheader o (NOLOCK) 
		   where  o.ord_hdrnumber=l.ord_hdrnumber
			  AND
			  l.ord_hdrnumber>0)
		         ,'')
		     ),

	Case When trc_terminal <> lgh_class1 Then
		'Y'
	Else
		'N'
	End RevType1AndTractorTerminalDifferentYN,

	
	'Booked By' =
		ISNULL(
		(Select ord_bookedby
		From 	orderheader o (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,''),

	'Order Currency' =
		ISNULL(
		(Select ord_currency
		From 	orderheader o (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,''),

	'Pay Currency' =
		ISNULL(
		(Select top 1 pyd_currency
		From 	paydetail (NOLOCK) 
		where 	paydetail.lgh_number=l.ord_hdrnumber
			
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
	
	'Sub Company ID' = (select ord_subcompany from orderheader (NOLOCK) where L.ord_hdrnumber = orderheader.ord_hdrnumber),
	
	'Pay Period DateStr' = 
                 (Select IsNull(cast(max(pyh_payperiod) as varchar(255)),'NotPaid')
                  From   paydetail (NOLOCK)
                  where  L.lgh_number = paydetail.lgh_number
			 And
			 pyd_minus > 0
                  ),	
	
	'Pay Period Date' = 
                 (Select min(pyh_payperiod)
                  From   paydetail (NOLOCK)
                  where  L.lgh_number = paydetail.lgh_number
			 And
			 pyd_minus > 0
                  ),	

	'Pay To' = 
                 (Select min(cast(pyd_payto as char(15)))
                  From   paydetail (NOLOCK)
                  where  L.lgh_number = paydetail.lgh_number
			 And
			 pyd_minus > 0
                  ),	


        lgh_odometerstart as 'Odometer Start',
        lgh_odometerend as 'Odometer End',
        (lgh_odometerend - lgh_odometerstart) as 'Hub Miles',
	lgh_outstatus as 'Dispatch Status',
	convert(float,lgh_enddate - lgh_startdate) * 24 As 'Trip Hours',
        lgh_type1,
	lgh_type2,
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
	
	SecondPickupSequence = (select min(b.stp_mfh_sequence) from stops b (NOLOCK)  where b.lgh_number = l.lgh_number and stp_type = 'PUP' and stp_mfh_sequence > 1 and stp_loadstatus = 'LD'),
	SecondDropSequence = (select min(b.stp_mfh_sequence) from stops b (NOLOCK)  where b.lgh_number = l.lgh_number and stp_type = 'DRP' and stp_mfh_sequence > 1 and stp_loadstatus = 'LD'),


	[Last GPS Date] = (select max(ckc_date) from checkcall (NOLOCK) where l.lgh_number = ckc_lghnumber),

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
GRANT SELECT ON  [dbo].[vTTSTMW_RevVsPay] TO [public]
GO
