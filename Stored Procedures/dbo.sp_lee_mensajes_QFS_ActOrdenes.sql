SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los mensajes  que inserta QFS y actualiza las ordenes en orderheader.
--  DROP PROCEDURE sp_lee_mensajes_QFS_ActOrdenes
--GO
--  exec sp_lee_mensajes_QFS_ActOrdenes

CREATE PROCEDURE [dbo].[sp_lee_mensajes_QFS_ActOrdenes]
AS
DECLARE	
	@V_idMensaje 	uniqueidentifier, 
	@V_Mensaje		Varchar(50),
	@V_fecha		Datetime, 
	@V_cliente		Varchar(20),
	@V_Unidad		Varchar(10),
	@V_IDOPERA		Varchar(10),
	@limovimiento			Int,
	@lstpnumber			Int,
	@li_maxstop			Int,
	@li_totalstopsig	Int,
	@li_maxstopsig		Int,
	@kmsdelstop			Int,
	@li_hrs				Int,
	@V_fechaF		Datetime,
	@li_i				Int



DECLARE @TTMensajes_QFS TABLE(
		QFM_idmensaje	uniqueidentifier not null,
		QFM_mensaje		Varchar(50) Null,
		QFM_fecha		DateTime null,
		QFM_cliente		Varchar(20) NULL,
		QFM_unidad		Varchar(20) Null)

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de mensajes
INSERT Into @TTMensajes_QFS 
	Select  A.messageId, LEFT(convert(varchar(50),A.messageBody),50), A.SentDatetime, left(B.displayName,20) Cliente , C.displayName Unidad
	From QSP..QFSMessage A, QSP..QFSSites B, QSP..QFSVehicles C
	Where messageRead = 0 and
			A.siteID *= B.siteID 
			and C.vehicleID = A.senderId 
		    --and C.displayName = '846' 
order by 3

-- Si hay movimientos en la tabla continua
		If Exists ( Select count(*) From  @TTMensajes_QFS )
		BEGIN --2 Si hay mensajes

		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE QFSmensajes_Cursor CURSOR FOR 
		SELECT QFM_idmensaje, QFM_mensaje, QFM_fecha, QFM_cliente, QFM_unidad
		FROM @TTMensajes_QFS 
	
		OPEN QFSmensajes_Cursor 
		FETCH NEXT FROM QFSmensajes_Cursor INTO @V_idmensaje, @V_mensaje, @V_fecha, @V_cliente, @V_unidad
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- del cursor Unidades_Cursor --3
				--SELECT @V_idmensaje, @V_mensaje, @V_fecha, @V_cliente, @V_unidad
				SELECT @V_mensaje = LTrim(@V_mensaje)
				SELECT @V_mensaje = RTrim(@V_mensaje)

-- Marca el mensaje de ya leido
								Update QSP..QFSMessage Set messageRead = 1
								where  QSP..QFSMessage.messageId = @V_idmensaje;

				-- Toma el cuerpo del mensaje para identificar si es una macro.
				IF @V_mensaje = 'Llegando a cargar' OR  @V_mensaje = 'Llegando a descargar' OR
				   @V_mensaje = 'Saliendo de cargar' OR @V_mensaje = 'Saliendo de descargar' OR
				   @V_mensaje = 'Iniciando Viaje'
					BEGIN --identificar @V_mensaje
								-- Busca el ID del operador segun su unidad
								SELECT @V_IDOPERA = IsNull(trc_driver,'XXX')
								FROM tmwSuite..tractorprofile 
								WHERE trc_number = @V_unidad;

								IF @V_mensaje = 'Iniciando Viaje' 
									Begin --Cuando acepta el viaje
										-- Cambia el estatus de la orden a DSP
											SELECT  @limovimiento = IsNull(max(mov_number),0)  
											FROM TmwSuite..orderheader 
											WHERE ord_tractor = @V_unidad and ord_status not in ('CAN','CMP');
							
											IF @limovimiento > 0 
												begin	
													Update TmwSuite..OrderHeader 
														Set Ord_status ='DSP' 
														Where	mov_number = @limovimiento	and
																Ord_status = 'PLN'

													Update	TmwSuite..legheader set lgh_outstatus = 'DSP' 
													where	mov_number = @limovimiento	and
															lgh_outstatus = 'PLN'
																																				
												end
									End -- Cuando acepta el viaje

									/******** Proceso para actualizar la Orden actual del driver  ***********/
							-- Pregunta si tiene Alias.
								IF NOT @V_cliente Is Null 
									Begin -- Cuando tiene Alias
										-- Obtenemos el numero de la orden.
										SELECT  @limovimiento = IsNull(max(mov_number),0)  
										FROM TmwSuite..orderheader 
										WHERE ord_tractor = @V_unidad and ord_status not in ('CAN','CMP');
							
											IF @limovimiento > 0 
												Begin -- Cuando encontro Numero de Orden


																	--Revisa que tipo de evento es: Entrada o salida.
																	IF @V_mensaje = 'Llegando a cargar' OR @V_mensaje = 'Llegando a descargar'  
																	Begin --Cuando va entrando
																		If Exists ( SELECT min(stp_number)
																			FROM TmwSuite..stops 
																			Where 	mov_number = @limovimiento and 
																				stp_status = 'OPN' and cmp_id = @V_cliente)
																			BEGIN -- Cuando va entrando y existe el Stop.
																				SELECT @lstpnumber = IsNull(Min(stp_number),0)
																				FROM TmwSuite..stops 
																				Where 	mov_number = @limovimiento and 
																					stp_status = 'OPN' and cmp_id = @V_cliente

																				-- y la fecha del stop
																				Update TmwSuite..stops 
																				Set stp_schdtearliest = @V_fecha, stp_arrivaldate = @V_fecha,
																					stp_status = 'DNE'
																				Where 	mov_number = @limovimiento and 
																					stp_number = @lstpnumber;
																				-- Actualiza el status a empezada...
																					Update TmwSuite..OrderHeader 
																						Set Ord_status ='STD' 
																						Where	mov_number = @limovimiento
																					Update	TmwSuite..legheader 
																						set lgh_outstatus = 'STD' 
																						where	mov_number = @limovimiento
																					Update TmwSuite..assetassignment 
																						Set asgn_status = 'STD'
																					 where mov_number = @limovimiento 

																				-- actualiza el status del o los Stops anteriores en caso de que esten en 'E'

																				--Update TmwSuite..stops 
