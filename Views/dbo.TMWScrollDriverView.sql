SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollDriverView] AS
SELECT
mpp_id,
mpp_lastname,
mpp_firstname,
mpp_middlename,
mpp_lastfirst,
mpp_status,    -- Include Retired Drivers and Driver Status
mpp_otherid, 
mpp_tractornumber, 
mpp_type1,		
mpp_type2,
mpp_type3,
mpp_type4,
mpp_misc1,
mpp_misc2,
mpp_misc3,
mpp_misc4,
mpp_qualificationlist,
PlannedCity.cty_nmstct,
AvailableCity.cty_state,
mpp_zip,
AvailableCity.cty_county,
mpp_company,
mpp_prior_region1,
mpp_prior_region2,
mpp_prior_region3,
mpp_prior_region4,
mpp_terminal,
mpp_division,
mpp_teamleader,
mpp_fleet,
mpp_gps_latitude,
mpp_gps_longitude*-1 as 'mpp_gps_longitude',
ISNULL(mpp_exp1_date,'12/31/49') as mpp_exp1_date,
ISNULL(mpp_exp2_date,'12/31/49') as mpp_exp2_date,
mpp_avl_date,
mpp_last_home,
mpp_want_home,
mpp_domicile,
mpp_state,
mpp_hiredate		--PTS 65119 - DJM
FROM dbo.manpowerprofile with (NOLOCK) 
	INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('manpowerprofile', null) rsva ON (manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) 
	LEFT OUTER JOIN dbo.city (NOLOCK) ON dbo.manpowerprofile.mpp_city = dbo.city.cty_code 
	LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON dbo.manpowerprofile.mpp_avl_city = AvailableCity.cty_code 
	LEFT OUTER JOIN dbo.city PlannedCity (NOLOCK) ON dbo.manpowerprofile.mpp_pln_city = PlannedCity.cty_code
GO
GRANT DELETE ON  [dbo].[TMWScrollDriverView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollDriverView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollDriverView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollDriverView] TO [public]
GO
