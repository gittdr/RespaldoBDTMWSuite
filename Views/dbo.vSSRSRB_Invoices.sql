SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/**
 *
 * NAME:
 * dbo.vSSRSRB_Invoices
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

CREATE   View [dbo].[vSSRSRB_Invoices]

--select * from vSSRSRB_Invoices
As


SELECT ivh_invoicenumber as 'Invoice Number', 
       ivh_order_by as 'Ordered By ID',
       'Ordered By' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ivh_order_by),
       ivh_billto as 'Bill To ID', 
       'Bill To Name' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ivh_billto),
       ivh_terms as 'Terms',
       convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Total Revenue',
       ivh_shipper as 'Shipper ID', 
       'Shipper Name' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ivh_shipper),
       ivh_consignee as 'Consignee ID', 
       'Consignee Name' = (select cmp_name from company  WITH (NOLOCK) where cmp_id = ivh_consignee),
       ivh_originpoint as 'Origin Point ID',
       ivh_destpoint as 'Destination Point ID', 
       ivh_invoicestatus as 'InvoiceStatus', 
       'Master Bill To ID' = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ivh_billto),
       'Master Bill To' = (select cmp_name from company a WITH (NOLOCK) where a.cmp_id = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ivh_billto)), 
       ivh_mbstatus as 'Master Bill Status List',
       (select cty_name from city WITH (NOLOCK) where cty_code = ivh_origincity) as 'Origin City',
       (select cty_name from city WITH (NOLOCK) where cty_code = ivh_destcity) as 'Dest City',
       ivh_originstate as 'Origin State', 
       ivh_deststate as 'Dest State', 
       ivh_supplier as 'Supplier', 
       --**Ship Date**
       ivh_shipdate as 'Ship Date',
       --Day
       (Cast(Floor(Cast([ivh_shipdate] as float))as smalldatetime)) as [Ship Date Only], 
       Cast(DatePart(yyyy,[ivh_shipdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_shipdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_shipdate]) as varchar(2)) as [Ship Day],
       --Month
       Cast(DatePart(mm,[ivh_shipdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_shipdate]) as varchar(4)) as [Ship Month],
       DatePart(mm,[ivh_shipdate]) as [Ship Month Only],
       --Year
       DatePart(yyyy,[ivh_shipdate]) as [Ship Year], 
       --**Delivery Date**
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
       OrderHasCreditMemoYN = IsNull((select Top 1 'Y' from invoiceheader b WITH (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber and b.ivh_creditmemo = 'Y'),'N'),
       'RevType4 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ivh_revtype4 and labeldefinition = 'RevType4'),''),                 
       Case 
		When invoiceheader.ivh_creditmemo = 'Y' Then
		        (invoiceheader.ivh_totalmiles * -1)
		Else
			invoiceheader.ivh_totalmiles
	End As 'Total Billed Miles',
	
(	SELECT 	IsNull(convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(ivd_charge,b.ivh_currency,'Revenue',ivd_number,ivd_currencydate,b.ivh_shipdate,b.ivh_deliverydate,b.ivh_billdate,b.ivh_revenue_date,b.ivh_xferdate,default,b.ivh_printdate,default,default,default),0.00))),0.00)
			FROM 	invoicedetail WITH (NOLOCK)
					join chargetype WITH (NOLOCK) on invoicedetail.cht_itemcode=chargetype.cht_itemcode
					join invoiceheader b WITH (NOLOCK) on b.ivh_hdrnumber = InvoiceHeader.ivh_hdrnumber
			WHERE 
				invoiceheader.ivh_invoicestatus <> 'CAN' 
				AND
				Invoiceheader.ivh_hdrnumber= invoicedetail.ivh_hdrnumber
				AND 
				(Upper(chargetype.cht_itemcode) like 'FUEL%'
					OR
					CharIndex('FUEL', cht_description)>0
				)
				and ivd_charge is Not Null
			) As 'Fuel Surcharge',

	Case 
		When invoiceheader.ivh_creditmemo = 'Y' Then
			(invoiceheader.ivh_totalweight * -1)
		Else
			invoiceheader.ivh_totalweight
	End As 'Total Weight',
	Case 
		When invoiceheader.ivh_creditmemo = 'Y' Then
			(invoiceheader.ivh_totalpieces * -1)
		Else
			invoiceheader.ivh_totalpieces
        End As 'Total Pieces',	
       ivh_currency as 'Currency', 
       --**Currency Date**
       ivh_currencydate as 'Currency Date', 
       --Day
       (Cast(Floor(Cast([ivh_currencydate] as float))as smalldatetime)) as [Currency Date Only], 
       Cast(DatePart(yyyy,[ivh_currencydate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_currencydate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_currencydate]) as varchar(2)) as [Currency Day],
       --Month
       Cast(DatePart(mm,[ivh_currencydate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_currencydate]) as varchar(4)) as [Currency Month],
       DatePart(mm,[ivh_currencydate]) as [Currency Month Only],
       --Year
       DatePart(yyyy,[ivh_currencydate]) as [Currency Year], 
       Case 
		When invoiceheader.ivh_creditmemo = 'Y' Then
 			(invoiceheader.ivh_totalvolume * -1)
		Else
			(invoiceheader.ivh_totalvolume)
       End As 'Total Volume',	
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
       ivh_hdrnumber as 'Invoice Header Number', 
       ord_hdrnumber as 'Order Header Number', 
       ivh_remark as 'Remark',
       ivh_driver as 'Driver ID', 
       'Driver Other ID' = IsNull((select mpp_otherid from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType1' = IsNull((select mpp_type1 from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType1 Name' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1' and manpowerprofile.mpp_id = ivh_driver),''),
       'DrvType2' = IsNull((select mpp_type2 from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType2 Name' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2' and manpowerprofile.mpp_id = ivh_driver),''),
       'DrvType3' = IsNull((select mpp_type3 from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType3 Name' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3' and manpowerprofile.mpp_id = ivh_driver),''),
       'DrvType4' = IsNull((select mpp_type4 from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType4 Name' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4' and manpowerprofile.mpp_id = ivh_driver),''),
       ivh_driver2 as 'Driver2 ID', 
       ivh_tractor as 'Tractor', 
       'TrcType1' = IsNull((select trc_type1 from tractorprofile WITH (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType1 Name' = IsNull((select name from labelfile WITH (NOLOCK) ,tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type1 and labeldefinition = 'TrcType1' and trc_number = ivh_tractor),''),
       'TrcType2' = IsNull((select trc_type2 from tractorprofile WITH (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType2 Name' = IsNull((select name from labelfile WITH (NOLOCK),tractorprofile WITH (NOLOCK)where labelfile.abbr = trc_type2 and labeldefinition = 'TrcType2' and trc_number = ivh_tractor),''),
       'TrcType3' = IsNull((select trc_type3 from tractorprofile WITH (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType3 Name' = IsNull((select name from labelfile WITH (NOLOCK),tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type3 and labeldefinition = 'TrcType3' and trc_number = ivh_tractor),''),
       'TrcType4'= IsNull((select trc_type4 from tractorprofile WITH (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType4 Name' = IsNull((select name from labelfile WITH (NOLOCK),tractorprofile WITH (NOLOCK) where labelfile.abbr = trc_type4 and labeldefinition = 'TrcType4' and trc_number = ivh_tractor),''),       
       ivh_trailer as 'Trailer', 
       'TrlType1' = IsNull((select min(trl_type1) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),''),
       'TrlType1 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1' and trl_id = ivh_trailer),''),
       'TrlType2' = IsNull((select min(trl_type2) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),''),
       'TrlType2 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type2 and labeldefinition = 'TrlType2' and trl_id = ivh_trailer),''),
       'TrlType3' = IsNull((select min(trl_type3) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),''),
       'TrlType3 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type3 and labeldefinition = 'TrlType3' and trl_id = ivh_trailer),''),
       'TrlType4'= IsNull((select min(trl_type4) from trailerprofile WITH (NOLOCK) where trl_id = ivh_trailer),''),
       'TrlType4 Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_type4 and labeldefinition = 'TrlType4' and trl_id = ivh_trailer),''),       
       ivh_user_id1 as 'User ID 1', 
       ivh_user_id2 as 'User ID 2', 
       ivh_ref_number as 'Reference Number',
       mov_number as 'Move Number', 
       ivh_edi_flag as 'EDI Flag',
       Case 
		When invoiceheader.ivh_creditmemo = 'Y' Then
 			(invoiceheader.ivh_freight_miles * -1)
		Else
			(invoiceheader.ivh_freight_miles)
       End as 'Freight Miles',
       ivh_low_temp as 'Low Temp',
       ivh_high_temp as 'High Temp',
       ivh_xferdate as 'Transfer Date',
       --Day
       (Cast(Floor(Cast([ivh_xferdate] as float))as smalldatetime)) as [Transfer Date Only], 
       Cast(DatePart(yyyy,[ivh_xferdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_xferdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_xferdate]) as varchar(2)) as [Transfer Day],
       --Month
       Cast(DatePart(mm,[ivh_xferdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_xferdate]) as varchar(4)) as [Transfer Month],
       DatePart(mm,[ivh_xferdate]) as [Transfer Month Only],
       --Year
       DatePart(yyyy,[ivh_xferdate]) as [Transfer Year],  
       tar_tarriffnumber as 'Tarriff Number',
       tar_number as 'Tar Number', 
       ivh_bookyear as 'Book Year', 
       ivh_bookmonth as 'Book Month',
       tar_tariffitem as 'Tariff Item',
       ivh_maxlength as 'Max Length',
       ivh_maxwidth as 'Max Width',
       ivh_maxheight as 'Max Height',
       ivh_mbstatus as 'Master Bill Status', 
       ivh_mbnumber as 'Master Bill Number', 
       ord_number as 'Order Number',
       ivh_quantity as 'Quantity', 
       ivh_rate as 'Rate', 
       convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Line Haul Revenue',
       convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0) - IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ivh_charge,0),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Accessorial Revenue',
       cht_itemcode as 'Charge Item Code',
       ivh_splitbill_flag as 'Splitill Flag',
       ivh_company as 'Company',
       ivh_carrier as 'Carrier',
       ivh_archarge as 'AR Charge',
       ivh_arcurrency as 'AR Currency',
       ivh_loadtime as 'Load Time',
       ivh_unloadtime as 'Unload Time',
       ivh_drivetime as 'Drive Time',
       ivh_rateby as 'Rate By',
       ivh_revenue_date as 'Revenue Date',
       (Cast(Floor(Cast(ivh_revenue_date as float))as smalldatetime)) as 'Revenue Date Only',
       ivh_batch_id as 'Batch ID',
       ivh_stopoffs as 'Stop Offs',
       Ivh_quantity_type as 'Quantity Type',
       cht_itemcode as 'Charge Type',
       ivh_originzipcode as 'Origin Zip Code',
       ivh_destzipcode as 'Dest Zip Code',
       ivh_ratingquantity as 'Rating Quantity',
       ivh_ratingunit as 'Rating Unit',
       ivh_unit as 'Unit',
       ivh_paperworkstatus as 'PaperWork Status',
       ivh_definition as 'Definition',
       ivh_hideshipperaddr as 'Hide Shipper Addr',		
       ivh_hideconsignaddr as 'Hide Consignee Addr',
       ivh_showshipper as 'Show Shipper',
       ivh_showcons as 'Show Cons',
       ivh_mileage_adjustment as 'Mileage Adjustment',
       ivh_allinclusivecharge as 'All Inclusive Charge',
       ivh_order_cmd_code as 'Order CMD Code',	
       [Commodity Name] = (select cmd_name from commodity WITH (NOLOCK) where cmd_code = ivh_order_cmd_code),
       ivh_applyto_definition as 'ApplyTo Definition',
       ivh_reftype as 'Ref Type',
       ivh_paperwork_override as 'PaperWork Override',
       ivh_attention as 'Attention',
       ivh_rate_type as 'Rate Type',
       ivh_cmrbill_link as 'CMRBill Link',	
       ivh_mbperiod as 'Master Bill Period',
       ivh_mbperiodstart as 'Master Bill Start',
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
       (select ord_bookdate from orderheader where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0) as 'Book Date',
       (select Min(cty_region1) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region1],
       (select Min(cty_region2) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region2],
       (select Min(cty_region3) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region3],
       (select Min(cty_region4) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region4],
       (select Min(cty_region1) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region1],
       (select Min(cty_region2) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region2],
       (select Min(cty_region3) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region3],
       (select Min(cty_region4) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region4],	

       (select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey = invoiceheader.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as RefType1,
       (select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey  = invoiceheader.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as RefNumber1,
       (select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey  = invoiceheader.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as RefType2,
       (select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey  = invoiceheader.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as RefNumber2,
       (select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey  = invoiceheader.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as RefType3,
       (select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey  = invoiceheader.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as RefNumber3,
       (select min(ref_type) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey  = invoiceheader.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as RefType4,
       (select min(ref_number) from referencenumber WITH (NOLOCK) where referencenumber.ref_tablekey  = invoiceheader.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as RefNumber4,

	
       (select Top 1 ivd_refnum from invoicedetail WITH (NOLOCK) where ivd_refnum Is Not Null and invoicedetail.ivh_hdrnumber = InvoiceHeader.ivh_hdrnumber) as IVDRefNum1,
       (select Top 1 ivd_reftype from invoicedetail WITH (NOLOCK) where ivd_refnum Is Not Null and invoicedetail.ivh_hdrnumber = InvoiceHeader.ivh_hdrnumber) as IVDRefType1,

	(select sum(ivd_charge) from  invoicedetail WITH (NOLOCK)
						join chargetype WITH (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
                        Where invoicedetail.cht_basisunit = 'STOP'
						  And cht_basis = 'ACC'
						  And invoicedetail.ivh_hdrnumber = InvoiceHeader.ivh_hdrnumber
						) as StopOffCharge,

       IsNull(dbo.TMWSSRS_fnc_checkforvalidcurrencyconversion(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),'No Conversion Status Returned') as 'Revenue Currency Conversion Status',
 
	(SELECT cmp_othertype1 from company WITH (NOLOCK) where [ivh_shipper] = cmp_id) 
	 As [Shipper OtherType1],   

        (SELECT cmp_othertype2 from company WITH (NOLOCK) where [ivh_shipper] = cmp_id) 
	 As [Shipper OtherType2],

	(SELECT cmp_othertype1 from company WITH (NOLOCK) where [ivh_billto] = cmp_id) 
	 As [BillTo OtherType1],   

        (SELECT cmp_othertype2 from company WITH (NOLOCK) where [ivh_billto] = cmp_id) 
	 As [BillTo OtherType2],

       'Other Type1-Ordered By' = (select Company.cmp_othertype1 from Company  WITH (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
       'Other Type2-Ordered By' = (select Company.cmp_othertype2 from Company  WITH (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
	cast(last_updateby as varchar(255)) as [Last Updated By],
	'RTP Updated By' = (select Top 1 updated_by from expedite_audit WITH (NOLOCK) where join_to_table_name = 'invoiceheader' and update_note like '%-> RTP%' and key_value = invoiceheader.ivh_hdrnumber),
		

	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader b WITH (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) Then
		IsNull((select sum(IsNull(pyd_amount,0)) from paydetail WITH (NOLOCK) where pyd_minus > 0 and paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber),0)
	Else
		0
	End as Pay,
	' ' as AllChargeTypes
	


FROM [invoiceheader] WITH (NOLOCK)


GO
GRANT DELETE ON  [dbo].[vSSRSRB_Invoices] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_Invoices] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_Invoices] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_Invoices] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_Invoices] TO [public]
GO
