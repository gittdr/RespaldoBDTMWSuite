SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[EstatTenderedOrdersViewFuel]
as select 
	'TMWWF_ESTAT_TENDERED' as 'TMWWF_ESTAT_TENDERED',
    ord.ord_number 'ord_number' , 	
	scompany.cmp_id 'PickupID',
	scompany.cmp_name 'PickupName',
	scity.cty_name 'PickupCity',
	scity.cty_state 'PickupState',
	ccompany.cmp_id 'ConsigneeID',
	ccompany.cmp_name 'ConsigneeName',
	ccity.cty_name 'ConsigneeCity',
	ccity.cty_state 'ConsigneeState',
    	(select cmp_name from company where cmp_id = ord.ord_billto) 'BillTo',	
	ord.ord_billto 'BillToID',
    	(select cmp_name from company where cmp_id = ord.ord_company) 'OrderBy',
    	ord.ord_company 'OrderByID', 
	ord.ord_revtype1 'RevType1', ord.ord_revtype2 'RevType2', ord.ord_revtype3 'RevType3', ord.ord_revtype4 'RevType4',	
	ord.ord_hdrnumber  'ord_hdrnumber',
	ord.ord_description 'Remark',			
	ord.ord_status 'DispStatus',
	ord.ord_startdate 'StartDate', 
	ord.ord_completiondate 'EndDate',
	fgt1.fgt_description 'Commodity1',
	fgt1.fgt_volume 'Gross1', 
	fgt2.fgt_supplier 'Supplier2',
	fgt2.fgt_description 'Commodity2',
	fgt2.fgt_volume 'Gross2', 
	fgt3.fgt_supplier 'Supplier3',
	fgt3.fgt_description 'Commodity3',
	fgt3.fgt_volume 'Gross3', 
	fgt4.fgt_supplier 'Supplier4',
	fgt4.fgt_description 'Commodity4',
	fgt4.fgt_volume 'Gross4', 
	ISNULL(scompany.cmp_latseconds/3600.0, scity.cty_latitude) 'PickupLatitude',
	ISNULL(scompany.cmp_longseconds/3600.0, scity.cty_longitude) 'PickupLongitude',
	ISNULL(ccompany.cmp_latseconds/3600.0, ccity.cty_latitude) 'ConsigneeLatitude',
	ISNULL(ccompany.cmp_longseconds/3600.0, ccity.cty_longitude) 'ConsigneeLongitude'
from orderheader as ord
		join city as scity on ord.ord_origincity = scity.cty_code
		join company as scompany on ord.ord_originpoint = scompany.cmp_id
		join city as ccity on ord.ord_destcity = ccity.cty_code
		join company as ccompany on ord_destpoint = ccompany.cmp_id
		left outer join legheader leg with (nolock)on leg.mov_number = ord.mov_number
		left outer join freightdetail fgt1 with (nolock) on fgt1.stp_number = leg.stp_number_end and fgt1.fgt_sequence = 1
		left outer join freightdetail fgt2 with (nolock) on fgt2.stp_number = leg.stp_number_end and fgt2.fgt_sequence = 2 
		left outer join freightdetail fgt3 with (nolock) on fgt3.stp_number = leg.stp_number_end and fgt3.fgt_sequence = 3
		left outer join freightdetail fgt4 with (nolock) on fgt4.stp_number = leg.stp_number_end and fgt4.fgt_sequence = 4
where ord.ord_status = 'TND'
GO
GRANT INSERT ON  [dbo].[EstatTenderedOrdersViewFuel] TO [public]
GO
GRANT SELECT ON  [dbo].[EstatTenderedOrdersViewFuel] TO [public]
GO
GRANT UPDATE ON  [dbo].[EstatTenderedOrdersViewFuel] TO [public]
GO
