SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para revisar las liquidaciones en donde se mezclan mas operadores
--DROP PROCEDURE sp_reporte_liq_erroneas_JR
--GO

--exec sp_reporte_liq_erroneas_JR
--sp_help orderheader

CREATE PROCEDURE [dbo].[sp_reporte_liq_erroneas_JR]
AS

DECLARE @TTLiquidaciones TABLE(
		TTL_NoLiquidacion		Int Null,
		TTL_CantidadOpe			Int Null)

DECLARE @TTLiquidaciones_mal TABLE(
		TTL_NoLiquidacion_mal		Int Null,
		TTL_CantidadOpe_mal			Int Null)


Declare
	@NoLiquidacion Int

SET NOCOUNT ON

BEGIN --1 Principal
	-- Inserta en la tabla temporal la información que haya en la de paso 
	INSERT Into @TTLiquidaciones
	select pyh_number, count(distinct(asgn_id)) 
	From paydetail 
	Where  pyh_payperiod > '2018-01-01' and pyh_number > 0 
	group by pyh_number
	order by 2 desc

	Insert Into @TTLiquidaciones_mal
	select TTL_NoLiquidacion, TTL_CantidadOpe
	From @TTLiquidaciones
	Where TTL_CantidadOpe > 1



	-- Se declara un curso para ir leyendo la tabla de paso
		--DECLARE Liquidaciones_Cursor CURSOR FOR 
		--SELECT TTL_NoLiquidacion_mal
		--FROM @TTLiquidaciones_mal
			
		--OPEN Liquidaciones_Cursor 
		--FETCH NEXT FROM Liquidaciones_Cursor INTO @NoLiquidacion

		--Mientras la lectura sea correcta y el contador sea menos al total de registros
--		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor ordenes

		-- Obtengo el paydetail de las ordenes
		
		select PH.asgn_id, PH.pyh_pyhnumber,PH.pyh_payperiod, PD.asgn_id, PD.ord_hdrnumber, PD.mov_number, PD.pyt_itemcode, PD.pyd_amount, PD.pyd_description 
		from payheader PH , paydetail PD
		where PH.pyh_pyhnumber = PD.pyh_number and PH.pyh_pyhnumber in (SELECT TTL_NoLiquidacion_mal FROM @TTLiquidaciones_mal) and PH.asgn_id <> PD.asgn_id
		and PH.pyh_pyhnumber not in (128806, 130942, 131235,133031, 133363, 131308)
		Order by 3 desc


		

	--	FETCH NEXT FROM Liquidaciones_Cursor INTO @NoLiquidacion



		END -- fin de la tabla tempo
	END



GO
