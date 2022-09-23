SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



	CREATE PROC [dbo].[WatchDog_BackBookingAlert]
	(
		--Standard Parameters
		@MINThreshold FLOAT = 70, --Adjust Default Number of Minutes
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalAlertTemplate',
		@WatchName VARCHAR(255)='AlertTemplate',
		@ThresholdFieldName VARCHAR(255) = 'Minutes',
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
	SELECT 
		Ord_hdrnumber as OrderNumber
		,cmp_name as Company
		,cty_name + ', ' + cty_state + ' ' + cmp_zip as Location
		,ord_bookedby as BookingAssociate
		,ord_bookdate as BookingDate
		,ord_startdate as StartDate
	INTO #TempResults
	FROM orderheader OH (NOLOCK) Left Join company COM (NOLOCK) on OH.ord_shipper = COM.cmp_id
			join City SC (NOLOCK) on OH.ord_origincity = SC.cty_code
	WHERE DATEDIFF(mi,ord_bookdate,getdate()) < @minThreshold 
		AND ord_bookdate > ord_startdate
		AND ord_bookdate <= GetDate() -- special because of sample data issues
	ORDER BY ord_bookedby,ord_hdrnumber


	--Reserved/Mandatory recordset wrapper for the content of the email
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
	--Reserved/Mandatory recordset wrapper for the content of the email

	--Standard Setting
	SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[WatchDog_BackBookingAlert] TO [public]
GO
