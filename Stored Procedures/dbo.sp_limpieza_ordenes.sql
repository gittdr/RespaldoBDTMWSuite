SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


--  exec [dbo].[sp_limpieza_ordenes] '340948','AVL'

CREATE PROC [dbo].[sp_limpieza_ordenes]
       @ordencan varchar(30), @ord_status varchar (3)

AS

	declare @stopcan int
	declare @V_registros integer
	declare @V_i integer


    declare @legcan int
	declare @L_registros integer
	declare @L_i integer
    
    declare @tractor varchar(10)
    declare @trailer1 varchar(10)
    declare @trailer2 varchar(10)
    declare @operador varchar(10)
                     
    declare @esttractor varchar(3)
    declare @esttrailer1 varchar(3)
    declare @esttrailer2 varchar(3)
    declare @estoperador varchar(3)
    declare @bandera integer
    declare @movimiento varchar(20) 



--***********************************************************************************************************************************************************************************************************
--**                                                    CASO (A) SI LA ORDEN ESTA EN AVL VAMOS A EJECUTAR TODO EL PROCESO PARA CANCELARLA                                                                  **
--***********************************************************************************************************************************************************************************************************

   if @ord_status in ('AVL','AVH','PND')
    BEGIN 
   

		--1///////CANCELAR STOPS/////////////////////////////////////////////////////////////////////
       

		--Se obtiene el total de movimientos de la orden
        select @movimiento = (Select top 1 mov_number from stops s where ord_hdrnumber = @ordencan )
	

		select @V_registros =  (Select count(*) from stops s where mov_number  = @movimiento )
		--Se inicializa el contador en 0
		select @V_i = 0

		-- Si hay movimientos en la tabla continua
		If Exists ( Select count(*) from stops s where mov_number  = @movimiento )

		BEGIN --Si hay registros procedemos.


		DECLARE Cancelar_stops CURSOR 
		FOR  (SELECT STP_NUMBER from stops s where mov_number  = @movimiento )

		OPEN Cancelar_stops
				FETCH NEXT FROM Cancelar_stops  INTO @stopcan
				WHILE (@@FETCH_STATUS = 0 and @V_i < @V_registros)
				  BEGIN -- del cursor 

					--cacelamos los movimientos de la orden cambiando el status
					UPDATE stops SET stp_status = 'NON', stp_lgh_status = 'AVL'  WHERE stp_number = @stopcan

					select @V_i = @V_i + 1

					FETCH NEXT FROM Cancelar_stops  INTO @stopcan
			
				   END -- del cursor
		    
		CLOSE Cancelar_stops 
		DEALLOCATE Cancelar_stops 
		END



		--2///////CANCELAR ORDEN/////////////////////////////////////////////////////////////////////

		update orderheader SET ord_status ='CAN', ord_invoicestatus ='XIN' WHERE orderheader.ord_hdrnumber =@ordencan

		--3///////BORRAR EVENTOS DE LOS STOPS DMT EMT/////////////////////////////////////////////////////////////////////

		DELETE event FROM stops WHERE stops.ord_hdrnumber =@ordencan AND event.stp_number =stops.stp_number AND event.evt_sequence > 1 AND event.evt_eventcode IN ( 'DMT' , 'EMT' ) 
		DELETE ticket_order_entry_plan_orders WHERE ord_hdrnumber = @ordencan
		-- 3.1- Elimina los registros en la tabla assetassignment jr
		delete assetassignment where mov_number= @movimiento

		--4///////INSERTAR EN EL LOG DE CANCELACION DE ORDENES////////////////////////////////////////////////////////////////////
		INSERT INTO dbo.orderheader_cancel_log ( ord_hdrnumber, ord_number, ohc_cancelled_by, ohc_cancelled_date, ohc_requested_by, ohc_remark ) 
		VALUES ( @ordencan , @ordencan, 'SATDR', getdate() , 'SATDR', 'ORDER CLEANING PROCESS' )

		--5///////CREAR NOTA DE CANCELACION////////////////////////////////////////////////////////////////////
		exec dx_add_note 'orderheader', @ordencan , 0,0, 'Estatus cambiado de AVL a CAN por proceso purga ordenes', 'N',null,''

		--6///////CANCELAR LOS LEGS DE LA ORDEN ////////////////////////////////////////////////////////////////////
		update legheader  set lgh_outstatus = 'CAN'  where ord_hdrnumber = @ordencan
   

  END

