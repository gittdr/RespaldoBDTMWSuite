SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE View [dbo].[vSSRSRB_OrderAndInvoiceInformation]
As

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_OrderAndInvoiceInformation]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View bASed on the old vttstmw_OrderAndInvoiceInformation
 
 *
**************************************************************************

Sample call


SELECT * FROM [vSSRSRB_OrderAndInvoiceInformation]

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
 * 3/26/2014 DW Made [OrderStatus] and [InvoiceStatus] return as one word to account for report parts. 
 * 10/24/2014 - MREED corrected fuel surcharge calculation, removed 6 fields that were just '' and no data - no reason for these.
 ***********************************************************/

select TempOrderInvoiceInformation2.*,
       convert(money,(PercentofRevenueForMovement * PayPerMove)) As Pay,
       convert(money,[Total Revenue] - (PercentofRevenueForMovement * PayPerMove)) As Net,
       [Carrier Name] = (select top 1 car_name from carrier WITH (NOLOCK) where car_id = [Carrier ID])
from

(

select    
        TempOrderInvoiceInformation.*,
       	
	Case When ([Invoice Header Number] = (select min(ivh_hdrnumber) from invoiceheader b WITH (NOLOCK) where [Order Header Number] = b.ord_hdrnumber and b.ord_hdrnumber <> 0)) Or ([Invoice Number] = 'NI')Then
		
		Case When [Total Revenue For Movement] = 0  Then
                	convert(float,1)/convert(float,(select count(c.ord_hdrnumber) from orderheader c WITH (NOLOCK) where c.mov_number = [Move Number])) 
       		Else
	        	convert(float,[Total Revenue For Order For Pay Allocation])/convert(float,[Total Revenue For Movement])
       		End 
       		
	Else
		 convert(money,0.00)
	
	End as PercentofRevenueForMovement,
	ord_bookdate as 'Booked Date', 
        (Cast(Floor(Cast([ord_bookdate] as float))as smalldatetime)) as [Book Date Only], 
        Cast(DatePart(yyyy,[ord_bookdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_bookdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_bookdate]) as varchar(2)) as [Book Day],
        Cast(DatePart(mm,[ord_bookdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_bookdate]) as varchar(4)) as [Book Month],
        DatePart(mm,[ord_bookdate]) as [Book Month Only],
        DatePart(yyyy,[ord_bookdate]) as [Book Year]
from
(	
select 	ord_number as 'Order Number',
	orderheader.cht_itemcode as 'Charge Item Code',
	ord_hdrnumber as 'Order Header Number', 
	mov_number as 'Move Number',
	ord_status as 'OrderStatus',
	ord_invoicestatus as 'InvoiceStatus',
	'' as 'Master Bill Status List',
	'' as [Master Bill Number], 
	ord_bookdate, 
	ord_bookedby as 'Booked By',
	ord_startdate as 'Ship Date', 
       	(Cast(Floor(Cast([ord_startdate] as float))as smalldatetime)) as [Ship Date Only], 
        Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_startdate]) as varchar(2)) as [Ship Day],
        Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) as [Ship Month],
        DatePart(mm,[ord_startdate]) as [Ship Month Only],
        DatePart(yyyy,[ord_startdate]) as [Ship Year], 
	ord_completiondate as 'Delivery Date', 
	(Cast(Floor(Cast([ord_completiondate] as float))as smalldatetime)) as [Delivery Date Only], 
        Cast(DatePart(yyyy,[ord_completiondate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_completiondate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_completiondate]) as varchar(2)) as [Delivery Day],
        Cast(DatePart(mm,[ord_completiondate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_completiondate]) as varchar(4)) as [Delivery Month],
        DatePart(mm,[ord_completiondate]) as [Delivery Month Only],
        DatePart(yyyy,[ord_completiondate]) as [Delivery Year], 
	Null as 'Bill Date',
	Null as [Bill Date Only], 
	Null as [Bill Day],	
	Null as [Bill Month],
	Null as [Bill Month Only],
	Null as [Bill Year],
	Null as  'Revenue Date',
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
	'Bill To Name' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where orderheader.ord_billto = Company.cmp_id), 
	ord_shipper as 'Shipper ID',
	'Shipper Name' = (select Top 1 Company.cmp_name from Company  WITH (NOLOCK) where orderheader.ord_shipper = Company.cmp_id), 
	ord_consignee as 'Consignee ID',
	'Consignee Name' = (select Top 1 Company.cmp_name from Company  WITH (NOLOCK) where orderheader.ord_consignee = Company.cmp_id), 
	ord_company as 'Ordered By ID',
	'Other Type1-Ordered By' = (select Company.cmp_othertype1 from Company  WITH (NOLOCK) where orderheader.ord_company = Company.cmp_id),
	'Other Type2-Ordered By' = (select Company.cmp_othertype2 from Company  WITH (NOLOCK) where orderheader.ord_company = Company.cmp_id),
	'Ordered By' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where orderheader.ord_company = Company.cmp_id), 
	(select cty_zip from city WITH (NOLOCK) where cty_code = ord_origincity) as 'Origin Zip Code',
        (select cty_zip from city WITH (NOLOCK) where cty_code = ord_destcity) as 'Dest Zip Code', 
	ord_originstate as 'Origin State', 
	'Origin City State' = (select City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where orderheader.ord_origincity = City.cty_code), 
	ord_deststate as 'Destination State',
	'Destination City State' = (select City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where orderheader.ord_destcity = City.cty_code),
	ord_driver1 as 'Driver ID',
	'Driver Name' = IsNull((select mpp_lastfirst from manpowerprofile WITH (NOLOCK) where mpp_id = ord_driver1),''), 
	'DrvType1' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1' and ord_driver1 = mpp_id),''),
	'DrvType2' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2' and ord_driver1 = mpp_id),''),
	'DrvType3' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3' and ord_driver1 = mpp_id),''),
	'DrvType4' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4' and ord_driver1 = mpp_id),''),
	ord_tractor as 'Tractor',
	ord_trailer as 'Trailer',
	ord_terms as 'Terms',
	'Master Bill To ID' = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ord_billto),
	'Master Bill To' = (select cmp_name from company a WITH (NOLOCK) where a.cmp_id = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ord_billto)), 
        ord_refnum as 'Reference Number',
        ord_reftype as 'Ref Type',
	IsNull(ord_totalmiles,0) as 'Billed Miles',
	IsNull(ord_totalweight,0) as 'Total Weight',
	IsNull(ord_totalpieces,0) as 'Total Pieces',
	ord_currency as 'Currency',
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as 'Total Revenue',
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as 'Line Haul Revenue',
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) - convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as 'Accessorial Revenue',
	ord_revtype1 as 'RevType1',
        'RevType1 Name' = IsNull((select name from labelfile WITH (NOLOCK)where labelfile.abbr = ord_revtype1 and labeldefinition = 'RevType1'),''),
	ord_revtype2 as 'RevType2',
	'RevType2 Name' = IsNull((select name from labelfile  WITH (NOLOCK)where labelfile.abbr = ord_revtype2 and labeldefinition = 'RevType2'),''),
	ord_revtype3 as 'RevType3',
	'RevType3 Name' = IsNull((select name from labelfile  WITH (NOLOCK)where labelfile.abbr = ord_revtype3 and labeldefinition = 'RevType3'),''),
	ord_revtype4 as 'RevType4',
        'RevType4 Name' = IsNull((select name from labelfile  WITH (NOLOCK) where labelfile.abbr = ord_revtype4 and labeldefinition = 'RevType4'),''),
	'Updated On Date' = (select max(lgh_updatedon) from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber),
        'PaperWork Received Date' =  (select max(pw_dt) from paperwork where pw_received = 'Y' and paperwork.ord_hdrnumber = orderheader.ord_hdrnumber),
	
        (select cmp_othertype1 from company where cmp_id = ord_billto) as [Other Type 1],
	(select cmp_othertype2 from company where cmp_id = ord_billto) as [Other Type 2],
	(
	   convert(money,IsNull((select convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(a.ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))) from orderheader a where a.mov_number = orderheader.mov_number and a.ord_invoicestatus <> 'PPD'),0.00)) 
		+   
	  convert(money,IsNull((select convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(a.ivh_totalcharge,0)-(IsNull(a.ivh_taxamount1,0) + IsNull(a.ivh_taxamount2,0) + IsNull(a.ivh_taxamount3,0) + IsNull(a.ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0))) from invoiceheader a where a.mov_number = orderheader.mov_number),0.00))
          ) As 'Total Revenue For Movement',
	   convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))
	   As 'Total Revenue For Order For Pay Allocation',	    
           convert(money,IsNull((select sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) from paydetail WITH (NOLOCK) where orderheader.mov_number = paydetail.mov_number and pyd_minus = 1),0.00)) as 'PayPerMove',
	   OrderHasPayDetailsYN = IsNull((select Min('Y') from paydetail WITH (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber and paydetail.ord_hdrnumber <> 0),'N'),
           MovementHasPayDetailsYN = IsNull((select Min('Y') from paydetail WITH (NOLOCK) where orderheader.mov_number = paydetail.mov_number and paydetail.mov_number <> 0),'N'),
           'Trailer Company' = (select min(trl_company) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Company Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_company and labeldefinition = 'Company' and trl_id = ord_trailer),''),
	   'Trailer Fleet' = (select min(trl_fleet) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Fleet Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_fleet and labeldefinition = 'Fleet' and trl_id = ord_trailer),''),
	   'Trailer Terminal' = (select min(trl_terminal) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Terminal Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_terminal and labeldefinition = 'Terminal' and trl_id = ord_trailer),''),
	   'Trailer Division' = (select min(trl_division) from trailerprofile WITH (NOLOCK) where trl_id = ord_trailer),    
	   'Trailer Division Name' = IsNull((select min(name) from labelfile WITH (NOLOCK),trailerprofile WITH (NOLOCK) where labelfile.abbr = trl_division and labeldefinition = 'Division' and trl_id = ord_trailer),''),
	   'Sub Company ID' = ord_subcompany,
	   'Sub Company' = (select Company.cmp_name from Company WITH (NOLOCK) where orderheader.ord_subcompany = Company.cmp_id),
	   ord_currencydate as 'Currency Date',
           IsNull(dbo.TMWSSRS_fnc_checkforvalidcurrencyconversion(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),'No Conversion Status Returned') as 'Revenue Currency Conversion Status',
	   (select Min(cty_region1) from city WITH (NOLOCK) Where ord_origincity = cty_code) as [Origin Region1],
           (select Min(cty_region2) from city WITH (NOLOCK) Where ord_origincity = cty_code) as [Origin Region2],
           (select Min(cty_region3) from city WITH (NOLOCK) Where ord_origincity = cty_code) as [Origin Region3],
           (select Min(cty_region4) from city WITH (NOLOCK) Where ord_origincity = cty_code) as [Origin Region4],
           (select Min(cty_region1) from city WITH (NOLOCK) Where ord_destcity = cty_code) as [Destination Region1],
           (select Min(cty_region2) from city WITH (NOLOCK) Where ord_destcity = cty_code) as [Destination Region2],
           (select Min(cty_region3) from city WITH (NOLOCK) Where ord_destcity = cty_code) as [Destination Region3],
           (select Min(cty_region4) from city WITH (NOLOCK) Where ord_destcity = cty_code) as [Destination Region4],
	   ord_fromorder as [Master Order Number],
	   [Carrier ID] = (select top 1 asgn_id from assetassignment WITH (NOLOCK) where assetassignment.mov_number = orderheader.mov_number and asgn_type = 'CAR'),
	   (	SELECT IsNull(sum(ivd_charge),0.00)
			FROM invoicedetail WITH (NOLOCK)
			JOIN chargetype WITH (NOLOCK) ON invoicedetail.cht_itemcode = chargetype.cht_itemcode	
			WHERE OrderHeader.ord_hdrnumber= invoicedetail.ord_hdrnumber
				AND 
				(
				Upper(chargetype.cht_itemcode) like 'FUEL%'
				OR
				CharIndex('FUEL', cht_description)>0
				)
				and ivd_charge is Not Null
			) As 'Fuel Surcharge',
		'Driver Other ID' = IsNull((select mpp_otherid from manpowerprofile WITH (NOLOCK) where mpp_id = ord_driver1),'')
