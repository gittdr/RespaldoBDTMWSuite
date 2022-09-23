SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los movimientos que inserta Qualcomm
-- y pasarlos a la tabla checkcall.
--DROP PROCEDURE sp_lee_geopos_qualcomm
--GO

--exec sp_lee_geopos_qualcomm

CREATE   PROCEDURE [dbo].[sp_lee_geopos_qualcomm]
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
	@liOrden			INT,
	@lstpnumber			Int


DECLARE @TTGeos_QC TABLE(
		QC_idtransaccion	BigInt not null,
		QC_date			DateTime null,
		QC_comment		Varchar(500) NULL,
		QC_latseconds		Float null,
		QC_longseconds		Float null,
		QC_tractor		Varchar(50) NULL,
		QC_vehicleignition	Varchar(10) NULL,
		QC_commentlarge		Varchar(500) NULL,
		QC_Evento		Varchar(10) NULL,
		QC_lugar		Varchar(100) NULL,
		QC_aliaslugar		Varchar(100) NULL,
		QC_cuenta		integer null,
		QC_tipoLugar		Varchar(50) Null)




BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de GeoPosiciones
INSERT Into @TTGeos_QC 
	SELECT 	GEO.idTransaccion, 
		GEO.fecha, 
		GEO.proximidadCiudad, 
		GEO.latitud, 
		GEO.longitud, 
		GEO.economico, 
		GEO.ignicion, 
		GEO.proximidadPoblacion,	
		GEO.Evento,
		GEO.lugar,
		GEO.aliaslugar,
		GEO.cuenta,
		GEO.TipoLugar
	FROM  QSP..TEventoGeocerca GEO (NOLOCK)
	WHERE GEO.ProximidadPI Is null AND
	      GEO.antena <> GEO.economico and 
	      GEO.cuenta <> 2 and 
                   GEO.tipoLugar <>  'restrictedLocation'


-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTGeos_QC )
	BEGIN --3 Si hay movimientos de posiciones

		
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Geoposiciones_Cursor CURSOR FOR 
		SELECT QC_idtransaccion, QC_date, QC_comment, QC_latseconds, QC_longseconds, QC_tractor, QC_vehicleignition, QC_commentlarge, QC_Evento, QC_lugar, QC_aliaslugar, QC_cuenta, QC_tipoLugar 
		FROM @TTGeos_QC 
	
		OPEN Geoposiciones_Cursor 
		FETCH NEXT FROM Geoposiciones_Cursor INTO @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_economico, @V_ignicion, @V_proximidadPoblacion, @V_evento , @V_lugar , @V_aliaslugar,@V_TIPOCUENTA , @V_tipolugar
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- del cursor Unidades_Cursor --3
		SELECT @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_economico, @V_ignicion, @V_proximidadPoblacion, @V_evento , @V_lugar , @V_aliaslugar, @V_TIPOCUENTA , @V_tipolugar
		
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

		-- Define el tipo de Evento
		IF upper(@V_evento) = 'ENTRANDO'
		Begin
			Select @V_CODEEVENTO = 'GEOENT'
		End
		IF Upper(@V_evento) = 'SALIENDO'
		Begin
			Select @V_CODEEVENTO = 'GEOSAL'
		End

		

		-- Se identifica el tipo de cuenta para identificar el tipo de sistema localizador
		-- sistema 1 QSP, 2 OTS/ATF
				IF @V_TIPOCUENTA = 1
				Begin
					Select @V_DESCRIPCTA = ' Sis-QSP'+' '+'[ING: '+@V_ENC_APAG + ']'
				End
				IF @V_TIPOCUENTA = 2
				Begin
					Select @V_DESCRIPCTA = ' Sis-OTS/ATF'+' '+'[ING: '+@V_ENC_APAG + ']'
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
		Values (@V_CONSECCKC, 'HIST', 		'DRV', 	@V_IDOPERA,	@V_fecha, 	@V_CODEEVENTO, 		0, 	left(@V_EVENTOYLUGAR,254 ),
			'QA', 		GetDate(), 	@V_latitud,	@V_longitud, 		0, 		@V_economico, 	Null, 	@V_ENC_APAG, 
			1,		Null, 		Null, 	Null, 		0, 		0, 		Null, 	Null, 
			Null, 		Null, 		left(@V_proximidadCiudad,254), 		0,		0,		0,		0,	0,		
			Null, 		Null, 		Null, 	Null, 		Null, 		Null, 		Null)			


					-- Inserta el mensaje para que se vaya a TotalMail.
