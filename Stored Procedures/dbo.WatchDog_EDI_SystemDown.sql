SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_EDI_SystemDown]
(
	@MinThreshold float = 100,
	@MinsBack int=-60,
	@TempTableName varchar(255)='##WatchDogGlobalEDISystemDown',
	@WatchName varchar(255) = 'EDISystemDown',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@AlertMessage VARCHAR(255)='EDI - Possible System Down' -- Overrides the Total Mail alert message
	
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_EDI_SystemDown
	Author/CreateDate: Lori Brickley / 1-19-2006
	Purpose: 	    Returns alert message when EDI has:
					1)  exceeded the threshold of pending records
				or	2)	exceeded the threshold between processing times
	Revision History:
	*/

	/*
	if not exists (select WatchName from WatchDogItem where WatchName = 'EDISystemDown')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	 VALUES ('EDISystemDown','12/30/1899','12/30/1899','WatchDog_EDI_SystemDown','','',0,0,'','','','','',1,0,'','','')
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
	

	/*************************************************************************
		Find all orders which arrived at the shipper within the last x minutes
	*************************************************************************/

	select 	@AlertMessage as [Alert Message], 
			MAX(err_date) AS LastEDIProcessing, 
			(SELECT count(*) from edi_214_pending) AS PendingEDIRecords
	INTO #TempResults
	from tts_errorlog (NOLOCK)
	where err_title = 'EDI Scheduler'

	
	DELETE FROM #TempResults
	WHERE 	(
				PendingEDIRecords < @MinThreshold
				AND 
				LastEDIProcessing >= DateAdd(mi,@MinsBack,GetDate())
			)
			OR
			(
				PendingEDIRecords = 0		
			)

				
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
