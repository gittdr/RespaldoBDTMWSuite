SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO








CREATE                                                 View [dbo].[vTTSTMW_ChargeDetails]
As

SELECT 
       'NI' as 'Invoice Number',
       ord_billto as 'Bill To ID',
       'Bill To' = (select cmp_name from company (NOLOCK) where cmp_id = ord_billto),
       ord_terms as 'Terms',
       ord_shipper as 'Shipper ID', 
       ord_consignee as 'Consignee ID', 
       ord_originpoint as 'Origin Point ID',
       ord_destpoint as 'Destination Point ID',  
       (select cty_name from city (NOLOCK) where cty_code = ord_origincity) as 'Origin City',
       (select cty_name from city (NOLOCK) where cty_code = ord_destcity) as 'Dest City',
       ord_originstate as 'Origin State', 
       ord_deststate as 'Dest State', 
       ord_originregion1 as 'Origin Region 1', 
       ord_destregion1 as 'Dest Region 1', 
       ord_supplier as 'Supplier', 
       ord_startdate as 'Ship Date', 
       --Day
       (Cast(Floor(Cast([ord_startdate] as float))as smalldatetime)) as [Ship Date Only], 
       Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_startdate]) as varchar(2)) as [Ship Day],
       --Month
       Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) as [Ship Month],
       DatePart(mm,[ord_startdate]) as [Ship Month Only],
       --Year
       DatePart(yyyy,[ord_startdate]) as [Ship Year],
       ord_completiondate as 'Delivery Date',
       --Day
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
       'RevType4 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ord_revtype4 and labeldefinition = 'RevType4'),'') ,                 
       ivd_number as 'Invoice Detail Number',
       stp_number as 'Stop Number', 
       ivd_description as 'Description', 
       invoicedetail.cht_itemcode as 'Charge Type',
       'Charge Type Description' = (select cht_description from chargetype (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode), 
       ivd_quantity as 'Quantity', 
       ivd_rate as 'Rate', 
       
       --<TTS!*!TMW><Begin><SQLVersion=7>
--       convert(money,IsNull(ivd_charge,0)) as 'Charge', 
       --<TTS!*!TMW><End><SQLVersion=7> 
       
       --<TTS!*!TMW><Begin><SQLVersion=2000+>
       convert(money,IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,Case When ivd_currencydate Is Not Null Then ivd_currencydate Else ord_currencydate End,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as Charge,
	--<TTS!*!TMW><End><SQLVersion=2000+>
 
       ivd_taxable1 as 'Tax Table1', 
       ivd_taxable2 as 'Tax Table2', 
       ivd_taxable3 as 'Tax Table3', 
       ivd_taxable4 as 'Tax Table4', 
       ivd_unit as 'Unit', 
       cur_code as 'Currency',
       ivd_currencydate as 'Currency Date', 
       ivd_glnum as 'Gl Number', 
       ivd_type as 'Type', 
       ivd_rateunit as 'Rate Unit', 
       ivd_itemquantity as 'Item Quantity', 
       ivd_subtotalptr as 'SubTotal Ptr', 
       ivd_allocatedrev as 'Allocated Revenue', 
       ivd_sequence as 'Sequence', 
       ord_invoicestatus as 'Invoice Status',
       ivd_refnum as 'Reference Number', 
       invoicedetail.cmd_code as 'Commodity Code', 
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
       0 as 'Tax Amount 1', 
       0 as 'Tax Amount 2', 
       0 as 'Tax Amount 3', 
       0 as 'Tax Amount 4',       
       ord_originregion2 as 'Origin Region 2', 
       ord_originregion3 as 'Origin Region 3', 
       ord_originregion4 as 'Origin Region 4', 
       ord_destregion2 as 'Dest Region 2',
       ord_destregion3 as 'Dest Region 3', 
       ord_destregion4 as 'Dest Region 4', 
       null as 'Transaction Type', 
       null as 'Credit Memo', 
       null as 'Apply To', 
       Null as 'Print Date', 
       --Day
       Null as [Print Date Only], 
       Null as [Print Day],
       --Month
       Null as [Print Month],
       Null as [Print Month Only],
       --Year
       Null as [Print Year],
       Null as [Bill Date], 
       --Day
       Null as [Bill Date Only], 
       Null as [Bill Day],
       --Month
       Null as [Bill Month],
       Null as [Bill Month Only],
       --Year
       Null as [Bill Year],
       Null as 'Last Print Date', 
       ord_remark as 'Remark',
       ord_driver1 as 'Driver1 ID', 
       'DrvType1' = IsNull((select mpp_type1 from manpowerprofile (NOLOCK) where mpp_id = ord_driver1),''),
       'DrvType1 Name' = IsNull((select name from labelfile (NOLOCK) ,manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1' and manpowerprofile.mpp_id = ord_driver1),''),
       'DrvType2' = IsNull((select mpp_type2 from manpowerprofile (NOLOCK) where mpp_id = ord_driver1),''),
       'DrvType2 Name' = IsNull((select name from labelfile (NOLOCK) ,manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2' and manpowerprofile.mpp_id = ord_driver1),''),
       'DrvType3' = IsNull((select mpp_type3 from manpowerprofile(NOLOCK) where mpp_id = ord_driver1),''),
       'DrvType3 Name' = IsNull((select name from labelfile (NOLOCK) ,manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3' and manpowerprofile.mpp_id = ord_driver1),''),
       'DrvType4' = IsNull((select mpp_type4 from manpowerprofile (NOLOCK) where mpp_id = ord_driver1),''),
       'DrvType4 Name' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4' and manpowerprofile.mpp_id = ord_driver1),''),
       ord_driver2 as 'Driver2 ID', 
       ord_tractor as 'Tractor', 
       'TrcType1' = IsNull((select trc_type1 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
       'TrcType1 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type1 and labeldefinition = 'TrcType1' and trc_number = ord_tractor),''),
       'TrcType2' = IsNull((select trc_type2 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
       'TrcType2 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type2 and labeldefinition = 'TrcType2' and trc_number = ord_tractor),''),
       'TrcType3' = IsNull((select trc_type3 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
       'TrcType3 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type3 and labeldefinition = 'TrcType3' and trc_number = ord_tractor),''),
       'TrcType4'= IsNull((select trc_type4 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
       'TrcType4 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type4 and labeldefinition = 'TrcType4' and trc_number = ord_tractor),''),       
       ord_trailer as 'Trailer', 
       'TrlType1' = IsNull((select min(trl_type1) from trailerprofile (NOLOCK) where trl_id  = ord_trailer),''),
       'TrlType1 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1' and trl_id = ord_trailer),''),
       'TrlType2' = IsNull((select min(trl_type2) from trailerprofile (NOLOCK) where trl_id = ord_trailer),''),
       'TrlType2 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type2 and labeldefinition = 'TrlType2' and trl_id = ord_trailer),''),
       'TrlType3' = IsNull((select min(trl_type3) from trailerprofile (NOLOCK) where trl_id = ord_trailer),''),
       'TrlType3 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type3 and labeldefinition = 'TrlType3' and trl_id = ord_trailer),''),
       'TrlType4'= IsNull((select min(trl_type4) from trailerprofile (NOLOCK) where trl_id = ord_trailer),''),
       'TrlType4 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type4 and labeldefinition = 'TrlType4' and trl_id = ord_trailer),''),       
       '' as 'User UD 1',
       '' as 'User UD 2',
       mov_number as 'Move Number',
       '' as 'EDI Flag',
       0 as 'Low Temp',
       0  as 'High Temp',
       0 as 'Transfer Date',
       --Day
       0 as [Transfer Date Only], 
       '' as [Transfer Day],
       --Month
       '' as [Transfer Month],
       '' as [Transfer Month Only],
       --Year
       0 as [Transfer Year], 
       ord_company as 'Ordered By ID', 
       invoicedetail.tar_number as 'Tarrif Number',
       datepart(yyyy,ord_bookdate) as 'Book Year', 
       datepart(mm,ord_bookdate) as 'Book Month',
       invoicedetail.tar_tariffitem as 'Tariff Item',
       0 as 'Max Length',
       0 as 'Max Width',
       0 as 'Max Height',
       '' as 'Master Bill Status', 
       0 as 'Master Bill Number', 
       ord_number as 'Order Number',
       '' as 'Splitill Flag',
       ord_company as 'Company',
       '' as 'Carrier',
       ord_loadtime as 'Load Time',
       ord_unloadtime as 'Unload Time',
       ord_drivetime as 'Drive Time',
       ord_rateby as 'Rate By',
       Null as 'Revenue Date',
       '' as 'Batch ID',
       Null as 'Stop Offs',
       ord_quantity_type as 'Quantity Type',
       (select cty_zip from city (NOLOCK) where cty_code = ord_origincity) as 'Origin Zip Code',
       (select cty_zip from city (NOLOCK) where cty_code = ord_destcity) as 'Dest Zip Code', 
       '' as 'PaperWork Status',
       '' as 'Definition',	
       ord_hideshipperaddr as 'Hide Shipper Addr',		
       ord_hideconsignaddr as 'Hide Consignee Addr',
       ord_showshipper as 'Show Shipper',
       ord_showcons as 'Show Cons',
       0 as 'Mileage Adjustment',
       ord_allinclusivecharge as 'All Inclusive Charge',
       orderheader.cmd_code as 'Order CMD Code',		
       '' as 'ApplyTo Definition',
       ord_reftype as 'Ref Type',
       '' as 'PaperWork Override',
       '' as 'Attention',
       '' as 'CMRBill Link',	
       '' as 'Master Bill Period',
       '' as 'Master Bill Start',
       invoicedetail.ord_hdrnumber as 'Order Header Number',
       'Trailer Company' = (select min(trl_company) from trailerprofile (NOLOCK) where trl_id = ord_trailer),    
       'Trailer Company Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_company and labeldefinition = 'Company' and trl_id = ord_trailer),''),
       'Trailer Fleet' = (select min(trl_fleet) from trailerprofile (NOLOCK) where trl_id = ord_trailer),    
       'Trailer Fleet Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_fleet and labeldefinition = 'Fleet' and trl_id = ord_trailer),''),
       'Trailer Terminal' = (select min(trl_terminal) from trailerprofile (NOLOCK) where trl_id = ord_trailer),    
       'Trailer Terminal Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_terminal and labeldefinition = 'Terminal' and trl_id = ord_trailer),''),
       'Trailer Division' = (select min(trl_division) from trailerprofile (NOLOCK) where trl_id = ord_trailer),
       'Trailer Division Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_division and labeldefinition = 'Division' and trl_id = ord_trailer),''),
       'Sub Company ID' = ord_subcompany,
       'Sub Company' = (select Company.cmp_name from Company (NOLOCK) where orderheader.ord_subcompany = Company.cmp_id),   
	ord_currency as 'Invoice Currency',
	--<TTS!*!TMW><Begin><SQLVersion=7>
--        '' as 'Revenue Currency Conversion Status',
        --<TTS!*!TMW><End><SQLVersion=7>
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	IsNull(dbo.fnc_checkforvalidcurrencyconversion(ivd_charge,ord_currency,'Revenue',ivd_number,Case When ivd_currencydate Is Not Null Then ivd_currencydate Else ord_currencydate End,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),'No Conversion Status Returned') as 'Revenue Currency Conversion Status',
	--<TTS!*!TMW><End><SQLVersion=2000+>
	'NonAllocatedMoveMiles' = (select sum(stp_lgh_mileage) from stops (NOLOCK),orderheader (NOLOCK) where orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber and stops.mov_number = orderheader.mov_number),
        
        ord_booked_revtype1 as 'Booked RevType1',
	 
        --<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Calculated Weight],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_calculated_weight as [Calculated Weight],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Loading Meters],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_loadingmeters as [Loading Meters],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Loading Meters Unit],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_loadingmeters_unit as [Loading Meters Unit],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Ordered Count],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_ordered_count as [Ordered Count],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as  [Ordered Loading Meters],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_ordered_loadingmeters as [Ordered Loading Meters],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Ordered Volume],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_ordered_volume as [Ordered Volume],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>

	'' as [Ordered Weight],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_ordered_weight as [Ordered Weight],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Pay LegHeaderNumber],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_paylgh_number as [Pay LegHeaderNumber],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Tarrif Type],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_tariff_type as [Tarrif Type],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Tax ID],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_taxid as [Tax ID],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [LH Stl],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--cht_lh_stl as [LH Stl],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [LH Min],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--cht_lh_min as [LH Min],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [LH Rev],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--cht_lh_rev as [LH Rev],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [LH Rpt],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--cht_lh_rpt as [LH Rpt],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [LH Prn],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--cht_lh_prn as [LH Prn],
	--<TTS!*!TMW><End><FeaturePack=Euro>  

	--<TTS!*!TMW><Begin><FeaturePack=Other> 
        '' as [Origin Country],
        --<TTS!*!TMW><End><FeaturePack=Other> 
        --(select cty_country from city (NOLOCK) where cty_code = ord_origincity) as 'Origin Country',
        --<TTS!*!TMW><End><FeaturePack=Euro> 

        --<TTS!*!TMW><Begin><FeaturePack=Other> 
        '' as [Destination Country],
        --<TTS!*!TMW><End><FeaturePack=Other> 
        --<TTS!*!TMW><Begin><FeaturePack=Euro> 
        --(select cty_country from city (NOLOCK) where cty_code = ord_destcity) as 'Destination Country',
        --<TTS!*!TMW><End><FeaturePack=Euro> 	


	(select cht_edicode from chargetype (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [EDI Code],
	(select cht_basis from chargetype (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [Basis],	
	(select cht_basisunit from chargetype (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [Basis Unit],	
	(select cht_basisper from chargetype (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [Basis Per],
	--(select Min(cty_region1) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region1],
        --(select Min(cty_region2) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region2],
        --(select Min(cty_region3) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region3],
        --(select Min(cty_region4) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region4],
        --(select Min(cty_region1) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region1],
        --(select Min(cty_region2) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region2],
        --(select Min(cty_region3) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region3],
        --(select Min(cty_region4) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region4],
	ord_status as [Order Status],
	--<TTS!*!TMW><Begin><FeaturePack=Other> 
        NULL as [Doc Number]
        --<TTS!*!TMW><End><FeaturePack=Other> 
        --<TTS!*!TMW><Begin><FeaturePack=Euro> 
        --NULL as [Doc Number]
        --<TTS!*!TMW><End><FeaturePack=Euro> 
	

FROM  invoicedetail (NOLOCK), orderheader (nolock)
Where OrderHeader.ord_hdrnumber = InvoiceDetail.ord_hdrnumber
      And
      ord_invoicestatus <> 'PPD'
      --not exists (select * from invoiceheader (NoLock) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)


Union

SELECT 
       'NI' as 'Invoice Number',
       ord_billto as 'Bill To ID',
       'Bill To' = (select cmp_name from company (NOLOCK) where cmp_id = ord_billto),
       ord_terms as 'Terms',
       ord_shipper as 'Shipper ID', 
       ord_consignee as 'Consignee ID', 
       ord_originpoint as 'Origin Point ID',
       ord_destpoint as 'Destination Point ID',  
       (select cty_name from city (NOLOCK) where cty_code = ord_origincity) as 'Origin City',
       (select cty_name from city (NOLOCK) where cty_code = ord_destcity) as 'Dest City',
       ord_originstate as 'Origin State', 
       ord_deststate as 'Dest State', 
       ord_originregion1 as 'Origin Region 1', 
       ord_destregion1 as 'Dest Region 1', 
       ord_supplier as 'Supplier', 
       ord_startdate as 'Ship Date', 
       --Day
       (Cast(Floor(Cast([ord_startdate] as float))as smalldatetime)) as [Ship Date Only], 
       Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_startdate]) as varchar(2)) as [Ship Day],
       --Month
       Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) as [Ship Month],
       DatePart(mm,[ord_startdate]) as [Ship Month Only],
       --Year
       DatePart(yyyy,[ord_startdate]) as [Ship Year],
       ord_completiondate as 'Delivery Date',
       --Day
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
       'RevType4 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ord_revtype4 and labeldefinition = 'RevType4'),'') ,                 
       0 as 'Invoice Detail Number',
       0 as 'Stop Number', 
       Null as 'Description', 
       'LH' as 'Charge Type',
       'Charge Type Description' = (select cht_description from chargetype (NOLOCK) where chargetype.cht_itemcode = 'LH'), 
       ord_quantity as 'Quantity', 
       ord_rate as 'Rate', 
       
       --<TTS!*!TMW><Begin><SQLVersion=7>
--       convert(money,IsNull(ord_charge,0)) as 'Charge', 
       --<TTS!*!TMW><End><SQLVersion=7> 
       
       --<TTS!*!TMW><Begin><SQLVersion=2000+>
       convert(money,IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as Charge,
       --<TTS!*!TMW><End><SQLVersion=2000+>

       Null as 'Tax Table1', 
       Null as 'Tax Table2', 
       Null as 'Tax Table3', 
       Null as 'Tax Table4', 
       ord_unit as 'Unit', 
       ord_currency as 'Currency',
       Null as 'Currency Date', 
       Null as 'Gl Number', 
       Null as 'Type', 
       ord_rateunit as 'Rate Unit', 
       0 as 'Item Quantity', 
       0 as 'SubTotal Ptr', 
       0 as 'Allocated Revenue', 
       0 as 'Sequence', 
       ord_invoicestatus as 'Invoice Status',
       ord_refnum as 'Reference Number', 
       cmd_code as 'Commodity Code', 
       '' as 'Company ID', 
       0 as 'Distance', 
       '' as 'Distance Unit', 
       ord_totalweight as 'Weight', 
       Null as 'Weight Unit', 
       Null as 'Count', 
       Null as 'Count Unit', 
       Null as 'Event Number', 
       ord_reftype as 'RefType', 
       Null as 'Volume', 
       Null as 'Volume Unit', 
       '' as 'Original Company ID',
       Null as 'Pay Revenue', 
       '' as 'Sign', 
       0 as 'Length', 
       0 as 'Tax Amount 1', 
       0 as 'Tax Amount 2', 
       0 as 'Tax Amount 3', 
       0 as 'Tax Amount 4',       
       ord_originregion2 as 'Origin Region 2', 
       ord_originregion3 as 'Origin Region 3', 
       ord_originregion4 as 'Origin Region 4', 
       ord_destregion2 as 'Dest Region 2',
       ord_destregion3 as 'Dest Region 3', 
       ord_destregion4 as 'Dest Region 4', 
       null as 'Transaction Type', 
       null as 'Credit Memo', 
       null as 'Apply To', 
       Null as 'Print Date', 
       --Day
       Null as [Print Date Only], 
       Null as [Print Day],
       --Month
       Null as [Print Month],
       Null as [Print Month Only],
       --Year
       Null as [Print Year],
       Null as [Bill Date], 
       --Day
       Null as [Bill Date Only], 
       Null as [Bill Day],
       --Month
       Null as [Bill Month],
       Null as [Bill Month Only],
       --Year
       Null as [Bill Year],
       Null as 'Last Print Date', 
       ord_remark as 'Remark',
       ord_driver1 as 'Driver1 ID', 
       'DrvType1' = IsNull((select mpp_type1 from manpowerprofile (NOLOCK) where mpp_id = ord_driver1),''),
       'DrvType1 Name' = IsNull((select name from labelfile (NOLOCK) ,manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1' and manpowerprofile.mpp_id = ord_driver1),''),
       'DrvType2' = IsNull((select mpp_type2 from manpowerprofile (NOLOCK) where mpp_id = ord_driver1),''),
       'DrvType2 Name' = IsNull((select name from labelfile (NOLOCK) ,manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2' and manpowerprofile.mpp_id = ord_driver1),''),
       'DrvType3' = IsNull((select mpp_type3 from manpowerprofile(NOLOCK) where mpp_id = ord_driver1),''),
       'DrvType3 Name' = IsNull((select name from labelfile (NOLOCK) ,manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3' and manpowerprofile.mpp_id = ord_driver1),''),
       'DrvType4' = IsNull((select mpp_type4 from manpowerprofile (NOLOCK) where mpp_id = ord_driver1),''),
       'DrvType4 Name' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4' and manpowerprofile.mpp_id = ord_driver1),''),
       ord_driver2 as 'Driver2 ID', 
       ord_tractor as 'Tractor', 
       'TrcType1' = IsNull((select trc_type1 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
       'TrcType1 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type1 and labeldefinition = 'TrcType1' and trc_number = ord_tractor),''),
       'TrcType2' = IsNull((select trc_type2 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
       'TrcType2 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type2 and labeldefinition = 'TrcType2' and trc_number = ord_tractor),''),
       'TrcType3' = IsNull((select trc_type3 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
       'TrcType3 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type3 and labeldefinition = 'TrcType3' and trc_number = ord_tractor),''),
       'TrcType4'= IsNull((select trc_type4 from tractorprofile (NOLOCK) where trc_number = ord_tractor),''),
       'TrcType4 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type4 and labeldefinition = 'TrcType4' and trc_number = ord_tractor),''),       
       ord_trailer as 'Trailer', 
       'TrlType1' = IsNull((select min(trl_type1) from trailerprofile (NOLOCK) where trl_id  = ord_trailer),''),
       'TrlType1 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1' and trl_id = ord_trailer),''),
       'TrlType2' = IsNull((select min(trl_type2) from trailerprofile (NOLOCK) where trl_id = ord_trailer),''),
       'TrlType2 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type2 and labeldefinition = 'TrlType2' and trl_id = ord_trailer),''),
       'TrlType3' = IsNull((select min(trl_type3) from trailerprofile (NOLOCK) where trl_id = ord_trailer),''),
       'TrlType3 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type3 and labeldefinition = 'TrlType3' and trl_id = ord_trailer),''),
       'TrlType4'= IsNull((select min(trl_type4) from trailerprofile (NOLOCK) where trl_id = ord_trailer),''),
       'TrlType4 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type4 and labeldefinition = 'TrlType4' and trl_id = ord_trailer),''),       
       '' as 'User UD 1',
       '' as 'User UD 2',
       mov_number as 'Move Number',
       '' as 'EDI Flag',
       0 as 'Low Temp',
       0  as 'High Temp',
       0 as 'Transfer Date',
       --Day
       0 as [Transfer Date Only], 
       '' as [Transfer Day],
       --Month
       '' as [Transfer Month],
       '' as [Transfer Month Only],
       --Year
       0 as [Transfer Year], 
       ord_company as 'Ordered By ID', 
       0 as 'Tarrif Number',
       datepart(yyyy,ord_bookdate) as 'Book Year', 
       datepart(mm,ord_bookdate) as 'Book Month',
       '' as 'Tariff Item',
       0 as 'Max Length',
       0 as 'Max Width',
       0 as 'Max Height',
       '' as 'Master Bill Status', 
       0 as 'Master Bill Number', 
       ord_number as 'Order Number',
       '' as 'Splitill Flag',
       ord_company as 'Company',
       '' as 'Carrier',
       ord_loadtime as 'Load Time',
       ord_unloadtime as 'Unload Time',
       ord_drivetime as 'Drive Time',
       ord_rateby as 'Rate By',
       Null as 'Revenue Date',
       '' as 'Batch ID',
       Null as 'Stop Offs',
       ord_quantity_type as 'Quantity Type',
       (select cty_zip from city (NOLOCK) where cty_code = ord_origincity) as 'Origin Zip Code',
       (select cty_zip from city (NOLOCK) where cty_code = ord_destcity) as 'Dest Zip Code', 
       '' as 'PaperWork Status',
       '' as 'Definition',	
       ord_hideshipperaddr as 'Hide Shipper Addr',		
       ord_hideconsignaddr as 'Hide Consignee Addr',
       ord_showshipper as 'Show Shipper',
       ord_showcons as 'Show Cons',
       0 as 'Mileage Adjustment',
       ord_allinclusivecharge as 'All Inclusive Charge',
       orderheader.cmd_code as 'Order CMD Code',		
       '' as 'ApplyTo Definition',
       ord_reftype as 'Ref Type',
    '' as 'PaperWork Override',
       '' as 'Attention',
       '' as 'CMRBill Link',	
       '' as 'Master Bill Period',
       '' as 'Master Bill Start',
       ord_hdrnumber as 'Order Header Number',
       'Trailer Company' = (select min(trl_company) from trailerprofile (NOLOCK) where trl_id = ord_trailer),    
       'Trailer Company Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_company and labeldefinition = 'Company' and trl_id = ord_trailer),''),
       'Trailer Fleet' = (select min(trl_fleet) from trailerprofile (NOLOCK) where trl_id = ord_trailer),    
       'Trailer Fleet Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_fleet and labeldefinition = 'Fleet' and trl_id = ord_trailer),''),
       'Trailer Terminal' = (select min(trl_terminal) from trailerprofile (NOLOCK) where trl_id = ord_trailer),    
       'Trailer Terminal Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_terminal and labeldefinition = 'Terminal' and trl_id = ord_trailer),''),
       'Trailer Division' = (select min(trl_division) from trailerprofile (NOLOCK) where trl_id = ord_trailer),
       'Trailer Division Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_division and labeldefinition = 'Division' and trl_id = ord_trailer),''),
       'Sub Company ID' = ord_subcompany,
       'Sub Company' = (select Company.cmp_name from Company (NOLOCK) where orderheader.ord_subcompany = Company.cmp_id),   
	ord_currency as 'Invoice Currency',
	--<TTS!*!TMW><Begin><SQLVersion=7>
--        '' as 'Revenue Currency Conversion Status',
        --<TTS!*!TMW><End><SQLVersion=7>
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	IsNull(dbo.fnc_checkforvalidcurrencyconversion(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),'No Conversion Status Returned') as 'Revenue Currency Conversion Status',
	--<TTS!*!TMW><End><SQLVersion=2000+>	
	'NonAllocatedMoveMiles' = (select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.mov_number = orderheader.mov_number),
        
        ord_booked_revtype1 as 'Booked RevType1',

	Null as [Calculated Weight],
	Null as [Loading Meters],
	Null as [Loading Meters Unit],
	Null as [Ordered Count],
	Null as  [Ordered Loading Meters],
	Null as [Ordered Volume],
        Null as [Ordered Weight],
	Null as [Pay LegHeaderNumber],
	Null as [Tarrif Type],
        Null as [Tax ID],
	Null as [LH Stl],
	Null as [LH Min],
	Null as [LH Rev],
	Null as [LH Rpt],
	Null as [LH Prn],
	
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


	'' as [EDI Code],
	'' as [Basis],	
	'' as [Basis Unit],	
	'' as [Basis Per],
	--(select Min(cty_region1) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region1],
        --(select Min(cty_region2) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region2],
        --(select Min(cty_region3) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region3],
        --(select Min(cty_region4) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region4],
        --(select Min(cty_region1) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region1],
        --(select Min(cty_region2) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region2],
        --(select Min(cty_region3) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region3],

        --(select Min(cty_region4) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region4],
	ord_status as [Order Status],
	--<TTS!*!TMW><Begin><FeaturePack=Other> 
        NULL as [Doc Number]
        --<TTS!*!TMW><End><FeaturePack=Other> 
        --<TTS!*!TMW><Begin><FeaturePack=Euro> 
        --NULL as [Doc Number]
        --<TTS!*!TMW><End><FeaturePack=Euro> 
	
	

FROM  orderheader (nolock) 
Where ord_invoicestatus <> 'PPD'
      --not exists (select * from invoiceheader (NoLock) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)

Union

SELECT ivh_invoicenumber as 'Invoice Number', 
       ivh_billto as 'Bill To ID',
       'Bill To' = (select cmp_name from company (NOLOCK) where cmp_id = ivh_billto),
       ivh_terms as 'Terms',
       ivh_shipper as 'Shipper ID', 
       ivh_consignee as 'Consignee ID', 
       ivh_originpoint as 'Origin Point ID',
       ivh_destpoint as 'Destination Point ID',  
       (select cty_name from city (NOLOCK) where cty_code = ivh_origincity) as 'Origin City',
       (select cty_name from city (NOLOCK) where cty_code = ivh_destcity) as 'Dest City',
       ivh_originstate as 'Origin State', 
       ivh_deststate as 'Dest State', 
       ivh_originregion1 as 'Origin Region 1', 
       ivh_destregion1 as 'Dest Region 1', 
       ivh_supplier as 'Supplier', 
       ivh_shipdate as 'Ship Date', 
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
       'RevType1 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ivh_revtype1 and labeldefinition = 'RevType1'),''),
       ivh_revtype2 as 'RevType2', 
       'RevType2 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ivh_revtype2 and labeldefinition = 'RevType2'),''),
       ivh_revtype3 as 'RevType3', 
       'RevType3 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ivh_revtype3 and labeldefinition = 'RevType3'),''),
       ivh_revtype4 as 'RevType4', 
       'RevType4 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ivh_revtype4 and labeldefinition = 'RevType4'),'') ,                 
       ivd_number as 'Invoice Detail Number',
       stp_number as 'Stop Number', 
       ivd_description as 'Description', 
       invoicedetail.cht_itemcode as 'Charge Type',
       'Charge Type Description' = (select cht_description from chargetype (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode), 
       ivd_quantity as 'Quantity', 
       ivd_rate as 'Rate', 
       
       --<TTS!*!TMW><Begin><SQLVersion=7>
--       convert(money,IsNull(ivd_charge,0)) as 'Charge', 
       --<TTS!*!TMW><End><SQLVersion=7> 
       
       --<TTS!*!TMW><Begin><SQLVersion=2000+>
       convert(money,IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',ivd_number,Case When ivd_currencydate Is Not Null Then ivd_currencydate Else ivh_currencydate End,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as Charge,
       --<TTS!*!TMW><End><SQLVersion=2000+>

       ivd_taxable1 as 'Tax Table1', 
       ivd_taxable2 as 'Tax Table2', 
       ivd_taxable3 as 'Tax Table3', 
       ivd_taxable4 as 'Tax Table4', 
       ivd_unit as 'Unit', 
       cur_code as 'Currency',
       ivd_currencydate as 'Currency Date',  
       ivd_glnum as 'Gl Number', 
       ivd_type as 'Type', 
       ivd_rateunit as 'Rate Unit', 
       ivd_itemquantity as 'Item Quantity', 
       ivd_subtotalptr as 'SubTotal Ptr', 
       ivd_allocatedrev as 'Allocated Revenue', 
       ivd_sequence as 'Sequence', 
       ivh_invoicestatus as 'Invoice Status',
       ivd_refnum as 'Reference Number', 
       cmd_code as 'Commodity Code', 
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
       ivh_originregion2 as 'Origin Region 2', 
       ivh_originregion3 as 'Origin Region 3', 
       ivh_originregion4 as 'Origin Region 4', 
       ivh_destregion2 as 'Dest Region 2',
       ivh_destregion3 as 'Dest Region 3', 
       ivh_destregion4 as 'Dest Region 4', 
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
       
       ivh_remark as 'Remark',
       ivh_driver as 'Driver1 ID', 
       'DrvType1' = IsNull((select mpp_type1 from manpowerprofile (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType1 Name' = IsNull((select name from labelfile (NOLOCK) ,manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1' and manpowerprofile.mpp_id = ivh_driver),''),
       'DrvType2' = IsNull((select mpp_type2 from manpowerprofile (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType2 Name' = IsNull((select name from labelfile (NOLOCK) ,manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2' and manpowerprofile.mpp_id = ivh_driver),''),
       'DrvType3' = IsNull((select mpp_type3 from manpowerprofile(NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType3 Name' = IsNull((select name from labelfile (NOLOCK) ,manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3' and manpowerprofile.mpp_id = ivh_driver),''),


       'DrvType4' = IsNull((select mpp_type4 from manpowerprofile (NOLOCK) where mpp_id = ivh_driver),''),
       'DrvType4 Name' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4' and manpowerprofile.mpp_id = ivh_driver),''),
       ivh_driver2 as 'Driver2 ID', 
       ivh_tractor as 'Tractor', 
       'TrcType1' = IsNull((select trc_type1 from tractorprofile (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType1 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type1 and labeldefinition = 'TrcType1' and trc_number = ivh_tractor),''),
       'TrcType2' = IsNull((select trc_type2 from tractorprofile (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType2 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type2 and labeldefinition = 'TrcType2' and trc_number = ivh_tractor),''),
       'TrcType3' = IsNull((select trc_type3 from tractorprofile (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType3 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type3 and labeldefinition = 'TrcType3' and trc_number = ivh_tractor),''),
       'TrcType4'= IsNull((select trc_type4 from tractorprofile (NOLOCK) where trc_number = ivh_tractor),''),
       'TrcType4 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type4 and labeldefinition = 'TrcType4' and trc_number = ivh_tractor),''),       
       ivh_trailer as 'Trailer', 
       'TrlType1' = IsNull((select min(trl_type1) from trailerprofile (NOLOCK) where trl_id  = ivh_trailer),''),
       'TrlType1 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1' and trl_id = ivh_trailer),''),
       'TrlType2' = IsNull((select min(trl_type2) from trailerprofile (NOLOCK) where trl_id = ivh_trailer),''),
       'TrlType2 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type2 and labeldefinition = 'TrlType2' and trl_id = ivh_trailer),''),
       'TrlType3' = IsNull((select min(trl_type3) from trailerprofile (NOLOCK) where trl_id = ivh_trailer),''),
       'TrlType3 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type3 and labeldefinition = 'TrlType3' and trl_id = ivh_trailer),''),
       'TrlType4'= IsNull((select min(trl_type4) from trailerprofile (NOLOCK) where trl_id = ivh_trailer),''),
       'TrlType4 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type4 and labeldefinition = 'TrlType4' and trl_id = ivh_trailer),''),       
       ivh_user_id1 as 'User ID 1', 
       ivh_user_id2 as 'User ID 2', 
       mov_number as 'Move Number', 
       ivh_edi_flag as 'EDI Flag',
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
       --Day
       --(Cast(Floor(Cast([ivh_revenue_date] as float))as smalldatetime)) as [Transfer Date Only], 
       --Cast(DatePart(yyyy,[ivh_revenue_date]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_xferdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_xferdate]) as varchar(2)) as [Transfer Day],
       --Month
       --Cast(DatePart(mm,[ivh_revenue_date]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_xferdate]) as varchar(4)) as [Transfer Month],
       --DatePart(mm,[ivh_revenue_date]) as [Revenue Month Only],
       --Year
       --DatePart(yyyy,[ivh_revenue_date]) as [Revenue Year], 
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
       'Trailer Company' = (select min(trl_company) from trailerprofile (NOLOCK) where trl_id = ivh_trailer),    
       'Trailer Company Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_company and labeldefinition = 'Company' and trl_id = ivh_trailer),''),
       'Trailer Fleet' = (select min(trl_fleet) from trailerprofile (NOLOCK) where trl_id = ivh_trailer),    
       'Trailer Fleet Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_fleet and labeldefinition = 'Fleet' and trl_id = ivh_trailer),''),
       'Trailer Terminal' = (select min(trl_terminal) from trailerprofile (NOLOCK) where trl_id = ivh_trailer),    
       'Trailer Terminal Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_terminal and labeldefinition = 'Terminal' and trl_id = ivh_trailer),''),
       'Trailer Division' = (select min(trl_division) from trailerprofile (NOLOCK) where trl_id = ivh_trailer),
       'Trailer Division Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_division and labeldefinition = 'Division' and trl_id = ivh_trailer),''),
       'Sub Company ID' = (select ord_subcompany from orderheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),
       'Sub Company' = (select Company.cmp_name from Company (NOLOCK),orderheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber and orderheader.ord_subcompany = Company.cmp_id),   
	ivh_currency as 'Invoice Currency',
	--<TTS!*!TMW><Begin><SQLVersion=7>
--        '' as 'Revenue Currency Conversion Status',
        --<TTS!*!TMW><End><SQLVersion=7>
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	IsNull(dbo.fnc_checkforvalidcurrencyconversion(ivd_charge,ivh_currency,'Revenue',ivd_number,Case When ivd_currencydate Is Not Null Then ivd_currencydate Else ivh_currencydate End,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),'No Conversion Status Returned') as 'Revenue Currency Conversion Status',
	--<TTS!*!TMW><End><SQLVersion=2000+>
	'NonAllocatedMoveMiles' = (select sum(stp_lgh_mileage) from stops (NOLOCK),orderheader (NOLOCK) where orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber and stops.mov_number = orderheader.mov_number),
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as 'Booked RevType1',
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivh_booked_revtype1 as 'Booked RevType1',
	--<TTS!*!TMW><End><FeaturePack=Euro>
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Calculated Weight],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_calculated_weight as [Calculated Weight],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Loading Meters],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_loadingmeters as [Loading Meters],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Loading Meters Unit],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_loadingmeters_unit as [Loading Meters Unit],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Ordered Count],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_ordered_count as [Ordered Count],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as  [Ordered Loading Meters],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_ordered_loadingmeters as [Ordered Loading Meters],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Ordered Volume],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_ordered_volume as [Ordered Volume],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Ordered Weight],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_ordered_weight as [Ordered Weight],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Pay LegHeaderNumber],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_paylgh_number as [Pay LegHeaderNumber],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Tarrif Type],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--ivd_tariff_type as [Tarrif Type],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [Tax ID],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>

	--ivd_taxid as [Tax ID],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [LH Stl],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--cht_lh_stl as [LH Stl],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [LH Min],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--cht_lh_min as [LH Min],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [LH Rev],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--cht_lh_rev as [LH Rev],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [LH Rpt],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--cht_lh_rpt as [LH Rpt],
	--<TTS!*!TMW><End><FeaturePack=Euro>
	 
	 
	
	--<TTS!*!TMW><Begin><FeaturePack=Other>
	'' as [LH Prn],
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--cht_lh_prn as [LH Prn],
	--<TTS!*!TMW><End><FeaturePack=Euro>  

	--<TTS!*!TMW><Begin><FeaturePack=Other> 
        '' as [Origin Country],
        --<TTS!*!TMW><End><FeaturePack=Other> 
        --<TTS!*!TMW><Begin><FeaturePack=Euro> 
        --(select cty_country from city (NOLOCK) where cty_code = ivh_origincity) as 'Origin Country',
        --<TTS!*!TMW><End><FeaturePack=Euro> 

        --<TTS!*!TMW><Begin><FeaturePack=Other> 
        '' as [Destination Country],
        --<TTS!*!TMW><End><FeaturePack=Other> 
        --<TTS!*!TMW><Begin><FeaturePack=Euro> 
        --(select cty_country from city (NOLOCK) where cty_code = ivh_destcity) as 'Destination Country',
        --<TTS!*!TMW><End><FeaturePack=Euro> 	


	(select cht_edicode from chargetype (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [EDI Code],
	(select cht_basis from chargetype (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [Basis],	
	(select cht_basisunit from chargetype (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [Basis Unit],	
	(select cht_basisper from chargetype (NOLOCK) where chargetype.cht_itemcode = invoicedetail.cht_itemcode) as [Basis Per],
	--(select Min(cty_region1) from city (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region1],
        --(select Min(cty_region2) from city (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region2],
        --(select Min(cty_region3) from city (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region3],
        --(select Min(cty_region4) from city (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region4],
        --(select Min(cty_region1) from city (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region1],
        --(select Min(cty_region2) from city (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region2],
        --(select Min(cty_region3) from city (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region3],
        --(select Min(cty_region4) from city (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region4],
	IsNull((select ord_status from orderheader (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber),'CMP') as [Order Status],
	--<TTS!*!TMW><Begin><FeaturePack=Other> 
        NULL as [Doc Number]
        --<TTS!*!TMW><End><FeaturePack=Other> 
        --<TTS!*!TMW><Begin><FeaturePack=Euro> 
        --ivh_docnumber as [Doc Number]
        --<TTS!*!TMW><End><FeaturePack=Euro>

FROM invoiceheader (NOLOCK) ,invoicedetail (NOLOCK)
Where InvoiceHeader.ivh_hdrnumber = InvoiceDetail.ivh_hdrnumber





--) As TempInvoiceDetails



	
	

















































GO
GRANT SELECT ON  [dbo].[vTTSTMW_ChargeDetails] TO [public]
GO
