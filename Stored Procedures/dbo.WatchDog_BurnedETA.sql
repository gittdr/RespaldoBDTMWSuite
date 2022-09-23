SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE Proc [dbo].[WatchDog_BurnedETA] 
(

    @Umbralasignacion float = 1,
	@TempTableName varchar(255)='##BurnedETA',
	@WatchName varchar(255)='BurnedETA',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @billto varchar(500)

)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables


	-- Initialize Temp Table



			select 

				Cliente = CP.ord_billto,
				OrdenTMW = CP.ord_hdrnumber,
				ProyectoOrden = CP.ord_revtype3_name,
				Viaje  =  CP.ord_refnum,
				Unidad = CP.tractor ,
				Sitio=  isnull(CP.ProxDestino,'Fin'),
				Evento = isnull((CP.proxevento),'Fin'), --  isnull((Select name from eventcodetable (nolock) where abbr = CP.proxevento),'Fin'),
				Cita =  cast(day(CP.proxcita) as varchar(20)) +'/'+ cast( month(cp.proxcita) as varchar(20)) + ' ' + cast(datepart(hour,cp.proxcita) as varchar(20)) +':'+
				case when len((cast(datepart(MINUTE,CP.proxcita) as varchar(20)))) = 1 then '0'+ cast(datepart(MINUTE,CP.proxcita) as varchar(20)) else cast(datepart(MINUTE,CP.proxcita) as varchar(20))  end,
				Retraso = cast(Cp.Etadif  as varchar(10))+ ' Hr(s)',
				PorRecorrer = CP.Elogist,cp.ord_revtype4,
				
				--PosicionActual = CP.trc_gps_desc ,
				Mapa = '<a href="' + 	'https://www.google.com/maps/?q=' +
				CAST((trc_gps_latitude) AS varchar)  + ',-' +
				CAST((trc_gps_longitude)AS varchar)  +'">Mapa ubicacion </a>' ,

				EventoActual = case 
									when ltrim(rtrim(estatusicon))  = 'Drvng' then 'En transito'
									when ltrim(rtrim(estatusicon))  = 'PLN'  then 'Por iniciar '
									else (select name from eventcodetable where abbr = estatusicon) end
				into   	#TempResults
				from TMWScrollOrderView_TDRCP CP
				 where
				 CP.ord_billto in ('NIAGARA','HOMEDEP','CUERVO','INOVADOR','CARMEX02','CENZAC','PALACIO',
				 'PEÑAFIEL','VERDEVALL','CONDUCMT') and cp.ord_revtype4 = 'SEN'
				 and Cp.etadif > 1
				 and CP.ProxEvento not in ('DMT','EMT')
				 order by cita 



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







GO
