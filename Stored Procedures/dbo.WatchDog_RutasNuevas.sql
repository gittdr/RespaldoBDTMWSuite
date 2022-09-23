SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_RutasNuevas] 
(

    @Umbralasignacion float = 10,
	@TempTableName varchar(255)='##WatchDogRutasNuevas',
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

           
--mostramos el resultado final de la tabla #todisplay


		select 

		case when mt_origintype = 'C' then (select cty_nmstct from city where cty_code = mt_origin) else mt_origin end as Origen,
		case when mt_destinationtype = 'C' then (select cty_nmstct from city where cty_code = mt_destination) else mt_destination end as Destino,
		mt_updatedby as ModificadaPor,
		mt_miles as KMS,
		mt_hours as Horas,
		mt_tolls_cost as Casetas
		into	#TempResultsa
		from mileagetable where mt_Type = 3
		and datediff(day,getdate(),mt_updatedon) between  0 and 2


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




GO
