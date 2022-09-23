SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_WSCargasDIESEL] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDog_WSCargasDIESEL',
	@WatchName varchar(255)='WatchDog_WSCargasDIESEL',
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

  


--select fp_enteredby, sum(fp_quantity) as litros

--into   	#TempResults
--from fuelpurchased
--where datediff(day, fp_date,getdate()) = 1
--group by fp_enteredby


select fp_vendorname as Proveedor,fp_cac_id, sum(fp_quantity) as litros, cast(fp_date as date) fechaCarga

into   	#TempResults
from fuelpurchased
where datediff(day, fp_date,getdate()) = 2
group by fp_vendorname, fp_cac_id,cast(fp_date as date)

--select cmp_id, cmp_longseconds, cmp_latseconds from company where cmp_ID = 'BRACOA'
--select * from qsp..navman_ic_api_site where DisplayName = 'BRACOA'

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
