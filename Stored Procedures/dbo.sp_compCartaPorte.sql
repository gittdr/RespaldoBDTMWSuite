SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera
Fecha: 30 NOV 2021 11:25 hrs
Version 1.0

Stored Proc que mandar a llamar al SP adecuado a la version necesaria 
para generar el complemento carta Porte CFDI

Recibe como parametro el numero de de legheader
dado que en una orden segmentado son varios los recursos involucrados.


Sentencia de prueba


exec sp_compCartaPorte 1212152

*/

CREATE proc [dbo].[sp_compCartaPorte]  @lgh_hdrnumber varchar(20)

as

--// procedimiento para detectar cuando un segmento pertenece a una orden segmentada

declare @numOrden int, @totSegmentos int, @letrainvoice char(1)
declare @Cliente varchar(20), @esunaorden bit, @esunafactura bit

--select @esunaorden   = 0
select @esunafactura = 0

--Si el argumento @lgh_hdrnumber < 1200000  and @lgh_hdrnumber > 1100000 se considera que es una orden

--if @lgh_hdrnumber < 1200000  and @lgh_hdrnumber > 1100000
--begin
--select @esunaorden = 1
--end
/*
if @lgh_hdrnumber >= 1330170 
begin
select @esunafactura = 1
end



if @esunafactura = 1
begin
	exec sp_compCartaPortev2_factura @lgh_hdrnumber	
end
Else
begin
*/
		--obtiene el cliente billto
		select @Cliente = isnull(oh.ord_billto,'N') from legheader lg, orderheader oh where 
		lg.ord_hdrnumber = oh.ord_hdrnumber and
		lg.lgh_number = @lgh_hdrnumber

		-- primero se obtiene el numero de orden
		select @numOrden = ord_hdrnumber from legheader where lgh_number = @lgh_hdrnumber;

		-- saca el numero de segmentos en la orden
		select @totSegmentos = count(*) from legheader where ord_hdrnumber = @numOrden;

		if @totSegmentos = 0 Return

		if @totSegmentos > 1 
			begin
				 exec sp_compCartaPortev2_OrdSegmentada @lgh_hdrnumber	
				 --select 'mas de 1'
			 end
			else
			begin
				if @Cliente = 'CUERVO' OR @Cliente = 'VERDVALL' OR @Cliente = 'DELAROSA' or @Cliente = 'PISA'-- and @lgh_hdrnumber =1272144

					begin
						exec sp_compCartaPortev2_conceptosfac @lgh_hdrnumber	
					end
				else
					begin
						exec sp_compCartaPortev2 @lgh_hdrnumber	
					end
				--select '1 segmento'
			end 
--end --fin de cuando no es orden
GO
