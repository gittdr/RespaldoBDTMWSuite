SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[sp_actualizaETA]

as


/***************************************************************************************************************************************************************************************************************************
Autor: Emilio Olvera Yanez
Fecha: 28 Agosto 2017
Version: 2.0
Anteriores:

1.0 32 de Marzo 2015: actualizaba directo en la tabla stops y causaba locks.

Descripcion: SP que actualiza los tiempos y distancias ETA mediante las funciones GEOGRAPHY incluidas en SQL SERVER 2008
de los STOPS que aun se encuentran abiertos.

Primero inserta en una tabla virtual el numero de stop, el point de origen y el point de destino 
Posteriormente esta tabla es recorrida por un cursor y ejecuta la funcion STDistance para obtener la distancia
Por ultimo con la distancia obtenida se actualiza la tabla de stops_ETA 

Sentencia de prueba: exec sp_actualizaETA


select * from stops_eta order by ste_updated desc
******************************************************************************************************************************************************************************************************************************/


--Declaracion de Variables para el el cursos

DECLARE @V_stop int
DECLARE @V_leg int
DECLARE @V_earliest datetime
DECLARE @V_latest datetime
DECLARE @V_arrival datetime
DECLARE @V_departure datetime
DECLARE @V_sourcelat varchar(12)
DECLARE @V_sourcelong varchar(12)
DECLARE @V_targetlat varchar(12)
DECLARE @V_targetlong varchar(12)

DECLARE @LatSeconds1 float,
			@LatSeconds2 float,
			@LongSeconds1 float,
			@LongSeconds2 float,
			@lat1 float,
			@lat2 float,
			@long1 float,
			@long2 float,
			@AirMiles float


--Declaracion de Tabla Virtual donde contendremos los datos.
DECLARE @movslatlong table
(
t_stop int,
t_leg int,
t_earliest datetime,
t_latest datetime,
t_arrival datetime,
t_departure datetime,
t_targetlong varchar(12),
t_targetlat varchar(12),
t_sourcelong varchar(12),
t_sourcelat varchar(12))





/******************************************************************************************************************************************************************************************************************************
-Se insertan en la tabla virtual los datos de los stops que no han sido completados, con su lat,long destino y su lat,long origen en campos geography
Considera los stops abiertos de -24 horas a 24 horas por suceder
Considera los stops de los tractores que su gps tiene a lo mucho una diferencia de 30 minutos de la ultima posicion.
si no esta moviendo no requerimos obtener constantemente su distancia al origen.
******************************************************************************************************************************************************************************************************************************/


insert into  @movslatlong

   SELECT 
   stp_number,
   stops.lgh_number,
   stp_schdtearliest,
   stp_schdtlatest,
   stp_arrivaldate,
   stp_departuredate,
   targetlong = cmp_longseconds,
   targetlat = cmp_latseconds,
   tsourcelong = t.trc_gps_longitude,
   tsourcelat  = t.trc_gps_latitude


   FROM    dbo.stops WITH (nolock)
   left join legheader leg on stops.lgh_number = leg.lgh_number 
   left join tractorprofile t on leg.lgh_tractor = trc_number
   left join company c on dbo.stops.cmp_id = c.cmp_id
   
   
   WHERE      

   datediff(hh,stp_arrivaldate,getdate()) between -120 and 120
   AND
   dbo.stops.stp_number in ( select stp_number from stops st (NOLOCK) where st.mov_number = stops.mov_number and st.stp_status <> 'DNE' and stp_mfh_sequence =
   (select  min(stp_mfh_sequence) from stops st (nolock) where st.mov_number = stops.mov_number and st.stp_status <> 'DNE'   ) )
   AND
   ((SELECT   lgh_tractor  FROM   dbo.legheader AS legheader_1 WITH (nolock)  WHERE  (lgh_number = dbo.stops.lgh_number)) NOT IN ('UNKNOWN', ''))
   AND  (c.cmp_longseconds is not null  or c.cmp_latseconds is not null)
   AND (t.trc_gps_longitude is not null or t.trc_gps_latitude is not null)
   AND   ((c.cmp_longseconds/3600.0 ) >0)
   AND   ((c.cmp_latseconds/3600.0 )>0)


   
   
   /*
   AND
   datediff(mi,(SELECT        trc_gps_date  FROM    tractorprofile(nolock) WHERE   trc_number =
   (SELECT  lgh_tractor  FROM    legheader(nolock)   WHERE   legheader.lgh_number = stops.lgh_number)),getdate()) <= 30
   */


