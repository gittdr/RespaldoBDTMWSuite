SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[AOEScrollCompanyView] AS
SELECT  cmp_id 'Company ID'
		, cmp_name 'Company Name'
		, cmp_address1 'Address'
		, city.cty_nmstct 'City/State'
		, cmp_zip 'Zip'
		, cmp_primaryphone 'Phone'
		, cmp_contact 'Contact'
		, cmp_revtype1
		, cmp_revtype2		
		, cmp_revtype3		
		, cmp_revtype4		
		, rowsec_rsrv_id		
FROM	company with (NOLOCK) LEFT JOIN 
		city WITH (NOLOCK) ON company.cmp_city = city.cty_code
GO
GRANT INSERT ON  [dbo].[AOEScrollCompanyView] TO [public]
GO
GRANT SELECT ON  [dbo].[AOEScrollCompanyView] TO [public]
GO
GRANT UPDATE ON  [dbo].[AOEScrollCompanyView] TO [public]
GO
