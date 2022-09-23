SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollTractorView] AS
SELECT 
trc_number, 
trc_type1,
trc_driver,
trc_status,
trc_company,
trc_terminal,
trc_division,
trc_owner,
trc_fleet,
trc_licstate,
trc_licnum,
trc_serial,
trc_model,  
trc_make, 
trc_year, 
trc_type2,
trc_type3,
trc_type4,
trc_misc1,
trc_misc2,
trc_misc3,
trc_misc4,
PlannedCity.cty_nmstct, 
AvailableCity.cty_state,
AvailableCity.cty_zip, 
AvailableCity.cty_county, 
trc_avl_cmp_id,
trc_prior_region1,
trc_prior_region2,
trc_prior_region3,
trc_prior_region4,
trc_gps_latitude,
trc_gps_longitude*-1 as 'trc_gps_longitude',
ISNULL(trc_exp1_date,'12/31/49') as 'trc_exp1_date',
ISNULL(trc_exp2_date,'12/31/49') as 'trc_exp2_date',
trc_driver2,
trc_engineserial

FROM	dbo.tractorprofile (NOLOCK)
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('tractorprofile', null) rsva ON (tractorprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)  
		LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON dbo.tractorprofile.trc_avl_city = AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city PlannedCity (NOLOCK) ON dbo.tractorprofile.trc_pln_city = PlannedCity.cty_code 
						
GO
GRANT DELETE ON  [dbo].[TMWScrollTractorView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollTractorView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollTractorView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollTractorView] TO [public]
GO
