SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los movimientos que inserta EASYBOX
-- y pasarlos a la tabla checkcall.
-- NO RECIBE PARAMETROS.
--GO
--creado por Emolvera
--ult modificacion 06/19/15 1.17 pm

--  exec sp_pasa_pos_EASYBOX_a_CheckCall
CREATE PROCEDURE [dbo].[sp_pasa_pos_EASYBOX_a_CheckCall]
AS


-----------------------------------------------------DECLARACION DE VARIABLES Y DE TABLA TEMPORAL PARA CONTENER DATOS---------------------------------------------------------------------------------------------------

DECLARE	
	@V_idTransaccion 	uniqueidentifier, 
	@V_fecha		Datetime, 
	@V_proximidadCiudad	Varchar(255), 
	@V_latitud		Float, 
	@V_longitud		Float, 
	@V_dispositivo		varchar(20), 
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
	@V_bateria          float,

	@V_Comentario		Varchar(255),
	@V_tipoevent         varchar(4),
	@V_dato_vel			varchar(4),
	@V_tiempo_sitio		float,
	@leg               varchar(10),
	@carrier           varchar(13)





DECLARE @TTGeos_QC TABLE(
		QC_idtransaccion	uniqueidentifier ,
		QC_date			DateTime null,
		QC_comment		Varchar(255) NULL,
		QC_latseconds		Float null,
		QC_longseconds		Float null,
		QC_dispositivo		varchar(20) NULL,
		QC_vehicleignition	Varchar(10) NULL,
		QC_commentlarge		Varchar(255) NULL,
		QC_Evento		Varchar(10) NULL,
		QC_velocidad		float  NULL,
		QC_aliaslugar		Varchar(100) NULL,
		QC_tipoLugar		Varchar(50) Null,
		QC_nombreSitio VARCHAR(500),
		QC_tiempoenSitio float,
		QC_bateria float)



---------------------------------------------------------VALIDACION DE SI SE CAEN LAS POSICIONES POR MAS DE 60 MINUTOS MANDE CORREO AVISANDO---------------------------------------------------


if   (select max(activitydatetime) from [QSP].[dbo].[EDActivity] with (nolock)) <=  (select DATEADD([minute],-60,getdate() )) 

 BEGIN


	if ((select max(enviado_easybox) from  QSP.dbo.QFS_mailflag) <> 'Si')
	 BEGIN
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'smtp TDR',
        @recipients = 'emolvera@tdr.com.mx',
        @body = 'SE perdio la conexion con el servidor EASYBOX, se esta intentando re-conectar' ,
        @subject = 'Sin posiciones en Checkcalls EASYBOX',
        @attach_query_result_as_file = 0 ;

     
        --si entro al ciclo marcamos la bandera para avisar que se mando el correo.
        update QSP.dbo.QFS_mailflag set enviado_easybox = 'Si'
      END

 END

ELSE 



-----------------------------------------------CARGARMOS LA TABLA TEMPORAL CON LAS POSICIONES DE ACTIVITY Y VEHICLE-----------------------------------------------------------------------------------------------------


BEGIN --1 Principal

            -- Cambiamos la bandera para el proceso que avisa si se caen la posiciones.
	        update QSP.dbo.QFS_mailflag set  enviado_easybox  = 'No'
 

			
			INSERT Into @TTGeos_QC 

			SELECT 	distinct idActivity , 
					QF.activityDateTime,
					QF.location+' - Vel:'+ isnull(cast(QF.velocidad as varchar(10)),'') + ' Bat:' + isnull(cast(QF.bateria as varchar(10)),''),
					abs(QF.latitude*3600), 
					abs(QF.longitud*3600),  
					replace(QF.vehicleid,'863092014271723','TDR00'), 
					0, 
					QF.location+' - Vel:'+ cast(QF.velocidad as varchar(10)) + ' Bat:' + cast(QF.bateria as varchar(10)),
					'1',  --QC Evento
					Qf.velocidad, --QC Velocidad
					'',  -- QC Alias lugar
					'',  --QC tipo lugar
					'', --QC nombre sitio
					0,   ---QC_tiempo en sitio
					Qf.bateria  ---QC_bateria
			FROM 
			[QSP].[dbo].[EDActivity]  QF  with (nolock) 
				where 
					 QF.leido = 'no' and 
					  not(latitude) is null 
					  and not(longitud) is null
					  and not (vehicleid) is null
					  and QF.activityDateTime > DateAdd(dd, -1,getdate()) 
					



