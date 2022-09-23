SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************
SP envia CABECERAS DE CARGA POR LEG

AUTOR:  EMOLVERA
VERSION: 5.0
FECHA: 1 de septiembre 2016 2:41pm

*********prueba envio cabecera de carga********************
exec sp_enviaMacroCab_de_cargaleg   476102, 1426, 'PLN'
***********************************************************
QUERYS adicionales de prueba


select lgh_number from legheader where mov_number = (select mov_number from orderheader where ord_hdrnumber =  '415416')
select ord_status from orderheader where ord_hdrnumber =  '290035'

select * from stops where lgh_number = '476102'

update tmwdes..legheader set lgh_tractor = '501' where lgh_number = '476102'
***************************************************************************************************************************/

CREATE PROCEDURE [dbo].[sp_enviaMacroCab_de_cargaleg]  @NoLeg integer, @unidad VARCHAR(8),	@statusLeg	VARCHAR(8)
AS

--Declaramos variables del entorno.
DECLARE	
	@v_totaluni 	Int,
	@v_unidad varchar(10),
	@V_parada		varchar(500),
	@V_billto		varchar(8),
	@orden varchar(10),
	@legemp int


--Declaramos una tabla temporal para las paradas.
DECLARE @TTparadas TABLE(
		TT_parada		Varchar(500) NULL,
		TT_unidad varchar(10),
		TT_stop int,
		TT_ordena varchar(5),
		TT_ordenb varchar(5)
		)



--Asiganmos valores a las varibles de entorno
set @orden = (select ord_hdrnumber from legheader (nolock) where lgh_number = @NoLeg)

set @legemp = (select count(*) from legheader (nolock) where lgh_outstatus = 'STD' and lgh_tractor = @unidad)


--Si el cliente no es sayer si dejamos que mande cabeceras de carga auqne tenga ordenes en STD
if (select ord_billto from orderheader where ord_hdrnumber = @orden) <> 'SAYER'
begin 
  set @legemp = 0
end


