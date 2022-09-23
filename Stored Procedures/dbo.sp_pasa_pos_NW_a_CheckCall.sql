SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los movimientos que inserta NAVMAN
-- y pasarlos a la tabla checkcall.
-- NO RECIBE PARAMETROS.
--GO
--modificador por Emolvera
--ult modificacion 3/19/15 1.17 pm

--  exec sp_pasa_pos_NW_a_CheckCall

CREATE PROCEDURE [dbo].[sp_pasa_pos_NW_a_CheckCall]
AS


-----------------------------------------------------DECLARACION DE VARIABLES Y DE TABLA TEMPORAL PARA CONTENER DATOS---------------------------------------------------------------------------------------------------

DECLARE	
	@V_idTransaccion 	uniqueidentifier, 
	@V_fecha		Datetime, 
	@V_proximidadCiudad	Varchar(500), 
	@V_latitud		Float, 
	@V_longitud		Float, 
	@V_economico		varchar(10), 
	@V_ignicion		Varchar(10), 
	@V_proximidadPoblacion	Varchar(500),
	@V_evento		Varchar(10),
	@V_lugar		Varchar(100),
	@V_tipolugar		varchar(50),
	@V_aliaslugar		Varchar(100),
	@V_IDOPERA		Varchar(10),
	@V_ENC_APAG		Char(1),
	@V_CONSECCKC		BigInt,
	@V_EVENTOYLUGAR		Varchar(500),
	@V_DESCRIPCTA		Varchar(50),
	@V_CODEEVENTO		Varchar(6),
	@V_TIPOCUENTA		int,
	@V_ANTENA		Varchar(50),
	@V_GPSLOCATION		Varchar(500),
	@V_velocidad		Float,
	@V_registros		integer,
	@V_i				integer,
	@V_NombreSitio		Varchar(500),
	@V_lastckc          Varchar(500),
	@V_Comentario		Varchar(500),
	@V_tipoevent         varchar(4),
	@V_dato_vel			varchar(4),
	@V_tiempo_sitio		float




DECLARE @TTGeos_QC TABLE(
		QC_idtransaccion	uniqueidentifier ,
		QC_date			DateTime null,
		QC_comment		Varchar(500) NULL,
		QC_latseconds		Float null,
		QC_longseconds		Float null,
		QC_tractor		varchar(10) NULL,
		QC_vehicleignition	Varchar(10) NULL,
		QC_commentlarge		Varchar(500) NULL,
		QC_Evento		Varchar(10) NULL,
		QC_velocidad		float  NULL,
		QC_aliaslugar		Varchar(100) NULL,
		QC_tipoLugar		Varchar(50) Null,
		QC_nombreSitio VARCHAR(500),
		QC_tiempoenSitio float)



---------------------------------------------------------VALIDACION DE SI SE CAEN LAS POSICIONES POR MAS DE 20 MINUTOS MANDE CORREO AVISANDO---------------------------------------------------


if   (select max(activitydatetime) from qsp.dbo.NWActivity  with (nolock)) <=  (select DATEADD([minute],-20,getdate() )) 

/*------------------NUEVO SERVICIO DE INTEGRACION NAVMAN-----------------------------------------------------------------------
if   (select
CONVERT(datetime, 
               SWITCHOFFSET(CONVERT(datetimeoffset, 
                                    max(activitydatetime)), 
                            DATENAME(TzOffset, SYSDATETIMEOFFSET()))) 
 from [QSP].[dbo].[navman_ic_api_activitylogreal]  with (nolock)) <=  (select DATEADD([minute],-20,getdate() )) 
----------------------------------------------------------------------------------------------------------------------------*/


 BEGIN


	if ((select enviado_navman from  QSP.dbo.QFS_mailflag) = 'No')
	 BEGIN
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'smtp TDR',
        @recipients = 'emolvera@tdr.com.mx;jmartinez@tdr.com.mx;esuderia4@tdr.com.mx;jrlopez@tdr.com.mx',
        @body = 'SE perdio la conexion con el servidor NAVMAN, se esta intentando re-conectar' ,
        @subject = 'Sin posiciones en Checkcalls NAVMAN',
        @attach_query_result_as_file = 0 ;

     
        --si entro al ciclo marcamos la bandera para avisar que se mando el correo.
        update QSP.dbo.NWmailflag set enviado_navman = 'Si'

    END

 END

