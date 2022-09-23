SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para cambiar el peso de las ordenes maestras
--DROP PROCEDURE sp_cambiaPeso_maestrasALTO_JR
--GO

--exec sp_cambiaPeso_maestrasALTO_JR

CREATE  PROCEDURE [dbo].[sp_cambiaPeso_maestrasALTO_JR] 
AS
DECLARE	
	@V_orden		Integer,
	@V_Peso			Integer,
	@V_StopDRP		Integer,
	@V_StopPUP		Integer


DECLARE @TTdatosOrden TABLE(
		TT_orden		Int Null,
		TT_Peso			Int Null)



SET NOCOUNT ON

BEGIN --1 Principal
	-- Inserta en la tabla temporal la información que haya en la de paso 
	INSERT Into @TTdatosOrden
	select orden, peso
	from Tabla_paso_peso_JR 


	-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT TT_orden, TT_peso
		FROM @TTdatosOrden 
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @V_orden, @V_peso
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor ordenes

		-- Obtengo los stops minimos de la carga y la descarga

		select @V_StopPUP	=	min(stp_number) from stops where ord_hdrnumber = @V_orden and stp_type = 'PUP' and stp_paylegpt = 'Y' 
		select @V_StopDRP	=	min(stp_number) from stops where ord_hdrnumber = @V_orden and stp_type = 'DRP' and stp_paylegpt = 'Y' 

		
		Update Stops set stp_weight = @V_peso where ord_hdrnumber = @V_orden  and stp_number =  @V_StopPUP
		Update Stops set stp_weight = @V_peso where ord_hdrnumber = @V_orden  and stp_number =  @V_StopDRP

		Update Stops set stp_weight = 0 where ord_hdrnumber = @V_orden  and stp_number not in ( @V_StopDRP,@V_StopPUP)

		Update orderheader Set ord_totalweight = @V_peso  where ord_hdrnumber = @V_orden


		FETCH NEXT FROM Posiciones_Cursor INTO @V_orden, @V_peso



		END -- fin de la tabla tempo
	END
		
GO
