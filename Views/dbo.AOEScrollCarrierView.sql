SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[AOEScrollCarrierView] AS
SELECT
	car_id 'Carrier ID',
	car_name 'Carrier Name',
	car_status 'Status',
	car_address1 'Address',
	city.cty_nmstct 'City/State', 
	car_zip 'Zip',	
	car_phone1 'Phone',
	car_contact 'Contact',
	car_scac 'SCAC',
	car_type1,
	car_type2,
	car_type3,
	car_type4,
	rowsec_rsrv_id
FROM carrier with (NOLOCK) LEFT JOIN city WITH (NOLOCK) ON carrier.cty_code = city.cty_code
WHERE car_status<>'OUT'
GO
GRANT INSERT ON  [dbo].[AOEScrollCarrierView] TO [public]
GO
GRANT SELECT ON  [dbo].[AOEScrollCarrierView] TO [public]
GO
GRANT UPDATE ON  [dbo].[AOEScrollCarrierView] TO [public]
GO
