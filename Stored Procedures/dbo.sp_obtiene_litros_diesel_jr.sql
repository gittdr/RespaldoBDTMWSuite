SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--DROP PROCEDURE [sp_obtiene_litros_diesel_jr]
--GO

--exec sp_obtiene_litros_diesel_jr 370555, 'SAY',27,388862, @ai_litros, @ld_rend_acumulado

CREATE  PROCEDURE [dbo].[sp_obtiene_litros_diesel_jr] @No_movimiento as integer, @as_proyecto as varchar(10), @ai_toneladas as integer, @no_lghnumber as integer, 
													 @V_descarga as varchar(60), @ai_litros as integer output ,@ld_rend_acumulado	as float output, @ai_kms_oper as integer output
AS

DECLARE	
	@V_registros	integer,
	@V_i			Integer,
	@V_consecutivo	Integer,	
	@V_Mov			Integer, 
	@V_proyecto		char(6),		
	@V_Peso			Integer, 
	@V_lghnnumber	Integer,
	@V_estatus		char(1),
	@V_cantidad		float,
	@V_costo		float,
	@v_evento		char(6),
	@v_tractor		char(8),
	@v_trailer1		char(13),
	@v_trailer2		char(13),			
	@v_motor		char(10),
	@v_kms_stop		integer,
	@v_kms_acumulado integer,
	@ls_tipoevento	char(6),
	@v_ejesunidad	Integer, 
	@v_ejescaja1	Integer, 
	@v_ejescaja2	Integer,
	@v_ejestot		Integer,
	@ld_rend_vacio	float,
	@ld_rend_cargado float,
	@litrosstop		Integer,
	@ld_rendelegido	float
		

DECLARE @TTstopsxmovs TABLE(
		TT_evento			char(6) null,
		TT_tractor			char(8) null,
		TT_trailer1			char(13) NULL,
		TT_trailer2			char(13) NULL,
		TT_motor			char(10) NULL,
		TT_kms				Integer null,
		TT_codigoevento		Char(50) Null,
		TT_tipoevento		Char(6) null,
		TT_lghnumber		integer null)
		
SET NOCOUNT ON

BEGIN --1 Principal
-- Inserta en la tabla temporal la información de los insumos para capas
--print 'lghnumber '+cast(@no_lghnumber as varchar(10))
--print 'movimiento '+cast(@No_movimiento as varchar(10))
select @ai_litros			= 0.00
select @ld_rend_acumulado	= 0.00
select @ai_kms_oper			= 0
Select @as_proyecto			= Rtrim(@as_proyecto)+'-P'
Select @V_descarga			= Rtrim(@V_descarga)
Select @V_descarga			= Ltrim(@V_descarga)

--print 'proyecto '+cast(@as_proyecto as varchar(10))

INSERT Into @TTstopsxmovs 
		select  eve.evt_eventcode, isnull(eve.evt_tractor,'UNK') tractor, isnull(eve.evt_trailer1,'UNK') trailer1, isnull(eve.evt_trailer2,'UNK') trailer2, 
				tra.trc_enginemake, isnull(sto.stp_lgh_mileage,0) kms, evt.name, evt.mile_typ_to_stop, sto.lgh_number
			from TMWSUITE..event eve, TMWSUITE..stops sto, TMWSUITE..tractorprofile tra,  TMWSUITE..eventcodetable evt
			WHERE eve.stp_number = sto.stp_number and 
				  eve.evt_tractor = tra.trc_number and sto.stp_event = evt.abbr and
				  sto.mov_number = @No_movimiento and sto.lgh_number = @no_lghnumber


