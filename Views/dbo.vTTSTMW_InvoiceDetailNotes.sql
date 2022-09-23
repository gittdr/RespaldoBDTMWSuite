SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE View [dbo].[vTTSTMW_InvoiceDetailNotes]

As

Select vTTSTMW_InvoiceDetails.*,
       OrderNotes = dbo.fnc_TMWRN_OrderNotes([Order Header Number])

From   vTTSTMW_InvoiceDetails




GO
GRANT SELECT ON  [dbo].[vTTSTMW_InvoiceDetailNotes] TO [public]
GO
