SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Proceso que actualiza el stop de las salidas...
-- recibe de parametros el movimiento y el num de secuencia
CREATE PROCEDURE [dbo].[sp_act_stops_salida_JR]
(
	@P_fecha			DateTime,
	@P_movimiento		integer,
	@P_lstpnumber		Integer,
	@P_cmp_origen		varchar(10),
	@P_cty_origen		int,
	@P_bandera			int out
	
)

AS

BEGIN 
	DECLARE @V_num_stop			int,
			@V_totalstopsig		int,
			@V_li_i				int,
			@V_maxstopsig		int,
			@V_cty_destino		int,
			@V_cmp_destino		varchar(10),
			@V_minutos1			int, 
			@V_minutos2			int, 
			@V_li_hrs			int,
			@V_fechaF			datetime


	SELECT @V_totalstopsig = Count(stp_number)
			FROM Tmwsuite..stops 
			Where 	mov_number = @P_movimiento  
					and stp_mfh_sequence > @P_lstpnumber;

			IF @V_totalstopsig > 0 
				select @V_li_i = 1
				select @P_bandera = 1 -- return

				While @V_li_i <= @V_totalstopsig

					Begin -- 9.1 while de tiene mas stops	

						SELECT @V_maxstopsig = min(stp_mfh_sequence)
						FROM Tmwsuite..stops 
						Where 	mov_number = @P_movimiento  and 
								stp_mfh_sequence > @P_lstpnumber

						-- Obtiene ciudad destino
						SELECT	@V_cty_destino = stp_city, 
								@V_cmp_destino = cmp_id
						FROM Tmwsuite..stops 
						Where mov_number		 = @P_movimiento and 
							  stp_mfh_sequence	 = @V_maxstopsig
						-- obtiene los datos de las hora de una ciudad a Otra
						execute dbo.miles_between_JR   @type = 3, @o_cmp = @P_cmp_origen, @d_cmp = @V_cmp_destino, @o_cty = @P_cty_origen, @d_cty = @V_cty_destino, @o_zip = '0', @d_zip = '0', @haztype = 0,@horas = @V_li_hrs output
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
							Select @P_lstpnumber	= @V_maxstopsig
							Select @P_cmp_origen	= @V_cmp_destino
							Select @P_cty_origen	= @V_cty_destino
							Select @V_li_i = @V_li_i+1

					END -- 9.1 while de tiene mas stops

END
GO