-------------------------------------------------- Codigo para inserta mensaje en TotalMail

					IF Exists (SELECT Trucks.SN FROM tmwSuite..tblTrucks Trucks, tmwSuite..tblCabUnits Cab WHERE 	Trucks.Truckname = @V_economico  and Cab.SN = Trucks.DefaultCabUnit)
					Begin					
					-- Toma la configuración de la Unidad
						SELECT @li_tbl_SN = Trucks.SN, @li_defaultdriver = Trucks.DefaultDriver, 
						@liFolder = Trucks.Inbox,  @lsDeliverTo = Cab.UnitID,
						@li_flota = Trucks.CurrentDispatcher
						FROM tmwSuite..tblTrucks Trucks, tmwSuite..tblCabUnits Cab 
						WHERE 	Trucks.Truckname = @V_economico  and Cab.SN = Trucks.DefaultCabUnit
					
					-- Toma el nombre de la flota
						SELECT @ls_nombreflota = flota.Name, @li_inboxflota = Inbox 
						FROM tmwSuite..tblDispatchGroup flota 
						WHERE SN = @li_flota
												
									
						Select @lsSubject 	=  'QA '+' '+left(@V_EVENTOYLUGAR,100 )
							
						Select @lsSubject =Left(@lsSubject, 255)

						Select @lsContenido	=  left(@V_EVENTOYLUGAR,100 )

						-- Insert el mensaje en la carpeta de la unidad 
						INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
						Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN)
						Values(5, 1, 1, 4, 3, @V_fecha, GetDate(), @liFolder, @lsContenido, @V_economico, @lsSubject , @ls_nombreflota, @li_tbl_SN, @li_defaultdriver)

						-- Insert el mensaje en la carpeta general
						INSERT INTO tmwSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
						Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN )
						Values(4, 1, 1, 4, 3, @V_fecha, GetDate(),  @li_inboxflota, @lsContenido, @V_economico, @lsSubject , @ls_nombreflota , @li_tbl_SN, @li_defaultdriver)


					END
					
------------------------------------ Codigo para inserta mensaje en TotalMail



		-- Se actualiza tambien en el catalogo de las unidades la ultima ubicacion
		-- siempre y cuando la fecha sea mayor de la que tiene.

		update tractorprofile 
		set trc_gps_desc = @V_EVENTOYLUGAR, 
		    trc_gps_date = @V_fecha  
		where 	trc_gps_date <= @V_fecha and trc_number = @V_economico

-- Es necesario Actualizar la ubicacion del operador tambien
-- 15-Abril 2013 JR

Update manpowerprofile  
Set mpp_gps_desc	=	@V_EVENTOYLUGAR, 
	mpp_gps_date	=	@V_fecha
Where mpp_gps_date <= @V_fecha and mpp_tractornumber = @V_economico
 



		-- Elimina los renglones de la tabla de paso
--		delete QSP..TEventoGeocerca 
--		where  QSP..TEventoGeocerca.idTransaccion = @V_idTransaccion;
		-- Marca la georeferencia para despues borrarla.
		Update QSP..TEventoGeocerca Set ProximidadPI = 'E'
		where  QSP..TEventoGeocerca.idTransaccion = @V_idTransaccion;


