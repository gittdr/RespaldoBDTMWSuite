SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_EXPTDDE] 
(

	@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogEXPTDDE',
	@WatchName varchar(255)='EXPTDDE',
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


   declare @fechaini datetime
   declare  @fechafin datetime
 
   set @fechaini = DateAdd(dd,@DaysBack,GetDate())
   set @fechafin = GetDate()


	-- Initialize Temp Table
	
select 
exp_id as IDOperador,
(select mpp_firstname + ' ' + mpp_lastname from manpowerprofile where mpp_id = exp_id) as Nombre,
exp_code as Tipo,
exp_expirationdate as Inicio,
exp_lastdate as Fin,
exp_Description as Descripcion,
(select usr_fname + ' ' + usr_lname from ttsusers where  usr_userid =  exp_updateby) as ModificadaPor
 into   	#TempResults
from expiration
where exp_code in ('VAC','DES','LIC','EXMED','LEG','SIC''FALTA','CAPA')
and datediff(day,getdate(),exp_expirationdate) = 0 






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
