SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vSSRSB_MoveAnalysis]

AS

/**
 *
 * NAME:
 * dbo.vSSRSB_MoveAnalysis
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Analysis by move
 
 *
**************************************************************************

Sample call


select * from vSSRSB_MoveAnalysis


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Analysis by Move
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created SSRS version of this view
 **/
Select TripSegment.*,
       (select sum(IsNull(ord_totalweight,0)) from orderheader WITH (NOLOCK) where orderheader.mov_number = [Move Number]) as [Total Weight],
        'Master Bill To Name' = (select cmp_name from company a WITH (NOLOCK) where a.cmp_id = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = [Bill To ID])), 
  	(select count(*) from orderheader WITH (NOLOCK) where orderheader.mov_number = [Move Number]) as [Order Count],
       Case When [Total Miles] = 0 or [Total Miles] Is Null Then
		0
       Else
		Convert(money,(Revenue/[Total Miles]))
       End As RevenuePerTravelMile,

       Case When [Loaded Miles] = 0 or [Loaded Miles] Is Null Then
		0
       Else
		Convert(money,(Revenue/[Loaded Miles]))
       End As RevenuePerLoadedMile,

       Case When [Total Miles] = 0 or [Total Miles] Is Null Then
		0
       Else
	        Convert(float,(IsNull([Empty Miles],0)/convert(float,[Total Miles])))
       End as [Percent Empty],

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
       		 convert(money,([Revenue]/[Hub Miles]))       End as 'LineHaulRevenuePerHubMile',  	


       Case When NumberOfSplitsOnMove = 0 Then
		0
       Else
	        convert(float,1/convert(float,NumberOfSplitsOnMove))
       End as 'Allocated Consolidated Load Count' ,

     
        (SELECT cmp_othertype1 from company WITH (NOLOCK) where [Bill To ID] = cmp_id) 
	 As [Bill to Other Type 1],   
	
	(SELECT cmp_othertype1 from company WITH (NOLOCK) where [Shipper ID] = cmp_id) 
	 As [Shipper Other Type 1], 

       (SELECT cmp_othertype2 from company WITH (NOLOCK) where [Bill To ID] = cmp_id) 
	 As [Bill to Other Type 2],

       (SELECT cmp_othertype2 from company WITH (NOLOCK) where [Shipper ID] = cmp_id) 
	 As [Shipper Other Type 2],	

	'Trailer Company' = (select min(trl_company) from trailerprofile WITH (NOLOCK) where trl_id = [Segment Trailer ID]),    
	'Trailer Fleet' = (select min(trl_fleet) from trailerprofile WITH (NOLOCK) where trl_id = [Segment Trailer ID]),    
	'Trailer Terminal' = (select min(trl_terminal) from trailerprofile WITH (NOLOCK) where trl_id = [Segment Trailer ID]),    
	'Trailer Division' = (select min(trl_division) from trailerprofile WITH (NOLOCK) where trl_id = [Segment Trailer ID]),    
	
	'Driver Division' = IsNull([TRIP Driver Division],(select mpp_division from manpowerprofile WITH (NOLOCK) where mpp_id = [Driver1 ID])),    
	'Driver Domicile' = IsNull([TRIP Driver Domicile],(select mpp_domicile from manpowerprofile WITH (NOLOCK) where mpp_id = [Driver1 ID])),  
	'Driver Fleet' = IsNull([TRIP Driver Fleet],(select mpp_fleet from manpowerprofile WITH (NOLOCK) where mpp_id = [Driver1 ID])),  
	'Driver Terminal' = IsNull([TRIP Driver Terminal],(select mpp_terminal from manpowerprofile WITH (NOLOCK) where mpp_id = [Driver1 ID])),  
	'Driver Company' = IsNull([TRIP Driver Company],(select mpp_company from manpowerprofile WITH (NOLOCK) where mpp_id = [Driver1 ID])),          
 
	'Tractor Company' = IsNull([TRIP Tractor Company],(select trc_company from tractorprofile WITH (NOLOCK) where trc_number = [Tractor ID])),          
	'Tractor Division' = IsNull([TRIP Tractor Division],(select trc_division from tractorprofile WITH (NOLOCK) where trc_number = [Tractor ID])),          
	'Tractor Terminal' = IsNull([TRIP Tractor Terminal],(select trc_terminal from tractorprofile WITH (NOLOCK) where trc_number = [Tractor ID])),          
	'Tractor Fleet' = IsNull([TRIP Tractor Fleet],(select trc_fleet from tractorprofile WITH (NOLOCK) where trc_number = [Tractor ID])),
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
	'Shipper Name' = (select cmp_name from company WITH (NOLOCK) where cmp_id = [Shipper ID]),
 	'Consignee Name' = (select cmp_name from company WITH (NOLOCK) where cmp_id = [Consignee ID]),
	'Bill To Name' = (select cmp_name from company WITH (NOLOCK) where cmp_id = [Bill To ID]),
	Case When [Segment Start City] = [Segment End City] Then
		'Y'
	Else
		'N'
	End as [SameSegmentCityYN],
	[Order Origin City] = (select min(cty_name) from orderheader WITH (NOLOCK),city WITH (NOLOCK) where orderheader.ord_hdrnumber = [Order Header Number] and cty_code = ord_origincity),
	[Order Origin State] = (select min(cty_state) from orderheader WITH (NOLOCK),city WITH (NOLOCK) where orderheader.ord_hdrnumber = [Order Header Number] and cty_code = ord_origincity),
	[Order Dest City] = (select min(cty_name) from orderheader WITH (NOLOCK),city WITH (NOLOCK) where orderheader.ord_hdrnumber = [Order Header Number] and cty_code = ord_destcity),
	[Order Dest State] = (select min(cty_state) from orderheader WITH (NOLOCK),city WITH (NOLOCK) where orderheader.ord_hdrnumber = [Order Header Number] and cty_code = ord_destcity),
	cast (round(((1.0 * Pay)/case when Revenue = 0 Then 1 Else Revenue End) , 4) * 100 as int) as 'PayPercentage'
	
	       
