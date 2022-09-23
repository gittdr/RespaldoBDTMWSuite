SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TrailerProfileRowRestrictedView] AS
SELECT	trl.*
FROM	dbo.trailerprofile as trl WITH(NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('trailerprofile', null) rsva on (rsva.rowsec_rsrv_id = trl.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)

GO
GRANT DELETE ON  [dbo].[TrailerProfileRowRestrictedView] TO [public]
GO
GRANT INSERT ON  [dbo].[TrailerProfileRowRestrictedView] TO [public]
GO
GRANT SELECT ON  [dbo].[TrailerProfileRowRestrictedView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrailerProfileRowRestrictedView] TO [public]
GO
