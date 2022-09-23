SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[OrderHeaderRowRestrictedView] AS
SELECT	oh.*
FROM	dbo.orderheader as oh WITH(NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('orderheader', null) rsva on (rsva.rowsec_rsrv_id = oh.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)

GO
GRANT DELETE ON  [dbo].[OrderHeaderRowRestrictedView] TO [public]
GO
GRANT INSERT ON  [dbo].[OrderHeaderRowRestrictedView] TO [public]
GO
GRANT SELECT ON  [dbo].[OrderHeaderRowRestrictedView] TO [public]
GO
GRANT UPDATE ON  [dbo].[OrderHeaderRowRestrictedView] TO [public]
GO
