SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--  drop table ##WatchDogValesDieselPerc
--  drop table #TempResultsdos
--   exec WatchDog_ValesDieselPerc

CREATE Proc [dbo].[WatchDog_ValesDieselPerc] 
(

	@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogValesDieselPerc',
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



declare @mostrarperc table 
(Unidad varchar(15), movimiento varchar(20), Vales varchar(200), Tarjeta varchar(100), importe Decimal(6,2))


 ------------------------------------------------------------------------------------------------------------------
 BEGIN


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
		and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TPE' and tca_tractor = trc_id)




/*B)     Insertamos en la tabla @mostrar que es la que contiene lo que se va a escribir en el email del perro
         tomaremos solo los registros que se marcaron en el paso anterior con Z para ser escritos.*/
---------------------------------------------------------------------------------------------------------------------


insert into @mostrarperc

	 select 
            (select trc_number from tractorprofile where trc_number = trc_id)	as Unidad,
            ''		as movimientos,
            ''		as Vales,
		    (select tca_id		from tractoraccesories where tca_type = 'TPE' and tca_tractor = trc_id)	 as 'NumeroTarjeta',
			CONVERT(DECIMAL(9,2),(sum(ftk_liters)))  as Importelitros
          from fuelticket
		where 
		ftk_printed_by = 'VELEC'  
		and isnull(ftk_disper,'N') = 'Z' 
		and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		and ftk_canceled_on is null 
		and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TPE' and tca_tractor = trc_id)
	   group by trc_id


update @mostrarperc set movimiento = 'M- ' + STUFF((select distinct ' ' + cast(mov_number as varchar) from fuelticket 
                                            where unidad  = trc_id  and ftk_printed_by = 'VELEC' 
                                            and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		                                     and ftk_canceled_on is null
											 and isnull(ftk_disper,'N') = 'Z' 
											 and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TPE' and tca_tractor = trc_id)
                                    FOR XML PATH('') ), 1, 1, '')



	update @mostrarperc set Vales = 'V- ' +  STUFF((select top (6) ' ' + cast(ftk_ticket_number as varchar) from fuelticket 
                                            where unidad  = trc_id  and ftk_printed_by = 'VELEC' 
                                            and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		                                     and ftk_canceled_on is null 
											 and isnull(ftk_disper,'N') = 'Z' 
											 and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TPE' and tca_tractor = trc_id)
                                    FOR XML PATH('') ), 1, 1, '')




-----SELECT FINAL YA PROCESADO----------------------------------------------------------------------------------------------------------------------------------------------------------

select 
Right('0000000000000'+unidad,12)  + ' 1 1 1 1 1 1 1 00:00:00 23:59:00 '+Right('000000000'+ cast( importe as varchar(20)),9)+' 0 0 0 0 0 0 0 0 '+ '0 0 103 0 0'   as CadenaPerc, movimiento, vales
into #TempResults
 from 
@mostrarperc

/*
---INSERTAR EN ENVIA MENSAJES QFS PARA QUE LO RECIBA LA UNIDAD AVISO DE DEPOSITO PROXIMO-------------------------------------------------------------------------------------------------

   insert into QSP.dbo.EnviaMensajes (cuenta,unidad,mensaje,fechainsersion) 
    (select 
		
            5,
            trc_id,
            'Prox.Dep.Perc: $'+  cast(CONVERT(DECIMAL(10,2),( 14.20 * sum(ftk_liters)))   as varchar)  + ' por: ' +   cast(sum(ftk_liters) as varchar) + ' Lts'
            + ' Mov: ' + cast(mov_number as varchar) + ', saldo expira: '+
            replace(CONVERT(VARCHAR(10), dateadd(dd,8,max(ftk_created_on)), 105),'-','/'),
            getdate()
	 from fuelticket
	 Where 
			ftk_printed_by = 'VELEC'  
			and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
			and ftk_canceled_on is null
			and isnull(ftk_disper,'N') = 'N' 
			and trc_id in (select displayname from QSP.dbo.QFSVehicles)
			and trc_id = (select tca_tractor from tractoraccesories where tca_type = 'TPE' and tca_tractor = trc_id)
		   group by trc_id, mov_number )

			 -- inserta el mensaje si la unidad tiene el tipo de mensajeria 
	    insert into QSP.dbo.NWEnviaMensajes (cuenta,unidad,mensaje,fechainsersion) 
    (select 
		
            5,
            trc_id,
            'Prox. Dep.Perc: $'+  cast(CONVERT(DECIMAL(10,2),(((((sum(ftk_cost)/sum(ftk_liters))-0.2988)*1.16)+0.2988) * sum(ftk_liters))) as varchar)  + ' por: ' +   cast(sum(ftk_liters) as varchar) + ' Lts'
            + ' Mov: ' + cast(mov_number as varchar) + ', saldo expira: '+
            replace(CONVERT(VARCHAR(10), dateadd(dd,8,max(ftk_created_on)), 105),'-','/'),
            getdate()
          from fuelticket
	 
		where 
		ftk_printed_by = 'VELEC'  
		and isnull(ftk_disper,'N') = 'N' 
		and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		and ftk_canceled_on is null
		and trc_id in (select displayname from QSP.dbo.NWVehicles)
		and trc_id = (select tca_tractor from tractoraccesories where tca_type = 'TPE' and tca_tractor = trc_id)
	   group by trc_id, mov_number )
*/
	   

---INSERTAR EN TABLA DE AUDITORIA FUELTICKETELECT-------------------------------------------------------------------------------------------------------------------------------------
	-- Marca los vales como ya dispersos 
	
	 Update fuelticket 
		 set ftk_disper_by = 'SA', ftk_disper_on = cast(getdate() as datetime), ftk_disper = 'Y'
		where ftk_printed_by = 'VELEC' 
		and ftk_canceled_on is null
		and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TPE' and tca_tractor = trc_id)

		select * from fuelticketelect
	  insert into fuelticketelect
		 select 
		   isnull((select tca_id from tractoraccesories where tca_type = 'TPE' and tca_tractor = trc_id),'NA') as numtarjeta ,
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
		   'PERC'
		from fuelticket
		where 
		ftk_printed_by = 'VELEC' 
		and isnull(ftk_disper,'N') = 'N' 
		and ftk_canceled_on is null
		and ftk_ticket_number  not in (select numVale from fuelticketelect where numvale is not null)
		and trc_id = (select tca_tractor		from tractoraccesories where tca_type = 'TPE' and tca_tractor = trc_id)
		
  
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



	--END



	    
---RENDER DE DATOS PARA EL REPORTE-----------------------------------------------------------------------------------------------------------------------------------------------


	----Commits the results to be used in the wrapper
	--If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	--Begin
	--	Set @SQL = 'Select * from #TempResultsdos'
	--End
	--Else
	--Begin
	--	Set @COLSQL = ''
	--	Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	--	Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResultsdos'
	--End

	--Exec (@SQL)
	Set NoCount Off

	END









GO
