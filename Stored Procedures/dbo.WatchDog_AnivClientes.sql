SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_AnivClientes] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogAnivClientes',
	@WatchName varchar(255)='Anivclientes',
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
	

select
cmp_name,
cmp_address1,
cmp_address2,
cty_nmstct,
cmp_zip,
cmp_contact,
cmp_createdate,
antiguedad = datediff(yy,cmp_createdate,getdate())
 into   	#TempResults
from  company
where cmp_billto = 'Y'
and cmp_active = 'Y'
and month(cmp_createdate) = month(getdate())
and datediff(yy,cmp_createdate,getdate()) > 1
order by datediff(yy,cmp_createdate,getdate()) desc


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
