SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_InvoicesByTripSegment]
AS

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_InvoicesByTripSegment]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_InvoicesByTripSegment
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_InvoicesByTripSegment]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 ***********************************************************/

SELECT ivh_invoicestatus as [InvoiceStatus],
	   ivh_invoicenumber as [Invoice Number],
	   ivh_deliverydate as [Delivery Date],
	   (Cast(Floor(Cast(ivh_deliverydate as float))as smalldatetime)) AS 'Delivery Date Only',
	   ivh_shipdate as [Ship Date],
	   (Cast(Floor(Cast(ivh_shipdate as float))as smalldatetime)) AS 'Ship Date Only',
       ivh_originstate as 'Origin State', 
       ivh_deststate as 'Destination State', 
	   IsNull(invoiceheader.ivh_totalcharge,0) as 'NonAllocatedTotalRevenue',
	   invoiceheader.ord_hdrnumber as 'Order Header Number', 
	   ord_status as [OrderStatus],
	   invoiceheader.ord_number as [Order Number],   
	   Case When legheader.lgh_type1 <> 'UNK' And legheader.lgh_type1 Is Not Null Then legheader.lgh_type1 Else legheader.trc_type1 End as Division  ,
       case when legheader.mov_number is null then invoiceheader.mov_number Else legheader.mov_number End as [Move Number],
       legheader.lgh_number as [LegHeader Number],
	   legheader.lgh_tractor as Tractor,
	   ivh_billdate as [Bill Date],
	   (Cast(Floor(Cast(ivh_billdate as float))as smalldatetime)) AS 'Bill Date Only',
	   Case When invoiceheader.ord_hdrnumber > 0 and ivh_hdrnumber = 
																	(
																	select min(b.ivh_hdrnumber) 
																	from invoiceheader b  with(NOLOCK)  
																	where b.ord_hdrnumber = invoiceheader.ord_hdrnumber
																	) Then dbo.fnc_ssrs_MilesForOrderOnLegHeader(invoiceheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number,'ALL','') 
			Else 0 End as TotalMiles,
	   Case When invoiceheader.ord_hdrnumber > 0 and ivh_hdrnumber = 
																	(
																	select min(b.ivh_hdrnumber) 
																	from invoiceheader b  with(NOLOCK)  
																	where b.ord_hdrnumber = invoiceheader.ord_hdrnumber
																	) Then dbo.fnc_ssrs_MilesForOrderOnLegHeader(invoiceheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number,'MT','') 
			Else 0 End as EmptyMiles,
	   Case When invoiceheader.ord_hdrnumber > 0 and ivh_hdrnumber = 
																	(
																	select min(b.ivh_hdrnumber) 
																	from invoiceheader b  with(NOLOCK)  
																	where b.ord_hdrnumber = invoiceheader.ord_hdrnumber
																	) Then dbo.fnc_ssrs_MilesForOrderOnLegHeader(invoiceheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number,'LD','') 
			Else 0 End as LoadedMiles,
	   ivh_order_by as 'Ordered By ID', 
       'Ordered By' = (select cmp_name from company  with(NOLOCK)  where cmp_id = ivh_order_by),
       ord_customer as 'Customer ID',
	   DateDiff(Day,ord_bookdate,ord_startdate) as [BookToShipDateLag],
	   ord_bookdate as 'Book Date', 
       (Cast(Floor(Cast([ord_bookdate] as float))as smalldatetime)) as [Book Date Only], 
       Cast(DatePart(yyyy,[ord_bookdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_bookdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_bookdate]) as varchar(2)) as [Book Day],
       Cast(DatePart(mm,[ord_bookdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_bookdate]) as varchar(4)) as [Book Month],
       DatePart(mm,[ord_bookdate]) as [Book Month Only],
       DatePart(yyyy,[ord_bookdate]) as [Book Year], 
	   ord_bookedby as 'Booked By', 
       ivh_originpoint as 'Origin Point ID', 
	   (select Min(a.stp_loadstatus) from stops a  with(NOLOCK)  Where a.mov_number = invoiceheader.mov_number and a.stp_mfh_sequence = (select max(b.stp_mfh_sequence) from stops b where b.mov_number = a.mov_number))  as LastLoadStatusOnMove,
       'Orgin Point' = (select cmp_name from company  with(NOLOCK)  where cmp_id = ivh_originpoint),
       ivh_destpoint as 'Destination Point ID', 
       'Destination Point' = (select cmp_name from company  with(NOLOCK)  where cmp_id = ivh_destpoint),
       (select cty_name from city  with(NOLOCK) where cty_code = ivh_origincity) as 'Origin City',
       (select cty_name from city  with(NOLOCK)  where cty_code = ivh_destcity) as 'Dest City', 
	   (select cty_zip from city  with(NOLOCK)  where cty_code = ivh_origincity) as 'Origin Zip Code',
       (select cty_zip from city  with(NOLOCK)  where cty_code = ivh_destcity) as 'Dest Zip Code', 
       ivh_supplier as 'Supplier ID',
	   RevType1 = IsNull(ivh_revtype1,''),
	   RevType2 = IsNull(ivh_revtype2,''),
	   RevType3 = IsNull(ivh_revtype3,''),
       RevType4 = IsNull(ivh_revtype4,''),
       AllocatedTotalRevenue = case when invoiceheader.ord_hdrnumber=0 Then  IsNull(invoiceheader.ivh_totalcharge,0) 
									Else dbo.fnc_SSRS_RevenueForOrderOnLegHeader(invoiceheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number, IsNull(invoiceheader.ivh_totalcharge,0)) End,
	   AllocatedFuelSurcharge = dbo.fnc_SSRS_RevenueForOrderOnLegHeader(legheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number,dbo.TMWSSRS_fnc_TotFuelSurchargeForInvoice(invoiceheader.ivh_hdrnumber)),
	   LegStartCity,
	   LegEndCity,
	   LegDivision,
	   LegFleet,
	   LegDriver1,
	   LegDriver2,
       [Start Date],
	   [End Date],
       ivh_billto as [Bill To ID]		
FROM invoiceheader  with(NOLOCK) 
LEFT JOIN orderheader  with(NOLOCK) 
	ON invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber 
LEFT JOIN   (
			Select distinct case when b.ord_hdrnumber = 0 then c.ord_hdrnumber else b.ord_hdrnumber end as ord_hdrnumber,c.lgh_number,c.lgh_tractor,c.mov_number,c.lgh_type1,c.trc_type1,c.lgh_startcty_nmstct as LegStartCity,c.lgh_endcty_nmstct as LegEndCity,c.trc_division as LegDivision,c.trc_fleet as LegFleet,lgh_driver1 as LegDriver1,lgh_driver2 as LegDriver2,lgh_startdate as [Start Date],lgh_enddate as [End Date]
			From stops b  with(NOLOCK) , legheader c  with(NOLOCK) 
			where b.lgh_number = c.lgh_number
			And case when b.ord_hdrnumber = 0 then c.ord_hdrnumber 
					 Else b.ord_hdrnumber end > 0
			And c.ord_hdrnumber > 0 
			) as legheader 
			on invoiceheader.ord_hdrnumber = legheader.ord_hdrnumber
Where      ivh_invoicestatus <> 'CAN'
GO
GRANT SELECT ON  [dbo].[vSSRSRB_InvoicesByTripSegment] TO [public]
GO
