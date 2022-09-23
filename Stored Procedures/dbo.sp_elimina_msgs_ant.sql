SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_elimina_msgs_ant]  AS

DECLARE @i_totalmsgs1            integer,
	@i_totalmsgs4            integer,
	@msg_error		 varchar(30),
	@fechamayor		 DATETIME,
	@fechamenor		 DATETIME

/* Obtiene la fecha del dia de hoy a las 14:00 para restarle 4hrs */

SELECT @fechamayor  = DATEADD(hour, -4, GETDATE())
SELECT @fechamenor  = DATEADD(hour, -24, (SELECT DATEADD(hour, -4, GETDATE())))

-- 1ro Elimina los mensajes con sus propiedades.

DELETE tblMsgProperties 
WHERE  MsgSN in (select SN from  tblmessages where 
		CAST(contents AS varchar(7)) in ( 'Checkca','DETECCI','PERDIDA' )  and 
		DTSent >= @fechamenor and DTSent <= @fechamayor)

/*verifica si hubo algun error*/
 IF @@error <> 0 
    BEGIN
      SELECT @msg_error = 'Problemas al leer los mensajes'
    END

-- 2do. se elimina el historico
DELETE tblHistory 
WHERE MsgSN in (select SN from  tblmessages where 
		CAST(contents AS varchar(7)) in ( 'Checkca','DETECCI','PERDIDA' ) and 
		DTSent >= @fechamenor and DTSent <= @fechamayor)

/*verifica si hubo algun error*/
 IF @@error <> 0 
    BEGIN
      SELECT @msg_error = 'Problemas al leer los mensajes'
    END

--  3er. Se elimina los mensajes.

DELETE tblmessages 
WHERE CAST(contents AS varchar(7)) in ( 'Checkca','DETECCI','PERDIDA' ) and 
DTSent >= @fechamenor and DTSent <= @fechamayor

/*verifica si hubo algun error*/
 IF @@error <> 0 
    BEGIN
      SELECT @msg_error = 'Problemas al leer los mensajes'
    END

GO
