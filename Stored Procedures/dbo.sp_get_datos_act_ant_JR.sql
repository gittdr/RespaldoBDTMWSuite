SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--- Proceso para Obtener datos de la actividad anterior del movimiento en entradas
CREATE PROCEDURE [dbo].[sp_get_datos_act_ant_JR]
(	
	@P_movimiento	integer,
	@P_unidad		varchar(10),
	@P_actividad	uniqueidentifier,
	@P_stpseq		Integer,
	@P_fecha_ant	DateTime Out,
	@P_Cliente_ant	varchar(20) Out,
	@V_tiempoMinEst	Integer out
)

AS

BEGIN 

DECLARE @V_kilometros		int,
		@V_Act_anteriores	int

-- pregunta si existe actividades anteriores
Select @V_Act_anteriores = count(*) From	QSP..QFSActivity A, 
						QSP..QFSSites B, 
						QSP..QFSVehicles C
				Where 	A.siteID		= B.siteID 
					and A.vehicleID = C.vehicleID  
					and A.eventSubtype in ('SMDP_EVENT_IN_GEOFENCE')
					and C.displayName in( @P_unidad) 
					and A.idActivity <> @P_actividad
	IF @V_Act_anteriores > 0
		BEGIN
			Select  @P_fecha_ant = A.receivedDateTime, 
						@P_Cliente_ant	 = left(B.displayName,20) 
				From	QSP..QFSActivity A, 
				QSP..QFSSites B, 
				QSP..QFSVehicles C
				Where 	A.siteID		= B.siteID 
				and A.vehicleID = C.vehicleID  
				and A.eventSubtype in ('SMDP_EVENT_IN_GEOFENCE')
				and C.displayName in( @P_unidad) and A.idActivity = 
						(Select   top 1  A.idActivity 
							From	QSP..QFSActivity A, 
									QSP..QFSSites B, 
									QSP..QFSVehicles C
							Where 	A.siteID		= B.siteID 
								and A.vehicleID = C.vehicleID  
								and A.eventSubtype in ('SMDP_EVENT_IN_GEOFENCE')
								and C.displayName in( @P_unidad) 
								and A.idActivity <> @P_actividad
							Order BY  A.receivedDateTime desc)
	--			IF @@error <> 0 RETURN 1
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