---------------------------------------------------CURSOR QUE RECORRE LA TABLA TEMPORAL DE POSICIONES Y LAS INSERTA EN TRACTORPROFILE Y CHECKCALL-----------------------------------------------------------------------------------------------------------------------------------------
					
			-- Si hay movimientos en la tabla continua
				If Exists ( Select count(*) From  @TTGeos_QC )
				BEGIN --2 Si hay movimientos de posiciones


							-- Se declara un curso para ir leyendo la tabla de paso
							DECLARE Geoposiciones_Cursor CURSOR FOR 
							SELECT                                    QC_idtransaccion, QC_date, QC_comment, QC_latseconds, QC_longseconds, QC_dispositivo, QC_vehicleignition, QC_commentlarge, QC_Evento, QC_velocidad, QC_aliaslugar,  QC_tipoLugar, QC_nombreSitio,QC_tiempoenSitio, QC_bateria
							FROM @TTGeos_QC 
	
							OPEN Geoposiciones_Cursor 
							FETCH NEXT FROM Geoposiciones_Cursor INTO @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_dispositivo, @V_ignicion, @V_proximidadPoblacion, @V_evento , @V_velocidad , @V_aliaslugar, @V_tipolugar, @V_NombreSitio, @V_tiempo_sitio, @V_Bateria	     
							WHILE @@FETCH_STATUS = 0 
							
							BEGIN -- del cursor
									

								

								       --correccion de nombres del dispositivos.
                                       select @V_dispositivo = replace(replace(@V_dispositivo,'t-02-04','T-02-4'),'T-03-07','T-03-7')
										-- Junta el Evento y el lugar.
										Select @V_EVENTOYLUGAR	= IsNull(@V_lugar,' ') + ' '+IsNull(@V_aliaslugar,'') + IsNull(@V_DESCRIPCTA,'')
										Select @V_nombresitio	= IsNull((SELECT  '^'+max([displayName])  FROM [QSP].[dbo].[NWSites] where ((@V_latitud/3600) * 1000000) between minlat and maxlat  and (-1*(@V_longitud/3600)* 1000000)  between minlon and maxlon),'')
									

										select @V_dato_vel = isnull(convert(int,@V_velocidad),'')

										Select @V_tipoevent = 'TRP'

							           	 Select @V_lastckc =  isnull((select max(ckc_comment) from tmwsuite.dbo.checkcall (nolock) where ckc_lghnumber = @leg and ckc_date
										=(select max(ckc_date) from checkcall (nolock) where ckc_lghnumber = @leg)  ),'')


							

----------------------------------------SE ARMA LA CADENA DE TEXTO PARA CAMPO COMENTARIO:  CASO EN EL CUAL LA POSICION ES UN SITIO ------------------------------------------------------------------------------------------------------


											IF (@V_NombreSitio != ' ' )

	
												Begin

												    
												    Select @V_tipoevent = 'SIT'
													Select @V_NombreSitio = '['+@V_NombreSitio+'] '
					
													SELECT @V_GPSLOCATION 	= left(@V_NombreSitio  ,255)
													

													---SI LA ULTIMA POS ES EN CALLE Y LA PROXIMA ES EN SITIO ESTA ENTRANDO.
													if @V_lastckc not like '%^%'
													  BEGIN
                                                       SELECT @V_Comentario = 'Entrando a: '  + left( @V_NombreSitio + ' | Vel:' + isnull(cast((@V_velocidad) as varchar(20)),'' ) + ' Bat:' + isnull(cast((@V_bateria) as varchar(20)),'') , 254)
													  END
													 ELSE
													 --SI LA ULTIMA POS ES EN SITIO Y LA PROXIMA ES EN SITIO, PERMANECE EN SITIO.
													  BEGIN
													    SELECT @V_Comentario = left((  @V_NombreSitio + ' | Vel:'+ isnull(cast((@V_velocidad) as varchar(20)),'') + ' Bat:' + isnull(cast((@V_bateria) as varchar(20)),'')        ), 254)
													  END
										
												End

											 Else

