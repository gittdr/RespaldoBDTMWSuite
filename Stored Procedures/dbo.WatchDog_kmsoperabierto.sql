SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE Proc [dbo].[WatchDog_kmsoperabierto] 
(

	@DaysBack int=7,
	@TempTableName varchar(255)='##WatchDogkmsoperabierto',
	@WatchName varchar(255)='kmsoperabierto',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @Flota varchar(20)
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)

--Reserved/Mandatory WatchDog Variables

select 
mpp_tractornumber as Tractor,
mpp_id as idoperador,
mpp_lastname as 'Nombre Operador',
(select dbo.fnc_TMWRN_FormatNumbers(  sum(isnull(ord_totalmiles,0)),0  ) from orderheader where ord_status not in ('MST','CAN') and ord_driver1 = mpp_id and datediff(dd,ord_startdate,getdate()) <= 7 ) as Kmssemana,
(select dbo.fnc_TMWRN_FormatNumbers(  sum(isnull(ord_totalmiles,0)),0  ) from orderheader where ord_driver1 = mpp_id and ord_status  not in ('MST','CAN') and datediff(dd,ord_startdate,getdate())>7  and datediff(dd,ord_startdate,getdate()) <=14 ) as Kms2semanas

into #TempResults

from manpowerprofile
where mpp_fleet = (select abbr from labelfile where labeldefinition = 'fleet' and name = @flota)
and mpp_status <> 'OUT'
order by mpp_lastname asc


/*select 
mpp_tractornumber as Tractor,
mpp_id as idoperador,
mpp_lastname as 'Nombre Operador',
(select dbo.fnc_TMWRN_FormatNumbers(  sum(isnull(ord_totalmiles,0)),0  ) from orderheader where ord_status not in ('MST','CAN') and ord_driver1 = mpp_id and datediff(dd,ord_startdate,getdate()) <= 7 ) as Kmssemana,
(select dbo.fnc_TMWRN_FormatNumbers(  sum(isnull(ord_totalmiles,0)),0  ) from orderheader where ord_driver1 = mpp_id and ord_status  not in ('MST','CAN') and datediff(dd,ord_startdate,getdate()) <= 7*2 ) as Kms2semanas

into #TempResults

from manpowerprofile
where mpp_fleet = (select abbr from labelfile where labeldefinition = 'fleet' and name = @flota)
and mpp_status <> 'OUT'
order by (select  sum(isnull(ord_totalmiles,0)) from orderheader where ord_driver1 = mpp_id and datediff(dd,ord_startdate,getdate()) <= 7 ) desc
*/
	

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
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults order by 4'
	End

	Exec (@SQL)
	Set NoCount Off






GO
