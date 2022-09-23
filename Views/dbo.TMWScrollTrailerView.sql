SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollTrailerView] AS
SELECT
trl_number,
trl_id,
cmp_id,
trl_company,
trl_division,
trl_fleet,
trl_terminal,
trl_owner,
trl_status,
trl_licstate,
trl_licnum,
trl_serial,
trl_make,
trl_model,
trl_year,
trl_type1,
trl_type2,
trl_type3,
trl_type4,
trl_misc1,
trl_misc2,
trl_misc3,
trl_misc4,
AvailableCity.cty_nmstct, 
AvailableCity.cty_state,
AvailableCity.cty_zip, 
AvailableCity.cty_county, 
trl_prior_region1,
trl_prior_region2,
trl_prior_region3,
trl_prior_region4,
trl_avail_cmp_id,
trl_gps_latitude,
trl_gps_longitude*-1 as 'trl_gps_longitude',
ISNULL(trl_exp1_date,'12/31/49') as trl_exp1_date,
ISNULL(trl_exp2_date,'12/31/49') as trl_exp2_date

FROM	dbo.trailerprofile (NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('trailerprofile', null) rsva ON (trailerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) 
		LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON IsNull(dbo.trailerprofile.trl_avail_city, 0) = AvailableCity.cty_code 
GO
GRANT DELETE ON  [dbo].[TMWScrollTrailerView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollTrailerView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollTrailerView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollTrailerView] TO [public]
GO
