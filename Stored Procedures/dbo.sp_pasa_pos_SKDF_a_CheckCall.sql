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

CREATE PROCEDURE [dbo].[sp_pasa_pos_SKDF_a_CheckCall]
AS


-----------------------------------------------------DECLARACION DE VARIABLES Y DE TABLA TEMPORAL PARA CONTENER DATOS---------------------------------------------------------------------------------------------------

DECLARE	
	@V_idTransaccion 	uniqueidentifier, 
	@V_fecha		Datetime, 
	@V_proximidadCiudad	Varchar(255), 
	@V_latitud		Float, 
	@V_longitud		Float, 
	@V_economico		varchar(10), 
	@V_ignicion		Varchar(10), 
	@V_proximidadPoblacion	Varchar(255),
	@V_evento		Varchar(10),
	@V_lugar		Varchar(100),
	@V_tipolugar		varchar(50),
	@V_aliaslugar		Varchar(100),
	@V_IDOPERA		Varchar(10),
	@V_ENC_APAG		Char(1),
	@V_CONSECCKC		BigInt,
	@V_EVENTOYLUGAR		Varchar(200),
	@V_DESCRIPCTA		Varchar(50),
	@V_CODEEVENTO		Varchar(6),
	@V_TIPOCUENTA		int,
	@V_ANTENA		Varchar(50),
	@V_GPSLOCATION		Varchar(255),
	@V_velocidad		Float,
	@V_registros		integer,
	@V_i				integer,
	@V_NombreSitio		Varchar(500),
	@V_lastckc          Varchar(500),

	@V_Comentario		Varchar(255),
	@V_tipoevent         varchar(4),
	@V_dato_vel			varchar(4),
	@V_tiempo_sitio		float




DECLARE @TTGeos_QC TABLE(
		QC_idtransaccion	uniqueidentifier ,
		QC_date			DateTime null,
		QC_comment		Varchar(255) NULL,
		QC_latseconds		Float null,
		QC_longseconds		Float null,
		QC_tractor		varchar(10) NULL,
		QC_vehicleignition	Varchar(10) NULL,
		QC_commentlarge		Varchar(255) NULL,
		QC_Evento		Varchar(10) NULL,
		QC_velocidad		float  NULL,
		QC_aliaslugar		Varchar(100) NULL,
		QC_tipoLugar		Varchar(50) Null,
		QC_nombreSitio VARCHAR(500),
		QC_tiempoenSitio float)



---------------------------------------------------------VALIDACION DE SI SE CAEN LAS POSICIONES POR MAS DE 20 MINUTOS MANDE CORREO AVISANDO---------------------------------------------------


if   (select max(activitydatetime) from [QSP].[dbo].[SKFActivity]  with (nolock)) <=  (select DATEADD([minute],-20,getdate() )) 

 BEGIN


	if ((select enviado_skydefense from  QSP.dbo.QFS_mailflag) = 'No')
	 BEGIN
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'smtp TDR',
        @recipients = 'emolvera@tdr.com.mx;jmartinez@tdr.com.mx;esuderia4@tdr.com.mx;jrlopez@tdr.com.mx',
        @body = 'SE perdio la conexion con el servidor SKYDEFENSE, se esta intentando re-conectar' ,
        @subject = 'Sin posiciones en Checkcalls SKYDEFENSE',
        @attach_query_result_as_file = 0 ;

     
        --si entro al ciclo marcamos la bandera para avisar que se mando el correo.
        update QSP.dbo.QFS_mailflag set enviado_skydefense = 'Si'

    END

 END

ELSE 



-----------------------------------------------CARGARMOS LA TABLA TEMPORAL CON LAS POSICIONES DE ACTIVITY Y VEHICLE-----------------------------------------------------------------------------------------------------


