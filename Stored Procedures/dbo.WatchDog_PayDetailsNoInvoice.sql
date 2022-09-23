SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




--watchdogprocessing 'paydetailsnoinvoice',1

create   Proc [dbo].[WatchDog_PayDetailsNoInvoice] 
	(
		@MinThreshold FLOAT = 14,
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalLargeMtMoves',
		@WatchName VARCHAR(255)='WatchLargeMTMoves',
		@ThresholdFieldName VARCHAR(255) = 'Empty Miles',
		@ColumnNamesOnly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@PayTypeList VARCHAR(255)='',
		@ExcludePayTypeList VARCHAR(255)='',
		@ExcludeBillToIDList VARCHAR(255)='',
		@DrvType1 VARCHAR(255) = '',
		@DrvType2 VARCHAR(255) = '',
		@DrvType3 VARCHAR(255) = '',
		@DrvType4 VARCHAR(255) = '',
		@DrvDivision VARCHAR(255) = '',
		@DrvTerminal VARCHAR(255) = '',
		@DrvFleet VARCHAR(255) = '',
		@DrvCompany VARCHAR(255) = '',
		@PayDetailStatus VARCHAR(255) = '',
		@PayHeaderStatus VARCHAR(255) = '',
		@IncludeChargeTypeList varchar(255)=''
	)
						
AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_OutstandingPayDetails
Author/CreateDate: Brent Keeton / 9-22-2004
Purpose: 	   Returns PayDetails updated in the last
				x minutes where there is no corresponding
				invoice.
Revision History:	Lori Brickley / 12-3-2004 / Add Comments
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

SET @ExcludeBillToIDList = ',' + ISNULL(@ExcludeBillToIDList,'') + ','

SET @PayTypeList= ',' + ISNULL(@PayTypeList,'') + ','
SET @ExcludePayTypeList= ',' + ISNULL(@ExcludePayTypeList,'') + ','
SET @PayDetailStatus = ',' + RTrim(ISNULL(@PayDetailStatus,'')) + ','
SET @PayHeaderStatus = ',' + RTrim(ISNULL(@PayHeaderStatus,'')) + ','
Set @IncludeChargeTypeList= ',' + ISNULL(@IncludeChargeTypeList,'') + ','

/*********************************************************************************************
	Select pay details updated in the last x minutes back where there is no matching invoice.
	
*********************************************************************************************/
SELECT 	paydetail.asgn_id AS [Assignment ID], 
		paydetail.asgn_type AS [Assignment Type], 
		pyt_itemcode AS [Pay Type], 
        LEFT(pyd_description,20) AS [Pay Type Description],
        pyd_status AS [Pay Status],
		payheader.pyh_paystatus AS [Settlement Status],
        LEFT(paydetail.pyh_payperiod, 11) AS [Pay Period Date],
		paydetail.mov_number AS [Move Number],
		[Order Number] =	(
								SELECT ord_number 
								FROM orderheader (NOLOCK) 
								WHERE orderheader.ord_hdrnumber = paydetail.ord_hdrnumber
							),
	Charge = IsNull((select sum(IsNull(ivd_charge,0)) from invoicedetail (NOLOCK) where invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber
	                and 
			(@IncludeChargeTypeList = ',,' OR (CHARINDEX(',' + RTrim(cht_itemcode) + ',',@IncludeChargeTypeList) > 0))),0)

INTO   	#TempResults 
FROM   	PayDetail (NOLOCK)  
		LEFT JOIN manpowerprofile (NOLOCK) On mpp_id = paydetail.asgn_id AND paydetail.asgn_type = 'DRV'
		LEFT JOIN payheader (NOLOCK) On payheader.pyh_pyhnumber = paydetail.pyh_number 
		LEFT JOIN InvoiceHeader (NOLOCK) On InvoiceHeader.mov_number = Paydetail.mov_number
		LEFT JOIN OrderHeader (NOLOCK) On OrderHeader.mov_number = Paydetail.mov_number       
WHERE   pyd_updatedon >= DATEADD(mi,@MinsBack,GETDATE())
       	AND (@paytypelist =',,' OR CHARINDEX(',' + rtrim(pyt_itemcode) + ',', @paytypelist) >0)
        AND (@ExcludePayTypeList = ',,' OR Not (CHARINDEX(',' + RTRIM(pyt_itemcode) + ',', @ExcludePayTypeList) > 0)) 
  	 	AND (@DrvType1 =',,' OR CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
        AND (@DrvType2 =',,' OR CHARINDEX(',' + mpp_type2 + ',', @DrvType2) >0)
        AND (@DrvType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
        AND (@DrvType4 =',,' OR CHARINDEX(',' + mpp_type4 + ',', @DrvType4) >0)
        AND (@DrvTerminal =',,' OR CHARINDEX(',' + mpp_terminal + ',', @DrvTerminal) >0)
        AND (@DrvFleet =',,' OR CHARINDEX(',' + mpp_fleet + ',', @DrvFleet) >0)
        AND (@DrvCompany =',,' OR CHARINDEX(',' + mpp_company + ',', @DrvCompany) >0)
        AND (@DrvDivision =',,' OR CHARINDEX(',' + mpp_division + ',', @DrvDivision) >0)
	 	AND (@PayDetailStatus =',,' OR CHARINDEX(',' + pyd_status + ',', @PayDetailStatus) >0)
	 	AND (@PayHeaderStatus =',,' OR CHARINDEX(',' + pyh_paystatus + ',', @PayHeaderStatus) >0)
	 	AND InvoiceHeader.ivh_hdrnumber IS NULL
	 	AND paydetail.mov_number > 0
	 	AND (@ExcludeBillToIDList = ',,' OR NOT (CHARINDEX(',' + ord_billto + ',', @ExcludeBillToIDList) > 0)) 

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
