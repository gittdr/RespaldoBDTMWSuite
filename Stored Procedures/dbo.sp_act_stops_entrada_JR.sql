SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--USE Tmwsuite
-- Proceso que actualiza el stop de las entradas...
-- recibe de parametros el movimiento y el num de secuencia
CREATE PROCEDURE [dbo].[sp_act_stops_entrada_JR]
(
	@P_fecha			DateTime,
	@P_movimiento		integer,
	@P_stop_secuencia	Integer
)

AS

BEGIN 
	DECLARE @V_num_stop		int,
			@V_cty_origen	int,
			@v_cmp_origen	varchar(10),
			@V_cty_dest		int,
			@v_cmp_dest		varchar(10),
			@V_minutos1		int, 
			@V_minutos2		int, 
			@V_li_hrs		int, 
			@V_fechaF		datetime,
			@V_totalstops_ant	int,
			@V_maxstop_ant		int,
			@V_li_i				int,
			@V_totalstopsig		int,
			@V_maxstopsig		int,
			@V_cty_destino		int,
			@P_stop_sec_ori		int


select @P_stop_sec_ori = @P_stop_secuencia

	Update Tmwsuite..stops 
	Set stp_arrivaldate		= @P_fecha, 
		stp_status			= 'DNE',
		stp_OOA_stop		= 1
	Where 	mov_number		= @P_movimiento and 
		stp_mfh_sequence	= @P_stop_secuencia

	IF @@error <> 0 Return 1

	-- Actualiza el status a empezada...
	Update Tmwsuite..OrderHeader		Set Ord_status			= 'STD'	Where	mov_number = @P_movimiento
	IF @@error <> 0 Return 1
	Update Tmwsuite..legheader		set lgh_outstatus		= 'STD'	Where	mov_number = @P_movimiento
	IF @@error <> 0 Return 1
	Update Tmwsuite..assetassignment	Set asgn_status			= 'STD'	Where	mov_number = @P_movimiento 
	IF @@error <> 0 Return 1

	-- debera actualizar cada stop anterior con status de 'E', 'OPN'
	-- preguntamos cuantos stops en status de 'E' estan..
		SELECT @V_totalstops_ant	=	Count(stp_number)
		FROM	Tmwsuite..stops
		WHERE	mov_number	= @P_movimiento and
				stp_mfh_sequence	< @P_stop_secuencia	and
				stp_status			= 'OPN'	

		IF @V_totalstops_ant > 0
			select @V_li_i = 1

			While @V_li_i <= @V_totalstops_ant
		Begin --2.0
			-- Busca el stops anterior al actual
				SELECT @V_maxstop_ant	=	max(stp_mfh_sequence)
				FROM	Tmwsuite..stops
				WHERE  mov_number	= @P_movimiento and
				stp_mfh_sequence	< @P_stop_secuencia	and
				stp_status			= 'OPN'	

				-- Obtiene la ciudad y compañia Origen
					Select	@V_cty_origen	 = stp_city,
							@v_cmp_origen	 = cmp_id 
					FROM	Tmwsuite..stops
					WHERE	mov_number		 = @P_movimiento and
							stp_mfh_sequence = @P_stop_secuencia
			
				-- Obtiene la ciudad y compañia destino
					Select	@V_cty_dest	 = stp_city,
							@v_cmp_dest	 = cmp_id,
							@V_num_stop	 = stp_number
					FROM	Tmwsuite..stops
					WHERE	mov_number		 = @P_movimiento and
							stp_mfh_sequence = @V_maxstop_ant

					-- obtiene los datos de las hora de una ciudad a Otra
						execute dbo.miles_between_JR   @type = 3, @o_cmp = @v_cmp_origen, @d_cmp = @v_cmp_dest, @o_cty = @V_cty_origen, @d_cty = @V_cty_dest, @o_zip = '0', @d_zip = '0', @haztype = 0,@horas = @V_li_hrs output
						select @V_minutos1	=  (FLOOR(ABS(@V_li_hrs)))*60
						select @V_minutos2	=  (ABS(@V_li_hrs) - FLOOR(ABS(@V_li_hrs)))*60
						select @V_li_hrs	=  @V_minutos1 + @V_minutos2																																	
						select @V_fechaF = dateadd(Minute,(-@V_li_hrs),@P_fecha)

						Update Tmwsuite..stops 
						Set stp_arrivaldate		= @V_fechaF,
							stp_departuredate	= @V_fechaF,
							stp_status			= 'DNE'
						Where 	mov_number		= @P_movimiento and 
								stp_mfh_sequence= @V_maxstop_ant
						IF @@error <> 0 Return 1

						Update	Tmwsuite..event
						Set		evt_status = 'DNE'
						Where 	evt_mov_number	= @P_movimiento and 
								stp_number		= @V_num_stop;
						IF @@error <> 0 Return 1

						--pasa los valores de las fechas a las variables
							Select @P_fecha			= @V_fechaF	
							--Select @li_maxstop		= @V_maxstopsig
							Select @P_stop_secuencia	= @V_maxstop_ant
							Select @V_cmp_origen	= @V_cmp_dest
							Select @V_cty_origen	= @V_cty_dest
							Select @V_li_i = @V_li_i+1
		END -- 2 while de tiene mas stops

		-- aqui actualizara los stops siguientes...
