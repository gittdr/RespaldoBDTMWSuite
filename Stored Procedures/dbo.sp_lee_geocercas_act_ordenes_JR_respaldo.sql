SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los movimientos que inserta Qualcomm y pasarlos a la tabla checkcall y que actualize las ordenes

-- exec sp_lee_geocercas_act_ordenes_JR

CREATE PROCEDURE [dbo].[sp_lee_geocercas_act_ordenes_JR_respaldo]
AS
DECLARE	
	@V_idactividad 		uniqueidentifier, 
	@V_Mensaje			Varchar(50),
	@V_fecha			Datetime, 
	@V_fechaanterior	Datetime,
	@V_cliente			Varchar(20),
	@V_Cteanterior		Varchar(20),
	@V_Unidad			Varchar(10),
	@limovimiento		Int,
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
	@v_bandera			Int

DECLARE @TTActividades_QFS TABLE(
		QAC_idactividad	uniqueidentifier not null,
		QAC_mensaje		Varchar(50) Null,
		QAC_fecha		DateTime null,
		QAC_cliente		Varchar(20) NULL,
		QAC_unidad		Varchar(20) Null)

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de actividades...
INSERT Into @TTActividades_QFS 
	Select  A.idActivity, A.eventSubtype, A.receivedDateTime, 
			left(B.displayName,20) Cliente, C.displayName Unidad
	From	QSP..QFSActivity A, 
			QSP..QFSSites B, 
			QSP..QFSVehicles C
	Where 	A.siteID		= B.siteID 
			and A.vehicleID = C.vehicleID  
			and A.eventSubtype in ('SMDP_EVENT_IN_GEOFENCE','SMDP_EVENT_OUT_GEOFENCE')
			and procesado	= 'no'
			and C.displayName in( '816','823','844','994','1060','1096','1099','1100','1102','1103','1104',
'1105','1108','1109','1110','1112','1113','1114','1115','1116','1117','1118','1119','1120','1121','1129','1139','1140')
	order by 3

		-- Si hay movimientos en la tabla continua
		If Exists ( Select count(*) From  @TTActividades_QFS )
		BEGIN --2 Si hay mensajes
				DECLARE QFSactividad_Cursor CURSOR FOR 
				SELECT QAC_idactividad, QAC_mensaje, QAC_fecha, QAC_cliente, QAC_unidad
				FROM   @TTActividades_QFS 
			
				OPEN QFSactividad_Cursor 
				FETCH NEXT FROM QFSactividad_Cursor INTO @V_idactividad, @V_mensaje, @V_fecha, @V_cliente, @V_unidad
				WHILE @@FETCH_STATUS = 0 
			BEGIN --3 del cursor Unidades_Cursor
				SELECT @V_mensaje = LTrim(@V_mensaje)
				SELECT @V_mensaje = RTrim(@V_mensaje)
				-- Marca la actividad de ya leida
				Update QSP..QFSActivity Set procesado = 'Si' where  QSP..QFSActivity.idActivity = @V_idactividad
				-- Toma el cuerpo del mensaje para identificar si es una macro.
				IF @V_mensaje = 'SMDP_EVENT_IN_GEOFENCE' OR  @V_mensaje = 'SMDP_EVENT_OUT_GEOFENCE'
				BEGIN --4 identificar @V_mensaje
					  -- Pregunta si tiene Alias.
					IF NOT @V_cliente Is Null 
					BEGIN -- 5 Cuando tiene Alias
