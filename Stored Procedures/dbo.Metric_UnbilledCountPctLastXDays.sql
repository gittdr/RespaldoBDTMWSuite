SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[Metric_UnbilledCountPctLastXDays]
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
		@Mode varchar(10) = 'Billed', -- Unbilled
		@ModeType varchar(10) = 'PCT', -- COUNT
		@NumDaysBack INT =21,
		@InvoiceStatusListThatMeansBilled VARCHAR(128)='RTP,PRN,XFR,PRO',
		@OnlyRevClass1List VARCHAR(128) ='',
		@OnlyRevClass2List VARCHAR(128) ='',
		@OnlyRevClass3List VARCHAR(128) ='',
		@OnlyRevClass4List VARCHAR(128) ='',
		@OnlyDrvType1List varchar(255) ='',
		@OnlyDrvType2List varchar(255) ='',
		@OnlyDrvType3List varchar(255) ='',
		@OnlyDrvType4List varchar(255) =''
	)

AS

	SET NOCOUNT ON  -- PTS46367

/* Version History
3/2008: modified Metric_UnbilledPctLastXDays to include @Mode & @ModeType parameters allowing metric to return
		Billed Pct / Billed Count / Unbilled Pct / Unbilled Count

*/

	--Standard Metric Initialization
	/*	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'UnbilledPctLastXDays2', 
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 204, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Unbilled Past 21 Days',
		@sCaptionFull = 'Unbilled Count or Pct Last 21 Days',
		@sProcedureName = 'Metric_UnbilledCountPctLastXDays',
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
	DECLARE @CountOfOrdersUnbilled INT 
	DECLARE @PercentageOfOrdersNotInvoiced FLOAT 
	
	DECLARE @LowDelvDate DATETIME
	DECLARE @HighDelvDate DATETIME
	
	--Standard Parameter Initialization
	SET @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	SET @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	SET @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	SET @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
	Set @OnlyDrvType1List= ',' + ISNULL(@OnlyDrvType1List,'') + ','
	Set @OnlyDrvType2List= ',' + ISNULL(@OnlyDrvType2List,'') + ','
	Set @OnlyDrvType3List= ',' + ISNULL(@OnlyDrvType3List,'') + ','
	Set @OnlyDrvType4List= ',' + ISNULL(@OnlyDrvType4List,'') + ','
	SET @InvoiceStatusListThatMeansBilled	= ',' + ISNULL(@InvoiceStatusListThatMeansBilled,'') + ','
	
	SET @HighDelvDate = CONVERT(DATETIME,CEILING(CONVERT(float,Getdate())))
	SET @LowDelvDate = Dateadd(d, -@NumDaysBack,@HighDelvDate)
	SET @PercentageOfOrdersInvoiced = 0
	
	SET @CountOfOrders =	(
								SELECT COUNT(*) 
								FROM orderheader o (NOLOCK) Join manpowerprofile m (NOLOCK) on o.ord_driver1 = m.mpp_id
								WHERE ord_Completiondate BETWEEN @LowDelvDate AND @HighDelvDate 
									AND ord_status='CMP' 
									AND ord_invoicestatus in  ('AVL', 'PPD','PND')
									AND (@OnlyRevClass1List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
									AND (@OnlyRevClass2List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
									AND (@OnlyRevClass3List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
									AND (@OnlyRevClass4List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
									AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvType1List) >0)
									AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvType2List) >0)
									AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvType3List) >0)
									AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvType4List) >0)
							)
	
	SET @CountOfOrdersBilled =	(
									SELECT COUNT(DISTINCT ord_hdrnumber) 
									FROM Invoiceheader i (NOLOCK) Join manpowerprofile m (NOLOCK) on i.ivh_driver = m.mpp_id
									WHERE 	ivh_deliverydate BETWEEN @LowDelvDate AND @HighDelvDate 
										AND ivh_invoicestatus in ('PRN','PRO','XFR')	
										AND (@InvoiceStatusListThatMeansBilled =',,' OR CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusListThatMeansBilled) >0)
										AND (@OnlyRevClass1List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
										AND (@OnlyRevClass2List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
										AND (@OnlyRevClass3List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
										AND (@OnlyRevClass4List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
										AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvType1List) >0)
										AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvType2List) >0)
										AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvType3List) >0)
										AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvType4List) >0)
								)
	

	Set @CountOfOrdersUnbilled = @CountOfOrders - @CountOfOrdersBilled

	IF (@CountOfOrders>0) 
		BEGIN
			SET @PercentageOfOrdersInvoiced = CONVERT(Float,@CountOfOrdersBilled) / CONVERT(Float,@CountOfOrders)
			SET @PercentageOfOrdersNotInvoiced = CONVERT(Float,@CountOfOrdersUnbilled) / CONVERT(Float,@CountOfOrders)
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
			FROM Orderheader o (NOLOCK) Join manpowerprofile m (NOLOCK) on o.ord_driver1 = m.mpp_id
			WHERE 	ord_Completiondate BETWEEN @LowDelvDate AND @HighDelvDate 
				AND ord_status='CMP' 
				AND ord_invoicestatus in  ('AVL', 'PPD','PND')
				AND (@OnlyRevClass1List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
				AND (@OnlyRevClass2List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
				AND (@OnlyRevClass3List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
				AND (@OnlyRevClass4List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
				AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvType1List) >0)
				AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvType2List) >0)
				AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvType3List) >0)
				AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvType4List) >0)
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
			If @Mode = 'Billed'
				Begin
					If @ModeType = 'PCT'
						Begin		-- this results in % billed of trips completed in last X days
							SELECT @ThisCount = @CountOfOrdersBilled
							SELECT @ThisTotal = @CountOfOrders
						End
					Else	-- @ModeType is 'COUNT' 
						Begin		-- this results in count of trips billed of those trips completed in last X days
							SELECT @ThisCount = @CountOfOrdersBilled
							SELECT @ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 
													1 
												ELSE 
													DATEDIFF(day, @DateStart, @DateEnd) 
												END
						End
				End
			Else	-- @Mode is 'Unbilled'
				Begin
					If @ModeType = 'PCT'
						Begin		-- this results in % unbilled of trips completed in last X days
							SELECT @ThisCount = @CountOfOrdersUnbilled
							SELECT @ThisTotal = @CountOfOrders
						End
					Else	-- @ModeType is 'COUNT' 
						Begin		-- this results in count of trips unbilled of those trips completed in last X days
							SELECT @ThisCount = @CountOfOrdersUnbilled
							SELECT @ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 
													1 
												ELSE 
													DATEDIFF(day, @DateStart, @DateEnd) 
												END
						End
				End
		END

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

GO
GRANT EXECUTE ON  [dbo].[Metric_UnbilledCountPctLastXDays] TO [public]
GO
