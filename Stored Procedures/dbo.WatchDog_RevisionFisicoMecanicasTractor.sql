SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_RevisionFisicoMecanicasTractor] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogRevisionFisicoMecanicasTractor',
	@WatchName varchar(255)='RevisionFisicoMecanicas',
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
	SELECT        dbo.tractorprofile.trc_number AS TRACTOR,dbo.tractoraccesories.tca_id AS FOLIO,  dbo.tractoraccesories.tca_dateaquired, dbo.tractoraccesories.tca_expire_date, 
                         A.name, B.name AS PROYECTO, DATEDIFF(day, GETDATE(), dbo.tractoraccesories.tca_expire_date) AS Dias, dbo.tractorprofile.trc_licnum,
						 dbo.EXTRACT_NUMPLACA(dbo.tractorprofile.trc_licnum) as Vencimiento
into   	#TempResults
FROM            dbo.tractorprofile LEFT OUTER JOIN
                         dbo.tractoraccesories ON dbo.tractorprofile.trc_number = dbo.tractoraccesories.tca_tractor AND dbo.tractoraccesories.tca_type = 'RFM' INNER JOIN
                         dbo.labelfile AS B ON dbo.tractorprofile.trc_type3 = B.abbr CROSS JOIN
                         dbo.labelfile AS A
WHERE        (dbo.tractorprofile.trc_status <> 'OUT') AND (dbo.tractorprofile.trc_number <> 'UNKNOWN') AND (A.abbr = 'RFM') AND (A.labeldefinition = 'trcacc') AND (B.labeldefinition = 'TrcType3')
and DATEDIFF(day, GETDATE(), dbo.tractoraccesories.tca_expire_date) <= 60
	

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
