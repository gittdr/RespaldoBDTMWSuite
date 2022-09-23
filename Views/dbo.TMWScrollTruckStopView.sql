SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollTruckStopView] AS
SELECT 
dbo.TruckStops.*,
dbo.city.cty_nmstct, 
dbo.city.cty_latitude, 
dbo.city.cty_longitude 
FROM dbo.TruckStops LEFT OUTER JOIN dbo.city ON dbo.TruckStops.ts_cty = dbo.city.cty_code 

GO
GRANT DELETE ON  [dbo].[TMWScrollTruckStopView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollTruckStopView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollTruckStopView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollTruckStopView] TO [public]
GO