BEGIN --1 Principal

            -- Cambiamos la bandera para el proceso que avisa si se caen la posiciones.
	        update QSP.dbo.QFS_mailflag set  enviado_skydefense  = 'No'
 
		

			
			INSERT Into @TTGeos_QC 

			SELECT 	QF.idActivity, 
					QF.receivedDateTime, 
					QF.location, 
					abs(QF.latitude*3600), 
					abs(QF.longitud*3600),  
					replace(QF.vehicleid,'TDR ',''), 
					QF.ignitionOn, 
					QF.location,
					1,
					isnull(QF.Speed,0),
					'',
					'',
					'',
					0
			FROM 
			[QSP].[dbo].[SKFActivity]  QF  with (nolock) 
				where 
					 QF.leido = 'no' and 
					  not(latitude) is null 
					  and not(longitud) is null
					  and not (vehicleid) is null
					  and QF.receivedDateTime > DateAdd(dd, -1,getdate()) 


---------------------------------------------------CURSOR QUE RECORRE LA TABLA TEMPORAL DE POSICIONES Y LAS INSERTA EN TRACTORPROFILE Y CHECKCALL-----------------------------------------------------------------------------------------------------------------------------------------
					
			-- Si hay movimientos en la tabla continua
				If Exists ( Select count(*) From  @TTGeos_QC )
				BEGIN --2 Si hay movimientos de posiciones
							-- Se declara un curso para ir leyendo la tabla de paso
							DECLARE Geoposiciones_Cursor CURSOR FOR 
							SELECT                                    QC_idtransaccion, QC_date, QC_comment, QC_latseconds, QC_longseconds, QC_tractor, QC_vehicleignition, QC_commentlarge, QC_Evento, QC_velocidad, QC_aliaslugar,  QC_tipoLugar, QC_nombreSitio,QC_tiempoenSitio
							FROM @TTGeos_QC 
	
							OPEN Geoposiciones_Cursor 
							FETCH NEXT FROM Geoposiciones_Cursor INTO @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_economico, @V_ignicion, @V_proximidadPoblacion, @V_evento , @V_velocidad , @V_aliaslugar, @V_tipolugar, @V_NombreSitio, @V_tiempo_sitio	     
							WHILE @@FETCH_STATUS = 0 
							BEGIN -- del cursor Unidades_Cursor --3
									

										-- Busca el ID del operador segun su unidad
										SELECT @V_IDOPERA = IsNull(trc_driver,'XXX')
										FROM TmwSuite..tractorprofile 
										WHERE trc_number = @V_economico;

										-- Define si esta Apagado o Encendido el motor
										IF (@V_evento) like '%MOTOR APAGADO%'
										Begin
											Select @V_ENC_APAG = 'N'
										End
										IF (@V_evento) not like '%MOTOR APAGADO%'
										Begin
											Select @V_ENC_APAG = 'Y'
										End
										else 
										begin
										Select @V_ENC_APAG = ''
										end


										-- Junta el Evento y el lugar.
										Select @V_EVENTOYLUGAR	= IsNull(@V_lugar,' ') + ' '+IsNull(@V_aliaslugar,'') + IsNull(@V_DESCRIPCTA,'')
										Select @V_nombresitio	= IsNull((SELECT '['+ [displayName] + ']'  FROM [QSP].[dbo].[NWSites] where ((@V_latitud/3600) * 1000000) between minlat and maxlat  and (-1*(@V_longitud/3600)* 1000000)  between minlon and maxlon),'')
										Select @V_lastckc =  isnull((select  rtrim(replace(replace(trc_lastpos_nearctynme,'[',''),']','')) from tmwsuite.dbo.tractorprofile where trc_number =  @V_economico) ,'')
										select @V_dato_vel = isnull(convert(varchar(4),@V_velocidad),'')

										Select @V_tipoevent = 'TRP'

									
                                        Select @V_Comentario = '°'+ ' [' + @V_ENC_APAG + '] '+  @V_proximidadCiudad + ' Vel. '+ cast(@V_dato_vel as varchar(4))


