SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**********************
SP inserta mensajes a total mail
Autor: Emilio Olvera

Descripcion: Sp que recibe como parametro el mensaje y el numero de la unidad e inserta el mensaje en totalmail

prueba

exec tm_insertamensaje 'probando prueba user', '1282','OEYE'

3/oct/2017 se agrega validacion para que si el contenido del mensaje es null no inserte

************************/



CREATE proc [dbo].[tm_insertamensaje]  (@mensaje text, @unidad varchar(10),@usuario varchar(10) = null)

as 
 begin 

 declare @drvsn int,
         @trcsn int,
		 @newSn int 

	
		 select @trcsn =  (select sn from tblTrucks nolock where DispSysTruckID = @unidad)
		 select @drvsn =  (select sn from tblDrivers nolock where DispSysDriverID = (select trc_Driver from tractorprofile nolock where trc_number = @unidad))

	
	if (@mensaje is not null) 
	 BEGIN


  IF(@usuario is null)
	 BEGIN
         insert into tblmessages (Type, Status	,Priority	,FromType	,DeliverToType	,DTSent, Folder	,Contents	,FromName
		,Subject, DeliverTo	,NLCPositionZip,Receipt,DeliveryKey,Position,ReplyFormID,BaseSN, ToTrcSN, ToDrvSN	)
         values (1, 4, 2, 1, 1, getdate(),362,@mensaje,'Admin', cast(@mensaje as varchar(255)) ,@unidad,'A2NP' ,2, 2,0, 0, 9,@trcsn,@drvsn)

		   --regresamos el prox id

           SELECT @NewSN = @@IDENTITY	-- Get the SN of the new record
           RETURN @NewSN


	 END
	ELSE
	 BEGIN
         insert into tblmessages (Type, Status	,Priority	,FromType	,DeliverToType	,DTSent, Folder	,Contents	,FromName
		,Subject, DeliverTo	,NLCPositionZip,Receipt,DeliveryKey,Position,ReplyFormID,BaseSN, ToTrcSN, ToDrvSN	)
         values (1, 4, 2, 1, 1, getdate(),362,@mensaje,@usuario, cast(@mensaje as varchar(255)) ,@unidad,'A2NP' ,2, 2,0, 0, 9,@trcsn,@drvsn)


		   --regresamos el prox id

            SELECT @NewSN = @@IDENTITY	-- Get the SN of the new record
            RETURN @NewSN


	 END
	 

      


 --insertamos el mensajes en la tabla message to

        
		 insert into tblTo (Message, ToName, ToType, isCC)

		(select 
		sn,
		toname = DeliverTo,
		totype = 4 ,  --- 3 es para grupos
		0
		from tblMessages (nolock)
		 where NLCPositionZip = 'A2NP' ) 

   
      -----------insert en la tabla de history en el modo truck para la consulta ------------------------------------------------------------------------------------------------------------------



      insert into tblHistory  (DriverSN,TruckSN,MsgSN,Chached)

      (select null, (select sn from tmwsuite..tbltrucks (nolock) where truckname = DeliverTo), sn,0
       from tmwsuite.dbo.tblMessages (nolock)
       where NLCPositionZip = 'A2NP' ) 

 
 --cambiamos la bandera de envio--------------------------------------------------------------------
  update tblMessages set  NLCPositionZip = 'A2NE' where  NLCPositionZip = 'A2NP'





  END
  

 end
GO
