SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  Proc [dbo].[WatchDog_OrdenesNoComp] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogOrdenesNoComp',
	@WatchName varchar(255)='OrdenesNoComp',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',  
    @diasumbral int = 0 
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

  
   --declare @fechaini datetime
   --declare  @fechafin datetime
 
   --set @fechaini = DateAdd(dd,@DaysBack,GetDate())
  -- set @fechafin = GetDate()
     --set @diasumbral = 1

	-- Initialize Temp Table
	

 --desplegamos la consulta    


select ord_billto as Cliente, ord_revtype3 as Proyecto, ord_tractor as Tractor,ord_driver1 as Operador, ord_hdrnumber as Orden, ord_status as Estatus, ord_bookdate as FechaCreada, ord_startdate as FechaInicio, ord_completiondate as FechaTermino
 into   	#TempResults
from orderheader 
where ord_status not in ('CMP','CAN','MST','ICO','QTE')
and ord_completiondate < GETDATE()
and ord_billto not in ('SAE','TDRQUERE')
order by ord_billto, ord_completiondate


	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults order by Cliente asc, FechaTermino asc'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults order by Cliente asc, FechaTermino asc'
	End

	Exec (@SQL)
	Set NoCount Off







GO
