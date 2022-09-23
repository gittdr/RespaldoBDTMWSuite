SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/**
 *
 * NAME:
 * dbo.vSSRSRB_InvoiceDetails
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 **/

--SELECT  top 100 * FROM vSSRSRB_InvoiceDetails
CREATE                                                                  View [dbo].[vSSRSRB_InvoiceDetails]
As

Select
	TempInvoiceDetails.*,
	Case When [Master Shipper ID] Is Not Null  And [Master Consignee ID] Is Null Then 
                        (select cmp_name from company a WITH (NOLOCK) where a.cmp_id = [Master Shipper ID])  
        When [Master Consignee ID] Is Not Null and [Master Shipper ID] Is Null Then 
                        (select cmp_name from company a WITH (NOLOCK) where a.cmp_id = [Master Shipper ID]) 
        Else 
                        Case When [Master Bill To ID] Is Null Then 
                                [Master Bill To] 
                        Else 
                                (select cmp_name from company a WITH (NOLOCK) where a.cmp_id = [Master Shipper ID]) 
                        End 
        End as [Responsible Company],
	Case When [Master Shipper ID] Is Not Null  And [Master Consignee ID] Is Null Then 
                       [Master Shipper ID]
        When [Master Consignee ID] Is Not Null and [Master Shipper ID] Is Null Then 
                       [Master Consignee ID]
        Else 
                        Case When [Master Bill To ID] Is Null Then 
                                [Master Bill To ID] 
                        Else 
                                [Master Shipper ID]
                        End 
        End as [Responsible Company ID],

	(Quantity-NonAllocatedMoveMiles) as QuantityMoveMilesVariance,
	DateDiff(mi,[Ship Date],[First Stop Departure Date])/60.0 as [Shipper Detention Time],
	DateDiff(mi,[Delivery Date],[Final Stop Departure Date])/60.0 as [Consignee Detention Time]
From

