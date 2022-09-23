SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_ReporteUnidades] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WReporteUbiUnidades',
	@WatchName varchar(255)='ReporteUbiUnidades',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected' ,
	@proyecto varchar(40) = ''
    
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

  
 declare @fechaini datetime
 
 
   --set @fechaini = DateAdd(dd,@DaysBack,GetDate())
  -- set @fechafin = GetDate()
     --set @diasumbral = 1

	-- Initialize Temp Table




select trc_number as Unidad,trc_gps_date as Fecha, trc_gps_desc as Direccion, cast(trc_gps_longitude as float(2))/3600 * -1  as Long, cast(trc_gps_latitude as float (2))/3600  as Lat,
Mapa = 
				'https://www.google.com.mx/maps/dir/' +
				CAST((trc_gps_latitude) / 3600.00 AS varchar)  + ',-' +
				CAST((trc_gps_longitude)/ 3600.00 AS varchar) 

into   	#TempResults
from tractorprofile (NOLOCK) where (select name from labelfile where labeldefinition= 'trctype3' and abbr = trc_type3) =  @proyecto
--and trc_number in (select ord_Tractor from orderheader where ord_shipper = 'VLPQUE' and  ord_status = 'STD')





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
