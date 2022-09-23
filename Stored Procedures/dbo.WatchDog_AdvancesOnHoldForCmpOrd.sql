SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--watchdogprocessing 'AdvancesOnHoldForCmpOrd',1

CREATE PROC [dbo].[WatchDog_AdvancesOnHoldForCmpOrd] 
	(	
		@MinThreshold FLOAT = 5,
		@MinsBack INT=NULL,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalAdvancesOnHoldForCmpOrd',
		@WatchName VARCHAR(255)='WatchAdvancesOnHoldForCmpOrd',
		@ThresholdFieldName VARCHAR(255) = '',
		@ColumnNamesOnly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@DrvType1 VARCHAR(255)='',
		@DrvType2 VARCHAR(255)='',
		@DrvType3 VARCHAR(255)='',
		@DrvType4 VARCHAR(255)='',
		@DrvFleet VARCHAR(255)='',
		@DrvDivision VARCHAR(255)='',
		@DrvCompany VARCHAR(255)='',
		@DrvTerminal VARCHAR(255)='',
		@DaysBack INT = -365
	)
						
AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_AdvancesOnHoldForCmpOrd
Author/CreateDate: Brent Keeton / 9-22-2004
Purpose: 	Supplies the pay, driver, and invoice details where
			the pay detail was updated within either the minutes back
			or days back, the order is complete, the pay item is on hold, 
			and the item code = 'LDMNY'   
Revision History:	Lori Brickley / 12-2-2004 / Add Comments
*/

--Reserved/Mandatory WatchDog Variables
DECLARE @SQL VARCHAR(8000)
DECLARE @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @DrvType1= ',' + ISNULL(@DrvType1,'') + ','
SET @DrvType2= ',' + ISNULL(@DrvType2,'') + ','
SET @DrvType3= ',' + ISNULL(@DrvType3,'') + ','
SET @DrvType4= ',' + ISNULL(@DrvType4,'') + ','

SET @DrvTerminal = ',' + ISNULL(@DrvTerminal,'') + ','
SET @DrvCompany = ',' + ISNULL(@DrvCompany,'') + ','
SET @DrvFleet = ',' + ISNULL(@DrvFleet,'') + ','
SET @DrvDivision = ',' + ISNULL(@DrvDivision,'') + ','

/*************************************************************************
	Create temp table #TempResults where the following conditions are met:
	
	Select pay details, driver info, and invoice details where the Pay 
	has been updated within the minutes back OR the days back depending on 
	if minsBack is left blank, the order status is 'CMP', the pay item code
	is 'LDMNY', and the pay status is on Hold.
*************************************************************************/
SELECT 
	paydetail.asgn_id AS [Assignment ID], 
	paydetail.asgn_type AS [Assignment Type],
	legheader.lgh_driver1 AS [Driver ID],
	[Driver Name] = 	(
							SELECT mpp_lastfirst 
							FROM manpowerprofile (NOLOCK) 
							WHERE lgh_driver1 = mpp_id
						),
	paydetail.pyt_itemcode AS [Pay Type],
	paydetail.pyd_description AS [Pay Type Description],
	IsNull(pyd_amount,0) AS Amount,
	[Order Number] = 	(	
							SELECT ord_number 
							FROM orderheader (NOLOCK) 
							WHERE orderheader.ord_hdrnumber = paydetail.ord_hdrnumber
						), 
	orderheader.ord_billto AS [BillTo ID],
	[Transfer Date] = 	(
							SELECT MIN(ivh_xferdate) 
							FROM invoiceheader (NOLOCK) 
							WHERE invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
						)	
INTO    #TempResults
FROM    PayDetail (NOLOCK) 
		Left Join orderheader (NOLOCK) ON paydetail.ord_hdrnumber = orderheader.ord_hdrnumber
        Left Join legheader (NOLOCK) ON legheader.lgh_number = paydetail.lgh_number
WHERE   ord_status = 'CMP'
		AND (@DrvType1 =',,' OR CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
        AND (@DrvType2 =',,' OR CHARINDEX(',' + mpp_type2 + ',', @DrvType2) >0)
        AND (@DrvType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
        AND (@DrvType4 =',,' OR CHARINDEX(',' + mpp_type4 + ',', @DrvType4) >0)
        AND (@DrvTerminal =',,' OR CHARINDEX(',' + mpp_terminal + ',', @DrvTerminal) >0)
        AND (@DrvFleet =',,' OR CHARINDEX(',' + mpp_fleet + ',', @DrvFleet) >0)
        AND (@DrvCompany =',,' OR CHARINDEX(',' + mpp_company + ',', @DrvCompany) >0)
		AND (@DrvDivision =',,' OR CHARINDEX(',' + mpp_division + ',', @DrvDivision) >0)
        AND pyt_itemcode = 'LDMNY'
		AND pyd_status = 'HLD'
		AND
			(
	 			(@MinsBack Is NOT NULL AND pyd_updatedon >= DATEADD(mi,@MinsBack,GETDATE()))
	 				OR
	 			(@MinsBack Is NULL AND pyd_updatedon >= DATEADD(DAY,@DaysBack,GETDATE()))
        	)

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
