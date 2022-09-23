SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Obtiene_Stops_Orden_JC]
		@Ai_orden Integer,
		@Ai_Segmento Integer,
		@Av_cmd_code varchar(8), 
		@Av_cmd_description varchar(60),
		@Af_weight float, 
		@Av_weightunit varchar(6), 
		@Af_count float, 
		@Av_countunit varchar(6)
AS
DECLARE	
	@Vi_stop        integer,
	@Vi_consecutivo	integer
	

DECLARE @TTStopsdeOrden TABLE(
		TNumStop integer not NULL)
		

SET NOCOUNT ON

BEGIN --1 Principal
	-- Inserta en la tabla temporal la información qde los stops de la orden
		INSERT Into @TTStopsdeOrden

		SELECT  stp_number as stopnumber
		FROM    stops
		WHERE   lgh_number = @Ai_segmento
		and stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
		
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT TNumStop
		FROM @TTStopsdeOrden

		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @Vi_stop
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor Unidades_Cursor --3
		---
			exec dx_add_neworder_freight_to_stop 'I',@Vi_stop, @Av_cmd_code, @Av_cmd_description, @Af_weight, --5
			@Av_weightunit, @Af_count, @Av_countunit, null,null,--10
			null,null,null,null,null,null,null,null,null,1,--20 -- se pone 1 para borrar la mercancia existente
			null,null,null,null,null,@Vi_consecutivo   --26
  --      @validate char(1), 1
  --      @stp_number int,2
  --      @cmd_code varchar(8), 3
		--@cmd_description varchar(60),4
		--@weight float, 5
		--@weightunit varchar(6), 6
		--@count float, 7
		--@countunit varchar(6),8
		--@volume float, 9
		--@volumeunit varchar(6),10
  --      @fgt_reftype varchar(6), 11
		--@fgt_refnum varchar(30),12
		--@fgt_rate money, 13
		--@fgt_rateunit varchar(6), 14
		--@fgt_charge money,15
		--@fgt_length float, 16
		--@fgt_lengthunit varchar(6), 17
		--@fgt_width float, 18
		--@fgt_widthunit varchar(6),19
		--@fgt_height float, 20
		--@fgt_heightunit varchar(6),21
		--@count2 float, 22
		--@count2unit varchar(6),23
		--@fgt_actual_qty float,24
		--@fgt_actual_unit varchar(6),25
		--@@fgt_number int OUTPUT		26		
								

		FETCH NEXT FROM Posiciones_Cursor INTO  @Vi_stop
		
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 


END --1 Principal

GO
