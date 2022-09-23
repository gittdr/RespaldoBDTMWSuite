SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_RightPadding]
	(
		--Standard Parameters
		@MINThreshold FLOAT = 3, -- Desired Value Length
		@MinsBack INT = -60,	-- Time frame to look back for records to evaluate
		@TempTableName VARCHAR(255) = '##WatchDogGlobalRightPadding',
		@WatchName VARCHAR(255)='RightPadding',
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
	SELECT ord_hdrnumber
	,ord_status
	,DataLength(ord_status) as ValueLength
	,last_updateby
	,last_updatedate
	INTO    #TempResults
	FROM	orderheader (NOLOCK)
	WHERE DateAdd(mi,@MinsBack,GetDate()) < last_updatedate  
		AND DataLength(ord_status) > @MINThreshold


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
GRANT EXECUTE ON  [dbo].[WatchDog_RightPadding] TO [public]
GO
