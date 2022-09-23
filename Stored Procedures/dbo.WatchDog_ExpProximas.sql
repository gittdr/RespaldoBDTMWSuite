SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_ExpProximas] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WExpProximas',
	@WatchName varchar(255)='ExpProximas',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected' ,
	@Proyecto varchar(40) = ''
    
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

  
   --set @fechaini = DateAdd(dd,@DaysBack,GetDate())
  -- set @fechafin = GetDate()
     --set @diasumbral = 1

	-- Initialize Temp Table



if @proyecto = 'TODOS'
begin
   SELECT
	(select name from labelfile where labeldefinition = 'DrvType3' and abbr = (select mpp_type3 from manpowerprofile where mpp_id = exp_id)) as proyecto,
	exp_id as driverid,
	((select mpp_firstname + ' ' + mpp_lastname from manpowerprofile where mpp_id = exp_id)) as operador,
	exp_code,
	exp_Description,
	exp_expirationdate,
	exp_lastdate
	into   	#TempResults
	from expiration 
	where exp_idtype  = 'DRV' and exp_completed = 'N'
	and exp_code in ('LIC','TRAM','EXMED')
	and (datediff(mm,exp_expirationdate,getdate()) = 0 or datediff(mm,exp_expirationdate,getdate()) = -1)
	order by proyecto

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





end



else

 begin


select

	(select name from labelfile where labeldefinition = 'DrvType3' and abbr = (select mpp_type3 from manpowerprofile where mpp_id = exp_id)) as proyecto,
	exp_id as driverid,
	((select mpp_firstname + ' ' + mpp_lastname from manpowerprofile where mpp_id = exp_id)) as operador,
	exp_code,
	exp_Description,
	exp_expirationdate,
	exp_lastdate
	into   	#TempResults2
	from expiration 
	where exp_idtype  = 'DRV' and exp_completed = 'N'
	and exp_code in ('LIC','TRAM','EXMED')
	and (datediff(mm,exp_expirationdate,getdate())  = 0 or datediff(mm,exp_expirationdate,getdate())  = -1)
	and  (select mpp_type3 from manpowerprofile where mpp_id = exp_id) = @proyecto
	order by proyecto


	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults2'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults2'
	End

	Exec (@SQL)
	Set NoCount Off




end



	




GO
