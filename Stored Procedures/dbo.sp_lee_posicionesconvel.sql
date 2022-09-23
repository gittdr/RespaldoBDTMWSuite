SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los movimientos que inserta Qualcomm
-- y pasarlos a la tabla checkcall.
--DROP PROCEDURE sp_lee_posicionesconvel
--GO

--exec sp_lee_posicionesconvel

CREATE   PROCEDURE [dbo].[sp_lee_posicionesconvel]
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
	@V_evento		Varchar(10),
	@V_lugar		Varchar(100),
	@V_tipolugar		varchar(50),
	@V_aliaslugar		Varchar(100),
	@V_IDOPERA		Varchar(10),
	@V_ENC_APAG		Char(1),
	@V_CONSECCKC		BigInt,
	@V_EVENTOYLUGAR		Varchar(200),
	@V_TIPOCUENTA		Int,
	@V_DESCRIPCTA		Varchar(50),
	@V_CODEEVENTO		Varchar(6),
	@li_tbl_SN			INT,
	@ls_nombreflota			Varchar(30),
	@ls_comentarioAct		Varchar(254),
	@li_inboxflota			INT,
	@li_defaultdriver		INT,
	@li_flota			INT,
	@lsContenido			Varchar(100),
	@lsSubject			Varchar(100),
	@liFolder 			INT,
	@lsDeliverTo			Varchar(10),
	@V_velocidad			INT


DECLARE @TTPosc_QC TABLE(
		Pos_idtransaccion	BigInt not null,
		Pos_tractor		Varchar(50) NULL,
		Pos_latseconds		Float null,
		Pos_longseconds		Float null,
		Pos_comment		Varchar(500) NULL,
		Pos_vehicleignition	Varchar(10) NULL,
		Pos_velocidad		integer NULL,
		Pos_date		DateTime null)




BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de TPosicion
INSERT Into @TTPosc_QC 
	SELECT 	TPOS.idTransaccion, 
		TPOS.economico,  
		TPOS.latitud, 
		TPOS.longitud, 
		TPOS.proximidadCiudad, 
		TPOS.ignicion,
		TPOS.velocidad,
		TPOS.fecha
	FROM  QSP..TPosicion TPOS (NOLOCK)
	WHERE TPOS.cuenta = 3 and TPOS.Fecha > '09-15-2011 17:00:00' and
	TPOS.ProximidadPI is null


-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTPosc_QC )
	BEGIN --3 Si hay movimientos de posiciones

		
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Geoposiciones_Cursor CURSOR FOR 
		SELECT Pos_idtransaccion, Pos_tractor, Pos_latseconds, Pos_longseconds, Pos_comment, Pos_vehicleignition, Pos_velocidad, Pos_date
		FROM @TTPosc_QC 
	
		OPEN Geoposiciones_Cursor 
		FETCH NEXT FROM Geoposiciones_Cursor INTO @V_idTransaccion, @V_economico,  @V_latitud, @V_longitud, @V_proximidadCiudad, @V_ignicion, @V_velocidad, @V_fecha
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- del cursor Unidades_Cursor --3
		SELECT  @V_idTransaccion, @V_economico,  @V_latitud, @V_longitud, @V_proximidadCiudad, @V_ignicion, @V_velocidad, @V_fecha
		
		-- Busca el ID del operador segun su unidad
		SELECT @V_IDOPERA = IsNull(trc_driver,'XXX')
		FROM tmwSuite..tractorprofile 
		WHERE trc_number = @V_economico;



		-- Define si esta Apagado o Encendido el motor
		IF upper(@V_ignicion) = 'ENCENDIDO'
		Begin
			Select @V_ENC_APAG = 'Y'
		End
		IF Upper(@V_ignicion) = 'APAGADO'
		Begin
			Select @V_ENC_APAG = 'N'
		End

		



		-- Junta el Evento y el lugar.
		Select @V_EVENTOYLUGAR	= IsNull(@V_evento,' ')+ ' ' + IsNull(@V_lugar,' ') + ' '+IsNull(@V_aliaslugar,'') + IsNull(@V_DESCRIPCTA,'')


		-- Multiplica por 3600 latitud y longitud
		Select @V_latitud	=	@V_latitud * 3600
		Select @V_longitud	=	@V_longitud * -3600


		

		-- Lee el consecutivo de los checkcall para hacer el insert a la tabla.					
		execute @V_CONSECCKC = tmwSuite..getsystemnumber_gateway N'CKCNUM' , NULL , 1 
		-- Inserta el nuevo checkcall
		
		Insert tmwSuite..checkcall(
		ckc_number, ckc_status, ckc_asgntype, ckc_asgnid, ckc_date, ckc_event, ckc_city, ckc_comment, 
		ckc_updatedby, ckc_updatedon, ckc_latseconds, ckc_longseconds, ckc_lghnumber, ckc_tractor, ckc_extsensoralarm, ckc_vehicleignition, 
		ckc_milesfrom, ckc_directionfrom, ckc_validity, ckc_mtavailable, ckc_minutes, ckc_mileage, ckc_home, ckc_cityname, 
		ckc_state, ckc_zip, ckc_commentlarge, ckc_minutes_to_final, ckc_miles_to_final, ckc_Odometer, TripStatus, ckc_odometer2, 
		ckc_speed, ckc_speed2, ckc_heading, ckc_gps_type, ckc_gps_miles, ckc_fuel_meter, ckc_idle_meter)
		Values (@V_CONSECCKC, 'HIST', 		'DRV', 	@V_IDOPERA,	@V_fecha, 	'CHK', 		0, 	'Velocidad... '+ Convert(varchar(10),@V_velocidad),
			'QA', 		GetDate(), 	@V_latitud,	@V_longitud, 		0, 		@V_economico, 	Null, 	@V_ENC_APAG, 
			1,		Null, 		Null, 	Null, 		0, 		0, 		Null, 	Null, 
			Null, 		Null, 		left(@V_proximidadCiudad,254), 		0,		0,		0,		0,	0,		
			Null, 		Null, 		Null, 	Null, 		Null, 		Null, 		Null)			


		-- Elimina los renglones de la tabla de paso
--		delete QSP..TEventoGeocerca 
--		where  QSP..TEventoGeocerca.idTransaccion = @V_idTransaccion;
		-- Marca la georeferencia para despues borrarla.
		Update QSP..TPosicion Set ProximidadPI = 'E'
		where  QSP..TPosicion.idTransaccion = @V_idTransaccion;



		FETCH NEXT FROM Geoposiciones_Cursor INTO @V_idTransaccion, @V_economico,  @V_latitud, @V_longitud, @V_proximidadCiudad, @V_ignicion, @V_velocidad, @V_fecha
	
	END --3 curso de los movimientos 

	CLOSE Geoposiciones_Cursor 
	DEALLOCATE Geoposiciones_Cursor 

END -- 2 si hay movimientos del RC

END --1 Principal

GO
