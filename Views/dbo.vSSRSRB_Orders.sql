SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  View [dbo].[vSSRSRB_Orders]


As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_Orders]
 *
 * TYPE:
 * View
 select * from vSSRSRB_Orders
 *
 * DESCRIPTION:
 * View based on the old vttstmw_Orders
 * 3/19/2014 JR created new view for SSRS
 * 12/22/14 EJD add orderheader.ord_status as 'DispatchStatus' for report part 
 * 01/26/2015 MTR	fixed join to city table for consignee ( it was same as shipper)
 * 08/06/2015 MTR added origin earliest date only and origin latest date only
 **/
select TempOrders2.*,
       convert(money,IsNull((PercentofRevenueForMovement * PayPerMove),0.00)) as Pay,
       convert(money,IsNull([Total Revenue] - (PercentofRevenueForMovement * PayPerMove),0.00)) As Net,
       convert(money,IsNull((PercentofRevenueForMovement * PayPerMove2),0.00)) as Pay2,
       convert(money,IsNull([Total Revenue] - (PercentofRevenueForMovement * PayPerMove2),0.00)) As Net2,
             [Carrier Name] = (select top 1 car_name from carrier WITH (NOLOCK) where car_id = [Carrier ID])

from

(

select TempOrders.*,
       
  	Case When [Total Revenue For Movement] = 0  Then
                convert(float,1)/convert(float,(select count(c.ord_hdrnumber) from orderheader c WITH (NOLOCK) where c.mov_number = [Move Number])) 
       	Else
	        convert(float,[Total Revenue])/convert(float,[Total Revenue For Movement])
       	End as PercentofRevenueForMovement,
	'Bill To Name' = (select cmp_name from company WITH (NOLOCK) where cmp_id = [Bill To ID]),
        'Master Bill To ID' = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = [Bill To ID]),
	'Master Bill To Name' = (select cmp_name from company a WITH (NOLOCK) where a.cmp_id = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = [Bill To ID])),
	(select cmp_othertype1 from company where cmp_id = [Bill To ID]) as [Other Type 1],
	(select cmp_othertype2 from company where cmp_id = [Bill To ID]) as [Other Type 2],
	DatePart(hour,AvailabledateFromAudit) as AvailableDateFromAuditHour,
	 case when [Delivery Date] < AvailableDateFromAudit Then

            	0
	 Else

   		cast(cast(Datediff(mi,AvailableDateFromAudit,[Delivery Date]) as float)/60 as decimal(15,2)) 
	 End as AvailableAuditToDeliveryLag



                        

            


from