--***********************************************************************************************************************************************************************************************************
--**                                                    CASO (B) SI LA ORDEN ESTA EN PLN VAMOS A EJECUTAR TODO EL PROCESO PARA INICIARLA                                                                   **
--**                                    mod 17-12-2013, se incluyo el cambio del estatus de los recursos implicados en la orden por el ult estatus asignado al recurso en assetassigment                   **
--***********************************************************************************************************************************************************************************************************

if @ord_status = 'PLN'
 BEGIN
     
 --1/////////OBTENER EL ESTADO DE LOS RECURSOS DE LA ORDEN///////////////////////////////////////



     --Se obtiene el total de legs de la orden
		select @L_registros =  (Select count(*) from legheader where ord_hdrnumber = @ordencan)
		--Se inicializa el contador en 0
		select @L_i = 0

		-- Si hay legs en la tabla continua
		If Exists (Select count(*) from legheader where ord_hdrnumber = @ordencan)
		BEGIN --Si hay registros procedemos.


		DECLARE iniciar_recursos CURSOR 
		FOR (select lgh_number from legheader where ord_hdrnumber = @ordencan)

		OPEN  iniciar_recursos
				FETCH NEXT FROM  iniciar_recursos  INTO @legcan
				WHILE (@@FETCH_STATUS = 0 and @L_i < @L_registros)
				  BEGIN -- del cursor 

                    --iniciamos el primer evento de la orden en base a sus legs
                  
                 
                    --ponemos los recursos en el estatus de la ultima asignacion que tienen
                     select @tractor = (select asgn_id from assetassignment WHERE lgh_number =  @legcan and asgn_type = 'TRC')
                     select @trailer1 = (select max(asgn_id) from assetassignment WHERE lgh_number =  @legcan and asgn_type = 'TRL')
                     select @trailer2 = (select min(asgn_id) from assetassignment WHERE lgh_number =  @legcan and asgn_type = 'TRL')
                     select @operador = (select asgn_id from assetassignment WHERE lgh_number =  @legcan and asgn_type = 'DRV')

                     select @esttractor  = isnull((select max(asgn_status) from assetassignment where asgn_type = 'TRC' and asgn_id = @tractor and asgn_status = 'STD'),'EEE')  
                     select @esttrailer1 = isnull((select max(asgn_status) from assetassignment where asgn_type = 'TRL' and asgn_id = @trailer1 and asgn_status = 'STD') ,'EEE')
                     select @esttrailer2 = isnull((select max(asgn_status) from assetassignment where asgn_type = 'TRL' and asgn_id = @trailer2 and asgn_status = 'STD') ,'EEE')
                     select @estoperador = isnull((select max(asgn_status) from assetassignment where asgn_type = 'DRV' and asgn_id = @operador and asgn_status = 'STD') ,'EEE')
            
                     if ( @esttractor <> 'STD') and (@esttrailer1 <> 'STD') and (@esttrailer2 <> 'STD') and (@estoperador <> 'STD')
                      begin
                       update stops set stp_status = 'DNE' where lgh_number = @legcan  and stp_mfh_sequence = 1
					   --iniciamos la asignacion de los recursos de la orden en base a sus legs
					   update assetassignment SET asgn_status = 'STD' WHERE lgh_number =  @legcan

                       update tractorprofile  set trc_status = 'USE'  where trc_number = @tractor and trc_status <> 'OUT'
                       update trailerprofile  set trl_status = 'USE'  where trl_number = @trailer1  and trl_status <> 'OUT'
                       update trailerprofile  set trl_status = 'USE' where trl_number = @trailer2  and trl_status <> 'OUT'
                       update manpowerprofile set mpp_status = 'USE' where mpp_id = @operador  and mpp_status <> 'OUT'

                       select @bandera = 1
                      end

					select @L_i = @L_i + 1

					FETCH NEXT FROM iniciar_recursos   INTO @stopcan
			
				   END -- del cursor
		    
		CLOSE iniciar_recursos 
		DEALLOCATE iniciar_recursos 
        END

      if @bandera =1 
       begin
	    --2///////INICIAR ORDEN/////////////////////////////////////////////////////////////////////
	    update orderheader SET ord_status ='STD' WHERE orderheader.ord_hdrnumber =@ordencan

	   --3///////INICIAR LOS LEGS DE LA ORDEN ////////////////////////////////////////////////////////////////////
	   update legheader  set lgh_outstatus = 'STD'  where ord_hdrnumber = @ordencan


       --4///////INSERTAR NOTA EN LA ORDEN PARA AVISAR QUE SE AUTO INICIO /////////////////////////////////////////
      exec dx_add_note 'orderheader', @ordencan , 0,0, 'Estatus cambiado de PLN a STD por proceso purga ordenes', 'N',null,''
       end
      


 END