from 	orderheader  WITH (NOLOCK)
where 	not exists (select * from invoiceheader WITH (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
	
union

/* >> GET DATA FOR ORDERS WITH  INVOICEHEADERS */

select 	invoiceheader.ord_number as 'Order Number',
	invoiceheader.cht_itemcode as 'Charge Item Code',
	invoiceheader.ord_hdrnumber as 'Order Header Number',  
	invoiceheader.mov_number as 'Move Number', 
	IsNull((select ord_status from orderheader WITH (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber),'CMP') as [OrderStatus],
	invoiceheader.ivh_invoicestatus as 'InvoiceStatus',
	invoiceheader.ivh_mbstatus as 'Master Bill Status List',
	invoiceheader.ivh_mbnumber as 'Master Bill Number', 
	(select ord_bookdate from orderheader WITH (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber) as ord_bookdate,
	(select ord_bookedby from orderheader WITH (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber) as 'Booked By', 
	ivh_shipdate as 'Ship Date', 
        (Cast(Floor(Cast([ivh_shipdate] as float))as smalldatetime)) as [Ship Date Only], 
        Cast(DatePart(yyyy,[ivh_shipdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_shipdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_shipdate]) as varchar(2)) as [Ship Day],
        Cast(DatePart(mm,[ivh_shipdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_shipdate]) as varchar(4)) as [Ship Month],
        DatePart(mm,[ivh_shipdate]) as [Ship Month Only],
	DatePart(yyyy,[ivh_shipdate]) as [Ship Year], 
	ivh_deliverydate as 'Delivery Date', 
        (Cast(Floor(Cast([ivh_deliverydate] as float))as smalldatetime)) as [Delivery Date Only], 
        Cast(DatePart(yyyy,[ivh_deliverydate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_deliverydate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_deliverydate]) as varchar(2)) as [Delivery Day],
        Cast(DatePart(mm,[ivh_deliverydate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_deliverydate]) as varchar(4)) as [Delivery Month],
        DatePart(mm,[ivh_deliverydate]) as [Delivery Month Only],
        DatePart(yyyy,[ivh_deliverydate]) as [Delivery Year], 
	ivh_billdate as 'Bill Date',
        (Cast(Floor(Cast([ivh_billdate] as float))as smalldatetime)) as [Bill Date Only], 
        Cast(DatePart(yyyy,[ivh_billdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_billdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_billdate]) as varchar(2)) as [Bill Day],
        Cast(DatePart(mm,[ivh_billdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_billdate]) as varchar(4)) as [Bill Month],
        DatePart(mm,[ivh_billdate]) as [Bill Month Only],
        DatePart(yyyy,[ivh_billdate]) as [Bill Year], 
	ivh_revenue_date as 'Revenue Date',
	ivh_xferdate as [Transfer Date],
        (Cast(Floor(Cast([ivh_xferdate] as float))as smalldatetime)) as [Transfer Date Only], 
        Cast(DatePart(yyyy,[ivh_xferdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ivh_xferdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ivh_xferdate]) as varchar(2)) as [Transfer Day],
        Cast(DatePart(mm,[ivh_xferdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ivh_xferdate]) as varchar(4)) as [Transfer Month],
        DatePart(mm,[ivh_xferdate]) as [Transfer Month Only],
        DatePart(yyyy,[ivh_xferdate]) as [Transfer Year],  
	ivh_invoicenumber as 'Invoice Number',
	ivh_hdrnumber as 'Invoice Header Number',
	'Y' as 'Invoiced', 
	ivh_billto as 'Bill To ID',
	'Bill To Name' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_billto = Company.cmp_id), 
	ivh_shipper as 'Shipper ID',
	'Shipper Name' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_shipper = Company.cmp_id),
	ivh_consignee as 'Consignee ID',
	'Consignee Name' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_consignee = Company.cmp_id),  
	ivh_order_by as 'Ordered By ID',
	'Other Type1-Ordered By' = (select Company.cmp_othertype1 from Company  WITH (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
	'Other Type2-Ordered By' = (select Company.cmp_othertype2 from Company  WITH (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
	'Ordered By' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
	(select cty_zip from city WITH (NOLOCK) where cty_code = ivh_origincity) as 'Origin Zip Code',
        (select cty_zip from city WITH (NOLOCK) where cty_code = ivh_destcity) as 'Dest Zip Code', 
	ivh_originstate as 'Origin State', 
	'Origin City State' = (select City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where invoiceheader.ivh_origincity = City.cty_code), 
	ivh_deststate as 'Destination State',
	'Destination City State' = (select City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where invoiceheader.ivh_destcity = City.cty_code), 
	invoiceheader.ivh_driver as 'Driver ID',
	'Driver Name' = IsNull((select mpp_lastfirst from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),''),
	'DrvType1' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1' and ivh_driver = mpp_id),''),
	'DrvType2' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2' and ivh_driver = mpp_id),''),
	'DrvType3' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3' and ivh_driver = mpp_id),''),
	'DrvType4' = IsNull((select name from labelfile WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4' and ivh_driver = mpp_id),''),
	ivh_tractor as 'Tractor',
	ivh_trailer as 'Trailer',
	invoiceheader.ivh_terms as 'Terms',
	'Master Bill To ID' = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ivh_billto),
	'Master Bill To' = (select cmp_name from company a WITH (NOLOCK) where a.cmp_id = (select cmp_mastercompany from company WITH (NOLOCK) where cmp_id = ivh_billto)), 
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
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Total Revenue',
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Line Haul Revenue',
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) - convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Accessorial Revenue',
	ivh_revtype1 as 'RevType1',
        'RevType1 Name' = IsNull((select name from labelfile WITH (NOLOCK)where labelfile.abbr = ivh_revtype1 and labeldefinition = 'RevType1'),''),
	ivh_revtype2 as 'RevType2',
        'RevType2 Name' = IsNull((select name from labelfile  WITH (NOLOCK)where labelfile.abbr = ivh_revtype2 and labeldefinition = 'RevType2'),''),
	ivh_revtype3 as 'RevType3',
        'RevType3 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ivh_revtype3 and labeldefinition = 'RevType3'),''),
	ivh_revtype4 as 'RevType4',
        'RevType4 Name' = IsNull((select name from labelfile  WITH (NOLOCK) where labelfile.abbr = ivh_revtype4 and labeldefinition = 'RevType4'),''),
	'Updated On Date' = (select max(lgh_updatedon) from legheader where legheader.ord_hdrnumber = invoiceheader.ord_hdrnumber),
        'PaperWork Received Date' =  (select max(pw_dt) from paperwork where pw_received = 'Y' and paperwork.ord_hdrnumber = invoiceheader.ord_hdrnumber),
	
        (select cmp_othertype1 from company where cmp_id = ivh_billto) as [Other Type 1],
        (select cmp_othertype2 from company where cmp_id = ivh_billto) as [Other Type 2],
	   (
	   convert(money,IsNull((select convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(a.ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))) from orderheader a where a.mov_number = invoiceheader.mov_number and a.ord_invoicestatus <> 'PPD'),0.00)) 
		+   
	   convert(money,IsNull((select convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(a.ivh_totalcharge,0)-(IsNull(a.ivh_taxamount1,0) + IsNull(a.ivh_taxamount2,0) + IsNull(a.ivh_taxamount3,0) + IsNull(a.ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0))) from invoiceheader a where a.mov_number = invoiceheader.mov_number),0.00))
            ) As 'Total Revenue For Movement',
	(select convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0))) from invoiceheader a where a.ord_hdrnumber = invoiceheader.ord_hdrnumber)
	      As 'Total Revenue For Order For Pay Allocation',	
        Case When ivh_hdrnumber = (select min(ivh_hdrnumber) from invoiceheader b WITH (NOLOCK) where invoiceheader.ord_hdrnumber = b.ord_hdrnumber and b.ord_hdrnumber <> 0) Then
	       convert(money,IsNull((select sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) from paydetail WITH (NOLOCK) where invoiceheader.mov_number = paydetail.mov_number and pyd_minus = 1),0.00)) 
        Else
	       convert(money,0.00)
	End as 'PayPerMove',
	OrderHasPayDetailsYN = IsNull((select Min('Y') from paydetail WITH (NOLOCK) where invoiceheader.ord_hdrnumber = paydetail.ord_hdrnumber and paydetail.ord_hdrnumber <> 0),'N'),
        MovementHasPayDetailsYN = IsNull((select Min('Y') from paydetail WITH (NOLOCK) where invoiceheader.mov_number = paydetail.mov_number and paydetail.mov_number <> 0),'N'),
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
	ivh_currencydate as 'Currency Date',
	IsNull(dbo.TMWSSRS_fnc_checkforvalidcurrencyconversion(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),'No Conversion Status Returned') as 'Revenue Currency Conversion Status',
	(select Min(cty_region1) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region1],
        (select Min(cty_region2) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region2],
        (select Min(cty_region3) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region3],
        (select Min(cty_region4) from city WITH (NOLOCK) Where ivh_origincity = cty_code) as [Origin Region4],
        (select Min(cty_region1) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region1],
        (select Min(cty_region2) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region2],
        (select Min(cty_region3) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region3],
        (select Min(cty_region4) from city WITH (NOLOCK) Where ivh_destcity = cty_code) as [Destination Region4],
	[Master Order Number]=(select ord_fromorder from orderheader WITH (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber),
	[Carrier ID] = IsNull(ivh_carrier,''),
			(	SELECT IsNull(convert(money,sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(ivd_charge,ivh.ivh_currency,'Revenue',ivd_number,ivd_currencydate,ivh.ivh_shipdate,ivh.ivh_deliverydate,ivh.ivh_billdate,ivh.ivh_revenue_date,ivh.ivh_xferdate,default,ivh.ivh_printdate,default,default,default),0.00))),0.00)
				FROM invoiceheader ivh
				JOIN invoicedetail ivd	ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
				JOIN chargetype cht	ON ivd.cht_itemcode = cht.cht_itemcode
				WHERE invoiceheader.ivh_invoicestatus <> 'CAN' 
				and invoiceheader.ivh_hdrnumber = ivh.ivh_hdrnumber
				AND (
					Upper(cht.cht_itemcode) like 'FUEL%'
					OR
					CharIndex('FUEL', cht_description)>0
					)
					and ivd_charge is Not Null
			) As 'Fuel Surcharge',
		'Driver Other ID' = IsNull((select mpp_otherid from manpowerprofile WITH (NOLOCK) where mpp_id = ivh_driver),'')

from    invoiceheader WITH (NOLOCK)

) as TempOrderInvoiceInformation
) as TempOrderInvoiceInformation2


GO
GRANT SELECT ON  [dbo].[vSSRSRB_OrderAndInvoiceInformation] TO [public]
GO
