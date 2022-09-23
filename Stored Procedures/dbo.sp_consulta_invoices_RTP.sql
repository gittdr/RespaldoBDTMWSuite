SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Procedimiento para leer las invoices que estan en Ready to Print 
-- y 

--DROP PROCEDURE sp_consulta_invoices_RTP
--GO

--exec sp_consulta_invoices_RTP 'SAYER'

CREATE  PROCEDURE [dbo].[sp_consulta_invoices_RTP] @a_billto varchar(8)
AS

DECLARE	
	@V_Numfactura varchar(10),
	@V_subtotal	 decimal(9,4),
	@V_casetas	 decimal(9,4),
	@V_iva		 decimal(9,4),
	@V_retencion decimal(9,4),
	@V_Orden    integer

Declare @TTFacturas Table (
		Numfactura varchar(10) null)

DECLARE @TTtotales TABLE(
		orden			integer null,
		factura			varchar(10) null,
		subtotal		decimal(9,4) null,
		casetas			decimal(9,4) null,
		iva 			decimal(9,4) null,
		retencion		decimal(9,4) null,
		total			decimal(9,4) null)

SET NOCOUNT ON


Insert Into @TTFacturas select ivh_invoicenumber from invoiceheader where  ivh_billto = @a_billto and ivh_mbstatus = 'RTP' 




-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTFacturas )
	BEGIN 
	-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT Numfactura
		FROM @TTFacturas 
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @V_numfactura
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- del cursor Unidades_Cursor --3
		--SELECT @V_numfactura

			-- IVA
			select @V_iva = isnull(sum(ivd_charge),0) from invoicedetail where ivh_hdrnumber in (@V_numfactura)and cht_itemcode = 'GST'
			-- RETENCION
			select @V_retencion = isnull(sum(ivd_charge),0) from invoicedetail where ivh_hdrnumber in (@V_numfactura)	and cht_itemcode = 'PST'
			-- Casetas
			select @V_casetas = isnull(sum(ivd_charge),0) from invoicedetail where ivh_hdrnumber in (@V_numfactura) and cht_itemcode in ('TOLL','CAS','CASRET','CASIVA')

			select @V_subtotal = isnull(sum(ivd_charge),0) from invoicedetail where ivh_hdrnumber in (@V_numfactura) and cht_itemcode in ('VIAJE','LHF')
			-- Obtiene la Orden

			select @V_Orden = isnull(ord_hdrnumber,0) from invoiceheader where ivh_invoicenumber in (@V_numfactura) 

			Insert @TTtotales Values (@V_Orden,@V_numfactura,@V_subtotal, @V_casetas, @V_iva,@V_retencion,(@V_subtotal+@V_casetas+@V_iva+@V_retencion))

			FETCH NEXT FROM Posiciones_Cursor INTO @V_numfactura
	
	END
	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 


END

select orden,factura, subtotal, casetas, iva, retencion, total from @TTtotales
GO
