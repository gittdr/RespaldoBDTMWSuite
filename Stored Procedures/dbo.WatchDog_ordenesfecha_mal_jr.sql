SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE Proc [dbo].[WatchDog_ordenesfecha_mal_jr] 
(

	@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogOrdenesfechaMal',
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
(billto  varchar(10), orden Int, fechabook datetime)


/*  A)  Busca si existe una orden dado de alta con fecha del 01-01-2019
*/
 ------------------------------------------------------------------------------------------------------------------
 insert into @Mostrar
 select ord_company,ord_hdrnumber,ord_bookdate from orderheader where ord_startdate = '1950-01-01 00:00:00.000' and ord_status <> 'CAN'

		
		/*LOS PASA A LA TABLA #TempResults*/
		select 
		billto,    
		orden,
		fechabook
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
