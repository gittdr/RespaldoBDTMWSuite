SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[ManpowerProfileRowRestrictedView] AS
SELECT	mpp.*
FROM	dbo.manpowerprofile as mpp WITH(NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('manpowerprofile', null) rsva on (rsva.rowsec_rsrv_id = mpp.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)

GO
GRANT DELETE ON  [dbo].[ManpowerProfileRowRestrictedView] TO [public]
GO
GRANT INSERT ON  [dbo].[ManpowerProfileRowRestrictedView] TO [public]
GO
GRANT SELECT ON  [dbo].[ManpowerProfileRowRestrictedView] TO [public]
GO
GRANT UPDATE ON  [dbo].[ManpowerProfileRowRestrictedView] TO [public]
GO