from

(

Select 
	l.Lgh_number	'Leg Number',
	l.mov_number 	'Move Number',
	l.ord_hdrnumber 'Order Header Number',
	(select ord_refnum from orderheader WITH (NOLOCK) where orderheader.ord_hdrnumber = l.ord_hdrnumber) as 'Reference Number',
	[Hub Basis] = IsNull((select Min('DHub') from invoicedetail WITH (NOLOCK) where invoicedetail.ord_hdrnumber = l.ord_hdrnumber and cht_basisunit = 'DHUB'),'Other'),
	--Added Tractor 
	Case When (select 'Y' from tractorprofile WITH (NOLOCK)  where trc_number = lgh_tractor and trc_retiredate > GetDate()) = 'Y' Then
		'Y'
	Else
	        'N'
	End as 'TractorActiveYN',
	

	 (
	   convert(money,IsNull((select sum(a.ord_totalcharge) from orderheader a where a.mov_number = l.mov_number and a.ord_invoicestatus <> 'PPD' and a.ord_status <> 'CAN'),0.00)) 
		+   
	   convert(money,IsNull((select sum(a.ivh_totalcharge) from invoiceheader a where a.mov_number = l.mov_number and a.ivh_invoicestatus <> 'CAN'),0.00))
            )
           As 'Revenue',

	[Fuel Surcharge] = (SELECT
                                                        
                                sum(IsNull(ivd_charge,0.00))

                        FROM    invoicedetail WITH (NOLOCK) Inner Join chargetype WITH (NOLOCK) On invoicedetail.cht_itemcode=chargetype.cht_itemcode 

                                                       Inner Join orderheader WITH (NOLOCK) On orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber 

                        WHERE 
                                ( 
                                   (orderheader.mov_number = l.mov_number And orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber )

                                              
                                )                                       
                                AND 
                                ( 
                                        Upper(chargetype.cht_itemcode) like 'FUEL%' 
                                        OR 
                                        CharIndex('FUEL', cht_description)>0 
                                ) 
                                and ivd_charge is Not Null) ,	


			
	(
	   convert(money,IsNull((select sum(a.ord_charge) from orderheader a where a.mov_number = l.mov_number and a.ord_invoicestatus <> 'PPD' and a.ord_status <> 'CAN'),0.00)) 
		+   
	   convert(money,IsNull((select sum(a.ivh_charge) from invoiceheader a where a.mov_number = l.mov_number and a.ivh_invoicestatus <> 'CAN'),0.00))
            )
           As 'LineHaul Revenue',


	Pay=IsNull((Select sum(IsNull(pyd_amount,0)) 
	from paydetail p WITH (NOLOCK)
	where 	p.lgh_number=l.lgh_number
		and
		p.pyd_pretax='Y'
	),0),

	trc_company as 'TRIP Tractor Company',
	trc_division as 'TRIP Tractor Division',
	trc_fleet as 'TRIP Tractor Fleet',
	trc_terminal as 'TRIP Tractor Terminal',
	
	mpp_fleet as 'TRIP Driver Fleet',
	mpp_division as 'TRIP Driver Division',
	mpp_domicile as 'TRIP Driver Domicile',
	mpp_company as 'TRIP Driver Company',
	mpp_terminal as 'TRIP Driver Terminal',

	'CarType1' = IsNull((Select car_type1 from carrier WITH (NOLOCK) where car_id = lgh_carrier),'NA'),
        'CarType2' = IsNull((Select car_type2 from carrier WITH (NOLOCK) where car_id = lgh_carrier),'NA'),
        'CarType3' = IsNull((Select car_type3 from carrier WITH (NOLOCK) where car_id = lgh_carrier),'NA'),
        'CarType4' = IsNull((Select car_type4 from carrier WITH (NOLOCK) where car_id = lgh_carrier),'NA'),

        NumberOfSplitsOnMove= 
		(Select count(distinct L2.lgh_number) 
		From legheader  L2 WITH (NOLOCK) where L2.Mov_number=L.Mov_number
		),

	NumberOfOrdersOnMove= 
		(Select count(distinct ord_hdrnumber) 
		From stops WITH (NOLOCK) where stops.mov_number=L.mov_number and stops.ord_hdrnumber <> 0
		),
        
	NumberOfDropsOnMove= 
		(Select count(stp_type) 
		From stops WITH (NOLOCK) where stops.mov_number=L.mov_number and stops.ord_hdrnumber <> 0 and stops.stp_type = 'DRP'
		),
	
	NumberOfPickUpsOnMove= 
		(Select count(stp_type) 
		From stops WITH (NOLOCK) where stops.mov_number=L.mov_number and stops.ord_hdrnumber <> 0 and stops.stp_type = 'PUP'
		),
	'Total Miles' = IsNull((select sum(stp_lgh_mileage) from stops WITH (NOLOCK) where stops.mov_number = l.mov_number),0),
 	'Empty Miles' = IsNull((select sum(stp_lgh_mileage) from stops WITH (NOLOCK) where stops.mov_number = l.mov_number and stp_loadstatus <> 'LD'),0),
        'Loaded Miles' = IsNull((select sum(stp_lgh_mileage) from stops WITH (NOLOCK) where stops.mov_number = l.mov_number and stp_loadstatus = 'LD'),0),

    

	lgh_tractor	'Tractor ID',
	lgh_driver1	'Driver1 ID',
	'Driver1 Name' = IsNull((select mpp_lastfirst from manpowerprofile WITH (NOLOCK)  where mpp_id = lgh_driver1),''),
	lgh_driver2	'Driver2 ID',
	'Driver2 Name' = IsNull((select mpp_lastfirst from manpowerprofile WITH (NOLOCK)  where mpp_id = lgh_driver2),''),
	lgh_carrier	'Carrier ID',
        'Carrier Name' = IsNull((select car_name from carrier WITH (NOLOCK)  where car_id = lgh_carrier),''),
	IsNull((select ord_trailer from orderheader WITH (NOLOCK) where orderheader.ord_hdrnumber = L.ord_hdrnumber),lgh_primary_trailer) as 'Primary Trailer ID',
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
		 From	company c WITH (NOLOCK)
		 where	l.cmp_id_start = c.cmp_id
	  	 	AND
			l.ord_hdrnumber>0),
	
	
	'Segment End CmpName' 	= 
		(Select	c.cmp_name
		 From	company c WITH (NOLOCK)
		 where	l.cmp_id_end = c.cmp_id
	  	 	AND
			l.ord_hdrnumber>0),	

		'Order Ship Date'	= lgh_rstartdate,

	'Order Delivery Date' = lgh_renddate,
	
	'Shipper ID' =
		ISNULL(
		(Select ord_shipper
		From 	orderheader o WITH (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,''),

	'Consignee ID' =
		ISNULL(
		(Select ord_consignee
		From 	orderheader o WITH (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,''),

	'Ordered By ID' =
		ISNULL(
		(Select ord_company
		From 	orderheader o WITH (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,''),

	'Bill To ID' =
		ISNULL(
		(Select ord_billto
		From 	orderheader o WITH (NOLOCK) 
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,''),

	'Revenue Date' = 
                 (Select min(ivh_revenue_date)
                 From   invoiceheader I WITH (NOLOCK) 
                 where  I.ord_hdrnumber = l.ord_hdrnumber
                        And
                        l.ord_hdrnumber > 0 
                  ),
      
        'Transfer Date' = 
                 (Select min(ivh_xferdate)
                 From   invoiceheader I WITH (NOLOCK)
                 where  I.ord_hdrnumber = l.ord_hdrnumber
                        And
                        l.ord_hdrnumber > 0 
                  ),
        
        'Bill Date' = 
                 (Select min(ivh_billdate)
                 From   invoiceheader I WITH (NOLOCK)
                 where  I.ord_hdrnumber = l.ord_hdrnumber
                        And
                        l.ord_hdrnumber > 0 
                  ),	
	
	'Sub Company ID' = (select ord_subcompany from orderheader WITH (NOLOCK) where L.ord_hdrnumber = orderheader.ord_hdrnumber),
	

	'Pay Period Date' = pyh_payperiod,
	(Cast(Floor(Cast(pyh_payperiod as float))as smalldatetime)) AS [Pay Period Date Only],
	'Pay Period DateStr' = 
                 (Select IsNull(cast(max(pyh_payperiod) as varchar(255)),'NotPaid')
                  From   paydetail WITH (NOLOCK)
                  where  L.lgh_number = paydetail.lgh_number
			 And
			 pyd_minus > 0
                  ),	
	
	'Pay To' = 
                 (Select min(cast(pyd_payto as char(15)))
                  From   paydetail WITH (NOLOCK)
                  where  L.lgh_number = paydetail.lgh_number
			 And
			 pyd_minus > 0
                  ),	


        lgh_odometerstart as 'Odometer Start',
        lgh_odometerend as 'Odometer End',
        (lgh_odometerend - lgh_odometerstart) as 'Hub Miles',
	lgh_outstatus as 'DispatchStatus',
	convert(float,lgh_enddate - lgh_startdate) * 24 As 'Trip Hours',
        lgh_type1,
	lgh_type2,
	
	IsNull((select cty_zip from city WITH (NOLOCK) where cty_code = l.lgh_startcity),'') as 'Trip Origin Zip Code',
	IsNull((select cty_zip from city WITH (NOLOCK) where cty_code = l.lgh_endcity),'') as 'Trip Destination Zip Code',
	
    (select Top 1 b.lgh_startstate  
    from legheader b WITH (NOLOCK) 
    where b.mov_number = l.mov_number and b.lgh_startdate = (select min(c.lgh_startdate) 
				from legheader c WITH (NOLOCK)where c.mov_number = b.mov_number)) as [Move Start State],
	(select Top 1 b.lgh_endstate  
		from legheader b WITH (NOLOCK) where b.mov_number = l.mov_number and b.lgh_enddate = (select max(c.lgh_enddate) 
		from legheader c WITH (NOLOCK)where c.mov_number = b.mov_number)) as [Move End State]
From 
	Legheader l WITH (NOLOCK) 
	left join paydetail WITH (NOLOCK) on paydetail.lgh_number = l.lgh_number 
	and paydetail.pyd_number = (select max(b.pyd_number) 
	from paydetail b WITH (NOLOCK) 
	where b.pyd_minus > 0 
	and b.lgh_number = paydetail.lgh_number)
Where   l.lgh_number = (select max(b.lgh_number) from legheader b WITH (NOLOCK) where b.mov_number = l.mov_number and b.lgh_outstatus <> 'CAN')
	

) as TripSegment

GO
GRANT SELECT ON  [dbo].[vSSRSB_MoveAnalysis] TO [public]
GO
