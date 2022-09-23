SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Procedimiento para actualizar los segundos remolques

-- exec sp_Actualiza_SegundoRemolque_JR_2

CREATE PROCEDURE [dbo].[sp_Actualiza_SegundoRemolque_JR_2] 
AS

DECLARE @V_No_tractor VARCHAR(10), 
@V_No_remolque1  VARCHAR(10),
@V_No_remolque2  VARCHAR(10),
@V_No_Movimiento Numeric,
@V_No_rem1_int	Numeric,
@V_No_rem2_int	Numeric


DECLARE @MovsSinRem2 TABLE(
No_tractor   varchar(10),
No_remolque1 varchar(10),
No_remolque2 varchar(10),
No_Movimiento numeric null)



SET NOCOUNT ON

BEGIN --1 Principal

-- llena tabla de los stops
INSERT Into @MovsSinRem2 
select lgh_tractor, lgh_primary_trailer, lgh_primary_pup, lgh.mov_number 
from legheader lgh where lgh_class3 = 'TOL' and lgh_type1 = 'FULL' and lgh_outstatus = 'CMP' and lgh_startdate > '2018-05-01' and lgh_primary_pup = 'UNKNOWN' 
and (select count(stp_number) from  stops sp where sp.mov_number = lgh.mov_number and  trl_id2 is null)  > 0
--and lgh.mov_number = 591393
					

	-- Se declara un cursor para ir leyendo la tabla de los documentos
		DECLARE movimientos_Cursor CURSOR FOR 
		SELECT No_tractor, No_remolque1, No_remolque2, No_Movimiento
		FROM @MovsSinRem2 
	
		OPEN movimientos_Cursor 
		FETCH NEXT FROM movimientos_Cursor INTO @V_No_tractor, @V_No_remolque1, @V_No_remolque2, @V_No_Movimiento
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )

		BEGIN -- del cursor de los documentos
			-- Le suma uno al remolque primario
			select @V_No_rem1_int = CAST(@V_No_remolque1 as numeric)
			select @V_No_rem1_int = @V_No_rem1_int + 1

			select @V_No_remolque2 = CAST(@V_No_rem1_int as varchar(10))

			-- Actualiza LegHeader
			update legheader set lgh_primary_pup = @V_No_remolque2 where mov_number = @V_No_Movimiento

			-- Actualiza OrderHeader
			update orderheader set ord_trailer2 = @V_No_remolque2  where mov_number = @V_No_Movimiento

			-- Actualiza Tabla de Eventos
			Update event Set evt_trailer2 = @V_No_remolque2 
			Where stp_number in (select stp_number from  stops where mov_number = @V_No_Movimiento) 
			and evt_trailer1 = @V_No_remolque1 and evt_trailer2 = 'UNKNOWN' 

			-- Actualiza Tabla Stops
			update stops set trl_id2 = @V_No_remolque2 where mov_number = @V_No_Movimiento and trl_id = @V_No_remolque1 

			FETCH NEXT FROM movimientos_Cursor INTO  @V_No_tractor, @V_No_remolque1, @V_No_remolque2, @V_No_Movimiento
	
		END -- fin del cursor de los documentos
	close movimientos_Cursor
	DEALLOCATE movimientos_Cursor



END --1 Principal





GO
