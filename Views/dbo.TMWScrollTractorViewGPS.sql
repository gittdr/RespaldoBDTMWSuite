SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollTractorViewGPS] AS
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
isnull(trc_gps_latitude/3600.0, AvailableCity.cty_latitude) 'trc_gps_latitude',
isnull(trc_gps_longitude/3600.0, AvailableCity.cty_longitude) 'trc_gps_longitude',
'TRACTOR_BLUE' As 'trc_icon',
'<b>' + trc_number + '</b> - ' + trc_driver as 'trc_info' 

FROM dbo.tractorprofile (NOLOCK) LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON dbo.tractorprofile.trc_avl_city = AvailableCity.cty_code 
					    LEFT OUTER JOIN dbo.city PlannedCity (NOLOCK) ON dbo.tractorprofile.trc_pln_city = PlannedCity.cty_code 
						
GO
GRANT DELETE ON  [dbo].[TMWScrollTractorViewGPS] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollTractorViewGPS] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollTractorViewGPS] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollTractorViewGPS] TO [public]
GO
