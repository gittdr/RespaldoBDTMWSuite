SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec sp_obtiene_ordenes_sayercasetas_JR

CREATE PROCEDURE [dbo].[sp_obtiene_ordenes_sayercasetas_JR] 
AS

DECLARE	
	@V_registros	integer,
	@V_i			Integer,
	@V_consecutivo	Integer,	
	@V_Orden			Integer
		

DECLARE @TTOrddenesSayer TABLE(TT_NoOrden	Integer null)
		
SET NOCOUNT ON

BEGIN --1 Principal

INSERT Into @TTOrddenesSayer 
		select ord_hdrnumber from orderheader where ord_billto in ('SAYER') and ord_status = 'CMP' and ord_invoicestatus = 'AVL'


-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTOrddenesSayer )
	BEGIN --3 Si hay movimientos de posiciones
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE ordenes_Cursor CURSOR FOR 
		SELECT TT_NoOrden
		FROM @TTOrddenesSayer
			
		OPEN ordenes_Cursor 
		FETCH NEXT FROM ordenes_Cursor INTO @V_orden

		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor abastecer_Cursor --3
		


		 exec sp_act_casetasykms_sayer_JR @V_orden
		 



			FETCH NEXT FROM ordenes_Cursor INTO @V_orden
		END --3 cursor del stops_Cursor

	CLOSE ordenes_Cursor 
	DEALLOCATE ordenes_Cursor 
END -- 2 si hay movimientos del RC


delete From @TTOrddenesSayer

INSERT Into @TTOrddenesSayer 
		select ord_hdrnumber from orderheader where ord_billto in ('SAYFUL') and ord_status = 'CMP' and ord_invoicestatus = 'AVL'

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTOrddenesSayer )
	BEGIN --3 Si hay movimientos de posiciones
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE ordenes_Cursor CURSOR FOR 
		SELECT TT_NoOrden
		FROM @TTOrddenesSayer
			
		OPEN ordenes_Cursor 
		FETCH NEXT FROM ordenes_Cursor INTO @V_orden

		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor abastecer_Cursor --3
		


		 exec sp_act_casetasykms_sayerfull_JR @V_orden



			FETCH NEXT FROM ordenes_Cursor INTO @V_orden
		END --3 cursor del stops_Cursor

	CLOSE ordenes_Cursor 
	DEALLOCATE ordenes_Cursor 
END -- 2 si hay movimientos del RC
delete From @TTOrddenesSayer

INSERT Into @TTOrddenesSayer 
		select ord_hdrnumber from orderheader where ord_billto in ('liverded') and ord_status = 'CMP' and ord_invoicestatus = 'AVL'

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTOrddenesSayer )
	BEGIN --3 Si hay movimientos de posiciones
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE ordenes_Cursor CURSOR FOR 
		SELECT TT_NoOrden
		FROM @TTOrddenesSayer
			
		OPEN ordenes_Cursor 
		FETCH NEXT FROM ordenes_Cursor INTO @V_orden

		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor abastecer_Cursor --3
		


		 exec sp_act_casetasykms_LIVERDED_JR @V_orden



			FETCH NEXT FROM ordenes_Cursor INTO @V_orden
		END --3 cursor del stops_Cursor

	CLOSE ordenes_Cursor 
	DEALLOCATE ordenes_Cursor 
END -- 2 si hay movimientos del RC




delete From @TTOrddenesSayer

INSERT Into @TTOrddenesSayer 
		select ord_hdrnumber from orderheader where ord_billto in ('SAYER') and ord_status = 'CMP' and ord_invoicestatus = 'PPD' AND ord_hdrnumber IN (SELECT ord_hdrnumber FROM invoiceheader where ivh_billto = 'SAYER' and ivh_invoicestatus = 'HLD')

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTOrddenesSayer )
	BEGIN --3 Si hay movimientos de posiciones
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE ordenes_Cursor CURSOR FOR 
		SELECT TT_NoOrden
		FROM @TTOrddenesSayer
			
		OPEN ordenes_Cursor 
		FETCH NEXT FROM ordenes_Cursor INTO @V_orden

		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor abastecer_Cursor --3
		


		 --exec sp_act_casetasykms_sayerfull_JR @V_orden
		 --actualiza iva 
		 UPDATE invoicedetail
		 SET ivd_charge =(select round(SUM(ivd_charge)*0.16,2) from invoicedetail where ord_hdrnumber = @V_orden and  cht_itemcode in('LHF','VIAJE','TOLL'))
		 WHERE cht_itemcode = 'GST' AND ord_hdrnumber = @V_orden

		 update invoiceheader
		 set ivh_totalcharge = (SELECT sum(ivd_charge) FROM invoicedetail WHERE ord_hdrnumber = @V_orden),
		 ivh_taxamount1 = (SELECT sum(ivd_charge) FROM invoicedetail WHERE ord_hdrnumber = @V_orden and cht_itemcode = 'GST'),
		 ivh_taxamount3 = (SELECT sum(ivd_charge) FROM invoicedetail WHERE ord_hdrnumber = @V_orden and cht_itemcode = 'GST'),
		 ivh_taxamount4 = (SELECT sum(ivd_charge) FROM invoicedetail WHERE ord_hdrnumber = @V_orden and cht_itemcode = 'GST')
		 where ord_hdrnumber = @V_orden


			FETCH NEXT FROM ordenes_Cursor INTO @V_orden
		END --3 cursor del stops_Cursor

	CLOSE ordenes_Cursor 
	DEALLOCATE ordenes_Cursor 
END -- 2 si hay movimientos del RC



END --1 Principal
GO
