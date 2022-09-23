SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[qdi_day_close_by_invoice] (@invnumb VARCHAR(15))
AS
   EXECUTE ps_to_e_invoices_by_invoice @invnumb 
   EXECUTE ps_to_e_AccessorialHist_by_invoice @invnumb 
   EXECUTE ps_to_e_ProdQtys_by_invoice @invnumb 
   EXECUTE ps_to_e_RoutingHistory_by_invoice @invnumb 
   EXECUTE ps_to_e_StopTimes_by_invoice @invnumb 
GO
GRANT EXECUTE ON  [dbo].[qdi_day_close_by_invoice] TO [public]
GO
