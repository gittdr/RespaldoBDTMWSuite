SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los mensajes  que inserta QFS y actualiza las ordenes en orderheader.
--  DROP PROCEDURE sp_lee_mensajes_std_ordenes_JR
--GO
--  exec sp_lee_mensajes_std_ordenes_JR

CREATE PROCEDURE [dbo].[sp_lee_mensajes_std_ordenes_JR]
AS
DECLARE	
	@V_idMensaje 	uniqueidentifier, 
	@V_Mensaje		Varchar(50),
	@V_fecha		Datetime, 
	@V_fechamsg		DateTime,
	@V_cliente		Varchar(20),
	@V_Unidad		Varchar(10),
	@V_IDOPERA		Varchar(10),
	@limovimiento			Int,
	@lstpnumber			Int,
	@li_maxstop			Int,
	@li_totalstopsig	Int,
	@li_maxstopsig		Int,
	@kmsdelstop			Int,
	@kmsdelstop2		Int,
	@li_hrs				float ,
	@V_fechaF		Datetime,
	@li_i				Int,
	@V_cty_origen		Int, 
	@V_cty_destino		Int, 
	@V_cmp_origen		Varchar(6), 
	@V_cmp_destino		Varchar(6),
	@li_ultimostop		Int,
	@li_minutos1		Int,
	@li_minutos2		Int,
	@err				Int,
	@V_ord_number		Int,
	@V_nota				Varchar(200)



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
	From QSP..QFSMessage A  with (nolock), QSP..QFSSites B  with (nolock), QSP..QFSVehicles C with (nolock)
	Where messageRead = 0 and 
		  A.siteID = B.siteID  and 
		  C.vehicleID = A.senderId and C.displayName in (	'-816','-823','-844','-994','-1060','-1096','-1099','-1100','-1102','-1103','-1104')
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
				SELECT @V_mensaje	= LTrim(@V_mensaje)
				SELECT @V_mensaje	= RTrim(@V_mensaje)
				SELECT @V_fechamsg	= @V_fecha
				-- Marca el mensaje de ya leido
				Update QSP..QFSMessage Set messageRead = 1
				where  QSP..QFSMessage.messageId = @V_idmensaje;
				-- Toma el cuerpo del mensaje para identificar si es una macro.
				IF  @V_mensaje = 'Iniciando Viaje'
					Begin --4 Mensaje Iniciando Viaje
