SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para actualizar con 1 kilometro el dato de las invoices del cliente liverpool del proyecto KFD y en status HLD
--DROP PROCEDURE Sp_actualiza_kms_liverpool_JR
--GO

--exec Sp_actualiza_kms_liverpool_JR
--sp_help orderheader

CREATE PROCEDURE [dbo].[Sp_actualiza_kms_liverpool_JR] 
AS

--update invoiceheader set ivh_totalmiles = 1 where ivh_billto = 'LIVERPOL' and ivh_invoicestatus = 'HLD' and ivh_revtype3 = 'KFD' and ivh_totalmiles = 0 and left(ivh_invoicenumber,1) <> 'S'
SET NOCOUNT ON

-- Si hay facturas ya de esa orden continua si no no pasa
	If ( select count(*) from invoiceheader where ivh_billto = 'LIVERPOL' and ivh_mbstatus = 'RTP' and ivh_revtype3 = 'KFD' and ivh_totalmiles = 0 and left(ivh_invoicenumber,1) <> 'S') > 0
	BEGIN 
		update invoiceheader set ivh_totalmiles = 1 where ivh_billto = 'LIVERPOL' and ivh_mbstatus = 'RTP' and ivh_revtype3 = 'KFD' and ivh_totalmiles = 0 and left(ivh_invoicenumber,1) <> 'S'

		Select 'Las facturas ya tienen kms'	
	END
	Else
		BEGIN
		Select 'No existen facturas del cte liverpool, status HLD y proyecto KFD'	
		END 


--select count(*) from invoiceheader where ivh_billto = 'LIVERPOL' and ivh_mbstatus = 'RTP' and ivh_revtype3 = 'KFD' and ivh_totalmiles = 0 and left(ivh_invoicenumber,1) <> 'S'




GO
