SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Procedimiento para actualizar los Dollys

-- exec sp_Actualiza_Dolly_JR 

CREATE PROCEDURE [dbo].[sp_Actualiza_Dolly_JR] 
AS

DECLARE @V_DollyActual VARCHAR(15), 
@V_No_Movimiento Numeric, 
@V_No_Stop Numeric


DECLARE @StopsSinDolly TABLE(
No_Movimiento numeric null,
No_Stop numeric Null)

SET NOCOUNT ON

BEGIN --1 Principal

-- llena tabla de los stops
INSERT Into @StopsSinDolly 
SELECT evt_mov_number,  stp_number 
FROM event WHERE evt_trailer2 <> 'UNKNOWN' and evt_dolly = 'UNKNOWN' and evt_startdate > '2018-01-01' and evt_carrier = 'UNKNOWN'  order by 1


					

	-- Se declara un cursor para ir leyendo la tabla de los documentos
		DECLARE stops_Cursor CURSOR FOR 
		SELECT No_Movimiento, No_Stop
		FROM @StopsSinDolly 
	
		OPEN stops_Cursor 
		FETCH NEXT FROM stops_Cursor INTO @V_No_Movimiento, @V_No_Stop
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )

		BEGIN -- del cursor de los documentos
			-- Revisa si tienen dolly 

					SELECT @V_DollyActual = isNull(max(evt_dolly),'0') 
					FROM event where  evt_mov_number = @V_No_Movimiento and evt_dolly <> 'UNKNOWN'


					IF  @V_DollyActual <> '0'
					Begin

						update event set evt_dolly = @V_DollyActual  where  stp_number = @V_No_Stop

					End	
					Else
					begin
						update event set evt_dolly = 'D-01'  where  stp_number = @V_No_Stop
					end

			
	FETCH NEXT FROM stops_Cursor INTO @V_No_Movimiento, @V_No_Stop
	
	END -- fin del cursor de los documentos
	close stops_Cursor
	DEALLOCATE stops_Cursor



END --1 Principal





GO
