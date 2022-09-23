SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_RevVsPayByOrder] 
	(
		@MinThreshold FLOAT = 100,
		@MinsBack INT=-20,
		@TempTableName varchar(255)='##WatchDogGlobalRevvsPay',
		@WatchName varchar(255) = 'RevenueVsPay',
		@ThresholdFieldName varchar(255) = 'Net',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode varchar (50) ='Selected',
		@ThresholdType varchar(255) = 'Dollars', --Choices:Dollars,PercentofRevenue
		@RevType1 varchar(140)='',
		@RevType2 varchar(140)='',
		@RevType3 varchar(140)='',
		@RevType4 varchar(140)='',
		@DriverType1 varchar(140)='',
		@DriverType2 varchar(140)='',
		@DriverType3 varchar(140)='',
		@DriverType4 varchar(140)='',
		@IncludeChargeTypeListOnly varchar(255)='',
		@ExcludeChargeTypeListOnly varchar(255)='',
		@ExcludePayTypeListOnly varchar(255)='',
		@IncludeBillToIDList varchar(255)='',
		@ExcludeBillToIDList varchar(255)='',
		@DateType varchar(100)='BILL',
		@PayDetailStatus varchar(200) = '',
		@PayHeaderStatus varchar(200) = 'XFR,COL,REL',
		@PayMovementMode varchar(200) = 'ReleasedPay' --Other Modes-> 'GreaterThenZeroPay','' (IF blank then the amount of pay doesn't matter it will return if threshold is met)
										--A.ReleasedPay -> Only show movements where the net between revenue and pay 
												 --is below or equal to the specified threshold and ONLY MOVES where the pay has been released
										--B.GreaterThenZeroPay-> Only show movements where the net between revenue and pay 
												 --is below or equal to the specified threshold and ONLY MOVES where the pay is > 0
										--C.AllPay-> Show All Movements where the net between revenue and pay is below or equal the specified threshold
											   --There is no requirement on the pay amount or no pay status restriction
	)

As

SET nocount on

/*
Procedure Name:    WatchDog_RevVsPay
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	   Returns either the NetProfit or the Percent of Revenue (ThresholdType)
				for orders invoiced within the last x minutes or pay details
				updated in the last x minutes (DateType)
Revision History:
		 1. Changed PayMovementMode to Allow records to be returned regardless of pay status V 1.7 LBK
*/


--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @RevType1= ',' + RTRIM(ISNULL(@RevType1,'')) + ','
SET @RevType2= ',' + RTRIM(ISNULL(@RevType2,'')) + ','
SET @RevType3= ',' + RTRIM(ISNULL(@RevType3,'')) + ','
SET @RevType4= ',' + RTRIM(ISNULL(@RevType4,'')) + ','
SET @DriverType1= ',' + RTRIM(ISNULL(@DriverType1,'')) + ','
SET @DriverType2= ',' + RTRIM(ISNULL(@DriverType2,'')) + ','
SET @DriverType3= ',' + RTRIM(ISNULL(@DriverType3,'')) + ','
SET @DriverType4= ',' + RTRIM(ISNULL(@DriverType4,'')) + ','
SET @PayDetailStatus = ',' + RTRIM(ISNULL(@PayDetailStatus,'')) + ','
SET @PayHeaderStatus = ',' + RTRIM(ISNULL(@PayHeaderStatus,'')) + ','

EXEC WatchDogPopulateSessionIDParamaters 'Revenue',@WatchName 

--Create Temp Table
CREATE TABLE #OrderList (ord_hdrnumber INT)

/***********************************************************************************
	Step 1:  

	IF DateType = Bill Then - 
		Select distinct invoiced orders where the invoice date is x minutes back,
		the invoice is not cancelled, the invoice does have an associated order
		NOTE:  ColumnNamesOnly Must Equal 0
	IF DateType <> Bill Then -
		Select distinct invoiced orders where the pay was updated in the last x
		minutes back and the invoice is not cancelled
		NOTE:  ColumnNamesOnly Must Equal 0 
***********************************************************************************/
IF @DateType = 'Bill'
BEGIN
	--Look at Moves that have change in the last X minutes
	INSERT INTO #OrderList
	SELECT DISTINCT invoiceheader.ord_hdrnumber
	FROM   invoiceheader (NOLOCK),legheader (NOLOCK)
	WHERE  ivh_billdate >= DATEADD(mi,@MinsBack,GETDATE())
       	       	AND ivh_invoicestatus <> 'CAN'
               	AND invoiceheader.ord_hdrnumber <> 0 
               	AND (@RevType1 =',,' OR CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)
               	AND (@RevType2 =',,' OR CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)
               	AND (@RevType3 =',,' OR CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)
               	AND (@RevType4 =',,' OR CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)
	       		AND legheader.mov_number = invoiceheader.mov_number
	       		AND (@DriverType1 =',,' OR CHARINDEX(',' + mpp_type1 + ',', @DriverType1) >0)
               	AND (@DriverType2 =',,' OR CHARINDEX(',' + mpp_type2 + ',', @DriverType2) >0)
               	AND (@DriverType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DriverType3) >0)
               	AND (@DriverType4 =',,' OR CHARINDEX(',' + mpp_type4 + ',', @DriverType4) >0)
	       		AND (
						(@ColumnNamesOnly = 1 AND 1=0)
							OR
						(@ColumnNamesOnly = 0)
       	       		)
