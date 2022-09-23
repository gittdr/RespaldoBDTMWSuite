SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
























--select top 100 * from vTTSTMW_Orders



CREATE        View [dbo].[vTTSTMW_Orders]

--Revision History
--1. Added Pay and changed the column name for Dest State
--   Added Ver 5.0 LBK
--2. Changed trl_number to trl_id when joining resolving trailer types 
     --and added min to eliminate subquery error
--   Fixed Ver 5.1 LBK
--3. Fixed Destination City column 
--so it joins on Destination City ID instead of orgin city ID
--   Fixed Ver 5.1 LBK
--4. Added Sub Company ID, Sub Company Name, Trailer terminal,company,fleet,division
--   Added Bill Date and Rev Date
--   Ver 5.3 LBK

As

select TempOrders2.*,
       convert(money,IsNull((PercentofRevenueForMovement * PayPerMove),0.00)) as Pay,
       convert(money,IsNull([Total Revenue] - (PercentofRevenueForMovement * PayPerMove),0.00)) As Net,
       convert(money,IsNull((PercentofRevenueForMovement * PayPerMove2),0.00)) as Pay2,
       convert(money,IsNull([Total Revenue] - (PercentofRevenueForMovement * PayPerMove2),0.00)) As Net2,
             [Carrier Name] = (select top 1 car_name from carrier (NOLOCK) where car_id = [Carrier ID])

from

