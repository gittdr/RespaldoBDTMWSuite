SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[AOEScrollTractorView] AS
SELECT 
trc_number 'Tractor', 
trc_driver 'Driver',
trc_status 'Status',
trc_company 'Company',
trc_terminal 'Terminal',
trc_division 'Division',
trc_owner 'Owner',
trc_fleet 'Fleet',
trc_year 'Year',
trc_make 'Make',
trc_model 'Model',  
trc_type1,
trc_type2,
trc_type3,
trc_type4,
PlannedCity.cty_nmstct 'PLN City/State', 
AvailableCity.cty_state 'AVL State',
trc_avl_cmp_id 'AVL Company',
rowsec_rsrv_id
FROM dbo.tractorprofile (NOLOCK) LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON dbo.tractorprofile.trc_avl_city = AvailableCity.cty_code 
					    LEFT OUTER JOIN dbo.city PlannedCity (NOLOCK) ON dbo.tractorprofile.trc_pln_city = PlannedCity.cty_code 
WHERE trc_status<>'OUT'
GO
GRANT INSERT ON  [dbo].[AOEScrollTractorView] TO [public]
GO
GRANT SELECT ON  [dbo].[AOEScrollTractorView] TO [public]
GO
GRANT UPDATE ON  [dbo].[AOEScrollTractorView] TO [public]
GO
