SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollCompanyView] AS
SELECT
	company.*,
	city.cty_latitude,
	city.cty_longitude 
FROM	dbo.Company (NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('Company', null) rsva ON (Company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		LEFT OUTER JOIN dbo.City (NOLOCK) ON dbo.Company.cmp_city = dbo.City.cty_code
GO
GRANT DELETE ON  [dbo].[TMWScrollCompanyView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollCompanyView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollCompanyView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollCompanyView] TO [public]
GO
