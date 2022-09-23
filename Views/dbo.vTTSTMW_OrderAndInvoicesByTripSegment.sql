SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO









CREATE         View [dbo].[vTTSTMW_OrderAndInvoicesByTripSegment]



As


Select *
From   vTTSTMW_UnbilledOrdersByTripSegment

Union

Select *
From    vTTSTMW_InvoicesByTripSegment










































































GO
