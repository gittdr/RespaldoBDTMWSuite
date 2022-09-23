SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[sp_tmalert] as
begin
--EXEC [sp_tmalert]
SELECT 
tblmessages.sn,

 'Mensaje nuevo de :' + fromname  + '  Asunto:' + subject + ' '  +' Mensaje: ' +

case when Contents like '%_*** EL OPERADOR NO RESPONDIO AL MENSAJE%' then 'Error al tratar de actualizar orden: ' + 
isnull((select 

case when description like  '%remolque%' then 'Error en remolque' 
		  when description like  '%Trailer not on file or assigned to that move%' then 'Error en remolque'
		  when description like  '%Change of trailer not permitted or missing Primary Trailer%' then 'Error en remolque'
		  when description like '%uses a value of the wrong type%'  then 'ConversionSPTMW'
		  when description like '%El recurso ingresado esta en uso en otra orden%' then 'El recurso esta en uso en otra orden'
		   when description like '%The equipment is already in use%' then 'El recurso esta en uso en otra orden'
		  when description like '%The equipment is in use on another trip%' then 'El recurso esta en uso en otra orden'
		  when description like '%Earlier activity for the move has not yet been completed%'  then 'Actividad previa para el movimiento no completada'
		  when description like '%Later stop is already completed%' then 'Stop posterior ya completado'
		  when description like '%That Trip Segment is already started%' then 'Viaje ya iniciado'
		  when description like '%Applicable order number not found%' then 'Numero de orden invalido'
		  when description like '%Specified date/time is later than expected%' then 'Citas caducas por mas de 72 hrs'
		  when description like '%Specified date/time is earlier than expected%' then 'Citas caducas por menos de 72 hrs'
		  when description like '%Departure date/time is later than expected%' then 'Citas caducas por mas de 72 hrs'
		  when description like '%Arrival or Departure date/time is earlier than expected%' then 'Citas caducas por menos de 72 hrs'
		  when description like  '%Tractor not found or not assigned/dispatched to that move%' then 'Tractor no encontrado o asignado a la orden'
		  when description like  '%Operador no existente o no asignado a la orden%' then 'Operador no encontradoo o no asignado a la orden'
		  when description like  '%or that tractor not assigned to it%' then 'Tractor no asignado a la orden, cambio de tractor de operador'
		  when description like  '%Driver not found or not assigned to that move%' then 'Operador no asignado a la orden, cambio de tractor de operador'
		  when description like '%SQL Server%' then 'Error SQL'
		  when description like '%Parse%' then 'Error Parseo SQL'
		  when description like '%Unrecognized unit of measure%' then 'Unidad de medida no reconocida'
		  when description like '%There is other incomplete activity in progress on that move%' then 'Actividad previa para el movimiento no completada'
		  else 'No clasificado'
		  end + ' | ' +isnull(substring(description,CHARINDEX('°',description), 1000),'')),'NA')
          else  dbo.[RTF2Text](Contents) end as mensaje,

DTsent,
flota = (select max(name) from labelfile where labeldefinition = 'fleet' and abbr =  (select  max(trc_fleet) from tractorprofile (nolock) where trc_number = fromname))

from tblMessages
left join tblMsgProperties on tblMessages.sn = tblMsgProperties.MsgSN 
left join tblErrorData on ErrListID = cast(tblMsgProperties.value as varchar(20))

where 
tblMsgProperties.PropSN = 6 and
positionzip <> 1 and tblmessages.sn = tblmessages.OrigMsgSn and
 ( (subject like '%mensaje libre de%' and FromType = 4 ) or  (Contents like '%_*** EL OPERADOR NO RESPONDIO AL MENSAJE%' ) )
 order by dtsent desc

 END


GO
