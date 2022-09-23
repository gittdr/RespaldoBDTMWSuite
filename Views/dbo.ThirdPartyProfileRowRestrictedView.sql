SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[ThirdPartyProfileRowRestrictedView] AS
SELECT	tpr.*
FROM	dbo.thirdpartyprofile as tpr WITH(NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('thirdpartyprofile', null) rsva on (rsva.rowsec_rsrv_id = tpr.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)

GO
GRANT DELETE ON  [dbo].[ThirdPartyProfileRowRestrictedView] TO [public]
GO
GRANT INSERT ON  [dbo].[ThirdPartyProfileRowRestrictedView] TO [public]
GO
GRANT SELECT ON  [dbo].[ThirdPartyProfileRowRestrictedView] TO [public]
GO
GRANT UPDATE ON  [dbo].[ThirdPartyProfileRowRestrictedView] TO [public]
GO