/*
						  -- Obtenemos el numero del movimiento
						SELECT  @limovimiento = IsNull(Min(mov_number),0)  
						FROM	TmwSuite..orderheader 
						WHERE	ord_tractor			= @V_unidad 
								and ord_status not in ('CAN','CMP')
*/
					SELECT  @limovimiento = IsNull(Min(mov_number),0)  
						FROM	TmwSuite..orderheader 
						WHERE 	Mov_number = (SELECT  top 1 IsNull(mov_number,0)
						FROM        TmwSuite..orderheader 
						WHERE        ord_tractor                        =  @V_unidad 
						and ord_status not in ('CAN','CMP')
						order by ord_startdate )


						IF @limovimiento > 0 
						BEGIN --6 Cuando encontro Numero de Orden
							  -- Revisa que tipo de evento es: Entrada o salida.
							IF @V_mensaje = 'SMDP_EVENT_IN_GEOFENCE'
							BEGIN -- 7  Cuando va entrando IN
							Update QSP..QFSActivity Set movimiento = @limovimiento, compañia = @V_cliente where  QSP..QFSActivity.idActivity = @V_idactividad
							-- Valida que entre la antepenultima y la actual entrada sean diferente compañia
							-- si en caso de ser la misma pregunta por el tiempo que sea mayor a 30 min para actualizar el dato

							Select  @V_fechaanterior = A.receivedDateTime, 
									@V_Cteanterior	 = left(B.displayName,20) 
							From	QSP..QFSActivity A, 
							QSP..QFSSites B, 
							QSP..QFSVehicles C
							Where 	A.siteID		= B.siteID 
							and A.vehicleID = C.vehicleID  
							and A.eventSubtype in ('SMDP_EVENT_IN_GEOFENCE')
							and C.displayName in( @V_unidad) and A.idActivity = 
									(Select   top 1  A.idActivity 
										From	QSP..QFSActivity A, 
												QSP..QFSSites B, 
												QSP..QFSVehicles C
										Where 	A.siteID		= B.siteID 
											and A.vehicleID = C.vehicleID  
											and A.eventSubtype in ('SMDP_EVENT_IN_GEOFENCE')
											and C.displayName in( @V_unidad) 
											and A.idActivity <> @V_idactividad)

								IF @V_Cteanterior <> @V_cliente OR (DateDiff(mi,@V_fechaanterior, @V_fecha) > 30)
									BEGIN --7.09
										print 'cte anterior '+@V_Cteanterior
										print 'cte anterior '+@V_cliente
										SELECT @lstpnumber  = IsNull(Min(stp_mfh_sequence),0) FROM TmwSuite..stops Where 	mov_number = @limovimiento and cmp_id = @V_cliente  and stp_OOA_stop	= 0 --and  stp_status = 'OPN' 
										 IF @lstpnumber > 0
											BEGIN --7.1 Cuando va entrando y existe el Stop.
												SELECT @lstpnumber = IsNull(Min(stp_mfh_sequence),0) 
												FROM TmwSuite..stops 
												Where 	mov_number	= @limovimiento and 
														 cmp_id		= @V_cliente and
													stp_OOA_stop	= 0 --stp_status = 'OPN' 
												-- y la fecha del stop
												Update TmwSuite..stops 
												Set stp_arrivaldate		= @V_fecha, 
													stp_status			= 'DNE',
													stp_OOA_stop		= 1
												Where 	mov_number		= @limovimiento and 
													stp_mfh_sequence	= @lstpnumber
												-- Actualiza el status a empezada...
												Update TmwSuite..OrderHeader		Set Ord_status			= 'STD'	Where	mov_number = @limovimiento
												Update TmwSuite..legheader			set lgh_outstatus	= 'STD'	Where	mov_number = @limovimiento
												Update TmwSuite..assetassignment	Set asgn_status			= 'STD'	Where	mov_number = @limovimiento 
												-- actualiza el status del o los Stops anteriores en caso de que esten en 'E'
												Update TmwSuite..stops 
													Set stp_arrivaldate		= dateadd(Minute,(-1),@V_fecha),
														stp_status			= 'DNE'
												  Where mov_number			= @limovimiento and 
														stp_mfh_sequence	< @lstpnumber	and 
														stp_status			= 'OPN'
												-- obtengo ahora si el número del stop y actualiza la tabla Event
														Select	@num_stop		= stp_number
														FRom	TmwSuite..stops 
														Where 	mov_number		= @limovimiento and 
																stp_mfh_sequence= @lstpnumber

														update TmwSuite..event
														Set evt_status = 'DNE'
														Where 	evt_mov_number = @limovimiento and 
															stp_number = @num_stop;
														-- Regista el Log de la actividad
														--exec [sp_Inserta_logactividadesQFS_JR] @V_fecha,'IN a la Geocerca',@limovimiento,'Se puso como DNE-A el Stop ',@V_unidad, @V_cliente
												
											End -- 7.1cuando va entrando y existe el stop
										END -- 7.09
												--exec [sp_Inserta_logactividadesQFS_JR] @V_fecha,'IN a la Geocerca',@limovimiento,'No encontro el Stop ',@V_unidad, @V_cliente
							End --7cuando va entrando
							IF @V_mensaje = 'SMDP_EVENT_OUT_GEOFENCE'
								Begin --8 cuando va saliendo
										Select @v_bandera = 1
										Update QSP..QFSActivity Set movimiento = @limovimiento, compañia = @V_cliente where  QSP..QFSActivity.idActivity = @V_idactividad
										SELECT @lstpnumber	= IsNull(Min(stp_mfh_sequence),0)
										FROM TmwSuite..stops 
										Where 	mov_number	= @limovimiento and 
												stp_status	= 'DNE' and 
												cmp_id		= @V_cliente
									IF @lstpnumber > 0
									BEGIN --8.1cuando va saliendo y existe el Stop
											SELECT @lstpnumber	= IsNull(Min(stp_mfh_sequence),0)
											FROM TmwSuite..stops 
											Where 	mov_number	= @limovimiento and 
													stp_status	= 'DNE' and 
													cmp_id		= @V_cliente
										-- Obtiene ciudad Origen
											SELECT @V_cty_origen = stp_city, @V_cmp_origen = cmp_id
											FROM TmwSuite..stops Where mov_number = @limovimiento and stp_mfh_sequence = @lstpnumber
											-- y Actualiza la fecha del stop
											Update	TmwSuite..stops 
											Set		stp_departuredate	= @V_fecha
											Where 	mov_number			= @limovimiento and 
													stp_mfh_sequence	= @lstpnumber
											--Aqui hay que preguntar si se tiene algun otro evento de 'P' o 'D'
											-- si existe otro mas, no hace nada, si ya no tiene podria completar la orden.??
											--toma el stop mayor ya sea carga o descarga
											SELECT @li_maxstop = max(stp_mfh_sequence)
											FROM TmwSuite..stops 
											Where mov_number = @limovimiento --and   stp_type in ('PUP','DRP')

											IF @li_maxstop > @lstpnumber
												-- es necesario saber si existen mas stops para completarlos o no...
												--sacamos el count de stops 
											BEGIN -- 9 cuando hay stops adelante
												SELECT @li_totalstopsig = Count(stp_number)
												FROM TmwSuite..stops 
												Where 	mov_number = @limovimiento  
														and stp_mfh_sequence > @lstpnumber;
												IF @li_totalstopsig > 0 
													select @li_i = 1
													select @v_bandera = 1
													While @li_i <= @li_totalstopsig
														Begin -- 9.1 while de tiene mas stops			
															SELECT @li_maxstopsig = min(stp_mfh_sequence)
															FROM TmwSuite..stops 
															Where 	mov_number = @limovimiento  and 
																	stp_mfh_sequence > @lstpnumber

															-- Obtiene ciudad destino
															SELECT	@V_cty_destino = stp_city, 
																	@V_cmp_destino = cmp_id
															FROM TmwSuite..stops 
															Where mov_number		 = @limovimiento and 
																  stp_mfh_sequence	 = @li_maxstopsig
															-- obtiene los datos de las hora de una ciudad a Otra
															execute dbo.miles_between_JR   @type = 3, @o_cmp = @V_cmp_origen, @d_cmp = @V_cmp_destino, @o_cty = @V_cty_origen, @d_cty = @V_cty_destino, @o_zip = '0', @d_zip = '0', @haztype = 0,@horas = @li_hrs output
															select @li_minutos1 =  (FLOOR(ABS(@li_hrs)))*60
															select @li_minutos2 =  (ABS(@li_hrs) - FLOOR(ABS(@li_hrs)))*60
															select @li_hrs		=  @li_minutos1 + @li_minutos2																																	
															select @V_fechaF = dateadd(Minute,(@li_hrs+1),@V_fecha)

															Update TmwSuite..stops 
															Set stp_arrivaldate		= @V_fechaF,
																stp_departuredate	= @V_fechaF
															Where 	mov_number		= @limovimiento and 
																	stp_mfh_sequence= @li_maxstopsig
															--pasa los valores de las fechas a las variables
																Select @V_fecha			= @V_fechaF	
																Select @li_maxstop		= @li_maxstopsig
																Select @lstpnumber		= @li_maxstopsig
																Select @V_cmp_origen	= @V_cmp_destino
																Select @V_cty_origen	= @V_cty_destino
																Select @li_i = @li_i+1
														END -- 9.1 while de tiene mas stops
											END --9 cuando existe mas stops
											ELSE
												Select @v_bandera = 0


