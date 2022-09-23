SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE  PROC [dbo].[WatchDog_PayDetailsAudit] 
	(
		@MinThreshold float = 14,
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalPayDetailsAudit',
		@WatchName VARCHAR(255)='WatchPayDetailsAudit',
		@ThresholdFieldName VARCHAR(255) = '',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'SELECTed',
		@AuditStatus CHAR(1) = 'D', --Default is D:Delete
		@PayTypeList VARCHAR(255)='',
		@DrvType1 VARCHAR(255) = '',
		@DrvType2 VARCHAR(255) = '',
		@DrvType3 VARCHAR(255) = '',
		@DrvType4 VARCHAR(255) = '',
		@DrvDivision VARCHAR(255) = '',
		@DrvTerminal VARCHAR(255) = '',
		@DrvFleet VARCHAR(255) = '',
		@DrvCompany VARCHAR(255) = '',
		@PayDetailStatus VARCHAR(255)=''
	)
						
AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_PayDetailsAudit
Author/CreateDate: Brent Keeton / 9-22-2004
Purpose: 	    Returns the Pay Detail audits in
				the last x minutes.
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

SET @PayTypeList= ',' + ISNULL(@PayTypeList,'') + ','

SET @PayDetailStatus= ',' + ISNULL(@PayDetailStatus,'') + ','

/*********************************************************************************************
	Select Pay Details where audit date is x minutes back, and the audit status is in the
	AuditStatus List.
*********************************************************************************************/
SELECT	audit_user AS [Audit User],
		audit_status AS [Audit Status],
		audit_date AS [Audit Date],
		paydetailaudit.asgn_id AS [Assignment ID], 
		paydetailaudit.asgn_type AS [Assignment Type], 
		paydetailaudit.pyt_itemcode AS [Pay Type], 
		paydetailaudit.pyd_amount AS [Amount],
		paydetailaudit.pyd_status AS [Pay Status],
        LEFT(paydetailaudit.pyh_payperiod, 11) AS [Pay Period Date],
		[Order Number] = 	(
								SELECT ord_number 
								FROM orderheader (NOLOCK) 
								WHERE orderheader.ord_hdrnumber = paydetail.ord_hdrnumber
							),
		[Transaction Date] = paydetailaudit.pyd_transdate
INTO   	#TempResults 
FROM   	PayDetailAudit (NOLOCK)  
		LEFT JOIN manpowerprofile (NOLOCK) ON mpp_id = paydetailaudit.asgn_id AND paydetailaudit.asgn_type = 'DRV'
		LEFT JOIN paydetail (NOLOCK) ON paydetail.pyd_number = paydetailaudit.pyd_number	
WHERE   audit_date >= DATEADD(mi,@MinsBack,GETDATE())
	 	AND (@paytypelist =',,' OR CHARINDEX(',' + rtrim(paydetailaudit.pyt_itemcode) + ',', @paytypelist) >0)
        AND (@DrvType1 =',,' OR CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
        AND (@DrvType2 =',,' OR CHARINDEX(',' + mpp_type2 + ',', @DrvType2) >0)
        AND (@DrvType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
        AND (@DrvType4 =',,' OR CHARINDEX(',' + mpp_type4 + ',', @DrvType4) >0)
        AND (@DrvTerminal =',,' OR CHARINDEX(',' + mpp_terminal + ',', @DrvTerminal) >0)
        AND (@DrvFleet =',,' OR CHARINDEX(',' + mpp_fleet + ',', @DrvFleet) >0)
        AND (@DrvCompany =',,' OR CHARINDEX(',' + mpp_company + ',', @DrvCompany) >0)
        AND (@DrvDivision =',,' OR CHARINDEX(',' + mpp_division + ',', @DrvDivision) >0)
	AND (@PayDetailStatus =',,' OR CHARINDEX(',' + paydetailaudit.pyd_status + ',', @PayDetailStatus) >0)
	 	AND (
	  			(@AuditStatus = '') 
	  				OR
          		(audit_status = @AuditStatus)
			)
ORDER BY audit_date

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
