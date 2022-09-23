SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO









--select top 500 *  from vTTSTMW_OrderandInvoiceInformation

CREATE                                                                   View [dbo].[vTTSTMW_OrderandInvoiceInformation] 

As

select TempOrderInvoiceInformation2.*,
       convert(money,(PercentofRevenueForMovement * PayPerMove)) As Pay,
       --convert(money,(PercentofRevenueForMovement * OpenPayPerMove)) As OpenPay,
       convert(money,[Total Revenue] - (PercentofRevenueForMovement * PayPerMove)) As Net,
       [Carrier Name] = (select top 1 car_name from carrier (NOLOCK) where car_id = [Carrier ID])

from

(

select    
        TempOrderInvoiceInformation.*,
       	
	Case When ([Invoice Header Number] = (select min(ivh_hdrnumber) from invoiceheader b (NOLOCK) where [Order Header Number] = b.ord_hdrnumber and b.ord_hdrnumber <> 0)) Or ([Invoice Number] = 'NI')Then
		
		Case When [Total Revenue For Movement] = 0  Then
                	convert(float,1)/convert(float,(select count(c.ord_hdrnumber) from orderheader c (NOLOCK) where c.mov_number = [Move Number])) 
       		Else
	        	convert(float,[Total Revenue For Order For Pay Allocation])/convert(float,[Total Revenue For Movement])
       		End 
       		
	Else
		 convert(money,0.00)
	
	End as PercentofRevenueForMovement,
	--**Book Date**
	ord_bookdate as 'Booked Date', 
        --Day
        (Cast(Floor(Cast([ord_bookdate] as float))as smalldatetime)) as [Book Date Only], 
        Cast(DatePart(yyyy,[ord_bookdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_bookdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_bookdate]) as varchar(2)) as [Book Day],
        --Month
        Cast(DatePart(mm,[ord_bookdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_bookdate]) as varchar(4)) as [Book Month],
        DatePart(mm,[ord_bookdate]) as [Book Month Only],
        --Year
        DatePart(yyyy,[ord_bookdate]) as [Book Year]
   

from

(	

select 	ord_number as 'Order Number',
	orderheader.cht_itemcode as 'Charge Item Code',
	ord_hdrnumber as 'Order Header Number', 
	mov_number as 'Move Number',
	ord_status as 'Order Status',
	ord_invoicestatus as 'Invoice Status',
	'' as 'Master Bill Status List',
	'' as [Master Bill Number], 
	ord_bookdate, 
	ord_bookedby as 'Booked By',
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
	--**Delivery Date**
	ord_completiondate as 'Delivery Date', 
	(Cast(Floor(Cast([ord_completiondate] as float))as smalldatetime)) as [Delivery Date Only], 
        Cast(DatePart(yyyy,[ord_completiondate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_completiondate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_completiondate]) as varchar(2)) as [Delivery Day],
        --Month
        Cast(DatePart(mm,[ord_completiondate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_completiondate]) as varchar(4)) as [Delivery Month],
        DatePart(mm,[ord_completiondate]) as [Delivery Month Only],
        --Year
        DatePart(yyyy,[ord_completiondate]) as [Delivery Year], 
	--**Bill Date**
	Null as 'Bill Date',
	Null as [Bill Date Only], 
	Null as [Bill Day],	
	Null as [Bill Month],
	Null as [Bill Month Only],
	Null as [Bill Year],
	--**Revenue Date**
	Null as  'Revenue Date',
	--**Transfer Date**
	Null as 'Transfer Date',
	Null as [Transfer Date Only], 
	Null as [Transfer Day],	
	Null as [Transfer Month],
	Null as [Transfer Month Only],
	Null as [Transfer Year],
	'NI' as 'Invoice Number',
	0 as 'Invoice Header Number',
	'N' as 'Invoiced',
	ord_billto as 'Bill To ID', 
	'Bill To' = (select Top 1 Company.cmp_name from Company (NOLOCK) where orderheader.ord_billto = Company.cmp_id), 
	ord_shipper as 'Shipper ID',
	'Shipper' = (select Top 1 Company.cmp_name from Company  (NOLOCK) where orderheader.ord_shipper = Company.cmp_id), 
	ord_consignee as 'Consignee ID',
	'Consignee' = (select Top 1 Company.cmp_name from Company  (NOLOCK) where orderheader.ord_consignee = Company.cmp_id), 
	ord_company as 'Ordered By ID',
	'Other Type1-Ordered By' = (select Company.cmp_othertype1 from Company  (NOLOCK) where orderheader.ord_company = Company.cmp_id),
	'Other Type2-Ordered By' = (select Company.cmp_othertype2 from Company  (NOLOCK) where orderheader.ord_company = Company.cmp_id),
	'Ordered By' = (select Top 1 Company.cmp_name from Company (NOLOCK) where orderheader.ord_company = Company.cmp_id), 
	(select cty_zip from city (NOLOCK) where cty_code = ord_origincity) as 'Origin Zip Code',
        (select cty_zip from city (NOLOCK) where cty_code = ord_destcity) as 'Dest Zip Code', 
	ord_originstate as 'Origin State', 
	'Origin City State' = (select City.cty_name + ', '+ City.cty_state from City (NOLOCK) where orderheader.ord_origincity = City.cty_code), 
	ord_deststate as 'Destination State',
	'Destination City State' = (select City.cty_name + ', '+ City.cty_state from City (NOLOCK) where orderheader.ord_destcity = City.cty_code),
	ord_driver1 as 'Driver ID',
	'Driver Name' = IsNull((select mpp_lastfirst from manpowerprofile (NOLOCK) where mpp_id = ord_driver1),''), 
	'DrvType1' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1' and ord_driver1 = mpp_id),''),
	'DrvType2' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2' and ord_driver1 = mpp_id),''),
	'DrvType3' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3' and ord_driver1 = mpp_id),''),
	'DrvType4' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4' and ord_driver1 = mpp_id),''),
	ord_tractor as 'Tractor',
	ord_trailer as 'Trailer',
	ord_terms as 'Terms',
	'Master Bill To ID' = (select cmp_mastercompany from company (NOLOCK) where cmp_id = ord_billto),
	'Master Bill To' = (select cmp_name from company a (NOLOCK) where a.cmp_id = (select cmp_mastercompany from company (NOLOCK) where cmp_id = ord_billto)), 
        ord_refnum as 'Reference Number',
        ord_reftype as 'Ref Type',
	IsNull(ord_totalmiles,0) as 'Billed Miles',
	IsNull(ord_totalweight,0) as 'Total Weight',
	IsNull(ord_totalpieces,0) as 'Total Pieces',
	ord_currency as 'Currency',
	--<TTS!*!TMW><Begin><SQLVersion=7>
--	convert(money,IsNull(ord_totalcharge,0)) as 'Total Revenue',
	--<TTS!*!TMW><End><SQLVersion=7>

        --<TTS!*!TMW><Begin><SQLVersion=2000+>
	convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as 'Total Revenue',
	--<TTS!*!TMW><End><SQLVersion=2000+>

	--<TTS!*!TMW><Begin><SQLVersion=7>
--	convert(money,IsNull(ord_charge,0)) as 'Line Haul Revenue',
	--<TTS!*!TMW><End><SQLVersion=7>	
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	convert(money,IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as 'Line Haul Revenue',
	--<TTS!*!TMW><End><SQLVersion=2000+>

	--<TTS!*!TMW><Begin><SQLVersion=7>
--	convert(money,IsNull(ord_totalcharge,0) - IsNull(ord_charge,0)) 'Accessorial Revenue',
	--<TTS!*!TMW><End><SQLVersion=7> 
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) - convert(money,IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as 'Accessorial Revenue',
	--<TTS!*!TMW><End><SQLVersion=2000+>	

	ord_revtype1 as 'RevType1',
        'RevType1 Name' = IsNull((select name from labelfile (NOLOCK)where labelfile.abbr = ord_revtype1 and labeldefinition = 'RevType1'),''),
	ord_revtype2 as 'RevType2',
	'RevType2 Name' = IsNull((select name from labelfile  (NOLOCK)where labelfile.abbr = ord_revtype2 and labeldefinition = 'RevType2'),''),
	ord_revtype3 as 'RevType3',
	'RevType3 Name' = IsNull((select name from labelfile  (NOLOCK)where labelfile.abbr = ord_revtype3 and labeldefinition = 'RevType3'),''),
	ord_revtype4 as 'RevType4',
        'RevType4 Name' = IsNull((select name from labelfile  (NOLOCK) where labelfile.abbr = ord_revtype4 and labeldefinition = 'RevType4'),''),
	'Updated On Date' = (select max(lgh_updatedon) from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber),
        'PaperWork Received Date' =  (select max(pw_dt) from paperwork where pw_received = 'Y' and paperwork.ord_hdrnumber = orderheader.ord_hdrnumber),
	
        (select cmp_othertype1 from company where cmp_id = ord_billto) as [Other Type 1],
	(select cmp_othertype2 from company where cmp_id = ord_billto) as [Other Type 2],
	
	
	 --sums total revenue for movement for only orders that we can allocate expense to
	 
	 --<TTS!*!TMW><Begin><SQLVersion=7>
--	 (
--	   convert(money,IsNull((select sum(a.ord_totalcharge) from orderheader a where a.mov_number = orderheader.mov_number and a.ord_invoicestatus <> 'PPD'),0.00)) 
--		+   
--	   convert(money,IsNull((select sum(a.ivh_totalcharge) from invoiceheader a where a.mov_number = orderheader.mov_number),0.00))
--         ) As 'Total Revenue For Movement',
	 --<TTS!*!TMW><End><SQLVersion=7> 
	 
	 --<TTS!*!TMW><Begin><SQLVersion=2000+>
	(
	   convert(money,IsNull((select convert(money,sum(IsNull(dbo.fnc_convertcharge(IsNull(a.ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))) from orderheader a where a.mov_number = orderheader.mov_number and a.ord_invoicestatus <> 'PPD'),0.00)) 
		+   
	  convert(money,IsNull((select convert(money,sum(IsNull(dbo.fnc_convertcharge(IsNull(a.ivh_totalcharge,0)-(IsNull(a.ivh_taxamount1,0) + IsNull(a.ivh_taxamount2,0) + IsNull(a.ivh_taxamount3,0) + IsNull(a.ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0))) from invoiceheader a where a.mov_number = orderheader.mov_number),0.00))
          ) As 'Total Revenue For Movement',
	 --<TTS!*!TMW><End><SQLVersion=2000+>
	
	   --<TTS!*!TMW><Begin><SQLVersion=7>
--	   convert(money,IsNull(ord_totalcharge,0)) As 'Total Revenue For Order For Pay Allocation',	        
	   --<TTS!*!TMW><End><SQLVersion=7> 
	
	   
	   --<TTS!*!TMW><Begin><SQLVersion=2000+>
	   convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))
	   As 'Total Revenue For Order For Pay Allocation',	    
	   --<TTS!*!TMW><End><SQLVersion=2000+>

	   --<TTS!*!TMW><Begin><SQLVersion=7>
--           convert(money,IsNull((select sum(pyd_amount) from paydetail (NOLOCK) where orderheader.mov_number = paydetail.mov_number and pyd_minus = 1),0.00)) as 'PayPerMove',
	   --<TTS!*!TMW><End><SQLVersion=7>
	   
	   --<TTS!*!TMW><Begin><SQLVersion=2000+>
           convert(money,IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) from paydetail (NOLOCK) where orderheader.mov_number = paydetail.mov_number and pyd_minus = 1),0.00)) as 'PayPerMove',
	   --<TTS!*!TMW><End><SQLVersion=2000+>   

	   OrderHasPayDetailsYN = IsNull((select Min('Y') from paydetail (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber and paydetail.ord_hdrnumber <> 0),'N'),
           MovementHasPayDetailsYN = IsNull((select Min('Y') from paydetail (NOLOCK) where orderheader.mov_number = paydetail.mov_number and paydetail.mov_number <> 0),'N'),
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
	   ord_currencydate as 'Currency Date',
	   --<TTS!*!TMW><Begin><SQLVersion=7>
--           '' as 'Revenue Currency Conversion Status',
           --<TTS!*!TMW><End><SQLVersion=7>
	   --<TTS!*!TMW><Begin><SQLVersion=2000+>
           IsNull(dbo.fnc_checkforvalidcurrencyconversion(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),'No Conversion Status Returned') as 'Revenue Currency Conversion Status',
	   --<TTS!*!TMW><End><SQLVersion=2000+>

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
	   
	   (select Min(cty_region1) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region1],
           (select Min(cty_region2) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region2],
           (select Min(cty_region3) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region3],
           (select Min(cty_region4) from city (NOLOCK) Where ord_origincity = cty_code) as [Origin Region4],
           (select Min(cty_region1) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region1],
           (select Min(cty_region2) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region2],
           (select Min(cty_region3) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region3],
           (select Min(cty_region4) from city (NOLOCK) Where ord_destcity = cty_code) as [Destination Region4],

	   --<TTS!*!TMW><Begin><FeaturePack=Other>
           '' as 'Booked RevType1',
           --<TTS!*!TMW><End><FeaturePack=Other>
           --<TTS!*!TMW><Begin><FeaturePack=Euro>
           --ord_booked_revtype1 as 'Booked RevType1'
           --<TTS!*!TMW><End><FeaturePack=Euro>  
	   ord_fromorder as [Master Order Number],
		
	   [Carrier ID] = (select top 1 asgn_id from assetassignment (NOLOCK) where assetassignment.mov_number = orderheader.mov_number and asgn_type = 'CAR'),
	   	   
	   (	SELECT 
				
				IsNull(sum(ivd_charge),0.00)
							
				
			FROM 	invoicedetail (NOLOCK), 
				chargetype (NOLOCK)
				
			WHERE 
				
				OrderHeader.ord_hdrnumber= invoicedetail.ord_hdrnumber
				And
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				AND 
				(
					Upper(chargetype.cht_itemcode) like 'FUEL%'
					OR
					CharIndex('FUEL', cht_description)>0
				)
				and ivd_charge is Not Null
			) As 'Fuel Surcharge',
		'Driver Other ID' = IsNull((select mpp_otherid from manpowerprofile (NOLOCK) where mpp_id = ord_driver1),'')
	 
from 	orderheader  (NOLOCK)
where 	not exists (select * from invoiceheader (NoLock) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
	
union

/* >> GET DATA FOR ORDERS WITH  INVOICEHEADERS */

select 	invoiceheader.ord_number as 'Order Number',
	invoiceheader.cht_itemcode as 'Charge Item Code',
	invoiceheader.ord_hdrnumber as 'Order Header Number',  
	invoiceheader.mov_number as 'Move Number', 
	IsNull((select ord_status from orderheader (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber),'CMP') as [Order Status],
	invoiceheader.ivh_invoicestatus as 'Invoice Status',
	invoiceheader.ivh_mbstatus as 'Master Bill Status List',
	invoiceheader.ivh_mbnumber as 'Master Bill Number', 
	(select ord_bookdate from orderheader (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber) as ord_bookdate,
	(select ord_bookedby from orderheader (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber) as 'Booked By', 
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
	--**Bill Date**
	ivh_billdate as 'Bill Date',
        --Day
        (Cast(Floor(Cast([ivh_billdate] as float))as smalldatetime)) as [Bill Date Only], 
        Cast(DatePart(yyyy,[ivh_billdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_billdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_billdate]) as varchar(2)) as [Bill Day],
        --Month
        Cast(DatePart(mm,[ivh_billdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_billdate]) as varchar(4)) as [Bill Month],
        DatePart(mm,[ivh_billdate]) as [Bill Month Only],
        --Year
        DatePart(yyyy,[ivh_billdate]) as [Bill Year], 
	ivh_revenue_date as 'Revenue Date',
	--**Transfer Date**
	ivh_xferdate as [Transfer Date],
	--Day
        (Cast(Floor(Cast([ivh_xferdate] as float))as smalldatetime)) as [Transfer Date Only], 
        Cast(DatePart(yyyy,[ivh_xferdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_xferdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_xferdate]) as varchar(2)) as [Transfer Day],
        --Month
        Cast(DatePart(mm,[ivh_xferdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_xferdate]) as varchar(4)) as [Transfer Month],
        DatePart(mm,[ivh_xferdate]) as [Transfer Month Only],
        --Year
        DatePart(yyyy,[ivh_xferdate]) as [Transfer Year],  
	ivh_invoicenumber as 'Invoice Number',
	ivh_hdrnumber as 'Invoice Header Number',
	'Y' as 'Invoiced', 
	ivh_billto as 'Bill To ID',
	'BillTo' = (select Top 1 Company.cmp_name from Company (NOLOCK) where invoiceheader.ivh_billto = Company.cmp_id), 
	ivh_shipper as 'Shipper ID',
	'Shipper' = (select Top 1 Company.cmp_name from Company (NOLOCK) where invoiceheader.ivh_shipper = Company.cmp_id),
	ivh_consignee as 'Consignee ID',
	'Consignee' = (select Top 1 Company.cmp_name from Company (NOLOCK) where invoiceheader.ivh_consignee = Company.cmp_id),  
	ivh_order_by as 'Ordered By ID',
	'Other Type1-Ordered By' = (select Company.cmp_othertype1 from Company  (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
	'Other Type2-Ordered By' = (select Company.cmp_othertype2 from Company  (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
	'Ordered By' = (select Top 1 Company.cmp_name from Company (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
	(select cty_zip from city (NOLOCK) where cty_code = ivh_origincity) as 'Origin Zip Code',
        (select cty_zip from city (NOLOCK) where cty_code = ivh_destcity) as 'Dest Zip Code', 
	ivh_originstate as 'Origin State', 
	'Origin City State' = (select City.cty_name + ', '+ City.cty_state from City (NOLOCK) where invoiceheader.ivh_origincity = City.cty_code), 
	ivh_deststate as 'Destination State',
	'Destination City State' = (select City.cty_name + ', '+ City.cty_state from City (NOLOCK) where invoiceheader.ivh_destcity = City.cty_code), 
	invoiceheader.ivh_driver as 'Driver ID',
	'Driver Name' = IsNull((select mpp_lastfirst from manpowerprofile (NOLOCK) where mpp_id = ivh_driver),''),
	'DrvType1' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1' and ivh_driver = mpp_id),''),
	'DrvType2' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2' and ivh_driver = mpp_id),''),
	'DrvType3' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3' and ivh_driver = mpp_id),''),
	'DrvType4' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4' and ivh_driver = mpp_id),''),
	ivh_tractor as 'Tractor',
	ivh_trailer as 'Trailer',
	invoiceheader.ivh_terms as 'Terms',
	'Master Bill To ID' = (select cmp_mastercompany from company (NOLOCK) where cmp_id = ivh_billto),
	'Master Bill To' = (select cmp_name from company a (NOLOCK) where a.cmp_id = (select cmp_mastercompany from company (NOLOCK) where cmp_id = ivh_billto)), 
        ivh_ref_number as 'Reference Number',
        ivh_reftype as 'Ref Type',	

	Case 
	When invoiceheader.ivh_creditmemo = 'Y' Then
		        (invoiceheader.ivh_totalmiles * -1)
	Else
			invoiceheader.ivh_totalmiles
	End As 'Billed Miles',
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

	
	--<TTS!*!TMW><Begin><SQLVersion=7>
--	IsNull(invoiceheader.ivh_totalcharge,0) as 'Total Revenue',
        --<TTS!*!TMW><End><SQLVersion=7>
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>

	convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Total Revenue',
	--<TTS!*!TMW><End><SQLVersion=2000+>
	
	--<TTS!*!TMW><Begin><SQLVersion=7>
-- 	convert(money,IsNull(invoiceheader.ivh_charge,0)) as 'Line Haul Revenue',
	--<TTS!*!TMW><End><SQLVersion=7>	

	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	convert(money,IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Line Haul Revenue',
	--<TTS!*!TMW><End><SQLVersion=2000+>
	
	--<TTS!*!TMW><Begin><SQLVersion=7>
--	convert(money,IsNull(invoiceheader.ivh_totalcharge,0) - IsNull(invoiceheader.ivh_charge,0)) as 'Accessorial Revenue',
	--<TTS!*!TMW><End><SQLVersion=7> 
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) - convert(money,IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Accessorial Revenue',
	--<TTS!*!TMW><End><SQLVersion=2000+>

	ivh_revtype1 as 'RevType1',
        'RevType1 Name' = IsNull((select name from labelfile (NOLOCK)where labelfile.abbr = ivh_revtype1 and labeldefinition = 'RevType1'),''),
	ivh_revtype2 as 'RevType2',
        'RevType2 Name' = IsNull((select name from labelfile  (NOLOCK)where labelfile.abbr = ivh_revtype2 and labeldefinition = 'RevType2'),''),
	ivh_revtype3 as 'RevType3',
        'RevType3 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = ivh_revtype3 and labeldefinition = 'RevType3'),''),
	ivh_revtype4 as 'RevType4',
        'RevType4 Name' = IsNull((select name from labelfile  (NOLOCK) where labelfile.abbr = ivh_revtype4 and labeldefinition = 'RevType4'),''),
	'Updated On Date' = (select max(lgh_updatedon) from legheader where legheader.ord_hdrnumber = invoiceheader.ord_hdrnumber),
        'PaperWork Received Date' =  (select max(pw_dt) from paperwork where pw_received = 'Y' and paperwork.ord_hdrnumber = invoiceheader.ord_hdrnumber),
	
        (select cmp_othertype1 from company where cmp_id = ivh_billto) as [Other Type 1],
        (select cmp_othertype2 from company where cmp_id = ivh_billto) as [Other Type 2],
	
	  --sums total revenue for movement for only orders that we can allocate expense to
	  
	  --<TTS!*!TMW><Begin><SQLVersion=7>
--	   (
--	    convert(money,IsNull((select sum(a.ord_totalcharge) from orderheader a where a.mov_number = invoiceheader.mov_number and a.ord_invoicestatus <> 'PPD'),0.00)) 
--		+   
--	    convert(money,IsNull((select sum(a.ivh_totalcharge) from invoiceheader a where a.mov_number = invoiceheader.mov_number),0.00))
--           ) As 'Total Revenue For Movement',
	  --<TTS!*!TMW><End><SQLVersion=7>

	  --<TTS!*!TMW><Begin><SQLVersion=2000+>
	   (
	   convert(money,IsNull((select convert(money,sum(IsNull(dbo.fnc_convertcharge(IsNull(a.ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))) from orderheader a where a.mov_number = invoiceheader.mov_number and a.ord_invoicestatus <> 'PPD'),0.00)) 
		+   
	   convert(money,IsNull((select convert(money,sum(IsNull(dbo.fnc_convertcharge(IsNull(a.ivh_totalcharge,0)-(IsNull(a.ivh_taxamount1,0) + IsNull(a.ivh_taxamount2,0) + IsNull(a.ivh_taxamount3,0) + IsNull(a.ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0))) from invoiceheader a where a.mov_number = invoiceheader.mov_number),0.00))
            ) As 'Total Revenue For Movement',
	  --<TTS!*!TMW><End><SQLVersion=2000+>	

	--<TTS!*!TMW><Begin><SQLVersion=7>
--	(select sum(ivh_totalcharge) from invoiceheader a where a.ord_hdrnumber = invoiceheader.ord_hdrnumber)
--	      As 'Total Revenue For Order For Pay Allocation',	  
	--<TTS!*!TMW><End><SQLVersion=7>	

	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	(select convert(money,sum(IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0))) from invoiceheader a where a.ord_hdrnumber = invoiceheader.ord_hdrnumber)
	      As 'Total Revenue For Order For Pay Allocation',	
	--<TTS!*!TMW><End><SQLVersion=2000+>

	--<TTS!*!TMW><Begin><SQLVersion=7>
--	Case When ivh_hdrnumber = (select min(ivh_hdrnumber) from invoiceheader b (NOLOCK) where invoiceheader.ord_hdrnumber = b.ord_hdrnumber and b.ord_hdrnumber <> 0) Then
--	       convert(money,IsNull((select sum(pyd_amount) from paydetail (NOLOCK) where invoiceheader.mov_number = paydetail.mov_number and pyd_minus = 1),0.00)) 
--        Else
--	       convert(money,0.00)
--	End as 'PayPerMove',
	--<TTS!*!TMW><End><SQLVersion=7>  
  
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
        Case When ivh_hdrnumber = (select min(ivh_hdrnumber) from invoiceheader b (NOLOCK) where invoiceheader.ord_hdrnumber = b.ord_hdrnumber and b.ord_hdrnumber <> 0) Then
	       convert(money,IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) from paydetail (NOLOCK) where invoiceheader.mov_number = paydetail.mov_number and pyd_minus = 1),0.00)) 
        Else
	       convert(money,0.00)
	End as 'PayPerMove',
	--<TTS!*!TMW><End><SQLVersion=2000+>

	
	OrderHasPayDetailsYN = IsNull((select Min('Y') from paydetail (NOLOCK) where invoiceheader.ord_hdrnumber = paydetail.ord_hdrnumber and paydetail.ord_hdrnumber <> 0),'N'),
        MovementHasPayDetailsYN = IsNull((select Min('Y') from paydetail (NOLOCK) where invoiceheader.mov_number = paydetail.mov_number and paydetail.mov_number <> 0),'N'),
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
	ivh_currencydate as 'Currency Date',
	--<TTS!*!TMW><Begin><SQLVersion=7>
--	'' as 'Revenue Currency Conversion Status',
	--<TTS!*!TMW><End><SQLVersion=7>
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	IsNull(dbo.fnc_checkforvalidcurrencyconversion(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),'No Conversion Status Returned') as 'Revenue Currency Conversion Status',
	--<TTS!*!TMW><End><SQLVersion=2000+>
	
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

	(select Min(cty_region1) from city (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region1],
        (select Min(cty_region2) from city (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region2],
        (select Min(cty_region3) from city (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region3],
        (select Min(cty_region4) from city (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region4],
        (select Min(cty_region1) from city (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region1],
        (select Min(cty_region2) from city (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region2],
        (select Min(cty_region3) from city (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region3],
        (select Min(cty_region4) from city (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region4],

	--<TTS!*!TMW><Begin><FeaturePack=Other>
        '' as 'Booked RevType1',
        --<TTS!*!TMW><End><FeaturePack=Other>
        --<TTS!*!TMW><Begin><FeaturePack=Euro>
        --ivh_booked_revtype1 as 'Booked RevType1'
        --<TTS!*!TMW><End><FeaturePack=Euro>  

	[Master Order Number]=(select ord_fromorder from orderheader (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber),
	[Carrier ID] = IsNull(ivh_carrier,''),
	
			(	SELECT 
				--<TTS!*!TMW><Begin><SQLVersion=7> 
--				IsNull(sum(ivd_charge),0.00)
				--<TTS!*!TMW><End><SQLVersion=7> 				
				--<TTS!*!TMW><Begin><SQLVersion=2000+>				
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,b.ivh_currency,'Revenue',ivd_number,ivd_currencydate,b.ivh_shipdate,b.ivh_deliverydate,b.ivh_billdate,b.ivh_revenue_date,b.ivh_xferdate,default,b.ivh_printdate,default,default,default),0.00))),0.00)
				--<TTS!*!TMW><End><SQLVersion=2000+>
			FROM 	invoicedetail (NOLOCK), 
				chargetype (NOLOCK),
				invoiceheader b (NOLOCK)
			WHERE 
				invoiceheader.ivh_invoicestatus <> 'CAN' 
				AND
				b.ivh_hdrnumber = InvoiceHeader.ivh_hdrnumber
				AND
				Invoiceheader.ivh_hdrnumber= invoicedetail.ivh_hdrnumber
				And
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				AND 
				(
					Upper(chargetype.cht_itemcode) like 'FUEL%'
					OR
					CharIndex('FUEL', cht_description)>0
				)
				and ivd_charge is Not Null
			) As 'Fuel Surcharge',
		'Driver Other ID' = IsNull((select mpp_otherid from manpowerprofile (NOLOCK) where mpp_id = ivh_driver),'')

from    invoiceheader (NOLOCK)
--from 	orderheader (NOLOCK),invoiceheader (NOLOCK) 
--where 	orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber 
	

) as TempOrderInvoiceInformation

) as TempOrderInvoiceInformation2




































































GO
GRANT SELECT ON  [dbo].[vTTSTMW_OrderandInvoiceInformation] TO [public]
GO
