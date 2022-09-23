SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[AOEScrollTrailerView] AS
SELECT
trl_number 'Trailer #',
trl_id 'Trailer ID',
cmp_id 'Company',
trl_company 'Company Name',
trl_division 'Division',
trl_fleet 'Fleet',
trl_terminal 'Terminal',
trl_owner 'Owner',
trl_status 'Status',
trl_year 'Year',
trl_make 'Make',
trl_model 'Model',
trl_type1,
trl_type2,
trl_type3,
trl_type4,
PlannedCity.cty_nmstct 'PLN City/State', 
AvailableCity.cty_state 'AVL State',
trl_avail_cmp_id 'AVL Company',
rowsec_rsrv_id
FROM dbo.trailerprofile (NOLOCK) LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON dbo.trailerprofile.trl_avail_city = AvailableCity.cty_code 
						LEFT OUTER JOIN dbo.city PlannedCity (NOLOCK) ON dbo.trailerprofile.trl_next_city = PlannedCity.cty_code 
WHERE trl_status <> 'OUT'
GO
GRANT INSERT ON  [dbo].[AOEScrollTrailerView] TO [public]
GO
GRANT SELECT ON  [dbo].[AOEScrollTrailerView] TO [public]
GO
GRANT UPDATE ON  [dbo].[AOEScrollTrailerView] TO [public]
GO