ELSE 



-----------------------------------------------CARGARMOS LA TABLA TEMPORAL CON LAS POSICIONES DE ACTIVITY Y VEHICLE-----------------------------------------------------------------------------------------------------


BEGIN --1 Principal

            -- Cambiamos la bandera para el proceso que avisa si se caen la posiciones.
	        update QSP.dbo.NWmailflag set enviado_navman = 'No'
 
		
			INSERT Into @TTGeos_QC 

			SELECT top (1000)	QF.idActivity, 
					QF.receivedDateTime, 
					substring(QF.location,1,499), 
					abs(QF.latitude*3600), 
					abs(QF.longitud*3600), 
					substring(v.displayName,1,9),
					QF.ignitionOn, 
					substring(QF.location,0,500) ,
					1,
					QF.Speed,
					substring(QFS.displayName,1,499),
					3 tipolugar,
					substring(QFS.displayName,1,499),
					onSiteTime --- se inserta en la varible float tiempoensitio
			FROM QSP..NWVehicles v with (nolock), 
			QSP..NWActivity  QF  with (nolock) left join QSP..NWSites QFS with (nolock) on (QF.SiteId = QFS.SiteId  )
				where v.vehicleId=QF.vehicleId
				and QF.leido = 'no'
					 and 
					  not (v.displayName) is null and
					  QF.receivedDateTime > DateAdd(dd, -1,getdate()) 




---------------------------------------------------CURSOR QUE RECORRE LA TABLA TEMPORAL DE POSICIONES Y LAS INSERTA EN TRACTORPROFILE Y CHECKCALL-----------------------------------------------------------------------------------------------------------------------------------------
					
			-- Si hay movimientos en la tabla continua
				If Exists ( Select count(*) From  @TTGeos_QC )
				BEGIN --2 Si hay movimientos de posiciones
							-- Se declara un curso para ir leyendo la tabla de paso
							DECLARE Geoposiciones_Cursor CURSOR FOR 
							SELECT QC_idtransaccion, QC_date, QC_comment, QC_latseconds, QC_longseconds, QC_tractor, QC_vehicleignition, QC_commentlarge, QC_Evento, QC_velocidad, QC_aliaslugar,  QC_tipoLugar, QC_nombreSitio,QC_tiempoenSitio
							FROM @TTGeos_QC 
	
							OPEN Geoposiciones_Cursor 
							FETCH NEXT FROM Geoposiciones_Cursor INTO @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_economico, @V_ignicion, @V_proximidadPoblacion, @V_evento , @V_velocidad , @V_aliaslugar, @V_tipolugar, @V_NombreSitio, @V_tiempo_sitio	     
							WHILE @@FETCH_STATUS = 0 
							BEGIN -- del cursor Unidades_Cursor --3
									

										-- Busca el ID del operador segun su unidad
										SELECT @V_IDOPERA = IsNull(trc_driver,'XXX')
										FROM TmwSuite..tractorprofile (nolock)
										WHERE trc_number = @V_economico;

										-- Define si esta Apagado o Encendido el motor
										IF upper(@V_ignicion) = '1'
										Begin
											Select @V_ENC_APAG = 'Y'
										End
										IF Upper(@V_ignicion) = '0'
										Begin
											Select @V_ENC_APAG = 'N'
										End


										-- Junta el Evento y el lugar.
										Select @V_EVENTOYLUGAR	= IsNull(@V_lugar,' ') + ' '+IsNull(@V_aliaslugar,'') + IsNull(@V_DESCRIPCTA,'')
										Select @V_nombresitio	= IsNull(@V_nombresitio,' ') 
										Select @V_lastckc =  (select  rtrim(replace(replace(trc_lastpos_nearctynme,'[',''),']','')) from tmwsuite.dbo.tractorprofile (nolock) where trc_number =  @V_economico) 
										select @V_dato_vel = convert(varchar(4),@V_velocidad)