-----------------------------------------SE ARMA LA CADENA DE TEXTO PARA CAMPO COMENTARIO: CASO EN EL CUAL LA POSICION NO ES UN SITIO-----------------------------------------------------------------------------------------------------
												
												Begin
												    
													--SI LA ULTIMA POS ES EN SITIO Y LA PROXIMA ES EN CALLE, SALE DE SITIO.
													if @V_lastckc not like 'Saliendo de:%' and @V_lastckc like '%^%'
													 BEGIN
													   Select @V_tipoevent = 'SIT'
													   Select @V_Comentario = 'Saliendo de: ' +    left(( @V_lastckc  ),254) + ' | Vel:'+ isnull(cast((@V_velocidad) as varchar(20)),'') + ' Bat:' + isnull(cast((@V_bateria) as varchar(20)) ,'') 
													 END
													ELSE
													  BEGIN
													  --SI LA ULTIMA POS ES EN CALLE Y LA PROXIMA ES EN CALLE, PERMANECE EN CALLE.
													   Select @V_tipoevent = 'TRP'
													   Select @V_Comentario =  left((left(@V_proximidadCiudad,254) ),254)
													  END
											
											     End

-------------------------------------------------------------CHECKCALL------------------------------------------------------------------------------------------------------------------------------

										-- Lee el consecutivo de los checkcall para hacer el insert a la tabla.					
										execute @V_CONSECCKC = TmwSuite..getsystemnumber_gateway N'CKCNUM' , NULL , 1 
										-- Inserta el nuevo checkcall



	-------------------CASO dispositivos moviles (se referencian a un leg activo iniciado que los tenga en extrainfo1) -------------------------------------------------------------------------------------------------		
							if @V_dispositivo like '%mov%' 
								begin 
								
											--Buscamos el numero de leg activo en base al numero de id del dispositivo que tiene asignado el leg por la carga masiva.
					                        select @leg = (select max(lgh_number) from legheader_active (nolock) where lgh_outstatus in ('STD') and lgh_number in (select lgh_number from legheader(nolock) where  lgh_extrainfo1  = @V_dispositivo  ))

										  --Buscamos el carrier de leg activo en base al numero de id del dispositivo que tiene asignado el leg por la carga masiva.
					                        select @carrier = (select max(lgh_carrier) from legheader_active (nolock) where lgh_outstatus in ('STD') and lgh_number in (select lgh_number from legheader(nolock) where  lgh_extrainfo1 = @V_dispositivo  ))

							                --si tenemos un numero de leg valido procedemos a insertar el checkcall------------------------------------
							                  if @leg is not null
											   begin
		
												Insert TmwSuite..checkcall(
												ckc_number, ckc_status, ckc_asgntype, ckc_asgnid, ckc_date, ckc_event, ckc_city, ckc_comment, 
												ckc_updatedby, ckc_updatedon, ckc_latseconds, ckc_longseconds, ckc_lghnumber, ckc_tractor, ckc_extsensoralarm, ckc_vehicleignition, 
												ckc_milesfrom, ckc_directionfrom, ckc_validity, ckc_mtavailable, ckc_minutes, ckc_mileage, ckc_home, ckc_cityname, 
												ckc_state, ckc_zip, ckc_commentlarge, ckc_minutes_to_final, ckc_miles_to_final, ckc_Odometer, TripStatus, ckc_odometer2, 
												ckc_speed, ckc_speed2, ckc_heading, ckc_gps_type, ckc_gps_miles, ckc_fuel_meter, ckc_idle_meter)
												Values (@V_CONSECCKC, 'HIST', 		'CAR', @carrier,	@V_fecha, 	@V_tipoevent , 		0, 	@V_Comentario,    --	left(@V_proximidadCiudad,254 ),
													'EBX', 		GetDate(), 	@V_latitud,	@V_longitud,  @leg, 		'UNKNOWN', 	Null, 	@V_ENC_APAG, 
													1,		Null, 		Null, 	Null, 		0, 		0, 		Null, 	Null, 
													Null, 		Null, 		left(@V_proximidadCiudad,254), 		0,		0,		0,		0,	0,		
													@V_dato_vel, 		Null, 		Null, 	Null, 		Null, 		Null, 		Null)	
												
									           end

								  end
												
							         
