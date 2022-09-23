SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE   PROC [dbo].[WatchDog_CompletedOrdersBillingLag]
	(
		@MinThreshold FLOAT = 5,
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalCompletedOrdersBillingLag',
		@WatchName VARCHAR(255)='WatchCompletedOrdersBillingLag',
		@ThresholdFieldName VARCHAR(255) = 'CompletedOrdersBillingLag',
		@ColumnNamesOnly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@RevType1 VARCHAR(255) = '',
		@RevType2 VARCHAR(255) = '',
		@RevType3 VARCHAR(255) = '',
		@RevType4 VARCHAR(255) = '',
		@IncludeBillToIDList VARCHAR(255) = '',
		@InvoiceStatusList VARCHAR(255) = 'XFR',
		@MaxThreshold int = 3650 -- don't list unbilled revenue older that x days
	)
						
AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_CompletedOrdersBillingLag
Author/CreateDate: Brent Keeton / 9-22-2004
Purpose:	Returns orders where the order is complete, and the invoice
			status is not in the InvoiceStatusList and the completion
			date is greater than x days.	
Revision History:	Lori Brickley / 12-3-2004 / Add Comments

			Brad Young / 10-11-2006 Change Tractor ID column to join on MOVE and incl. CAR ID
*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL VARCHAR(8000)
Declare @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @RevType1= ',' + ISNULL(@RevType1,'') + ','
SET @RevType2= ',' + ISNULL(@RevType2,'') + ','
SET @RevType3= ',' + ISNULL(@RevType3,'') + ','
SET @RevType4= ',' + ISNULL(@RevType4,'') + ','
SET @IncludeBillToIDList = ',' + ISNULL(@IncludeBillToIDList,'') + ','
SET @InvoiceStatusList = ',' + ISNULL(@InvoiceStatusList ,'') + ','

/**************************************************************************************
	Selects the orders where the order status is complete, the order does not have
	the @InvoiceStatusList and the order completion date is greater than x days
**************************************************************************************/
SELECT 	[Order Number] = ord_number,
		mov_number AS [Move Number],
		ord_billto AS [Bill To ID],
		[Bill To] = (
						SELECT cmp_name 
						FROM company (NOLOCK) 
						WHERE cmp_id = ord_billto
					),
		ord_totalcharge AS [Total Revenue],
		ord_bookedby as [Entered/Booked By],
		[TeamLeader] = (
							SELECT top 1 mpp_teamleader
							FROM legheader (NOLOCK)
							WHERE legheader.ord_hdrnumber = orderheader.ord_hdrnumber
						),
		[Tractor ID] = (
							SELECT top 1 case lgh_tractor when 'UNKNOWN' then lgh_carrier else lgh_tractor end
							FROM legheader (NOLOCK)
							WHERE legheader.mov_number = orderheader.mov_number --was ord_hdrnumber
						),
		DATEDIFF(DAY,ord_completiondate,GETDATE()) AS [Lag Days],
		[Invoice Status] = (
							SELECT ivh_invoicestatus 
							FROM invoiceheader ih (NOLOCK) 
							WHERE (ih.ord_hdrnumber = OrderHeader.ord_hdrnumber)
							   AND ih.ivh_hdrnumber = (select max(i3.ivh_hdrnumber) from invoiceheader i3 (nolock) where i3.ord_hdrnumber = orderheader.ord_hdrnumber)
						   )	
INTO    #TempResults
FROM    OrderHeader (NOLOCK)
WHERE   ord_status = 'CMP'
	And ord_invoicestatus <> 'XIN'
	AND ord_invoicestatus <> 'CAN'
	And	(@RevType1 =',,' OR CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
      	AND (@RevType2 =',,' OR CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
        AND (@RevType3 =',,' OR CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
        AND (@RevType4 =',,' OR CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
        AND (@IncludeBillToIDList =',,' OR CHARINDEX(',' + ord_billto + ',', @IncludeBillToIDList) >0)
		AND NOT EXISTS (
							SELECT InvoiceHeader.ord_hdrnumber 
							FROM InvoiceHeader (NOLOCK) 
							WHERE InvoiceHeader.ord_hdrnumber = OrderHeader.ord_hdrnumber 
								AND InvoiceHeader.ivh_hdrnumber = (select max(i2.ivh_hdrnumber) from invoiceheader i2 (nolock) where i2.ord_hdrnumber = orderheader.ord_hdrnumber)
								AND 
								   (ivh_invoicestatus = 'CAN'
								   OR
								   (@InvoiceStatusList =',,' OR CHARINDEX(',' + ivh_invoicestatus + ',', @InvoiceStatusList) >0)
								   )
						)
		AND DATEDIFF(DAY,ord_completiondate,GETDATE()) >= @MinThreshold
		AND DATEDIFF(DAY,ord_completiondate,GETDATE()) <= @MaxThreshold 
ORDER BY DATEDIFF(DAY,ord_completiondate,GETDATE()) ASC

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