--***********************************************************************************************************************************************************************************************************
--**                                                    CASO (C) SI LA ORDEN ESTA EN STD VAMOS A EJECUTAR TODO EL PROCESO PARA COMPLETARLA                                                                 **
--**                                    mod 17-12-2013, se incluyo el cambio del estatus de los recursos implicados en la orden por el ult estatus asignado al recurso en assetassigment                   **
--***********************************************************************************************************************************************************************************************************


if @ord_status = 'STD'
 BEGIN 

	  --1///////TERMINAR STOPS/////////////////////////////////////////////////////////////////////

		--Se obtiene el total de movimientos de la orden
        select @movimiento = (Select top 1 mov_number from stops s where ord_hdrnumber = @ordencan )
		select @V_registros =  (Select count(*) from stops s where mov_number = @movimiento )
		--Se inicializa el contador en 0
		select @V_i = 0

		-- Si hay movimientos en la tabla continua
		If Exists ( Select count(*) from stops s where  mov_number = @movimiento )
		BEGIN --Si hay registros procedemos.


		DECLARE terminar_stops CURSOR 
		FOR  (SELECT STP_NUMBER from stops s where  mov_number = @movimiento )

		OPEN terminar_stops
				FETCH NEXT FROM terminar_stops  INTO @stopcan
				WHILE (@@FETCH_STATUS = 0 and @V_i < @V_registros)
				  BEGIN -- del cursor 

					--completamos los movimientos de la orden cambiando el status
					UPDATE stops SET stp_status = 'DNE', stp_lgh_Status = 'CMP'  WHERE stp_number = @stopcan

                
					select @V_i = @V_i + 1

					FETCH NEXT FROM terminar_stops  INTO @stopcan
			
				   END -- del cursor
		    
		CLOSE terminar_stops 
		DEALLOCATE terminar_stops 
		END


	  --2///////TERMINAR ORDEN/////////////////////////////////////////////////////////////////////
	  update orderheader SET ord_status ='CMP', ord_invoicestatus = 'AVL'  WHERE orderheader.ord_hdrnumber =@ordencan

	  --3///////TERMINAR LOS LEGS DE LA ORDEN ////////////////////////////////////////////////////////////////////
	   update legheader  set lgh_outstatus = 'CMP'  where ord_hdrnumber = @ordencan

      --4///////TERMINAR LOS RECURSOS DE LA ORDEN /////////////////////////////////////////

      --mov_number = @movimiento 

        --Se obtiene el total de legs de la movto
        select @L_registros =  (Select count(*) from legheader where mov_number = @movimiento )
		--select @L_registros =  (Select count(*) from legheader where ord_hdrnumber = @ordencan)
		--Se inicializa el contador en 0
		select @L_i = 0

		-- Si hay legs en la tabla continua
		If Exists (Select count(*) from legheader where mov_number = @movimiento)
		BEGIN --Si hay registros procedemos.


		DECLARE terminar_recursos CURSOR 
		FOR (select lgh_number from legheader where mov_number = @movimiento)

		OPEN  terminar_recursos
				FETCH NEXT FROM  terminar_recursos  INTO @legcan
				WHILE (@@FETCH_STATUS = 0 and @L_i < @L_registros)
				  BEGIN -- del cursor 

					--completamos los recursos de las ordenes
					 update assetassignment SET asgn_status = 'CMP' WHERE lgh_number =  @legcan

                  
                     --ponemos los recursos en el estatus de la ultima asignacion que tienen
                     select @tractor = (select asgn_id from assetassignment WHERE lgh_number =  @legcan and asgn_type = 'TRC')
                     select @trailer1 = (select max(asgn_id) from assetassignment WHERE lgh_number =  @legcan and asgn_type = 'TRL')
                     select @trailer2 = (select min(asgn_id) from assetassignment WHERE lgh_number =  @legcan and asgn_type = 'TRL')
                     select @operador = (select max(asgn_id) from assetassignment WHERE lgh_number =  @legcan and asgn_type = 'DRV')

                     select @esttractor =  (select max(asgn_status) from assetassignment where asgn_type = 'TRC' and asgn_id = @tractor  and asgn_enddate = (select max(asgn_enddate) from assetassignment where asgn_type = 'TRC' and asgn_id = @tractor ))
                     select @esttrailer1 = (select max(asgn_status) from assetassignment where asgn_type = 'TRL' and asgn_id = @trailer1 and asgn_enddate = (select max(asgn_enddate) from assetassignment where asgn_type = 'TRL' and asgn_id = @trailer1 ))
                     select @esttrailer2 = (select max(asgn_status) from assetassignment where asgn_type = 'TRL' and asgn_id = @trailer2 and asgn_enddate = (select max(asgn_enddate) from assetassignment where asgn_type = 'TRL' and asgn_id = @trailer2 ))
                     select @estoperador = (select max(asgn_status) from assetassignment where asgn_type = 'DRV' and asgn_id = @operador  and asgn_enddate = (select max(asgn_enddate) from assetassignment where asgn_type = 'DRV' and asgn_id = @operador ))
            
                     update tractorprofile  set trc_status = replace(replace(@esttractor,'STD','USE'),'CMP','AVL')  where trc_number = @tractor and trc_status <> 'OUT'
                     update trailerprofile  set trl_status = replace(replace(@esttrailer1,'STD','USE'),'CMP','AVL')  where trl_number = @trailer1  and trl_status <> 'OUT'
                     update trailerprofile  set trl_status = replace(replace(@esttrailer2,'STD','USE'),'CMP','AVL')  where trl_number = @trailer2  and trl_status <> 'OUT'
                     update manpowerprofile set mpp_status = replace(replace(@estoperador,'STD','USE'),'CMP','AVL')  where mpp_id = @operador  and mpp_status <> 'OUT'



					select @L_i = @L_i + 1

					FETCH NEXT FROM terminar_recursos   INTO @stopcan
			
				   END -- del cursor
		    
		CLOSE terminar_recursos 
		DEALLOCATE terminar_recursos 
        END

      --5///////INSERTAR NOTA EN LA ORDEN PARA AVISAR QUE SE AUTO TERMINO /////////////////////////////////////////
      exec dx_add_note 'orderheader', @ordencan , 0,0, 'Estatus cambiado de STD a CMP por proceso purga ordenes', 'N',null,''
	 


 END
GO
