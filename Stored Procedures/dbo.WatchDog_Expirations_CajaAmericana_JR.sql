SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_Expirations_CajaAmericana_JR] 
(

    @Umbralasignacion float = 10,
	@TempTableName varchar(255)='##WatchDogExpirationsCajaAmericanaJR',
	@WatchName varchar(255)='Expira',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
    @FiltroNombre varchar(50) = '',
	@ColumnMode varchar (50) ='Selected'
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables





	-- Initialize Temp Table
	

 
create table #ExpCajasAmericanas (caja varchar(20) ,estatus varchar(20), fechavencimiento datetime, descripcion varchar(100) ,dias int)


Begin
Insert into #ExpCajasAmericanas
select trl_id, (select name from labelfile where labeldefinition = 'TrlStatus'  and abbr = trl_status), exp_expirationdate, exp_description,
DATEDIFF(day,  exp_expirationdate, GETDATE()) AS Dias
from expiration, trailerprofile  
where exp_code = 'FIAN' and exp_completed ='N' and  trl_id = exp_id 
and (DATEDIFF(day,  exp_expirationdate, GETDATE())) > -5 order by 5 desc



          
--mostramos el resultado final de la tabla #todisplay

			select * 
			into 
			#TempResultsa
			from #ExpCajasAmericanas  order by 5

	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResultsa'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResultsa'
	End

	Exec (@SQL)
	Set NoCount Off


	

 end

GO