--																					Set stp_schdtearliest = @V_fecha, stp_arrivaldate = @V_fecha,
																					--	stp_status = 'DNE'
																					--Where 	mov_number = @limovimiento and 
--																						stp_number < @lstpnumber and stp_status = 'OPN';
																				
																			End --cuando va entrando y existe el stop
																		End --cuando va entrando

																	IF @V_mensaje = 'Saliendo de cargar' OR @V_mensaje = 'Saliendo de descargar'
																	Begin --cuando va saliendo
																		If Exists ( SELECT Min(stp_number)
																			FROM TmwSuite..stops 
																			Where 	mov_number = @limovimiento and 
																				stp_status = 'DNE' and cmp_id = @V_cliente)
																		BEGIN --cuando va saliendo y existe el Stop
																			SELECT @lstpnumber = IsNull(Min(stp_number),0)
																			FROM TmwSuite..stops 
																			Where 	mov_number = @limovimiento and 
																				stp_status = 'DNE' and cmp_id = @V_cliente

																			-- y la fecha del stop
																			Update TmwSuite..stops 
																			Set stp_schdtlatest = @V_fecha, 
																				stp_departuredate = @V_fecha
																			Where 	mov_number = @limovimiento and 
																				stp_number = @lstpnumber;
																			
																						--Aqui hay que preguntar si se tiene algun otro evento de 'P' o 'D'
																						-- si existe otro mas, no hace nada, si ya no tiene podria completar la orden.??
																						--toma el stop mayor ya sea carga o descarga

																						SELECT @li_maxstop = max(stp_number)
																						FROM TmwSuite..stops 
																						Where 	mov_number = @limovimiento  and 
																								stp_type in ('PUP','DRP')

																						IF @lstpnumber >= @li_maxstop
																							-- Ya no existen 'P' or 'D'...
																							-- es necesario saber si existen mas stops para completarlos o no...
																							--sacamos el count de stops 
																							
																						SELECT @li_totalstopsig = Count(stp_number)
																						FROM TmwSuite..stops 
																						Where 	mov_number = @limovimiento  and stp_number > @li_maxstop;


																							IF @li_totalstopsig > 0 
																							Begin
																								select @li_i = 1
																							End
																							While @li_i <= @li_totalstopsig
																								Begin			
																										SELECT @li_maxstopsig = max(stp_number)
																										FROM TmwSuite..stops 
																										Where 	mov_number = @limovimiento  and stp_number > @li_maxstop

																											-- toma el dato de los kms del stops
																											SELECT @kmsdelstop	= stp_lgh_mileage 
																											FROM TmwSuite..stops 
																											Where mov_number = @limovimiento  and 
																												  stp_number = @li_maxstopsig
																											-- cuanto tiempo es para sumarlo a la fecha anterior.
																											select @li_hrs = Ceiling(@kmsdelstop / 70)
																											-- saca el valor de la fecha sumando las hrs
																													
																											select @V_fechaF = dateadd(hour,@li_hrs,@V_fecha)

																											Update TmwSuite..stops 
																											Set stp_schdtearliest	= @V_fecha, 
																												stp_arrivaldate		= @V_fecha,
																												stp_status			= 'DNE',
																												stp_schdtlatest		= @V_fechaF, 
																												stp_departuredate	= @V_fechaF
																											Where 	mov_number = @limovimiento and 
																													stp_number = @li_maxstopsig
																											--pasa los valores de las fechas a las variables
																												Select @V_fecha		=  	@V_fechaF	
																												Select @li_maxstop	=	@li_maxstopsig
																									Select	@li_i = @li_i+1
																									END --del While

														-- Pone como Completada la Orden:
																					Update TmwSuite..OrderHeader 
																						Set Ord_status ='CMP' 
																						Where	mov_number = @limovimiento

																					Update	TmwSuite..legheader 
																						set lgh_outstatus = 'CMP' 
																						where	mov_number = @limovimiento

																					Update TmwSuite..assetassignment 
																						Set asgn_status = 'CMP'
																					 where mov_number = @limovimiento 
														




																		End --Cuando va saliendo y existe el Stop
																	End --cuando va saliendo
												End -- Cuando encontro Numero de Orden
								end --- cuando no tiene alias
						END -- cuando identifica el valor del Vmensaje
						FETCH NEXT FROM QFSmensajes_Cursor INTO @V_idmensaje, @V_mensaje, @V_fecha, @V_cliente, @V_unidad
		END --3 curso de los movimientos 

	CLOSE QFSmensajes_Cursor 
	DEALLOCATE QFSmensajes_Cursor 

END -- 2 si hay mensajes

END --1 Principal
--select * from lissystem
GO
