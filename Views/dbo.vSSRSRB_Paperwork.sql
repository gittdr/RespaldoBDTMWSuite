SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_Paperwork] 
AS

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_Paperwork]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_Paperwork
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_Paperwork]

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
 ***********************************************************/

select 	
	ord_number as 'Order Number', 
	orderheader.mov_number as 'Move Number',
	ord_status as 'OrderStatus',
	ord_invoicestatus as 'InvoiceStatus',
	ord_bookdate as 'Booked Date',
    (Cast(Floor(Cast(ord_bookdate as float))as smalldatetime)) AS 'Booked Date Only',
    ord_bookedby as 'Booked By',
	ord_startdate as 'Ship Date',
    (Cast(Floor(Cast(ord_startdate as float))as smalldatetime)) AS 'Ship Date Only',
	ord_completiondate as 'Delivery Date',
    (Cast(Floor(Cast(ord_completiondate as float))as smalldatetime)) AS 'Delivery Date Only',
	Null as 'Bill Date',
	Null as 'Bill Date Only',
	Null as 'Revenue Date',
	Null as 'Revenue Date Only',
	Null as 'Transfer Date',
	Null as 'Transfer Date Only',
	'NI' as 'Invoice Number',
	'N' as 'Invoiced',
	ord_billto as 'Bill To ID', 
	'Bill To' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where orderheader.ord_billto = Company.cmp_id), 
	ord_shipper as 'Shipper ID',
	'Shipper' = (select Top 1 Company.cmp_name from Company  WITH (NOLOCK) where orderheader.ord_shipper = Company.cmp_id), 
	ord_consignee as 'Consignee ID',
	'Consignee' = (select Top 1 Company.cmp_name from Company  WITH (NOLOCK) where orderheader.ord_consignee = Company.cmp_id), 
	ord_company as 'Ordered By ID',
	'Ordered By' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where orderheader.ord_company = Company.cmp_id), 
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
	ord_currency as 'Currency',
	ord_revtype1 as 'RevType1',
    'RevType1 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype1 and labeldefinition = 'RevType1'),''),
	ord_revtype2 as 'RevType2',
	'RevType2 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype2 and labeldefinition = 'RevType2'),''),
	ord_revtype3 as 'RevType3',
	'RevType3 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype3 and labeldefinition = 'RevType3'),''),
	ord_revtype4 as 'RevType4',
    'RevType4 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ord_revtype4 and labeldefinition = 'RevType4'),''),
	'Updated On Date' = (select max(lgh_updatedon) from legheader WITH (NOLOCK) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber),
    abbr  as 'Paperwork',
	'Paperwork Name' = (select name from labelfile WITH (NOLOCK) where labeldefinition = 'Paperwork' and labelfile.abbr = paperwork.abbr), 
    pw_received as 'Paperwork ReceivedYN', 
    Paperwork.ord_hdrnumber as 'Order Header Number',
    pw_dt as 'Paperwork Received Date',
	lgh_number as [Leg Number],
	last_updatedby as [Last Updated By],
	last_updateddatetime as [Last Updated Date],
	ord_booked_revtype1 as 'Booked RevType1',
    '' as [Origin Country],
    '' as [Destination Country],
    (select cty_zip from city WITH (NOLOCK) where cty_code = ord_origincity) as 'Origin Zip Code',
    (select cty_zip from city WITH (NOLOCK) where cty_code = ord_destcity) as 'Dest Zip Code', 
	[Carrier Name] = (select top 1 car_name from assetassignment WITH (NOLOCK),carrier WITH (NOLOCK) where assetassignment.mov_number = orderheader.mov_number and asgn_type = 'CAR' and asgn_id = car_id),
	[Carrier ID] = (select top 1 asgn_id from assetassignment WITH (NOLOCK) where assetassignment.mov_number = orderheader.mov_number and asgn_type = 'CAR'), 
	'' as [Imaged]
FROM orderheader  WITH (NOLOCK)
JOIN Paperwork WITH (NOLOCK)
	ON orderheader.ord_hdrnumber = paperwork.ord_hdrnumber
WHERE orderheader.ord_hdrnumber NOT IN (select ord_hdrnumber from invoiceheader WITH (NOLOCK))

Union

