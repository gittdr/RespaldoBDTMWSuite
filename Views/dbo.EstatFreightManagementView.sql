SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[EstatFreightManagementView]
as 	select
		'TMWWF_ESTAT_ACTIVE' as 'TMWWF_ESTAT_ACTIVE',
		(select top 1 ref_number from referencenumber where ref_type='SO' and ord_hdrnumber=o.ord_hdrnumber order by [timestamp] desc) 'SO Number',
		(select top 1 ref_number from referencenumber where ref_type='PO' and ord_hdrnumber=o.ord_hdrnumber order by [timestamp] desc) 'PO Number',
		(select top 1 ref_number from referencenumber where ref_type='GLCODE' and ord_hdrnumber=o.ord_hdrnumber order by [timestamp] desc) 'GL Code',
		o.ord_status 'Indicator',
		cmp_ship.cmp_name 'Source Location Name',
		cty_ship.cty_name 'Source City',
		cty_ship.cty_state 'Source State',
		cty_ship.cty_zip 'Source Zip',
		o.ord_startdate 'Start Time',
		cmp_cons.cmp_name 'Destination Location Name',
		cty_cons.cty_name 'Destination City',
		cty_cons.cty_state 'Destination State',
		cty_cons.cty_zip 'Destination Zip',
		o.ord_completiondate 'End Time',
		o.trl_type1 'Mode',
		o.ord_totalweight 'Total Gross Weight',
		o.ord_charge 'Total Actual Cost',
		car.car_name 'Service Provider',
		o.ord_number 'Shipment ID',
		o.ord_number,
		o.ord_hdrnumber,
		o.ord_status 'DispStatus',
		o.ord_startdate 'StartDate',
		o.ord_billto 'BillToID',
    	o.ord_company 'OrderByID', 	
		cmp_ship.cmp_id 'PickupID',
		cmp_cons.cmp_id 'ConsigneeID'
	from orderheader o
		inner join company cmp_ship on cmp_ship.cmp_id = o.ord_shipper
		inner join city cty_ship on cty_ship.cty_code = cmp_ship.cmp_city
		inner join company cmp_cons on cmp_cons.cmp_id = o.ord_consignee
		inner join city cty_cons on cty_cons.cty_code = cmp_cons.cmp_city
		left join legheader leg on leg.ord_hdrnumber = o.ord_hdrnumber
		left join carrier car on car.car_id = leg.lgh_carrier
GO
GRANT INSERT ON  [dbo].[EstatFreightManagementView] TO [public]
GO
GRANT SELECT ON  [dbo].[EstatFreightManagementView] TO [public]
GO
GRANT UPDATE ON  [dbo].[EstatFreightManagementView] TO [public]
GO
