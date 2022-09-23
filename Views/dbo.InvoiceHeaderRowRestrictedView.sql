SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[InvoiceHeaderRowRestrictedView] AS
SELECT	ivh.*
FROM	dbo.invoiceheader as ivh WITH(NOLOCK) 
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('invoiceheader', null) rsva on (rsva.rowsec_rsrv_id = ivh.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)

GO
GRANT DELETE ON  [dbo].[InvoiceHeaderRowRestrictedView] TO [public]
GO
GRANT INSERT ON  [dbo].[InvoiceHeaderRowRestrictedView] TO [public]
GO
GRANT SELECT ON  [dbo].[InvoiceHeaderRowRestrictedView] TO [public]
GO
GRANT UPDATE ON  [dbo].[InvoiceHeaderRowRestrictedView] TO [public]
GO
