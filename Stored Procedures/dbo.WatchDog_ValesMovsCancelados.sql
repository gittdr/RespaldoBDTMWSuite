SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE Proc [dbo].[WatchDog_ValesMovsCancelados] 
(

	@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogValesmovcancelados',
	@WatchName varchar(255)='ValesElect',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @Modo varchar(20)
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)

--Reserved/Mandatory WatchDog Variables




if @modo = 'Creados'
	BEGIN


---Creamos tabla temporal donde se escribiran los movimientos cancelados con vales que se van a poner en el perro

declare @mostrar table 
(Operador varchar(10), Movimiento Int, Litros Decimal(10,2))


/*  A)   Primero tomamos todos los vales electronicos que no estan dispersados y los marcamos con una Z para que sean considerados
en escribirse en el email del perro
*/
 ------------------------------------------------------------------------------------------------------------------
 insert into @Mostrar
		SELECT  drv_id,mov_number, sum(ftk_liters)
		from fuelticket 
		where mov_number in (select mov_number from orderheader where ord_status = 'CAN' and ord_bookdate > '11-01-2015') and ftk_canceled_on is null
		group by drv_id, mov_number
		UNION
		SELECT  drv_id,mov_number, sum(ftk_liters)
		from fuelticket 
		where mov_number in (select mov_number from legheader where lgh_outstatus = 'CAN' and lgh_startdate > '11-01-2015')	and ftk_canceled_on is null
		group by drv_id, mov_number
		order by 2

		/*LOS PASA A LA TABLA #TempResults*/
		select 
		Operador,    
		Movimiento,
		Litros
		into #TempResults
		 from 
		@Mostrar


---RENDER DE DATOS PARA EL REPORTE-----------------------------------------------------------------------------------------------------------------------------------------------


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



	END

GO
