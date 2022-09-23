SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_Accesorialelevado] 
(

	@TempTableName varchar(255)='##WatchDog_accesorialelevado',
	@WatchName varchar(255)='AccesorialElevado',
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
	


CREATE TABLE #AccesorialElevado(
		Orden	VARCHAR(15),
		Cargo	float,
		TipoCargo		VARCHAR(20),
        Fecha  datetime
        )


   INSERT INTO #AccesorialElevado


    select 
    ord_hdrnumber as Orden,
    ivd_charge as Cargo,
    cht_itemcode as TipoCargo,
    last_updatedate as Fecha
    from invoicedetail
    where cht_itemcode in ('GST','PST')
    and cur_code = 'US'
    and ivd_charge > 100000
    and ord_hdrnumber not in (select ord_hdrnumber from invoiceheader)





 --desplegamos la consulta    
 select *
 into   	#TempResults
 from #AccesorialElevado
order by Fecha DESC


--eliminamos el accesorial elevado.
update invoicedetail set ivd_CHARGE = null
where cht_itemcode in ('GST','PST')
    and cur_code = 'US'
    and ivd_charge > 100000
    and ord_hdrnumber not in (select ord_hdrnumber from invoiceheader)







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
