SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*Revision de folders existentes para todos los recursos

select inbox,* from tbltrucks where inbox not in (select sn from tblFolders)

select inbox,* from tblDrivers where inbox not in (select sn from tblFolders)

select inbox,* from tblCabUnits  where inbox not in (select sn from tblFolders)
 

*/


--exec tm_sync

CREATE proc [dbo].[tm_sync]
as 
begin

   --crear tractor virutal para permisionarios en caso de que aun no exista en totalmail

   declare @Virtrc varchar(20)

   DECLARE addvirtualtractor CURSOR FOR 
   select DispSysDriverID from tblDrivers (nolock) where DispSysDriverID like 'P-%' and '.'+DispSysDriverID not in (select TruckName from tblTrucks (nolock) where TruckName like '.P-%')

   OPEN addvirtualtractor 
	FETCH NEXT FROM addvirtualtractor  INTO @Virtrc

	WHILE (@@FETCH_STATUS = 0 )
	
	BEGIN 
	
	 select @Virtrc = '.' + @Virtrc

	 exec  [tm_ConfigTruck]  @Virtrc ,'','','','','',0,0,0
     
	 FETCH NEXT FROM addvirtualtractor  INTO @Virtrc
			
	END

    CLOSE addvirtualtractor
	DEALLOCATE addvirtualtractor


    --agregar nuevos cabs units si se agregaron nuevas unidades (incluye cab units para permisionarios).

	 declare @cabu varchar(20)

     DECLARE addmc CURSOR FOR 
     select  replace(truckname,'.','')+'.'  from tbltrucks where  replace(truckname,'.','') +'.' not in (select unitid from tblCabUnits)

     OPEN addmc 
	 FETCH NEXT FROM addmc  INTO @cabu

	 WHILE (@@FETCH_STATUS = 0 )
	
	 BEGIN 
	  
	  exec  [tm_ConfigMCUnit] @cabu,'','ELEOS','','',0,0,0,0
     
	  FETCH NEXT FROM addmc   INTO @cabu
			
	 END

     CLOSE addmc 
	 DEALLOCATE addmc 

	 update tblCabUnits set GroupFlag = 0 where GroupFlag is null
	 update tblCabUnits set InstanceId = 1 where InstanceId is null

     --updte para poner el mobilecomm en unidades que no lo tienen caso unidades fisicas

     update tblCabUnits set Truck = (select sn from tblTrucks (nolock) where Truckname = replace(UnitID,'.','')), 
	 LinkedObjSN =(select sn from tblTrucks (nolock) where Truckname = replace(UnitID,'.',''))  ,
	 LinkedAddrType = 4 
	 where unitid like '%.'

	 --updte para poner el mobilecomm en unidades que no lo tienen caso unidades virtuales

     update tblCabUnits set Truck = (select sn from tblTrucks (nolock) where Truckname = '.' + replace(UnitID,'.','')),
	 LinkedObjSN =(select sn from tblTrucks (nolock) where Truckname = '.' + replace(UnitID,'.',''))  ,
	 LinkedAddrType = 4 
	 where  unitid like 'P%.'

   --update para poner el camion en el mobilecomm que no lo tiene asignado considera tractos virtuales permisionarios.

   update  tblTrucks set DefaultCabUnit = (select sn from tblCabUnits (nolock) where Unitid = replace(truckname,'.','')+'.') 

   -- crear nuevos dispatch groups si se agregan flotas

   declare @Flota varchar(20)

   DECLARE flotatotm CURSOR FOR 
   (select name from labelfile where labeldefinition = 'Fleet' and retired = 'N'
   and name not in (select Name from tblDispatchGroup))

   OPEN flotatotm  
	FETCH NEXT FROM flotatotm  INTO @flota

	WHILE (@@FETCH_STATUS = 0 )
	
	BEGIN 
	
	 exec tm_CreateDispatchGroup @Flota,'',0,0 
     
	 FETCH NEXT FROM flotatotm   INTO @flota
			
	END

    CLOSE flotatotm
	DEALLOCATE flotatotm 


   -- Borrar dispatch groups de los que ya no exista una flota


   declare @Disgroup varchar(20)

   DECLARE deletedisgroup CURSOR FOR 
   (select Name from tblDispatchGroup where name not in (select name from labelfile where labeldefinition = 'fleet' and (retired = 'N' or retired is null)) and name not in ('!MCROUTER', ' UNKNOWN'))

   OPEN deletedisgroup 
	FETCH NEXT FROM deletedisgroup  INTO @Disgroup

	WHILE (@@FETCH_STATUS = 0 )
	
	BEGIN 
	
	 exec [tm_DeleteDispatchGroup] @Disgroup,0
     
	 FETCH NEXT FROM deletedisgroup  INTO @Disgroup
			
	END

    CLOSE deletedisgroup
	DEALLOCATE deletedisgroup 


  --Update para poner los tractos en el dispatch group con base en la flota TMW

  update tblTrucks set CurrentDispatcher = 
 
   (select SN  from tblDispatchGroup tg where tg.name = 
   (select name
    from labelfile where labeldefinition = 'fleet' and abbr = trc_Fleet) ) 
    from tractorprofile
    inner join tblTrucks on truckname = trc_number
    where  trc_number <> 'UNKNOWN'


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

	 update tblDrivers set CurrentDispatcher =(select SN from tblDispatchGroup tg where tg.name =  'In & Out')
	 where DispSysDriverID in (select mpp_id from manpowerprofile nolock where mpp_status = 'OUT')

	 --poner en grupo INOUT tractos dados de baja trc_Status = 'OUT'

	 update tblTrucks set CurrentDispatcher =(select SN from tblDispatchGroup tg where tg.name =  'In & Out')
	 where Truckname in (select trc_number from tractorprofile nolock where trc_status = 'OUT')

	 --poner en grupo INOUT tractos virtuales de operadores dados de baja trc_Status = 'OUT'

	 update tblTrucks set CurrentDispatcher =(select SN from tblDispatchGroup tg where tg.name =  'In & Out')
	 where Truckname in (select '.'+mpp_id from manpowerprofile nolock where mpp_status = 'OUT' and mpp_id like 'P-%') and Truckname like '.P-%'

	 --poner CABunits de tractos dados de baja trc_Status = 'OUT'

	 update tblCabUnits set CurrentDispatcher =(select SN from tblDispatchGroup tg where tg.name =  'In & Out')
	 where  replace(Unitid,'.','') in (select trc_number from tractorprofile nolock where trc_status = 'OUT')

	 --poner  CABunits de tractos virtuales de operadores dados de baja trc_Status = 'OUT'

	 update tblCabUnits set CurrentDispatcher =(select SN from tblDispatchGroup tg where tg.name =  'In & Out')
	 where  replace(Unitid,'.','') in  (select mpp_id from manpowerprofile nolock where mpp_status = 'OUT' and mpp_id like 'P-%') and UnitID like 'P-%'

     --update para poner el driver correcto en el tractor

	 update tblTrucks set defaultdriver = (select SN from tbldrivers where dispsysdriverid = (select trc_driver from tractorprofile (nolock) where trc_number = dispsystruckid))
	 
	 --update para pone el tracto correcto en el driver

	 update tblDrivers set CurrentTruck = (select SN from tblTrucks where dispsystruckid = (select mpp_tractornumber from manpowerprofile (nolock) where mpp_id = DispSysDriverID))

	 --update asignar un tractor virtual en totalmail para operadores de permisionarios (el tractor ya debe de estar creado en totalmail).

	 update tblDrivers set CurrentTruck = (select sn from tblTrucks (nolock)  where truckname  =  '.' + DispSysDriverID) where DispSysDriverID like 'P-%' and CurrentTruck is null 

	--update asignarle al tractor virtual el operador 

	 update tblTrucks set DefaultDriver = (select sn from tbldrivers (nolock)  where DispSysDriverID =  replace(TruckName,'.','')) where DefaultDriver is null and truckname like '.P-%'

	 --limpiar la libreta de direcciones
     delete tblAddresses where (select name from tblFolders where sn = inbox) is null


   end
GO
