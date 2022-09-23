SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera
modif: Juan Ramon
Fecha: 30 NOV 2021 11:25 hrs
fecha modif 14 ENE 2022 10.00 hrs
Version 1.0

Stored Proc que mandar a llamar al SP adecuado a la version necesaria 
para generar el complemento carta Porte CFDI

Recibe como parametro el numero de de legheader
dado que en una orden segmentado son varios los recursos involucrados.


Sentencia de prueba


exec sp_compCartaPorte 1212152
sp_compCartaPortev2_OrdSegmentada 1212152

[sp_compCartaPorte_pruebasJR] 1240280
*/

CREATE proc [dbo].[sp_compCartaPorte_pruebasJR]  @lgh_hdrnumber varchar(20)

as
--// procedimiento para detectar cuando un segmento pertenece a una orden segmentada

declare @numOrden int, @totSegmentos int

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
		exec sp_compCartaPortev2 @lgh_hdrnumber	
		--select '1 segmento'
	end
GO