-----------------------------------------SE ARMA LA CADENA DE TEXTO PARA CAMPO COMENTARIO:  CASO EN EL CUAL LA POSICION ES UN SITIO ------------------------------------------------------------------------------------------------------

											IF @V_NombreSitio != ' '

	
												Begin

												 
												    Select @V_tipoevent = 'SIT'
													Select @V_NombreSitio = '['+@V_NombreSitio+'] '
					
													SELECT @V_GPSLOCATION 	= left(@V_NombreSitio + ' Vel. '+cast(@V_dato_vel as varchar (4)) ,255)
													

													---SI LA ULTIMA POS ES EN CALLE Y LA PROXIMA ES EN SITIO ESTA ENTRANDO.
													if @V_lastckc = ''
													  BEGIN
                                                       SELECT @V_Comentario = 'Entrando a: '  + left(('[' + @V_ENC_APAG + '] '  + @V_NombreSitio+ ' Vel. '+cast( @V_dato_vel as varchar(4))+' | '+ cast(round(@V_tiempo_sitio/3600.0,2) as varchar(20)) + 'hrs.'), 254)
													  END
													 ELSE
													 --SI LA ULTIMA POS ES EN SITIO Y LA PROXIMA ES EN SITIO, PERMANECE EN SITIO.
													  BEGIN
													    SELECT @V_Comentario = left(('[' + @V_ENC_APAG + '] '  + @V_NombreSitio+ ' Vel. '+cast( @V_dato_vel as varchar(4))+' | '+ cast(round(@V_tiempo_sitio/3600.0,2) as varchar(20)) + 'hrs.'), 254)
													  END
												End
											Else

-----------------------------------------SE ARMA LA CADENA DE TEXTO PARA CAMPO COMENTARIO: CASO EN EL CUAL LA POSICION NO ES UN SITIO-----------------------------------------------------------------------------------------------------
												
												Begin
												    
													--SI LA ULTIMA POS ES EN SITIO Y LA PROXIMA ES EN CALLE, SALE DE SITIO.
													if @V_lastckc <> ''
													 BEGIN
													   Select @V_tipoevent = 'SIT'
													   Select @V_Comentario = 'Saliendo de: ' +  '[' + @V_ENC_APAG + '] ' +  left(('[' + @V_lastckc + '] '  + ' Vel. '+cast(@V_dato_vel as varchar(4))),254)
													 END
													ELSE
													  BEGIN
													  --SI LA ULTIMA POS ES EN CALLE Y LA PROXIMA ES EN CALLE, PERMANECE EN CALLE.
													   Select @V_tipoevent = 'TRP'
													   Select @V_Comentario =  left(('[' + @V_ENC_APAG + '] '+ left(@V_proximidadCiudad,254) + ' Vel. '+cast(@V_dato_vel as varchar(4))),254)
													 END
												End

											


--------------------------------------------------SE ACTUALIZA TRACTORPROFILE: gps desc, date, lastlong-ctyname, gps_vel----------------------------------------------------------------------------------------

									   -- Se actualiza en el catalogo de las unidades la ultima ubicacion
										-- siempre y cuando la fecha sea mayor de la que tiene.

										

											IF (@V_GPSLOCATION != NULL)
											 BEGIN
													update tmwSuite..tractorprofile 
													set trc_gps_desc = @V_Comentario,
														trc_gps_date = @V_fecha,
														trc_gps_longitude = @V_longitud,
														trc_gps_latitude =  @V_latitud,
														trc_lastpos_nearctynme =  isnull(cast(@V_NombreSitio as varchar(30)),''),
                                                        trc_gps_speed = @V_dato_vel,
														trc_geo_process_oo = cast(@V_ENC_APAG  as char (1)),
														trc_gps_heading = ((@V_tiempo_sitio/60)/60)
													where 	trc_gps_date <= @V_fecha and trc_number = @V_economico
												

											 END
											Else 
											 BEGIN
													update tmwSuite..tractorprofile 
													set trc_gps_desc = @V_Comentario, 
														trc_gps_date = @V_fecha,
														trc_gps_longitude = @V_longitud,
														trc_gps_latitude =  @V_latitud,
														trc_lastpos_nearctynme =  isnull(cast(@V_NombreSitio as varchar(30)),''),
														trc_gps_speed = @V_dato_vel,
														trc_geo_process_oo =  cast(@V_ENC_APAG  as char (1)),
														trc_gps_heading =  ((@V_tiempo_sitio/60)/60)

													where 	trc_gps_date <= @V_fecha and trc_number = @V_economico
												
											 END



