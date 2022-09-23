SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[PayToRowRestrictedView] AS
SELECT	pto.*
FROM	dbo.payto as pto WITH(NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('payto', null) rsva on (rsva.rowsec_rsrv_id = pto.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)

GO
GRANT DELETE ON  [dbo].[PayToRowRestrictedView] TO [public]
GO
GRANT INSERT ON  [dbo].[PayToRowRestrictedView] TO [public]
GO
GRANT SELECT ON  [dbo].[PayToRowRestrictedView] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayToRowRestrictedView] TO [public]
GO