BEGIN --1 Principal
--Select @statusOrden = 'PLN'


		------------------ verificamos que la unidad tenga el sistema de NavMan...---------------------------------------------
	
		If Exists (select displayName from QSP..NWVehicles where displayName = @unidad )
		BEGIN --2.1 existe la unidad en NMVehicles
				-- Valida que la orden este en estatus de Planeada para enviar la macro de asignacion de carga.
				
				
				IF (@statusLeg = 'PLN' and @legemp = 0)
				BEGIN -- 3 estatus de la orden planeada
					-- Inserta el mensaje en la tabla de envia mensajes...

					   ----MENSAJE 1:CABECERA DE CARGA ***********************************************************************************************************************************************************************************************


					   if @orden <> '0'
					    begin

					    INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro, fechainsersion)
						(select 5,@unidad, null, 
						'*CARTA PORTE* --- Orden:' + cast(rtrim(ord_hdrnumber) as varchar)
						 
						+ ' Origen:'+ lgh_rstartcty_nmstct
						+ ' Destino:'  + lgh_rendcty_nmstct
						+ ' Cita:' +  cast(lgh_startdate as varchar)
						+ ' Carga:' + (select isnull(cmp_name,'ND') from company (nolock) where cmp_id = rtrim(cmp_id_start))  
						+ ' Domicilio:' + (select isnull(cmp_address1,'') +' '+ isnull(cmp_address2,'') + ' '+ isnull(cmp_centroidctynmstct,'')  from company(nolock) where cmp_id = rtrim(cmp_id_start)) 
						+ ' Descarga:' + (select isnull(cmp_name,'ND') from company where cmp_id = rtrim(cmp_id_end))  
						+ ' Domicilio:' +  (select isnull(cmp_address1,'') +' '+ isnull(cmp_address2,'') + ' '+ isnull(cmp_centroidctynmstct,'')    from company (nolock)  where cmp_id = rtrim(cmp_id_end))  
						
						, null, getdate()
					    from legheader(nolock)
					    where lgh_number  = @NoLeg)



                       --MENSAJE 2: DETALLE DE LA CABECERA DE CARGA *****************************************************************************************************************************************************************************************************
						INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro, fechainsersion)
						(select 5,@unidad, null, 


						'**Detalle Carta Porte**  Orden:' + cast(rtrim(ord_hdrnumber) as varchar) + 

						  ' Cotiene:' +(select  isnull(rtrim(ord_description),'') from orderheader (nolock) where ord_hdrnumber = @orden)
						+ ' Peso: '+ cast(lgh_tot_weight as varchar(10))
						+ ' Remolque:' + isnull(rtrim(lgh_primary_trailer),'') + ' Remolque2:' + isnull(rtrim(lgh_primary_pup),'') 

						+   ' KmsCargados: ' + 
									CAST((SELECT     IsNull(SUM(stp_lgh_mileage), 0)
											FROM          stops(NOLOCK)
											WHERE legheader.lgh_number = stops.lgh_number  AND stops.stp_loadstatus = 'LD')as varchar)
						  + ' KmVacios:'
								 +      CAST( (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
														FROM          stops(NOLOCK)
														WHERE legheader.lgh_number = stops.lgh_number  AND stops.stp_loadstatus <> 'LD') AS varchar)
						  + ' KmsTotales:'
								+      CAST( (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
											FROM          stops(NOLOCK)
												WHERE legheader.lgh_number= stops.lgh_number  ) AS varchar)

						 + '   Eventos:'+ CAST((SELECT COUNT(STP_NUMBER) FROM STOPS
								WHERE legheader.lgh_number = stops.lgh_number ) as varchar)
												 
						  + '////Comentarios:' + (select  IsNull(rtrim(ord_remark),'') from orderheader (nolock) where ord_hdrnumber = @orden)
									, null, getdate()
									from legheader (nolock)
									where lgh_number = @NoLeg)

						 end
						else -- si la orden es 0 es un movimiento en vacio

						 begin

				    ----MENSAJE 1:MOVIMIENTO EN VACIO ***********************************************************************************************************************************************************************************************

						   INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro, fechainsersion)
							(select 5,@unidad, null, 
							'*Movimiento en vacio:' 
						 
							+ ' Origen:'+ lgh_rstartcty_nmstct
							+ ' Destino:'  + lgh_rendcty_nmstct
							+ ' Cita:' +  cast(lgh_startdate as varchar)
							+ ' Carga:' + (select isnull(cmp_name,'ND') from company (nolock) where cmp_id = rtrim(cmp_id_start))  
							+ ' Domicilio:' + (select isnull(cmp_address1,'') +' '+ isnull(cmp_address2,'') + ' '+ isnull(cmp_centroidctynmstct,'')  from company(nolock) where cmp_id = rtrim(cmp_id_start)) 
							+ ' Descarga:' + (select isnull(cmp_name,'ND') from company where cmp_id = rtrim(cmp_id_end))  
							+ ' Domicilio:' +  (select isnull(cmp_address1,'') +' '+ isnull(cmp_address2,'') + ' '+ isnull(cmp_centroidctynmstct,'')    from company (nolock)  where cmp_id = rtrim(cmp_id_end))  
						
							, null, getdate()
							from legheader(nolock)
							where lgh_number  = @NoLeg)


					--MENSAJE 2: DETALLE DEL MOVIMIENTO EN VACIO*****************************************************************************************************************************************************************************************************
						INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro, fechainsersion)
						(select 5,@unidad, null, 


						'**Detalle movimiento en vacio**'   + 

					
						+ ' Remolque:' + isnull(rtrim(lgh_primary_trailer),'') + ' Remolque2:' + isnull(rtrim(lgh_primary_pup),'') 

						+   ' KmsCargados: ' + 
									CAST((SELECT     IsNull(SUM(stp_lgh_mileage), 0)
											FROM          stops(NOLOCK)
											WHERE legheader.lgh_number = stops.lgh_number  AND stops.stp_loadstatus = 'LD')as varchar)
						  + ' KmVacios:'
								 +      CAST( (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
														FROM          stops(NOLOCK)
														WHERE legheader.lgh_number = stops.lgh_number  AND stops.stp_loadstatus <> 'LD') AS varchar)
						  + ' KmsTotales:'
								+      CAST( (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
											FROM          stops(NOLOCK)
												WHERE legheader.lgh_number= stops.lgh_number  ) AS varchar)

						 + '   Eventos:'+ CAST((SELECT COUNT(STP_NUMBER) FROM STOPS
								WHERE legheader.lgh_number = stops.lgh_number ) as varchar)
												 
						  + '////Comentarios:' + (select  IsNull(rtrim(ord_remark),'') from orderheader (nolock) where ord_hdrnumber = @orden)
									, null, getdate()
									from legheader (nolock)
									where lgh_number = @NoLeg)


						 end

				  --MENSAJE 3 al N: STOPS DE LOS LEGS *****************************************************************************************************************************************************************************************************

							-- INSERTAMOS LOS MENSAJES Y LAS UNIDADES QUE CONTENDRAN LOS STOPS EN LA TABLA TEMPORAL
							INSERT Into @TTparadas 

						      
						    --NUEVA VERSION DEL MENSAJE POR EMOLVERA 8/30/2016 10:10AM
								  SELECT  + ' * '+ cast(rtrim(stp_mfh_sequence) as varchar) +'/'+ CAST((SELECT COUNT(STP_NUMBER) FROM STOPS (nolock) WHERE  @Noleg = stops.lgh_number) as varchar)
								    + ' '  + (select name  from eventcodetable where abbr= stp_event)+ ' en '+ isnull(rtrim(cmp_name),'') +' - ' +isnull(rtrim(stp_address),'') +''+isnull(rtrim(stp_address2),'')+
								  ' reportarse con ' + isnull(rtrim(stp_contact),'') + ' tel ' + isnull(rtrim(stp_phonenumber),'') 
								  	+' de la orden ' + cast(rtrim(ord_hdrnumber) as varchar) +'|'+cast(rtrim(stp_number) as varchar),
									@unidad,
									stp_number,
									stp_mfh_sequence,
									0
									FROM STOPS 
									WHERE @NoLeg = stops.lgh_number
									order by stp_mfh_sequence
								

                          --SI EL STOP TIENE SUBPARADAS
						  INSERT Into @TTparadas

								  SELECT  + ' **(E)** ' + + cast(rtrim(evt_sequence-1) as varchar) +'/'+ CAST((SELECT COUNT(STP_NUMBER)-1 FROM event e (nolock) WHERE e.stp_number = event.stp_number) as varchar)
								   +' ' +(select name  from eventcodetable where abbr= evt_eventcode) +  ' en ' +  (select isnull(rtrim(cmp_name),'')  from stops (nolock)  where stops.stp_number= event.stp_number)
								   +' |'+cast(rtrim(evt_number) as varchar),
								   @unidad,
									stp_number,
									(select stp_mfh_sequence from stops (nolock) where stops.stp_number = event.stp_number),
									evt_sequence
									FROM event (nolock)
									WHERE event.stp_number in (select TT_stop from @TTparadas) and evt_sequence > 1
									 order by evt_sequence asc



							--Si tiene detalle en las paradas, envia 1 mensaje por cada parada a la unidad correspondiente
								If Exists ( Select count(*) From  @TTparadas )
								Begin--4 si hay legs
								-- Se declara un curso para ir leyendo la tabla de paso
									DECLARE Paradas_Cursor CURSOR FOR 
									SELECT TT_parada, TT_unidad
									FROM @TTparadas order by TT_ordena , TT_ordenb
								
									OPEN Paradas_Cursor 
									FETCH NEXT FROM Paradas_Cursor INTO @V_parada, @v_unidad
									WHILE @@FETCH_STATUS = 0 
										BEGIN --5 del cursor Paradas_Cursor 
											--SELECT @V_parada
											
									        ----------------Si la unidad Tiene NAVMAN enviamos los mensajes----------------------------------
										
											if @v_unidad in (select displayname  from QSP..NWVehicles (nolock))
											begin

											-- Insert el mensaje con la descripcion de la parada para cada unidad correspondiente
											 INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro)
											 Values(5,@unidad, null, @V_parada,null )
											end


											FETCH NEXT FROM Paradas_Cursor INTO @V_parada, @V_unidad
										END -- 5 del cursor Paradas_Cursor 
					

							CLOSE Paradas_Cursor 
							DEALLOCATE Paradas_Cursor 
						END -- 4 curso de las paradas 
			



						select lgh_number, 'Macro enviada', @unidad from legheader (nolock)  where lgh_number = @NoLeg
						
						----------------Cambiamos el status del leg a despachado tras mandar las cabeceras----------------------------------  
					    update legheader set lgh_outstatus = 'DSP' where lgh_number = @Noleg

				
				END  -- 3 estatus de la orden planeada 
				        
						select lgh_number, 'El Estatus del leg debe de ser PLN para enviar la macro y no deben de existir ordenes ya empezadas...', @unidad from tmwSuite..legheader (nolock) where lgh_number = @NoLeg

		END	--2 existe la unidad en QFSVehicles

		select lgh_number, 'La Unidad no cuenta con sistema NAVMAN', @unidad from tmwSuite..legheader(nolock) where lgh_number = @NoLeg
		
END --1 Principal



GO
