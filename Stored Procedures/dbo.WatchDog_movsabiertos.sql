SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_movsabiertos] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##MovsAbiertos',
	@WatchName varchar(255)='MovsAbiertos',
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
	

select mov_number as movimiento, ord_hdrnumber as orden,  ord_tractor as tractor, 
ord_driver1 as driver, ord_startdate as fecha, ord_status as  ordstatus 
 into   	#TempResults
from orderheader where ord_status in ('AVL','PLN','DSP','STD')
and ord_tractor <> 'UNKNOWN' and ord_driver1 <> 'UNKNOWN'
order by ord_hdrnumber  


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
