SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  View [dbo].[vSSRSRB_OrderInformation]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_OrderInformation
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data for OrderInformation
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Created
 **/
 
SELECT     ord_company as 'Ordered By ID', 
           'Ordered By' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_company),
	       ord_number as 'Order Number', 
           ord_customer as 'Customer ID', 
	       ord_bookdate as 'Book Date', 
       	   (Cast(Floor(Cast([ord_bookdate] as float))as smalldatetime)) as [Book Date Only], 
           Cast(DatePart(yyyy,[ord_bookdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_bookdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_bookdate]) as varchar(2)) as [Book Day],
           Cast(DatePart(mm,[ord_bookdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_bookdate]) as varchar(4)) as [Book Month],
           DatePart(mm,[ord_bookdate]) as [Book Month Only],
           DatePart(yyyy,[ord_bookdate]) as [Book Year], 
	       ord_bookedby as 'Booked By', 
           ord_status as 'OrderStatus', 
           ord_originpoint as 'Origin Point ID', 
	   (select Min(a.stp_loadstatus) from stops a WITH (NOLOCK) Where a.mov_number = orderheader.mov_number and a.stp_mfh_sequence = (select max(b.stp_mfh_sequence) from stops b where b.mov_number = a.mov_number))  as LastLoadStatusOnMove,
           'Orgin Point' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_originpoint),
           ord_destpoint as 'Destination Point ID', 
           'Destination Point' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_destpoint),
           ord_invoicestatus as 'InvoiceStatus', 
           (select cty_name from city WITH (NOLOCK) where cty_code = ord_origincity) as 'Origin City',
           (select cty_name from city WITH (NOLOCK) where cty_code = ord_destcity) as 'Dest City', 
	   (select cty_zip from city WITH (NOLOCK) where cty_code = ord_origincity) as 'Origin Zip Code',
           (select cty_zip from city WITH (NOLOCK) where cty_code = ord_destcity) as 'Dest Zip Code', 
           ord_originstate as 'Origin State', 
           ord_deststate as 'Destination State', 
           ord_supplier as 'Supplier ID', 
           ord_billto as 'Bill To ID', 
           'Bill To' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_billto),
           'Master Bill To ID' = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ord_billto),
	       'Master Bill To' = (select cmp_name from company a WITH (NOLOCK) where a.cmp_id = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ord_billto)), 
	       ord_startdate as 'Ship Date', 
       	   (Cast(Floor(Cast([ord_startdate] as float))as smalldatetime)) as [Ship Date Only], 
           Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_startdate]) as varchar(2)) as [Ship Day],
           Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) as [Ship Month],
           DatePart(mm,[ord_startdate]) as [Ship Month Only],
           DatePart(yyyy,[ord_startdate]) as [Ship Year],
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
           Cast(DatePart(mm,[ord_completiondate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_completiondate]) as varchar(4)) as [Delivery Month],
           DatePart(mm,[ord_completiondate]) as [Delivery Month Only],
           DatePart(yyyy,[ord_completiondate]) as [Delivery Year], 
           ord_revtype1 as 'RevType1', 
           'RevType1 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype1 and labeldefinition = 'RevType1'),''),
	   ord_revtype2 as 'RevType2',
	   'RevType2 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype2 and labeldefinition = 'RevType2'),''),
	   ord_revtype3 as 'RevType3',
	   'RevType3 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype3 and labeldefinition = 'RevType3'),''),
	   ord_revtype4 as 'RevType4',
           'RevType4 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype4 and labeldefinition = 'RevType4'),''),
	   ord_currency as 'Currency', 
           --**Currency Date**
	   ord_currencydate as 'Currency Date' , 
       	   (Cast(Floor(Cast([ord_currencydate] as float))as smalldatetime)) as [Currency Date Only], 
           Cast(DatePart(yyyy,[ord_currencydate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_currencydate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_currencydate]) as varchar(2)) as [Currency Day],
           Cast(DatePart(mm,[ord_currencydate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_currencydate]) as varchar(4)) as [Currency Month],
           DatePart(mm,[ord_currencydate]) as [Currency Month Only],
           DatePart(yyyy,[ord_currencydate]) as [Currency Year], 
           ord_hdrnumber as 'Order Header Number', 
           ord_refnum as 'Reference Number', 
           ord_invoicewhole as 'Invoice Whole', 
           ord_remark as 'Remark', 
           ord_shipper as 'Shipper ID', 
           'Shipper' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_shipper),
           ord_consignee as 'Consignee ID', 
           'Consignee' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_consignee),
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
           'Sub Company' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_subcompany),
	       ord_lowtemp as 'Low Temperature', 
           ord_hitemp as 'High Temperature', 
           ord_rate as 'Rate', 
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
           cmd_code as 'Commodity Code', 
           ord_description as 'Commodity Description', 
           ord_terms as 'Order Terms', 
           cht_itemcode as 'Charge Type', 
           ord_origin_earliestdate as 'Origin Earliest Date', 
           ord_origin_latestdate as 'Origin Latest Date', 
           ord_dest_earliestdate as 'Destination Earliest Date', 
           ord_dest_latestdate as 'Destination Latest Date', 
           ref_sid as 'Reference SID', 
           ref_pickup as 'Reference Pickup', 
           ord_cmdvalue as 'CmdValue', 
           ord_availabledate as 'Available Date', 
           ord_miscqty as 'Misc Qty' , 
           ord_datetaken as 'Date Taken', 
	       ord_loadtime as 'Load Time', 
           ord_unloadtime as 'Unload Time', 
           ord_drivetime as 'Drive Time', 
           ord_rateby as 'Rate By', 
           ord_quantity_type as 'Quantity Type', 
           ord_thirdpartytype1 as 'Third Party Type1', 
           ord_thirdpartytype2 as 'Third Party Type2', 
           ord_charge_type as 'Order Charge Type', 
           ord_bol_printed as 'Bol Printed', 
           ord_fromorder as 'From Order', 
           ord_mintemp as 'Min Temp', 
           ord_maxtemp as 'Max Temp', 
           ord_distributor as 'Distributor', 
           opt_trc_type4 as 'Option Tractor Type4', 
           opt_trl_type4 as 'Option Trailer Type4', 
           appt_init as 'Appt Init', 
           appt_contact as 'Appt Contact', 
           ord_ratingunit as 'Rating Unit', 
           ord_booked_revtype1 as 'Booked RevType1', 
           ord_mileagetable as 'Mileage Table', 
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
           ord_fromschedule as 'From Schedule',
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


       (select cmp_othertype1 from company where cmp_id = ord_billto) as [Other Type 1],
	   (select cmp_othertype2 from company where cmp_id = ord_billto) as [Other Type 2],
	   
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

       'Other Type1-Ordered By' = (select Company.cmp_othertype1 from Company  WITH (NOLOCK) where orderheader.ord_company = Company.cmp_id),
	   'Other Type2-Ordered By' = (select Company.cmp_othertype2 from Company  WITH (NOLOCK) where orderheader.ord_company = Company.cmp_id)
	  
FROM   dbo.orderheader WITH (NOLOCK)

GO
GRANT SELECT ON  [dbo].[vSSRSRB_OrderInformation] TO [public]
GO
