SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[Metric_UnbilledPctLastXDays]
	(	
		--Standard Parameters
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart DATETIME, 
		@DateEnd DATETIME, 
		@UseMetricParms INT, 
		@ShowDetail INT,
		
		--Additional/Optional Parameters
		@NumDaysBack INT =21,
		@InvoiceStatusListThatMeansBilled VARCHAR(128)='RTP,PRN,XFR,PRO',
		@OnlyRevClass1List VARCHAR(128) ='',
		@OnlyRevClass2List VARCHAR(128) ='',
		@OnlyRevClass3List VARCHAR(128) ='',
		@OnlyRevClass4List VARCHAR(128) ='',
		@OnlyBillToIDList VARCHAR(128) ='',
		@ExcludeBillToIDList VARCHAR(128) =''
	)

AS
	SET NOCOUNT ON  -- PTS46367

	--Standard Metric Initialization
	/*	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'UnbilledPctLastXDays', 
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 204, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Unbilled % Past 7 Days',
		@sCaptionFull = 'Unbilled PCT Last 7 Days',
		@sProcedureName = 'Metric_UnbilledPctLastXDays',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
	*/
	
	--Metric Specific Variables
	DECLARE @CountOfOrders INT 
	DECLARE @CountOfOrdersBilled INT 
	DECLARE @PercentageOfOrdersInvoiced FLOAT 
	
	DECLARE @LowDelvDate DATETIME
	DECLARE @HighDelvDate DATETIME
	
	--Standard Parameter Initialization
	SET @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	SET @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	SET @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	SET @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	SET @OnlyBillToIDList= ',' + ISNULL(@OnlyBillToIDList,'') + ','
	SET @ExcludeBillToIDList= ',' + ISNULL(@ExcludeBillToIDList,'') + ','

	SET @InvoiceStatusListThatMeansBilled	= ',' + ISNULL(@InvoiceStatusListThatMeansBilled,'') + ','
	
	SET @HighDelvDate = CONVERT(DATETIME,CEILING(CONVERT(float,Getdate())))
	SET @LowDelvDate = Dateadd(d, -@NumDaysBack,@HighDelvDate)
	SET @PercentageOfOrdersInvoiced = 0
	
	SET @CountOfOrders =	(
								SELECT COUNT(*) 
								FROM orderheader o (NOLOCK)
								WHERE ord_Completiondate BETWEEN @LowDelvDate AND @HighDelvDate 
									AND ord_status='CMP' 
									AND ord_invoicestatus in  ('AVL', 'PPD','PND')
									AND (@OnlyRevClass1List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
									AND (@OnlyRevClass2List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
									AND (@OnlyRevClass3List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
									AND (@OnlyRevClass4List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
									AND (@OnlyBillToIDList =',,' OR CHARINDEX(',' + RTRIM( ord_billto ) + ',', @OnlyBillToIDList) >0)
									AND (@ExcludeBillToIDList =',,' OR NOT CHARINDEX(',' + RTRIM( ord_billto ) + ',', @ExcludeBillToIDList) >0)
							)
	
	SET @CountOfOrdersBilled =	(
									SELECT COUNT(DISTINCT ord_hdrnumber) 
									FROM Invoiceheader i (NOLOCK)
									WHERE 	ivh_deliverydate BETWEEN @LowDelvDate AND @HighDelvDate 
										AND ivh_invoicestatus in ('PRN','PRO','XFR')	
										AND (@InvoiceStatusListThatMeansBilled =',,' OR CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusListThatMeansBilled) >0)
										AND (@OnlyRevClass1List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
										AND (@OnlyRevClass2List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
										AND (@OnlyRevClass3List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
										AND (@OnlyRevClass4List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
										AND (@OnlyBillToIDList =',,' OR CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @OnlyBillToIDList) >0)
										AND (@ExcludeBillToIDList =',,' OR NOT CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToIDList) >0)
								)
	
	IF (@CountOfOrders>0) 
		BEGIN
			SET @PercentageOfOrdersInvoiced = CONVERT(Float,@CountOfOrdersBilled) / CONVERT(Float,@CountOfOrders)
		END
	
	IF (@ShowDetail=1)
		BEGIN
			SELECT	Ord_hdrnumber,
					Ord_invoicestatus,
					ivh_invoicenumber =	(
											SELECT min(ivh_invoicenumber) 
											FROM invoiceheader i (NOLOCK)
											WHERE i.Ord_hdrnumber=o.ord_hdrnumber
										),
					Ord_shipper,
					OriginCity= 	(
										SELECT cty_nmstct 
										FROM city (NOLOCK)
										WHERE ord_origincity=cty_code
									),
					ord_startdate,	
					ord_consignee,
					DestCity= 	(
									SELECT cty_nmstct 
									FROM city (NOLOCK)
									WHERE ord_destcity=cty_code
								),
					ord_completiondate
			FROM Orderheader o (NOLOCK)
			WHERE 	ord_Completiondate BETWEEN @LowDelvDate AND @HighDelvDate 
				AND ord_status='CMP' 
				AND ord_invoicestatus in  ('AVL', 'PPD','PND')
				AND (@OnlyRevClass1List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
				AND (@OnlyRevClass2List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
				AND (@OnlyRevClass3List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
				AND (@OnlyRevClass4List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
				AND (@OnlyBillToIDList =',,' OR CHARINDEX(',' + RTRIM( ord_billto ) + ',', @OnlyBillToIDList) >0)
				AND (@ExcludeBillToIDList =',,' OR NOT CHARINDEX(',' + RTRIM( ord_billto ) + ',', @ExcludeBillToIDList) >0)
		END

	-- NO BACKFILL. Find old data if present
	IF (abs(DateDiff(d,Getdate(),@DateStart))>1)
		BEGIN
			SET @ThisTotal= 	(	
									SELECT DailyTotal 
									FROM MetricDetail (NOLOCK)
									WHERE MetricCode='Metric_UnbilledPctLastXDays' 
										AND PlainDate =@DateStart
								)
			SET @ThisCount= 	(
									SELECT DailyCount 
									FROM MetricDetail (NOLOCK)
									WHERE MetricCode='Metric_UnbilledPctLastXDays' 
										AND PlainDate =@DateStart
								)
		END
	ELSE
		BEGIN
			SELECT @ThisTotal = @CountOfOrders
			SELECT @ThisCount = @CountOfOrdersBilled
		END

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

GO
GRANT EXECUTE ON  [dbo].[Metric_UnbilledPctLastXDays] TO [public]
GO
