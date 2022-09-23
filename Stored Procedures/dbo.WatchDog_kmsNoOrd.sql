SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_kmsNoOrd] 
(

    @Umbralasignacion float = 1,
	@TempTableName varchar(255)='##KmsNoOrd',
	@WatchName varchar(255)='KmsNoOrd',
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

	    select 
		economico,
		(select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile where trc_number = economico) as Flota,
		round(Distancia_Recorrida,0) as Distancia_Recorrida,
		fecha_final as UltOdometro
		--,(select * from tractoraccesories where tca_tractor = '1477') 
		into   	#TempResults
		from fuel.dbo.intralix_getperformance1day
		where datediff(dd,fecha_final,getdate()) = 1
		and (select count(*) from legheader l where l.lgh_tractor = economico and datediff(day,lgh_startdate,getdate()) =1)  = 0 
		order by cast(distancia_recorrida  as float) desc



	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults order by flota desc, distancia_recorrida desc'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults order by flota desc, distancia_recorrida desc'
	End

	Exec (@SQL)
	Set NoCount Off







GO
