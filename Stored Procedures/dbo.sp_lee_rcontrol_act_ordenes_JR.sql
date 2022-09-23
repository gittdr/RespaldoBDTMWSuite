SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los registros de Registro Confiable  y que actualize las ordenes

-- exec sp_lee_rcontrol_act_ordenes_JR

CREATE PROCEDURE [dbo].[sp_lee_rcontrol_act_ordenes_JR]
AS
DECLARE	
	@V_idregistro 		Integer, 
	@V_Mensaje			Varchar(50),
	@V_fecha			Datetime, 
	@V_fechaanterior	Datetime,
	@V_cliente			Varchar(20),
	@V_Cteanterior		Varchar(20),
	@V_Unidad			Varchar(10),
	@limovimiento		Int ,
	@limovimiento_Sig	Int,
	@lstpnumber			Int,
	@num_stop			Int,
	@li_maxstop			Int,
	@li_totalstopsig	Int,
	@li_maxstopsig		Int,
	@kmsdelstop			Int,
	@li_hrs				float,
	@V_fechaF			Datetime,
	@V_fechamsg			Datetime,
	@li_i				Int,
	@V_cty_origen		Int,
	@V_cty_destino		Int,
	@V_cmp_origen		Varchar(10),
	@V_cmp_destino		Varchar(10),
	@li_minutos1		Int,
	@li_minutos2		Int,
	@err				Int,
	@v_bandera			Int,
	@V_stp_event		Varchar(8),
	@V_ord_number		Varchar(12),
	@V_nota				Varchar(200),
	@V_Kmstiempoenmin	Int,
	@V_operador			Varchar(8),
	@V_ubicacion		Varchar(100),
	@V_CK_ubicacion		Varchar(200)

DECLARE @TTRegistros_RC TABLE(
		RC_idregistro	Integer not null,
		RC_mensaje		Varchar(50) Null,
		RC_fecha		DateTime null,
		RC_cliente		Varchar(20) NULL,
		RC_unidad		Varchar(20) Null,
		RC_Operador		Varchar(8) Null,
		RC_Ubicacion	Varchar(100) Null)

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de actividades...
INSERT Into @TTRegistros_RC 
	SELECT 
		MRC.id_folio,
		MRC.tipo_mov, 
		MRC.fecha_mov, 
		CRC.tmw_company_id,
		IsNull(MP.mpp_tractornumber,'XXX') unidad,
		MP.mpp_id,
		MRC.ubicacion
	FROM	QSP..movimientos_RC MRC (NOLOCK) , 
			manpowerprofile MP,
			company_RC CRC
	Where	fecha_mov > '11-26-2012' and 
			right(MRC.RFC_operador,10) = MP.mpp_misc3 and 
			MP.mpp_status <> 'OUT' and
			CRC.rc_nombre_cmp = MRC.ubicacion and 
			MRC.idevento Is Null and
			MP.mpp_tractornumber in ('1124','91014','91137','9881','91143',
'91145','91126','9914','1151')
	order by 3

		-- Si hay movimientos en la tabla continua
		If Exists ( Select count(*) From  @TTRegistros_RC )
		BEGIN --2 Si hay mensajes
				DECLARE QFSactividad_Cursor CURSOR FOR 
				SELECT RC_idregistro, RC_mensaje, RC_fecha, RC_cliente, RC_unidad,RC_operador, RC_Ubicacion
				FROM   @TTRegistros_RC 
			
				OPEN QFSactividad_Cursor 
				FETCH NEXT FROM QFSactividad_Cursor INTO @V_idregistro, @V_mensaje, @V_fecha, @V_cliente, @V_unidad, @V_operador, @V_ubicacion
				WHILE @@FETCH_STATUS = 0 
			BEGIN --3 del cursor Unidades_Cursor
				SELECT @V_mensaje = LTrim(@V_mensaje)
				SELECT @V_mensaje = RTrim(@V_mensaje)
				-- Marca la actividad de ya leida
				Update QSP..movimientos_RC Set idevento = 2 where  QSP..movimientos_RC.id_folio = @V_idregistro
				-- Toma el cuerpo del mensaje para identificar si es una macro.
				IF @V_mensaje = 'RCENT' OR  @V_mensaje = 'RCSAL'
				BEGIN --4 identificar @V_mensaje
					IF NOT @V_cliente Is Null 
					BEGIN -- 5 Cuando tiene Alias
						Exec sp_obtiene_movimiento_jr @V_unidad, 'CAN','CMP', @limovimiento out, @V_ord_number out
						--print 'Mov '+convert(varchar(10),@limovimiento)
						IF @limovimiento > 0 
						BEGIN --6 Cuando encontro Numero de Orden
							IF @V_mensaje = 'RCENT' 
							BEGIN -- 7  Cuando va entrando IN
							SELECT @lstpnumber  = IsNull(Min(stp_mfh_sequence),0) FROM Tmwsuite..stops Where 	mov_number = @limovimiento and cmp_id = @V_cliente  and stp_OOA_stop	= 0 --and  stp_status = 'OPN' 
								 IF @lstpnumber > 0
									BEGIN --7.1 Cuando va entrando y existe el Stop.
											-- Valida que entre la antepenultima y la actual entrada sean diferente compañia
											-- si en caso de ser la misma pregunta por el tiempo que sea mayor a 30 min para actualizar el dato
											--	print 'stop '+convert(varchar(10),@lstpnumber)
												Exec sp_get_datos_RC_ant_JR @limovimiento, @V_unidad, @V_idregistro,@lstpnumber, @V_fechaanterior Out, @V_Cteanterior Out, @V_Kmstiempoenmin Out
												--print 'fecha ant '+convert(varchar(25),@V_fechaanterior)
												--print 'fecha nueva  '+convert(varchar(25),@V_fecha)

												--print 'min  '+convert(varchar(10),@V_Kmstiempoenmin)
												--print 'dif  '+convert(varchar(10),DateDiff(mi,@V_fechaanterior, @V_fecha))

												IF @V_Cteanterior <> @V_cliente OR (DateDiff(mi,@V_fechaanterior, @V_fecha) > @V_Kmstiempoenmin)
