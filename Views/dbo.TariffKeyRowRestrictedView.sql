SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TariffKeyRowRestrictedView] AS
SELECT	trk.*
FROM	dbo.tariffkey as trk WITH(NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('tariffkey', null) rsva on (rsva.rowsec_rsrv_id = trk.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)

GO
GRANT DELETE ON  [dbo].[TariffKeyRowRestrictedView] TO [public]
GO
GRANT INSERT ON  [dbo].[TariffKeyRowRestrictedView] TO [public]
GO
GRANT SELECT ON  [dbo].[TariffKeyRowRestrictedView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TariffKeyRowRestrictedView] TO [public]
GO
