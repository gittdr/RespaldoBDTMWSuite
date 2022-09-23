SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








--SP que sirve para obtener los datos de las invoices con estatus HLD del cliente a consultar

--DROP PROCEDURE sp_datosfactura_montos_JR
--GO

--  exec sp_datosfactura_montos_JR 'LIVERPOL'

CREATE PROCEDURE [dbo].[sp_datosfactura_montos_JR] @idcliente varchar(8)

AS
DECLARE	
	@V_orden			Integer,
	@V_factura		Varchar(10)


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
				
			--Hace el Update de los datos el iva y de la retencion que tiene el detalle.
			-- Iva del Detalle
			Update @TTmontosfactura set fact_IVA_det =
				(select sum(ivd_charge) from invoicedetail where  cht_itemcode = 'GST' and ivh_hdrnumber = @V_Factura )
			where fact_orden = @V_orden and fact_invoice =  @V_Factura
			-- Retencion del detalle
			Update @TTmontosfactura set fact_Ret_det =
				(select sum(ivd_charge) from invoicedetail where  cht_itemcode = 'PST' and ivh_hdrnumber = @V_Factura )
			where fact_orden = @V_orden and fact_invoice =  @V_Factura


			-- IVA detalle calculado
		Update @TTmontosfactura set IVA_calc = (
					select Sum(ivd_charge)*.16 from invoicedetail ID, chargetype CT 
					where  ID.cht_itemcode not in ('GST','PST') and CT.cht_itemcode = ID.cht_itemcode 
					 and ID.ivh_hdrnumber = @V_Factura and cht_taxtable1 = 'Y')
		where fact_orden = @V_orden and fact_invoice =  @V_Factura

			-- RETENCION Detallle calculado
		Update @TTmontosfactura set Ret_calc = (
			select sum(ivd_charge)*.04 from invoicedetail ID, chargetype CT 
			where  ID.cht_itemcode not in ('GST','PST') and CT.cht_itemcode = ID.cht_itemcode 
			 and ID.ivh_hdrnumber = @V_Factura and cht_taxtable2 = 'Y')
		where fact_orden = @V_orden and fact_invoice =  @V_Factura

		FETCH NEXT FROM Posiciones_Cursor INTO @V_orden, @V_Factura
		
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 


Select fact_orden,fact_invoice, fact_total,fact_IVA,fact_IVA_det,IVA_calc,  (fact_IVA -  fact_IVA_det),
(fact_IVA -  IVA_calc)     from @TTmontosfactura 
--where ABS(fact_IVA -  fact_IVA_det) > 2 or ABS(fact_IVA -  fact_IVA_det) is null


END --1 Principal










GO
