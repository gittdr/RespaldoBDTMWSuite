SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_MasdeDosOrdenes] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogMasdeDosOrdenes',
	@WatchName varchar(255)='MasdeDosOrdenes',
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

  
   --declare @fechaini datetime
   --declare  @fechafin datetime
 
   --set @fechaini = DateAdd(dd,@DaysBack,GetDate())
  -- set @fechafin = GetDate()
     --set @diasumbral = 1

	-- Initialize Temp Table
	

--select Operador, ordenes 
--into   	#TempResults
--from 
--(select ord_Driver1 as Operador, count(*) as ordenes  from orderheader 
--        where ord_status in('PLN','AVL','STD','DSP') and ord_revtype3= 'BAJ'
--group by ord_driver1
--) as operadores
--where ordenes >= 2
--order by ordenes desc

select Operador, ordenes 
into   	#TempResults
from 
(select lgh_driver1 as Operador, count(*) as ordenes  from legheader 
        where lgh_outstatus in('PLN','AVL','STD','DSP') and lgh_class3= 'BAJ'
group by lgh_driver1
) as operadores
where ordenes >= 2
order by ordenes desc



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
