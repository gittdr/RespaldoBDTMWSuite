SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






--SP que sirve para recalcular los montos porque no los calcula corectamente.

--DROP PROCEDURE sp_recalcula_montos_fact_JR
--GO

--  exec sp_recalcula_montos_fact_JR 'SAYER'

CREATE PROCEDURE [dbo].[sp_recalcula_montos_fact_JR] @idcliente varchar(8)

AS
DECLARE	
	@V_orden			Integer,
	@V_factura			Varchar(10),
	@V_fact_IVA_hdr		decimal(18,3),
	@V_fact_IVA_det		decimal(18,3),
	@V_IVA_calc			decimal(18,3),
	@V_Total_fact		decimal(18,3)


DECLARE @TTmontosfactura TABLE(
		fact_orden		Int null,
		fact_invoice	Varchar(15) NULL,
		fact_total		decimal(18,3) Null,
		fact_IVA		decimal(18,3) Null,
		fact_Ret		decimal(18,3) Null,
		fact_IVA_det	decimal(18,3) Null,
		fact_Ret_det	decimal(18,3) Null,
		IVA_calc		decimal(18,3) Null,
		Ret_calc		decimal(18,3) Null)
-- fact_orden,fact_invoice, fact_total,fact_IVA,fact_Ret,fact_IVA_det,fact_Ret_det,IVA_calc,Ret_calc
SET NOCOUNT ON

BEGIN --1 Principal

IF (select cmp_inv_toll_detail from company with (nolock) where cmp_id = @idcliente ) = 'Y'  
	BEGIN
			-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
			INSERT Into @TTmontosfactura
			select ord_hdrnumber, ivh_invoicenumber, ivh_totalcharge, ivh_taxamount1, ivh_taxamount2,0,0,0,0 
			from invoiceheader where ivh_billto = @idcliente and ivh_mbstatus = 'RTP' and 
			ord_hdrnumber > 0


					-- Se declara un curso para ir leyendo la tabla de paso
					DECLARE Posiciones_Cursor CURSOR FOR 
					SELECT fact_orden, fact_invoice
					FROM @TTmontosfactura 
				
					OPEN Posiciones_Cursor 
					FETCH NEXT FROM Posiciones_Cursor INTO @V_orden, @V_Factura
					--Mientras la lectura sea correcta y el contador sea menos al total de registros
					WHILE (@@FETCH_STATUS = 0 )
					BEGIN -- del cursor Unidades_Cursor --3
						
					-- Toma el dato del iva qe tiene registrado la factura
					Select @V_fact_IVA_hdr = fact_IVA	From @TTmontosfactura  Where fact_orden = @V_orden and fact_invoice =  @V_Factura

						
					-- Obtiene Iva del Detalle.
					 select @V_fact_IVA_det = sum(ivd_charge) from invoicedetail where  cht_itemcode = 'GST' and ivh_hdrnumber = @V_Factura 
					--Insert into  Pruebasem (TEXTO) Values ( 'Entro iva M '+cast(@V_fact_IVA_hdr as Varchar(20)))
					--Insert into  Pruebasem (TEXTO) Values ( 'Entro iva D '+cast(@V_fact_IVA_det as Varchar(20)))

				
					-- verifica que haya diferencia entre los ivas del encabezado al detalle
					IF ABS(@V_fact_IVA_hdr -  @V_fact_IVA_det) > .001 or ABS(@V_fact_IVA_hdr -  @V_fact_IVA_det) is null 
					Begin
						-- Suma todos los conceptos del detalle.
						select @V_Total_fact = sum(ivd_charge) from invoicedetail where ivh_hdrnumber = @V_Factura		

						Update invoiceheader set  ivh_totalcharge = @V_Total_fact,  ivh_archarge	= @V_Total_fact	, ivh_taxamount1 = @V_fact_IVA_det	Where ivh_invoicenumber = @V_Factura

						--Insert into  Pruebasem (TEXTO) Values ( 'hace update '+cast(@V_Factura as Varchar(20)))
					End

					FETCH NEXT FROM Posiciones_Cursor INTO @V_orden, @V_Factura
				END --3 curso de los movimientos 

				CLOSE Posiciones_Cursor 
				DEALLOCATE Posiciones_Cursor 

			Select 'Fin Proceso Iva corregido solo Facturas en RTP Cte: '+@idcliente
		END
		Select 'Este Cliente '+@idcliente+', no debe de tener problema de iva'

END --1 Principal
GO
