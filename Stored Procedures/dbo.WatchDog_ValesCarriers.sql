SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_ValesCarriers] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogValesCarriers',
	@WatchName varchar(255)='ValesCarriers',
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

  
	-- Initialize Temp Table
	

select drv_id, mov_number,trc_id,sum(ftk_liters) as litros
into   	#TempResults
from fuelticket 
where lgh_number in (select lgh_number from paydetail PD where  lgh_number in (select lgh_number from legheader where  lgh_carrier <> 'UNKNOWN' and lgh_startdate > '2018-04-13' and mov_number >0 and lgh_driver1 = 'UNKNOWN')
and asgn_id = 'PROVEEDO' and pyd_quantity > 0 and pyt_itemcode = 'VALEEL') 
group by drv_id, mov_number,lgh_number, trc_id
order by 2
 
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
