SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--  drop table ##WatchDogValesDieselSodexo
--  drop table #TempResultsdos
--   exec WatchDog_ValesDieselSodexo

CREATE Proc [dbo].[WatchDog_ValesDieselSodexo] 
(

	@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogValesDieselSodexo',
	@WatchName varchar(255)='ValesElect',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected'
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)

--Reserved/Mandatory WatchDog Variables

BEGIN


---Creamos tabla temporal donde se escribiran los vales que se van a poner en el perro
declare @mostrar table 
(Unidad varchar(15), movimiento varchar(200), Vales varchar(200), Costo Decimal(10,0), Tarjeta varchar(100), importe Decimal(10,2))
 ------------------------------------------------------------------------------------------------------------------




/*  A)   Primero tomamos todos los vales electronicos que no estan dispersados y los marcamos con una Z para que sean considerados
en escribirse en el email del perro
*/
 ------------------------------------------------------------------------------------------------------------------

	Update fuelticket 
		 set ftk_disper_by = 'SA', ftk_disper_on = cast(getdate() as datetime), ftk_disper = 'Z'
		where ftk_printed_by = 'VELEC' 
		and isnull(ftk_disper,'N') = 'N' 
		and ftk_canceled_on is null
		and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id)

	


/*B)     Insertamos en la tabla @mostrar que es la que contiene lo que se va a escribir en el email del perro
tomaremos solo los registros que se marcaron en el paso anterior con Z para ser escritos.
*/
-------------------------------------------------------------------------------------------------------------------------------

insert into @Mostrar

	 select 
            trc_id	as Unidad,
            ''		as movimientos,
            ''		as Vales,
		    (select tca_cost	from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id)  as 'Cuenta',
			'=concatenar(' + substring((select tca_id from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id),0,11)+','+ substring((select tca_id from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id),11,18)  + ')' as 'NumeroTarjeta',
			CONVERT(DECIMAL(10,2),
			(
			------------------------------------PRECIO DEL DIESEL POR PROYECTO DEL TRACTO--------------------------------------------------------------------------------------------------------------
			(select precio from precio_diesel_proyecto (nolock) where id_proyecto =  isnull((select trc_type3 from tractorprofile (nolock) where tractorprofile.trc_number = fuelticket.trc_id),'UNK')) 
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
			 * sum(ftk_liters)))  as Importe
          from fuelticket (nolock)
		where 
		ftk_printed_by = 'VELEC' 
		and ftk_disper = 'Z'  
		and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		and ftk_canceled_on is null 
	   and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id)
	   group by trc_id


--agregamos la informacion extra de la lista de los movimientos--------------------------------
update @Mostrar set movimiento = 'M ' + STUFF((select distinct top (6) ' ' + cast(mov_number as varchar) from fuelticket 
                                            where unidad  = trc_id  and ftk_printed_by = 'VELEC' 
                                            and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		                                     and ftk_canceled_on is null
											 and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id)
                                    FOR XML PATH('') ), 1, 1, '')


---agregamos la inforomacion extra de la lista los vales--------------------------------------------
update @Mostrar set Vales = 'Vs ' +  STUFF((select top (6) ' ' + cast(ftk_ticket_number as varchar) from fuelticket 
                                            where unidad  = trc_id  and ftk_printed_by = 'VELEC' 
                                            and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		                                     and ftk_canceled_on is null 
											 and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id)
                                    FOR XML PATH('') ), 1, 1, '')




-----SELECT FINAL YA PROCESADO----------------------------------------------------------------------------------------------------------------------------------------------------------
-- se escribe ahora si ya formalmente en la salida para el perro


select 
Unidad As '*No de Empleado',
left(Movimiento,50)	as Nombre,
left(Vales,50)		as 'Apellido Paterno',
'.'			as 'Apellido Materno',
costo		as Cuenta,
left(Tarjeta,30)		as Tarjeta,
importe     as Importe
into #TempResults
 from 
@Mostrar



