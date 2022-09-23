SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--watchdogprocessing 'SettlementBilledMilesVar',1

CREATE PROC [dbo].[WatchDog_SettlementBilledMilesVar]     
	(
		@MinThreshold FLOAT = 2500,
		@MinsBack INT=-555555,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalSettlementBilledMilesVar',
		@WatchName VARCHAR(255)='WatchSettlementBilledMilesVar',
		@ThresholdFieldName VARCHAR(255) = '',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@DrvType1 VARCHAR(255)='',
		@DrvType2 VARCHAR(255)='',
		@DrvType3 VARCHAR(255)='',
		@DrvType4 VARCHAR(255)='',
		@DrvFleet VARCHAR(255)='',
		@DrvDivision VARCHAR(255)='',
		@DrvDomicile VARCHAR(255)='',
		@DrvCompany VARCHAR(255)='',
		@DrvTerminal VARCHAR(255)='',
		@RevType1 VARCHAR(255)='',
		@RevType2 VARCHAR(255)='',
		@RevType3 VARCHAR(255)='',
		@RevType4 VARCHAR(255)='',
		@DispatchStatus VARCHAR(140)='DSP,PLN,STD,CMP',
		@PayDetailStatus VARCHAR(255) = 'TSM',
		@DriverID VARCHAR(255)='',
		@ExcludeDriverID VARCHAR(255)=''
 	)

AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_SettlementBilledMilesVar   
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	    Returns the orders where billed miles
				differs from settlement miles.
Revision History: 	Lori Brickley / 12-2-2004 / Add Comments
*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL VARCHAR(8000)
Declare @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @DrvType1= ',' + ISNULL(@DrvType1,'') + ','
SET @DrvType2= ',' + ISNULL(@DrvType2,'') + ','
SET @DrvType3= ',' + ISNULL(@DrvType3,'') + ','
SET @DrvType4= ',' + ISNULL(@DrvType4,'') + ','
SET @DrvFleet= ',' + ISNULL(@DrvFleet,'') + ','
SET @DrvDivision= ',' + ISNULL(@DrvDivision,'') + ','
SET @DrvDomicile= ',' + ISNULL(@DrvDomicile,'') + ','
SET @DrvCompany= ',' + ISNULL(@DrvCompany,'') + ','
SET @DrvTerminal= ',' + ISNULL(@DrvTerminal,'') + ','
SET @RevType1= ',' + ISNULL(@RevType1,'') + ','
SET @RevType2= ',' + ISNULL(@RevType2,'') + ','
SET @RevType3= ',' + ISNULL(@RevType3,'') + ','
SET @RevType4= ',' + ISNULL(@RevType4,'') + ','
SET @DispatchStatus= ',' + ISNULL(@DispatchStatus,'') + ','
SET @PayDetailStatus= ',' + ISNULL(@PayDetailStatus,'') + ','
SET @DriverID= ',' + ISNULL(@DriverID,'') + ','
SET @ExcludeDriverID= ',' + ISNULL(@ExcludeDriverID,'') + ','


/***********************************************************************
	Step 1:
	Create temp table #TempOrders where the following conditions are met:
	
	Select invoiced order details where the invoice header number is the 
	max invoice number, and the bill date is withing the minutes back, 
	and the invoice status is not cancelled.
***********************************************************************/
SELECT 	ord_number,
       	ord_hdrnumber,
       	ivh_billto,
       	mov_number,
       	ivh_totalmiles AS [BilledMiles]
INTO   	#TempOrders
FROM   	InvoiceHeader (NOLOCK)
WHERE  	ivh_billdate >= DATEADD(mi,@MinsBack,GETDATE())
       	AND ivh_hdrnumber =	(
								SELECT MAX(b.ivh_hdrnumber) 
								FROM invoiceheader b (NOLOCK) 
								WHERE b.ord_hdrnumber = invoiceheader.ord_hdrnumber 
									AND b.ivh_invoicestatus <> 'CAN'
							)
       	AND ivh_invoicestatus <> 'CAN'
       	AND (@RevType1 =',,' OR CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)
       	AND (@RevType2 =',,' OR CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)
       	AND (@RevType3 =',,' OR CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)
       	AND (@RevType4 =',,' OR CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)

