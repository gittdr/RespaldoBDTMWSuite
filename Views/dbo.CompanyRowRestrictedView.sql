SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[CompanyRowRestrictedView] AS
SELECT	cmp.*
FROM	dbo.company as cmp WITH(NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('company', null) rsva on (rsva.rowsec_rsrv_id = cmp.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)

GO
GRANT DELETE ON  [dbo].[CompanyRowRestrictedView] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyRowRestrictedView] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyRowRestrictedView] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyRowRestrictedView] TO [public]
GO
