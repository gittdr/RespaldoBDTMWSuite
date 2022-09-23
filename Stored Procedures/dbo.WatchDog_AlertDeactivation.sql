SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

	CREATE PROC [dbo].[WatchDog_AlertDeactivation]
	(
		--Standard Parameters
		@MINThreshold FLOAT = 2, -- Value at which notification becomes warning
		@MinsBack INT = -20,	-- not used
		@TempTableName VARCHAR(255) = '##WatchDogGlobalAlertDeactivation',
		@WatchName VARCHAR(255)='AlertDeactivation',
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

	--All data included in the emailed alert must be inserted into the temp table called #TempResults
	

	SELECT WatchName
		,DataSourceSN
		,SQLStatement as StoredProcedure
		,EmailAddress
		,IsNull(ConsecutiveFailures,0) as ConsecutiveFailures
		,ConsecutiveFailuresLimit
		,ActiveFlag as AlertStatus
		,FailureStatus =
			Case 
				When IsNull(ConsecutiveFailures,0) >= ConsecutiveFailuresLimit Then 'Deactivated!'
				When IsNull(ConsecutiveFailures,0) = (ConsecutiveFailuresLimit - 1) Then 'Warning!'
				When IsNull(ConsecutiveFailures,0) between 1 and (ConsecutiveFailuresLimit - 1) Then 'Notification'
			Else
				'UNKNOWN Status'
			End
	INTO    #TempResults
	FROM	WatchDogItem (NOLOCK)
	WHERE IsNull(ConsecutiveFailures,0) > 0



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

GO
GRANT EXECUTE ON  [dbo].[WatchDog_AlertDeactivation] TO [public]
GO