(

SELECT     ord_company as 'Ordered By ID', 
           'Ordered By' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_company),
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
           ord_status as 'OrderStatus', 
           ord_originpoint as 'Origin Point ID', 
	   (select Min(a.stp_loadstatus) from stops a WITH (NOLOCK) Where a.mov_number = orderheader.mov_number and a.stp_mfh_sequence = (select max(b.stp_mfh_sequence) from stops b where b.mov_number = a.mov_number))  as LastLoadStatusOnMove,
           'Orgin Point' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_originpoint),
           ord_destpoint as 'Destination Point ID', 
           'Destination Point' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_destpoint),
           ord_invoicestatus as 'InvoiceStatus', 
           (
	   convert(money,IsNull((select sum(a.ord_totalcharge) from orderheader a where a.mov_number = orderheader.mov_number and a.ord_invoicestatus <> 'PPD'),0.00)) 
		+   
	   convert(money,IsNull((select sum(a.ivh_totalcharge) from invoiceheader a where a.mov_number = orderheader.mov_number),0.00))
            )
           As 'Total Revenue For Movement',
           (select cty_name from city WITH (NOLOCK) where cty_code = ord_origincity) as 'Origin City',
           (select cty_name from city WITH (NOLOCK) where cty_code = ord_destcity) as 'Dest City', 
	   (select cty_zip from city WITH (NOLOCK) where cty_code = ord_origincity) as 'Origin Zip Code',
           (select cty_zip from city WITH (NOLOCK) where cty_code = ord_destcity) as 'Dest Zip Code', 
           ord_originstate as 'Origin State', 
           ord_deststate as 'Destination State', 
           ord_supplier as 'Supplier ID', 
	   Case When ord_invoicestatus = 'PPD' Then
   	        (select Top 1 ivh_billto from InvoiceHeader WITH (NOLOCK) where InvoiceHeader.ord_hdrnumber = OrderHeader.ord_hdrnumber)
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
	   CASE DatePart(dw,[ord_completiondate]) WHEN 1 THEN 'Sunday'
                 			     WHEN 2 THEN 'Monday'
                 			     WHEN 3 THEN 'Tuesday'
                 			     WHEN 4 THEN 'Wednesday'
                 			     WHEN 5 THEN 'Thursday'
                 			     WHEN 6 THEN 'Friday'
                 			     WHEN 7 THEN 'Saturday'
                 			     ELSE SPACE(0)
           END as [Delivery DayOfWeek],
	   DatePart(dw,[ord_completiondate]) as [Delivery DayOfWeekNumeric],
           ord_revtype1 as 'RevType1', 
           'RevType1 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype1 and labeldefinition = 'RevType1'),''),
	   ord_revtype2 as 'RevType2',
	   'RevType2 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype2 and labeldefinition = 'RevType2'),''),
	   ord_revtype3 as 'RevType3',
	   'RevType3 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype3 and labeldefinition = 'RevType3'),''),
	   ord_revtype4 as 'RevType4',
           'RevType4 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype4 and labeldefinition = 'RevType4'),''),
           ord_totalweight as 'Total Weight', 
           ord_totalpieces as 'Total Pieces', 
           ord_totalmiles as 'Total Miles', 
           
	   'BOL Number' = (Select Top 1 ref_number
		    	   From   ReferenceNumber WITH (NOLOCK)  
		    	   Where  (ref_type = 'BL#' or ref_type = 'BOL' or ref_type = 'B/L#')
                            	   and 
                            	   (orderheader.ord_hdrnumber = referencenumber.ref_tablekey and ref_table = 'orderheader')
		   		),

           Case When ord_invoicestatus = 'PPD' Then
		convert(money,IsNull((select sum(invoiceheader.ivh_totalcharge) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),0))
           Else
		convert(money,IsNull(ord_totalcharge,0))
	   End as 'Total Revenue',
	   ord_currency as 'Currency', 
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
           'Shipper Name' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_shipper),
           shp.cmp_address1 as [Shipper Address 1],
           shp.cmp_address2 as [Shipper Address 2],
           shp.cty_nmstct as [Shipper City State],
           shp.cmp_zip as [Shipper Zip Code],
           ord_consignee as 'Consignee ID', 
           'Consignee Name' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_consignee),
           con.cmp_address1 as [Consignee Address 1],
           con.cmp_address2 as [Consignee  Address 2],
           con.cty_nmstct as [Consignee  City State],
           con.cmp_zip as [Consignee  Zip Code],
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
           'Sub Company Name' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_subcompany),
	   ord_lowtemp as 'Low Temperature', 
           ord_hitemp as 'High Temperature', 
           ord_quantity as 'Quantity', 
           ord_rate as 'Rate', 
	   PickupCount = (select count(stops.ord_hdrnumber) from stops WITH (NOLOCK) where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_type = 'PUP'),
           DropCount = (select count(stops.ord_hdrnumber) from stops WITH (NOLOCK) where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_type = 'DRP'),
	   --<TTS!*!TMW><Begin><SQLVersion=7>
	   Case When ord_invoicestatus = 'PPD' Then
		convert(money,IsNull((select sum(invoiceheader.ivh_charge) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),0))
           Else
		convert(money,IsNull(ord_charge,0))
	   End as 'Line Haul Revenue',
 	   ord_rateunit as 'Rate Unit', 
           ord_unit as 'Unit', 
           trl_type1 as 'Trailer Type1', 
           ord_driver1 as 'Driver1 ID', 
           ord_driver2 as 'Driver2 ID', 
           ord_tractor as 'Tractor ID', 
           'TrcType1' = IsNull((select trc_type1 from tractorprofile WITH (NOLOCK) where trc_number = ord_tractor),''),
           'TrcType1 Name' = IsNull((select name from labelfile WITH (NOLOCK) ,tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type1 and labeldefinition = 'TrcType1' and trc_number = ord_tractor),''),
           'TrcType2' = IsNull((select trc_type2 from tractorprofile WITH (NOLOCK) where trc_number = ord_tractor),''),
           'TrcType2 Name' = IsNull((select name from labelfile WITH (NOLOCK),tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type2 and labeldefinition = 'TrcType2' and trc_number = ord_tractor),''),
           'TrcType3' = IsNull((select trc_type3 from tractorprofile WITH (NOLOCK) where trc_number = ord_tractor),''),
           'TrcType3 Name' = IsNull((select name from labelfile WITH (NOLOCK),tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type3 and labeldefinition = 'TrcType3' and trc_number = ord_tractor),''),
           'TrcType4'= IsNull((select trc_type4 from tractorprofile WITH (NOLOCK) where trc_number = ord_tractor),''),
           'TrcType4 Name' = IsNull((select name from labelfile WITH (NOLOCK),tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type4 and labeldefinition = 'TrcType4' and trc_number = ord_tractor),''),       
	   ord_trailer as 'Trailer ID', 
	   'TrlType1' = IsNull((select min(trl_type1) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),''),
           'TrlType1 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1' and trl_id = ord_trailer),''),
           'TrlType2' = IsNull((select min(trl_type2) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),''),
           'TrlType2 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type2 and labeldefinition = 'TrlType2' and trl_id = ord_trailer),''),
           'TrlType3' = IsNull((select min(trl_type3) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),''),
           'TrlType3 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type3 and labeldefinition = 'TrlType3' and trl_id = ord_trailer),''),
           'TrlType4'= IsNull((select min(trl_type4) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),''),
           'TrlType4 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type4 and labeldefinition = 'TrlType4' and trl_id = ord_trailer),''),       
           ord_length as 'Length', 
           ord_width as 'Width', 
           ord_height as 'Height', 
           ord_lengthunit as 'Length Unit', 
           ord_widthunit as 'Width Unit', 
           ord_heightunit as 'Height Unit', 
           ord_reftype as 'Ref Type', 
           orderheader.cmd_code as 'Commodity Code', 
           ord_description as 'Commodity Description', 
           ord_terms as 'Order Terms', 
           cht_itemcode as 'Charge Type', 
           ord_origin_earliestdate as 'Origin Earliest Date', 
		   (Cast(Floor(Cast(ord_origin_earliestdate as float))as smalldatetime)) AS [Origin Earliest Date Only],
           ord_origin_latestdate as 'Origin Latest Date', 
		   (Cast(Floor(Cast(ord_origin_latestdate as float))as smalldatetime)) AS [Origin Latest Date Only],
           ord_odmetermiles as 'Odometer Miles', 
           ord_stopcount as 'Stop Count', 
           ord_dest_earliestdate as 'Destination Earliest Date', 
           (Cast(Floor(Cast(ord_dest_earliestdate as float))as smalldatetime)) AS [Destination Earliest Date Only],
           ord_dest_latestdate as 'Destination Latest Date', 
           (Cast(Floor(Cast(ord_dest_latestdate as float))as smalldatetime)) AS [Destination Latest Date Only],
           ref_sid as 'Reference SID', 
           ref_pickup as 'Reference Pickup', 
           ord_cmdvalue as 'CmdValue', 
	  
	   Case When ord_invoicestatus = 'PPD' Then
		convert(money,IsNull((select sum(invoiceheader.ivh_totalcharge) - sum(invoiceheader.ivh_charge) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),0))
           Else
		convert(money,IsNull(ord_accessorial_chrg,0))
	   End as 'Accessorial Revenue', 
 
           ord_availabledate as 'Available Date', 
           ord_miscqty as 'Misc Qty' , 
           ord_tempunits as 'Temp Units', 
           ord_datetaken as 'Date Taken', 
            (Cast(Floor(Cast(ord_datetaken  as float))as smalldatetime)) AS [Date Taken Only],
           ord_totalweightunits as 'Total Weight Units', 
           ord_totalvolumeunits as 'TotalVolume Units', 
           ord_totalcountunits as 'Total Count Units', 
	   ord_loadtime as 'Load Time', 
           ord_unloadtime as 'Unload Time', 
           ord_drivetime as 'Drive Time', 
           ord_rateby as 'Rate By', 
           ord_quantity_type as 'Quantity Type', 
           ord_thirdpartytype1 as 'Third Party Type1', 
	  (select tpr_name from thirdpartyprofile WITH (NOLOCK) where tpr_id = ord_thirdpartytype1) as 'Third Party Type1 Name', 
           ord_thirdpartytype2 as 'Third Party Type2', 
	  (select tpr_name from thirdpartyprofile WITH (NOLOCK) where tpr_id = ord_thirdpartytype2) as 'Third Party Type2 Name',
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
 	   (select top 1 labelfile.name from labelfile WITH (NOLOCK),serviceexception WITH (NOLOCK) where labelfile.abbr =  sxn_expcode and sxn_ord_hdrnumber = orderheader.ord_hdrnumber) as [Exception Code],
	   cast((select top 1 sxn_description from serviceexception WITH (NOLOCK) where sxn_ord_hdrnumber = orderheader.ord_hdrnumber) as varchar(255)) as [Exception Description],
	   (select top 1 sxn_expdate from serviceexception WITH (NOLOCK) where sxn_ord_hdrnumber = orderheader.ord_hdrnumber) as [Exception Date],
		(select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as RefType1,
		(select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as RefNumber1,
		(select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as RefType2,
		(select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as RefNumber2,
		(select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as RefType3,
		(select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as RefNumber3,
		(select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as RefType4,
		(select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as RefNumber4,
		(select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 5 and ref_table = 'orderheader') as RefType5,
		(select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 5 and ref_table = 'orderheader') as RefNumber5,
		(select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 6 and ref_table = 'orderheader') as RefType6,
		(select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 6 and ref_table = 'orderheader') as RefNumber6,
		(select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 7 and ref_table = 'orderheader') as RefType7,
		(select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 7 and ref_table = 'orderheader') as RefNumber7,
		(select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 8 and ref_table = 'orderheader') as RefType8,
		(select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = orderheader.ord_hdrnumber and ref_sequence = 8 and ref_table = 'orderheader') as RefNumber8,

           convert(money,IsNull((select sum(pyd_amount) from paydetail WITH (NOLOCK) where orderheader.mov_number = paydetail.mov_number and pyd_minus = 1),0.00)) as 'PayPerMove',   
	   'Trailer Company' = (select min(trl_company) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Company Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_company and labeldefinition = 'Company' and trl_id = ord_trailer),''),
	   'Trailer Fleet' = (select min(trl_fleet) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Fleet Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_fleet and labeldefinition = 'Fleet' and trl_id = ord_trailer),''),
	   'Trailer Terminal' = (select min(trl_terminal) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Terminal Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_terminal and labeldefinition = 'Terminal' and trl_id = ord_trailer),''),
	   'Trailer Division' = (select min(trl_division) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Division Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_division and labeldefinition = 'Division' and trl_id = ord_trailer),''),

	   (select min(ivh_billdate) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Bill Date',
	   (select min(ivh_revenue_date) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Revenue Date',	   
           (select min(ivh_xferdate) from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Transfer Date',

	    Case When ord_revtype1 In ('Outbound','Out') Or ord_revtype2 In ('Outbound','Out') Or  ord_revtype3 In ('Outound','Out') Or  ord_revtype4 In ('Outound','Out') Then
			 IsNull((select Min('Y') from orderheader b WITH (NOLOCK) where b.ord_startdate > orderheader.ord_completiondate and DateDiff(hour,orderheader.ord_completiondate,b.ord_startdate) < 13 and orderheader.ord_tractor = b.ord_tractor and (b.ord_revtype1 In ('Inbound','In') Or b.ord_revtype2 In ('Inbound','In') Or  b.ord_revtype3 In ('Inbound','In') Or  b.ord_revtype4 In ('Inbound','In'))),'N')
	    Else
			'NotApplicable'
	    End as BackHaulLoadYNOrNA,		
	
	    (select Min(cty_region1) from city WITH (NOLOCK) Where ord_origincity = cty_code) as [Origin Region1],
            (select Min(cty_region2) from city WITH (NOLOCK) Where ord_origincity = cty_code) as [Origin Region2],
            (select Min(cty_region3) from city WITH (NOLOCK) Where ord_origincity = cty_code) as [Origin Region3],
            (select Min(cty_region4) from city WITH (NOLOCK) Where ord_origincity = cty_code) as [Origin Region4],
            (select Min(cty_region1) from city WITH (NOLOCK) Where ord_destcity = cty_code) as [Destination Region1],
            (select Min(cty_region2) from city WITH (NOLOCK) Where ord_destcity = cty_code) as [Destination Region2],
            (select Min(cty_region3) from city WITH (NOLOCK) Where ord_destcity = cty_code) as [Destination Region3],
            (select Min(cty_region4) from city WITH (NOLOCK) Where ord_destcity = cty_code) as [Destination Region4],	
	    case when ord_originstate = ord_deststate then
		IsNull((select 'N' from orderheader b where b.ord_hdrnumber = orderheader.ord_hdrnumber and b.ord_hdrnumber Not In (select stops.ord_hdrnumber from stops WITH (NOLOCK) where stops.ord_hdrnumber = b.ord_hdrnumber and stp_state <> orderheader.ord_originstate)),'Y')
	    Else
		'Y'
	    End as LeftState,

	   'OrderTrlType1' = trl_type1,
           'OrderTrlType1 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1'),''),
	  
      'Other Type1-Ordered By' = (select Company.cmp_othertype1 from Company  WITH (NOLOCK) where orderheader.ord_company = Company.cmp_id),
	  'Other Type2-Ordered By' = (select Company.cmp_othertype2 from Company  WITH (NOLOCK) where orderheader.ord_company = Company.cmp_id),
	   WeightOnStops = (select max(stp_weight) from stops WITH (NOLOCK) where stops.ord_hdrnumber = orderheader.ord_hdrnumber),
	   convert(money,IsNull((select sum(pyd_amount) from paydetail WITH (NOLOCK) where orderheader.mov_number = paydetail.mov_number and pyd_minus > -1),0.00)) as 'PayPerMove2',
	   'Final Move Number' = (select max(a.mov_number) from stops a WITH (NOLOCK) where a.ord_hdrnumber = orderheader.ord_hdrnumber and a.stp_arrivaldate = (select max(b.stp_arrivaldate) from stops b WITH (NOLOCK) where b.ord_hdrnumber = orderheader.ord_hdrnumber)),
	   OrderCancelReason = (select a.ohc_remark from orderheader_cancel_log a WITH (NOLOCK) where a.ord_hdrnumber = orderheader.ord_hdrnumber and a.ohc_cancelled_date = (select max(b.ohc_cancelled_date) from orderheader_cancel_log b WITH (NOLOCK) where b.ord_hdrnumber = a.ord_hdrnumber)),
	   Case When ord_status = 'PPD' Then
		(select Top 1 ivh_carrier from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)
	   Else
		(select top 1 asgn_id from assetassignment WITH (NOLOCK) where assetassignment.mov_number = orderheader.mov_number and asgn_type = 'CAR')
	   End as [Carrier ID],
	   [Paperwork ReceivedYN] = IsNull((select Min(IsNull(pw_received,'N')) from paperwork WITH (NOLOCK) where paperwork.ord_hdrnumber = orderheader.ord_hdrnumber),'N'),
	   [Commodity Class Name]= (select ccl_description from commodity WITH (NOLOCK),commodityclass WITH (NOLOCK) where commodityclass.ccl_code = commodity.cmd_class and commodity.cmd_code = orderheader.cmd_code),
       [Commodity Class Code]= (select ccl_code from commodity WITH (NOLOCK),commodityclass WITH (NOLOCK) where commodityclass.ccl_code = commodity.cmd_class and commodity.cmd_code = orderheader.cmd_code),
	   (select top 1 labelfile.name from labelfile WITH (NOLOCK),serviceexception WITH (NOLOCK) where labelfile.abbr =  sxn_expcode and sxn_ord_hdrnumber = orderheader.ord_hdrnumber) as [Service Exception Code],
 	   Case When (select count(*) from expedite_audit where expedite_audit.ord_hdrnumber = orderheader.ord_hdrnumber and activity like '%orderheader%' and update_note like '%-> AVL%' ) > 0 Then
		(select top 1 updated_dt from expedite_audit where expedite_audit.ord_hdrnumber = orderheader.ord_hdrnumber and activity like '%orderheader%' and update_note like '%-> AVL%' order by updated_dt desc)

 	   Else

 		Case When 'AVL' = ord_status Then
  			(select max(updated_dt) from expedite_audit WITH (NOLOCK) where expedite_audit.ord_hdrnumber = orderheader.ord_hdrnumber)
 		Else
  			NULL
 		End

 	End as AvailableDateFromAudit,
    orderheader.ord_status as 'DispatchStatus', --EJD 12.22.14
	
	[Delivery Instructions] = IsNull((select Top 1 stp_comment from stops WITH (NOLOCK) where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_type = 'DRP' Order By stp_arrivaldate desc),'')

FROM       dbo.orderheader WITH (NOLOCK)
left outer join dbo.company shp with (nolock) on orderheader.ord_shipper = shp.cmp_id
left outer join dbo.company con with (nolock) on orderheader.ord_consignee = con.cmp_id

) as TempOrders

) as TempOrders2


GO
