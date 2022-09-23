SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para cambiar el status de una orden a AVL
--DROP PROCEDURE sp_cambiastatus_SINPOD_JR
--GO

--exec sp_cambiastatus_SINPOD_JR 251026
--sp_help orderheader

CREATE  PROCEDURE [dbo].[sp_cambiastatus_SINPOD_JR] @No_orden int
AS


SET NOCOUNT ON

-- Si hay facturas ya de esa orden continua si no no pasa
	If ( SELECT count(*) FROM invoiceheader WHERE ord_hdrnumber = @No_orden) >= 2
	BEGIN 
		update orderheader set ord_invoicestatus = 'AVL' where ord_hdrnumber =	@No_orden;

		Select 'La orden ya tiene la factura en Disponible'	
	END
	Else
		BEGIN
		Select 'La orden necesita estar facturada y con nota de credito para continuar'	
		END 





GO
