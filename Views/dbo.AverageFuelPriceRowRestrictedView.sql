SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[AverageFuelPriceRowRestrictedView] AS
SELECT	afp.*
FROM	dbo.averagefuelprice as afp WITH(NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('averagefuelprice', null) rsva on (rsva.rowsec_rsrv_id = afp.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)

GO
GRANT DELETE ON  [dbo].[AverageFuelPriceRowRestrictedView] TO [public]
GO
GRANT INSERT ON  [dbo].[AverageFuelPriceRowRestrictedView] TO [public]
GO
GRANT SELECT ON  [dbo].[AverageFuelPriceRowRestrictedView] TO [public]
GO
GRANT UPDATE ON  [dbo].[AverageFuelPriceRowRestrictedView] TO [public]
GO
