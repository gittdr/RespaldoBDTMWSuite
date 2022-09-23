SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  VIEW  [dbo].[Eval_LPC] 

AS 
 SELECT 

	 (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ) as DriverID, 
	 gerente = case

	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Cemex'        then 'Angie Curro'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'GNV'          then 'Angie Curro'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Audi'  then 'Angie Curro'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Maulec'       then 'Angie Curro'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Pilgrims'     then 'Esther Mora'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'BMW'          then 'Esther Mora'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Sayer'        then 'Esther Mora'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Peñafiel'     then 'Angie Curro'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Liverpool'    then 'Isac Martinez'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Walmart'        then 'J.M. Solis'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'ABIERTO1'      then 'Ricardo Rivas'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'ABIERTO2'      then 'Ricardo Rivas'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'ABIERTO3'      then 'Ricardo Rivas'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Eucomex'      then 'Isac Martinez'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Fullsureste' then 'Isac Martinez'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Tolvas'       then 'Isac Martinez'
	 else ' '

	 end ,


	 lpc = case
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Cemex'        then 'Jaen Ortega'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'GNV'          then 'Yahir Martinez'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Audi'         then 'Jaen Ortega'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Maulec'       then 'Angie Curro'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Pilgrims'     then 'Karen Martinez'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'BMW'          then 'Christian Uribe'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Sayer'        then 'Ramon Escobedo'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Peñafiel'     then 'Jorge Gonzalez'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Liverpool'    then 'Carlos Duarte'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Wm Vh'        then 'Lorenzo Hernandez'
	  when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'ABIERTO1'      then 'Veronica Trejo'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'ABIERTO2'      then 'Carlos Zamudio'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'ABIERTO3'      then 'Claudia Ramirez'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Eucomex'      then 'Israel Orihuela'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Full sureste' then 'Carlos Duarte'
	 when  (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = 'Tolvas'       then 'Antonio Chavez'
	 else ' '
	  end
,
	 

	 (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) as flota,



	 ((select mpp_type3 from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) as proyecto,

	 ((select mpp_type4 from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) as division,

	 t.sn, t.dtsent, t.Subject,

     replace(replace(substring(subject,CHARINDEX('*',subject,1),(CHARINDEX('-',subject,1))),'*',''),'-','') as TipoMsg,

     description as error,

      case when Description like  '%remolque%' then 'Error en remolque' 

      when Description like  '%Trailer not on file or assigned to that move%' then 'Error en remolque'

	  when Description like  '%Change of trailer not permitted or missing Primary Trailer%' then 'Error en remolque'

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

	  when Description like '%SQL Server%' then 'Error SQL'

	  when Description like '%Parse%' then 'Error Parseo SQL'

	  when Description like '%Unrecognized unit of measure%' then 'Unidad de medida no reconocida'

	  when Description like '%There is other incomplete activity in progress on that move%' then 'Actividad previa para el movimiento no completada'

	  else 'No clasificado'



	  end as errorcategoria

	FROM tblMessages t (NOLOCK)

 		INNER JOIN tblMsgProperties (NOLOCK) ON t.SN = tblMsgProperties.MsgSN  

		join tblErrorData ON ErrListID= Value

 	WHERE  

 	tblMsgProperties.PropSN = 6 

	and subject like '%**%'

	and source like '%PSXact.clsPSXact: VB%'

	and subject <> '** ENVIAR CABECER DE CARGA **'

	and dtsent between '01-01-2019' and '12-31-2019'

	and  (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ) is not null

	--and (select name from labelfile where labeldefinition = 'fleet' and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) = @Flota

	
GO
