SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Proceso que actualiza el stop de las salidas.
-- recibe de parametros el movimiento y el num de secuencia

CREATE PROCEDURE [dbo].[sp_act_mov_sig_JR]
(
	@P_Cliente			varchar(20),
	@P_movimiento_sig	integer,
	@P_fecha			DateTime,
	@P_cty_origen		Integer,
	@P_cmp_origen		varchar(10)
)

AS

BEGIN 
	DECLARE @V_lstpnumber	int,
			@V_num_stop		int,
			@V_maxstop		int,
			@V_totalstopsig	int,
			@V_li_i			int,
			@V_maxstopsig	int,
			@V_minutos1		int,
			@V_minutos2		int,
			@V_hrs			int,
			@V_cty_destino	varchar(10),
			@V_cmp_destino	varchar(10),
			@V_fechaF		DateTime

		-- Pregunta si existe el cliente en los stops del nuevo movimiento
		IF Exists ( SELECT min(stp_mfh_sequence)
					FROM Tmwsuite..stops 
					Where 	mov_number	= @P_movimiento_sig and 
							stp_status	= 'OPN' and 
							cmp_id		= @P_Cliente)
		BEGIN --10.1 Cuando va entrando y existe el Stop.
				SELECT @V_lstpnumber	= IsNull(Min(stp_mfh_sequence),0)
				FROM Tmwsuite..stops 
				Where 	mov_number	= @P_movimiento_sig and 
						stp_status	= 'OPN' and 
						cmp_id		= @P_Cliente
					-- actualiza Fecha del stop 
					Update Tmwsuite..stops 
					Set stp_arrivaldate		= dateadd(Minute,(1),@P_fecha),
						stp_departuredate	= dateadd(Minute,(2),@P_fecha),
						stp_status			= 'DNE'
					Where 	mov_number		= @P_movimiento_sig and 
						stp_mfh_sequence	= @V_lstpnumber
					IF @@error <> 0 Return 1
					-- Actualiza el status a empezada...
					Update Tmwsuite..OrderHeader		Set Ord_status		= 'STD'	Where	mov_number = @P_movimiento_sig
					IF @@error <> 0 Return 1
					Update Tmwsuite..legheader		set lgh_outstatus	= 'STD'	Where	mov_number = @P_movimiento_sig
					IF @@error <> 0 Return 1
					Update Tmwsuite..assetassignment	Set asgn_status		= 'STD'	Where	mov_number = @P_movimiento_sig 
					IF @@error <> 0 Return 1

						-- obtengo ahora si el número del stop y actualiza la tabla Event
								Select	@V_num_stop		= stp_number
								FRom	Tmwsuite..stops 
								Where 	mov_number		= @P_movimiento_sig and 
										stp_mfh_sequence= @V_lstpnumber

								update Tmwsuite..event
								Set evt_status = 'DNE'
								Where 	evt_mov_number = @P_movimiento_sig and 
									stp_number = @V_num_stop
								IF @@error <> 0 Return 1
								-- inicio pregunta si la nueva orden tiene stops 																								
									SELECT @V_maxstop = max(stp_mfh_sequence)
									FROM Tmwsuite..stops 
									Where mov_number = @P_movimiento_sig and 
										  stp_type in ('PUP','DRP')

									IF @V_maxstop > @V_lstpnumber
										-- es necesario saber si existen mas stops para completarlos o no...
										--sacamos el count de stops 
									BEGIN -- 10.2 cuando hay stops adelante
										SELECT @V_totalstopsig = Count(stp_number)
										FROM Tmwsuite..stops 
										Where 	mov_number = @P_movimiento_sig  
												and stp_number > @V_lstpnumber;
										IF @V_totalstopsig > 0 
										Begin
											select @V_li_i = 1
										End
										While @V_li_i <= @V_totalstopsig
										Begin -- 10.3 while de tiene mas stops			
											SELECT @V_maxstopsig = min(stp_mfh_sequence)
											FROM Tmwsuite..stops 
											Where 	mov_number = @P_movimiento_sig  and 
													stp_mfh_sequence > @V_lstpnumber

											-- Obtiene ciudad destino
											SELECT	@V_cty_destino = stp_city, 
													@V_cmp_destino = cmp_id
											FROM Tmwsuite..stops 
											Where mov_number		 = @P_movimiento_sig and 
												  stp_mfh_sequence	 = @V_maxstopsig
											-- obtiene los datos de las hora de una ciudad a Otra
											execute dbo.miles_between_JR   @type = 3, @o_cmp = @P_cmp_origen, @d_cmp = @V_cmp_destino, @o_cty = @P_cty_origen, @d_cty = @V_cty_destino, @o_zip = '0', @d_zip = '0', @haztype = 0,@horas = @V_hrs output
											select @V_minutos1 =  (FLOOR(ABS(@V_hrs)))*60
											select @V_minutos2 =  (ABS(@V_hrs) - FLOOR(ABS(@V_hrs)))*60
											select @V_hrs		=  @V_minutos1 + @V_minutos2																																	
											select @V_fechaF = dateadd(Minute,(@V_hrs+1),@P_fecha)

											Update Tmwsuite..stops 
											Set stp_arrivaldate		= @V_fechaF,
												stp_departuredate	= @V_fechaF
											Where 	mov_number		= @P_movimiento_sig and 
													stp_mfh_sequence= @V_maxstopsig
											IF @@error <> 0 Return 1
											--pasa los valores de las fechas a las variables
												Select @P_fecha			= @V_fechaF	
												Select @V_maxstop		= @V_maxstopsig
												Select @V_lstpnumber	= @V_maxstopsig
												Select @P_cmp_origen	= @V_cmp_destino
												Select @P_cty_origen	= @V_cty_destino
												Select @V_li_i = @V_li_i+1
										END -- 10.3 while de tiene mas stops
									
									END --10.2 cuando existe mas stops
						
							End -- 10.1cuando va entrando y existe el stop
					
				Else -- si no existe el mov.
				return 0



END
GO
