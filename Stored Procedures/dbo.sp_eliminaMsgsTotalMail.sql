SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Store Procedure que obtiene las ordenes cerradas en una semana
-- este reporte se crea cada Viernes.
--Drop Proc  sp_eliminaMsgsTotalMail

CREATE procedure [dbo].[sp_eliminaMsgsTotalMail]
AS

Declare @fechahace14 datetime


SELECT  DATEADD(day, -14,  GETDATE())

-- Resta 14 dias para dejar un historial de 14 dias en los mensajes.

SELECT @fechahace14 = DATEADD(day, -14,  GETDATE())

-- 1ro Elimina los mensajes con sus propiedades.
DELETE tblMsgProperties 
WHERE   MsgSN in (select SN from  tblmessages where 
		DTSent < @fechahace14 )

-- 2do. se elimina el historico
DELETE tblHistory 
WHERE  MsgSN in (select SN from  tblmessages where 
		DTSent < @fechahace14 )

--  3er. Se elimina los mensajes.

DELETE tblmessages where DTSent < @fechahace14



GO