/***********************************************************************
	Step 2:
	Create temp table #LegList where the following conditions are met:
	
	Select the corresponding legs to the #TempOrders in Step 1 where
	the leg status is not cancelled. 
***********************************************************************/
SELECT 	legheader.mov_number,
		lgh_number,
		lgh_enddate,
		lgh_driver1
INTO    #LegList
FROM  	legheader (NOLOCK), #TempOrders
WHERE	legheader.mov_number = #TempOrders.mov_number
       	AND (@DrvType1 =',,' OR CHARINDEX(',' +  mpp_type1 + ',', @DrvType1) >0)
       	AND (@DrvType2 =',,' OR CHARINDEX(',' + mpp_type2 + ',', @DrvType2) >0)
       	AND (@DrvType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
       	AND (@DrvType4 =',,' OR CHARINDEX(',' + mpp_type4 + ',', @DrvType4) >0)
       	AND (@DrvFleet =',,' OR CHARINDEX(',' + mpp_Fleet + ',', @DrvFleet) >0)
       	AND (@DrvDivision =',,' OR CHARINDEX(',' + mpp_Division + ',', @DrvDivision) >0)
       	AND (@DrvDomicile =',,' OR CHARINDEX(',' + mpp_Domicile + ',', @DrvDomicile) >0)
       	AND (@DrvCompany =',,' OR CHARINDEX(',' + mpp_Company + ',', @DrvCompany) >0)
       	AND	(@DrvTerminal =',,' OR CHARINDEX(',' + mpp_Terminal + ',', @DrvTerminal) >0) 
       	AND	(@DriverID =',,' OR CHARINDEX(',' + lgh_driver1 + ',', @DriverID) >0)
       	AND	(@ExcludeDriverID =',,' OR CHARINDEX(',' + lgh_driver1 + ',', @ExcludeDriverID) =0)
       	 	  
       	AND lgh_outstatus <> 'CAN'

/***********************************************************************
	Step 3:
	Create temp table #TempBilledAndSettledMiles where the following 
	conditions are met:
	
	Select the corresponding settlement miles to the legs and orders 
	from Steps 1 & 2 where the leg is the last leg 
	(maximum leg by leg number and mov number) 
***********************************************************************/
SELECT 	#TempOrders.*,
		SettlementMiles = 	(
								SELECT SUM(ISNULL(pyd_quantity,0)) 
								FROM paydetail (NOLOCK) 
								WHERE paydetail.ord_hdrnumber = #TempOrders.ord_hdrnumber 
									AND pyd_unit = 'MIL' 
									AND (@PayDetailStatus =',,' OR CHARINDEX(',' + RTrim(pyt_itemcode) + ',', @PayDetailStatus) >0)
							),
		lgh_driver1 AS [Driver ID]
INTO    #TempBilledAndSettledMiles
FROM    #TempOrders, #LegList
WHERE   #TempOrders.mov_number = #LegList.mov_number
		AND #LegList.lgh_number = 	(
										SELECT MAX(b.lgh_number) 
										FROM #LegList b 
										WHERE b.mov_number = #LegList.mov_number 
											AND b.lgh_enddate = 	(
																		SELECT MAX(c.lgh_enddate) 
																		FROM #LegList c 
																		WHERE c.mov_number = b.mov_number
																	)
									)
 
/***********************************************************************
	Step 4:
	Create temp table #TempResults where the following conditions are met:
	
	Select the Order number, Move Number, Bill To, Billed Miles, and
	Settlement Miles from Steps 1-3 where the Billed Miles are not
	equal to the Settlement Miles AND Settlement Miles are Not Null
***********************************************************************/       
SELECT 	ord_number AS [Order #],
       	mov_number AS [Move #],
       	ivh_billto AS [BillTo ID],
       	BilledMiles,
       	SettlementMiles,
       	[Driver ID] 
INTO   	#TempResults
FROM 	#TempBilledAndSettledMiles
WHERE  	BilledMiles <> SettlementMiles
       	AND SettlementMiles IS NOT NULL	
ORDER BY [BilledMiles]-[SettlementMiles]

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

GO
