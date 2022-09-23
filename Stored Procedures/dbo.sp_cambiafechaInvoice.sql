SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec sp_cambiafechaInvoice


CREATE  PROCEDURE [dbo].[sp_cambiafechaInvoice] 
AS


SET NOCOUNT ON

-- Si hay facturas ya de esa orden continua si no no pasa
	If ( select count(*) from invoiceheader (nolock) where ivh_invoicestatus = 'PRN' and datediff(d,ivh_billdate, ivh_printdate)  > 0) > 0
	BEGIN 
		update invoiceheader set ivh_billdate = ivh_printdate  where ivh_invoicestatus = 'PRN' and datediff(d,ivh_billdate, ivh_printdate)  > 0

		Select 'Se actualizo la fecha de impresión de las facturas'
	END
	Else
		BEGIN
		Select 'No hay facturas por actualizar'	
		END 





GO