-----------------------------------------SE ARMA LA CADENA DE TEXTO PARA CAMPO COMENTARIO:  CASO EN EL CUAL LA POSICION ES UN SITIO ------------------------------------------------------------------------------------------------------

											IF (@V_NombreSitio != ' '  and @V_NombreSitio is not null)

	
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
													if (@V_lastckc <> '' and @V_lastckc is not null)
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
													set trc_gps_desc = cast(@V_Comentario as varchar(255)),
														trc_gps_date = @V_fecha,
														trc_gps_longitude = @V_longitud,
														trc_gps_latitude =  @V_latitud,
														trc_lastpos_nearctynme =  isnull(cast(@V_NombreSitio as varchar(30)),''),
                                                        trc_gps_speed = @V_dato_vel,
														trc_geo_process_oo = cast(@V_ENC_APAG  as char (1))
													where 	trc_gps_date <= @V_fecha and trc_number = @V_economico
												
											 END
											Else 
											 BEGIN
													update tmwSuite..tractorprofile 
													set trc_gps_desc = cast(@V_Comentario as varchar(255)), 
														trc_gps_date = @V_fecha,
														trc_gps_longitude = @V_longitud,
														trc_gps_latitude =  @V_latitud,
														trc_lastpos_nearctynme =  isnull(cast(@V_NombreSitio as varchar(30)),''),
														trc_gps_speed = @V_dato_vel,
														trc_geo_process_oo =  cast(@V_ENC_APAG  as char (1))

													where 	trc_gps_date <= @V_fecha and trc_number = @V_economico
												
											 END


-------------------------------------------------------------CHECKCALL------------------------------------------------------------------------------------------------------------------------------

										-- Lee el consecutivo de los checkcall para hacer el insert a la tabla.					
										execute @V_CONSECCKC = TmwSuite..getsystemnumber_gateway N'CKCNUM' , NULL , 1 
										-- Inserta el nuevo checkcall
		
										Insert TmwSuite..checkcall(
										ckc_number, ckc_status, ckc_asgntype, ckc_asgnid, ckc_date, ckc_event, ckc_city, ckc_comment, 
										ckc_updatedby, ckc_updatedon, ckc_latseconds, ckc_longseconds, ckc_lghnumber, ckc_tractor, ckc_extsensoralarm, ckc_vehicleignition, 
										ckc_milesfrom, ckc_directionfrom, ckc_validity, ckc_mtavailable, ckc_minutes, ckc_mileage, ckc_home, ckc_cityname, 
										ckc_state, ckc_zip, ckc_commentlarge, ckc_minutes_to_final, ckc_miles_to_final, ckc_Odometer, TripStatus, ckc_odometer2, 
										ckc_speed, ckc_speed2, ckc_heading, ckc_gps_type, ckc_gps_miles, ckc_fuel_meter, ckc_idle_meter)
										Values (@V_CONSECCKC, 'HIST', 		'DRV', 	@V_IDOPERA,	@V_fecha, 	@V_tipoevent , 		0, 	@V_Comentario,    --	left(@V_proximidadCiudad,254 ),
											'SKD', 		GetDate(), 	@V_latitud,	@V_longitud, 		0, 		@V_economico, 	Null, 	@V_ENC_APAG, 
											1,		Null, 		Null, 	Null, 		0, 		0, 		Null, 	Null, 
											Null, 		Null, 		left(@V_proximidadCiudad,254), 		0,		0,		0,		0,	0,		
											@V_dato_vel, 		Null, 		Null, 	Null, 		Null, 		Null, 		Null)			


									-- Marca la georeferencia para despues borrarla.
										Update QSP.dbo.[SKFActivity] Set leido = 'Si' where  QSP.dbo.[SKFActivity].idActivity = @V_idTransaccion
										
									
								

								-- Es necesario Actualizar la ubicacion del operador tambien

								Update TmwSuite..manpowerprofile  
								Set mpp_gps_desc	=	left(@V_proximidadCiudad,45 ), 
									mpp_gps_date	=	@V_fecha
								Where mpp_gps_date <= @V_fecha and mpp_tractornumber = @V_economico
                          

							FETCH NEXT FROM Geoposiciones_Cursor INTO @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_economico, @V_ignicion, @V_proximidadPoblacion, @V_evento , @V_velocidad , @V_aliaslugar, @V_tipolugar, @V_NombreSitio, @V_tiempo_sitio	 
						END --3 curso de los movimientos 
									CLOSE Geoposiciones_Cursor 
									DEALLOCATE Geoposiciones_Cursor 

			END -- 2 si hay movimientos del RC

END --1 Principal

GO
