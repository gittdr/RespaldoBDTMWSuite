SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
prueba envio cabecera de carga
exec sp_enviaMacroCab_de_cargaoperations   317190, 1256, 'PLN'

select mov_number from orderheader where ord_hdrnumber =  '290035'
select ord_status from orderheader where ord_hdrnumber =  '290035'
update orderheader set ord_status ='PLN' where ord_hdrnumber =  '290035'
*/

CREATE PROCEDURE [dbo].[sp_enviaMacroCab_de_cargaOperations]  @NoMovimiento integer, @unidad VARCHAR(8),	@statusOrden	VARCHAR(8)
AS
DECLARE	
	@v_totaluni 	Int,
	@V_parada		varchar(500),
	@V_billto		varchar(8)
--Declara una tabla temporal para las paradas.
DECLARE @TTparadas TABLE(
		TT_parada		Varchar(500) NULL)

BEGIN --1 Principal
--Select @statusOrden = 'PLN'

--Valida que la unidad ya este en la tabla QFSVehicles...
If Exists (select displayName from QSP..QFSVehicles where displayName = @unidad )
		BEGIN --2 existe la unidad en QFSVehicles
				-- Valida que la orden este en estatus de Planeada para enviar la macro de asignacion de carga.
				IF @statusOrden = 'PLN'
				BEGIN -- 3 estatus de la orden planeada
					-- Inserta el mensaje en la tabla de envia mensajes...

					   --DATOS DEL CLIENTE **********************************************************************************************************************************************************************************************
						INSERT Into QSP..EnviaMensajes (cuenta, unidad, macro, mensaje, detmacro, fechainsersion)
						(select 5,@unidad, null, 
						'*CARTA PORTE* --- Orden:' + cast(rtrim(ord_number) as varchar)
						 + ' Cliente:' + (select isnull(cmp_name,'ND')  from company where cmp_id = ord_billto)  
						 + ' RFC:' + (select isnull(cmp_taxid,'ND') from company where cmp_id = ord_billto) 
						 + ' Domicilio Fiscal:' + (select cmp_address1 +' '+ cmp_address2 + ' '+ cmp_centroidctynmstct from company where cmp_id = ord_billto)

						--ORIGEN***********************************************************************************************************************************************************************************************

						 + ' Origen-Nombre:' + (select isnull(cmp_name,'ND') from company where cmp_id = rtrim(ord_originpoint))  
						 + ' Origen-Domicilio:' + (select isnull(cmp_address1,'') +' '+ isnull(cmp_address2,'') + ' '+ isnull(cmp_centroidctynmstct,'')  from company where cmp_id = rtrim(ord_originpoint))  

						 --DESTINO***********************************************************************************************************************************************************************************************
						 
						 + ' Destino-Nombre:' + (select isnull(cmp_name,'ND') from company where cmp_id = rtrim(ord_destpoint))  
						 + ' Destino-Domicilio:' +  (select isnull(cmp_address1,'') +' '+ isnull(cmp_address2,'') + ' '+ isnull(cmp_centroidctynmstct,'')    from company where cmp_id = rtrim(ord_destpoint))  
						 
					
					  
						
						, null, getdate()
					    from orderheader 
					    where mov_number = @NoMovimiento)


                       --MENSAJE PARA LOS EVENTOS *****************************************************************************************************************************************************************************************************
						INSERT Into QSP..EnviaMensajes (cuenta, unidad, macro, mensaje, detmacro, fechainsersion)
						(select 5,@unidad, null, 

						'**Detalle Carta Porte**  Orden:' + cast(rtrim(ord_number) as varchar)  + 

								 --REFERENCIA*********************************************************************************************************************************************************************************************
					     + ' Referencia:' + isnull(rtrim(ord_refnum),'')

						 --DATOS DE LA CARGA*********************************************************************************************************************************************************************************************
					     + ' Se dice cotiene:' + isnull(rtrim(ord_description),'')
						 + ' PESO: '+ CAST(rtrim(rtrim(ord_TOTALWEIGHT)) AS VARCHAR) 
						 
						 --REMOLQUES*****************************************************************************************************************************************************************************************************
						 
						 + ' Remolque:' + isnull(rtrim(ORD_TRAILER),'') +
						 + ' Remolque2:' + isnull(rtrim(ORD_TRAILER),'') 
						  



						  + '   Eventos:'+ CAST((SELECT COUNT(STP_NUMBER) FROM STOPS
								WHERE orderheader.ORD_HDRNUMBER = stops.ORD_hdrnumber) as varchar)
						  + ' KmsCargados: ' + 
									CAST((SELECT     IsNull(SUM(stp_lgh_mileage), 0)
											FROM          stops(NOLOCK)
											WHERE orderheader.ORD_HDRNUMBER = stops.ORD_hdrnumber AND stops.stp_loadstatus = 'LD')as varchar)
						  + ' KmVacios:'
								 +      CAST( (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
														FROM          stops(NOLOCK)
														WHERE orderheader.ORD_HDRNUMBER = stops.ORD_hdrnumber AND stops.stp_loadstatus <> 'LD') AS varchar)
						  + ' KmsTotales:'
								+      CAST( (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
											FROM          stops(NOLOCK)
												WHERE orderheader.ORD_HDRNUMBER = stops.ORD_hdrnumber ) AS varchar)
												 
						  + '////Comentarios:' + IsNull(rtrim(ord_remark),'')
									, null, getdate()
									from orderheader 
									where mov_number = @NoMovimiento)



							-- hace el select de las paradas y las inserta en la tabla temporal
							INSERT Into @TTparadas 
									SELECT '**' +(select name  from eventcodetable where abbr= stp_event)+'** -------------------- Orden:'+ cast(rtrim(ord_hdrnumber) as varchar) +'        Parada:'+ cast(rtrim(stp_sequence) as varchar) +' de '+ CAST((SELECT COUNT(STP_NUMBER) FROM STOPS
									WHERE  stp_type <> 'NONE' and @NoMovimiento = stops.mov_number) as varchar) + '       Fecha:'
									+ cast((rtrim(stp_schdtearliest)) as varchar) + ' Cliente:'+isnull(rtrim(cmp_name),'') +
									' Direccion:'+isnull(rtrim(stp_address),'') +''+isnull(rtrim(stp_address2),'')+'  Telefono:'+isnull(rtrim(stp_phonenumber),'')+'  Contacto:'+isnull(rtrim(stp_contact),'') as eventmsg
									FROM STOPS 
									WHERE @NoMovimiento = stops.mov_number and stp_type <> 'NONE'
									 order by stp_sequence



							--Si tiene detalle en las paradas, envia 1 mensaje por cada parada
								If Exists ( Select count(*) From  @TTparadas )
								Begin--4 si hay legs
								-- Se declara un curso para ir leyendo la tabla de paso
									DECLARE Paradas_Cursor CURSOR FOR 
									SELECT TT_parada
									FROM @TTparadas 
								
									OPEN Paradas_Cursor 
									FETCH NEXT FROM Paradas_Cursor INTO @V_parada
									WHILE @@FETCH_STATUS = 0 
										BEGIN --5 del cursor Paradas_Cursor 
											--SELECT @V_parada
											-- Insert el mensaje con la descripcion de la parada.
											INSERT Into QSP..EnviaMensajes (cuenta, unidad, macro, mensaje, detmacro)
											Values(5,@unidad, null, @V_parada,null )

											FETCH NEXT FROM Paradas_Cursor INTO @V_parada
										END -- 5 del cursor Paradas_Cursor 
					

							CLOSE Paradas_Cursor 
							DEALLOCATE Paradas_Cursor 
						END -- 4 curso de las paradas 
			--//	encuentro el billto

						select @V_billto =ord_billto from orderheader where mov_number = @NoMovimiento;
						IF @V_billto = 'LIVERPOL' OR @V_billto = 'ALMLIVER'
						-- Insert el mensaje especial como mensaje.
							BEGIN
								INSERT Into QSP..EnviaMensajes (cuenta, unidad, macro, mensaje, detmacro)
								Values(5,@unidad, null,'R E C U E R D A
								Revisar tus hoja de instrucciones donde se te indican las paradas autorizadas y citas de descarga.
								Notifica POR ESCRITO al CEMS cualquier eventualidad en el camino, evita boletinajes y sanciones economicas. 
								Antes de detenerte pide autorizacion al CEMS, una parada no autorizada es equivalente a ser boletinado automaticamente.' ,null )
							END

						IF @V_billto = 'KATNAT' OR @V_billto = 'COMMON' OR @V_billto = 'MEXARROZ' OR @V_billto = 'QUAD' OR @V_billto = 'WALMART' OR @V_billto = 'NESTLE'

						-- Insert el mensaje especial como mensaje.
							BEGIN
								INSERT Into QSP..EnviaMensajes (cuenta, unidad, macro, mensaje, detmacro)
								Values(5,@unidad, null,'SR. OPERADOR, si detectas exceso de peso en la carga mayor a 27 tons. 
													pasa a la bascula a pesar la caja y presenta el ticket en control de equipo, 
													para que te puedan ajustar el combustible. GRACIAS' ,null )
							END



						select ord_hdrnumber as orden, 
						'Macro enviada' as mensaje,
						 @unidad as unidad
						 from orderheader  where mov_number = @NoMovimiento
						-- Actualiza status de despachada...
						Update orderheader set ord_status = 'DSP' where mov_number = @NoMovimiento 
						Update legheader set lgh_outstatus = 'DSP' 
									where	mov_number = @NoMovimiento	and lgh_outstatus = 'PLN'
						Update assetassignment set asgn_status = 'DSP' where mov_number = @NoMovimiento and asgn_status = 'PLN'
				END  -- 3 estatus de la orden planeada 
				else
				 begin
						select ord_hdrnumber as orden,
						'El Estatus , debe de ser planeada para enviar la macro...' as mensaje, 
						@unidad as unidad
						from orderheader  where mov_number = @NoMovimiento
						end
		END	--2 existe la unidad en QFSVehicles


		------------------ verifica que la unidad tenga el sistema de NavMan...---------------------------------------------

		If Exists (select displayName from QSP..NWVehicles where displayName = @unidad )
		BEGIN --2.1 existe la unidad en NMVehicles
				-- Valida que la orden este en estatus de Planeada para enviar la macro de asignacion de carga.
				IF @statusOrden = 'PLN'
				BEGIN -- 3 estatus de la orden planeada
					-- Inserta el mensaje en la tabla de envia mensajes...

					   --DATOS DEL CLIENTE **********************************************************************************************************************************************************************************************
						INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro, fechainsersion)
						(select 5,@unidad, null, 
						'*CARTA PORTE* --- Orden:' + cast(rtrim(ord_number) as varchar)
						 + ' Cliente:' + (select isnull(cmp_name,'ND')  from company where cmp_id = ord_billto)  
						 + ' RFC:' + (select isnull(cmp_taxid,'ND') from company where cmp_id = ord_billto) 
						 + ' Domicilio Fiscal:' + (select cmp_address1 +' '+ cmp_address2 + ' '+ cmp_centroidctynmstct from company where cmp_id = ord_billto)

						--ORIGEN***********************************************************************************************************************************************************************************************

						 + ' Origen-Nombre:' + (select isnull(cmp_name,'ND') from company where cmp_id = rtrim(ord_originpoint))  
						 + ' Origen-Domicilio:' + (select isnull(cmp_address1,'') +' '+ isnull(cmp_address2,'') + ' '+ isnull(cmp_centroidctynmstct,'')  from company where cmp_id = rtrim(ord_originpoint))  

						 --DESTINO***********************************************************************************************************************************************************************************************
						 
						 + ' Destino-Nombre:' + (select isnull(cmp_name,'ND') from company where cmp_id = rtrim(ord_destpoint))  
						 + ' Destino-Domicilio:' +  (select isnull(cmp_address1,'') +' '+ isnull(cmp_address2,'') + ' '+ isnull(cmp_centroidctynmstct,'')    from company where cmp_id = rtrim(ord_destpoint))  
						 
					
					  
						
						, null, getdate()
					    from orderheader 
					    where mov_number = @NoMovimiento)


                       --MENSAJE PARA LOS EVENTOS *****************************************************************************************************************************************************************************************************
						INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro, fechainsersion)
						(select 5,@unidad, null, 

						'**Detalle Carta Porte**  Orden:' + cast(rtrim(ord_number) as varchar)  + 

								 --REFERENCIA*********************************************************************************************************************************************************************************************
					     + ' Referencia:' + isnull(rtrim(ord_refnum),'')

						 --DATOS DE LA CARGA*********************************************************************************************************************************************************************************************
					     + ' Se dice cotiene:' + isnull(rtrim(ord_description),'')
						 + ' PESO: '+ CAST(rtrim(rtrim(ord_TOTALWEIGHT)) AS VARCHAR) 
						 
						 --REMOLQUES*****************************************************************************************************************************************************************************************************
						 
						 + ' Remolque:' + isnull(rtrim(ORD_TRAILER),'') +
						 + ' Remolque2:' + isnull(rtrim(ORD_TRAILER),'') 
						  



						  + '   Eventos:'+ CAST((SELECT COUNT(STP_NUMBER) FROM STOPS
								WHERE orderheader.ORD_HDRNUMBER = stops.ORD_hdrnumber) as varchar)
						  + ' KmsCargados: ' + 
									CAST((SELECT     IsNull(SUM(stp_lgh_mileage), 0)
											FROM          stops(NOLOCK)
											WHERE orderheader.ORD_HDRNUMBER = stops.ORD_hdrnumber AND stops.stp_loadstatus = 'LD')as varchar)
						  + ' KmVacios:'
								 +      CAST( (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
														FROM          stops(NOLOCK)
														WHERE orderheader.ORD_HDRNUMBER = stops.ORD_hdrnumber AND stops.stp_loadstatus <> 'LD') AS varchar)
						  + ' KmsTotales:'
								+      CAST( (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
											FROM          stops(NOLOCK)
												WHERE orderheader.ORD_HDRNUMBER = stops.ORD_hdrnumber ) AS varchar)
												 
						  + '////Comentarios:' + IsNull(rtrim(ord_remark),'')
									, null, getdate()
									from orderheader 
									where mov_number = @NoMovimiento)



							-- hace el select de las paradas y las inserta en la tabla temporal
							INSERT Into @TTparadas 
									SELECT '**' +(select name  from eventcodetable where abbr= stp_event)+'** -------------------- Orden:'+ cast(rtrim(ord_hdrnumber) as varchar) +'        Parada:'+ cast(rtrim(stp_sequence) as varchar) +' de '+ CAST((SELECT COUNT(STP_NUMBER) FROM STOPS
									WHERE  stp_type <> 'NONE' and @NoMovimiento = stops.mov_number) as varchar) + '       Fecha:'
									+ cast((rtrim(stp_schdtearliest)) as varchar) + ' Cliente:'+isnull(rtrim(cmp_name),'') +
									' Direccion:'+isnull(rtrim(stp_address),'') +''+isnull(rtrim(stp_address2),'')+'  Telefono:'+isnull(rtrim(stp_phonenumber),'')+'  Contacto:'+isnull(rtrim(stp_contact),'') as eventmsg
									FROM STOPS 
									WHERE @NoMovimiento = stops.mov_number and stp_type <> 'NONE'
									 order by stp_sequence



							--Si tiene detalle en las paradas, envia 1 mensaje por cada parada
								If Exists ( Select count(*) From  @TTparadas )
								Begin--4 si hay legs
								-- Se declara un curso para ir leyendo la tabla de paso
									DECLARE Paradas_Cursor CURSOR FOR 
									SELECT TT_parada
									FROM @TTparadas 
								
									OPEN Paradas_Cursor 
									FETCH NEXT FROM Paradas_Cursor INTO @V_parada
									WHILE @@FETCH_STATUS = 0 
										BEGIN --5 del cursor Paradas_Cursor 
											--SELECT @V_parada
											-- Insert el mensaje con la descripcion de la parada.
											INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro)
											Values(5,@unidad, null, @V_parada,null )

											FETCH NEXT FROM Paradas_Cursor INTO @V_parada
										END -- 5 del cursor Paradas_Cursor 
					

							CLOSE Paradas_Cursor 
							DEALLOCATE Paradas_Cursor 
						END -- 4 curso de las paradas 
			--//	encuentro el billto

						select @V_billto =ord_billto from orderheader where mov_number = @NoMovimiento;
						IF @V_billto = 'LIVERPOL' OR @V_billto = 'ALMLIVER'
						-- Insert el mensaje especial como mensaje.
							BEGIN
								INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro)
								Values(5,@unidad, null,'R E C U E R D A
								Revisar tus hoja de instrucciones donde se te indican las paradas autorizadas y citas de descarga.
								Notifica POR ESCRITO al CEMS cualquier eventualidad en el camino, evita boletinajes y sanciones economicas. 
								Antes de detenerte pide autorizacion al CEMS, una parada no autorizada es equivalente a ser boletinado automaticamente.' ,null )
							END

						IF @V_billto = 'KATNAT' OR @V_billto = 'COMMON' OR @V_billto = 'MEXARROZ' OR @V_billto = 'QUAD' OR @V_billto = 'WALMART' OR @V_billto = 'NESTLE'

						-- Insert el mensaje especial como mensaje.
							BEGIN
								INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro)
								Values(5,@unidad, null,'SR. OPERADOR, si detectas exceso de peso en la carga mayor a 27 tons. 
													pasa a la bascula a pesar la caja y presenta el ticket en control de equipo, 
													para que te puedan ajustar el combustible. GRACIAS' ,null )
							END



						select ord_hdrnumber as orden,
						 'Macro enviada' as mensaje,
						  @unidad as unidad
						   from orderheader  where mov_number = @NoMovimiento
						-- Actualiza status de despachada...
						Update orderheader set ord_status = 'DSP' where mov_number = @NoMovimiento 
						Update legheader set lgh_outstatus = 'DSP' 
									where	mov_number = @NoMovimiento	and lgh_outstatus = 'PLN'
						Update assetassignment set asgn_status = 'DSP' where mov_number = @NoMovimiento and asgn_status = 'PLN'
				END  -- 3 estatus de la orden planeada 
				else
				 begin
						select ord_hdrnumber as orden, 
						'El Estatus , debe de ser planeada para enviar la macro...' as mensaje,
						 @unidad as unidad
						 from tmwSuite..orderheader  where mov_number = @NoMovimiento
			     end
		END	--2 existe la unidad en QFSVehicles

		ELSE

		BEGIN

		select ord_hdrnumber as orden,
		'No tiene sistema QFS ni Navman la Unidad' as mensaje,
		 @unidad as unidad  from tmwSuite..orderheader  where mov_number = @NoMovimiento
		END
END --1 Principal



GO
