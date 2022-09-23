SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create View [dbo].[vSSRSRB_InvoiceDetailNotes]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_InvoiceDetailNotes
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data for InvoiceDetailNotes
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Created 
 **/

Select vSSRSRB_InvoiceDetails.*,
       OrderNotes = dbo.fnc_SSRRS_OrderNotes([Order Header Number])

From   vSSRSRB_InvoiceDetails

GO
GRANT SELECT ON  [dbo].[vSSRSRB_InvoiceDetailNotes] TO [public]
GO
