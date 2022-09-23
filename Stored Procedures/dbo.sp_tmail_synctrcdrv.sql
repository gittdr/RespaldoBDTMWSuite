SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**********
Descripcion: Stored proc que actualiza la asignacion de operadores a unidades
les asigna su flota correcta, crea mobile comm units si se crearon nuevos tractores y no se dieron de alta 

Autor: Emilio Olvera Yanez
Version: 5.0
Fecha rev:Jueves 14 de Junio 2018

exec sp_tmail_synctrcdrv 

*************/

CREATE proc [dbo].[sp_tmail_synctrcdrv] 

as

--agregar nuevos cabs units si se agregaron nuevas unidades (no considerando las que ya esta en OUT)

	insert into tblCabUnits ( UnitID, Type, Truck, CurrentDispatcher, InBox, OutBox, Retired, GroupFlag, UpdateGroup, MCPassword, LinkedAddrType, LinkedObjSN, InstanceId, RouteSyncEnabled, PositionOnly, 
							 EnableZippedBlobs, OutInstanceId)

	select 

	truckname+'.' Unitid,
	32 Type,
	SN Truck,
	0 currentdispatchgroup,
	inbox,
	outbox,
	'False' Retired,
	0 Groupflag,
	0 Updategroup,
	'' as password,
	4 linkedaddrtype,
	SN linkedsn,
	1 instance,
	'False',
	'False',
	'False',
	NULL
	  from tbltrucks
	  where truckname+'.' not in (select unitid from      tblCabUnits)
	  and truckname+'.' not in ((select trc_number+'.' from tractorprofile (nolock) where trc_Status = 'OUT'))


   --asignacion de los cabunits creados a los tractores 


    update tbltrucks set defaultcabunit = (select SN from tblcabunits where unitid = truckname+'.') where defaultcabunit is null 


  --Borrado de cabunits de unidades que se dieron de baja.

  delete tblCabUnits where unitid in (select trc_number+'.' from tractorprofile (nolock) where trc_Status = 'OUT')


  ---***************************************************************************************************************************************************************************************************-------------------------

  --Update para poner los tractos en el dispatch group con base en la flota TMW

  update tblTrucks set CurrentDispatcher = 
 
   (select SN  from tblDispatchGroup tg where tg.name = 
   (select name
    from labelfile where labeldefinition = 'fleet' and abbr = trc_Fleet) ) 
    from tractorprofile
    inner join tblTrucks on truckname = trc_number
    where  trc_number <> 'UNKNOWN'


    --poner en grupo INOUT drivers dados de baja mpp_Status = 'OUT'

	 update tbltrucks set CurrentDispatcher =(select SN  from tblDispatchGroup tg where tg.name =  'In & Out')
	 where DispSystruckID in (select trc_number from tractorprofile nolock where trc_status = 'OUT')


	--update para poner los drivers en el dispatch group con base en la flota TMW

	update tblDrivers set CurrentDispatcher = 
 
	(select SN  from tblDispatchGroup tg where tg.name = 
	(select name
	 from labelfile where labeldefinition = 'fleet' and abbr = mpp_Fleet) ) 
	 from manpowerprofile
	 inner join tblDrivers on DispSysDriverID = mpp_id
	 where mpp_status <> 'OUT'
	 and mpp_id <> 'UNKNOWN'

	 --poner en grupo INOUT drivers dados de baja mpp_Status = 'OUT'

	 update tblDrivers set CurrentDispatcher =(select SN  from tblDispatchGroup tg where tg.name =  'In & Out')
	 where DispSysDriverID in (select mpp_id from manpowerprofile nolock where mpp_status = 'OUT')


---***************************************************************************************************************************************************************************************************-------------------------

     --update para poner el driver correcto en el tractor

	 update tblTrucks set defaultdriver = (select SN from tbldrivers where dispsysdriverid = (select trc_driver from tractorprofile (nolock) where trc_number = dispsystruckid))
	 
	 --update para pone el tracto correcto en el driver

	 update tblDrivers set CurrentTruck = (select SN from tblTrucks where dispsystruckid = (select mpp_tractornumber from manpowerprofile (nolock) where mpp_id = DispSysDriverID))


---***************************************************************************************************************************************************************************************************-------------------------

	 --limpiar la libreta de direcciones
     delete tblAddresses where (select name from tblFolders where sn = inbox) is null

	 --Se pone de nombre del operador del id no el nombre completo

	 update tbldrivers set name = dispsysdriverid






   
GO
