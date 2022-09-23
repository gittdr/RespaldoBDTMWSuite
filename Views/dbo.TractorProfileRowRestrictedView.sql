SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TractorProfileRowRestrictedView] AS
SELECT	trc.*
FROM	dbo.tractorprofile as trc WITH(NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('tractorprofile', null) rsva on (rsva.rowsec_rsrv_id = trc.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)

GO
GRANT DELETE ON  [dbo].[TractorProfileRowRestrictedView] TO [public]
GO
GRANT INSERT ON  [dbo].[TractorProfileRowRestrictedView] TO [public]
GO
GRANT SELECT ON  [dbo].[TractorProfileRowRestrictedView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TractorProfileRowRestrictedView] TO [public]
GO
