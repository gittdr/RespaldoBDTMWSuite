SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los movimientos que inserta Qualcomm
-- y pasarlos a la tabla checkcall.
--DROP PROCEDURE sp_lee_movs_qualcomm
--GO

--exec sp_lee_movs_qualcomm

CREATE   PROCEDURE [dbo].[sp_lee_movs_qualcomm]
AS

DECLARE	
	@V_idTransaccion 	BigInt, 
	@V_fecha		Datetime, 
	@V_proximidadCiudad	Varchar(500), 
	@V_latitud		Float, 
	@V_longitud		Float, 
	@V_economico		Varchar(50), 
	@V_ignicion		Varchar(10), 
	@V_proximidadPoblacion	Varchar(500),
	@V_IDOPERA		Varchar(10),
	@V_ENC_APAG		Char(1),
	@V_CONSECCKC		BigInt,
	@V_TIPOCUENTA		int,
	@V_ANTENA		Varchar(50),
	@V_DESCRIPCTA		Varchar(10),
	@V_GPSLOCATION		Varchar(255)


DECLARE @TTMovs_QC TABLE(
		QC_idtransaccion	BigInt not null,
		QC_date			DateTime null,
		QC_comment		Varchar(500) NULL,
		QC_latseconds		Float null,
		QC_longseconds		Float null,
		QC_tractor		Varchar(50) NULL,
		QC_vehicleignition	Varchar(10) NULL,
		QC_commentlarge		Varchar(500) NULL,
		QC_cuenta		Int Null,
		QC_antena		Varchar(50) null)

SET NOCOUNT ON

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
INSERT Into @TTMovs_QC 
	SELECT 	TP.idTransaccion, 
		TP.fecha, 
		TP.proximidadCiudad, 
		TP.latitud, 
		TP.longitud, 
		TP.economico, 
		TP.ignicion, 
		TP.proximidadPoblacion ,
		TP.cuenta,
		TP.antena
	FROM  QSP..TPosicion TP (NOLOCK)
	WHERE TP.velocidad = 0 and TP.cuenta = 2


-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTMovs_QC )
	BEGIN --3 Si hay movimientos de posiciones

		
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT QC_idtransaccion, QC_date, QC_comment, QC_latseconds, QC_longseconds, QC_tractor, QC_vehicleignition, QC_commentlarge, QC_cuenta, QC_antena
		FROM @TTMovs_QC 
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_economico, @V_ignicion, @V_proximidadPoblacion, @V_TIPOCUENTA, @V_ANTENA
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- del cursor Unidades_Cursor --3
		SELECT @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_economico, @V_ignicion, @V_proximidadPoblacion, @V_TIPOCUENTA, @V_ANTENA

		--Valida que el numero economico no sea el numero de antena.
		IF @V_economico <> @V_ANTENA
			BEGIN	--cuando valida si la antena es dif al numero economico
				-- Busca el ID del operador segun su unidad
				SELECT @V_IDOPERA = IsNull(trc_driver,'XXX')
				FROM tmwSuite..tractorprofile 
				WHERE trc_number = @V_economico;
		
				-- Define si esta Apgado o Encendido el motor
				IF upper(@V_ignicion) = 'ENCENDIDO'
				Begin
					Select @V_ENC_APAG = 'Y'
				End
				IF Upper(@V_ignicion) = 'APAGADO'
				Begin
					Select @V_ENC_APAG = 'N'
				End
		
				-- Multiplica por 3600 latitud y longitud
				Select @V_latitud	=	@V_latitud * 3600
				Select @V_longitud	=	@V_longitud * -3600

				-- Define el tipo de sistema localizador tiene
				-- sistema 1 QSP, 2 OTS/ATF
				IF @V_TIPOCUENTA = 1
				Begin
					Select @V_DESCRIPCTA = ' Sis-QSP'
				End
				IF @V_TIPOCUENTA = 2
				Begin
--					Select @V_DESCRIPCTA = ' Sis-OTS/ATF'
					Select @V_DESCRIPCTA = ' * '
				End

				-- Reemplaza el dato del UNKNOWN por un '-'

				SELECT @V_proximidadCiudad	=	REPLACE(@V_proximidadCiudad,'UNKNOWN','-')
				SELECT @V_proximidadPoblacion	=	REPLACE(@V_proximidadPoblacion,'UNKNOWN','-')


				SELECT @V_GPSLOCATION 		= left((@V_proximidadCiudad + @V_DESCRIPCTA),255)
		
				-- Lee el consecutivo de los checkcall para hacer el insert a la tabla.					
				execute @V_CONSECCKC = tmwSuite..getsystemnumber_gateway N'CKCNUM' , NULL , 1 
				-- Inserta el nuevo checkcall
				Insert tmwSuite.. checkcall(
				ckc_number, ckc_status, ckc_asgntype, ckc_asgnid, ckc_date, ckc_event, ckc_city, ckc_comment, 
				ckc_updatedby, ckc_updatedon, ckc_latseconds, ckc_longseconds, ckc_lghnumber, ckc_tractor, ckc_extsensoralarm, ckc_vehicleignition, 
				ckc_milesfrom, ckc_directionfrom, ckc_validity, ckc_mtavailable, ckc_minutes, ckc_mileage, ckc_home, ckc_cityname, 
				ckc_state, ckc_zip, ckc_commentlarge, ckc_minutes_to_final, ckc_miles_to_final, ckc_Odometer, TripStatus, ckc_odometer2, 
				ckc_speed, ckc_speed2, ckc_heading, ckc_gps_type, ckc_gps_miles, ckc_fuel_meter, ckc_idle_meter)
				Values (@V_CONSECCKC, 'HIST', 		'DRV', 	@V_IDOPERA,	@V_fecha, 	'TRP', 		0, 	left((@V_proximidadCiudad +@V_DESCRIPCTA),254), 
					'QA', 		GetDate(), 	@V_latitud,	@V_longitud, 		0, 		@V_economico, 	Null, 	@V_ENC_APAG, 
					1,		Null, 		Null, 	Null, 		0, 		0, 		Null, 	Null, 
					Null, 		Null, 		left((@V_proximidadPoblacion + @V_DESCRIPCTA),254), 		0,		0,		0,		0,	0,		
					Null, 		Null, 		Null, 	Null, 		Null, 		Null, 		Null)			
				-- Se actualiza tambien en el catalogo de las unidades la ultima ubicacion
				-- siempre y cuando la fecha sea mayor de la que tiene.

				update tractorprofile 
				set trc_gps_desc = @V_GPSLOCATION, 
				    trc_gps_date = @V_fecha  
				where 	trc_gps_date <= @V_fecha and trc_number = @V_economico




		
			END --cuando valida si la antena es dif al numero economico
				-- Elimina los renglones de la tabla de paso
		--		delete QSP..TPosicion 
		--		where  QSP..TPosicion.idTransaccion = @V_idTransaccion;
				-- marca cada uno de los registros para que se eliminen despues.
				Update QSP..TPosicion Set velocidad = 1
				where  QSP..TPosicion.idTransaccion = @V_idTransaccion


		FETCH NEXT FROM Posiciones_Cursor INTO @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_economico, @V_ignicion, @V_proximidadPoblacion, @V_TIPOCUENTA, @V_ANTENA
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 

	


END -- 2 si hay movimientos del RC

END --1 Principal


GO
