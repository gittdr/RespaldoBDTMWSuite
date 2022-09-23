SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollStopView] AS
SELECT 
dbo.stops.*, 
dbo.city.cty_nmstct, 
dbo.company.cmp_latseconds,
dbo.company.cmp_longseconds,
(select ord_BelongsTo from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) as [ord_BelongsTo],
(select rowsec_rsrv_id from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) as [ord_rowsec_rsrv_id]
FROM dbo.stops (NOLOCK) 
	LEFT OUTER JOIN dbo.city (NOLOCK) ON dbo.stops.stp_city = dbo.city.cty_code 
	LEFT OUTER JOIN dbo.company (NOLOCK) ON dbo.stops.cmp_id = dbo.company.cmp_id
	
GO
GRANT DELETE ON  [dbo].[TMWScrollStopView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollStopView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollStopView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollStopView] TO [public]
GO
