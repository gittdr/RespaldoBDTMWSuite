SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--watchdogprocessing 'customerloadcount'

CREATE PROC [dbo].[WatchDog_CustomerBookedLoadCount]
	(
		@MinThreshold FLOAT = 100,	-- order count BELOW which results will be returned
		@MinsBack INT=-20,			-- Not Used
		@TempTableName VARCHAR(255)='##WatchDogGlobalCustomerBooked',
		@WatchName VARCHAR(255)='WatchCustomerBookedLoadCount',
		@ThresholdFieldName VARCHAR(255) = 'LoadCount',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR (50) ='Selected',
		@BeginDate DATETIME = NULL, --If Null, GetDate
		@EndDate DATETIME = NULL, --If Null, GetDate
		@BeginDateDaysBack INT = NULL, --If Null, GetDate
		@EndDateDaysBack INT = NULL, --If Null, GetDate + 1
		@RevType1 VARCHAR(140)='',
		@RevType2 VARCHAR(140)='',
		@RevType3 VARCHAR(140)='',
		@RevType4 VARCHAR(140)='',
		@BillToIDList VARCHAR(140)='',
		@ShipperIDList VARCHAR(140)='',
		@ConsigneeIDList VARCHAR(140)='',
		@OrderStatus VARCHAR(140)='PLN,AVL,STD,DSP,CMP',
		@DateType VARCHAR(50) = 'Book', --Delivery or Ship
		@ListIndividualOrdersYN VARCHAR(1) = 'Y',
		@GroupbyParentCompanyYN VARCHAR(1) = 'N',
		@OnlyParentCompanyList VARCHAR(1)='',
		@NumberOfDaysToIncludeInHistoricAverage INT = 30
 	 )
						
AS

SET NOCOUNT ON

/*
Procedure Name:  WatchDog_CustomerBookedLoadCount
Author: 	 Brent Keeton
Purpose: 	 Allow tracking of customer load counts
		 Users enter a threshold and if count
		 goes below x amount of loads send a watchdog
		 Users put in any shipper,billto,consignee combination
		 and get back all orders that make up the load count 
		 that obviously didn't meet the threshold
Revision History:
	4/17/2008	fixes to correct problem with evaluation of @MinThreshold when @ListIndividualOrdersYN	= 'Y'
*/

--Reserved/Mandatory WatchDog Variables
DECLARE @SQL VARCHAR(8000)
DECLARE @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Additional WatchDog Variables
DECLARE @OrderCount INT

--Standard Parameter Initialization
SET @BillToIDList= ',' + RTRIM(ISNULL(@BillToIDList,'')) + ','
SET @ShipperIDList= ',' + RTRIM(ISNULL(@ShipperIDList,'')) + ','
SET @ConsigneeIDList= ',' + RTRIM(ISNULL(@ConsigneeIDList,'')) + ','

SET @RevType1= ',' + ISNULL(@RevType1,'') + ','
SET @RevType2= ',' + ISNULL(@RevType2,'') + ','
SET @RevType3= ',' + ISNULL(@RevType3,'') + ','
SET @RevType4= ',' + ISNULL(@RevType4,'') + ','
SET @OrderStatus= ',' + ISNULL(@OrderStatus,'') + ','

SET @OnlyParentCompanyList= ',' + ISNULL(@OnlyParentCompanyList,'') + ','


--Resolve the Begin Date
IF @BeginDate IS NULL
	BEGIN
		SET @BeginDate = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)
		IF @BeginDateDaysBack IS NULL
			BEGIN
				--go back to previous month
				SET @BeginDate = DATEADD(MONTH,-1,GETDATE())
				--and SET date to first day of the MONTH
				SET @BeginDate = CAST(CAST(DATEPART(yyyy,@BeginDate) AS CHAR(4)) + 
					         CASE WHEN LEN(CAST(DATEPART(mm,@BeginDate) AS VARCHAR(2))) < 2 THEN '0' + CAST(DATEPART(mm,@BeginDate) AS CHAR(1)) ELSE CAST(DATEPART(mm,@BeginDate) AS CHAR(2)) END +
					         '01' AS DATETIME)						

			END
		ELSE
			BEGIN
		 		SET @BeginDate = DATEADD(DAY, -@BeginDateDaysBack, @BeginDate)
	     	END

	END
	
