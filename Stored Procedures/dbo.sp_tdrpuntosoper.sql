SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--Ejecucion semanal que actualiza los tdr puntos de cada operador
--exec [sp_tdrpuntosoper]   '2014-01-01'

CREATE PROC [dbo].[sp_tdrpuntosoper]    
@fechabase datetime 

AS


declare @V_registros integer
declare @V_i integer
declare @kmspasados integer
declare @kmsnuevos integer
declare @operador  varchar(10)




   	--Se obtiene el total de metricas que existen
		select @V_registros =  
        (select count(*) from  [tdrappuspuntos]where Tipo = 'Operador')
     
		--Se inicializa el contador en 0
		select @V_i = 0


          DECLARE Recorre_operadores CURSOR 
		  FOR  (select idusuario  from  [tdrappuspuntos] where Tipo = 'Operador' )
		

		  OPEN Recorre_operadores 
		    FETCH NEXT FROM Recorre_operadores  INTO @operador
			WHILE (@@FETCH_STATUS = 0 and @V_i < @V_registros)
			   BEGIN -- del cursor 

					
        
                          select @kmspasados = (select Puntaje from   tdrappuspuntos WHERE  (IdUsuario = @operador))
                          select @kmsnuevos =  (select (isnull(sum(LegLoadedMiles),0) * 0.0238)  from ResNow_Triplets 
                                                where ord_startdate >  @fechabase   and ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_status = 'CMP')
                                                and  lgh_driver1 =  @operador) 

--/*
                               --Hacemos el update para que se den de alta los nuevos puntos acumulados
                               update  manpowerprofile  set mpp_cont_ded_nbr =   @kmsnuevos   where mpp_id =  @operador 
                               --insertamos en el estado de cuenta el registro de que se dieron de alta los nuevos puntos
                              
                              if @kmsnuevos > 0
                              begin
                               insert into tdrpuntos_edocuenta values (@operador,getdate(),@kmspasados,'PUNTOS GANADOS',@kmsnuevos-@kmspasados,'Incremento semanal por kms cargados en ordenes completadas',@kmsnuevos)
                              end
--*/
                     --Regresar puntos acumulados y descontados a 0
                      --Update manpowerprofile set mpp_updt_cont_ded_nbr = 0, mpp_exp2_enddate = null  where mpp_id = @operador 
                      --Update manpowerprofile set mpp_cont_ded_nbr = 0, mpp_exp2_enddate = null  where mpp_id = @operador 
                      --delete tdrpuntos_edocuenta

								select @V_i = @V_i + 1

								FETCH NEXT FROM Recorre_operadores INTO @operador
						
				END -- del cursor
					    
		CLOSE Recorre_operadores 
		DEALLOCATE Recorre_operadores 










GO