(

select TempOrders.*,
       
  	Case When [Total Revenue For Movement] = 0  Then
                convert(float,1)/convert(float,(select count(c.ord_hdrnumber) from orderheader c (NOLOCK) where c.mov_number = [Move Number])) 
       	Else
	        convert(float,[Total Revenue])/convert(float,[Total Revenue For Movement])
       	End as PercentofRevenueForMovement,
	'Bill To' = (select cmp_name from company (NOLOCK) where cmp_id = [Bill To ID]),
        'Master Bill To ID' = (select cmp_mastercompany from company (NOLOCK) where cmp_id = [Bill To ID]),
	'Master Bill To' = (select cmp_name from company a (NOLOCK) where a.cmp_id = (select cmp_mastercompany from company (NOLOCK) where cmp_id = [Bill To ID])),
	(select cmp_othertype1 from company where cmp_id = [Bill To ID]) as [Other Type 1],
	(select cmp_othertype2 from company where cmp_id = [Bill To ID]) as [Other Type 2]
from

(

SELECT     ord_company as 'Ordered By ID', 
           'Ordered By' = (select cmp_name from company (NOLOCK) where cmp_id = ord_company),
	   ord_number as 'Order Number', 
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
           ord_status as 'Order Status', 
           ord_originpoint as 'Origin Point ID', 
	   (select Min(a.stp_loadstatus) from stops a (NOLOCK) Where a.mov_number = orderheader.mov_number and a.stp_mfh_sequence = (select max(b.stp_mfh_sequence) from stops b where b.mov_number = a.mov_number))  as LastLoadStatusOnMove,
           'Orgin Point' = (select cmp_name from company (NOLOCK) where cmp_id = ord_originpoint),
           ord_destpoint as 'Destination Point ID', 
           'Destination Point' = (select cmp_name from company (NOLOCK) where cmp_id = ord_destpoint),
           ord_invoicestatus as 'InvoiceStatus', 

	    --<TTS!*!TMW><Begin><SQLVersion=7>
--           (
--	   convert(money,IsNull((select sum(a.ord_totalcharge) from orderheader a where a.mov_number = orderheader.mov_number and a.ord_invoicestatus <> 'PPD'),0.00)) 
--		+   
--	   convert(money,IsNull((select sum(a.ivh_totalcharge) from invoiceheader a where a.mov_number = orderheader.mov_number),0.00))
--            )
--           As 'Total Revenue For Movement',
	   --<TTS!*!TMW><End><SQLVersion=7> 

	   --<TTS!*!TMW><Begin><SQLVersion=2000+>
	   (
	   convert(money,IsNull((select sum(IsNull(dbo.fnc_convertcharge(IsNull(a.ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) from orderheader a where a.mov_number = orderheader.mov_number and a.ord_invoicestatus <> 'PPD'),0.00)) 
		+   
	   convert(money,IsNull((select sum(IsNull(dbo.fnc_convertcharge(IsNull(a.ivh_totalcharge,0)-(IsNull(a.ivh_taxamount1,0) + IsNull(a.ivh_taxamount2,0) + IsNull(a.ivh_taxamount3,0) + IsNull(a.ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) from invoiceheader a where a.mov_number = orderheader.mov_number),0.00))
            )
           As 'Total Revenue For Movement',
	   --<TTS!*!TMW><End><SQLVersion=2000+>


           (select cty_name from city (NOLOCK) where cty_code = ord_origincity) as 'Origin City',
           (select cty_name from city (NOLOCK) where cty_code = ord_destcity) as 'Dest City', 
	   (select cty_zip from city (NOLOCK) where cty_code = ord_origincity) as 'Origin Zip Code',
           (select cty_zip from city (NOLOCK) where cty_code = ord_destcity) as 'Dest Zip Code', 
           ord_originstate as 'Origin State', 
           ord_deststate as 'Destination State', 
           ord_supplier as 'Supplier ID', 
           --ord_billto as 'Bill To ID', 
	   --changed to pull bill to off invoice as of V 5.7
	   Case When ord_invoicestatus = 'PPD' Then
   	        (select Top 1 ivh_billto from InvoiceHeader (NOLOCK) where InvoiceHeader.ord_hdrnumber = OrderHeader.ord_hdrnumber)
	   Else
		ord_billto
	   End as 'Bill To ID', 
           
	   --**Ship Date**
	   ord_startdate as 'Ship Date', 
           --Day
       	   (Cast(Floor(Cast([ord_startdate] as float))as smalldatetime)) as [Ship Date Only], 
           Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_startdate]) as varchar(2)) as [Ship Day],
           --Month
           Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) as [Ship Month],
           DatePart(mm,[ord_startdate]) as [Ship Month Only],
           --Year
           DatePart(yyyy,[ord_startdate]) as [Ship Year],
	   --Ship Day Of Week
	   CASE DatePart(dw,[ord_startdate]) WHEN 1 THEN 'Sunday'
                 			     WHEN 2 THEN 'Monday'
                 			     WHEN 3 THEN 'Tuesday'
                 			     WHEN 4 THEN 'Wednesday'
                 			     WHEN 5 THEN 'Thursday'
                 			     WHEN 6 THEN 'Friday'
                 			     WHEN 7 THEN 'Saturday'
                 			     ELSE SPACE(0)
           END as [Ship DayOfWeek],
	   DatePart(dw,[ord_startdate]) as [Ship DayOfWeekNumeric],
 
	   --**Delivery Date**
	   ord_completiondate as 'Delivery Date', 
	   (Cast(Floor(Cast([ord_completiondate] as float))as smalldatetime)) as [Delivery Date Only], 
           Cast(DatePart(yyyy,[ord_completiondate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_completiondate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_completiondate]) as varchar(2)) as [Delivery Day],
           --Month
           Cast(DatePart(mm,[ord_completiondate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_completiondate]) as varchar(4)) as [Delivery Month],
           DatePart(mm,[ord_completiondate]) as [Delivery Month Only],
           --Year
           DatePart(yyyy,[ord_completiondate]) as [Delivery Year], 
           ord_revtype1 as 'RevType1', 
           'RevType1 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ord_revtype1 and labeldefinition = 'RevType1'),''),
	   ord_revtype2 as 'RevType2',
	   'RevType2 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ord_revtype2 and labeldefinition = 'RevType2'),''),
	   ord_revtype3 as 'RevType3',
	   'RevType3 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ord_revtype3 and labeldefinition = 'RevType3'),''),
	   ord_revtype4 as 'RevType4',
           'RevType4 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ord_revtype4 and labeldefinition = 'RevType4'),''),
           ord_totalweight as 'Total Weight', 
           ord_totalpieces as 'Total Pieces', 
           ord_totalmiles as 'Total Miles', 
           
	   'BOL Number' = (Select Top 1 ref_number
		    	   From   ReferenceNumber (NOLOCK)  
		    	   Where  (ref_type = 'BL#' or ref_type = 'BOL' or ref_type = 'B/L#')
                            	   and 
                            	   (orderheader.ord_hdrnumber = referencenumber.ref_tablekey and ref_table = 'orderheader')
		   		),


	   --<TTS!*!TMW><Begin><SQLVersion=7>
--           Case When ord_invoicestatus = 'PPD' Then
--		convert(money,IsNull((select sum(invoiceheader.ivh_totalcharge) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),0))
--           Else
--		convert(money,IsNull(ord_totalcharge,0))
--	   End as 'Total Revenue',
	   --<TTS!*!TMW><End><SQLVersion=7>            

	   
	   --<TTS!*!TMW><Begin><SQLVersion=2000+>
	   Case When ord_invoicestatus = 'PPD' Then
		convert(money,IsNull((select sum(IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),0))
           Else
		convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))
	   End as 'Total Revenue',
	   --<TTS!*!TMW><End><SQLVersion=2000+>   

	   ord_currency as 'Currency', 
           --**Currency Date**
	   ord_currencydate as 'Currency Date' , 
	   --Day
       	   (Cast(Floor(Cast([ord_currencydate] as float))as smalldatetime)) as [Currency Date Only], 
           Cast(DatePart(yyyy,[ord_currencydate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_currencydate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_currencydate]) as varchar(2)) as [Currency Day],
           --Month
           Cast(DatePart(mm,[ord_currencydate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_currencydate]) as varchar(4)) as [Currency Month],
           DatePart(mm,[ord_currencydate]) as [Currency Month Only],
           --Year
           DatePart(yyyy,[ord_currencydate]) as [Currency Year], 
	   ord_totalvolume as 'Total Volume', 
           ord_hdrnumber as 'Order Header Number', 
           ord_refnum as 'Reference Number', 
           ord_invoicewhole as 'Invoice Whole', 
           ord_remark as 'Remark', 
           ord_shipper as 'Shipper ID', 
           'Shipper' = (select cmp_name from company (NOLOCK) where cmp_id = ord_shipper),
           ord_consignee as 'Consignee ID', 
           'Consignee' = (select cmp_name from company (NOLOCK) where cmp_id = ord_consignee),
           ord_pu_at as 'Pickup At', 
           ord_dr_at as 'Drop At',

           ord_priority as 'Order Priority',
           mov_number as 'Move Number',
           tar_tarriffnumber as 'Tarrif Number',
           tar_number as 'Tar Number',
           tar_tariffitem as 'Tarrif Item',
      ord_contact as 'Contact',
           ord_showshipper as 'Show Shipper',
           ord_showcons as 'Show Consignee',
           ord_subcompany as 'Sub Company ID', 
           'Sub Company' = (select cmp_name from company (NOLOCK) where cmp_id = ord_subcompany),
	   ord_lowtemp as 'Low Temperature', 
           ord_hitemp as 'High Temperature', 
           ord_quantity as 'Quantity', 
           ord_rate as 'Rate', 
	   PickupCount = (select count(stops.ord_hdrnumber) from stops (NOLOCK) where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_type = 'PUP'),
           DropCount = (select count(stops.ord_hdrnumber) from stops (NOLOCK) where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_type = 'DRP'),
	   --<TTS!*!TMW><Begin><SQLVersion=7>
--	   Case When ord_invoicestatus = 'PPD' Then
--		convert(money,IsNull((select sum(invoiceheader.ivh_charge) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),0))
--           Else
--		convert(money,IsNull(ord_charge,0))
--	   End as 'Line Haul Revenue',
	   --<TTS!*!TMW><End><SQLVersion=7>   
  
	  --<TTS!*!TMW><Begin><SQLVersion=2000+>
          Case When ord_invoicestatus = 'PPD' Then
		convert(money,IsNull((select sum(IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),0))
           Else
		convert(money,IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))
	  End as 'Line Haul Revenue',
          --<TTS!*!TMW><End><SQLVersion=2000+>	
 
	   ord_rateunit as 'Rate Unit', 
           ord_unit as 'Unit', 
           trl_type1 as 'Trailer Type1', 

           ord_driver1 as 'Driver1 ID', 
           ord_driver2 as 'Driver2 ID', 
           ord_tractor as 'Tractor ID', 
           'TrcType1' = IsNull((select trc_type1 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
           'TrcType1 Name' = IsNull((select name from labelfile (NOLOCK) ,tractorprofile (NOLOCK) where labelfile.abbr = trc_type1 and labeldefinition = 'TrcType1' and trc_number = ord_tractor),''),
           'TrcType2' = IsNull((select trc_type2 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
           'TrcType2 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type2 and labeldefinition = 'TrcType2' and trc_number = ord_tractor),''),
           'TrcType3' = IsNull((select trc_type3 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
           'TrcType3 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type3 and labeldefinition = 'TrcType3' and trc_number = ord_tractor),''),
           'TrcType4'= IsNull((select trc_type4 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
           'TrcType4 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type4 and labeldefinition = 'TrcType4' and trc_number = ord_tractor),''),       
	   ord_trailer as 'Trailer ID', 
	   'TrlType1' = IsNull((select min(trl_type1) from trailerprofile (NOLOCK) where trl_id = ord_trailer),''),
           'TrlType1 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1' and trl_id = ord_trailer),''),
           'TrlType2' = IsNull((select min(trl_type2) from trailerprofile (NOLOCK) where trl_id = ord_trailer),''),
           'TrlType2 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type2 and labeldefinition = 'TrlType2' and trl_id = ord_trailer),''),
           'TrlType3' = IsNull((select min(trl_type3) from trailerprofile (NOLOCK) where trl_id = ord_trailer),''),
           'TrlType3 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type3 and labeldefinition = 'TrlType3' and trl_id = ord_trailer),''),
           'TrlType4'= IsNull((select min(trl_type4) from trailerprofile (NOLOCK) where trl_id = ord_trailer),''),
           'TrlType4 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type4 and labeldefinition = 'TrlType4' and trl_id = ord_trailer),''),       
           ord_length as 'Length', 
           ord_width as 'Width', 
           ord_height as 'Height', 
           ord_lengthunit as 'Length Unit', 
           ord_widthunit as 'Width Unit', 
           ord_heightunit as 'Height Unit', 
           ord_reftype as 'Ref Type', 
           cmd_code as 'Commodity Code', 
           ord_description as 'Commodity Description', 
           ord_terms as 'Order Terms', 
           cht_itemcode as 'Charge Type', 
           ord_origin_earliestdate as 'Origin Earliest Date', 
           ord_origin_latestdate as 'Origin Latest Date', 
           ord_odmetermiles as 'Odometer Miles', 
           ord_stopcount as 'Stop Count', 
           ord_dest_earliestdate as 'Destination Earliest Date', 
           ord_dest_latestdate as 'Destination Latest Date', 
           ref_sid as 'Reference SID', 
           ref_pickup as 'Reference Pickup', 
           ord_cmdvalue as 'CmdValue', 
	   
	   --<TTS!*!TMW><Begin><SQLVersion=7>
--	   Case When ord_invoicestatus = 'PPD' Then
--		convert(money,IsNull((select sum(invoiceheader.ivh_totalcharge) - sum(invoiceheader.ivh_charge) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),0))
--           Else
--		convert(money,IsNull(ord_accessorial_chrg,0))
--
--	   End as 'Accessorial Revenue', 
           --<TTS!*!TMW><End><SQLVersion=7>     
	
	   --<TTS!*!TMW><Begin><SQLVersion=2000+>
	   Case When ord_invoicestatus = 'PPD' Then
		convert(money,IsNull((select sum(IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) - sum(IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),0))
           Else
		convert(money,IsNull(dbo.fnc_convertcharge(ord_accessorial_chrg,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))
	   End as 'Accessorial Revenue',
	   --<TTS!*!TMW><End><SQLVersion=2000+>	
 
           ord_availabledate as 'Available Date', 
           ord_miscqty as 'Misc Qty' , 
           ord_tempunits as 'Temp Units', 
           ord_datetaken as 'Date Taken', 
           ord_totalweightunits as 'Total Weight Units', 
           ord_totalvolumeunits as 'TotalVolume Units', 
           ord_totalcountunits as 'Total Count Units', 
	   ord_loadtime as 'Load Time', 
           ord_unloadtime as 'Unload Time', 
           ord_drivetime as 'Drive Time', 
           ord_rateby as 'Rate By', 
           ord_quantity_type as 'Quantity Type', 
           ord_thirdpartytype1 as 'Third Party Type1', 
	  (select tpr_name from thirdpartyprofile (NOLOCK) where tpr_id = ord_thirdpartytype1) as 'Third Party Type1 Name', 
           ord_thirdpartytype2 as 'Third Party Type2', 
	  (select tpr_name from thirdpartyprofile (NOLOCK) where tpr_id = ord_thirdpartytype2) as 'Third Party Type2 Name',
           ord_charge_type as 'Order Charge Type', 
           ord_bol_printed as 'Bol Printed', 
           ord_fromorder as 'From Order', 

           ord_mintemp as 'Min Temp', 
           ord_maxtemp as 'Max Temp', 
           ord_distributor as 'Distributor', 
           ord_cod_amount as 'Cod Amount', 
           opt_trc_type4 as 'Option Tractor Type4', 
           opt_trl_type4 as 'Option Trailer Type4', 
           appt_init as 'Appt Init', 
           appt_contact as 'Appt Contact', 
           ord_ratingquantity as 'Rating Quantity', 
           ord_ratingunit as 'Rating Unit', 
           ord_booked_revtype1 as 'Booked RevType1', 
           ord_tareweight as 'Tare Weight', 
           ord_grossweight as 'Gross Weight', 
           ord_mileagetable as 'Mileage Table', 
           ord_allinclusivecharge as 'All Inclusive Charge', 
           ord_extrainfo1 as 'ExtraInfo1', 
           ord_extrainfo2 as 'ExtraInfo2', 
           ord_extrainfo3 as 'ExtraInfo3', 
           ord_extrainfo4 as 'ExtraInfo4',  
           ord_extrainfo5 as 'ExtraInfo5', 
           ord_extrainfo6 as 'ExtraInfo6', 
           ord_extrainfo7 as 'ExtraInfo7', 
           ord_extrainfo8 as 'ExtraInfo8',  
           ord_extrainfo9 as 'ExtraInfo9', 
           ord_extrainfo10 as 'ExtraInfo10', 
           ord_extrainfo11 as 'ExtraInfo11', 
           ord_extrainfo12 as 'ExtraInfo12', 
           ord_extrainfo13 as 'ExtraInfo13', 
           ord_extrainfo14 as 'ExtraInfo14', 
           ord_extrainfo15 as 'ExtraInfo15', 
           ord_rate_type as 'ExtraInfo16', 
           ord_barcode as 'ExtraInfo17', 
           ord_broker as 'ExtraInfo18', 
           ord_stlquantity as 'ExtraInfo19', 
           ord_stlunit as 'Stl Unit', 
           ord_stlquantity_type as 'Stl Quantity Type', 
           ord_schedulebatch as 'Schedule Batch', 
           IsNull(ord_fromschedule,-1) as 'From Schedule',
 	   (select top 1 labelfile.name from labelfile (NOLOCK),serviceexception (NOLOCK) where labelfile.abbr =  sxn_expcode and sxn_ord_hdrnumber = orderheader.ord_hdrnumber) as [Exception Code],
	   cast((select top 1 sxn_description from serviceexception (NOLOCK) where sxn_ord_hdrnumber = orderheader.ord_hdrnumber) as varchar(255)) as [Exception Description],
	   (select top 1 sxn_expdate from serviceexception (NOLOCK) where sxn_ord_hdrnumber = orderheader.ord_hdrnumber) as [Exception Date],
	   (select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as RefType1,
           (select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as RefNumber1,
           (select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as RefType2,
           (select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as RefNumber2,
           (select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as RefType3,
           (select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as RefNumber3,
           (select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as RefType4,
           (select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as RefNumber4,


      	   
	
	   --<TTS!*!TMW><Begin><SQLVersion=7>
--           convert(money,IsNull((select sum(pyd_amount) from paydetail (NOLOCK) where orderheader.mov_number = paydetail.mov_number and pyd_minus = 1),0.00)) as 'PayPerMove',   
	   --<TTS!*!TMW><End><SQLVersion=7>  

	   --<TTS!*!TMW><Begin><SQLVersion=2000+>
	   convert(money,IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) from paydetail (NOLOCK) where orderheader.mov_number = paydetail.mov_number and pyd_minus = 1),0.00)) as 'PayPerMove',
	   --<TTS!*!TMW><End><SQLVersion=2000+>	
	   
	   'Trailer Company' = (select min(trl_company) from trailerprofile (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Company Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_company and labeldefinition = 'Company' and trl_id = ord_trailer),''),
	   'Trailer Fleet' = (select min(trl_fleet) from trailerprofile (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Fleet Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_fleet and labeldefinition = 'Fleet' and trl_id = ord_trailer),''),
	   'Trailer Terminal' = (select min(trl_terminal) from trailerprofile (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Terminal Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_terminal and labeldefinition = 'Terminal' and trl_id = ord_trailer),''),
	   'Trailer Division' = (select min(trl_division) from trailerprofile (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Division Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_division and labeldefinition = 'Division' and trl_id = ord_trailer),''),

	   (select min(ivh_billdate) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Bill Date',
	   (select min(ivh_revenue_date) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Revenue Date',	   
           (select min(ivh_xferdate) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Transfer Date',

	    Case When ord_revtype1 In ('Outbound','Out') Or ord_revtype2 In ('Outbound','Out') Or  ord_revtype3 In ('Outound','Out') Or  ord_revtype4 In ('Outound','Out') Then
			 IsNull((select Min('Y') from orderheader b (NOLOCK) where b.ord_startdate > orderheader.ord_completiondate and DateDiff(hour,orderheader.ord_completiondate,b.ord_startdate) < 13 and orderheader.ord_tractor = b.ord_tractor and (b.ord_revtype1 In ('Inbound','In') Or b.ord_revtype2 In ('Inbound','In') Or  b.ord_revtype3 In ('Inbound','In') Or  b.ord_revtype4 In ('Inbound','In'))),'N')
	    Else
			'NotApplicable'
	    End as BackHaulLoadYNOrNA,		
	
	    (select Min(cty_region1) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region1],
            (select Min(cty_region2) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region2],
            (select Min(cty_region3) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region3],
            (select Min(cty_region4) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region4],
            (select Min(cty_region1) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region1],
            (select Min(cty_region2) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region2],
            (select Min(cty_region3) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region3],
            (select Min(cty_region4) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region4],	
	    case when ord_originstate = ord_deststate then
		IsNull((select 'N' from orderheader b where b.ord_hdrnumber = orderheader.ord_hdrnumber and b.ord_hdrnumber Not In (select stops.ord_hdrnumber from stops (NOLOCK) where stops.ord_hdrnumber = b.ord_hdrnumber and stp_state <> orderheader.ord_originstate)),'Y')
	    Else
		'Y'
	    End as LeftState,

	   'OrderTrlType1' = trl_type1,
           'OrderTrlType1 Name' = IsNull((select min(name) from labelfile (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1'),''),

	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Charge Type LH],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --ord_charge_type_lh as [Charge Type LH],
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
 	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Complete Stamp],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --ord_complete_stamp as [Complete Stamp], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  (select Top 1 cmp_address1 from company (NOLOCK) where cmp_id = ord_consignee) as [Consignee Address],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_consignee_address as [Consignee Address],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 

	  '' as [Consignee Address2],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_consignee_address2 as [Consignee Address2], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
 	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Consignee Contact],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_consignee_contact as [Consignee Contact], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Consignee Country],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_consignee_country as [Consignee Country],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Consignee FaxNumber],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_consignee_faxnumber as [Consignee FaxNumber],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  	
 	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Consignee PhoneNumber],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_consignee_phonenumber as [Consignee PhoneNumber],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Consignee Time Fix], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 

	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_consignee_time_fix as [Consignee Time Fix], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Consignee Zip Code],  
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_consignee_zipcode as [Consignee Zip Code],  
	  --<TTS!*!TMW><End><FeaturePack=Euro> 

  
 	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Cross Dock Status],  
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_crossdock_status as [Cross Dock Status],   
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
 	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Customs Document],   
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_customs_document as [Customs Document],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Def Count],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_def_count as [Def Count],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Def CountUnit],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_def_countunit as [Def CountUnit],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Def LoadingMeters],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_def_loadingmeters as [Def LoadingMeters],	
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Def LoadingMetersUnit],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_def_loadingmetersunit as [Def LoadingMetersUnit],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Def Volume],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_def_volume as [Def Volume],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Def VolumeUnit],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_def_volumeunit as [Def VolumeUnit],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Def Weight],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_def_weight as [Def Weight], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Def WeightUnit],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_def_weightunit as [Def WeightUnit], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Entry Port], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_entryport as [Entry Port], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Entry Port ETA], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_entryport_eta as [Entry Port ETA],  
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Entry Port City], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --(select cty_name from city (NOLOCK) where cty_code = ord_entryportcity) as [Entry Port City], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Exit Port], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_exitport as [Exit Port], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Exit Port ETD], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_exitport_etd as [Exit Port ETD], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Exit Port City],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  ----(select cty_name from city (NOLOCK) where cty_code = ord_exitportcity) as [Exit Port City],  

	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Frontier], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_frontier as [Frontier],  
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Frontier Destination Miles], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_frontier_destination_miles as [Frontier Destination Miles], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Frontier Origin Miles], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_origin_frontier_miles as [Frontier Origin Miles], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Reserved Number], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_reserved_number as [Reserved Number],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Revenue Pay], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_revenue_pay as [Revenue Pay], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Revenue Pay Fix],  
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_revenue_pay_fix as [Revenue Pay Fix],  
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Shipper Address],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_shipper_address as [Shipper Address],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Shipper Address 2],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_shipper_address2 as [Shipper Address 2], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Shipper Contact], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_shipper_contact as [Shipper Contact],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Shipper Country], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_shipper_country as [Shipper Country],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Shipper FaxNumber], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_shipper_faxnumber as [Shipper FaxNumber],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Shipper PhoneNumber], 


	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_shipper_phonenumber as [Shipper PhoneNumber], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Shipper Time Fix],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_shipper_time_fix as [Shipper Time Fix],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Shipper Zip Code],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_shipper_zipcode as [Shipper Zip Code],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Total Loading Meters], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_totalloadingmeters as [Total Loading Meters], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Total Loading Meters Unit], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_totalloadingmetersunit as [Total Loading Meters Unit], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Trl Rent Inv],  
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --ord_trlrentinv as [Trl Rent Inv],  
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Total Calculated Weight], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --total_calculated_weight as [Total Calculated Weight],   
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Total Order Calculated Weight],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --total_ord_calculated_weight as [Total Order Calculated Weight],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 


	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Origin Country],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --(select cty_country from city (NOLOCK) where cty_code = ord_origincity) as 'Origin Country',
	  --<TTS!*!TMW><End><FeaturePack=Euro> 

	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Destination Country],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --(select cty_country from city (NOLOCK) where cty_code = ord_destcity) as 'Destination Country',
	  --<TTS!*!TMW><End><FeaturePack=Euro> 	  

          'Other Type1-Ordered By' = (select Company.cmp_othertype1 from Company  (NOLOCK) where orderheader.ord_company = Company.cmp_id),
	  'Other Type2-Ordered By' = (select Company.cmp_othertype2 from Company  (NOLOCK) where orderheader.ord_company = Company.cmp_id),
	   WeightOnStops = (select max(stp_weight) from stops (NOLOCK) where stops.ord_hdrnumber = orderheader.ord_hdrnumber),
	   convert(money,IsNull((select sum(pyd_amount) from paydetail (NOLOCK) where orderheader.mov_number = paydetail.mov_number and pyd_minus > -1),0.00)) as 'PayPerMove2',
	   'Final Move Number' = (select max(a.mov_number) from stops a (NOLOCK) where a.ord_hdrnumber = orderheader.ord_hdrnumber and a.stp_arrivaldate = (select max(b.stp_arrivaldate) from stops b (NOLOCK) where b.ord_hdrnumber = orderheader.ord_hdrnumber)),
	   OrderCancelReason = (select a.ohc_remark from orderheader_cancel_log a (NOLOCK) where a.ord_hdrnumber = orderheader.ord_hdrnumber and a.ohc_cancelled_date = (select max(b.ohc_cancelled_date) from orderheader_cancel_log b (NOLOCK) where b.ord_hdrnumber = a.ord_hdrnumber)),
	   Case When ord_status = 'PPD' Then
		(select Top 1 ivh_carrier from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)
	   Else
		(select top 1 asgn_id from assetassignment (NOLOCK) where assetassignment.mov_number = orderheader.mov_number and asgn_type = 'CAR')
	   End as [Carrier ID],
	   [Paperwork ReceivedYN] = IsNull((select Min(IsNull(pw_received,'N')) from paperwork (NOLOCK) where paperwork.ord_hdrnumber = orderheader.ord_hdrnumber),'N')
	


FROM       dbo.orderheader (NOLOCK)

) as TempOrders

) as TempOrders2











































































GO
GRANT SELECT ON  [dbo].[vTTSTMW_Orders] TO [public]
GO