/* solo para pruebas

   drop table #TempResults
   select * from #TempResults


*/

  /***************************************************************************************************************************************************************************************************************************
																							--- ENVIO DIRECTO A NAVMAN  NWNEVIAMENSAJE---
  ****************************************************************************************************************************************************************************************************************************/	
  --'Prox.Dep.Sodexo: $'+  cast(CONVERT(DECIMAL(10,2),(((((sum(ftk_cost)/sum(ftk_liters))-0.2988)*1.16)+0.2988) * sum(ftk_liters))) as varchar)  + ' por: ' +   cast(sum(ftk_liters) as varchar) + ' Lts'


			 -- inserta el mensaje si la unidad tiene el tipo de mensajeria 
	 --   insert into QSP.dbo.NWEnviaMensajes (cuenta,unidad,mensaje,fechainsersion) 
  --  (select 
		
  --          5,
  --          trc_id,
  --          'Prox.Dep.Sodexo: '+  ' por: ' +   cast(sum(ftk_liters) as varchar) + ' Lts'
  --          + ' Mov: ' + cast(mov_number as varchar) + ', saldo expira: '+
  --          replace(CONVERT(VARCHAR(10), dateadd(dd,8,max(ftk_created_on)), 105),'-','/'),
  --          getdate()
  --        from fuelticket
	 
		--where 
		--ftk_printed_by = 'VELEC'  
		--and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		--and ftk_canceled_on is null
		--and isnull(ftk_disper,'N') = 'Z' 
		--and trc_id in (select displayname from QSP.dbo.NWVehicles)
		--and trc_id = (select tca_tractor from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id)
	 --  group by trc_id, mov_number )

	
