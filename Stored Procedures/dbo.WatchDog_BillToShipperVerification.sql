SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'BillToShipperVerfication',1

CREATE Proc [dbo].[WatchDog_BillToShipperVerification] 
	(
		@MinThreshold float = 100,
		@MinsBack int=-20,
		@TempTableName varchar(255)='##WatchDogGlobalBillToShipperVerification',
		@WatchName varchar(255) = 'BillToShipperVerification',
		@ThresholdFieldName varchar(255) = 'BillToShipperVerification',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode varchar (50) ='Selected',
		--@ThresholdType varchar(255) = 'InvalidShippers',
		@RevType1 varchar(140)='',
		@RevType2 varchar(140)='',
		@RevType3 varchar(140)='',
		@RevType4 varchar(140)='',
		@OrderStatus varchar(255)=''
	)

AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_BillToShipperVerification
Author/CreateDate: Lori Brickley / 12-3-2004
Purpose: 	   Returns orders WHERE the start date is within
				the last x minutes back
Revision History:
1. 6/21/2004 -> Added IsNull around charge fields BK
*/

--Reserved/Mandatory WatchDog Variables
DECLARE @SQL varchar(8000)
DECLARE @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
SET @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
SET @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
SET @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
SET @OrderStatus= ',' + RTrim(ISNULL(@OrderStatus,'')) + ','

/********************************************************************************
	Selects all orders WHERE the start date is within the last x minutes back
********************************************************************************/
SELECT  ord_number AS [Order #],
		mov_number AS [Move #],
		ord_shipper AS [Shipper ID],
       	(
			SELECT cty_name 
			FROM city (NOLOCK) 
			WHERE cty_code = ord_origincity
		) AS [Origin City],
       	ord_consignee AS [Consignee ID],
       	(
			SELECT cty_name 
			FROM city (NOLOCK) 
			WHERE cty_code = ord_destcity
		) AS [Destination City],
       	(
			SELECT cmp_name 
			FROM company (NOLOCK) 
			WHERE cmp_id = ord_billto
		) AS [BillTo],
		ord_billto AS [BillTo ID]
INTO   	#TempResults
FROM   	orderheader (NOLOCK)
WHERE  (@OrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
	AND (@RevType1 =',,' OR CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
    AND (@RevType2 =',,' OR CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
    AND (@RevType3 =',,' OR CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
    AND (@RevType4 =',,' OR CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
	AND ord_startdate > DATEADD(mi,@MinsBack,GETDATE())	
	
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