--											ELSE 
											IF @V_mensaje = 'SMDP_EVENT_OUT_GEOFENCE' and @v_bandera = 0
												BEGIN -- 15
																Update TmwSuite..OrderHeader 
																	Set Ord_status ='CMP' , Ord_Invoicestatus = 'AVL'
																	Where	mov_number = @limovimiento	and
																			Ord_status = 'STD'
																	Print '1.- si pasa y no debe de max '+ convert(varchar(5), @li_maxstop)
																	Print '1.1.- si pasa y no debe de stpo'+ convert(varchar(5), @lstpnumber)
																--SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Terminando Viaje',@limovimiento,'No actualizo el status de la orden y de la invoice',@V_unidad, @V_cliente
																Update	TmwSuite..legheader set lgh_outstatus = 'CMP' 
																where	mov_number = @limovimiento	and
																		lgh_outstatus = 'STD'
																--SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Terminando Viaje',@limovimiento,'No actualizo el leg header como CMP',@V_unidad, @V_cliente

																--Update TmwSuite..stops set stp_lgh_status = 'CMP' , stp_status = 'DNE'
																--where	mov_number = @limovimiento
																--SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Terminando Viaje',@limovimiento,'No actualizo los stops como DNE y CMP',@V_unidad, @V_cliente
																	Print '2.- si pasa y no debe de'
																	Update TmwSuite..assetassignment 
																	Set asgn_status = 'CMP'
																	where mov_number = @limovimiento 
																	  -- Busca la sig orden que esta como despachada...
																	  	SELECT  @limovimiento_Sig = IsNull(Min(mov_number),0)  
																		FROM	TmwSuite..orderheader 
																		WHERE	ord_tractor			= @V_unidad 
																				and ord_status not in ('CAN','CMP')
																		IF @limovimiento_Sig > 0 
																		BEGIN --10 Cuando encontro Numero de Orden
																			Print '3.-si pasa y no debe de'
																			  	If Exists ( SELECT min(stp_mfh_sequence)
																							FROM TmwSuite..stops 
																							Where 	mov_number = @limovimiento_Sig and 
																									stp_status = 'OPN' and cmp_id = @V_cliente)
																				BEGIN --10.1 Cuando va entrando y existe el Stop.
																					Print '4.-si pasa y no debe de'
																						SELECT @lstpnumber = IsNull(Min(stp_mfh_sequence),0)
																						FROM TmwSuite..stops 
																						Where 	mov_number = @limovimiento_Sig and 
																								stp_status = 'OPN' and cmp_id = @V_cliente
																						-- y la fecha del stop
																						Update TmwSuite..stops 
																						Set stp_arrivaldate		= dateadd(Minute,(1),@V_fecha),
																							stp_departuredate	= dateadd(Minute,(2),@V_fecha),
																							stp_status			= 'DNE'
																						Where 	mov_number		= @limovimiento_Sig and 
																							stp_mfh_sequence	= @lstpnumber
																						-- Actualiza el status a empezada...
																						Update TmwSuite..OrderHeader		Set Ord_status		= 'STD'	Where	mov_number = @limovimiento_Sig
																						Update TmwSuite..legheader		set lgh_outstatus	= 'STD'	Where	mov_number = @limovimiento_Sig
																						Update TmwSuite..assetassignment	Set asgn_status		= 'STD'	Where	mov_number = @limovimiento_Sig 
															
																						-- obtengo ahora si el número del stop y actualiza la tabla Event
																								Select	@num_stop		= stp_number
																								FRom	TmwSuite..stops 
																								Where 	mov_number		= @limovimiento_Sig and 
																										stp_mfh_sequence= @lstpnumber

																								update TmwSuite..event
																								Set evt_status = 'DNE'
																								Where 	evt_mov_number = @limovimiento_Sig and 
																									stp_number = @num_stop
																								-- inicio pregunta si la nueva orden tiene stops 																								
																									SELECT @li_maxstop = max(stp_mfh_sequence)
																									FROM TmwSuite..stops 
																									Where mov_number = @limovimiento_Sig and 
																										  stp_type in ('PUP','DRP')

																									IF @li_maxstop > @lstpnumber
																										-- es necesario saber si existen mas stops para completarlos o no...
																										--sacamos el count de stops 
																									BEGIN -- 10.2 cuando hay stops adelante
																										SELECT @li_totalstopsig = Count(stp_number)
																										FROM TmwSuite..stops 
																										Where 	mov_number = @limovimiento_Sig  
																												and stp_number > @lstpnumber;
																										IF @li_totalstopsig > 0 
																										Begin
																											select @li_i = 1
																										End
																										While @li_i <= @li_totalstopsig
																										Begin -- 10.3 while de tiene mas stops			
																											SELECT @li_maxstopsig = min(stp_mfh_sequence)
																											FROM TmwSuite..stops 
																											Where 	mov_number = @limovimiento_Sig  and 
																													stp_mfh_sequence > @lstpnumber

																											-- Obtiene ciudad destino
																											SELECT	@V_cty_destino = stp_city, 
																													@V_cmp_destino = cmp_id
																											FROM TmwSuite..stops 
																											Where mov_number		 = @limovimiento_Sig and 
																												  stp_mfh_sequence	 = @li_maxstopsig
																											-- obtiene los datos de las hora de una ciudad a Otra
																											execute dbo.miles_between_JR   @type = 3, @o_cmp = @V_cmp_origen, @d_cmp = @V_cmp_destino, @o_cty = @V_cty_origen, @d_cty = @V_cty_destino, @o_zip = '0', @d_zip = '0', @haztype = 0,@horas = @li_hrs output
																											select @li_minutos1 =  (FLOOR(ABS(@li_hrs)))*60
																											select @li_minutos2 =  (ABS(@li_hrs) - FLOOR(ABS(@li_hrs)))*60
																											select @li_hrs		=  @li_minutos1 + @li_minutos2																																	
																											select @V_fechaF = dateadd(Minute,(@li_hrs+1),@V_fecha)

																											Update TmwSuite..stops 
																											Set stp_arrivaldate		= @V_fechaF,
																												stp_departuredate	= @V_fechaF
																											Where 	mov_number		= @limovimiento_Sig and 
																													stp_mfh_sequence= @li_maxstopsig
																											--pasa los valores de las fechas a las variables
																												Select @V_fecha			= @V_fechaF	
																												Select @li_maxstop		= @li_maxstopsig
																												Select @lstpnumber		= @li_maxstopsig
																												Select @V_cmp_origen	= @V_cmp_destino
																												Select @V_cty_origen	= @V_cty_destino
																												Select @li_i = @li_i+1
																										END -- 10.3 while de tiene mas stops
																									
																									END --10.2 cuando existe mas stops
																						
													End -- 10.1cuando va entrando y existe el stop

																								--exec [sp_Inserta_logactividadesQFS_JR] @V_fecha,'IN a la Geocerca',@limovimiento,'No encontro el Stop ',@V_unidad, @V_cliente
												End -- 10 cuando va entrando
												END --15

										--exec [sp_Inserta_logactividadesQFS_JR] @V_fecha,'OUT a la Geocerca',@limovimiento,'Actualizo fecha final del stop ',@V_unidad, @V_cliente
									End -- 8.1Cuando va saliendo y existe el Stop
									--exec [sp_Inserta_logactividadesQFS_JR] @V_fecha,'OUT a la Geocerca',@limovimiento,'No encontro el Stop ',@V_unidad, @V_cliente
							END -- 8.cuando va saliendo
						END --6 Cuando encontro Numero de Orden
					END --5 cuando no tiene alias
				END --4 cuando identifica el valor del Vmensaje
				FETCH NEXT FROM QFSactividad_Cursor INTO @V_idactividad, @V_mensaje, @V_fecha, @V_cliente, @V_unidad
			END --3 curso de los movimientos 
				CLOSE QFSactividad_Cursor 
				DEALLOCATE QFSactividad_Cursor 
		END -- 2 si hay mensajes
END --1 Principal
GO
