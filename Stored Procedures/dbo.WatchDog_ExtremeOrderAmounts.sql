SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_ExtremeOrderAmounts] 
	(
		@MinThreshold FLOAT = 100, -- $
		@MinsBack INT=-20, --Compared against CompletionDate
		@TempTableName VARCHAR(255)='##WatchDogGlobalExtremeOrderAmounts',
		@WatchName VARCHAR(255) = 'ExtremeOrderAmounts',
		@ThresholdFieldName VARCHAR(255) = 'Charge',
		@ColumnNamesOnly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR (50) ='Selected',
		@RevType1 VARCHAR(140)='',
		@RevType2 VARCHAR(140)='',
		@RevType3 VARCHAR(140)='',
		@RevType4 VARCHAR(140)='',
		@AmountType VARCHAR(50)='Total', --Linehaul or Accessorial
		@OrderStatus VARCHAR(255)='AVL,DSP,PLN,STD,CMP',
		@ThresholdDirection VARCHAR(50)='Above',
		@BookedBy varchar(255)='',
		@ParameterToUseForDynamicEmail varchar(140)=''
	)

AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_ExtremeOrderAmounts
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	     To Return Extreme Order Amounts
		     either below or above a certain threshold
Revision History:	Lori Brickley / 12-3-2004 / Add Comments and Fix Format
*/

--Reserved/MANDatory WatchDog Variables
Declare @SQL VARCHAR(8000)
Declare @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

SET @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
SET @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
SET @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
SET @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
SET @OrderStatus= ',' + RTrim(ISNULL(@OrderStatus,'')) + ','
Set @BookedBy =  ',' + ISNULL(@BookedBy,'') + ',' 

EXEC WatchDogPopulateSessionIDParamaters 'Revenue',@WatchName 

/*********************************************************************************************
	Step 1:
	
	Select Order where order completion date is within the minutes back, and the invoice
	status is not 'XIN'.
*********************************************************************************************/
SELECT ord_number AS [Order #],
       mov_number AS [Move #],
       ord_shipper AS [Shipper ID],
       ISNULL((SELECT cty_name FROM city (NOLOCK) WHERE cty_code = ord_origincity),'') AS [Origin City],
       ISNULL((SELECT cty_state FROM city (NOLOCK) WHERE cty_code = ord_origincity),'') AS [Origin State],
       ord_consignee AS [Consignee ID],
       ISNULL((SELECT cty_name FROM city (NOLOCK) WHERE cty_code = ord_destcity),'') AS [Destination City],
       ISNULL((SELECT cty_state FROM city (NOLOCK) WHERE cty_code = ord_destcity),'') AS [Destination State],
       ISNULL((SELECT cmp_name FROM company (NOLOCK) WHERE cmp_id = ord_billto),'') AS [BillTo],
       ord_billto AS [BillTo ID],
       CASE @AmountType
	    WHEN 'Total' THEN ISNULL(dbo.fnc_TMWRN_Revenue('Order',DEFAULT,DEFAULT,DEFAULT,ord_hdrnumber,DEFAULT,DEFAULT,'','','','','','','','',''),0)
	    WHEN 'LineHaul' THEN ISNULL(dbo.fnc_TMWRN_Revenue('Order',DEFAULT,DEFAULT,DEFAULT,ord_hdrnumber,DEFAULT,DEFAULT,'','','','','','','','',''),0)
	    WHEN 'Accessorial' THEN ISNULL(dbo.fnc_TMWRN_Revenue('Order',DEFAULT,DEFAULT,DEFAULT,ord_hdrnumber,DEFAULT,DEFAULT,'','','','','','','','',''),0)
       END AS Charge,
		ord_bookedby as [Booked by],
		EmailSend = ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,default,ord_bookedby),'')
INTO   #TempOrders
FROM   orderheader (NOLOCK)
WHERE  ord_completiondate >= DATEADD(mi,@MinsBack,GETDATE())
       AND (@OrderStatus =',,' or CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
       AND (@RevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
       AND (@RevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
       AND (@RevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
       AND (@RevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
       And (@BookedBy =',,' or CHARINDEX(',' + ord_bookedby + ',', @BookedBy) >0)
	   AND ord_invoicestatus <> 'XIN'
	   AND ord_status <> 'CAN'

/*********************************************************************************************
	Step 2:
	
	Select Orders where the order charge is above or below @MinThreshold $.
*********************************************************************************************/
SELECT * 
INTO   #TempResults
FROM   #TempOrders
WHERE	(
	  		(@ThresholdDirection = 'Above' AND charge > @MinThreshold)
	   			Or
	  		(@ThresholdDirection = 'Below' AND charge < @MinThreshold)
	 	)  
ORDER BY Charge DESC

--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
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

SET NOCOUNT Off

GO
