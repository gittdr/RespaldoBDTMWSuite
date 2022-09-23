SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_AccPaidToDrvNotBillToCust] 
	(
		@MinThreshold float = .50,
		@MinsBack int=-20,
		@TempTableName varchar(255) = '##WatchDogGlobalAccPaidToDrvNotBillToCust',
		@WatchName varchar(255)='WatchAccPaidToDrvNotBilltoCust',
		@ThresholdFieldName varchar(255) = '',
		@ColumnNamesOnly bit = 0,
        @ExecuteDirectly bit = 0,
		@ColumnMode varchar(50) = 'Selected',
		@DrvType1 varchar(255) = '',
		@DrvType2 varchar(255) = '',
		@DrvType3 varchar(255) = '',
		@DrvType4 varchar(255) = '',
		@DrvDivision varchar(255) = '',
		@DrvTerminal varchar(255) = '',
		@DrvFleet varchar(255) = '',
		@DrvCompany varchar(255) = '',
		@IncludePayTypeList varchar(255) = '',
		@ExcludePayTypeList varchar(255) = '',
		@PayStatus varchar(255) = '',
		@IncludeBillToIDList varchar(255) = '',
		@ExcludeBillToIDList varchar(255) = ''
	
	)
				
AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_AccPaidToDrvNotBillToCust
Author/CreateDate: Brent Keeton / 9-22-2004
Purpose: 	Provides the pay detail information for Accessorials on pay which do not
			have same corresponding invoiced Accessorials
Revision History:  Lori Brickley / 12-1-2004 / Documentation
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
SET @IncludePayTypeList = ',' + ISNULL(@IncludePayTypeList,'') + ','
SET @ExcludePayTypeList = ',' + ISNULL(@ExcludePayTypeList,'') + ','
SET @PayStatus = ',' + ISNULL(@PayStatus,'') + ','
SET @IncludeBillToIDList = ',' + ISNULL(@IncludeBillToIDList,'') + ','
SET @ExcludeBillToIDList = ',' + ISNULL(@ExcludeBillToIDList,'') + ','

SET @DrvTerminal = ',' + ISNULL(@DrvTerminal,'') + ','
SET @DrvCompany = ',' + ISNULL(@DrvCompany,'') + ','
SET @DrvFleet = ',' + ISNULL(@DrvFleet,'') + ','
SET @DrvDivision = ',' + ISNULL(@DrvDivision,'') + ','

/*************************************************************************
	Create temp table #TempResults where the following conditions are met:
	
	Select pay details where the Pay has been updated within the minutes back,
	the pay type is accessorial (ancillary), and the invoiced order does
	not include the same accessorial item being billed
	
*************************************************************************/
SELECT  paydetail.asgn_id AS [Assignment ID], 
		paydetail.asgn_type AS [Assignment Type],
		legheader.lgh_driver1 AS [Driver ID],
		paydetail.pyt_itemcode AS [Pay Type],
		paydetail.pyd_description AS [Pay Type Description],
		IsNull(pyd_amount,0) AS Amount,
		[Order Number] =	(
								SELECT ord_number 
								FROM orderheader (NOLOCK) 
								WHERE orderheader.ord_hdrnumber = paydetail.ord_hdrnumber
							), 
		orderheader.ord_billto as [BillTo ID]
INTO    #TempResults
FROM    PayDetail (NOLOCK) 
		LEFT JOIN paytype (NOLOCK) ON paydetail.pyt_itemcode = paytype.pyt_itemcode
		LEFT JOIN orderheader (NOLOCK) ON paydetail.ord_hdrnumber = orderheader.ord_hdrnumber
        LEFT JOIN legheader (NOLOCK) ON legheader.lgh_number = paydetail.lgh_number
WHERE	pyd_updatedon >= DateAdd(mi,@MinsBack,GetDate())
	 	AND paytype.pyt_basis = 'ANC'
	 	AND pyd_minus = 1
	 	AND (@IncludePayTypeList =',,' or CHARINDEX(',' + rtrim(paydetail.pyt_itemcode) + ',', @IncludePayTypeList) >0)
	 	AND (@PayStatus =',,' or CHARINDEX(',' + pyd_status + ',', @PayStatus) >0)       
	 	AND NOT EXISTS (
							SELECT invoicedetail.ord_hdrnumber 
							FROM invoicedetail (NOLOCK) 
							WHERE cht_itemcode = paydetail.pyt_itemcode and invoicedetail.ord_hdrnumber = paydetail.ord_hdrnumber
						)
	 	AND (@DrvType1 =',,' OR CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
        AND (@DrvType2 =',,' OR CHARINDEX(',' + mpp_type2 + ',', @DrvType2) >0)
        AND (@DrvType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
        AND (@DrvType4 =',,' OR CHARINDEX(',' + mpp_type4 + ',', @DrvType4) >0)
        AND (@DrvTerminal =',,' OR CHARINDEX(',' + mpp_terminal + ',', @DrvTerminal) >0)
        AND (@DrvFleet =',,' OR CHARINDEX(',' + mpp_fleet + ',', @DrvFleet) >0)
        AND (@DrvCompany =',,' OR CHARINDEX(',' + mpp_company + ',', @DrvCompany) >0)
	 	AND (@DrvDivision =',,' OR CHARINDEX(',' + mpp_division + ',', @DrvDivision) >0)
	 	AND (@IncludeBillToIDList =',,' OR CHARINDEX(',' + orderheader.ord_billto + ',', @IncludeBillToIDList) >0)
	 	AND (@ExcludeBillToIDList = ',,' OR NOT (CHARINDEX(',' + orderheader.ord_billto + ',', @ExcludeBillToIDList) > 0)) 
	 	AND (@ExcludePayTypeList = ',,' OR NOT (CHARINDEX(',' + RTRIM(paydetail.pyt_itemcode) + ',', @ExcludePayTypeList) > 0)) 

--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'Select * from #TempResults'
END
ELSE
BEGIN
	SET @COLSQL = ''
	EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	SET @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
END

EXEC (@SQL)

SET NOCOUNT OFF

GO