--Resolve the End Date
IF @EndDate IS NULL
	BEGIN
		SET @EndDate = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)
		IF @EndDateDaysBack IS NULL
	   		BEGIN
				--set to first day of current MONTH	
				--will just pull everything prior to this date
				--in the WHERE clause
				SET @EndDate = CAST(CAST(DATEPART(yyyy,@EndDate) AS CHAR(4)) + 
					       CASE WHEN LEN(CAST(DATEPART(mm,@EndDate) AS VARCHAR(2))) < 2 THEN '0' + CAST(DATEPART(mm,@EndDate) AS CHAR(1)) ELSE CAST(DATEPART(mm,@EndDate) AS CHAR(2)) END +
					       '01' AS DATETIME)
			END
		ELSE
			BEGIN
				SET @ENDDate = DATEADD(DAY, -@EndDateDaysBack, @EndDate) 
			END			  
	END
ELSE
	BEGIN
		SET @EndDate = DATEADD(DAY, 1, @EndDate)
	END


---------------------------------------	
If @ListIndividualOrdersYN	= 'N'
	BEGIN
		IF @GroupbyParentCompanyYN = 'Y'
			BEGIN
				--Step 1 - Find the Parent Company Under Threshold
				SELECT 	
					billto.cmp_mastercompany as [Parent Company ID],
					'Parent Company' = (Select top 1 cmp_name from company (NOLOCK) where billto.cmp_mastercompany = cmp_id),
					count(*) as OrderCount,
					0 as HistoricAvg
				INTO   	#TempResults3
				FROM   	orderheader (NOLOCK) 
					LEFT JOIN company billto (NOLOCK) ON orderheader.ord_billto = billto.cmp_id
					LEFT JOIN company shipper (NOLOCK) ON orderheader.ord_shipper = shipper.cmp_id
					LEFT JOIN company consignee (NOLOCK) ON orderheader.ord_consignee = consignee.cmp_id
				WHERE 	(
		 					(@DateType = 'Book' AND ord_bookdate >= @begindate AND ord_bookdate < @enddate)
		 					OR
		 					(@DateType = 'Delivery' AND ord_completiondate >= @begindate AND ord_completiondate < @enddate)
		 					OR
		 					(@DateType = 'Ship' AND ord_startdate >= @begindate AND ord_startdate < @enddate)
						)
	       			AND (@RevType1 =',,' OR CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
	       			AND (@RevType2 =',,' OR CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
	       			AND (@RevType3 =',,' OR CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
	       			AND (@RevType4 =',,' OR CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
	       			AND	(@OrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
	       			AND	(@BillToIDList =',,' OR CHARINDEX(',' + ord_billto + ',', @BillToIDList) >0)
	       			AND	(@ShipperIDList =',,' OR CHARINDEX(',' + ord_shipper + ',', @ShipperIDList) >0)
	       			AND	(@ConsigneeIDList =',,' OR CHARINDEX(',' + ord_consignee + ',', @ConsigneeIDList) >0)
					AND	(@OnlyParentCompanyList =',,' OR CHARINDEX(',' + billto.cmp_mastercompany + ',', @OnlyParentCompanyList) >0)
				group by billto.cmp_mastercompany
				having count(*) < @MinThreshold
				order by count(*) desc

				--Find x Day Average
				SELECT 	
					billto.cmp_mastercompany as [Parent Company ID],
					'Parent Company' = (Select top 1 cmp_name from company (NOLOCK) where billto.cmp_mastercompany = cmp_id),
					count(*) as OrderCount
				INTO   	#TempResults3a
				FROM   	orderheader (NOLOCK) 
					LEFT JOIN company billto (NOLOCK) ON orderheader.ord_billto = billto.cmp_id
					LEFT JOIN company shipper (NOLOCK) ON orderheader.ord_shipper = shipper.cmp_id
					LEFT JOIN company consignee (NOLOCK) ON orderheader.ord_consignee = consignee.cmp_id
				WHERE 	(
		 					(@DateType = 'Book' AND ord_bookdate >= dateadd(day,-@NumberOfDaysToIncludeInHistoricAverage,@begindate) AND ord_bookdate < @enddate)
		 					OR
		 					(@DateType = 'Delivery' AND ord_completiondate >= dateadd(day,-@NumberOfDaysToIncludeInHistoricAverage,@begindate) AND ord_completiondate < @enddate)
		 					OR
		 					(@DateType = 'Ship' AND ord_startdate >= dateadd(day,-@NumberOfDaysToIncludeInHistoricAverage,@begindate) AND ord_startdate < @enddate)
						)
	       			AND (@RevType1 =',,' OR CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
	       			AND (@RevType2 =',,' OR CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
	       			AND (@RevType3 =',,' OR CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
	       			AND (@RevType4 =',,' OR CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
	       			AND	(@OrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
	       			AND	(@BillToIDList =',,' OR CHARINDEX(',' + ord_billto + ',', @BillToIDList) >0)
	       			AND	(@ShipperIDList =',,' OR CHARINDEX(',' + ord_shipper + ',', @ShipperIDList) >0)
	       			AND	(@ConsigneeIDList =',,' OR CHARINDEX(',' + ord_consignee + ',', @ConsigneeIDList) >0)
					AND	(@OnlyParentCompanyList =',,' OR CHARINDEX(',' + billto.cmp_mastercompany + ',', @OnlyParentCompanyList) >0)

				group by billto.cmp_mastercompany
				order by count(*) desc
				
				UPDATE #TempResults3
				SET HistoryAverage = (	SELECT (sum(ordercount)/@NumberOfDaysToIncludeInHistoricAverage)
										FROM #TempResults3a
										WHERE #TempResults3a.[Parent Company ID] = #TempResults3.[Parent Company ID]
									 )
				FROM #TempResults3a
				WHERE #TempResults3a.[Parent Company ID] = #TempResults3.[Parent Company ID]

				--Step 2 - Insert the Child companies for the Parent Companies
				Select billto.cmp_mastercompany as [Parent Company ID],
						'Parent Company' = (Select top 1 cmp_name from company (NOLOCK) where billto.cmp_mastercompany = cmp_id),
						ord_billto AS [Child Company ID],
	       				billto.cmp_name AS [Child Company],
						count(*) AS OrderCount,
						0 as HistoricAverage
				INTO   	#TempResults4
				FROM   	orderheader (NOLOCK) 
					LEFT JOIN company billto (NOLOCK) ON orderheader.ord_billto = billto.cmp_id
					LEFT JOIN company shipper (NOLOCK) ON orderheader.ord_shipper = shipper.cmp_id
					LEFT JOIN company consignee (NOLOCK) ON orderheader.ord_consignee = consignee.cmp_id
				WHERE 	(
		 					(@DateType = 'Book' AND ord_bookdate >= @begindate AND ord_bookdate < @enddate)
		 					OR
		 					(@DateType = 'Delivery' AND ord_completiondate >= @begindate AND ord_completiondate < @enddate)
		 					OR
		 					(@DateType = 'Ship' AND ord_startdate >= @begindate AND ord_startdate < @enddate)
						)
	       			AND (@RevType1 =',,' OR CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
	       			AND (@RevType2 =',,' OR CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
	       			AND (@RevType3 =',,' OR CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
	       			AND (@RevType4 =',,' OR CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
	       			AND	(@OrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
	       			AND	(@BillToIDList =',,' OR CHARINDEX(',' + ord_billto + ',', @BillToIDList) >0)
	       			AND	(@ShipperIDList =',,' OR CHARINDEX(',' + ord_shipper + ',', @ShipperIDList) >0)
	       			AND	(@ConsigneeIDList =',,' OR CHARINDEX(',' + ord_consignee + ',', @ConsigneeIDList) >0)
					AND	(@OnlyParentCompanyList =',,' OR CHARINDEX(',' + billto.cmp_mastercompany + ',', @OnlyParentCompanyList) >0)
					AND billto.cmp_mastercompany in (select distinct [Parent Company ID] from #TempResults3)

				group by orderheader.ord_billto,billto.cmp_name,[Child Company ID],[Child Company],[Child Company ID]
				having count(*) < @MinThreshold
				order by count(*) desc
				
				--Find x Day Average
				Select billto.cmp_mastercompany as [Parent Company ID],
						'Parent Company' = (Select top 1 cmp_name from company (NOLOCK) where billto.cmp_mastercompany = cmp_id),
						ord_billto AS [Child Company ID],
	       				billto.cmp_name AS [Child Company],
						count(*) AS OrderCount
				INTO   	#TempResults4a
				FROM   	orderheader (NOLOCK) 
					LEFT JOIN company billto (NOLOCK) ON orderheader.ord_billto = billto.cmp_id
					LEFT JOIN company shipper (NOLOCK) ON orderheader.ord_shipper = shipper.cmp_id
					LEFT JOIN company consignee (NOLOCK) ON orderheader.ord_consignee = consignee.cmp_id
				WHERE 	(
		 					(@DateType = 'Book' AND ord_bookdate >= dateadd(day,-@NumberOfDaysToIncludeInHistoricAverage,@begindate) AND ord_bookdate < @enddate)
		 					OR
		 					(@DateType = 'Delivery' AND ord_completiondate >= dateadd(day,-@NumberOfDaysToIncludeInHistoricAverage,@begindate) AND ord_completiondate < @enddate)
		 					OR
		 					(@DateType = 'Ship' AND ord_startdate >= dateadd(day,-@NumberOfDaysToIncludeInHistoricAverage,@begindate) AND ord_startdate < @enddate)
						)
	       			AND (@RevType1 =',,' OR CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
	       			AND (@RevType2 =',,' OR CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
	       			AND (@RevType3 =',,' OR CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
	       			AND (@RevType4 =',,' OR CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
	       			AND	(@OrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
	       			AND	(@BillToIDList =',,' OR CHARINDEX(',' + ord_billto + ',', @BillToIDList) >0)
	       			AND	(@ShipperIDList =',,' OR CHARINDEX(',' + ord_shipper + ',', @ShipperIDList) >0)
	       			AND	(@ConsigneeIDList =',,' OR CHARINDEX(',' + ord_consignee + ',', @ConsigneeIDList) >0)
					AND	(@OnlyParentCompanyList =',,' OR CHARINDEX(',' + billto.cmp_mastercompany + ',', @OnlyParentCompanyList) >0)
					AND billto.cmp_mastercompany in (select distinct [Parent Company ID] from #TempResults3)

				group by orderheader.ord_billto,billto.cmp_name,[Child Company ID],[Child Company],[Child Company ID]
				having count(*) < @MinThreshold
				order by count(*) desc
			
				UPDATE #TempResults4
				SET HistoryAverage = (	SELECT (sum(ordercount)/@NumberOfDaysToIncludeInHistoricAverage)
										FROM #TempResults4a
										WHERE #TempResults4a.[Parent Company ID] = #TempResults4.[Parent Company ID]
									 )
				FROM #TempResults4a
				WHERE #TempResults4a.[Parent Company ID] = #TempResults4.[Parent Company ID]


				--Final Select
				select * 
				into #TempResults5
				from 
				(
					select 	#TempResults4.[Parent Company ID],
							#TempResults4.[Parent Company],
							#TempResults4.[Child Company], 
							#TempResults4.OrderCount,
							#TempResults4.HistoricAverage
					from #TempResults4
					union select 	#TempResults3.[Parent Company ID],
									#TempResults3.[Parent Company],
									#TempResults3.[Child Company], 
									#TempResults3.OrderCount,
									#TempResults3.HistoricAverage
					from #TempResults3
				) xx
				order by [Parent Company ID] asc, OrderCount Desc
			END
		ELSE	-- NOT @GroupbyParentCompanyYN = 'Y'
			BEGIN
				SELECT 	
	       			ord_billto AS [BillTo ID],
	       			billto.cmp_name AS [BillTo],
					count(*) as OrderCount
				INTO   	#TempResults2
				FROM   	orderheader (NOLOCK) 
					LEFT JOIN company billto (NOLOCK) ON orderheader.ord_billto = billto.cmp_id
					LEFT JOIN company shipper (NOLOCK) ON orderheader.ord_shipper = shipper.cmp_id
					LEFT JOIN company consignee (NOLOCK) ON orderheader.ord_consignee = consignee.cmp_id
				WHERE 	(
		 					(@DateType = 'Book' AND ord_bookdate >= @begindate AND ord_bookdate < @enddate)
		 					OR
		 					(@DateType = 'Delivery' AND ord_completiondate >= @begindate AND ord_completiondate < @enddate)
		 					OR
		 					(@DateType = 'Ship' AND ord_startdate >= @begindate AND ord_startdate < @enddate)
						)
	       			AND (@RevType1 =',,' OR CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
	       			AND (@RevType2 =',,' OR CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
	       			AND (@RevType3 =',,' OR CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
	       			AND (@RevType4 =',,' OR CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
	       			AND	(@OrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
	       			AND	(@BillToIDList =',,' OR CHARINDEX(',' + ord_billto + ',', @BillToIDList) >0)
	       			AND	(@ShipperIDList =',,' OR CHARINDEX(',' + ord_shipper + ',', @ShipperIDList) >0)
	       			AND	(@ConsigneeIDList =',,' OR CHARINDEX(',' + ord_consignee + ',', @ConsigneeIDList) >0)
				group by orderheader.ord_billto,billto.cmp_name
				having count(*) < @MinThreshold
				order by count(*) desc
			END
	END
ELSE		-- @ListIndividualOrdersYN	= 'Y'
	BEGIN	
			
		--------------------------------------	

		/*********************************************************************************************
			Step 1:

			Select the order header data within the date range (Book-bookdate, Delivery-completiondate,
			Ship-startdate)
		*********************************************************************************************/
		SELECT 	ord_number AS [Order #],
      			ord_bookdate AS [Book Date],
       			ord_billto AS [BillTo ID],
       			billto.cmp_name AS [BillTo],
       			ord_shipper AS [Shipper ID],
       			shipper.cmp_name AS [Shipper],
       			ord_consignee AS [Consignee ID],
       			consignee.cmp_name AS [Consignee]
		INTO   	#TempOrderList
		FROM   	orderheader (NOLOCK) 
				LEFT JOIN company billto (NOLOCK) ON orderheader.ord_billto = billto.cmp_id
				LEFT JOIN company shipper (NOLOCK) ON orderheader.ord_shipper = shipper.cmp_id
				LEFT JOIN company consignee (NOLOCK) ON orderheader.ord_consignee = consignee.cmp_id
		WHERE 	(
	 				(@DateType = 'Book' AND ord_bookdate >= @begindate AND ord_bookdate < @enddate)
	 					OR
	 				(@DateType = 'Delivery' AND ord_completiondate >= @begindate AND ord_completiondate < @enddate)
	 					OR
	 				(@DateType = 'Ship' AND ord_startdate >= @begindate AND ord_startdate < @enddate)
				)
       			AND (@RevType1 =',,' OR CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
       			AND (@RevType2 =',,' OR CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
       			AND (@RevType3 =',,' OR CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
       			AND (@RevType4 =',,' OR CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
       			AND	(@OrderStatus =',,' OR CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
       			AND	(@BillToIDList =',,' OR CHARINDEX(',' + ord_billto + ',', @BillToIDList) >0)
       			AND	(@ShipperIDList =',,' OR CHARINDEX(',' + ord_shipper + ',', @ShipperIDList) >0)
       			AND	(@ConsigneeIDList =',,' OR CHARINDEX(',' + ord_consignee + ',', @ConsigneeIDList) >0)
		      

		/*********************************************************************************************
			Step 2:
			
			Count the orders from Step 1 where the count of orders is less than the minimum threshold
		*********************************************************************************************/
-- added 4/17/2008 to fix @MinThreshold evaluation
		Select [BillTo ID],OrderCount = Count(*)
		Into #TempCountList
		From #TempOrderList
		Group by [BillTo ID]

/*  This is original code 
		SELECT @OrderCount = Count(*)
		FROM   #TempOrderList
		HAVING COUNT(*) < @MinThreshold
*/		 
		/*********************************************************************************************
			Step 3:

			Select all orders where the Order Count is less than the minimum threshold
		*********************************************************************************************/
-- modified 4/17/2008 to fix @MinThreshold evaluation
		SELECT #TempOrderList.*, OrderCount
		INTO   #TempResults 
		FROM   #TempOrderList join #TempCountList on #TempOrderList.[BillTo ID] = #TempCountList.[BillTo ID]
		WHERE  OrderCount < @MinThreshold	
		Order by #TempOrderList.[BillTo ID],[Order #]

	END

--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
BEGIN
	If @ListIndividualOrdersYN	= 'N'
		IF @GroupbyParentCompanyYN = 'Y'
			SET @SQL = 'SELECT * FROM #TempResults5'
		ELSE
			SET @SQL = 'SELECT * FROM #TempResults2'
	ELSE
		SET @SQL = 'SELECT * FROM #TempResults'
END
ELSE
BEGIN
	SET @COLSQL = ''
	EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	If @ListIndividualOrdersYN	= 'N'
		IF @GroupbyParentCompanyYN = 'Y'
			SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults5'
		ELSE
			SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults2'
	ELSE
		SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
END

EXEC (@SQL)

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[WatchDog_CustomerBookedLoadCount] TO [public]
GO
