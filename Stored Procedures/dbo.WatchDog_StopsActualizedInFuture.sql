SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_StopsActualizedInFuture]
	(
		@MinThreshold FLOAT = 14,
		@MinsBack INT = -44640, -- 31 days
		@TempTableName VARCHAR(255) = '##WatchDogGlobalStopsActualizedInFuture',
		@WatchName VARCHAR(255)='WatchStopsActualizedInFuture',
		@ThresholdFieldName VARCHAR(255) = null,
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@ParameterToUseForDynamicEmail varchar(140)=''
 	)
						
AS

	SET NOCOUNT ON
	
	/***************************************************************
	Procedure Name:    WatchDog_FutureStops
	Author/CreateDate: Don George / 6-8-2005
	Purpose: 


	Revision History:	
	****************************************************************/
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL VARCHAR(8000)
	Declare @COLSQL VARCHAR(4000)
	--Reserved/Mandatory WatchDog Variables
	
	--Standard Parameter Initialization
	SELECT t1.stp_arrivaldate, t1.stp_status, t1.stp_departuredate, t1.stp_departure_status, t1.ord_hdrnumber, 
		t1.lgh_number, t2.lgh_tractor
		,ISNULL(dbo.fnc_TMWRN_EmailSend('REVTYPE3', 
					mpp_company, mpp_division, mpp_domicile, default, mpp_type1, mpp_type2, mpp_type3, mpp_type4, default, 
					t3.ord_revtype3, t3.ord_revtype3, t3.ord_revtype3, t3.ord_revtype3, mpp_teamleader, mpp_terminal, default, trc_type1, trc_type2, 
					trc_type3, trc_type4, default, t2.trl_type1, t2.trl_type2, t2.trl_type3, t2.trl_type4, default),'') AS EmailSend 
	INTO #tempResults
	FROM stops t1 (NOLOCK) INNER JOIN legheader t2 (NOLOCK) ON t1.lgh_number = t2.lgh_number 
			INNER JOIN orderheader t3 (NOLOCK) ON t1.ord_hdrnumber = t3.ord_hdrnumber
	WHERE 
		t1.stp_status = 'DNE' AND t1.stp_arrivaldate > getdate()
		AND t1.ord_hdrnumber <> 0
	order by t1.stp_arrivaldate  desc


	--Commits the results to be used in the wrapper
	IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
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
	
	SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[WatchDog_StopsActualizedInFuture] TO [public]
GO
