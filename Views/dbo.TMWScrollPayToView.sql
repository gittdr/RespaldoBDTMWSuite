SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollPayToView] AS
	SELECT
			pto.*, 
			dbo.city.cty_nmstct, 
			dbo.city.cty_latitude, 
			dbo.city.cty_longitude 
	FROM	dbo.PayToRowRestrictedView pto
			LEFT OUTER JOIN dbo.city (NOLOCK) ON pto.pto_city = dbo.city.cty_code 

GO
GRANT DELETE ON  [dbo].[TMWScrollPayToView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollPayToView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollPayToView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollPayToView] TO [public]
GO
