SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SP que sirve para obtener los billtos y las ordenes que tengan tarifa

--DROP PROCEDURE sp_reporte_billto_ordenesJR
--GO

--  exec sp_reporte_billto_ordenesJR

CREATE PROCEDURE [dbo].[sp_reporte_billto_ordenesJR]

AS
DECLARE	
	@V_Billto			Varchar(15),
	@V_OrdenesOciosas   Integer,
	@V_OrdenesCancel    Integer,
	@V_totalOrdenes		Integer,
	@V_totalOrdencero	Integer,
	@V_totalAccidentes	Integer,
	@V_Monto			Money,
	@V_descripcion		Varchar(50)

	
DECLARE @TTCompOrdenes TABLE(
		IDBillto	Varchar(15) NULL,
		totalOrdenes integer Null,
		OrdenesOciosas integer null,
		OrdenesCancel integer null,
		ordenesSinTarif integer Null,
		porcensintarifa	float null,
		totalaccidentes integer null,
		fechacreacion datetime null,
		hacemeses integer null)
		

SET NOCOUNT ON

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
INSERT Into @TTCompOrdenes
select cmp_id, 0,0,0,0,0,0,cmp_createdate, DATEDIFF(mm,cmp_createdate,GETDATE()) as antiguedadmeses
from company where  cmp_billto = 'Y' and cmp_active = 'Y'
 order by 6

		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT IDBillto
		FROM @TTCompOrdenes 
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @V_Billto
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor Unidades_Cursor --3
				
			--Hace el update
			select @V_totalOrdenes    = count(*) from orderheader where ord_status = 'CMP' and ord_billto = @V_Billto
			
			select @V_OrdenesOciosas    = count(*) from orderheader where ord_status not in ('CMP','MST','CAN')  and ord_billto = @V_Billto and datediff(day,ord_startdate,getdate()) > 3
			
			select @V_OrdenesCancel    = count(*) from orderheader where ord_status ='CAN'  and ord_billto = @V_Billto

			select @V_totalOrdencero  = count(*) from orderheader where  ord_status = 'CMP' and ord_billto = @V_Billto and isnull(tar_number,0)  = 0 and ord_completiondate >= '2016-01-01' and ord_status = 'CMP' and ord_completiondate < CONVERT(varchar, getdate(), 101)   and ord_invoicestatus = 'AVL'

			select @V_totalAccidentes = count(*) from tdrsilt..accidente_accidente where id_cliente_tmw = @V_Billto

			update @TTCompOrdenes set totalOrdenes = @V_totalOrdenes, OrdenesOciosas = @V_OrdenesOciosas, OrdenesCancel = @V_OrdenesCancel, ordenesSinTarif = @V_totalOrdencero, totalaccidentes = @V_totalAccidentes  where IDBillto  = @V_Billto


		FETCH NEXT FROM Posiciones_Cursor INTO @V_Billto
		
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 

	select IDBillto , totalOrdenes, OrdenesOciosas, isnull(OrdenesCancel,0) as OrdenesCancel, ordenesSinTarif, (cast(ordenesSinTarif  as float) / cast(totalOrdenes as float)) as PorcenSinTarifa , totalaccidentes, hacemeses from @TTCompOrdenes where totalOrdenes > 0 order by hacemeses asc
END --1 Principal



GO
