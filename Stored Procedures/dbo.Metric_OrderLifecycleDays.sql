SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[Metric_OrderLifecycleDays]
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
		@DateType varchar(50) = 'TransferDate',					-- BookDate, ShipDate, DeliveryDate, BillDate, PrintDate, TransferDate
		@EarlyDateType varchar(50) = 'BookDate',				-- BookDate, ShipDate, DeliveryDate, BillDate, PrintDate
		@LateDateType varchar(50) = 'TransferDate',				-- ShipDate, DeliveryDate, BillDate, PrintDate, TransferDate
		@InvoiceLagMethod varchar(20) = 'LagToLastInvoice',	--	LagToFirstInvoice, LagToLastInvoice
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
-- DETAILOPTIONS=1:QualifyingList,2:ByBillTo,3:CompleteList

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
		end
	Else If @DateType = 'ShipDate'
		begin
			Insert into #TempOrderList (ord_hdrnumber)
			Select ord_hdrnumber
			From Invoiceheader (NOLOCK)
			Where ivh_shipdate >= @DateStart and ivh_shipdate < @DateEnd
		end
	Else If @DateType = 'DeliveryDate'
		begin
			Insert into #TempOrderList (ord_hdrnumber)
			Select ord_hdrnumber
			From Invoiceheader (NOLOCK)
			Where ivh_deliverydate >= @DateStart and ivh_deliverydate < @DateEnd
		end
	Else If @DateType = 'BillDate'
		begin
			Insert into #TempOrderList (ord_hdrnumber)
			Select ord_hdrnumber
			From Invoiceheader (NOLOCK)
			Where ivh_billdate >= @DateStart and ivh_billdate < @DateEnd
		end
	Else If @DateType = 'PrintDate'
		begin
			Insert into #TempOrderList (ord_hdrnumber)
			Select ord_hdrnumber
			From Invoiceheader (NOLOCK)
			Where ivh_printdate >= @DateStart and ivh_printdate < @DateEnd
		end
	Else	-- @DateType = 'TransferDate'
		begin
			Insert into #TempOrderList (ord_hdrnumber)
			Select ord_hdrnumber
			From Invoiceheader (NOLOCK)
			Where ivh_xferdate >= @DateStart and ivh_xferdate < @DateEnd
		end

	create table #TempInvoiceOfRecord (ord_hdrnumber int, TheInvoice int)

	If @LateDateType in ('BillDate','PrintDate','TransferDate')
		begin
			If @InvoiceLagMethod = 'LagToFirstInvoice'
				begin
					Insert into #TempInvoiceOfRecord (ord_hdrnumber, TheInvoice)
						Select ord_hdrnumber
						,min(ivh_hdrnumber) as TheInvoice
						From Invoiceheader (NOLOCK)
						where ord_hdrnumber in (select ord_hdrnumber from #TempOrderList)
						group by ord_hdrnumber

					Select ord_hdrnumber
					,min(ivh_hdrnumber) as VeryFirstInvoice
					into #TempMinInv
					From Invoiceheader (NOLOCK)
					where ord_hdrnumber in (select ord_hdrnumber from #TempInvoiceOfRecord)
					group by ord_hdrnumber
					
					delete from #TempInvoiceOfRecord where NOT TheInvoice in (select VeryFirstInvoice from #TempMinInv)
					drop table #TempMinInv
				end
			else	--	@InvoiceLagMethod = 'LagToLastInvoice'
				begin
					Insert into #TempInvoiceOfRecord (ord_hdrnumber, TheInvoice)
						Select ord_hdrnumber
						,max(ivh_hdrnumber) as TheInvoice
						From Invoiceheader (NOLOCK)
						where ord_hdrnumber in (select ord_hdrnumber from #TempOrderList)
						group by ord_hdrnumber

					Select ord_hdrnumber
					,max(ivh_hdrnumber) as VeryLastInvoice
					into #TempMaxInv
					From Invoiceheader (NOLOCK)
					where ord_hdrnumber in (select ord_hdrnumber from #TempInvoiceOfRecord)
					group by ord_hdrnumber

					delete from #TempInvoiceOfRecord where NOT TheInvoice in (select VeryLastInvoice from #TempMaxInv)
					drop table #TempMaxInv
				end
		end

	create table #ResultsTable 
		(
			OrderNumber varchar(15)
			,InvoiceNumber varchar(15)
			,BillTo varchar(10)
			,Shipper varchar(10)
			,Consignee varchar(10)
			,Bookdate datetime
			,ShipDate datetime
			,DeliveryDate datetime
			,BillDate datetime
			,PrintDate datetime
			,TransferDate datetime
			,LifeCycleDays float
			,TotalCharges float
		)

	If @LateDateType in ('BillDate','PrintDate','TransferDate')
		begin
			Insert into #ResultsTable
			select OrderNumber = orderheader.ord_number
			,InvoiceNumber = ivh_invoicenumber
			,BillTo = ivh_billto
			,Shipper = ivh_shipper
			,Consignee = ivh_consignee
			,Bookdate = ord_bookdate
			,ShipDate = ivh_shipdate
			,DeliveryDate = ivh_deliverydate
			,BillDate = ivh_billdate
			,PrintDate = ivh_printdate
			,TransferDate = ivh_xferdate
			,LifeCycleDays =
				Case
					When @EarlyDateType = 'BookDate' then
						Case
							When @LateDateType = 'BillDate' then DateDiff(d,ord_bookdate,ivh_billdate)
							When @LateDateType = 'PrintDate' then DateDiff(d,ord_bookdate,ivh_printdate)
							When @LateDateType = 'TransferDate' then DateDiff(d,ord_bookdate,ivh_xferdate)
						Else	-- Mismatched Dates
							NULL
						End
					When @EarlyDateType = 'ShipDate' then
						Case
							When @LateDateType = 'BillDate' then DateDiff(d,ivh_shipdate,ivh_billdate)
							When @LateDateType = 'PrintDate' then DateDiff(d,ivh_shipdate,ivh_printdate)
							When @LateDateType = 'TransferDate' then DateDiff(d,ivh_shipdate,ivh_xferdate)
						Else	-- Mismatched Dates
							NULL
						End
					When @EarlyDateType = 'DeliveryDate' then
						Case
							When @LateDateType = 'BillDate' then DateDiff(d,ivh_deliverydate,ivh_billdate)
							When @LateDateType = 'PrintDate' then DateDiff(d,ivh_deliverydate,ivh_printdate)
							When @LateDateType = 'TransferDate' then DateDiff(d,ivh_deliverydate,ivh_xferdate)
						Else	-- Mismatched Dates
							NULL
						End
					When @EarlyDateType = 'BillDate' then
						Case
							When @LateDateType = 'PrintDate' then DateDiff(d,ivh_billdate,ivh_printdate)
							When @LateDateType = 'TransferDate' then DateDiff(d,ivh_billdate,ivh_xferdate)
						Else	-- Mismatched Dates
							NULL
						End
					When @EarlyDateType = 'PrintDate' then
						Case
							When @LateDateType = 'TransferDate' then DateDiff(d,ivh_printdate,ivh_xferdate)
						Else	-- Mismatched Dates
							NULL
						End
				Else	-- Mismatched Dates
					NULL
				End
			,TotalCharges =	convert(money,IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) 
			from invoiceheader join orderheader on invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
			where invoiceheader.ord_hdrnumber in (select ord_hdrnumber from #TempInvoiceOfRecord)
			AND invoiceheader.ivh_hdrnumber = (select TheInvoice from #TempInvoiceOfRecord where #TempInvoiceOfRecord.ord_hdrnumber = invoiceheader.ord_hdrnumber)
			-- transaction-grain filters
			AND (@OnlyRevType1List =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @OnlyRevType1List) > 0)
			AND (@OnlyRevType2List =',,' or CHARINDEX(',' + orderheader.ord_revtype2 + ',', @OnlyRevType2list) > 0)
			AND (@OnlyRevType3List =',,' or CHARINDEX(',' + orderheader.ord_revtype3 + ',', @OnlyRevType3List) > 0)
			AND (@OnlyRevType4List =',,' or CHARINDEX(',' + orderheader.ord_revtype4 + ',', @OnlyRevType4List) > 0)
			AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @ExcludeRevType1List) = 0)
			AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + orderheader.ord_revtype2 + ',', @ExcludeRevType2List) = 0)
			AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + orderheader.ord_revtype3 + ',', @ExcludeRevType3List) = 0)
			AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + orderheader.ord_revtype4 + ',', @ExcludeRevType4List) = 0)
			AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @OnlyBillToList) > 0)
			AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @OnlyShipperList) > 0)
			AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @OnlyConsigneeList) > 0)
			AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @OnlyOrderedByList) > 0)
			AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @ExcludeBillToList) = 0)                  
			AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @ExcludeShipperList) = 0)                  
			AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @ExcludeConsigneeList) = 0)                  
			AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @ExcludeOrderedByList) = 0)                  
		end
	Else	-- NOT @LateDateType in ('BillDate','PrintDate','TransferDate')
		begin
			Insert into #ResultsTable
			select OrderNumber = orderheader.ord_number
			,InvoiceNumber = ivh_invoicenumber
			,BillTo = ivh_billto
			,Shipper = ivh_shipper
			,Consignee = ivh_consignee
			,Bookdate = ord_bookdate
			,ShipDate = ivh_shipdate
			,DeliveryDate = ivh_deliverydate
			,BillDate = ivh_billdate
			,PrintDate = ivh_printdate
			,TransferDate = ivh_xferdate
			,LifeCycleDays =
				Case
					When @EarlyDateType = 'BookDate' then
						Case
							When @LateDateType = 'ShipDate' then DateDiff(d,ord_bookdate,ord_startdate)
							When @LateDateType = 'DeliveryDate' then DateDiff(d,ord_bookdate,ord_completiondate)
						Else	-- Mismatched Dates
							NULL
						End
					When @EarlyDateType = 'ShipDate' then 
						Case
							When @LateDateType = 'DeliveryDate' then DateDiff(d,ord_startdate,ord_completiondate)
						Else	-- Mismatched Dates
							NULL
						End
				Else	--	@EarlyDateType = 'ShipDate'
					NULL
				End
			,TotalCharges =	convert(money,IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) 
			from orderheader left join invoiceheader on orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
			where orderheader.ord_hdrnumber in (select ord_hdrnumber from #TempOrderList)
			-- transaction-grain filters
			AND (@OnlyRevType1List =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @OnlyRevType1List) > 0)
			AND (@OnlyRevType2List =',,' or CHARINDEX(',' + orderheader.ord_revtype2 + ',', @OnlyRevType2list) > 0)
			AND (@OnlyRevType3List =',,' or CHARINDEX(',' + orderheader.ord_revtype3 + ',', @OnlyRevType3List) > 0)
			AND (@OnlyRevType4List =',,' or CHARINDEX(',' + orderheader.ord_revtype4 + ',', @OnlyRevType4List) > 0)
			AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @ExcludeRevType1List) = 0)
			AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + orderheader.ord_revtype2 + ',', @ExcludeRevType2List) = 0)
			AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + orderheader.ord_revtype3 + ',', @ExcludeRevType3List) = 0)
			AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + orderheader.ord_revtype4 + ',', @ExcludeRevType4List) = 0)
			AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @OnlyBillToList) > 0)
			AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @OnlyShipperList) > 0)
			AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @OnlyConsigneeList) > 0)
			AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @OnlyOrderedByList) > 0)
			AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @ExcludeBillToList) = 0)                  
			AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @ExcludeShipperList) = 0)                  
			AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @ExcludeConsigneeList) = 0)                  
			AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @ExcludeOrderedByList) = 0)                  
		end

	--SQL Calculation of the Numerator (@ThisCount) and the Denominator (@ThisTotal)
	set @ThisCount = (select sum(LifeCycleDays) as AccumulatedLifeCycleDays from #ResultsTable where NOT LifeCycleDays is NULL)
	set @ThisTotal = (select count(*) as SampleSize from #ResultsTable where NOT LifeCycleDays is NULL)

	--Standard Final Result
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 

	--Detail (For returning detail for the ResultsNow detail request)
	IF @ShowDetail = 1		-- QualifyingList
		BEGIN
			Select OrderNumber
			,InvoiceNumber
			,BillTo
			,Shipper
			,Consignee
			,Bookdate
			,ShipDate
			,DeliveryDate
			,BillDate
			,PrintDate
			,TransferDate
			,LifeCycleDays
			,TotalCharges
			From #ResultsTable
			Where NOT LifeCycleDays is NULL
			Order by OrderNumber
		END

	IF @ShowDetail = 2	-- BillTo
		BEGIN
			select BillTo
			,Avg(LifeCycleDays) as AvgLifeCycleDays
			from #ResultsTable 
			group by BillTo
			order by BillTo
		END

	IF @ShowDetail = 3		-- CompleteList
		BEGIN
			Select OrderNumber
			,InvoiceNumber
			,BillTo
			,Shipper
			,Consignee
			,Bookdate
			,ShipDate
			,DeliveryDate
			,BillDate
			,PrintDate
			,TransferDate
			,LifeCycleDays
			,TotalCharges
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
			@sMetricCode = 'OrderLifecycleDays',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 900, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDECIMAL = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 1,
			@sCaption = 'Order Lifecycle Days',
			@sCaptionFull = 'Order Lifecycle Days',
			@sPROCEDUREName = 'Metric_OrderLifecycleDays',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'

	*/

GO
GRANT EXECUTE ON  [dbo].[Metric_OrderLifecycleDays] TO [public]
GO