/***************************************************************************************************************************************************************************************************************************
																							--- TOTAL MAIL ---
  ****************************************************************************************************************************************************************************************************************************/

  --insertamos el mensaje en la tabla tblmessage

       insert into tmwsuite.dbo.tblmessages (Type	,Status	,Priority	,FromType	,DeliverToType	,DTSent	,DTReceived	,DTRead	,DTAcknowledged	,DTTransferred	,Folder	,Contents	,FromName	,
       Subject	,DeliverTo	,HistDrv	,HistDrv2	,HistTrk	,OrigMsgSN	,Receipt	,DeliveryKey	,Position	,PositionZip	,NLCPosition	,NLCPositionZip	,VehicleIgnition	,
       Latitude	,Longitude	,DTPosition	,SpecialMsgSN	,ResubmitOf	,Odometer	,ReplyMsgSN	,ReplyMsgPage	,ReplyFormID	,ReplyPriority	,ToDrvSN	,ToTrcSN	,FromDrvSN	,
       FromTrcSN	,MaxDelayMins	,BaseSN	,McuId	,Export)

	   select 
		[type] = 1,
		[status] = 4,
		[priority] = 2,
		Fromtype = 1,
		delivertotype = 1,
		dtsent = getdate(),
		dtreceived = NULL,
		DTread = NULL,
		DTAcknowledge = NULL,
		DTTransfer = NULL,
		----------------------------------------------------------------------MANDAMOS EL MENSAJE AL FOLDER SENT  -------DEL ADMINISTRADOR------------------------------------------------------------------------------------------------
		Folder =362,
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--Contents =     ('Prox.Dep.Sodexo: $'+  cast(CONVERT(DECIMAL(10,2),(((((sum(ftk_cost)/sum(ftk_liters))-0.2988)*1.16)+0.2988) * sum(ftk_liters))) as varchar)  + ' por: ' +   cast(sum(ftk_liters) as varchar) + ' Lts'
		Contents =     ('Prox.Dep.Sodexo por: ' +   cast(sum(ftk_liters) as varchar) + ' Lts'
        + ' Mov: ' + cast(mov_number as varchar) + ', saldo expira: '+ replace(CONVERT(VARCHAR(10), dateadd(dd,8,max(ftk_created_on)), 105),'-','/')),
		Fromname = 'Admin',
		[Subject] =    ('Prox.Dep.Sodexo por: ' +   cast(sum(ftk_liters) as varchar) + ' Lts'
        + ' Mov: ' + cast(mov_number as varchar) + ', saldo expira: '+ replace(CONVERT(VARCHAR(10), dateadd(dd,8,max(ftk_created_on)), 105),'-','/')),
		DeliverTo = trc_id,
		HistDrv = NULL,
		HistDrv2 = NULL,
		HistTrk = NULL,
		OrigMsgSN =NULL,
		Receipt = 2,
		DeliveryKey = 2,
		Position = 0,
		PositionZip = NULL,
		NLCPosition = NULL,
		NLCPositionZip = 'A2NP',
		VehicleIgnition = NULL,
		Latitude = NULL,
		Longitude = NULL,
		DTPosition = NULL,
		SpecialMsgSN = NULL,
		ResubmitOf = NULL,
		Odometer = NULL,
		ReplyMsgSN = NULL,
		ReplyMsgnPage = NULL,
		ReplyFormID = 0,
		ReplyPriority = NULL,
		ToDrvSN = (select sn from tblDrivers nolock where DispSysDriverID = (select trc_Driver from tractorprofile nolock where trc_number = trc_id)),
		ToTrcSN = (select sn from tblTrucks nolock where DispSysTruckID = trc_id),
		FromDrvSN = NULL,
		FromTrcSN = NULL,
		MaxDelayMins = NULL,
		BaseSN = 9,
		Mculd = NULL,
		Export = NULL
		from fuelticket (nolock)
		where 
		ftk_printed_by = 'VELEC'  
		and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		and ftk_canceled_on is null
		and isnull(ftk_disper,'N') = 'Z' 
		and trc_id = (select tca_tractor from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id)
	   group by trc_id, mov_number 

--and trc_id in (select displayname from QSP.dbo.NWVehicles)
 --insertamos el mensajes en la tabla message to

         insert into tmwsuite.dbo.tblTo (Message, ToName, ToType, isCC)

		(select 
		sn,
		toname = DeliverTo,
		totype = 4 ,  --- 3 es para grupos
		0
		from tmwsuite.dbo.tblMessages (nolock)
		where NLCPositionZip = 'A2NP' ) 

   
      -----------insert en la tabla de history en el modo truck para la consulta ------------------------------------------------------------------------------------------------------------------

      insert into tmwsuite.dbo.tblHistory  (DriverSN,TruckSN,MsgSN,chached)

      (select NULL, (select sn from tmwsuite..tbltrucks (nolock) where truckname = DeliverTo), sn, 0
       from tmwsuite.dbo.tblMessages (nolock)
       where NLCPositionZip = 'A2NP' ) 

 
 --cambiamos la bandera de envio navmana a 88 para indicar que ya fue procesado (88 = admin a tractor navman procesado)--------------------------------------------------------------------
  update tmwsuite.dbo.tblMessages set NLCPositionZip = 'A2NE' where NLCPositionZip = 'A2NP'


  /*****************************************************************************************************************************************************************************************************************/

  

---D)           INSERTAR EN TABLA DE AUDITORIA FUELTICKETELECT-------------------------------------------------------------------------------------------------------------------------------------
	

	/*** Insertamos el registro de lo que se mando en el perro 
	     en la tabla de auditoria Fuelticket elect solo se inserta lo que se marco con Z previamente.
	***/
	
		
	 insert into fuelticketelect
		 select 
		   isnull((select tca_id from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id),'NA') as numtarjeta ,
		   trc_id as Tractor,
		   ftk_liters as Litros,
		   CONVERT(DECIMAL(10,2),(((((ftk_cost/ftk_liters)-0.2988)*1.16)+0.2988) * ftk_liters))  as Costo,
			mov_number as Movimiento,
			ftk_ticket_number as NumVale,
			ftk_created_by as CreadoPor,
			ftk_created_on as FechaCreacion,
			drv_id as Operador,
			ord_hdrnumber as Orden,
            'Carga',
           getdate(),
		   NULL,
		   'SODEX'
		from fuelticket
		where 
		ftk_printed_by = 'VELEC' 
		and ftk_canceled_on is null
		and ftk_disper = 'Z' 
		and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id)


		--Como paso final se marca la tabla de fuelticket con una Y para afirmar que ya se disperso el vale.


		Update fuelticket 
		 set ftk_disper = 'Y'
		where ftk_printed_by = 'VELEC' 
		and ftk_disper = 'Z' 
		and ftk_canceled_on is null
		and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TSO' and tca_tractor = trc_id)
  
---RENDER DE DATOS PARA EL REPORTE-----------------------------------------------------------------------------------------------------------------------------------------------


	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
		Begin
			Set @SQL = 'Select * from #TempResults'
		End
	Else
		Begin
			Set @COLSQL = ''
			Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
			Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'

		End

	Exec (@SQL)
	Set NoCount Off

			--Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'

	END









GO
