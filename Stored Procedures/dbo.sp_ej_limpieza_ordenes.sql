SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--exec sp_ej_limpieza_ordenes 'STD'
CREATE  PROC [dbo].[sp_ej_limpieza_ordenes]
 @status varchar(6)

AS

declare @ordenl varchar(30)
declare @ordens varchar(3)
declare @V_registros integer
declare @V_i integer


--CREAMOS TABLA VIRTUAL CON LAS ORDENES QUE VAMOS A PROCESAR

Declare @Ordenes Table (orden varchar(30), ordstatus varchar(3))

--(A)    CANCELAR ORDENES EN AVL QUE TENGAN MAS DE UN DIA EN AVL----------------
--INSERTAMOS LAS ORDENES QUE ESTEN EN AVL y TENGAN HOY - FECHA DE CARGA  >= 2


IF @status in ('AVL','AVH','PND')
 BEGIN
	INSERT INTO @ordenes
	select ord_hdrnumber,ord_status from orderheader where ord_status in ('AVL','AVH','PND')  and datediff(hh,ord_startdate,getdate())>= 120
 END




--(B) EMPEZAR ORDENES EN PLN QUE TENGAN MAS DE UN DIA EN PLN----------------
--INSERTAMOS LAS ORDENES QUE ESTEN EN PLN y TENGAN  HOY - FECHA DE CARGA  >= 1
/*IF @status in ('PLN','TODOS')
 BEGIN
	INSERT INTO @ordenes
	select ord_hdrnumber,ord_status,ord_startdate, ord_completiondate from orderheader where ord_status = ('PLN')  and datediff(dd,ord_startdate,getdate())>= 1
 END
*/
--(C)       COMPLETAR ORDENES EN PLN QUE TENGAN MAS DE UN DIA EN STD----------------
--HOY - FECHA ENTREGA/DESCARGA DEL ULTIMO STOP = >1
IF @status in ('STD')
 BEGIN
	INSERT INTO @ordenes
	select ord_hdrnumber,ord_status from orderheader o where ord_status = ('STD') and datediff(dd, (select isnull(max(stp_departuredate),'1900-01-01')  from stops st where st.ord_hdrnumber = o.ord_hdrnumber)  ,getdate())>= 1 
 END

--YA TENIENDO TODAS LAS ORDENES REQUERIDAS EN LA TABLA VIRTUAL VAMOS A RECORRER LA TABLA CON UN CURSOR PARA QUE EJECUTE EL sp_limpieza_ordenes
--EL SP RECIBE EL NUMERO DE LA ORDEN Y EL STATUS PARA QUE EN BASE A ESTE CAMBIE EL STATUS DE LA ORDEN

        --Se inicializa variable de la orden
        select @ordenl = 0

    	--Se obtiene el total de ordenes que existen en la tabla virtual
		select @V_registros =  
        (select count(*) from  @ordenes)
     
		--Se inicializa el contador en 0
		select @V_i = 0

		-- Si existen ordenes en la tabla virtual continua
		If Exists (select count(*) from  @ordenes)
		
        BEGIN --Si hay registros procedemos.

          DECLARE Recorre_ordenespurga CURSOR 
		  FOR  (select orden,ordstatus from @ordenes )
		

		  OPEN Recorre_ordenespurga
		    FETCH NEXT FROM Recorre_ordenespurga  INTO @ordenl,@ordens
			WHILE (@@FETCH_STATUS = 0 and @V_i < @V_registros)
			   BEGIN -- del cursor 

								--cacelamos los movimientos de la orden cambiando el status
								exec sp_limpieza_ordenes @ordenl, @ordens

								select @V_i = @V_i + 1

								FETCH NEXT FROM Recorre_ordenespurga INTO @ordenl,@ordens
						
				END -- del cursor
					    
		CLOSE Recorre_ordenespurga
		DEALLOCATE Recorre_ordenespurga
		END


GO