END
ELSE
BEGIN
	--Look at Moves that have change in the last X minutes
	--but driven by when the paydetails last changed or 
	--more then likely released
	INSERT INTO #OrderList
	SELECT DISTINCT invoiceheader.ord_hdrnumber
	FROM   	paydetail (NOLOCK)
			LEFT JOIN payheader (NOLOCK) ON paydetail.pyh_number = payheader.pyh_pyhnumber
			INNER JOIN legheader (NOLOCK) ON legheader.lgh_number = paydetail.lgh_number
			INNER JOIN invoiceheader (NOLOCK) ON paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber
			
	WHERE  	pyd_updatedon >= DATEADD(mi,@MinsBack,GETDATE())
       	  	AND ivh_invoicestatus <> 'CAN'
            AND (@RevType1 =',,' OR CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)
            AND (@RevType2 =',,' OR CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)
            AND (@RevType3 =',,' OR CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)
            AND (@RevType4 =',,' OR CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)
	        AND (@DriverType1 =',,' OR CHARINDEX(',' + mpp_type1 + ',', @DriverType1) >0)
            AND (@DriverType2 =',,' OR CHARINDEX(',' + mpp_type2 + ',', @DriverType2) >0)
            AND (@DriverType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DriverType3) >0)
            AND (@DriverType4 =',,' OR CHARINDEX(',' + mpp_type4 + ',', @DriverType4) >0)
	        AND (@PayDetailStatus =',,' OR CHARINDEX(',' + pyd_status + ',', @PayDetailStatus) >0)
	        AND (@PayHeaderStatus =',,' OR CHARINDEX(',' + pyh_paystatus + ',', @PayHeaderStatus) >0)
	        AND (
					(@ColumnNamesOnly = 1 AND 1=0)
						OR
					(@ColumnNamesOnly = 0)
       	       	)
End

/***********************************************************************************
	Step 2:
	
	Calculate the corresponding Net Profit or the Percent of Revenue where 
	revenue is greater than 0, and based on Mode
		ReleasedPay - the Pay was Released
		GreaterThanZeroPay - Pay greater than 0
		AllPay - No Restriction
***********************************************************************************/
SELECT	TempRevVsPay.*,
       	(Revenue-Pay) as Net,
       	((Pay)/Case When Revenue = 0 Then 1 ELSE Revenue End) as PercentofRevenue
INTO	#TempResults
FROM (
		SELECT 	'Origin' = 	(
								SELECT cty_name + ', ' + cty_state 
								FROM city (NOLOCK) 
								WHERE ord_origincity = cty_code
							),
       			'Destination' = 	(
										SELECT cty_name + ', ' + cty_state 
										FROM city (NOLOCK) 
										WHERE ord_destcity = cty_code
									),
       			ord_number as 'Order Number',
       			mov_number as [Move #],
       			IsNull(dbo.fnc_TMWRN_Revenue('Order',default,default,default,orderheader.ord_hdrnumber,default,default,@IncludeChargeTypeListOnly,@ExcludeChargeTypeListOnly,'','','',@ExcludeBillToIDList,@IncludeBillToIDList,'',''),0) as Revenue, 
       			dbo.fnc_TotPayForOrder(orderheader.ord_hdrnumber,@ExcludePayTypeListOnly) as Pay,
       			PayReleased = IsNull((SELECT min('Y') FROM paydetail WHERE paydetail.ord_hdrnumber = orderheader.ord_hdrnumber AND paydetail.pyd_status = 'REL'),'N')
       	FROM   	#OrderList, orderheader (NOLOCK)
		WHERE  	#OrderList.ord_hdrnumber = orderheader.ord_hdrnumber   
	) AS TempRevVsPay
WHERE  (
			(@ThresholdType = 'Dollars' AND (Revenue-Pay) <= @MinThreshold)
				OR
			(@ThresholdType = 'PercentOfRevenue' AND (Case When Revenue <> 0 Then ((Pay)/Revenue) ELSE 0 End) >= @MinThreshold)
       )
       AND Revenue > 0
       AND (
	 			(@PayMovementMode = 'ReleasedPay' AND PayReleased = 'Y')  --just moves WHERE the pay is released
	 				OR  
	 			(@PayMovementMode = 'GreaterThenZeroPay' AND Pay > 0) --just moves where pay > 0
	 				OR 
	 			(@PayMovementMode = 'AllPay') --No Restriction so only return where the net
				 								--is below or equal to the threshold
       		)
ORDER BY 	CASE 	WHEN @ThresholdType = 'Dollars' THEN (Revenue-Pay) END,
	 		CASE 	WHEN @ThresholdType = 'PercentOfRevenue' THEN ((Pay)/CASE WHEN Revenue = 0 THEN 1 
					ELSE Revenue END)  END
	 DESC
		
--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'SELECT * FROM #TempResults'
END
ELSE
BEGIN
	SET @COLSQL = ''
	EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	SET @SQL = 'SELECT identity(INT,1,1) as RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
END

EXEC (@SQL)

SET nocount off

GO
