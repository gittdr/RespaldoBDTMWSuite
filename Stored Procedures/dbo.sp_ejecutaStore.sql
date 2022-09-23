SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--use tmwSuite
--exec sp_ejecutaStore
--DROP PROCEDURE sp_ejecutaStore

--Procedimiento para verificar los cheques otorgados por Anticipo a operadores
	-- Algoritmo: Obtener los cheques por periodo
	--Verificar los cheques en la tabla de banco_cheque_detalle por número de cheque
	--para ver los movimientos
	--Verificar que estos movimientos se encuentren en la tabla de tmwSuite..paydetail y verificar el monto.

CREATE PROCEDURE [dbo].[sp_ejecutaStore] 
AS  
		

BEGIN --Principal 1
	exec sp_reporteoperaciones_int
	exec sp_reporteoperaciones_ded
	exec sp_reporteoperaciones_Esp
	exec sp_reporteoperaciones_abi
	exec sp_reporteoperaciones_ded_swat
	exec sp_reporteoperaciones_ded_optimizado
	exec sp_ejecutaPNFS
	
	--select * from v_operacionalResource

END --Principal 1


GO
