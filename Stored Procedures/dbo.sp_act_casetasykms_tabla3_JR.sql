SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec sp_act_casetasykms_sayer_JR 605931
-- Proceso que actualiza el stop de las entradas...
-- recibe de parametros el movimiento y el num de secuencia
CREATE PROCEDURE [dbo].[sp_act_casetasykms_tabla3_JR]
(
	@P_NumOrden		integer
)

AS

BEGIN 
	DECLARE @V_num_stop		int,
			@v_cmp_origen	varchar(10),
			@V_cty_origen	int,
			@v_cmp_dest		varchar(10),
			@V_cty_dest		int,
			@v_cmp_orig_ant	varchar(10),
			@V_cty_orig_ant	int,
			@V_totalstops	int,
			@V_li_i			int,
			@v_casetas		money,
			@v_kms			int,
			@v_casetas_total money,
			@v_kms_total	int,
			@v_numerostop	int,
			@v_movimiento	int,
			@v_facturable	varchar(1),
			@v_tipoevento	varchar(6)
			
	DECLARE @TT_Stops TABLE
	(
		TT_secuencia integer,
		TT_compania varchar(15),
		TT_ciudad	 integer,
		TT_numstop	 integer,
		TT_facturable varchar(1),
		TT_tipoevento varchar(6)
	)


	-- busca el movimiento del numero de orden

	select @v_movimiento = isNull(mov_number,0) from orderheader where ord_hdrnumber = @P_NumOrden;

IF @v_movimiento > 0

	Begin
	begin tran
				-- llena la tabla temporal
				insert @TT_Stops (TT_secuencia, TT_compania, TT_ciudad,TT_numstop,TT_facturable,TT_tipoevento)  
				select stp_mfh_sequence, cmp_id, stp_city, stops.stp_number, (select ect_billable from eventcodetable where abbr = evt_eventcode ), (select fgt_event from eventcodetable where abbr = evt_eventcode ) 
				from stops stops, event  eve
				 where mov_number = @v_movimiento 
				 and stops.stp_number = eve.stp_number
				 order by 1

				--select stp_mfh_sequence, cmp_id, stp_city, stp_trip_mileage, stp_lgh_mileage , (select ect_billable from eventcodetable where abbr = evt_eventcode ), (select fgt_event from eventcodetable where abbr = evt_eventcode )
				--from stops stops, event  eve
				--where mov_number = 615363 
				--and stops.stp_number = eve.stp_number
				--order by 1


				SELECT @V_totalstops	=	Count(stp_number)
				FROM	stops
				WHERE	mov_number	= @v_movimiento 

				select @V_li_i = 1

				While @V_li_i <= @V_totalstops
				BEGIN
					IF @V_li_i = 1 
						select @v_cmp_origen = TT_compania, @V_cty_origen = TT_ciudad From @TT_Stops where TT_secuencia = @V_li_i
					ELSE
					Begin
						select @v_cmp_orig_ant = @v_cmp_origen
						select @V_cty_orig_ant = @V_cty_origen
						select @v_cmp_dest = TT_compania, @V_cty_dest = TT_ciudad, @v_numerostop = TT_numstop, @v_facturable = TT_facturable, @v_tipoevento = TT_tipoevento  
						From @TT_Stops 
						where TT_secuencia = @V_li_i

						--Print @v_cmp_orig_ant
						--Print @v_cmp_dest
						--print cast(@V_li_i as varchar)
						execute dbo.miles_between_CasetasJR   @type = 3, @o_cmp = @v_cmp_orig_ant, @d_cmp = @v_cmp_dest, @o_cty = @V_cty_orig_ant, @d_cty = @V_cty_dest, @o_zip = '0', @d_zip = '0', @haztype = 0,@casetas = @v_casetas output, @kilometros = @v_kms output

						-- actualiza las casetas
							update stops set stp_ord_toll_cost = @v_casetas where stp_number = @v_numerostop

						-- actualiza los datos del stops facturable
						IF @v_facturable = 'Y' and @v_tipoevento <> 'NONE'
							update stops set stp_ord_mileage = @v_kms where stp_number = @v_numerostop

						select @v_cmp_origen = @v_cmp_dest
						select @V_cty_origen = @V_cty_dest

					end

					SET @V_li_i = @V_li_i + 1
				END
				commit tran
	End -- movimiento > 0
Return 0
END
GO