--							SELECT  @limovimiento = IsNull(Min(mov_number),0)  
--							FROM TmwSuite..orderheader 
--							WHERE ord_tractor = @V_unidad and ord_status in ('DSP');

							Exec sp_obtiene_movimiento_DSP_jr @V_unidad, 'DSP','DSP', @limovimiento out, @V_ord_number out
		
							IF @limovimiento > 0 
								BEGIN -- 4.1 si encontro el movimiento DSP, actualiza a STD
									Update TmwSuite..OrderHeader 
										Set Ord_status ='STD' 
										Where	mov_number = @limovimiento	and
												Ord_status = 'DSP'
									SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Iniciando Viaje',@limovimiento,'No puso la OrderHeader como STP ',@V_unidad, @V_cliente

									Update	TmwSuite..legheader set lgh_outstatus = 'STD' 
									where	mov_number = @limovimiento	and
											lgh_outstatus = 'DSP'
									SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Iniciando Viaje',@limovimiento,'No puso el legheader como STP ',@V_unidad, @V_cliente

									Update TmwSuite..stops set stp_lgh_status = 'STD' 
									where	mov_number = @limovimiento

									Update TmwSuite..assetassignment 
									Set asgn_status = 'STD'
									where mov_number = @limovimiento 
									SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Iniciando Viaje',@limovimiento,'No puso el stops como STP ',@V_unidad, @V_cliente

									exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Iniciando Viaje',@limovimiento,'Proceso Se puso como empezado el Viaje ',@V_unidad, @V_cliente
									
									If Exists (SELECT Min(stp_number) FROM TmwSuite..stops 
												Where 	mov_number			= @limovimiento and
														stp_status			= 'OPN' and
														stp_mfh_sequence	= 1)
											BEGIN --4.2 cuando si existe el 1er renglon abierto
												--  solo para inicialiar la var lstpnumber
												SELECT @lstpnumber = IsNull(Min(stp_mfh_sequence),0)
												FROM TmwSuite..stops 
												Where	mov_number	= @limovimiento and 
														stp_status	= 'OPN' and 
														stp_mfh_sequence = 1
												-- Actualiza fecha inicial del stop
													Update TmwSuite..stops 
													Set stp_arrivaldate		= @V_fecha,
														stp_status			= 'DNE'
													Where 	mov_number		= @limovimiento and 
															stp_mfh_sequence= @lstpnumber;
												-- Obtiene el dato de la compañia Origen renglon 1
													SELECT	@V_cty_origen = stp_city, 
															@V_cmp_origen = cmp_id
													FROM TmwSuite..stops 
													Where 	mov_number		= @limovimiento and 
															stp_mfh_sequence= @lstpnumber
													-- Obtiene el dato de la compañia Destino
														SELECT	@V_cty_destino = stp_city, 
																@V_cmp_destino = cmp_id
														FROM TmwSuite..stops 
														Where	mov_number		= @limovimiento and 
																stp_mfh_sequence= 2
														-- saca el valor de la fecha sumando las hrs


							execute dbo.miles_between_JR   @type = 3, @o_cmp = @V_cmp_origen, @d_cmp = @V_cmp_destino, @o_cty = @V_cty_origen, @d_cty = @V_cty_destino, @o_zip = '0', @d_zip = '0', @haztype = 0,@horas = @li_hrs output
												

															select @li_minutos1 =  (FLOOR(ABS(@li_hrs)))*60
															select @li_minutos2 =  (ABS(@li_hrs) - FLOOR(ABS(@li_hrs)))*60

															select @li_hrs		=  @li_minutos1 + @li_minutos2

															select @V_fechaF = dateadd(Minute,(@li_hrs),@V_fecha)

															Update TmwSuite..stops 
															Set 	stp_departuredate	= @V_fechaF
															Where 	mov_number = @limovimiento and 
																	stp_mfh_sequence = 1
																Select @V_nota = 'Iniciando Viaje'

												IF @err = 0 exec dx_add_note 'orderheader', @V_ord_number, 0,0, @V_nota, 'N',null,''

			/** proceso para desplazar las fechas de los siguientes stops **/	

										SELECT @li_maxstop = max(stp_mfh_sequence)
										FROM TmwSuite..stops 
										Where 	mov_number = @limovimiento  --and 												stp_type in ('PUP','DRP')
										-- 1 porque estamos trabando con el renglon 1
										IF @li_maxstop > 1
											-- existe mas P o D
											-- es necesario saber si existen mas stops para completarlos o no...
											--sacamos el count de stops 
											BEGIN -- 5 cuando hay stops adelante
												  --print  'cuando hay stops adelante'
															SELECT @li_totalstopsig = Count(stp_number)
															FROM TmwSuite..stops 
															Where 	mov_number = @limovimiento  and 
																	stp_mfh_sequence > 1;


															IF @li_totalstopsig > 0 
															Begin
																select @li_i = 1
															End
															While @li_i <= @li_totalstopsig
																				Begin -- 5.1 while de tiene mas stops			

																						SELECT @li_maxstopsig = min(stp_mfh_sequence)
																						FROM TmwSuite..stops 
																						Where 	mov_number = @limovimiento  and stp_mfh_sequence > @lstpnumber

																			-- Obtiene ciudad destino
																					SELECT @V_cty_destino = stp_city, @V_cmp_destino = cmp_id
																					FROM TmwSuite..stops 
																					Where 	mov_number		 = @limovimiento and 
																						stp_mfh_sequence = @li_maxstopsig

																				execute dbo.miles_between_JR   @type = 3, @o_cmp = @V_cmp_origen, @d_cmp = @V_cmp_destino, @o_cty = @V_cty_origen, @d_cty = @V_cty_destino, @o_zip = '0', @d_zip = '0', @haztype = 0,@horas = @li_hrs output

																					select @li_minutos1 =  (FLOOR(ABS(@li_hrs)))*60
																					select @li_minutos2 =  (ABS(@li_hrs) - FLOOR(ABS(@li_hrs)))*60
																					select @li_hrs		=  @li_minutos1 + @li_minutos2
																									
																							select @V_fechaF = dateadd(Minute,(@li_hrs+1),@V_fecha)

																							Update TmwSuite..stops 
																							Set stp_schdtearliest	= @V_fechaF, 
																								stp_arrivaldate		= @V_fechaF,
																								stp_schdtlatest		= @V_fechaF, 
																								stp_departuredate	= @V_fechaF
																							Where 	mov_number = @limovimiento and 
																									stp_mfh_sequence = @li_maxstopsig
																							--pasa los valores de las fechas a las variables
																								Select @V_fecha		=  	@V_fechaF	
																								Select @li_maxstop	=	@li_maxstopsig
																								Select @lstpnumber	=   @li_maxstopsig
																								Select @V_cmp_origen	= @V_cmp_destino
																								Select @V_cty_origen	= @V_cty_destino
																						Select	@li_i = @li_i+1
																						
																					END -- 5.1 while de tiene mas stops
														END --5 cuando existe mas stops	
													END	--4.2 cuando si existe el 1er renglon abierto
												END	-- 4.1
													exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Iniciando Viaje',@limovimiento,'No encontro el movimiento',@V_unidad, @V_cliente
											end -- Mensaje Iniciando Viaje.. 4
									
												-- Aqui considerar si es el fin de viaje...
											IF  @V_mensaje = 'Terminando viaje'