select 	
	invoiceheader.ord_number as 'Order Number', 	
	invoiceheader.mov_number as 'Move Number', 
	orderheader.ord_status as 'OrderStatus', 
	invoiceheader.ivh_invoicestatus as 'InvoiceStatus',
	ord_bookdate as 'Booked Date',
    (Cast(Floor(Cast(ord_bookdate as float))as smalldatetime)) AS 'Booked Date Only',
	ord_bookedby as 'Booked By',
	ord_startdate as 'Ship Date',
    (Cast(Floor(Cast(ord_startdate as float))as smalldatetime)) AS 'Ship Date Only',
	ord_completiondate as 'Delivery Date',
    (Cast(Floor(Cast(ord_completiondate as float))as smalldatetime)) AS 'Delivery Date Only',
	ivh_billdate as 'Bill Date',
    (Cast(Floor(Cast(ivh_billdate as float))as smalldatetime)) AS 'Bill Date Only',
	ivh_revenue_date as 'Revenue Date',
    (Cast(Floor(Cast(ivh_revenue_date as float))as smalldatetime)) AS 'Revenue Date Only',
	ivh_xferdate as 'Transfer Date',
    (Cast(Floor(Cast(ivh_xferdate as float))as smalldatetime)) AS 'Transfer Date Only',
	ivh_invoicenumber as 'Invoice Number',
	'Y' as 'Invoiced', 
	ivh_billto as 'Bill To ID',
	'BillTo' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_billto = Company.cmp_id), 
	ivh_shipper as 'Shipper ID',
	'Shipper' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_shipper = Company.cmp_id),
	ivh_consignee as 'Consignee ID',
	'Consignee' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_consignee = Company.cmp_id),  
	ivh_order_by as 'Ordered By ID',
	'Ordered By' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_order_by = Company.cmp_id),
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
	ivh_currency as 'Currency',
	ivh_revtype1 as 'RevType1',
    'RevType1 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ivh_revtype1 and labeldefinition = 'RevType1'),''),
	ivh_revtype2 as 'RevType2',
    'RevType2 Name' = IsNull((select name from labelfile  WITH (NOLOCK) where labelfile.abbr = ivh_revtype2 and labeldefinition = 'RevType2'),''),
	ivh_revtype3 as 'RevType3',
    'RevType3 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = ivh_revtype3 and labeldefinition = 'RevType3'),''),
	ivh_revtype4 as 'RevType4',
    'RevType4 Name' = IsNull((select name from labelfile  WITH (NOLOCK) where labelfile.abbr = ivh_revtype4 and labeldefinition = 'RevType4'),''),
	'Updated On Date' = (select max(lgh_updatedon) from legheader where legheader.ord_hdrnumber = invoiceheader.ord_hdrnumber),
    abbr  as 'Paperwork',
	'Paperwork Name' = (select name from labelfile WITH (NOLOCK) where labeldefinition = 'Paperwork' and labelfile.abbr = paperwork.abbr), 
    pw_received as 'Paperwork ReceivedYN', 
    Paperwork.ord_hdrnumber as 'Order Header Number',
    pw_dt as 'Paperwork Received Date',
	lgh_number as [Leg Header Number],
	last_updatedby as [Last Updated By],
	last_updateddatetime as [Last Updated Date],
    '' as 'Booked RevType1',
    '' as [Origin Country],
    '' as [Destination Country],
	(select cty_zip from city WITH (NOLOCK) where cty_code = ivh_origincity) as 'Origin Zip Code',
    (select cty_zip from city WITH (NOLOCK) where cty_code = ivh_destcity) as 'Dest Zip Code', 
	[Carrier Name] = (select top 1 car_name from assetassignment WITH (NOLOCK),carrier WITH (NOLOCK) where assetassignment.mov_number = orderheader.mov_number and asgn_type = 'CAR' and asgn_id = car_id),
	[Carrier ID] = (select top 1 asgn_id from assetassignment WITH (NOLOCK) where assetassignment.mov_number = orderheader.mov_number and asgn_type = 'CAR'), 
	'' as [Imaged]
from orderheader WITH (NOLOCK)
JOIN invoiceheader WITH (NOLOCK)
	ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
JOIN paperwork WITH(NOLOCK)
	ON invoiceheader.ord_hdrnumber = paperwork.ord_hdrnumber
GO
GRANT SELECT ON  [dbo].[vSSRSRB_Paperwork] TO [public]
GO
