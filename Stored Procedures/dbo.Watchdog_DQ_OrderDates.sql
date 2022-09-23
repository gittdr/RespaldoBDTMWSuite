SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

	CREATE PROC [dbo].[Watchdog_DQ_OrderDates]
	(
		--Standard Parameters
		@MINThreshold FLOAT = 14, -- Threshold value for comparison purposes
		@MinsBack INT = -20,	-- Time frame to look back for records to evaluate
		@TempTableName VARCHAR(255) = '##WatchDogGlobalDQ_OrderDates',
		@WatchName VARCHAR(255)='DQ_OrderDates',
		@ThresholdFieldName VARCHAR(255) = 'Days',
		@ColumnNamesONly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'Selected'

		--Additional/Optional Parameters
	)
						
	AS

	--Standard Setting
	SET NOCOUNT ON

	--Reserved/Mandatory WatchDog Variables
	DECLARE @SQL VARCHAR(8000)
	DECLARE @COLSQL VARCHAR(4000)
	--Reserved/Mandatory WatchDog Variables

	--Typical List-Type Parameter Initialization
--	SET @ExampleParameter1List = ',' + ISNULL(@ExampleParameter1List,'') + ','

	-- local variables
	declare @ThisRunTime datetime
	set @ThisRunTime = GETDATE()

	--All data included in the emailed alert must be inserted into the temp table called #TempResults
	select ord_hdrnumber
	,ord_startdate
	,ord_completiondate
	,ord_status
	into #TempResults
	from orderheader with (NOLOCK)
	where last_updatedate > DateAdd(mi,@MinsBack,@ThisRunTime)
	AND ord_status in ('AVL','PLN','DSP','STD','CMP')
	AND ord_startdate > ord_completiondate


	--Begin Reserved/Mandatory recordset wrapper for the content of the email
	IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
	BEGIN
		SET @SQL = 'SELECT * FROM #TempResults'
	END
	ELSE
	BEGIN
		SET @COLSQL = ''
		EXEC WatchDogColumnNames @WatchName=@WatchName, @ColumnMode=@ColumnMode, @SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
	END

	EXEC (@SQL)
	--End Reserved/Mandatory recordset wrapper for the content of the email

	--Standard Setting
	SET NOCOUNT OFF


-- Part 3
	--Standard Initialization of the Alert
	--The following section of commented out code will insert the alert into the "All" list and allow
	--availability for edits within The Dawg application	
	/*
		if not exists (select WatchName from WatchDogItem where WatchName = 'DQ_OrderDates')
		INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress,
		 					BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName,
		 					NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, 
		 					DEFAULTCurrency, CurrencyDateType, Description,CheckedOut,ScheduleID,ScheduledRun)
		VALUES ('DQ_OrderDates', '12/30/1899', '12/30/1899', 'Watchdog_DQ_OrderDates', 
						'', '', 0, 0, '', '', '', '', '', 1, 0, '', '', '',0,1,'01/01/1900')
	*/

GO
GRANT EXECUTE ON  [dbo].[Watchdog_DQ_OrderDates] TO [public]
GO
