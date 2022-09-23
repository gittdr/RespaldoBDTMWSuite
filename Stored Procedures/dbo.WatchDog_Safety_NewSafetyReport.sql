SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'NewSafetyReport' ,1
CREATE Proc [dbo].[WatchDog_Safety_NewSafetyReport] 
(
	@MinThreshold float = 200,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalSafetyNewSafetyReport',
	@WatchName varchar(255)='WatchSafetyNewSafetyReport',
	@ThresholdFieldName varchar(255) = 'NewSafetyReport',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected'
)
						
As

	Set NoCount On


	/*
	Procedure Name:    WatchDog_Safety_NewSafetyReport
	Author/CreateDate: Lori Brickley / 01-10-2006
	Purpose: 	   Returns new safety reports created in the last x minutes
	Revision History:
	*/

	/*
	if not exists (select WatchName from WatchDogItem where WatchName = 'NewSafetyReport')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	 VALUES ('NewSafetyReport','12/30/1899','12/30/1899','WatchDog_Safety_NewSafetyReport','','',0,0,'','','','','',1,0,'','','')
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Select  srp_EventDate as [Date],
			srp_number as [Safety Report #], 
			srp_driver1 as [Driver ID], 
			'Driver Name' = (select mpp_lastfirst from manpowerprofile (nolock) where mpp_id = srp_driver1),
			srp_Classification as [Classification],
			srp_safetytype1 as [Safety Type 1],
			srp_safetytype2 as [Safety Type 2],
			srp_safetytype3 as [Safety Type 3],
			srp_safetytype4 as [Safety Type 4],
			srp_SafetyStatus as [Status]
	into    #TempResults
	From    safetyreport (NoLock)
	Where   srp_EventDate >= DateAdd(mi,@MinsBack,GetDate())

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
GRANT EXECUTE ON  [dbo].[WatchDog_Safety_NewSafetyReport] TO [public]
GO
