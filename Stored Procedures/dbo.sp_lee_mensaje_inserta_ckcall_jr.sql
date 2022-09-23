SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los mensajes  que inserta QFS e insertarlo en checkcall.
--  DROP PROCEDURE sp_lee_mensaje_inserta_ckcall_jr
--GO
--  exec sp_lee_mensaje_inserta_ckcall_jr

CREATE PROCEDURE [dbo].[sp_lee_mensaje_inserta_ckcall_jr]
AS
DECLARE	
	@V_idMensaje 	uniqueidentifier, 
	@V_Mensaje		Varchar(50),
	@V_fecha		Datetime, 
	@V_cliente		Varchar(20),
	@V_Unidad		Varchar(10),
	@V_IDOPERA		Varchar(10),
	@V_CONSECCKC	bigint,
	@P_IDOPERA varchar(8)



DECLARE @TTMensajes_QFS TABLE(
		QFM_idmensaje	uniqueidentifier not null,
		QFM_mensaje		Varchar(50) Null,
		QFM_fecha		DateTime null,
		QFM_cliente		Varchar(20) NULL,
		QFM_unidad		Varchar(20) Null)

BEGIN --1 Principal
	
		-- Inserta en la tabla temporal la información que haya en la de mensajes
		INSERT Into @TTMensajes_QFS 
			Select  A.messageId, LEFT(convert(varchar(50),A.messageBody),50), A.SentDatetime , IsNull(left(B.displayName,20),'') Cliente , C.displayName Unidad
			From QSP..QFSMessage A  with (nolock)
			left join QSP..QFSSites as B On (A.siteID = B.siteID)
			, QSP..QFSVehicles C with (nolock)
			Where messageRead = 0 and 
				  C.vehicleID = A.senderId and LEFT(convert(varchar(50),A.messageBody),50) in
				  ( 'Llegando a Carga','Esperando  Carga','Saliendo de Carga','Llegando a Descarga','Esperando Descarga','Saliendo de Descarga')
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

				Select @V_mensaje = @V_mensaje + IsNull(@V_cliente,'')
				select @V_mensaje = left(@V_mensaje,254)
				
				-- Marca el mensaje de ya leido
				Update QSP..QFSMessage Set messageRead = 1	where  QSP..QFSMessage.messageId = @V_idmensaje;

				-- Toma el cuerpo del mensaje para insertarlo en la tablas de CheckCalls.

				Begin
				-- Obtengo de la tablas de unidades el Id Operador..
					select @P_IDOPERA = trc_driver from TmwSuite..tractorprofile 
					where trc_number= @V_unidad
				End 

		-- Lee el consecutivo de los checkcall para hacer el insert a la tabla.					
		execute @V_CONSECCKC = TmwSuite..getsystemnumber_gateway N'CKCNUM' , NULL , 1 
		-- Inserta el nuevo checkcall
		Insert TmwSuite..checkcall(
		ckc_number, ckc_status, ckc_asgntype, ckc_asgnid, ckc_date, ckc_event, ckc_city, ckc_comment, 
		ckc_updatedby, ckc_updatedon, ckc_latseconds, ckc_longseconds, ckc_lghnumber, ckc_tractor, ckc_extsensoralarm, ckc_vehicleignition, 
		ckc_milesfrom, ckc_directionfrom, ckc_validity, ckc_mtavailable, ckc_minutes, ckc_mileage, ckc_home, ckc_cityname, 
		ckc_state, ckc_zip, ckc_commentlarge, ckc_minutes_to_final, ckc_miles_to_final, ckc_Odometer, TripStatus, ckc_odometer2, 
		ckc_speed, ckc_speed2, ckc_heading, ckc_gps_type, ckc_gps_miles, ckc_fuel_meter, ckc_idle_meter)
		Values (@V_CONSECCKC, 'HIST', 'DRV', 	@P_IDOPERA,	@V_fecha, 	'TRP', 		0, 	@V_mensaje, 
			'TMWST', 		GetDate(), 	null,	null, 		0, 		@V_unidad, 	Null, 	Null, 
			1,		Null, 		Null, 	Null, 		0, 		0, 		Null, 	Null, 
			Null, 		Null, 		@V_mensaje, 		0,		0,		0,		0,	0,		
			Null, 		Null, 		Null, 	Null, 		Null, 		Null, 		Null)



					FETCH NEXT FROM QFSmensajes_Cursor INTO @V_idmensaje, @V_mensaje, @V_fecha, @V_cliente, @V_unidad
			END --3 del cursor Unidades_Cursor 

			CLOSE QFSmensajes_Cursor 
			DEALLOCATE QFSmensajes_Cursor 

		END -- 2 si hay mensajes

END --1 Principal
GO
