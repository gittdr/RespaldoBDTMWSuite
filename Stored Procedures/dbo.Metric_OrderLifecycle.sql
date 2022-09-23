SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[Metric_OrderLifecycle]
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
		@DateType varchar(50) = 'OrderStart',					-- BookDate, OrderStart, OrderEnd
		@Numerator varchar(25) = 'DeliverToLastInv',			-- BookToPlan,BookToShip,BookToFirstInv,BookToLastInv,PlanToShip,ShipToDeliver,ShipToFirstInv,ShipToLastInv,DeliverToFirstInv,DeliverToLastInv
		@Denominator varchar(25) = 'OrderCount',				-- OrderCount
		@TimeMeasureMHD char(1) = 'D',							-- (M)inutes, (H)ours, (D)ays
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
-- DETAILOPTIONS=1:ByRevType1,2:ByRevType1-2,3:ByRevType1-3,4:ByRevType1-4,5:ByBillTo,6:ByCustomerRep,7:ByCarrierRep,8:OrderListing

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
	create table #TempOrderList (ord_hdrnumber int)

	If @DateType = 'BookDate'
		begin
			Insert into #TempOrderList (ord_hdrnumber)
			Select ord_hdrnumber
			From OrderHeader (NOLOCK)
			Where ord_bookdate >= @DateStart and ord_bookdate < @DateEnd
			AND ord_status = 'CMP'
		end
	Else If @DateType = 'OrderStart'
		begin
			Insert into #TempOrderList (ord_hdrnumber)
			Select ord_hdrnumber
			From OrderHeader (NOLOCK)
			Where ord_startdate >= @DateStart and ord_startdate < @DateEnd
			AND ord_status = 'CMP'
		end
	Else	--If @DateType = 'OrderEnd'
		begin
			Insert into #TempOrderList (ord_hdrnumber)
			Select ord_hdrnumber
			From OrderHeader (NOLOCK)
			Where ord_completiondate >= @DateStart and ord_completiondate < @DateEnd
			AND ord_status = 'CMP'
		end

	create table #ResultsTable 
		(
			ord_hdrnumber int
			,OrderNumber varchar(15)
			,BillTo varchar(10)
			,Shipper varchar(10)
			,Consignee varchar(10)
			,RevType1 varchar(10)
			,RevType4 varchar(10)
			,RevType3 varchar(10)
			,RevType2 varchar(10)
			,CompanyBranch varchar(12)
			,OrderBranch varchar(12)
			,LegBranch varchar(12)
			,Bookdate datetime
			,PlanDate datetime
			,ShipDate datetime
			,DeliveryDate datetime
			,BillDate datetime
			,PrintDate datetime
			,TransferDate datetime
			,BookToPlan float
			,BookToShip float
			,BookToFirstInv float
			,BookToLastInv float
			,PlanToShip float
			,ShipToDeliver float
			,ShipToFirstInv float
			,ShipToLastInv float
			,DeliverToFirstInv float
			,DeliverToLastInv float
		)

		Insert into #ResultsTable
			(
				ord_hdrnumber,OrderNumber,BillTo,Shipper,Consignee,RevType1,RevType2,RevType3,RevType4,CompanyBranch,OrderBranch,LegBranch
				,Bookdate,PlanDate,ShipDate,DeliveryDate,BillDate,PrintDate,TransferDate,BookToPlan
				,BookToShip,BookToFirstInv,BookToLastInv,PlanToShip,ShipToDeliver,ShipToFirstInv,ShipToLastInv,DeliverToFirstInv,DeliverToLastInv
			)
		select OH.ord_hdrnumber
		,OrderNumber = OH.ord_number
		,BillTo = IsNull(ivh_billto,ord_billto)
		,Shipper = IsNull(ivh_shipper,ord_shipper)
		,Consignee = IsNull(ivh_consignee,ord_consignee)
		,RevType1 = IsNull(ivh_revtype1,ord_revtype1)
		,RevType2 = IsNull(ivh_revtype2,ord_revtype2)
		,RevType3 = IsNull(ivh_revtype3,ord_revtype3)
		,RevType4 = IsNull(ivh_revtype4,ord_revtype4)
		,CompanyBranch = BTC.cmp_bookingterminal
		,OrderBranch = OH.ord_booked_revtype1
		,LegBranch = NULL
		,Bookdate = ord_bookdate
		,PlanDate = ord_bookdate
		,ShipDate = IsNull(ivh_shipdate,ord_startdate)
		,DeliveryDate = IsNull(ivh_deliverydate,ord_completiondate)
		,BillDate = MAX(ivh_billdate)
		,PrintDate = MAX(ivh_printdate)
		,TransferDate = MAX(ivh_xferdate)
		,BookToPlan = 0.0
		,BookToShip = DateDiff(mi,ord_bookdate,ord_startdate)
		,BookToFirstInv = DateDiff(mi,ord_bookdate,MIN(ivh_billdate))
		,BookToLastInv = DateDiff(mi,ord_bookdate,MAX(ivh_billdate))
		,PlanToShip = 0.0
		,ShipToDeliver = DateDiff(mi,ord_startdate,ord_completiondate)
		,ShipToFirstInv = DateDiff(mi,ord_startdate,MIN(ivh_billdate))
		,ShipToLastInv = DateDiff(mi,ord_startdate,MAX(ivh_billdate))
		,DeliverToFirstInv = DateDiff(mi,ord_completiondate,MIN(ivh_billdate))
		,DeliverToLastInv = DateDiff(mi,ord_completiondate,MAX(ivh_billdate))
		from orderheader OH (NOLOCK) left join invoiceheader IH (NOLOCK) on OH.ord_hdrnumber = IH.ord_hdrnumber
		left join company BTC (NOLOCK) on BTC.cmp_id = ISNULL(IH.ivh_billto,OH.ord_billto)
		where OH.ord_hdrnumber in (select ord_hdrnumber from #TempOrderList)
		-- transaction-grain filters
		AND (@OnlyRevType1List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype1,OH.ord_revtype1) + ',', @OnlyRevType1List) > 0)
		AND (@OnlyRevType2List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype2,OH.ord_revtype2) + ',', @OnlyRevType2list) > 0)
		AND (@OnlyRevType3List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype3,OH.ord_revtype3) + ',', @OnlyRevType3List) > 0)
		AND (@OnlyRevType4List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype4,OH.ord_revtype4) + ',', @OnlyRevType4List) > 0)
		AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype1,OH.ord_revtype1) + ',', @ExcludeRevType1List) = 0)
		AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype2,OH.ord_revtype2) + ',', @ExcludeRevType2List) = 0)
		AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype3,OH.ord_revtype3) + ',', @ExcludeRevType3List) = 0)
		AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype4,OH.ord_revtype4) + ',', @ExcludeRevType4List) = 0)
		AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(IH.ivh_billto,OH.ord_billto) + ',', @OnlyBillToList) > 0)
		AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(IH.ivh_shipper,OH.ord_shipper) + ',', @OnlyShipperList) > 0)
		AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(IH.ivh_consignee,OH.ord_consignee) + ',', @OnlyConsigneeList) > 0)
		AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(IH.ivh_company,OH.ord_company) + ',', @OnlyOrderedByList) > 0)
		AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(IH.ivh_billto,OH.ord_billto) + ',', @ExcludeBillToList) = 0)                  
		AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(IH.ivh_shipper,OH.ord_shipper) + ',', @ExcludeShipperList) = 0)                  
		AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(IH.ivh_consignee,OH.ord_consignee) + ',', @ExcludeConsigneeList) = 0)                  
		AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(IH.ivh_company,OH.ord_company) + ',', @ExcludeOrderedByList) = 0)                  
		group by OH.ord_hdrnumber,OH.ord_number,ivh_billto,ord_billto,ivh_shipper,ord_shipper,ivh_consignee,ord_consignee
		,ivh_revtype1,ord_revtype1,ivh_revtype2,ord_revtype2,ivh_revtype3,ord_revtype3,ivh_revtype4,ord_revtype4
		,BTC.cmp_bookingterminal,OH.ord_booked_revtype1
		,ord_bookdate,ord_startdate,ord_completiondate,ivh_shipdate,ivh_deliverydate

		-- get orders planned 
		select ROSC.ord_hdrnumber as PlanOrder
		,MAX(ROSC.updated_dt) as LastPlanDate 
		into #TempLastPlanned
		from ResNow_OrderStatusChanges ROSC (NOLOCK) 
		where ROSC.ord_hdrnumber in (select ord_hdrnumber from #ResultsTable) 
		AND ROSC.NextStatus in ('PLN','DSP','STD','CMP')
		AND NOT ROSC.PriorStatus in ('PLN','DSP','STD','CMP')
		group by ROSC.ord_hdrnumber
		order by ROSC.ord_hdrnumber

		Update #ResultsTable set PlanDate = LastPlanDate
		,BookToPlan = DateDiff(mi,Bookdate,LastPlanDate)
		,PlanToShip = DateDiff(mi,LastPlanDate,ShipDate)
		from #TempLastPlanned
		where #TempLastPlanned.PlanOrder = #ResultsTable.ord_hdrnumber

		-- update FIRST LegBranch value
		select LH.ord_hdrnumber
		,LH.lgh_booked_revtype1
		into #TempLegBranch
		from legheader LH (NOLOCK) join stops ST (NOLOCK) on LH.lgh_number = ST.lgh_number
		where LH.ord_hdrnumber in (select ord_hdrnumber from #ResultsTable)
		AND ST.stp_mfh_sequence = 1

		Update #ResultsTable set LegBranch = lgh_booked_revtype1
		from #TempLegBranch
		where #TempLegBranch.ord_hdrnumber = #ResultsTable.ord_hdrnumber

		If @TimeMeasureMHD = 'H'
		begin
			Update #ResultsTable set BookToPlan = Round(BookToPlan / 60.0,4)
			,BookToShip = Round(BookToShip / 60.0,4)
			,BookToFirstInv = Round(BookToFirstInv / 60.0,4)
			,BookToLastInv = Round(BookToLastInv / 60.0,4)
			,PlanToShip = Round(PlanToShip / 60.0,4)
			,ShipToDeliver = Round(ShipToDeliver / 60.0,4)
			,ShipToFirstInv = Round(ShipToFirstInv / 60.0,4)
			,ShipToLastInv = Round(ShipToLastInv / 60.0,4)
			,DeliverToFirstInv = Round(DeliverToFirstInv / 60.0,4)
			,DeliverToLastInv = Round(DeliverToLastInv / 60.0,4)
		end
		Else If @TimeMeasureMHD = 'D'
		begin
			Update #ResultsTable set BookToPlan = Round(BookToPlan / 1440.0,4)
			,BookToShip = Round(BookToShip / 1440.0,4)
			,BookToFirstInv = Round(BookToFirstInv / 1440.0,4)
			,BookToLastInv = Round(BookToLastInv / 1440.0,4)
			,PlanToShip = Round(PlanToShip / 1440.0,4)
			,ShipToDeliver = Round(ShipToDeliver / 1440.0,4)
			,ShipToFirstInv = Round(ShipToFirstInv / 1440.0,4)
			,ShipToLastInv = Round(ShipToLastInv / 1440.0,4)
			,DeliverToFirstInv = Round(DeliverToFirstInv / 1440.0,4)
			,DeliverToLastInv = Round(DeliverToLastInv / 1440.0,4)
		end
		Else
		begin
			Update #ResultsTable set BookToPlan = Round(BookToPlan,4)
			,BookToShip = Round(BookToShip,4)
			,BookToFirstInv = Round(BookToFirstInv,4)
			,BookToLastInv = Round(BookToLastInv,4)
			,PlanToShip = Round(PlanToShip,4)
			,ShipToDeliver = Round(ShipToDeliver,4)
			,ShipToFirstInv = Round(ShipToFirstInv,4)
			,ShipToLastInv = Round(ShipToLastInv,4)
			,DeliverToFirstInv = Round(DeliverToFirstInv,4)
			,DeliverToLastInv = Round(DeliverToLastInv,4)		
		end


	--SQL Calculation of the Numerator (@ThisCount) and the Denominator (@ThisTotal)
	set @ThisCount = 
		Case
			when @Numerator = 'BookToPlan' then (select SUM(BookToPlan) from #ResultsTable where NOT BookToPlan is NULL)
			when @Numerator = 'BookToShip' then (select SUM(BookToShip) from #ResultsTable where NOT BookToShip is NULL)
			when @Numerator = 'BookToFirstInv' then (select SUM(BookToFirstInv) from #ResultsTable where NOT BookToFirstInv is NULL)
			when @Numerator = 'BookToLastInv' then (select SUM(BookToLastInv) from #ResultsTable where NOT BookToLastInv is NULL)
			when @Numerator = 'PlanToShip' then (select SUM(PlanToShip) from #ResultsTable where NOT PlanToShip is NULL)
			when @Numerator = 'ShipToDeliver' then (select SUM(ShipToDeliver) from #ResultsTable where NOT ShipToDeliver is NULL)
			when @Numerator = 'ShipToFirstInv' then (select SUM(ShipToFirstInv) from #ResultsTable where NOT ShipToFirstInv is NULL)
			when @Numerator = 'ShipToLastInv' then (select SUM(ShipToLastInv) from #ResultsTable where NOT ShipToLastInv is NULL)
			when @Numerator = 'DeliverToFirstInv' then (select SUM(DeliverToFirstInv) from #ResultsTable where NOT DeliverToFirstInv is NULL)
		Else --	when @Numerator = 'DeliverToLastInv' then 
			(select SUM(DeliverToLastInv) from #ResultsTable where NOT DeliverToLastInv is NULL)
		End

	set @ThisTotal = Case when @Denominator = 'OrderCount' then (select count(ord_hdrnumber) from #ResultsTable) End
		--Case
		--	when @Denominator = 'BookToPlan' then (select count(*) from #ResultsTable where NOT BookToPlan is NULL)
		--	when @Denominator = 'BookToShip' then (select count(*) from #ResultsTable where NOT BookToShip is NULL)
		--	when @Denominator = 'BookToFirstInv' then (select count(*) from #ResultsTable where NOT BookToFirstInv is NULL)
		--	when @Denominator = 'BookToLastInv' then (select count(*) from #ResultsTable where NOT BookToLastInv is NULL)
		--	when @Denominator = 'PlanToShip' then (select count(*) from #ResultsTable where NOT PlanToShip is NULL)
		--	when @Denominator = 'ShipToDeliver' then (select count(*) from #ResultsTable where NOT ShipToDeliver is NULL)
		--	when @Denominator = 'ShipToFirstInv' then (select count(*) from #ResultsTable where NOT ShipToFirstInv is NULL)
		--	when @Denominator = 'ShipToLastInv' then (select count(*) from #ResultsTable where NOT ShipToLastInv is NULL)
		--	when @Denominator = 'DeliverToFirstInv' then (select count(*) from #ResultsTable where NOT DeliverToFirstInv is NULL)
		--Else --	when @Numerator = 'DeliverToLastInv' then 
		--	(select count(*) from #ResultsTable)
		--End

	--Standard Final Result
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 

	--Detail (For returning detail for the ResultsNow detail request)
	IF @ShowDetail = 1		-- ByRevType1
		BEGIN
			select RevType1
			,count(*) as OrderCount
			,Round(Avg(BookToPlan),4) as AvgBookToPlan
			,Round(Avg(BookToShip),4) as AvgBookToShip
			,Round(Avg(BookToFirstInv),4) as AvgBookToFirstInv
			,Round(Avg(BookToLastInv),4) as AvgBookToLastInv
			,Round(Avg(PlanToShip),4) as AvgPlanToShip
			,Round(Avg(ShipToDeliver),4) as AvgShipToDeliver
			,Round(Avg(ShipToFirstInv),4) as AvgShipToFirstInv
			,Round(Avg(ShipToLastInv),4) as AvgShipToLastInv
			,Round(Avg(DeliverToFirstInv),4) as AvgDeliverToFirstInv
			,Round(Avg(DeliverToLastInv),4) as AvgDeliverToLastInv
			from #ResultsTable 
			group by RevType1
			order by RevType1
		END
	Else IF @ShowDetail = 2		-- ByRevType1-2
		BEGIN
			select RevType1
			,RevType2
			,count(*) as OrderCount
			,Round(Avg(BookToPlan),4) as AvgBookToPlan
			,Round(Avg(BookToShip),4) as AvgBookToShip
			,Round(Avg(BookToFirstInv),4) as AvgBookToFirstInv
			,Round(Avg(BookToLastInv),4) as AvgBookToLastInv
			,Round(Avg(PlanToShip),4) as AvgPlanToShip
			,Round(Avg(ShipToDeliver),4) as AvgShipToDeliver
			,Round(Avg(ShipToFirstInv),4) as AvgShipToFirstInv
			,Round(Avg(ShipToLastInv),4) as AvgShipToLastInv
			,Round(Avg(DeliverToFirstInv),4) as AvgDeliverToFirstInv
			,Round(Avg(DeliverToLastInv),4) as AvgDeliverToLastInv
			from #ResultsTable 
			group by RevType1,RevType2
			order by RevType1,RevType2
		END
	Else IF @ShowDetail = 3		-- ByRevType1-3
		BEGIN
			select RevType1
			,RevType2
			,RevType3
			,count(*) as OrderCount
			,Round(Avg(BookToPlan),4) as AvgBookToPlan
			,Round(Avg(BookToShip),4) as AvgBookToShip
			,Round(Avg(BookToFirstInv),4) as AvgBookToFirstInv
			,Round(Avg(BookToLastInv),4) as AvgBookToLastInv
			,Round(Avg(PlanToShip),4) as AvgPlanToShip
			,Round(Avg(ShipToDeliver),4) as AvgShipToDeliver
			,Round(Avg(ShipToFirstInv),4) as AvgShipToFirstInv
			,Round(Avg(ShipToLastInv),4) as AvgShipToLastInv
			,Round(Avg(DeliverToFirstInv),4) as AvgDeliverToFirstInv
			,Round(Avg(DeliverToLastInv),4) as AvgDeliverToLastInv
			from #ResultsTable 
			group by RevType1,RevType2,RevType3
			order by RevType1,RevType2,RevType3
		END
	Else IF @ShowDetail = 4		-- ByRevType1-4
		BEGIN
			select RevType1
			,RevType2
			,RevType3
			,RevType4
			,count(*) as OrderCount
			,Round(Avg(BookToPlan),4) as AvgBookToPlan
			,Round(Avg(BookToShip),4) as AvgBookToShip
			,Round(Avg(BookToFirstInv),4) as AvgBookToFirstInv
			,Round(Avg(BookToLastInv),4) as AvgBookToLastInv
			,Round(Avg(PlanToShip),4) as AvgPlanToShip
			,Round(Avg(ShipToDeliver),4) as AvgShipToDeliver
			,Round(Avg(ShipToFirstInv),4) as AvgShipToFirstInv
			,Round(Avg(ShipToLastInv),4) as AvgShipToLastInv
			,Round(Avg(DeliverToFirstInv),4) as AvgDeliverToFirstInv
			,Round(Avg(DeliverToLastInv),4) as AvgDeliverToLastInv
			from #ResultsTable 
			group by RevType1,RevType2,RevType3,RevType4
			order by RevType1,RevType2,RevType3,RevType4
		END
	Else IF @ShowDetail = 5	-- BillTo
		BEGIN
			select BillTo
			,count(*) as OrderCount
			,Round(Avg(BookToPlan),4) as AvgBookToPlan
			,Round(Avg(BookToShip),4) as AvgBookToShip
			,Round(Avg(BookToFirstInv),4) as AvgBookToFirstInv
			,Round(Avg(BookToLastInv),4) as AvgBookToLastInv
			,Round(Avg(PlanToShip),4) as AvgPlanToShip
			,Round(Avg(ShipToDeliver),4) as AvgShipToDeliver
			,Round(Avg(ShipToFirstInv),4) as AvgShipToFirstInv
			,Round(Avg(ShipToLastInv),4) as AvgShipToLastInv
			,Round(Avg(DeliverToFirstInv),4) as AvgDeliverToFirstInv
			,Round(Avg(DeliverToLastInv),4) as AvgDeliverToLastInv
			from #ResultsTable 
			group by BillTo
			order by BillTo
		END
	Else IF @ShowDetail = 6	-- CustomerRep
		BEGIN
			select OrderBranch
			,count(*) as OrderCount
			,Round(Avg(BookToPlan),4) as AvgBookToPlan
			,Round(Avg(BookToShip),4) as AvgBookToShip
			,Round(Avg(BookToFirstInv),4) as AvgBookToFirstInv
			,Round(Avg(BookToLastInv),4) as AvgBookToLastInv
			,Round(Avg(PlanToShip),4) as AvgPlanToShip
			,Round(Avg(ShipToDeliver),4) as AvgShipToDeliver
			,Round(Avg(ShipToFirstInv),4) as AvgShipToFirstInv
			,Round(Avg(ShipToLastInv),4) as AvgShipToLastInv
			,Round(Avg(DeliverToFirstInv),4) as AvgDeliverToFirstInv
			,Round(Avg(DeliverToLastInv),4) as AvgDeliverToLastInv
			from #ResultsTable 
			group by OrderBranch
			order by OrderBranch
		END
	Else IF @ShowDetail = 7	-- CarrierRep
		BEGIN
			select LegBranch
			,count(*) as OrderCount
			,Round(Avg(BookToPlan),4) as AvgBookToPlan
			,Round(Avg(BookToShip),4) as AvgBookToShip
			,Round(Avg(BookToFirstInv),4) as AvgBookToFirstInv
			,Round(Avg(BookToLastInv),4) as AvgBookToLastInv
			,Round(Avg(PlanToShip),4) as AvgPlanToShip
			,Round(Avg(ShipToDeliver),4) as AvgShipToDeliver
			,Round(Avg(ShipToFirstInv),4) as AvgShipToFirstInv
			,Round(Avg(ShipToLastInv),4) as AvgShipToLastInv
			,Round(Avg(DeliverToFirstInv),4) as AvgDeliverToFirstInv
			,Round(Avg(DeliverToLastInv),4) as AvgDeliverToLastInv
			from #ResultsTable 
			group by LegBranch
			order by LegBranch
		END	
	Else IF @ShowDetail = 8		-- CompleteList
		BEGIN
			Select OrderNumber
			,BillTo
			,Shipper
			,Consignee
			,RevType1
			,RevType2
			,RevType3
			,RevType4
			,CompanyBranch
			,OrderBranch
			,LegBranch
			,Bookdate
			,PlanDate
			,ShipDate
			,DeliveryDate
			,BillDate
			,PrintDate
			,TransferDate
			,BookToPlan
			,BookToShip
			,BookToFirstInv
			,BookToLastInv
			,PlanToShip
			,ShipToDeliver
			,ShipToFirstInv
			,ShipToLastInv
			,DeliverToFirstInv
			,DeliverToLastInv
			From #ResultsTable
			Order by OrderNumber
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
			@sMetricCode = 'OrderLifecycle',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 900, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDECIMAL = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 1,
			@sCaption = 'Order Lifecycle Days',
			@sCaptionFull = 'Order Lifecycle Days',
			@sPROCEDUREName = 'Metric_OrderLifecycle',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'

	*/

GO
GRANT EXECUTE ON  [dbo].[Metric_OrderLifecycle] TO [public]
GO