/******** Proceso para actualizar la Orden actual del driver  ***********/
/*
		-- Pregunta si tiene Alias.
		IF NOT @V_aliaslugar Is Null and @V_tipolugar = 'Customer'
		Begin -- Cuando tiene Alias
			-- Obtenemos el numero de la orden.
			SELECT  @liOrden = IsNull(max(ord_hdrnumber),0)  
			FROM TmwSuite..orderheader 
			WHERE ord_tractor = @V_economico and ord_status not in ('CAN','CMP');
	
			IF @liOrden > 0 
				Begin -- Cuando encontro Numero de Orden
					--Revisa que tipo de evento es: Entrada o salida.
					IF @V_evento = 'Entrando'
					Begin --Cuando va entrando
						If Exists ( SELECT min(stp_number)
							FROM TmwSuite..stops 
							Where 	ord_hdrnumber = @liOrden and 
								stp_status = 'OPN' and cmp_id = @V_aliaslugar)
						BEGIN -- Cuando va entrando y existe el Stop.
							SELECT @lstpnumber = IsNull(Min(stp_number),0)
							FROM TmwSuite..stops 
							Where 	ord_hdrnumber = @liOrden and 
								stp_status = 'OPN' and cmp_id = @V_aliaslugar
							-- y la fecha del stop
							Update TmwSuite..stops 
							Set stp_schdtearliest = @V_fecha
							Where 	ord_hdrnumber = @liOrden and 
								stp_number = @lstpnumber;
							-- actualiza la fecha inicial del evento.
							Update TmwSuite..event 
							Set evt_startdate = @V_fecha
							where 	ord_hdrnumber = @liOrden and 
								stp_number = @lstpnumber

							Update QSP..TEventoGeocerca Set Observaciones = 'E-No Orden '+convert(varchar(6), @liOrden)
							where  QSP..TEventoGeocerca.idTransaccion = @V_idTransaccion and cuenta = 2;

						End --cuando va entrando y existe el stop
						Else --Cuando va entrando y NO existe el stop
							-- Marca la georeferencia que no tiene Stop
							begin
							Update QSP..TEventoGeocerca Set Observaciones = 'Entrando y no esta el Stop, Orden No.'+convert(varchar(6), @liOrden)
							where  QSP..TEventoGeocerca.idTransaccion = @V_idTransaccion  and cuenta = 2;
							end
					End --cuando va entrando

					IF @V_evento = 'Saliendo'
					Begin --cuando va saliendo
						If Exists ( SELECT Min(stp_number)
							FROM TmwSuite..stops 
							Where 	ord_hdrnumber = @liOrden and 
								stp_status = 'OPN' and cmp_id = @V_aliaslugar)
						BEGIN --cuando va saliendo y existe el Stop
							SELECT @lstpnumber = IsNull(Min(stp_number),0)
							FROM TmwSuite..stops 
							Where 	ord_hdrnumber = @liOrden and 
								stp_status = 'OPN' and cmp_id = @V_aliaslugar

							-- y la fecha del stop
							Update TmwSuite..stops 
							Set stp_schdtlatest = @V_fecha, stp_status = 'DNE'
							Where 	ord_hdrnumber = @liOrden and 
								stp_number = @lstpnumber;
							
							-- actualiza la fecha final del evento.
							Update TmwSuite..event 
							Set evt_enddate = @V_fecha
							where 	ord_hdrnumber = @liOrden and 
								stp_number = @lstpnumber

							Update QSP..TEventoGeocerca Set Observaciones = 'S-No Orden '+convert(varchar(6), @liOrden)
							where  QSP..TEventoGeocerca.idTransaccion = @V_idTransaccion  and cuenta = 2;

						End --Cuando va saliendo y existe el Stop
						Else -- cuando va saliendo y NO existe el stop
							-- Marca la georeferencia que no tiene Stop
							begin
							Update QSP..TEventoGeocerca Set Observaciones = 'Saliendo y no esta el Stop, Orden No.'+convert(varchar(6), @liOrden)
							where  QSP..TEventoGeocerca.idTransaccion = @V_idTransaccion  and cuenta = 2;
							end



					End --cuando va saliendo



				End -- Cuando encontro Numero de Orden
				Else -- Cuando no encontro numero de orden
				-- Marca la georeferencia que no tiene alias
				begin
				Update QSP..TEventoGeocerca Set Observaciones = 'No encontro No. de Orden...'
				where  QSP..TEventoGeocerca.idTransaccion = @V_idTransaccion  and cuenta = 2;
				end

		End -- Cuando tiene Alias
		ELSE	--Else -- cuando no tiene alias.
			IF  @V_tipolugar = 'Customer'
			-- Marca la georeferencia que no tiene alias
			begin
			Update QSP..TEventoGeocerca Set Observaciones = 'No tiene Alias...'
			where  QSP..TEventoGeocerca.idTransaccion = @V_idTransaccion  and cuenta = 2;
			end



		FETCH NEXT FROM Geoposiciones_Cursor INTO @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_economico, @V_ignicion, @V_proximidadPoblacion, @V_evento , @V_lugar , @V_aliaslugar, @V_TIPOCUENTA , @V_tipolugar
*/	
	END --3 curso de los movimientos 

	CLOSE Geoposiciones_Cursor 
	DEALLOCATE Geoposiciones_Cursor 

END -- 2 si hay movimientos del RC

END --1 Principal

GO
