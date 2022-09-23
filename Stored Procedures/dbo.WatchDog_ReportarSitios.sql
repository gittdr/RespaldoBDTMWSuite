SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[WatchDog_ReportarSitios] 
(

	@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogReportarSitios',
	@WatchName varchar(255)='ReportaSitios',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @Cliente varchar(20)
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)

--Reserved/Mandatory WatchDog Variables

BEGIN


--obtenemos los checkcalls a reportar

select ckc_tractor as unidad, ckc_date as fecha, ckc_comment as ubicacion 
into #TempResultsdos
from checkcall (nolock) 
where  ((ckc_comment like '%TDRLAREDO%') 
or
 (ckc_comment like  '%CAS/Tepotzotlan/IAVE%'))
 and ckc_tractor in 
 (select ord_Tractor from orderheader (nolock) where ord_billto = @cliente and ckc_validity <> 1 )



 --marcamos los check calls ya seleccionados

 update checkcall set 
 ckc_validity = 1
 where  ((ckc_comment like '%TDRLAREDO%') 
or
 (ckc_comment like  '%CAS/Tepotzotlan/IAVE%'))
 and ckc_tractor in 
 (select ord_Tractor from orderheader (nolock) where ord_billto = @cliente and ckc_validity <> 1 )




	    
---RENDER DE DATOS PARA EL REPORTE-----------------------------------------------------------------------------------------------------------------------------------------------


	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResultsdos'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResultsdos'
	End

	Exec (@SQL)
	Set NoCount Off




END
GO
