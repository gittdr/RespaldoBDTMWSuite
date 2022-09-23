SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OrdenesSinReferencia] 
(

	@TempTableName varchar(255)='##WatchDog_accesorialelevado',
	@WatchName varchar(255)='AccesorialElevado',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @cliente varchar(20)
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables



	-- Initialize Temp Table
	



select 
Orden = ord_number,
Origen = ord_originpoint,
Destino = ord_destpoint,
FechaInicio = ord_startdate, 
FechaFin = ord_completiondate 
 into   	#TempResults
 from orderheader 
where ord_billto = @cliente
and ord_status = 'STD'
and (ord_refnum is null or ord_refnum = '')



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
