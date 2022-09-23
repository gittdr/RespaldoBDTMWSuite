SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'InactiveCustomers' ,1
CREATE PROC [dbo].[WatchDog_CustomerInactivity] 
	(
		@MinThreshold float = 3,
		@MinsBack int=-20,
		@TempTableName VARCHAR(255) = '##WatchDogCustomerInactivity',
		@WatchName VARCHAR(255)='WatchCustomer',
		@ThresholdFieldName VARCHAR(255) = 'Days',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@DaysSinceLastOrderMax int = NULL,
		@CompanyID VARCHAR(255)='',
		@CompanyType VARCHAR(255) = 'BillTo', --Shipper,Consignee,All
		@RevType1 VARCHAR(255) = '',
		@RevType2 VARCHAR(255) = '',
		@RevType3 VARCHAR(255) = '',
		@RevType4 VARCHAR(255) = '',	
		@ExcludeCompanyID VARCHAR(255)='',
		@OnlyOrderStatus VARCHAR(255)='',
		@ExcludeOrderStatus VARCHAR(255)=''
	)
						
AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_CustomerInactivity
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	   Returns Companies where the days
				since the last order taken is greater than
				the max.
Revision History:  Lori Brickley / 12-3-2004 / Add Comments
Tricia Noble / 02-06-09 / Adjusted @DaysSinceLastOrderMax to be less than or equal to instead of greater than or equal to Last Date Taken
*/

--Reserved/Mandatory WatchDog Variables
DECLARE @SQL VARCHAR(8000)
DECLARE @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @RevType1= ',' + ISNULL(@RevType1,'') + ','
SET @RevType2= ',' + ISNULL(@RevType2,'') + ','
SET @RevType3= ',' + ISNULL(@RevType3,'') + ','
SET @RevType4= ',' + ISNULL(@RevType4,'') + ','
SET @CompanyID= ',' + ISNULL(@CompanyID,'') + ','
SET @ExcludeCompanyID= ',' + ISNULL(@ExcludeCompanyID,'') + ','
SET @OnlyOrderStatus= ',' + ISNULL(@OnlyOrderStatus,'') + ','
SET @ExcludeOrderStatus= ',' + ISNULL(@ExcludeOrderStatus,'') + ','

/************************************************************************************
	Step 1:

	Select companies where the @CompanyType matches the type and the company is 
	active 
************************************************************************************/
SELECT cmp_id AS [Company ID],
       cmp_name AS [Company Name],
       CASE 	WHEN (@CompanyType = 'BillTo' AND cmp_billto = 'Y') THEN
		  			(	SELECT MAX(ord_datetaken) 
		  				FROM OrderHeader  (NOLOCK) 
		  				WHERE cmp_id = ord_billto
		  					AND (@OnlyOrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OnlyOrderStatus) >0) 
		  					AND (@ExcludeOrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @ExcludeOrderStatus) =0)
		  			)
	    		WHEN  (@CompanyType = 'Shipper' AND cmp_shipper = 'Y') THEN
		  			(	SELECT MAX(ord_datetaken) 
		  				FROM OrderHeader (NOLOCK) 
		  				WHERE cmp_id = ord_shipper
		  					AND (@OnlyOrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OnlyOrderStatus) >0) 
		  					AND (@ExcludeOrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @ExcludeOrderStatus) =0)
		  			)
	    		WHEN  (@CompanyType = 'Consignee' AND cmp_consingee = 'Y') THEN
		  			(	SELECT MAX(ord_datetaken) 
		  				FROM OrderHeader  (NOLOCK) 
		  				WHERE cmp_id = ord_consignee
		  					AND (@OnlyOrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OnlyOrderStatus) >0) 
		  					AND (@ExcludeOrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @ExcludeOrderStatus) =0)
		  			)
		  		WHEN  (@CompanyType = 'All') THEN
		  			(	SELECT MAX(ord_datetaken) 
		  				FROM OrderHeader  (NOLOCK) 
		  				WHERE (
		  							(cmp_id = ord_billto)
		  							or
		  							(cmp_id = ord_consignee)
		  							or
		  							(cmp_id = ord_shipper)
		  							or
		  							(cmp_id = ord_company)
		  						)
		  					AND (@OnlyOrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OnlyOrderStatus) >0) 
		  					AND (@ExcludeOrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @ExcludeOrderStatus) =0)
		  			)
       			END 
       			
		AS [Last Date Taken]
INTO   #TempCompanies
FROM   company (NOLOCK) 
WHERE  (	(@CompanyType = 'BillTo' AND cmp_billto = 'Y')
       		OR (@CompanyType = 'Consignee' AND cmp_consingee = 'Y')
       		OR (@CompanyType = 'Shipper' AND cmp_shipper = 'Y')
       		OR (@CompanyType='All')
		)
       AND cmp_active = 'Y'
       AND (@RevType1 =',,' OR CHARINDEX(',' + cmp_revtype1 + ',', @RevType1) >0)
       AND (@RevType2 =',,' OR CHARINDEX(',' + cmp_revtype2 + ',', @RevType2) >0)
       AND (@RevType3 =',,' OR CHARINDEX(',' + cmp_revtype3 + ',', @RevType3) >0)
       AND (@RevType4 =',,' OR CHARINDEX(',' + cmp_revtype4 + ',', @RevType4) >0)
       AND (@CompanyID =',,' OR CHARINDEX(',' + cmp_id + ',', @CompanyID) >0)
       AND (@ExcludeCompanyID =',,' OR CHARINDEX(',' + cmp_id + ',', @ExcludeCompanyID) =0)
        
        
/************************************************************************************
	Step 2:

	Select companies where the number of days since the last order is greater than
	the @DaysSinceLastOrderMax
************************************************************************************/
SELECT * ,
       DATEDIFF(DAY,[Last Date Taken],GETDATE()) AS [Days Since Last Order]
INTO   #TempResults
FROM   #TempCompanies
WHERE  DATEDIFF(DAY,[Last Date Taken],GETDATE()) >= @MinThreshold
       AND
       (
			(@DaysSinceLastOrderMAX IS NULL)
				OR
			(@DaysSinceLastOrderMax IS NOT NULL AND DATEDIFF(DAY,[Last Date Taken],GETDATE()) <= @DaysSinceLastOrderMax)
       )
ORDER BY [Last Date Taken] ASC

--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'SELECT * FROM #TempResults'
END
ELSE
BEGIN
	SET @COLSQL = ''
	EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	SET @SQL = 'SELECT identity(int,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
END

EXEC (@SQL)

SET NOCOUNT OFF

GO
