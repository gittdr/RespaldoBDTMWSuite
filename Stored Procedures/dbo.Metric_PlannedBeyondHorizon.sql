SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[Metric_PlannedBeyondHorizon]
	(
		--Standard Parameters
		@Result DECIMAL(20, 5) OUTPUT, 
		@ThisCount DECIMAL(20, 5) OUTPUT, 
		@ThisTotal DECIMAL(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms INT = 0, 
		@ShowDetail INT = 0,

	--Additional/Optional Parameters
		@DateType varchar(20) = 'OrderStart',		-- OrderStart, PlanDate
		@Numerator varchar(20) = 'MetHorizon',		-- MetHorizon, MissedHorizon
		@Denominator varchar(20) = 'Day',			-- Day, OrderCount
		@PlanHorizonThresholdHours varchar(10) = '12',	
	-- filtering parameters: includes
		@OnlyRevType1List varchar(255) ='',
		@OnlyRevType2List varchar(255) ='',
		@OnlyRevType3List varchar(255) ='',
		@OnlyRevType4List varchar(255) ='',
		@OnlyBillToList varchar(255) = '',
		@OnlyShipperList varchar(255) = '',
		@OnlyConsigneeList varchar(255) = '',
		@OnlyOrderedByList varchar(255) = '',
	-- filtering parameters: excludes
		@ExcludeRevType1List varchar(255) ='',
		@ExcludeRevType2List varchar(255) ='',
		@ExcludeRevType3List varchar(255) ='',
		@ExcludeRevType4List varchar(255) ='',
		@ExcludeBillToList varchar(255) = '',
		@ExcludeShipperList varchar(255) = '',
		@ExcludeConsigneeList varchar(255) = '',
		@ExcludeOrderedByList varchar(255) = ''
	)
AS

	--Standard Setting
	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:MetHorizon,2:MissedHorizon,3:OrderCount

	-- local variables
	Declare @PlanHorizonThreshold float
	set @PlanHorizonThreshold = Convert(float,@PlanHorizonThresholdHours)

	--Standard Initialization for all List Parameters
	SET @OnlyRevType1List= ',' + ISNULL(@OnlyRevType1List,'') + ','
	SET @OnlyRevType2List= ',' + ISNULL(@OnlyRevType2List,'') + ','
	SET @OnlyRevType3List= ',' + ISNULL(@OnlyRevType3List,'') + ','
	SET @OnlyRevType4List= ',' + ISNULL(@OnlyRevType4List,'') + ','
	Set @OnlyBillToList= ',' + ISNULL(@OnlyBillToList,'') + ','
	Set @OnlyShipperList= ',' + ISNULL(@OnlyShipperList,'') + ','
	Set @OnlyConsigneeList= ',' + ISNULL(@OnlyConsigneeList,'') + ','
	Set @OnlyOrderedByList= ',' + ISNULL(@OnlyOrderedByList,'') + ','
	SET @ExcludeRevType1List= ',' + ISNULL(@ExcludeRevType1List,'') + ','
	SET @ExcludeRevType2List= ',' + ISNULL(@ExcludeRevType2List,'') + ','
	SET @ExcludeRevType3List= ',' + ISNULL(@ExcludeRevType3List,'') + ','
	SET @ExcludeRevType4List= ',' + ISNULL(@ExcludeRevType4List,'') + ','
	Set @ExcludeBillToList= ',' + ISNULL(@ExcludeBillToList,'') + ','
	Set @ExcludeShipperList= ',' + ISNULL(@ExcludeShipperList,'') + ','
	Set @ExcludeConsigneeList= ',' + ISNULL(@ExcludeConsigneeList,'') + ','
	Set @ExcludeOrderedByList= ',' + ISNULL(@ExcludeOrderedByList,'') + ','

	-- Custom Metric SQL here
	Create Table #TempTriplets (mov_number int, lgh_number int, ord_hdrnumber int, plandate datetime NULL)

	If @DateType = 'PlanDate'
		begin
			-- get orders planned today
			select ROSC.ord_hdrnumber as PlannedOrder
			,MAX(ROSC.updated_dt) as LastPlanDate 
			into #TempLastPlanned
			from ResNow_OrderStatusChanges ROSC (NOLOCK) 
			where ROSC.NextStatus in ('PLN','DSP','STD','CMP')
			AND NOT ROSC.PriorStatus in ('PLN','DSP','STD','CMP')
			group by ROSC.ord_hdrnumber
			having MAX(ROSC.updated_dt) >= @DateStart AND MAX(ROSC.updated_dt) < @DateEnd
			order by ROSC.ord_hdrnumber

			-- insert the valid triplets into the @TempTriplets table
			Insert into #TempTriplets (mov_number,lgh_number,ord_hdrnumber,plandate)
			SELECT RNT.mov_number
			,RNT.lgh_number
			,T1.PlannedOrder 
			,T1.LastPlanDate
			FROM #TempLastPlanned T1 join ResNow_Triplets RNT (NOLOCK) on T1.PlannedOrder = RNT.ord_hdrnumber
			
			drop table #TempLastPlanned
		end
	Else	-- @DateType = 'OrderStart'
		Begin
			Insert into #TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select ResNow_Triplets.mov_number
				,ResNow_Triplets.lgh_number
				,ResNow_Triplets.ord_hdrnumber
				From ResNow_Triplets (NOLOCK) join orderheader (NOLOCK) on ResNow_Triplets.ord_hdrnumber = orderheader.ord_hdrnumber
				where ResNow_Triplets.ord_startdate >= @DateStart AND ResNow_Triplets.ord_startdate < @DateEnd
				AND orderheader.ord_status in ('PLN','DSP','STD','CMP')

			select ROSC.ord_hdrnumber as PlannedOrder
			,MAX(ROSC.updated_dt) as LastPlanDate 
			into #TempPlanning
			from ResNow_OrderStatusChanges ROSC (NOLOCK) 
			where exists (select * from #TempTriplets TT where TT.ord_hdrnumber = ROSC.ord_hdrnumber)
			AND ROSC.NextStatus in ('PLN','DSP','STD','CMP')
			AND NOT ROSC.PriorStatus in ('PLN','DSP','STD','CMP')
			group by ROSC.ord_hdrnumber

			Update #TempTriplets set PlanDate = LastPlanDate
			From #TempPlanning
			Where #TempTriplets.ord_hdrnumber = #TempPlanning.PlannedOrder

			drop table #TempPlanning
		End

	Select distinct OrderNumber = ord_number
	,BillTo = ord_billto
	,Shipper = ord_shipper
	,Consignee = ord_consignee
	,PlanDate = TT.plandate
	,ShipDate = ord_startdate
	,DeliveryDate = ord_completiondate
	,PlanningHorizon = DateDiff(mi,TT.PlanDate,ord_startdate) / 60.0
	Into #ResultsTable
	From #TempTriplets TT join orderheader (NOLOCK) on TT.ord_hdrnumber = orderheader.ord_hdrnumber
	WHERE NOT PlanDate is NULL
	-- transaction-grain filters
	AND (@OnlyRevType1List =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @OnlyRevType1List) > 0)
	AND (@OnlyRevType2List =',,' or CHARINDEX(',' + orderheader.ord_revtype2 + ',', @OnlyRevType2list) > 0)
	AND (@OnlyRevType3List =',,' or CHARINDEX(',' + orderheader.ord_revtype3 + ',', @OnlyRevType3List) > 0)
	AND (@OnlyRevType4List =',,' or CHARINDEX(',' + orderheader.ord_revtype4 + ',', @OnlyRevType4List) > 0)
	AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @OnlyBillToList) > 0)
	AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @OnlyShipperList) > 0)
	AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @OnlyConsigneeList) > 0)
	AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @OnlyOrderedByList) > 0)
	AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @ExcludeRevType1List) = 0)
	AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + orderheader.ord_revtype2 + ',', @ExcludeRevType2List) = 0)
	AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + orderheader.ord_revtype3 + ',', @ExcludeRevType3List) = 0)
	AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + orderheader.ord_revtype4 + ',', @ExcludeRevType4List) = 0)
	AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @ExcludeBillToList) = 0)                  
	AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @ExcludeShipperList) = 0)                  
	AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @ExcludeConsigneeList) = 0)
	AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @ExcludeOrderedByList) = 0)                  


	--SQL Calculation of the Numerator (@ThisCount) and the Denominator (@ThisTotal)
	Set @ThisCount = 
		Case 
			When @Numerator = 'MetHorizon' then (Select count(distinct OrderNumber) from #ResultsTable where PlanningHorizon >= @PlanHorizonThreshold)
		Else	-- @Numerator = 'MissedHorizon'
			(Select count(*) from #ResultsTable where PlanningHorizon < @PlanHorizonThreshold)
		End

	Set @ThisTotal =
		Case
			When @Denominator = 'OrderCount' then (Select count(distinct OrderNumber) from #ResultsTable)
		Else -- When @Denominator = 'Day'
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		End

	--Standard Final Result
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 

	--Detail (For returning detail for the ResultsNow detail request)
	IF @ShowDetail = 1 -- MetHorizon
	BEGIN
		Select OrderNumber
			,BillTo
			,Shipper
			,Consignee
			,PlanDate
			,ShipDate
			,DeliveryDate
			,PlanningHorizon 
			,PlanningStatus = Case when PlanningHorizon >= @PlanHorizonThreshold then 'Met' Else 'Missed' End
		From #ResultsTable
		Where PlanningHorizon >= @PlanHorizonThreshold
	END

	IF @ShowDetail = 2 -- MissedHorizon
	BEGIN
		Select OrderNumber
			,BillTo
			,Shipper
			,Consignee
			,PlanDate
			,ShipDate
			,DeliveryDate
			,PlanningHorizon 
			,PlanningStatus = Case when PlanningHorizon >= @PlanHorizonThreshold then 'Met' Else 'Missed' End
		From #ResultsTable
		Where PlanningHorizon < @PlanHorizonThreshold
	END

	IF @ShowDetail = 3 -- OrderCount
	BEGIN
		Select OrderNumber
			,BillTo
			,Shipper
			,Consignee
			,PlanDate
			,ShipDate
			,DeliveryDate
			,PlanningHorizon 
			,PlanningStatus = Case when PlanningHorizon >= @PlanHorizonThreshold then 'Met' Else 'Missed' End
		From #ResultsTable
	END

	--Standard Setting
	SET NOCOUNT OFF

-- Part 3

	--Standard Initialization of the Metric
	--The following section of commented out code will
	--	insert the metric into the metric list and allow
	--  availability for edits within the ResultsNow Application
	/*

		EXEC MetricInitializeItem
			@sMetricCode = 'PlannedBeyondHorizon',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 900, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDECIMAL = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 1,
			@sCaption = 'Planned Beyond Horizon',
			@sCaptionFull = 'Planned Beyond Horizon',
			@sPROCEDUREName = 'Metric_PlannedBeyondHorizon',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'

	*/

GO
GRANT EXECUTE ON  [dbo].[Metric_PlannedBeyondHorizon] TO [public]
GO