--			 Obtiene la ciudad y compañia Origen
				Select	@V_cty_origen	 = stp_city,
						@v_cmp_origen	 = cmp_id 
				FROM	Tmwsuite..stops
				WHERE	mov_number		 = @P_movimiento and
						stp_mfh_sequence = @P_stop_sec_ori

			SELECT @V_totalstopsig = Count(stp_number)
						FROM Tmwsuite..stops 
			Where 	mov_number = @P_movimiento  
					and stp_mfh_sequence > @P_stop_sec_ori;

			IF @V_totalstopsig > 0 
				select @V_li_i = 1

				While @V_li_i <= @V_totalstopsig

					Begin -- 3 while de tiene mas stops	

						SELECT @V_maxstopsig = min(stp_mfh_sequence)
						FROM Tmwsuite..stops 
						Where 	mov_number = @P_movimiento  and 
								stp_mfh_sequence > @P_stop_sec_ori

						-- Obtiene ciudad destino
						SELECT	@V_cty_dest = stp_city, 
								@V_cmp_dest = cmp_id
						FROM Tmwsuite..stops 
						Where mov_number		 = @P_movimiento and 
							  stp_mfh_sequence	 = @V_maxstopsig
						-- obtiene los datos de las hora de una ciudad a Otra
						execute dbo.miles_between_JR   @type = 3, @o_cmp = @V_cmp_origen, @d_cmp = @V_cmp_dest, @o_cty = @V_cty_origen, @d_cty = @V_cty_dest, @o_zip = '0', @d_zip = '0', @haztype = 0,@horas = @V_li_hrs output
						select @V_minutos1 =  (FLOOR(ABS(@V_li_hrs)))*60
						select @V_minutos2 =  (ABS(@V_li_hrs) - FLOOR(ABS(@V_li_hrs)))*60
						select @V_li_hrs		=  @V_minutos1 + @V_minutos2																																	
						select @V_fechaF = dateadd(Minute,(@V_li_hrs+1),@P_fecha)

						Update Tmwsuite..stops 
						Set stp_arrivaldate		= @V_fechaF,
							stp_departuredate	= @V_fechaF
						Where 	mov_number		= @P_movimiento and 
								stp_mfh_sequence= @V_maxstopsig
						IF @@error <> 0 Return 1
						--pasa los valores de las fechas a las variables
							Select @P_fecha			= @V_fechaF	
							--Select @li_maxstop		= @V_maxstopsig
							Select @P_stop_sec_ori	= @V_maxstopsig
							Select @V_cmp_origen	= @V_cmp_dest
							Select @V_cty_origen	= @V_cty_dest
							Select @V_li_i = @V_li_i+1

					END -- 3 while de tiene mas stops
Return 0
END
GO