-------------------CASO dispositivos en tractores (solo insertamos al checkcall y tractor profile) -------------------------------------------------------------------------------------------------	

                  else if ( @V_dispositivo in (select trc_number from tractorprofile where trc_status <> 'OUT'))
					   
					  BEGIN

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
														trc_geo_process_oo = cast(@V_ENC_APAG  as char (1))
													where 	trc_gps_date <= @V_fecha and trc_number = @V_dispositivo
												
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
														trc_geo_process_oo =  cast(@V_ENC_APAG  as char (1))

													where 	trc_gps_date <= @V_fecha and trc_number = @V_dispositivo
												
											 END


                       ---se inserta en el chekcall----------------------------------------------------------

					   Insert TmwSuite..checkcall(
												ckc_number, ckc_status, ckc_asgntype, ckc_asgnid, ckc_date, ckc_event, ckc_city, ckc_comment, 
												ckc_updatedby, ckc_updatedon, ckc_latseconds, ckc_longseconds, ckc_lghnumber, ckc_tractor, ckc_extsensoralarm, ckc_vehicleignition, 
												ckc_milesfrom, ckc_directionfrom, ckc_validity, ckc_mtavailable, ckc_minutes, ckc_mileage, ckc_home, ckc_cityname, 
												ckc_state, ckc_zip, ckc_commentlarge, ckc_minutes_to_final, ckc_miles_to_final, ckc_Odometer, TripStatus, ckc_odometer2, 
												ckc_speed, ckc_speed2, ckc_heading, ckc_gps_type, ckc_gps_miles, ckc_fuel_meter, ckc_idle_meter)
												Values (@V_CONSECCKC, 'HIST', 		'DRV', '',	@V_fecha, 	@V_tipoevent , 		0, 	@V_Comentario,    --	left(@V_proximidadCiudad,254 ),
													'EBX', 		GetDate(), 	@V_latitud,	@V_longitud,  0,  @V_dispositivo, 	Null, 	@V_ENC_APAG, 
													1,		Null, 		Null, 	Null, 		0, 		0, 		Null, 	Null, 
													Null, 		Null, 		left(@V_proximidadCiudad,254), 		0,		0,		0,		0,	0,		
													@V_dato_vel, 		Null, 		Null, 	Null, 		Null, 		Null, 		Null)	



					 END
											
			
-------------------CASO dispositivos en trailers (solo insertamos en el trailerprofile) -------------------------------------------------------------------------------------------------	



                    else if @V_dispositivo in (select trl_number from trailerprofile where trl_status <> 'OUT')

					begin 

					  -- Se actualiza en el catalogo de las unidades la ultima ubicacion
						-- siempre y cuando la fecha sea mayor de la que tiene.


											IF (@V_GPSLOCATION != NULL)
											 BEGIN
													update tmwSuite..trailerprofile 
													set trl_gps_desc = @V_Comentario,
														trl_gps_date = @V_fecha,
														trl_gps_longitude = @V_longitud,
														trl_gps_latitude =  @V_latitud,
														--trl_gps_heading =  isnull(cast(@V_NombreSitio as varchar(30)),''),
                                                        trl_gps_speed = @V_dato_vel
												
													where --	trl_gps_date <= @V_fecha and
													 trl_number = @V_dispositivo
												
											 END
											Else 
											 BEGIN
													update tmwSuite..trailerprofile 
													set trl_gps_desc = @V_Comentario, 
														trl_gps_date = @V_fecha,
														trl_gps_longitude = @V_longitud,
														trl_gps_latitude =  @V_latitud,
														--trl_gps_heading =  isnull(cast(@V_NombreSitio as varchar(30)),''),
														trl_gps_speed = @V_dato_vel
														

													where 	--trl_gps_date <= @V_fecha and
													 trl_number = @V_dispositivo
												
											 END

								
					

					end
				
-- Marca de leido------------------------------------------------------
					
				    Update QSP.dbo.[EDActivity] Set leido = 'Si' where  QSP.dbo.[EDActivity].idActivity = @V_idTransaccion
								
					
							FETCH NEXT FROM Geoposiciones_Cursor INTO @V_idTransaccion, @V_fecha, @V_proximidadCiudad, @V_latitud, @V_longitud, @V_dispositivo, @V_ignicion, @V_proximidadPoblacion, @V_evento , @V_velocidad , @V_aliaslugar, @V_tipolugar, @V_NombreSitio, @V_tiempo_sitio, @V_Bateria	 
			
			END --del cursor 
									CLOSE Geoposiciones_Cursor 
									DEALLOCATE Geoposiciones_Cursor 

		END -- de que existen registros en la tabla  
 
END --del principal

GO
