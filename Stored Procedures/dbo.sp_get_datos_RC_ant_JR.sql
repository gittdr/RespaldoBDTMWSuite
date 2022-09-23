SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--- Proceso para Obtener datos de la actividad anterior del movimiento en entradas
CREATE PROCEDURE [dbo].[sp_get_datos_RC_ant_JR]
(	
	@P_movimiento	integer,
	@P_unidad		varchar(10),
	@P_actividad	Integer,
	@P_stpseq		Integer,
	@P_fecha_ant	DateTime Out,
	@P_Cliente_ant	varchar(20) Out,
	@V_tiempoMinEst	Integer out
)

AS

BEGIN 

DECLARE @V_kilometros		int,
		@V_Act_anteriores	int

-- pregunta si existe Registros RC anteriores
	SELECT @V_Act_anteriores = count(*)
	FROM	QSP..movimientos_RC MRC, 
			manpowerprofile MP
	Where	right(MRC.RFC_operador,10) = MP.mpp_misc3 and 
			MP.mpp_status <> 'OUT' and 
			MRC.tipo_mov = 'RCENT' and
			MP.mpp_tractornumber in (@P_unidad) and 
			MRC.id_folio <> @P_actividad

	IF @V_Act_anteriores > 0
		BEGIN
			Select  @P_fecha_ant	=	MRC.fecha_mov, 
				 @P_Cliente_ant		=	CRC.tmw_company_id 
			From	QSP..movimientos_RC MRC, 
				company_RC CRC, manpowerprofile MP
			Where MRC.tipo_mov = 'RCENT'
			and right(MRC.RFC_operador,10) = MP.mpp_misc3 
			and CRC.rc_nombre_cmp = MRC.ubicacion 
			and MP.mpp_tractornumber in( @P_unidad) and MRC.id_folio = 
									(Select  top 1    MRC.id_folio 
										From	QSP..movimientos_RC MRC, 
												manpowerprofile MP
										Where right(MRC.RFC_operador,10) = MP.mpp_misc3 and 
												MP.mpp_status <> 'OUT' and 
												MRC.tipo_mov = 'RCENT' and
												MP.mpp_tractornumber in (@P_unidad) and 
												MRC.id_folio <> @P_actividad
										Order BY  MRC.fecha_mov desc)

	END

	IF @V_Act_anteriores = 0
		begin
			Select	@P_fecha_ant	= getdate()
			Select	@P_Cliente_ant	= 'TDR'
		end

-- saca el total de kilometros de la ruta que debe de recorrer para obtener el tiempo
	Select @V_kilometros = sum(IsNull(stp_trip_mileage,1))
	From Stops
	where Mov_number = @P_movimiento and stp_mfh_sequence <= @P_stpseq

	
	select @V_tiempoMinEst = (@V_kilometros/90)*60

		
END
GO
