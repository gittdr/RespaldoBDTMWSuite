SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[AOEScrollPendingEntriesView] AS
SELECT	record_type = 'Carrier',
		car_id 'ID',
		car_name 'Name',
		car_address1 'Address',
		c1.cty_nmstct 'City/State', 
		car_zip 'Zip', 
		car_phone1 'Phone',
		car_contact 'Contact',
		rowsec_rsrv_id
FROM	carrier a WITH (NOLOCK) LEFT JOIN 
		city c1 WITH (NOLOCK) ON a.cty_code = c1.cty_code
WHERE	a.car_status = 'OUT'
	UNION ALL
SELECT  record_type = 'Customer',
		cmp_id 'ID', 
		cmp_name 'Name',
		cmp_address1 'Address',
		city.cty_nmstct 'City/State',
		cmp_zip 'Zip',
		cmp_primaryphone 'Phone',
		cmp_contact 'Contact',
		rowsec_rsrv_id  
FROM	company WITH (NOLOCK) LEFT JOIN 
		city WITH (NOLOCK) ON company.cmp_city = city.cty_code
WHERE	cmp_active = 'N'
GO
GRANT INSERT ON  [dbo].[AOEScrollPendingEntriesView] TO [public]
GO
GRANT SELECT ON  [dbo].[AOEScrollPendingEntriesView] TO [public]
GO
GRANT UPDATE ON  [dbo].[AOEScrollPendingEntriesView] TO [public]
GO
