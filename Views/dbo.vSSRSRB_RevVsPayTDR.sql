SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vSSRSRB_RevVsPayTDR]

AS
/**
 *
 * NAME:
 * dbo.vSSRSRB_RevVsPay
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 * select * from [vSSRSRB_RevVsPay]
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 * 06/05/2014 -- MREED -- added shiftschedules as used in fuel dispatch
 * 10/9/2014 JR - put in case statement to allow for clients without a shiftschedules table and removed
 left outer join to shiftschedules
 **/
SELECT 
	([Revenue] - [LineHaul Revenue]) as [Accessorial Revenue],
    CASE WHEN NumberOfSplitsOnMove = 0 
		 THEN 0
	ELSE convert(float,1/convert(float,NumberOfSplitsOnMove))
	END as [Allocated Consolidated Load Count], 
	[Bill Date],
	(Cast(Floor(Cast([Bill Date] AS float))as smalldatetime)) as [Bill Date Only],	    
	[Bill Day] =
		Cast(DatePart(yyyy,[Bill Date]) as varchar(4)) +  '-' + Cast(DatePart(mm,[Bill Date]) as varchar(2))
			+ '-' + Cast(DatePart(dd,[Bill Date]) as varchar(2)),
    [Bill Month] =
		Cast(DatePart(mm,[Bill Date]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[Bill Date]) as varchar(4)),				
    DatePart(mm,[Bill Date]) as [Bill Month Only],
    [Bill To Name] = (select cmp_name from company WITH (NOLOCK) where cmp_id = [Bill To ID]),
    [Bill To ID],			
	DatePart(yyyy,[Bill Date]) as [Bill Year],
	[BOL Number],
	[Booked By],
    [Booked RevType1],
    [Carrier ID],
    [Carrier Name],
    [Carrier Pay],
    [CarType1],
    [CarType2],
    [CarType3],
    [CarType4],
    [Comment],
    [Commodity Code],
    [Consignee Name],
    [Consignee ID],   
    (CAST(FLOOR(CAST([Order Delivery Date] AS float))AS smalldatetime)) as [Delivery Date Only],
    [Delivery Day] =
		CAST(DATEPART(yyyy,[Order Delivery Date]) as varchar(4)) +  '-' + CAST(DATEPART(mm,[Order Delivery Date]) as varchar(2)) 
			+ '-' + CAST(DATEPART(dd,[Order Delivery Date]) as varchar(2)),
	[Delivery Month] =
		CAST(DATEPART(mm,[Order Delivery Date]) as varchar(2)) + '/' + CAST(DATEPART(yyyy,[Order Delivery Date]) as varchar(4)),	
	DATEPART(mm,[Order Delivery Date]) as [Delivery Month Only],
    DATEPART(yyyy,[Order Delivery Date]) as [Delivery Year],
	[DispatchStatus],
    [Driver Company],
    [Driver Division],
    [Driver Domicile],
    [Driver Fleet],
    [Driver Hire Date],
	[Driver Pay],
	[Driver Terminal],
	[Driver1 ID],
	[Driver1 Name],
	[Driver1 Other ID],
	[Driver2 ID],
	[Driver2 Name],
	[DrvType1],
	[DrvType2],
	[DrvType3],
	[DrvType4],
	[Empty Billed Miles],
	[Empty Miles],
	[Fleet],
	[Freight Description],
	[Fuel Surcharge],
	CASE WHEN [Revenue] = 0 or [Revenue] Is Null
		 THEN 0
    ELSE Convert(float,(IsNull([Fuel Surcharge],0)/convert(float,[Revenue])))
    END AS [FuelSurchargePercentofRevenue],
    [Hub Miles],
    [Last GPS Date],
    [Last GPS Location] =
		(SELECT TOP 1 ckc_comment 
			FROM checkcall WITH (NOLOCK) 
			WHERE [Leg Number] = ckc_lghnumber and ckc_date = [Last GPS Date]),
	[Leg Hauler],
    [Leg Number],
	
	[LineHaul Pay],
	[LineHaul Revenue],
	CASE WHEN [Hub Miles] = 0 
		 THEN 0
	ELSE convert(money,([LineHaul Revenue]/[Hub Miles]))
    END AS [LineHaulRevenuePerHubMile], 
	CASE WHEN [Loaded Miles] = 0 or [Loaded Miles] Is Null
		 THEN 0
    ELSE Convert(money,([LineHaul Revenue]/[Loaded Miles]))
    END AS [LineHaulRevenuePerLoadedMile],
    [Loaded Billed Miles],
	[Loaded Miles],
	CASE WHEN [Revenue] = 0 or [Revenue] Is Null 
		 THEN 0
    ELSE CONVERT(MONEY,(([Revenue]-[Pay])/[Revenue]))
    END AS [Margin],
	[Master Bill To] = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = [Bill To ID]),
	[Monitor Party],
	[Move Number],
	([Revenue]-[Pay]) AS [Net],
    CASE WHEN [Loaded Miles] = 0 or [Loaded Miles] Is Null 
		 THEN 0
    ELSE CONVERT(MONEY,(([Revenue]-[Pay])/[Loaded Miles]))
    END AS [NetPerLoadedMile],
    CASE WHEN [Total Miles] = 0 or [Total Miles] Is Null 
		THEN 0
    ELSE Convert(money,(([Revenue]-[Pay])/[Total Miles]))
    END AS [NetPerTravelMile],
    [NumberOfDropsOnLeg],
    [NumberOfOrdersOnLeg],
    [NumberOfOrderStopsOnLeg],
    [NumberOfPickUpsOnLeg],
	[NumberOfSplitsOnMove],
	[NumberOfStopsOnLeg],
	[Odometer End],
	[Odometer Start],
	[Order Book Date],
	[Order Currency],
	[Order Delivery Date],
	[Order Dest City],
	[Order Dest State],
	[Order Header Number],
	[Order Number],
	[Order Origin City],
	[Order Origin State],
	[Order Ship Date],
	(CAST(FLOOR(CAST([Order Ship Date] AS float))AS smalldatetime))AS [Order Ship Date Only],	
	[Order Ship Day] =
		CAST(DATEPART(yyyy,[Order Ship Date]) AS varchar(4)) +  '-' + CAST(DATEPART(mm,[Order Ship Date]) AS varchar(2)) 
			+ '-' + Cast(DatePart(dd,[Order Ship Date]) AS varchar(2)),
	CASE DatePart(dw,[Order Ship Date]) WHEN 1 THEN 'Sunday'
                 			    WHEN 2 THEN 'Monday'
                 			    WHEN 3 THEN 'Tuesday'
                 			    WHEN 4 THEN 'Wednesday'
                 			    WHEN 5 THEN 'Thursday'
                 			    WHEN 6 THEN 'Friday'
                 			    WHEN 7 THEN 'Saturday'
                 			    ELSE SPACE(0)
    END AS [Order Ship DayOfWeek],
    [Order Ship Month] = 
		CAST(DATEPART(mm,[Order Ship Date]) AS varchar(2)) + '/' + Cast(DatePart(yyyy,[Order Ship Date]) AS varchar(4)),
	DatePart(mm,[Order Ship Date]) as [Order Ship Month Only],
	DatePart(yyyy,[Order Ship Date]) as [Order Ship Year],
	[OrderStatus],
	[Ordered By ID],
	[OrderTrailerType1],
	[Billto Other Type1] = (SELECT cmp_othertype1 from company WITH (NOLOCK) where [Bill To ID] = cmp_id),
	[Billto Other Type2] =(SELECT cmp_othertype2 from company WITH (NOLOCK) where [Bill To ID] = cmp_id),
	[Pay],
	[Pay Currency],	
	[Pay Period Date],
	[Pay Period DateStr],
	[Pay Period Month]
		= CAST(DATEPART(mm,[Pay Period Date]) AS varchar(2)) + '/' + Cast(DatePart(yyyy,[Pay Period Date]) AS varchar(4)),	
	DatePart(mm,[Pay Period Date]) as [Pay Period Month Only],
	[Pay To],	
	CASE WHEN [Total Miles] = 0 or [Total Miles] Is Null
		 THEN 0
    ELSE round((IsNull([Empty Miles],0)/convert(float,[Total Miles])),2)
    END AS [Percent Empty], 
	[Primary Trailer ID],
	[Reference Number],
	[ReleasedTaxableCompensationPay],
	[Revenue],
	[Revenue Date],
	CASE WHEN NumberOfSplitsOnMove = 0 
		 THEN 0
    ELSE convert(money,[Revenue] * convert(float,1/convert(float,NumberOfSplitsOnMove)))
    END AS [Revenue Per Load],    
    CASE WHEN [Hub Miles] = 0 
		 THEN 0
    ELSE convert(money,([Revenue]/[Hub Miles]))
    END AS [RevenuePerHubMile],
    CASE WHEN [Loaded Miles] = 0 or [Loaded Miles] Is Null 
		 THEN 0
    ELSE CONVERT(MONEY,(Revenue/[Loaded Miles]))
    END AS [RevenuePerLoadedMile],
    CASE WHEN [Total Miles] = 0 or [Total Miles] Is Null 
		THEN 0
    ELSE Convert(money,(Revenue/[Total Miles]))
    END AS [RevenuePerTravelMile],
    [RevType1],
    [RevType1 Code],
    [RevType1 Name],    
    [RevType1AndTractorTerminalDifferentYN],
    [RevType2],
    [RevType2 Code],
    [RevType2 Name],
    [RevType3],
    [RevType3 Code],
    [RevType3 Name],
    [RevType4],
    [RevType4 Code],
    [RevType4 Name],    
    [SameSegmentCityYN],
	[SecondDropCityState] =
		(SELECT TOP 1 ISNULL(cty_name,'') + ', ' + IsNull(cty_state,'') 
			FROM city WITH (NOLOCK),stops WITH (NOLOCK) 
			WHERE stp_city = cty_code and stops.lgh_number = [Leg Number] and stops.stp_mfh_sequence = SecondDropSequence
		 ),
    [SecondDropSequence],
    [SecondPickupCityState] =
		(SELECT TOP 1 ISNULL(cty_name,'') + ', ' + IsNull(cty_state,'') 
			FROM city WITH (NOLOCK),stops WITH (NOLOCK) 
			WHERE stp_city = cty_code and stops.lgh_number = [Leg Number] and stops.stp_mfh_sequence = SecondPickUpSequence
		 ),
	[SecondPickupSequence],
	[Segment End City],
	[Segment End CmpID],
	[Segment End CmpName],	
	[Segment End Date],
	[Segment End Date Only],
	[Segment End Day],	
	[Segment End Month],
	[Segment End Month Only],
	[Segment End Region1],
	[Segment End State],
	[Segment End Year],
	[Segment Start City],
	[Segment Start CmpID],
	[Segment Start CmpName],
	[Segment Start Date],
	[Segment Start Date Only],	
	[Segment Start Day],
	[Segment Start Month],
	[Segment Start Month Only],	
	[Segment Start Region1],
	[Segment Start State],
	[Segment Start Year],
	[Segment Status],
	[Segment Trailer ID],
	[Shipper Name],
	[Shipper ID],
	[Shipper OtherType1] = (SELECT cmp_othertype1 from company WITH (NOLOCK) where [Shipper ID] = cmp_id),
	[Shipper OtherType2] = (SELECT cmp_othertype2 from company WITH (NOLOCK) where [Shipper ID] = cmp_id),	
	[Sub Company ID],
	[TaxableCompensationPay],
	[Team Leader ID],
	[Total Billed Miles],
	[Total Miles],
	[Tractor Company],
	[Tractor Division],
	[Tractor Fleet],
	[Tractor ID],
	[Tractor Pay],
	[Tractor Terminal],
	[TractorActiveYN],
	[Trailer Company],
	[Trailer Division],
	[Trailer Fleet],
	[Trailer Terminal],	
	[Transfer Date],
	(CAST(FLOOR(CAST([Transfer Date] AS float))AS smalldatetime)) AS [Transfer Date Only],
	[Transfer Day] =
			CAST(DATEPART(yyyy,[Transfer Date]) AS varchar(4)) +  '-' + Cast(DatePart(mm,[Transfer Date]) AS varchar(2))  
				+ '-' + CAST(DATEPART(dd,[Transfer Date]) AS varchar(2)),
	[Transfer Month] =
			CAST(DATEPART(mm,[Transfer Date]) AS varchar(2)) + '/' + CAST(DATEPART(yyyy,[Transfer Date]) AS varchar(4)),					
	DatePart(mm,[Transfer Date]) as [Transfer Month Only],	
	DatePart(yyyy,[Transfer Date]) AS [Transfer Year],	
	[TrcType1],
    [TrcType2],
    [TrcType3],
    [TrcType4],
    [Trip Destination Zip Code],
    [TRIP Driver Company],
    [TRIP Driver Division],
    [TRIP Driver Domicile],
    [TRIP Driver Fleet],
    [TRIP Driver Terminal],
    [Trip Hours],
    [Trip Origin Zip Code],
    [TRIP Tractor Company],
    [TRIP Tractor Division],
    [TRIP Tractor Fleet],
    [TRIP Tractor Terminal],
    [TrlType1],
    [TrlType2],
    [TrlType3],
    [TrlType4]
	,cerradapor
			