--/************************************************************************CURSOR QUE RECORRE LA TABLA VIRTUAL **********************************************************************************************************
        
-- Borramos todos los stops de los cuales sus legs ya esten cerrados, pues ya no son necesarios.

   delete stops_eta where lgh_number in (select lgh_number from legheader (nolock) where lgh_outstatus in ('CMP','CAN'))
   delete stops_eta where lgh_number not in (select lgh_number from legheader)


		          

-- Si hay movimientos en la tabla continua
			
			              DECLARE @offset_minutes decimal(6,2), @offset_date datetime, @offset_kms decimal(6,2), @velocidad decimal(6,2)


							-- Se declara un curso para ir leyendo la tabla de paso
							DECLARE stoplatlong_Cursor CURSOR FOR 
							SELECT t_stop,t_leg,
							t_earliest,t_latest,t_arrival,t_departure, t_targetlat,t_targetlong, t_sourcelat, t_sourcelong  FROM @movslatlong


							/*************************************************/
							--Aqui configuramos la velocidad promedio de viaje

							select @velocidad = 65.00
							/************************************************/


							OPEN stoplatlong_Cursor 
							FETCH NEXT FROM stoplatlong_Cursor  INTO @V_stop, @V_leg,@V_earliest, @V_latest ,@V_arrival,@V_departure,@V_targetlat,@V_targetlong, @V_sourcelat, @V_sourcelong  
							WHILE @@FETCH_STATUS = 0 
							BEGIN -- del cursor Unidades_Cursor --3

							 
							 --HACEMOS LOS CALCULOS PARA LOS KILOMETROS AREOS ENTRE DISTANCIAS LAT/LONG

							 	SET @LatSeconds1  =  CONVERT(float, @V_targetlat)
	                            SET @LatSeconds2  =  CONVERT(float, @V_sourcelat)
	                            SET @LongSeconds1 = CONVERT(float, @V_targetlong)
	                            SET @LongSeconds2 = CONVERT(float, @V_sourcelong)

							  
							  If  ISNULL(@latSeconds1, 0) = 0 OR ISNULL(@latSeconds2, 0) = 0 OR ISNULL(@longSeconds1, 0) = 0 OR ISNULL(@longSeconds2, 0) = 0
									BEGIN
										SELECT @offset_kms =-1 
										RETURN 
									END

								Set @lat1 = Convert(float,@LatSeconds1)/3600.0 -- convert Seconds to factional degrees
								Set @lat2 = Convert(float,@LatSeconds2)/3600.0 -- convert Seconds to factional degrees
								Set @Long1 = Convert(float,@LongSeconds1)/3600.0 -- convert Seconds to factional degrees
								Set @Long2 = Convert(float,@LongSeconds2)/3600.0 -- convert Seconds to factional degrees

								If  (@lat1<5 or @lat1>85) 
									BEGIN
										SELECT -1 AirMiles
										RETURN 
									END
								If  (@lat2<5 or @lat2>85)
									BEGIN
										SELECT -1 AirMiles
										RETURN 
									END
								If  (@long1<5 or @long1>175)
									BEGIN
										SELECT -1 AirMiles
										RETURN 
									END
								If  (@long2<5 or @long2>175)
									BEGIN
										SELECT -1 AirMiles
										RETURN 
									END

								IF (@LAT1=@LAT2 and @long1=@long2)
									BEGIN
										SELECT 0 AirMiles
										RETURN 
									END


								Select	@offset_kms= 
								 ISNULL(	
											/* -- Convert values from degrees to radians */
									(
									Select 
									(Acos(
			
										cos(	(@lat1 * 3.14159265358979 / 180.0)  )  *
										cos(	(@Lat2 * 3.14159265358979 / 180.0)  )  *
			
												cos (  
											(@long1 * 3.14159265358979 / 180.0) - 
											(@long2 * 3.14159265358979 / 180.0)
											)	+
										Sin (	(@lat1 * 3.14159265358979 / 180.0) ) *
										Sin (	(@Lat2 * 3.14159265358979 / 180.0) ) 	
										) * 3956.5) * 1.60934 
									)
								,-1)

							 

							  select @offset_minutes =  @offset_kms / @velocidad
						

							  select @Offset_Date = dateadd(Minute,@offset_minutes , getdate())

							  --Insertamos los datos calculados del ETA en la tabla stops_ETA  8/28/2017

                              if @V_stop not in (select stp_number from stops_eta (nolock) )
							   BEGIN

								 insert into  stops_eta
								  values
								  (@V_stop,                                                                               --stp_number                         (int)
								   @V_leg,                                                                                --lgh_number int                     (int)
								   @offset_minutes*3600,                                                                  --ste_seconds_out                     (int)
								   @offset_kms,                                                                           --ste_miles_out                      (decimal 6,2)
								   getdate(),                                                                             --ste_updated                        (datetime)
								   0,                                                                                     --ckc_number                         (int)
								   @V_earliest,                                                                           --ste_original_earliest              (datetime)
								   @V_arrival,						                                                      --Ste_original_arrival               (datetime)
								   @V_departure,						                                                  --ste_original_departure             (datetime)
								   @offset_date,						                                                  --ste_updated_earliest               (datetime)
								   @offset_date,							                                              --ste_updated_arrival                (datetime)
								   dateadd(MINUTE, datediff(MINUTE,@V_arrival,@V_departure),@offset_date),				  --ste_updated_departure              (datetime)
								   0,							                                                          --ste_message_count                  (tinyint)
								   @V_latest,							                                                  --ste_original_latest                (datetime)
								   dateadd(MINUTE, datediff(MINUTE,@V_earliest,@V_latest),@offset_date)				  --ste_updated_latest                 (datetime)
								   )
								END
							  else

							  BEGIN
							   
							   --si ya existe el registro hacemos update

							   update stops_eta
							   set ste_seconds_out =   @offset_minutes*3600,
							       ste_miles_out =     @offset_kms,
								   ste_updated = getdate(),
								   ste_updated_earliest =  @offset_date,
								   ste_updated_departure = dateadd(MINUTE, datediff(MINUTE,@V_arrival,@V_departure),@Offset_Date),
								   ste_updated_arrival = @offset_date,
								   ste_updated_latest  = dateadd(MINUTE, datediff(MINUTE,@V_earliest,@V_latest),@Offset_Date)  	
							   where stp_number = @V_stop
								   
	
							  END


					       FETCH NEXT FROM stoplatlong_Cursor  INTO @V_stop, @V_leg,@V_earliest, @V_latest ,@V_arrival,@V_departure,@V_targetlat,@V_targetlong, @V_sourcelat, @V_sourcelong  
						   END --3 cursor de los movimientos 
						   CLOSE stoplatlong_Cursor
						   DEALLOCATE stoplatlong_Cursor

	


		--****************************/				

GO