-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTstopsxmovs )
	BEGIN --3 Si hay movimientos de posiciones
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE stops_Cursor CURSOR FOR 
		SELECT TT_evento, TT_tractor,  TT_trailer1, TT_trailer2, TT_motor, TT_kms, TT_tipoevento
		FROM @TTstopsxmovs 
	
		OPEN stops_Cursor 
		FETCH NEXT FROM stops_Cursor INTO @v_evento, @v_tractor, @v_trailer1, @v_trailer2, @v_motor, @v_kms_stop, @ls_tipoevento

		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor abastecer_Cursor --3
			

			-- Obtiene los ejes de la orden...
				IF @v_tractor <> 'UNK'  and @v_tractor <> 'UNKNOWN'  and @v_tractor  <> '0'  
					select @v_ejesunidad = trc_axles 
					from TMWSUITE..tractorprofile 
					where trc_number = @v_tractor;
					if 	@v_ejesunidad is null  	select	@v_ejesunidad = 0
				
	
				IF @v_trailer1 <> 'UNK' and @v_trailer1 <> 'UNKNOWN'  and @v_trailer1 <> '0'    
					select @v_ejescaja1 = trl_axles  
					from TMWSUITE..trailerprofile 
					where trl_id = @v_trailer1;
					if @v_ejescaja1 is null		select @v_ejescaja1   = 0
						
				IF @v_trailer2 <> 'UNK' and @v_trailer2 <> 'UNKNOWN'  and @v_trailer2 <> '0'
					select @v_ejescaja2 = trl_axles  
					from TMWSUITE..trailerprofile 
					where trl_id = @v_trailer2;
					select @v_ejescaja2   = @v_ejescaja2+2
					IF @v_ejescaja2 is null	select @v_ejescaja2   = 0
				
				select @v_ejestot	= @v_ejesunidad	+ @v_ejescaja1	+ @v_ejescaja2
				-- se asigna el rendimiento dependiendo del lugar de descarga

				IF @V_descarga = 'IXTAPALUCA,EM/'
				begin
					select @ld_rend_vacio	= 1.75
					select @ld_rend_cargado = 1.75
				end
				IF @V_descarga = 'NICOLAS ROMERO,EM/Mex'
				begin
					select @ld_rend_vacio	= 2.10
					select @ld_rend_cargado = 2.10
				end
				IF @V_descarga = 'ORIZABA,VZ/'
				begin
					select @ld_rend_vacio	= 1.71
					select @ld_rend_cargado = 1.71
				end

					--select	@ld_rend_vacio		=  fec_mpg_empty, 
					--		@ld_rend_cargado	=  fec_mpg_loaded 
					--from TMWSUITE..fueleconomy 
					--where 
					--fec_region		= @as_proyecto and 
					--fec_engine		= @v_motor and 
					--fec_num_axles	= @v_ejestot and 
					--fec_min_weight <= @ai_toneladas and 
					--fec_max_weight >= @ai_toneladas;

					--print '@as_proyecto '+cast(@as_proyecto as varchar(10))
					--print '@v_motor '+cast(@v_motor as varchar(14))
					--print '@v_ejestot '+cast(@v_ejestot as varchar(10))
					--print '@ai_toneladas '+cast(@ai_toneladas as varchar(10))


					 IF @ld_rend_vacio is null or  @ld_rend_cargado is null
						begin
								select @ld_rend_acumulado	=	0.00
							--	select @ld_rend_vacio		=	0.00
								select @ai_litros			=	0.00
							--	select @ld_rend_vacio		=	0.00
							--	select @ld_rend_cargado		=	0.00
								return
						end 


						--Dependiendo del evento toma el rendimiento de vacio o de cargado...
							IF @ls_tipoevento = 'LD' 
								begin
									select @litrosstop		=	@v_kms_stop / @ld_rend_cargado
									select @ld_rendelegido	=	@ld_rend_cargado
									--print 'litros LD '+cast(@litrosstop as varchar(4))
									--print 'rendelegido LD '+cast(@ld_rendelegido as varchar(4))
								end 
							ELSE
								begin
									select @litrosstop		=	@v_kms_stop / @ld_rend_vacio
									select @ld_rendelegido	=   @ld_rend_vacio
									--print 'litros em '+cast(@litrosstop as varchar(4))
									--print 'rendelegido em '+cast(@ld_rendelegido as varchar(4))
								end	
					select @ai_litros			=	@ai_litros + @litrosstop
					select @ld_rend_acumulado	=	@ld_rend_acumulado + @ld_rendelegido
					Select @v_kms_acumulado		=	@v_kms_acumulado + @v_kms_stop 
					
			FETCH NEXT FROM stops_Cursor INTO @v_evento, @v_tractor, @v_trailer1, @v_trailer2, @v_motor, @v_kms_stop, @ls_tipoevento
		END --3 cursor del stops_Cursor
		select @ld_rend_acumulado	= @ld_rend_acumulado/(Select count(*) From  @TTstopsxmovs )
		Select @ai_kms_oper			=	@v_kms_acumulado

					--print '@ai_litros fin '+cast(@ai_litros as varchar(4))
					--print '@ld_rend_acumulado fin '+cast(@ld_rend_acumulado as varchar(4))	
					--print '@ai_kms_oper fin '+cast(@ai_kms_oper as varchar(4))

	CLOSE stops_Cursor 
	DEALLOCATE stops_Cursor 
END -- 2 si hay movimientos del RC
END --1 Principal
GO