(

SELECT ivh_invoicenumber as 'Invoice Number', 
       invoiceheader.ivh_mbstatus as 'Master Bill Status List', 
       ivh_billto as 'Bill To ID',
       'Bill To' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ivh_billto),
       (select ord_bookedby from orderheader WITH (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber) as [Booked By],
       ivh_terms as 'Terms',
       ivh_shipper as 'Shipper ID', 
       'Shipper' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ivh_shipper),
       ivh_consignee as 'Consignee ID', 
       'Consignee' = (select cmp_name from company  WITH (NOLOCK) where cmp_id = ivh_consignee), 
       'Master Shipper ID' = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ivh_shipper),
       'Master Consignee ID' = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ivh_consignee), 
       'Master Bill To ID' = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ivh_billto),
       'Master Bill To' = (select cmp_name from company a WITH (NOLOCK) where a.cmp_id = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ivh_billto)), 
       ivh_originpoint as 'Origin Point ID',
       ivh_destpoint as 'Destination Point ID',  
       (select cty_name from city WITH (NOLOCK) where cty_code = ivh_origincity) as 'Origin City',
       (select cty_name from city WITH (NOLOCK) where cty_code = ivh_destcity) as 'Dest City',
       ivh_originstate as 'Origin State', 
       ivh_deststate as 'Dest State', 
       ivh_originregion1 as 'Origin Region 1', 
       ivh_destregion1 as 'Dest Region 1', 
       ivh_supplier as 'Supplier', 
       ivh_shipdate as 'Ship Date', 
       ivh_order_cmd_code as [Invoice Commodity Code],
       [Invoice Commodity Name] = (select cmd_name from commodity WITH (NOLOCK) where cmd_code = ivh_order_cmd_code),
       --Day
       (Cast(Floor(Cast([ivh_shipdate] as float))as smalldatetime)) as [Ship Date Only], 
       Cast(DatePart(yyyy,[ivh_shipdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_shipdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_shipdate]) as varchar(2)) as [Ship Day],
       --Month
       Cast(DatePart(mm,[ivh_shipdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_shipdate]) as varchar(4)) as [Ship Month],
       DatePart(mm,[ivh_shipdate]) as [Ship Month Only],
       --Year
       DatePart(yyyy,[ivh_shipdate]) as [Ship Year],
       ivh_deliverydate as 'Delivery Date',
       --Day
       (Cast(Floor(Cast([ivh_deliverydate] as float))as smalldatetime)) as [Delivery Date Only], 
       Cast(DatePart(yyyy,[ivh_deliverydate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_deliverydate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_deliverydate]) as varchar(2)) as [Delivery Day],
       --Month
       Cast(DatePart(mm,[ivh_deliverydate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_deliverydate]) as varchar(4)) as [Delivery Month],
       DatePart(mm,[ivh_deliverydate]) as [Delivery Month Only],
       --Year
       DatePart(yyyy,[ivh_deliverydate]) as [Delivery Year], 
       ivh_revtype1 as 'RevType1', 
       'RevType1 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ivh_revtype1 and labeldefinition = 'RevType1'),''),
       ivh_revtype2 as 'RevType2', 
       'RevType2 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ivh_revtype2 and labeldefinition = 'RevType2'),''),
       ivh_revtype3 as 'RevType3', 
       'RevType3 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ivh_revtype3 and labeldefinition = 'RevType3'),''),
       ivh_revtype4 as 'RevType4', 
       'RevType4 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ivh_revtype4 and labeldefinition = 'RevType4'),'') ,                 
       ivd_number as 'Invoice Detail Number',
       stp_number as 'Stop Number', 
       ivd_description as 'Description', 
       invoicedetail.cht_itemcode as 'Charge Type',
       'Charge Type Description' = (select cht_description from chargetype WITH (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode), 
       ivd_quantity as 'Quantity', 
       cast(ivd_rate as float) as 'Rate', 
       convert(money,IsNull(ivd_charge,0)) as 'Charge', 
       ivd_taxable1 as 'Tax Table1', 
       ivd_taxable2 as 'Tax Table2', 
       ivd_taxable3 as 'Tax Table3', 
       ivd_taxable4 as 'Tax Table4', 
       ivd_unit as 'Unit', 
       cur_code as 'Currency',
       ivd_currencydate as 'Currency Date',  
       cast(ivd_glnum as varchar(255)) as 'Gl Number', 
       ivd_type as 'Type', 
       ivd_rateunit as 'Rate Unit', 
       ivd_itemquantity as 'Item Quantity', 
       ivd_subtotalptr as 'SubTotal Ptr', 
       ivd_allocatedrev as 'Allocated Revenue', 
       ivd_sequence as 'Sequence', 
       ivh_invoicestatus as 'InvoiceStatus',
       ivd_refnum as 'Reference Number', 
       cmd_code as 'Commodity Code', 
       [Commodity Name] = (select cmd_name from commodity WITH (NOLOCK) where cmd_code = invoicedetail.cmd_code),
       cmp_id as 'Company ID', 
       ivd_distance as 'Distance', 
       ivd_distunit as 'Distance Unit', 
       ivd_wgt as 'Weight', 
       ivd_wgtunit as 'Weight Unit', 
       ivd_count as 'Count', 
       ivd_countunit as 'Count Unit', 
       evt_number as 'Event Number', 
       ivd_reftype as 'RefType', 
       ivd_volume as 'Volume', 
       ivd_volunit as 'Volume Unit', 
       ivd_orig_cmpid as 'Original Company ID',
       ivd_payrevenue as 'Pay Revenue', 
       ivd_sign as 'Sign', 
       ivd_length as 'Length',        
       ivh_taxamount1 as 'Tax Amount 1', 
       ivh_taxamount2 as 'Tax Amount 2', 
       ivh_taxamount3 as 'Tax Amount 3', 
       ivh_taxamount4 as 'Tax Amount 4', 
       ivh_transtype as 'Transaction Type', 
       ivh_creditmemo as 'Credit Memo', 
       ivh_applyto as 'Apply To', 
       ivh_printdate as 'Print Date', 
       --Day
       (Cast(Floor(Cast([ivh_printdate] as float))as smalldatetime)) as [Print Date Only], 
       Cast(DatePart(yyyy,[ivh_printdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_printdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_printdate]) as varchar(2)) as [Print Day],
       --Month
       Cast(DatePart(mm,[ivh_printdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_printdate]) as varchar(4)) as [Print Month],
       DatePart(mm,[ivh_printdate]) as [Print Month Only],
       --Year
       DatePart(yyyy,[ivh_printdate]) as [Print Year],
       ivh_billdate as 'Bill Date', 
       --Day
       (Cast(Floor(Cast([ivh_billdate] as float))as smalldatetime)) as [Bill Date Only], 
       Cast(DatePart(yyyy,[ivh_billdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_billdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_billdate]) as varchar(2)) as [Bill Day],
       --Month
       Cast(DatePart(mm,[ivh_billdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_billdate]) as varchar(4)) as [Bill Month],
       DatePart(mm,[ivh_billdate]) as [Bill Month Only],
       --Year
       DatePart(yyyy,[ivh_billdate]) as [Bill Year],
       ivh_lastprintdate as 'Last Print Date', 
       ivh_originregion2 as 'Origin Region 2', 
       ivh_originregion3 as 'Origin Region 3', 
       ivh_originregion4 as 'Origin Region 4', 
       ivh_destregion2 as 'Dest Region 2',
       ivh_destregion3 as 'Dest Region 3', 
       ivh_destregion4 as 'Dest Region 4', 
       ivh_remark as 'Remarks',
       ivh_driver as 'Driver1 ID', 
       'DrvType1' = IsNull((select mpp_type1 from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType1 Name' = IsNull((select name from labelfile WITH (NOLOCK) ,manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1' and manpowerprofile.mpp_id = ivh_driver),''),
       'DrvType2' = IsNull((select mpp_type2 from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType2 Name' = IsNull((select name from labelfile WITH (NOLOCK) ,manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2' and manpowerprofile.mpp_id = ivh_driver),''),
       'DrvType3' = IsNull((select mpp_type3 from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType3 Name' = IsNull((select name from labelfile WITH (NOLOCK) ,manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3' and manpowerprofile.mpp_id = ivh_driver),''),
       'DrvType4' = IsNull((select mpp_type4 from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType4 Name' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4' and manpowerprofile.mpp_id = ivh_driver),''),
       ivh_driver2 as 'Driver2 ID', 
       ivh_tractor as 'Tractor', 
       'TrcType1' = IsNull((select trc_type1 from tractorprofile WITH (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType1 Name' = IsNull((select name from labelfile WITH (NOLOCK),tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type1 and labeldefinition = 'TrcType1' and trc_number = ivh_tractor),''),
       'TrcType2' = IsNull((select trc_type2 from tractorprofile WITH (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType2 Name' = IsNull((select name from labelfile WITH (NOLOCK),tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type2 and labeldefinition = 'TrcType2' and trc_number = ivh_tractor),''),
       'TrcType3' = IsNull((select trc_type3 from tractorprofile WITH (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType3 Name' = IsNull((select name from labelfile WITH (NOLOCK),tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type3 and labeldefinition = 'TrcType3' and trc_number = ivh_tractor),''),
       'TrcType4'= IsNull((select trc_type4 from tractorprofile WITH (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType4 Name' = IsNull((select name from labelfile WITH (NOLOCK),tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type4 and labeldefinition = 'TrcType4' and trc_number = ivh_tractor),''),       
       ivh_trailer as 'Trailer', 
       'TrlType1' = IsNull((select min(trl_type1) from trailerprofile WITH (NOLOCK) where trl_id  = ivh_trailer),''),
       'TrlType1 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1' and trl_id = ivh_trailer),''),
       'TrlType2' = IsNull((select min(trl_type2) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),''),
       'TrlType2 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type2 and labeldefinition = 'TrlType2' and trl_id = ivh_trailer),''),
       'TrlType3' = IsNull((select min(trl_type3) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),''),
       'TrlType3 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type3 and labeldefinition = 'TrlType3' and trl_id = ivh_trailer),''),
       'TrlType4'= IsNull((select min(trl_type4) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),''),
       'TrlType4 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type4 and labeldefinition = 'TrlType4' and trl_id = ivh_trailer),''),       
       ivh_user_id1 as 'User ID 1', 
       ivh_user_id2 as 'User ID 2', 
       mov_number as 'Move Number', 
       ivh_edi_flag as 'EDI Flag',
       ivh_low_temp as 'Low Temp',
       ivh_high_temp as 'High Temp',
       ivh_xferdate as 'Transfer Date',
       IsNull(ivh_totalcharge,0) as 'InvoiceTotalCharge',
       --Day
       (Cast(Floor(Cast([ivh_xferdate] as float))as smalldatetime)) as [Transfer Date Only], 
       Cast(DatePart(yyyy,[ivh_xferdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_xferdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_xferdate]) as varchar(2)) as [Transfer Day],
       --Month
       Cast(DatePart(mm,[ivh_xferdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_xferdate]) as varchar(4)) as [Transfer Month],
       DatePart(mm,[ivh_xferdate]) as [Transfer Month Only],
       --Year
       DatePart(yyyy,[ivh_xferdate]) as [Transfer Year], 
       ivh_order_by as 'Ordered By ID', 
       invoicedetail.tar_number as 'Tarrif Number',
       ivh_bookyear as 'Book Year', 
       ivh_bookmonth as 'Book Month',
       invoicedetail.tar_tariffitem as 'Tariff Item',
       ivh_maxlength as 'Max Length',
       ivh_maxwidth as 'Max Width',
       ivh_maxheight as 'Max Height',
       ivh_mbstatus as 'Master Bill Status', 
       ivh_mbnumber as 'Master Bill Number', 
       ord_number as 'Order Number',
       ivh_splitbill_flag as 'Splitill Flag',
       ivh_company as 'Company',
       ivh_carrier as 'Carrier',
       ivh_loadtime as 'Load Time',
       ivh_unloadtime as 'Unload Time',
       ivh_drivetime as 'Drive Time',
       ivh_rateby as 'Rate By',
       ivh_revenue_date as 'Revenue Date',
       ivh_batch_id as 'Batch ID',
       ivh_stopoffs as 'Stop Offs',
       Ivh_quantity_type as 'Quantity Type',
       ivh_originzipcode as 'Origin Zip Code',
       ivh_destzipcode as 'Dest Zip Code',
       ivh_paperworkstatus as 'PaperWork Status',
       ivh_definition as 'Definition',
       ivh_hideshipperaddr as 'Hide Shipper Addr',		
       ivh_hideconsignaddr as 'Hide Consignee Addr',
       ivh_showshipper as 'Show Shipper',
       ivh_showcons as 'Show Cons',
       ivh_mileage_adjustment as 'Mileage Adjustment',
       ivh_allinclusivecharge as 'All Inclusive Charge',
       ivh_order_cmd_code as 'Order CMD Code',		
       ivh_applyto_definition as 'ApplyTo Definition',
       ivh_reftype as 'Ref Type',
       ivh_paperwork_override as 'PaperWork Override',
       ivh_attention as 'Attention',
       ivh_cmrbill_link as 'CMRBill Link',	
       ivh_mbperiod as 'Master Bill Period',
       ivh_mbperiodstart as 'Master Bill Start',
       invoicedetail.ord_hdrnumber as 'Order Header Number',
       Case when ivd_number = (select min(ivd_number) from invoicedetail b WITH (NOLOCK)  where b.ivh_hdrnumber = invoicedetail.ivh_hdrnumber) Then
		1
       Else
		0
       End as InvoiceCount,
       (select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoicedetail.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as RefType1,
       (select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoicedetail.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as RefNumber1,
       (select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoicedetail.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as RefType2,
       (select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoicedetail.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as RefNumber2,
       (select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoicedetail.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as RefType3,
       (select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoicedetail.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as RefNumber3,
       (select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoicedetail.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as RefType4,
       (select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoicedetail.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as RefNumber4,
       (select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoicedetail.ord_hdrnumber and ref_sequence = 5 and ref_table = 'orderheader') as RefType5,
       (select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoicedetail.ord_hdrnumber and ref_sequence = 5 and ref_table = 'orderheader') as RefNumber5,
       'Trailer Company' = (select min(trl_company) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),    
       'Trailer Company Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_company and labeldefinition = 'Company' and trl_id = ivh_trailer),''),
       'Trailer Fleet' = (select min(trl_fleet) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),    
       'Trailer Fleet Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_fleet and labeldefinition = 'Fleet' and trl_id = ivh_trailer),''),
       'Trailer Terminal' = (select min(trl_terminal) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),    
       'Trailer Terminal Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_terminal and labeldefinition = 'Terminal' and trl_id = ivh_trailer),''),
       'Trailer Division' = (select min(trl_division) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),
       'Trailer Division Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_division and labeldefinition = 'Division' and trl_id = ivh_trailer),''),
       'Sub Company ID' = (select ord_subcompany from orderheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),
       'Sub Company' = (select Company.cmp_name from Company WITH (NOLOCK),orderheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber and orderheader.ord_subcompany = Company.cmp_id),   
		ivh_currency as 'Invoice Currency',
		'NonAllocatedMoveMiles' = (select sum(stp_lgh_mileage) from stops WITH (NOLOCK),orderheader WITH (NOLOCK) where orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber and stops.mov_number = orderheader.mov_number),
		(select cht_edicode from chargetype WITH (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [EDI Code],
		(select cht_basis from chargetype WITH (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [Basis],	
		(select cht_basisunit from chargetype WITH (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [Basis Unit],	
		(select cht_basisper from chargetype WITH (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [Basis Per],
		 (select cht_primary from chargetype with (nolock) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [PrimaryYN],
		(select min(cty_region1) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region1],
        (select min(cty_region2) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region2],
        (select min(cty_region3) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region3],
        (select min(cty_region4) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region4],
        (select min(cty_region1) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region1],
        (select min(cty_region2) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region2],
        (select min(cty_region3) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region3],
        (select min(cty_region4) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region4] ,
		lgh_type1 = (select min(RTrim(trk_lghtype1)) from tariffkey where trk_number = tar_number),
		[Final Stop Departure Date] = (select max(stp_departuredate) from stops WITH (NOLOCK) where stops.ord_hdrnumber = invoicedetail.ord_hdrnumber),
		[First Stop Departure Date] = (select min(stp_departuredate) from stops WITH (NOLOCK) where stops.ord_hdrnumber = invoicedetail.ord_hdrnumber),
		(SELECT cmp_othertype1 from company WITH (NOLOCK) where [ivh_shipper] = cmp_id)  As [Shipper OtherType1],   
        (SELECT cmp_othertype2 from company WITH (NOLOCK) where [ivh_shipper] = cmp_id)  As [Shipper OtherType2],
		(SELECT cmp_othertype1 from company WITH (NOLOCK) where [ivh_billto] = cmp_id) 	 As [BillTo OtherType1],   
        (SELECT cmp_othertype2 from company WITH (NOLOCK) where [ivh_billto] = cmp_id) 	 As [BillTo OtherType2],
        'Other Type1-Ordered By' = (select Company.cmp_othertype1 from Company  WITH (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
        'Other Type2-Ordered By' = (select Company.cmp_othertype2 from Company  WITH (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
		[GL 12th Digit Value]= (select top 1 gl_matchvalue from gl_reset WITH (NOLOCK) where gl_value = substring(ivd_glnum,gl_startposition,gl_length) and gl_startposition = 12 and gl_transferto = 'AR' order by gl_matchvalue desc),
		[TypeOfCharge] = (select cht_typeofcharge from chargetype WITH (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode),
		CountOfFirstInvoiceDetailForOrder = 
				Case When ivd_number = (select min(b.ivd_number) from invoicedetail b WITH (NOLOCK) where b.ord_hdrnumber = invoicedetail.ord_hdrnumber and b.ord_hdrnumber >0) Then
						1			
					    Else
						0
					    End
	
	
	
FROM invoiceheader WITH (NOLOCK)
join invoicedetail WITH (NOLOCK) on InvoiceHeader.ivh_hdrnumber = InvoiceDetail.ivh_hdrnumber

) As TempInvoiceDetails


GO
GRANT DELETE ON  [dbo].[vSSRSRB_InvoiceDetails] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_InvoiceDetails] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_InvoiceDetails] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_InvoiceDetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_InvoiceDetails] TO [public]
GO
