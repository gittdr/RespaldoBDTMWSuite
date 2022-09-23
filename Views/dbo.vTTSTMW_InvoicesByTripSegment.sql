SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE       View [dbo].[vTTSTMW_InvoicesByTripSegment]

As


select TempInvoices.*,
       AllocatedTotalRevenue = case when [order header number]=0 Then NonAllocatedTotalRevenue Else
	 dbo.fnc_TMWRN_RevenueForOrderOnLegHeader([Order Header Number],[LegHeader Number],[Move Number],NonAllocatedTotalRevenue) End
from

(

SELECT     
	
           ivh_invoicestatus as [InvoiceStatus],
	   ivh_invoicenumber as [Invoice Number],
	   ivh_deliverydate as [Delivery Date],
	   ivh_shipdate as [Ship Date],
           ivh_originstate as 'Origin State', 
           ivh_deststate as 'Destination State', 
	   IsNull(invoiceheader.ivh_totalcharge,0) as 'NonAllocatedTotalRevenue',
	   invoiceheader.ord_hdrnumber as 'Order Header Number', 
	   ord_status as [Order Status],
	   invoiceheader.ord_number as [Order Number],   
	   Case When legheader.lgh_type1 <> 'UNK' And legheader.lgh_type1 Is Not Null Then legheader.lgh_type1 Else legheader.trc_type1 End as Division  ,
           stops.mov_number as [Move Number],
           stops.lgh_number as [LegHeader Number],
	   legheader.lgh_tractor as Tractor,
	   ivh_billdate as [Bill Date],
	   Case When invoiceheader.ord_hdrnumber > 0 and ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) Then
		dbo.fnc_TMWRN_MilesForOrderOnLegHeader(invoiceheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number,'ALL','') 
	   Else
		0
	   End as TotalMiles,
	   Case When invoiceheader.ord_hdrnumber > 0 and ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) Then
		dbo.fnc_TMWRN_MilesForOrderOnLegHeader(invoiceheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number,'MT','') 
	   Else
		0
	   End as EmptyMiles,
	   Case When invoiceheader.ord_hdrnumber > 0 and ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) Then
		dbo.fnc_TMWRN_MilesForOrderOnLegHeader(invoiceheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number,'LD','') 
	   Else
		0
	   End as LoadedMiles,
	   ivh_order_by as 'Ordered By ID', 
           'Ordered By' = (select cmp_name from company (NOLOCK) where cmp_id = ivh_order_by),
           ord_customer as 'Customer ID',
	
	   DateDiff(Day,ord_bookdate,ord_startdate) as [BookToShipDateLag],
           --**Book Date**
	   ord_bookdate as 'Book Date', 
           --Day
       	   (Cast(Floor(Cast([ord_bookdate] as float))as smalldatetime)) as [Book Date Only], 
           Cast(DatePart(yyyy,[ord_bookdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_bookdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_bookdate]) as varchar(2)) as [Book Day],
           --Month
           Cast(DatePart(mm,[ord_bookdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_bookdate]) as varchar(4)) as [Book Month],
           DatePart(mm,[ord_bookdate]) as [Book Month Only],
           --Year
           DatePart(yyyy,[ord_bookdate]) as [Book Year], 
	   ord_bookedby as 'Booked By', 
           ivh_originpoint as 'Origin Point ID', 
	   (select Min(a.stp_loadstatus) from stops a (NOLOCK) Where a.mov_number = invoiceheader.mov_number and a.stp_mfh_sequence = (select max(b.stp_mfh_sequence) from stops b where b.mov_number = a.mov_number))  as LastLoadStatusOnMove,
           'Orgin Point' = (select cmp_name from company (NOLOCK) where cmp_id = ivh_originpoint),
           ivh_destpoint as 'Destination Point ID', 
           'Destination Point' = (select cmp_name from company (NOLOCK) where cmp_id = ivh_destpoint),
           
           (select cty_name from city (NOLOCK) where cty_code = ivh_origincity) as 'Origin City',
           (select cty_name from city (NOLOCK) where cty_code = ivh_destcity) as 'Dest City', 
	   (select cty_zip from city (NOLOCK) where cty_code = ivh_origincity) as 'Origin Zip Code',
       (select cty_zip from city (NOLOCK) where cty_code = ivh_destcity) as 'Dest Zip Code', 
           ivh_supplier as 'Supplier ID'
           
	
	        

FROM       invoiceheader (NOLOCK) Left Join stops (NOLOCK) On stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and invoiceheader.ord_hdrnumber > 0 and stops.stp_number = (select min(b.stp_number) from stops b (NOLOCK) where b.ord_hdrnumber = stops.ord_hdrnumber and b.lgh_number = stops.lgh_number)
				  Left Join legheader (NOLOCK) On legheader.lgh_number = stops.lgh_number
				  Left Join orderheader (NOLOCK) On invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber 
				 
Where      ivh_invoicestatus <> 'CAN'
	   

) as TempInvoices


















































































GO
GRANT SELECT ON  [dbo].[vTTSTMW_InvoicesByTripSegment] TO [public]
GO