--------------------------------------------------SE ACTUALIZA MANPOWERPROFILE: gps desc, gps time---------------------------------------------------------------------------------------				
								
								Update TmwSuite..manpowerprofile  
								Set mpp_gps_desc	=	left(@V_proximidadCiudad,45 ), 
									mpp_gps_date	=	@V_fecha
								Where mpp_gps_date <= @V_fecha and mpp_tractornumber = @V_economico




--hasta aqui corre en cuestion de milisegundos
-------------------------------------------------------------CHECKCALL------------------------------------------------------------------------------------------------------------------------------


										-- Lee el consecutivo de los checkcall para hacer el insert a la tabla.					
										execute @V_CONSECCKC = TmwSuite..getsystemnumber_gateway N'CKCNUM' , NULL , 1 
	

--hasta aqui tarda 4 segundos en correrl
--el problema esta en la tabla de checkcalls ya que es muy pesada
-- debemos solo mantener 1 mes de posiciones a lo mucho

										-- Inserta el nuevo checkcall
	
	
										Insert TmwSuite..checkcall(
										ckc_number, ckc_status, ckc_asgntype, ckc_asgnid, ckc_date, ckc_event, ckc_city, ckc_comment, 
										ckc_updatedby, ckc_updatedon, ckc_latseconds, ckc_longseconds, ckc_lghnumber, ckc_tractor, ckc_extsensoralarm, ckc_vehicleignition, 
										ckc_milesfrom, ckc_directionfrom, ckc_validity, ckc_mtavailable, ckc_minutes, ckc_mileage, ckc_home, ckc_cityname, 
										ckc_state, ckc_zip, ckc_commentlarge, ckc_minutes_to_final, ckc_miles_to_final, ckc_Odometer, TripStatus, ckc_odometer2, 
										ckc_speed, ckc_speed2, ckc_heading, ckc_gps_type, ckc_gps_miles, ckc_fuel_meter, ckc_idle_meter)
										Values (@V_CONSECCKC, 'HIST', 		'DRV', 	@V_IDOPERA,	@V_fecha, 	@V_tipoevent , 		0, 	@V_Comentario,    --	left(@V_proximidadCiudad,254 ),
											'NW', 		GetDate(), 	@V_latitud,	@V_longitud, 		0, 		@V_economico, 	Null, 	@V_ENC_APAG, 
											1,		Null, 		Null, 	Null, 		0, 		0, 		Null, 	Null, 
											Null, 		Null, 		left(@V_proximidadCiudad,250), 		0,		0,		0,		0,	0,		
											@V_dato_vel, 		Null, 		Null, 	Null, 		Null, 		Null, 		Null)			

									-- Marca la georeferencia para despues borrarla.
										Update QSP..NWActivity Set leido = 'Si' where  QSP..NWActivity.idActivity = @V_idTransaccion
							
								


							

 									

							FETCH NEXT FROM Geoposiciones_Cursor INTO @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_economico, @V_ignicion, @V_proximidadPoblacion, @V_evento , @V_velocidad , @V_aliaslugar, @V_tipolugar, @V_NombreSitio, @V_tiempo_sitio	 
						END --3 curso de los movimientos 
									CLOSE Geoposiciones_Cursor 
									DEALLOCATE Geoposiciones_Cursor 

			END -- 2 si hay movimientos del RC

END --1 Principal

GO
