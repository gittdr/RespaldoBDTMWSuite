SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_ExpiraDrivers] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogExpiraDrivers',
	@WatchName varchar(255)='ExpiraDrivers',
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

(select mpp_type3 from manpowerprofile (nolock) where mpp_id = exp_id) as Proyecto,
exp_id as Operador,
(select name from labelfile (nolock) where labeldefinition = 'DrvExp' and abbr = exp_code) as Motivo,
exp_expirationdate as ExpDate,
exp_compldate as EndDate,
datediff(dd, exp_expirationdate, exp_compldate) as dias
into #TempResults
from expiration (nolock)
where exp_idtype = 'DRV'
and exp_completed = 'Y'
and exp_compldate between dateadd(dd,-7,getdate())  and getdate()
order by  datediff(dd, exp_expirationdate, exp_compldate) desc



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
