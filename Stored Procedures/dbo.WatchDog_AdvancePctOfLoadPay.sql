SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_AdvancePctOfLoadPay] 
	(
		@MinThreshold FLOAT = .50, 
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalAdvancePctOfLoadPay',
		@WatchName VARCHAR(255)='WatchAdvancePctOfLoadPay',
		@ThresholdFieldName VARCHAR(255) = '',
		@ColumnNamesOnly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'SELECTed',
		@DrvType1 VARCHAR(255) = '',
		@DrvType2 VARCHAR(255) = '',
		@DrvType3 VARCHAR(255) = '',
		@DrvType4 VARCHAR(255) = '',
		@DrvDivision VARCHAR(255) = '',
		@DrvTerminal VARCHAR(255) = '',
		@DrvFleet VARCHAR(255) = '',
		@DrvCompany VARCHAR(255) = '',
		@DispatchStatus VARCHAR(255) = 'STD'
	)
						
AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_AdvancePctOfLoadPay
Author/CreateDate: Brent Keeton / 9-22-2004
Purpose: 	    Returns pay details from legheaders started within
				the last x minutes where Advance percentage of
				Load pay exceeds minThreshold (decimal).
Revision History:	Lori Brickley / 12-3-2004 / Add Comments, Add minThreshold restriction
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
SET @DispatchStatus = ',' + ISNULL(@DispatchStatus,'') + ','

SET @DrvTerminal = ',' + ISNULL(@DrvTerminal,'') + ','
SET @DrvCompany = ',' + ISNULL(@DrvCompany,'') + ','
SET @DrvFleet = ',' + ISNULL(@DrvFleet,'') + ','
SET @DrvDivision = ',' + ISNULL(@DrvDivision,'') + ','

/**************************************************************************************
	Step 1:

	Select pay detail, including advances and Load Pay,
	where the legheader start date is x minutes back
**************************************************************************************/
SELECT	sum(IsNull(pyd_amount,0)) as TotalLoadPay,
		[Advance Amount] = 	(
								SELECT -1 * sum(IsNull(b.pyd_amount,0)) 
								FROM paydetail b (NOLOCK) 
								WHERE b.lgh_number = paydetail.lgh_number 
									AND rtrim(b.pyt_itemcode) = 'LDMNY'
							),
		paydetail.asgn_id as [Assignment ID], 
		paydetail.asgn_type as [Assignment Type],
		lgh_outstatus as [Dispatch Status],
		[Order Number] = 	(
								SELECT ord_number 
								FROM orderheader (NOLOCK) 
								WHERE orderheader.ord_hdrnumber = legheader_active.ord_hdrnumber
							) 
INTO    #TempLoadPay
FROM    PayDetail (NOLOCK) 
		INNER JOIN legheader_active (NOLOCK) ON paydetail.lgh_number = legheader_active.lgh_number    
WHERE  	lgh_startdate >= DateAdd(mi,@MinsBack,GetDate())
		AND (@DrvType1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
        AND (@DrvType2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @DrvType2) >0)
        AND (@DrvType3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
        AND (@DrvType4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @DrvType4) >0)
        AND (@DrvTerminal =',,' or CHARINDEX(',' + mpp_terminal + ',', @DrvTerminal) >0)
        AND (@DrvFleet =',,' or CHARINDEX(',' + mpp_fleet + ',', @DrvFleet) >0)
        AND (@DrvCompany =',,' or CHARINDEX(',' + mpp_company + ',', @DrvCompany) >0)
        AND (@DrvDivision =',,' or CHARINDEX(',' + mpp_division + ',', @DrvDivision) >0)
	 	AND (@DispatchStatus =',,' or CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatus) >0)
GROUP BY paydetail.asgn_id,paydetail.asgn_id,paydetail.asgn_type,paydetail.lgh_number,legheader_active.lgh_outstatus,legheader_active.ord_hdrnumber

/**************************************************************************************
	Step 2:

	Insert new column to Step 1, Percent of advanced to Total Load Pay
**************************************************************************************/
SELECT #TempLoadPay.*,
       	CASE 	WHEN TotalLoadPay = 0 THEN
					0
       			ELSE
					[Advance Amount]/TotalLoadPay 
				END 
		AS [PercentageOfLoadPay]

		INTO   #TempResults
		FROM   #TempLoadPay

		WHERE CASE  WHEN TotalLoadPay = 0 
						THEN 0   
		            ELSE    
		     			[Advance Amount]/TotalLoadPay     
		      END  > @MinThreshold    

--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'SELECT * FROM #TempResults'
END
ELSE
BEGIN
	SET @COLSQL = ''
	EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	SET @SQL = 'SELECT identity(int,1,1) as RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
END

EXEC (@SQL)

SET NOCOUNT OFF

GO