--												IF DateDiff(mi,@V_fechaanterior, @V_fecha) > @V_Kmstiempoenmin
												BEGIN --7.09
														 Select @V_stp_event = stp_event FROM Tmwsuite..stops Where mov_number = @limovimiento and stp_mfh_sequence = @lstpnumber 
														 Select @V_stp_event = convert(varchar(3),@lstpnumber)+'-'+@V_stp_event

														 exec @err = sp_act_stops_entrada_JR @V_fecha, @limovimiento, @lstpnumber

														--IF @err = 0 Update QSP..QFSActivity Set procesado = 'Si' where  QSP..QFSActivity.idActivity = @V_idactividad
														--IF @err = 0 Update QSP..QFSActivity Set movimiento = @limovimiento, compañia = @V_cliente, evento = @V_stp_event  where  QSP..QFSActivity.idActivity = @V_idactividad
	
														Select @V_nota			=  'RC Ent  a '+ @V_cliente +' -> '+left(right(Convert(varchar(25),@V_fecha,120),14),11)+'->'+ @V_stp_event
														Select @V_CK_ubicacion	=  'RC Ent a '+ @V_ubicacion

														IF @err = 0 exec dx_add_note 'orderheader', @V_ord_number, 0,0, @V_nota, 'N',null,''
														IF @err = 0 exec sp_inserta_checkcal_RC_JR  @V_operador, @V_fecha, 'RCENT', @V_CK_ubicacion, @V_unidad
												END -- 7.09

									End -- 7.1cuando va entrando y existe el stop
								


							End --7cuando va entrando
							IF @V_mensaje = 'RCSAL'
								Begin --8 cuando va saliendo
									Select @v_bandera = 1
									--Update QSP..QFSActivity Set movimiento = @limovimiento, compañia = @V_cliente where  QSP..QFSActivity.idActivity = @V_idactividad
									SELECT @lstpnumber	= IsNull(MAX(stp_mfh_sequence),0)
									FROM Tmwsuite..stops 
									Where 	mov_number	= @limovimiento and 
											stp_status	= 'DNE' and 
											cmp_id		= @V_cliente
									IF @lstpnumber > 0
									BEGIN --8.1cuando va saliendo y existe el Stop
											Select @V_stp_event = stp_event FROM Tmwsuite..stops Where 	mov_number = @limovimiento and stp_mfh_sequence = @lstpnumber 
											Select @V_stp_event = convert(varchar(3),@lstpnumber)+'-'+@V_stp_event

										/*SELECT @lstpnumber	= IsNull(Max(stp_mfh_sequence),0)
										FROM Tmwsuite..stops 
										Where 	mov_number	= @limovimiento and 
												stp_status	= 'DNE' and 
												cmp_id		= @V_cliente*/
										-- Obtiene ciudad Origen
											SELECT @V_cty_origen = stp_city, @V_cmp_origen = cmp_id
											FROM Tmwsuite..stops Where mov_number = @limovimiento and stp_mfh_sequence = @lstpnumber
											-- y Actualiza la fecha del stop
											Update	Tmwsuite..stops 
											Set		stp_departuredate	= @V_fecha
											Where 	mov_number			= @limovimiento and 
													stp_mfh_sequence	= @lstpnumber
											--Update QSP..QFSActivity Set procesado = 'Si' where  QSP..QFSActivity.idActivity = @V_idactividad
											--Update QSP..QFSActivity Set movimiento = @limovimiento, compañia = @V_cliente, evento = @V_stp_event  where  QSP..QFSActivity.idActivity = @V_idactividad

											Select @V_nota	=	'RC Sal de '+ @V_cliente +' -> '+left(right(Convert(varchar(25),@V_fecha,120),14),11)+'->'+ @V_stp_event
											 exec dx_add_note 'orderheader', @V_ord_number, 0,0, @V_nota, 'N',null,''

											Select @V_CK_ubicacion	=  'RC Sal de '+ @V_ubicacion

											IF @err = 0 exec sp_inserta_checkcal_RC_JR  @V_operador, @V_fecha, 'RCSAL',@V_CK_ubicacion, @V_unidad

											-- Aqui hay que preguntar si se tiene algun otro evento de 'P' o 'D'
											-- si existe otro mas, no hace nada, si ya no tiene podria completar la orden.??
											SELECT @li_maxstop = max(stp_mfh_sequence)
											FROM Tmwsuite..stops 
											Where mov_number = @limovimiento 

											IF @li_maxstop > @lstpnumber
												BEGIN -- 9 cuando hay stops adelante
													exec sp_act_stops_salida_JR @V_fecha, @limovimiento, @lstpnumber, @V_cmp_origen, @V_cty_origen, @v_bandera out
												END --9 cuando existe mas stops
											ELSE
												Select @v_bandera = 0
											-- reproceso de la salida
											IF @V_mensaje = 'RCSAL' and @v_bandera = 0
												BEGIN -- 15
														Update Tmwsuite..OrderHeader 
														Set Ord_status ='CMP' , Ord_Invoicestatus = 'AVL'
														Where	mov_number = @limovimiento	and
																Ord_status = 'STD'

														Update	Tmwsuite..legheader set lgh_outstatus = 'CMP' 
														where	mov_number = @limovimiento	and
																lgh_outstatus = 'STD'

														Update Tmwsuite..assetassignment 
														Set asgn_status = 'CMP'
														where mov_number = @limovimiento 

														  -- Busca la sig orden que esta como despachada...
															Exec sp_obtiene_movimiento_jr @V_unidad, 'CAN','CMP', @limovimiento_Sig out, @V_ord_number out
															IF @limovimiento_Sig > 0 
															BEGIN --10 Cuando encontro Numero de Orden
																Exec sp_act_mov_sig_JR  @V_cliente, @limovimiento_Sig, @V_fecha, @V_cty_origen, @V_cmp_origen
															End -- 10 cuando va entrando
												END --15
									End -- 8.1Cuando va saliendo y existe el Stop
							END -- 8.cuando va saliendo
						END --6 Cuando encontro Numero de Orden
					END --5 cuando no tiene alias
				END --4 cuando identifica el valor del Vmensaje
				FETCH NEXT FROM QFSactividad_Cursor INTO @V_idregistro, @V_mensaje, @V_fecha, @V_cliente, @V_unidad, @V_operador, @V_ubicacion
			END --3 curso de los movimientos 
				CLOSE QFSactividad_Cursor 
				DEALLOCATE QFSactividad_Cursor 
		END -- 2 si hay mensajes
END --1 Principal
GO
