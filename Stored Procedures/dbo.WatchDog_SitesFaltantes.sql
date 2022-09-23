SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_SitesFaltantes] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogSitesFaltantes',
	@WatchName varchar(255)='SitesFaltantes',
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

  


select cmp_id as idcompania
,cmp_name as nombrecompania,
isnull((select cast(max(stp_schdtearliest) as varchar(20)) from stops (nolock) where stops.cmp_id= company.cmp_id),'Aun No Visitada')  as '--ultimavisita--',
cast(cmp_createdate as varchar(20)) as fechaalta

into   	#TempResults
 from company  where datediff(dd,cmp_createdate,getdate()) <= 365 
and (cmp_id not in (select displayName from QSP.dbo.navman_ic_api_site ))
order by  

(select max(stp_schdtearliest) from stops (nolock) where stops.cmp_id= company.cmp_id) desc


--select cmp_id, cmp_longseconds, cmp_latseconds from company where cmp_ID = 'BRACOA'
--select * from qsp..navman_ic_api_site where DisplayName = 'BRACOA'

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