FROM

(
SELECT	
	'Bill Date' = 
             (SELECT min(ivh_billdate)
				FROM invoiceheader I WITH (NOLOCK)
				WHERE I.ord_hdrnumber = lgh.ord_hdrnumber AND lgh.ord_hdrnumber > 0 
              ),		
	'Bill To ID' =
		ISNULL(
			(SELECT min(ivh_billto)
				FROM   invoiceheader I WITH (NOLOCK)
				WHERE  I.ord_hdrnumber = lgh.ord_hdrnumber AND lgh.ord_hdrnumber > 0),
			ISNULL(ordstrt.ord_billto,'')
			 ),
	'BOL Number' = (Select Top 1 ref_number
	   From   ReferenceNumber WITH (NOLOCK)  
	   Where  (ref_type = 'BL#' or ref_type = 'BOL' or ref_type = 'B/L#')
                	   and 
                	   (ord.ord_hdrnumber = referencenumber.ref_tablekey and ref_table = 'stops')
				),	 
	ISNULL(ordstrt.ord_bookedby,'') AS 'Booked By', 
	'' as 'Booked RevType1',
	lgh_carrier AS 'Carrier ID',
	ISNULL(car.car_name,'') as 'Carrier Name', 
	'Carrier Pay'=
		ISNULL((SELECT SUM(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
					FROM paydetail WITH (NOLOCK) 
					WHERE paydetail.lgh_number=lgh.lgh_number AND asgn_type = 'CAR' AND pyd_pretax = 'Y'),
	      	 	0.00), 
	      	 	
	ISNULL(car.car_type1,'NA') as CarType1, 
	ISNULL(car.car_type2,'NA') as CarType2,
	ISNULL(car.car_type3,'NA') as CarType3, 
	ISNULL(car.car_type4,'NA') as CarType4, 
	'' as [Comment],
	lgh.cmd_code AS 'Commodity Code', 
	'Consignee Name' = 
		(SELECT cmp_name 
			FROM company WITH (NOLOCK) 
			WHERE cmp_id = ISNULL(ordstrt.ord_consignee,'')),
	ISNULL(ordstrt.ord_consignee,'') as 'Consignee ID', 
	lgh_outstatus as 'DispatchStatus',
	
	ISNULL(lgh.mpp_company,drv1.mpp_company) AS 'Driver Company',   
	ISNULL(lgh.mpp_division,drv1.mpp_division) AS 'Driver Division', 
	ISNULL(lgh.mpp_domicile,drv1.mpp_domicile) AS 'Driver Domicile', 
	ISNULL(lgh.mpp_fleet,drv1.mpp_fleet) AS 'Driver Fleet', 
	drv1.mpp_hiredate as 'Driver Hire Date',
	     	 	 
	'Driver Pay'=
		ISNULL((SELECT SUM(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
					FROM paydetail WITH (NOLOCK) 
					WHERE paydetail.lgh_number=lgh.lgh_number AND asgn_type = 'DRV' AND pyd_pretax = 'Y'),
				0.00),
				
	IsNull(lgh.mpp_terminal,drv1.mpp_terminal) AS 'Driver Terminal', 
				
	lgh_driver1 AS 'Driver1 ID',
	ISNULL(drv1.mpp_lastfirst,'') AS 'Driver1 Name', 
	ISNULL(drv1.mpp_otherid,'') AS 'Driver1 Other ID', 
	lgh_driver2 AS 'Driver2 ID',
	ISNULL(drv2.mpp_lastfirst,'') AS 'Driver2 Name', 	
	lgh.mpp_type1 AS DrvType1, 
	lgh.mpp_type2 AS DrvType2, 
	lgh.mpp_type3 AS DrvType3, 
	lgh.mpp_type4 AS DrvType4, 
			
	'Empty Billed Miles' = 
		ISNULL((SELECT SUM(ISNULL(stp_ord_mileage,0)) 
					FROM stops WITH (NOLOCK) 
					WHERE stops.lgh_number = lgh.lgh_number and stp_loadstatus <> 'LD' and stops.ord_hdrnumber > 0),
				0),
				
 	'Empty Miles' = 
 		ISNULL((SELECT SUM(ISNULL(stp_lgh_mileage,0)) 
 					FROM stops WITH (NOLOCK) 
 					WHERE stops.lgh_number = lgh.lgh_number and stp_loadstatus <> 'LD'),
 				0),
 				
 	lgh.mpp_fleet AS Fleet, 
 	fgt_description AS 'Freight Description', 	
 	(lgh_odometerend - lgh_odometerstart) as 'Hub Miles',			
	IsNull(dbo.TMWSSRS_fnc_allocatedTotFuelRevByMiles(lgh_number),0.00) as 'Fuel Surcharge', 
	[Last GPS Date] = 
		(SELECT MAX(ckc_date) 
			FROM checkcall WITH (NOLOCK) 
			WHERE lgh.lgh_number = ckc_lghnumber),
	lgh_type2 as 'Leg Hauler', 			
	lgh_number AS 'Leg Number',
	'LineHaul Pay'=
		ISNULL((SELECT SUM(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
					FROM paydetail WITH (NOLOCK)
					join paytype WITH (NOLOCK) on paydetail.pyt_itemcode = paytype.pyt_itemcode 
					WHERE paydetail.lgh_number=lgh.lgh_number 
			        AND paytype.pyt_basis = 'LGH' AND paydetail.pyd_pretax = 'Y'),
			    0.00),
		      	 	       	
	IsNull(dbo.TMWSSRS_fnc_allocatedTotOrdLineHaulRevByMiles(lgh_number),0.00) AS 'LineHaul Revenue',
		
	'Loaded Billed Miles' = 
		ISNULL((SELECT SUM(ISNULL(stp_ord_mileage,0)) 
					FROM stops WITH (NOLOCK) 
					WHERE stops.lgh_number = lgh.lgh_number and stp_loadstatus = 'LD' and stops.ord_hdrnumber > 0),
				0),
				
	'Loaded Miles' = 
		ISNULL((SELECT SUM(ISNULL(stp_lgh_mileage,0)) 
					FROM stops WITH (NOLOCK) 
					WHERE stops.lgh_number = lgh.lgh_number and stp_loadstatus = 'LD'),
				0),
				
	lgh_type1 as 'Monitor Party',
	lgh.mov_number AS 'Move Number',
	
	NumberOfDropsOnLeg = 
		(SELECT COUNT(stp_type) 
			FROM STOPS WITH (NOLOCK) 
			WHERE stops.lgh_number=lgh.lgh_number and stops.ord_hdrnumber <> 0 and stops.stp_type = 'DRP'
		),			
	NumberOfOrdersOnLeg = 
		(SELECT COUNT(distinct ord_hdrnumber) 
			FROM STOPS WITH (NOLOCK) 
			WHERE stops.lgh_number=lgh.lgh_number and stops.ord_hdrnumber <> 0
		),
	NumberOfOrderStopsOnLeg =  
		(SELECT COUNT(stp_type) 
			FROM STOPS WITH (NOLOCK) 
			WHERE stops.lgh_number=lgh.lgh_number and stops.ord_hdrnumber <> 0
		),			
	NumberOfPickUpsOnLeg =
		(SELECT COUNT(stp_type) 
			FROM STOPS WITH (NOLOCK) 
			WHERE stops.lgh_number=lgh.lgh_number and stops.ord_hdrnumber <> 0 AND stops.stp_type = 'PUP'
		),		        
	NumberOfSplitsOnMove = 
		(SELECT COUNT(distinct L2.lgh_number) 
			FROM legheader L2 WITH (NOLOCK) 
			WHERE L2.Mov_number=lgh.Mov_number
		),	
	NumberOfStopsOnLeg = 
		(SELECT COUNT(stp_type) 
			from stops WITH (NOLOCK) 
			WHERE stops.lgh_number=lgh.lgh_number
		),
	
	lgh_odometerend as 'Odometer End',
    lgh_odometerstart as 'Odometer Start',	
	ordstrt.ord_bookdate AS 'Order Book Date', --'Order Book Date'
	ISNULL(ordstrt.ord_currency,'') AS 'Order Currency', --'Order Currency'
	
	'Order Dest City' = 
	(SELECT MIN(cty_name) 
		FROM city WITH (NOLOCK) 
		WHERE ord.ord_hdrnumber = lgh.ord_hdrnumber and city.cty_code = ord.ord_destcity),		
	'Order Dest State' = 
		(SELECT MIN(cty_state) 
			FROM city WITH (NOLOCK) 
			WHERE ord.ord_hdrnumber = lgh.ord_hdrnumber and city.cty_code = ord.ord_destcity),
			
	ISNULL(ordstrt.ord_completiondate,lgh_enddate) AS 'Order Delivery Date', --'Order Delivery Date' 	
	lgh.ord_hdrnumber AS 'Order Header Number',
	ord.ord_number AS 'Order Number', --'Order Number'
	
	'Order Origin City' = 
		(SELECT MIN(cty_name) 
			FROM city WITH (NOLOCK) 
			WHERE ord.ord_hdrnumber = lgh.ord_hdrnumber and city.cty_code = ord.ord_origincity),
				
	'Order Origin State' = 
		(SELECT MIN(cty_state) 
			FROM city WITH (NOLOCK) 
			WHERE ord.ord_hdrnumber = lgh.ord_hdrnumber and city.cty_code = ord.ord_origincity),
	
	ISNULL(ordstrt.ord_startdate,lgh_startdate) AS 'Order Ship Date', --'Order Ship Date'	
	ordstrt.ord_status as 'OrderStatus',
	ISNULL(ordstrt.ord_company,'') as 'Ordered By ID', --'Ordered By ID'	
	ord.trl_type1 AS 'OrderTrailerType1',-- 'OrderTrailerType1'

	Pay = ISNULL((SELECT SUM(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
						FROM paydetail WITH (NOLOCK) 
						WHERE lgh_number=lgh.lgh_number and pyd_minus = 1),
					0.00),
					
	'Pay Currency' =
		ISNULL(
			(SELECT TOP 1 pyd_currency
				FROM paydetail WITH (NOLOCK) 
				WHERE paydetail.lgh_number=lgh.lgh_number
			)
			,''),
			
	'Pay Period Date' = 
             (SELECT MIN(pyh_payperiod)
				FROM paydetail WITH (NOLOCK)
				WHERE lgh.lgh_number = paydetail.lgh_number AND pyd_minus > 0
	          ),	

	'Pay Period DateStr' = 
             (SELECT ISNULL(CAST(MAX(pyh_payperiod) AS varchar(255)),'NotPaid')
				FROM paydetail WITH (NOLOCK)
				WHERE lgh.lgh_number = paydetail.lgh_number AND pyd_minus > 0
              ),					
	'Pay To' = 
             (SELECT MIN(CAST(pyd_payto as char(15)))
				FROM paydetail WITH (NOLOCK)
				WHERE lgh.lgh_number = paydetail.lgh_number AND pyd_minus > 0
              ),
	
	ISNULL(ord.ord_trailer,lgh_primary_trailer) AS 'Primary Trailer ID', --'Primary Trailer ID',  				
	ord.ord_refnum AS 'Reference Number', --'Reference Number'	
	
	ReleasedTaxableCompensationPay =
		ISNULL((SELECT SUM(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
					FROM paydetail WITH (NOLOCK) 
					WHERE paydetail.lgh_number=lgh.lgh_number AND paydetail.pyd_status = 'REL' AND pyd_pretax = 'Y'),
				0.00),	
					
	Revenue = convert(money,IsNull(dbo.TMWSSRS_fnc_allocatedTotOrdRevByMiles(lgh_number),0.00)),
	'Revenue Date' = 
                 (Select min(ivh_revenue_date)
                 From   invoiceheader I WITH (NOLOCK) 
                 where  I.ord_hdrnumber = lgh.ord_hdrnumber AND lgh.ord_hdrnumber > 0 
                  ),     
		
	lgh_class1 AS RevType1,
	ISNULL(revtype1.code,'') as 'RevType1 Code', --'RevType1 Code'	
	ISNULL(revtype1.name,'') as 'RevType1 Name', --'RevType1 Name'	
	lgh_class2 AS RevType2,
	ISNULL(revtype2.code,'') as 'RevType2 Code', --'RevType2 Code'	
	ISNULL(revtype2.name,'') as 'RevType2 Name', --'RevType2 Name'	
	lgh_class3 AS RevType3,
	ISNULL(revtype3.code,'') as 'RevType3 Code', --'RevType3 Code'	
	ISNULL(revtype3.name,'') as 'RevType3 Name', --'RevType3 Name'
	lgh_class4 AS RevType4,
	ISNULL(revtype4.code,'') as 'RevType4 Code', --'RevType4 Code'	
	ISNULL(revtype4.name,'') as 'RevType4 Name', --'RevType4 Name'	
	
	CASE WHEN lgh.trc_terminal <> lgh_class1 
		 THEN 'Y'
		 ELSE 'N'
	END AS RevType1AndTractorTerminalDifferentYN,
	
	CASE WHEN lgh_startcty_nmstct = lgh_endcty_nmstct
		 THEN 'Y'
		 ELSE 'N'
	END AS SameSegmentCityYN,
		
	SecondDropSequence = 
		(SELECT MIN(b.stp_mfh_sequence) 
			FROM stops b WITH (NOLOCK)  
			WHERE b.lgh_number = lgh.lgh_number AND stp_type = 'DRP' AND stp_mfh_sequence > 1 AND stp_loadstatus = 'LD'),			
	SecondPickupSequence = 
		(SELECT MIN(b.stp_mfh_sequence) 
			FROM stops b WITH (NOLOCK)  
			WHERE b.lgh_number = lgh.lgh_number AND stp_type = 'PUP' AND stp_mfh_sequence > 1 AND stp_loadstatus = 'LD'),
	
	lgh_endcty_nmstct AS 'Segment End City',
	cmp_id_end AS 'Segment End CmpID',	
	destcmp.cmp_name as 'Segment End CmpName',        
	lgh_EndDate AS 'Segment End Date',
	(CAST(FLOOR(CAST([lgh_EndDate] AS float))as smalldatetime)) AS 'Segment End Date Only', 
	'Segment End Day' =  
		CAST(DATEPART(yyyy,[lgh_EndDate]) as varchar(4)) +  '-' + CAST(DATEPART(mm,[lgh_endDate]) AS varchar(2)) 
			+ '-' + CAST(DATEPART(dd,[lgh_endDate]) AS varchar(2)),
	CAST(DATEPART(mm,[lgh_EndDate]) as varchar(2)) + '/' + CAST(DATEPART(yyyy,[lgh_endDate]) as varchar(4)) AS 'Segment End Month', 
	DATEPART(mm,[lgh_EndDate]) as 'Segment End Month Only',		
	lgh_endregion1 AS 'Segment End Region1',
	lgh_endstate AS 'Segment End State',
	DATEPART(yyyy,[lgh_EndDate]) as 'Segment End Year',        
        
 	lgh_startcty_nmstct AS 'Segment Start City',
 	cmp_id_start AS 'Segment Start CmpID',
 	origincmp.cmp_name AS 'Segment Start CmpName',
 	lgh_startDate AS 'Segment Start Date',	
 	(CAST(FLOOR(CAST([lgh_startDate] AS float))AS smalldatetime)) AS 'Segment Start Date Only',
    'Segment Start Day' = 
		CAST(DATEPART(yyyy,[lgh_startDate]) AS varchar(4)) +  '-' + CAST(DATEPART(mm,[lgh_startDate]) as varchar(2)) 
			+ '-' + CAST(DATEPART(dd,[lgh_startDate]) AS varchar(2)),
	CAST(DATEPART(mm,[lgh_startDate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[lgh_startDate]) as varchar(4)) AS 'Segment Start Month', 
	DATEPART(mm,[lgh_startDate]) as 'Segment Start Month Only',	 
	lgh_startregion1 AS 'Segment Start Region1',  
	lgh_startstate AS 'Segment Start State',	
	DATEPART(yyyy,[lgh_startDate]) as 'Segment Start Year',	
    lgh_outstatus AS 'Segment Status',     
	lgh_primary_trailer as 'Segment Trailer ID',
		
	[Shipper Name] = 
		(SELECT cmp_name 
			FROM company WITH (NOLOCK) 
			WHERE cmp_id = ISNULL(ordstrt.ord_shipper,'')),	
				
	ISNULL(ordstrt.ord_shipper,'') AS 'Shipper ID', --'Shipper ID'
	ord.ord_subcompany as 'Sub Company ID',		
	TaxableCompensationPay =
		ISNULL((SELECT SUM(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
					FROM   paydetail WITH (NOLOCK) 
					WHERE  paydetail.lgh_number=lgh.lgh_number AND pyd_pretax = 'Y'),
				0.00),
				
	lgh.mpp_teamleader AS 'Team Leader ID', 
				
	'Total Billed Miles' = 
		ISNULL((SELECT SUM(ISNULL(stp_ord_mileage,0)) 
					FROM stops WITH (NOLOCK) 
					WHERE stops.lgh_number = lgh.lgh_number and stops.ord_hdrnumber > 0 ),0),					
	'Total Miles' = 
		ISNULL((SELECT SUM(ISNULL(stp_lgh_mileage,0)) 
					FROM stops WITH (NOLOCK) 
					WHERE stops.lgh_number = lgh.lgh_number),0),
	ISNULL(lgh.trc_company,trc.trc_company) AS 'Tractor Company', --'Tractor Company'
	ISNULL(lgh.trc_division,trc.trc_division) AS 'Tractor Division', --'Tractor Division'
	ISNULL(lgh.trc_fleet,trc.trc_fleet) as 'Tractor Fleet',	--'Tractor Fleet'			
	lgh_tractor AS 'Tractor ID',
			
	'Tractor Pay'=
		ISNULL((SELECT SUM(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
					FROM paydetail WITH (NOLOCK) 
					WHERE paydetail.lgh_number=lgh.lgh_number AND asgn_type = 'TRC' AND pyd_pretax = 'Y'),			       
	      	 	0.00),	
	      	 	
   ISNULL(lgh.trc_terminal,trc.trc_terminal) AS 'Tractor Terminal', --'Tractor Terminal' 
            
    TractorActiveYN =    
		CASE WHEN 
			(SELECT 'Y' 
				FROM tractorprofile WITH (NOLOCK)  
				WHERE trc_number = lgh_tractor and trc_retiredate > GetDate()) = 'Y'
			THEN 'Y'
		ELSE 'N'
		END,
	'Trailer Company' = 
		(SELECT MIN(trl_company) 
			FROM trailerprofile WITH (NOLOCK) 
			WHERE trl_id = lgh_primary_trailer
		 ),    
	'Trailer Fleet' = 
		(SELECT MIN(trl_fleet) 
			FROM trailerprofile WITH (NOLOCK) 
			WHERE trl_id = lgh_primary_trailer
		 ),    
	'Trailer Terminal' = 
		(SELECT MIN(trl_terminal) 
			FROM trailerprofile WITH (NOLOCK) 
			WHERE trl_id = lgh_primary_trailer
		 ),   
	'Trailer Division' = 
		(SELECT MIN(trl_division) 
			FROM trailerprofile WITH (NOLOCK) 
			WHERE trl_id = lgh_primary_trailer
		 ),  	   	
	'Transfer Date' =	
         (SELECT min(ivh_xferdate)
			FROM   invoiceheader I WITH (NOLOCK)
			WHERE  I.ord_hdrnumber = lgh.ord_hdrnumber AND lgh.ord_hdrnumber > 0 
          ),          	      	 									
	
	trc.trc_type1 AS TrcType1, 
	trc.trc_type2 AS TrcType2, 
	trc.trc_type3 AS TrcType3, 
	trc.trc_type4 AS TrcType4,
	ISNULL(destcty.cty_zip,'') as 'Trip Destination Zip Code', --'Trip Destination Zip Code',
	lgh.mpp_company AS 'TRIP Driver Company',	
	lgh.mpp_division AS 'TRIP Driver Division',
	lgh.mpp_domicile AS 'TRIP Driver Domicile',	
	lgh.mpp_fleet AS 'TRIP Driver Fleet',
	lgh.mpp_terminal AS 'TRIP Driver Terminal',
	convert(float,lgh_enddate - lgh_startdate) * 24 As 'Trip Hours',
	ISNULL(origcty.cty_zip,'') as 'Trip Origin Zip Code', --'Trip Origin Zip Code',		
	lgh.trc_company AS 'TRIP Tractor Company',
	lgh.trc_division AS 'TRIP Tractor Division',
	lgh.trc_fleet AS 'TRIP Tractor Fleet',
	lgh.trc_terminal AS 'TRIP Tractor Terminal', 	   
	lgh.trl_type1 AS TrlType1, 
	trl_type2 AS TrlType2, 
	trl_type3 AS TrlType3, 
	trl_type4 AS TrlType4,
	lgh.shift_ss_id 'Shift ID Leg',
	lgh.mfh_number 'Shift Sequence',

	(select top 1 s.ss_shift 
		from ShiftSchedules s with(nolock)
		where lgh.shift_ss_id = s.ss_id)
	as 'Shift',
		(select top 1 s.ss_date 
			from ShiftSchedules s with(nolock)
		where lgh.shift_ss_id = s.ss_id)
	as 'Shift Date' ,
		 (select top 1 s.ss_shiftstatus 
			from ShiftSchedules s with(nolock)
		where lgh.shift_ss_id = s.ss_id)
as  'Shift Status',
	(select top 1 s.ss_terminal
			from ShiftSchedules s with(nolock)
		where lgh.shift_ss_id = s.ss_id)
	as 'Shift Terminal',
	 (select top 1(CAST(FLOOR(CAST(s.ss_date  AS float))AS smalldatetime))
	from ShiftSchedules s with(nolock)
		where lgh.shift_ss_id = s.ss_id)
	as [Shift Date Only]
	
,case when (select cast(count(*) as float) from stops where stp_status ='DNE' and lgh_number = lgh.lgh_number) = 0 
 then 0 else
 
  (select round(cast(count(*) as float) /(select cast(count(*) as float) from stops where stp_status ='DNE' and lgh_number = lgh.lgh_number),2)
from stops where stp_status ='DNE' and stp_tmstatus  ='OK' and lgh_number = lgh.lgh_number)
 end as cerradapor

FROM legheader lgh	
LEFT JOIN orderheader ord WITH (NOLOCK) ON ord.ord_hdrnumber = lgh.ord_hdrnumber
LEFT JOIN orderheader ordstrt WITH (NOLOCK) on ordstrt.ord_hdrnumber = lgh.ord_hdrnumber AND lgh.ord_hdrnumber>0
LEFT JOIN manpowerprofile drv1 WITH (NOLOCK) ON drv1.mpp_id = lgh.lgh_driver1
LEFT JOIN manpowerprofile drv2 WITH (NOLOCK) ON drv2.mpp_id = lgh.lgh_driver2
LEFT JOIN carrier car WITH (NOLOCK) ON car.car_id = lgh.lgh_carrier
LEFT JOIN labelfile revtype1 WITH (NOLOCK) ON revtype1 .abbr = ord.ord_revtype1 AND revtype1.labeldefinition = 'RevType1'
LEFT JOIN labelfile revtype2 WITH (NOLOCK) ON revtype2.abbr = ord.ord_revtype2 AND revtype2.labeldefinition = 'RevType2'
LEFT JOIN labelfile revtype3 WITH (NOLOCK) ON revtype3.abbr = ord.ord_revtype3 AND revtype3.labeldefinition = 'RevType3'
LEFT JOIN labelfile revtype4 WITH (NOLOCK) ON revtype4.abbr = ord.ord_revtype4 AND revtype4.labeldefinition = 'RevType4'
LEFT JOIN company origincmp WITH (NOLOCK) ON lgh.cmp_id_start = origincmp.cmp_id AND lgh.ord_hdrnumber > 0	
LEFT JOIN company destcmp WITH (NOLOCK) ON lgh.cmp_id_end = destcmp.cmp_id AND lgh.ord_hdrnumber >0 
LEFT JOIN city origcty WITH (NOLOCK) ON origcty.cty_code = lgh_startcity
LEFT JOIN city destcty WITH (NOLOCK) ON destcty.cty_code = lgh_endcity
LEFT JOIN tractorprofile trc WITH (NOLOCK) on trc.trc_number = lgh.lgh_tractor
LEFT JOIN labelfile trctype1 WITH (NOLOCK) on trctype1.abbr = trc.trc_type1 and trctype1.labeldefinition = 'TrcType1'
LEFT JOIN labelfile trctype2 WITH (NOLOCK) on trctype2.abbr = trc.trc_type2 and trctype2.labeldefinition = 'TrcType2'
LEFT JOIN labelfile trctype3 WITH (NOLOCK) on trctype3.abbr = trc.trc_type3 and trctype3.labeldefinition = 'TrcType3'
LEFT JOIN labelfile trctype4 WITH (NOLOCK) on trctype4.abbr = trc.trc_type4 and trctype4.labeldefinition = 'TrcType4'
--Left join shiftschedules on lgh.shift_ss_id = shiftschedules.ss_id -- used by fuel dispatch

) as TripSegment





GO
