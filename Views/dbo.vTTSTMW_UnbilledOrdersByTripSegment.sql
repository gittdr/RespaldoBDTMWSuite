SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO










--select top 100 [Order Number],* from vTTSTMW_UnbilledOrdersByTripSegment where [LegHeader Number]=2097
CREATE                View [dbo].[vTTSTMW_UnbilledOrdersByTripSegment]



As



select TempOrders.*,
       AllocatedTotalRevenue = dbo.fnc_TMWRN_RevenueForOrderOnLegHeader([Order Header Number],[LegHeader Number],[Move Number],NonAllocatedTotalRevenue)
from

(

SELECT     
	
           ord_invoicestatus as 'InvoiceStatus', 
	   ' ' as [Invoice Number],
	   ord_completiondate as [Delivery Date],
	   ord_startdate as [Ship Date],
           ord_originstate as 'Origin State', 
           ord_deststate as 'Destination State', 
	   convert(money,IsNull(ord_totalcharge,0)) as 'NonAllocatedTotalRevenue',
	   orderheader.ord_hdrnumber as 'Order Header Number', 
	   ord_status as [Order Status],
	   ord_number as [Order Number],
	   Case When legheader.lgh_type1 <> 'UNK' And legheader.lgh_type1 Is Not Null Then legheader.lgh_type1 Else legheader.trc_type1 End as Division  ,
           stops.mov_number as [Move Number],
           stops.lgh_number as [LegHeader Number],
	   legheader.lgh_tractor as [Tractor],
	   NULL as [Bill Date],
	   dbo.fnc_TMWRN_MilesForOrderOnLegHeader(orderheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number,'ALL','') as TotalMiles,
	   dbo.fnc_TMWRN_MilesForOrderOnLegHeader(orderheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number,'MT','') as EmptyMiles,
           dbo.fnc_TMWRN_MilesForOrderOnLegHeader(orderheader.ord_hdrnumber,legheader.lgh_number,legheader.mov_number,'LD','') as LoadedMiles,
	   ord_company as 'Ordered By ID', 
           'Ordered By' = (select cmp_name from company (NOLOCK) where cmp_id = ord_company),
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
           ord_originpoint as 'Origin Point ID', 
	   (select Min(a.stp_loadstatus) from stops a (NOLOCK) Where a.mov_number = orderheader.mov_number and a.stp_mfh_sequence = (select max(b.stp_mfh_sequence) from stops b where b.mov_number = a.mov_number))  as LastLoadStatusOnMove,
           'Orgin Point' = (select cmp_name from company (NOLOCK) where cmp_id = ord_originpoint),
           ord_destpoint as 'Destination Point ID', 
           'Destination Point' = (select cmp_name from company (NOLOCK) where cmp_id = ord_destpoint),
           
           (select cty_name from city (NOLOCK) where cty_code = ord_origincity) as 'Origin City',
           (select cty_name from city (NOLOCK) where cty_code = ord_destcity) as 'Dest City', 
	   (select cty_zip from city (NOLOCK) where cty_code = ord_origincity) as 'Origin Zip Code',
           (select cty_zip from city (NOLOCK) where cty_code = ord_destcity) as 'Dest Zip Code', 
           ord_supplier as 'Supplier ID'
	   
	        

FROM       orderheader (NOLOCK) Left Join stops (NOLOCK) On stops.ord_hdrnumber = orderheader.ord_hdrnumber and stops.stp_number = (select min(b.stp_number) from stops b (NOLOCK) where b.ord_hdrnumber = orderheader.ord_hdrnumber and b.lgh_number = stops.lgh_number)
				Left Join legheader (NOLOCK) On legheader.lgh_number = stops.lgh_number
				     	
Where      ord_invoicestatus Not In ('PPD','XIN')
	   And
	   ord_status Not In ('MST','CAN')
	   

) as TempOrders



















GO
GRANT SELECT ON  [dbo].[vTTSTMW_UnbilledOrdersByTripSegment] TO [public]
GO