--PRINT 'Paso por aqui 1'
												Begin --6 Mensaje Terminando Viaje
												-- Busca la orden con estatus de STD
						Exec sp_obtiene_movimiento_DSP_jr @V_unidad, 'STD','STD', @limovimiento out, @V_ord_number out
--													SELECT @limovimiento = IsNull(Min(mov_number),0)  
--													  FROM TmwSuite..orderheader 
---													 WHERE	ord_tractor = @V_unidad and 
--															ord_status in ('STD');
							
														IF @limovimiento > 0 
															begin	-- 6.1 encuentra orden STD
																SELECT @li_ultimostop = max(stp_mfh_sequence)
																FROM TmwSuite..stops 
																Where 	mov_number = @limovimiento 

																-- Actualiza la fecha fin del ultimo leg
																Update TmwSuite..stops 
																Set stp_departuredate	= @V_fecha,
																	stp_status			= 'DNE'
																Where 	mov_number		= @limovimiento and 
																	stp_mfh_sequence	= @li_ultimostop;
																SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Terminando Viaje',@limovimiento,'No actualizo la fecha del Ult leg del mov ',@V_unidad, @V_cliente

																Update TmwSuite..OrderHeader 
																	Set Ord_status ='CMP' , Ord_Invoicestatus = 'AVL'
																	Where	mov_number = @limovimiento	and
																			Ord_status = 'STD'
																SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Terminando Viaje',@limovimiento,'No actualizo el status de la orden y de la invoice',@V_unidad, @V_cliente
																Update	TmwSuite..legheader set lgh_outstatus = 'CMP' 
																where	mov_number = @limovimiento	and
																		lgh_outstatus = 'STD'
																SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Terminando Viaje',@limovimiento,'No actualizo el leg header como CMP',@V_unidad, @V_cliente

																Update TmwSuite..stops set stp_lgh_status = 'CMP' , stp_status = 'DNE'
																where	mov_number = @limovimiento
																SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Terminando Viaje',@limovimiento,'No actualizo los stops como DNE y CMP',@V_unidad, @V_cliente
																Update TmwSuite..assetassignment 
																Set asgn_status = 'CMP'
																where mov_number = @limovimiento 
																SELECT @err = @@error IF @err <> 0 exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Msg Terminando Viaje',@limovimiento,'No actualizo los assiments como CMP',@V_unidad, @V_cliente

																exec [sp_Inserta_logactividadesQFS_JR] @V_fechamsg,'Terminando Viaje',@limovimiento,'Se puso como Completado el movimiento',@V_unidad, @V_cliente
															END -- encuentra orden STD 6.1
															exec [sp_Inserta_logactividadesQFS_JR] @V_fecha,'Terminando Viaje',@limovimiento,'No encontro el movimiento como STD ',@V_unidad, @V_cliente
													END -- Mensaje Terminando Viaje 6
								--END -- cuando existe el movimiento
							--End -- Cuando acepta el viaje
					FETCH NEXT FROM QFSmensajes_Cursor INTO @V_idmensaje, @V_mensaje, @V_fecha, @V_cliente, @V_unidad
			END --3 del cursor Unidades_Cursor 

			CLOSE QFSmensajes_Cursor 
			DEALLOCATE QFSmensajes_Cursor 

		END -- 2 si hay mensajes

END --1 Principal
GO
