SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[AOEScrollDriverView] AS
SELECT
mpp_id 'Driver ID',
mpp_lastname 'Last Name',
mpp_firstname 'First Name',
mpp_status 'Status',    -- Include Retired Drivers and Driver Status
mpp_tractornumber 'Tractor', 
mpp_type1,		
mpp_type2,
mpp_type3,
mpp_type4,
PlannedCity.cty_nmstct 'PLN City/State',
AvailableCity.cty_state 'AVL State',
rowsec_rsrv_id
FROM dbo.manpowerprofile with (NOLOCK) LEFT OUTER JOIN dbo.city (NOLOCK) ON dbo.manpowerprofile.mpp_city = dbo.city.cty_code 
									   LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON dbo.manpowerprofile.mpp_avl_city = AvailableCity.cty_code 
									   LEFT OUTER JOIN dbo.city PlannedCity (NOLOCK) ON dbo.manpowerprofile.mpp_pln_city = PlannedCity.cty_code		
WHERE mpp_status<>'OUT'
GO
GRANT INSERT ON  [dbo].[AOEScrollDriverView] TO [public]
GO
GRANT SELECT ON  [dbo].[AOEScrollDriverView] TO [public]
GO
GRANT UPDATE ON  [dbo].[AOEScrollDriverView] TO [public]
GO
