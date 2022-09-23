SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[WatchDog_DawgSetupAlert]
	(
		--Standard Parameters
		@MINThreshold FLOAT = 14, --Adjust to Alert SpecificatiON Default
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalAlertTemplate',
		@WatchName VARCHAR(255)='DawgSetupAlert',
		@ThresholdFieldName VARCHAR(255) = 'Alert',
		@ColumnNamesONly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'Selected'
		
	)
						
AS

	--Standard Initialization of the Alert
	--The following section of commented out code will insert the alert into the "All" list and allow
	--availability for edits within The Dawg application
	
	/*
		if not exists (select WatchName from WatchDogItem where WatchName = 'DawgSetupAlert')
		INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
		VALUES ('DawgSetupAlert','12/30/1899','12/30/1899','WatchDog_DawgSetupAlert','','',0,0,'','','','','',1,0,'','','')
	*/

	--Standard Setting
	SET NOCOUNT ON

	--Reserved/Mandatory WatchDog Variables
	DECLARE @SQL VARCHAR(8000)
	DECLARE @COLSQL VARCHAR(4000)
	--Reserved/Mandatory WatchDog Variables
	
	--Standard Lsit Parameter Initialization
	
	--All data intended to be included in the emailed alert should be inserted
	--into the temp table called #TempResults
		SELECT 	WatchName as Alert, 
				SQLStatement AS 'Stored Procedure', 
				EmailAddress as Recipient, 
				LastRunDate, 
				ScheduleName,
				objDescription AS 'Schedule Description'
		INTO #TempResults
		FROM WatchDogItem join WatchDogScheduleObject on WatchDogItem.ScheduleID = WatchDogScheduleObject.ID
		WHERE activeflag = 1
				
	--Standard recordset wrapper for the content of the email
	IF @ColumnNamesONly = 1 OR @ExecuteDirectly = 1
	BEGIN
		SET @SQL = 'SELECT * FROM #TempResults'
	END
	ELSE
	BEGIN
		SET @COLSQL = ''
		EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
	END
	
	EXEC (@SQL)
	--Standard recordset wrapper for the content of the email

	--Standard Setting
	SET NOCOUNT OFF



GO
