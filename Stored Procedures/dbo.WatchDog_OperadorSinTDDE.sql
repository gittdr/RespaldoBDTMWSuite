SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OperadorSinTDDE] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogOperadorSinTDDE',
	@WatchName varchar(255)='OperadorSinTDDE',
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
	

SELECT        dbo.manpowerprofile.mpp_id AS ID, dbo.manpowerprofile.mpp_lastfirst AS Nombre, dbo.manpowerprofile.mpp_status AS Estatus, dbo.driverdocument.drd_docnumber AS Documento, dbo.driverdocument.drd_default AS Activo, 
                         dbo.manpowerprofile.mpp_type3 AS proyecto, dbo.labelfile.name AS nombreproyecto
into   	#TempResults
FROM            dbo.manpowerprofile LEFT OUTER JOIN
                         dbo.driverdocument ON dbo.manpowerprofile.mpp_id = dbo.driverdocument.mpp_id AND dbo.driverdocument.drd_doctype = 'TDDE' INNER JOIN
                         dbo.labelfile ON dbo.manpowerprofile.mpp_type3 = dbo.labelfile.abbr
WHERE        (dbo.manpowerprofile.mpp_status <> 'OUT') AND (dbo.manpowerprofile.mpp_id <> 'UNKNOWN') AND (LEFT(dbo.manpowerprofile.mpp_id, 2) <> 'P-') AND (dbo.labelfile.labeldefinition = 'DrvType3')
and dbo.driverdocument.drd_docnumber is null


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
