SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'LateLoads' ,1

CREATE PROC [dbo].[WatchDog_LateLoadsDemo]           
	(
		@MinThreshold FLOAT = 14,
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalLateLoads',
		@WatchName VARCHAR(255)='WatchLateLoads',
		@ThresholdFieldName VARCHAR(255) = null,
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@AirMilesAdjustmentPct INT = 10,
		@MaxAvgMilesPerHour INT = 45,
		@RevType1 VARCHAR(255)='',
		@RevType2 VARCHAR(255)='',
		@RevType3 VARCHAR(255)='',
		@RevType4 VARCHAR(255)='',
		@TeamLeader VARCHAR(255)=''  
 	)
						
AS

SET NOCOUNT ON

/***************************************************************
Procedure Name:    WatchDog_StopEvent
Author/CreateDate: Lori Brickley / 1-13-2005
Purpose: 	   	Provides a list of user defined stop events 
				which occured within the last x minutes		
Revision History:	
****************************************************************/

--Reserved/Mandatory WatchDog Variables
Declare @SQL VARCHAR(8000)
Declare @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @RevType1= ',' + ISNULL(@RevType1,'') + ','
SET @RevType2= ',' + ISNULL(@RevType2,'') + ','
SET @RevType3= ',' + ISNULL(@RevType3,'') + ','
SET @RevType4= ',' + ISNULL(@RevType4,'') + ','
SET @TeamLeader = ',' + ISNULL(@TeamLeader,'') + ','


/****************************************************************************
	Create temp table #TempResults where the following conditions are met:
	
	The load is already late (not arrived, past latest scheduled arrival)
	The load is going to be late (based on shortest distance at average miles per hour
			will still be late)
	The load might be late (based on shortest distance at average miles per hour
			might be late)

*****************************************************************************/
SELECT 	GETDATE() AS Now, 
		t2.stp_schdtlatest as ScheduleLatestArrival, 
		t2.stp_arrivaldate as ArrivalDate,
		'LATE' AS OrderStatus,
		t1.ord_hdrnumber AS OrderNumber,
		t1.lgh_tractor as Tractor, 
		t2.cmp_id as Company, 
		t2.stp_city as StopCity
	INTO #TempResults
	FROM legheader t1, stops t2, tractorprofile t3, city t4
	WHERE t1.lgh_number = t2.lgh_number
		AND t1.lgh_tractor = t3.trc_number
		AND t2.stp_city = t4.cty_code
		AND lgh_updatedon > DATEADD(minute, -@MinsBack, GETDATE()) 
		AND stp_status = 'DNE'
		AND stp_arrivaldate > stp_schdtlatest
		AND (@RevType1 =',,' OR CHARINDEX(',' + lgh_class1 + ',', @RevType1) >0)
        AND (@RevType2 =',,' OR CHARINDEX(',' + lgh_class2 + ',', @RevType2) >0)
        AND (@RevType3 =',,' OR CHARINDEX(',' + lgh_class3 + ',', @RevType3) >0)
        AND (@RevType4 =',,' OR CHARINDEX(',' + lgh_class4 + ',', @RevType4) >0)
        AND (@TeamLeader =',,' OR CHARINDEX(',' + mpp_teamleader + ',', @TeamLeader) >0) 

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
