SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[WatchDog_NoODOINTRALIX] 
(

    @Umbralasignacion float = 1,
	@TempTableName varchar(255)='##NOODOINTRALIX',
	@WatchName varchar(255)='NOODOINTRALIX',
	@ThresholdFieldName varchar(255) = '',
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



	     select * 
		into   	#TempResults
		 from (
			select 
			(select unitnumber from [172.24.16.113].TMWAMS.dbo.units where units.UNITID = UNITMTR.UNITID) as Unidad,
			THISRDING as UltimoOdometro,
			THISRDDAY as Fecha,
			datediff(day,thisrdday,getdate()) as DiasSinReportar
			from [172.24.16.113].TMWAMS.dbo.UNITMTR where METERDEFID = 35
			and (select unitnumber from [172.24.16.113].TMWAMS.dbo.units where units.UNITID = UNITMTR.UNITID) 
			in (select trc_number from tractorprofile where trc_status <>'Out')
		 ) as q
			where DiasSinReportar >= 5
			order by DiasSinReportar desc







	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults order by 4 desc'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults order by 4 '
	End

	Exec (@SQL)
	Set NoCount Off







GO
