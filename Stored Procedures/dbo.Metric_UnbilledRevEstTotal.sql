SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[Metric_UnbilledRevEstTotal]
	(	
		--Standard Parameters
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,

		--Additional/Optional Parameters		
		@OnlyRevClass1List varchar(128) ='',
		@OnlyRevClass2List varchar(128) ='',
		@OnlyRevClass3List varchar(128) ='',
		@OnlyRevClass4List varchar(128) ='',
		@OnlyCompanyList varchar(128)='',
		@OnlyOrderStatusList varchar(128) ='CMP',
		@InvoiceStatusListToConsiderUnbilled varchar(128) ='HLD',
		@InvoiceStatusListToConsiderBilled varchar(128) ='XFR', -- NOTE XFR is ALWAYS considered billed
		@MetricCode varchar(255)='UnbilledRevEstTotal',
		@EstimatedRevenueYN char(1) = 'Y'

		-- NO BACKFILLING POSSIBLE. HAS CODE TO FIND OLD VALUE IF PRESENT
	)
AS
	SET NOCOUNT ON  -- PTS46367

	--Populate default currency and currency date types
	Exec PopulateSessionIDParamatersInProc 'Revenue',@MetricCode

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'UnbilledRevEstTotal',
		@nActive = 1,	-- 1=active, 0=inactive.
		@nSort = 203, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'CURR',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Unbilled Revenue',
		@sCaptionFull = 'Estimate unbilled revenue',
		@sProcedureName = 'Metric_UnbilledRevEstTotal',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',
		@sCategory = 'Billing'

	</METRIC-INSERT-SQL>
*/

	--Local Variables
	Declare @TotalBillMilesLast60Days FLOAT
	Declare @TotalRevenueLast60Days FLOAT
	Declare @TotalLHRevenueLast60Days FLOAT
	Declare @AverageRevPerBillMile FLOAT
	Declare @AverageLHRevPerBillMile FLOAT
	
	--Temp Order Table
	CREATE TABLE #orderheader (		
									ord_hdrnumber int, 
									ord_completiondate datetime, 
									ord_bookdate datetime, 
									ord_status varchar(6), 
									ord_invoicestatus varchar(6),
									ord_fromorder varchar(12),
									ord_billto varchar(8), 
									ord_shipper varchar(8), 
									ord_consignee varchar(8), 
									ord_terms varchar(6), 
									ord_totalweight decimal(20, 5),
									ord_refnum varchar(100), 
									cmd_code varchar(8), 
									ord_totalpieces decimal(20, 5),
									mov_number int,
									ord_Charge MONEY,
									ord_totalCharge MONEY,
									BillMiles int,
									est_ord_totalCharge Money,
									TotalChargedUsedForCalc Money
								)

	--Standard Parameter Initialization
	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
	Set @OnlyCompanyList= ',' + ISNULL(@OnlyCompanyList,'') + ','
	Set @OnlyOrderStatusList= ',' + ISNULL(@OnlyOrderStatusList,'') + ','
	Set @InvoiceStatusListToConsiderUnbilled= ',' + ISNULL(@InvoiceStatusListToConsiderUnbilled,'') + ','
	Set @InvoiceStatusListToConsiderBilled= ',' + ISNULL(@InvoiceStatusListToConsiderBilled,'') + ','

	-- Initialize the #orderheader table (temporary) to be used for many calculations.
	INSERT INTO #orderheader 
	SELECT 	ord_hdrnumber, ord_completiondate, ord_bookdate, ord_status, ord_invoicestatus,
			ord_fromorder, ord_billto, ord_shipper, ord_consignee, ord_terms, ord_totalweight, 
			ord_refnum, cmd_code, ord_totalpieces, mov_number,
			convert(money,IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as ord_Charge,
			convert(money,IsNull(dbo.fnc_convertcharge(ord_totalcharge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as ord_totalCharge,
			BillMiles =ISNULL((	
								Select SUM(ISNULL(stp_ord_mileage,0))
								From stops s (NOLOCK)
								where s.mov_number=orderheader.mov_number
									and s.ord_hdrnumber=orderheader.ord_hdrnumber
								),0),

			0 est_ord_totalCharge ,
			0 TotalChargedUsedForCalc 
	FROM orderheader WITH (NOLOCK) 
	WHERE  	ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd
		AND ord_invoicestatus <> 'XIN'
		AND NOT EXISTS	(	
							Select * 
							from invoiceheader i (NOLOCK)
							where 	i.ord_hdrnumber=orderheader.ord_hdrnumber 
							--and i.ivh_Invoicestatus='XFR'
							and (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusListToConsiderBilled ) >0)
						)
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
		AND (@OnlyCompanyList =',,' or CHARINDEX(',' + RTRIM( ord_subcompany ) + ',', @OnlyCompanyList) >0)
		AND (@OnlyOrderStatusList =',,' or CHARINDEX(',' + RTRIM( ord_status ) + ',', @OnlyOrderStatusList) >0)

	-- ADD IN ON HOLD INVOICES
	INSERT INTO #orderheader 
	SELECT 	ord_hdrnumber, ord_completiondate, ord_bookdate, ord_status, ord_invoicestatus,ord_fromorder, 
			ord_billto, ord_shipper, ord_consignee, ord_terms, ord_totalweight, ord_refnum, cmd_code, 
			ord_totalpieces, mov_number,
			convert(money,IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as ord_Charge,
			convert(money,IsNull(dbo.fnc_convertcharge(ord_totalcharge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as ord_totalCharge,
			BillMiles =ISNULL((
								Select SUM(ISNULL(stp_ord_mileage,0))
								From stops s (NOLOCK)
								where 	s.mov_number=orderheader.mov_number
									and s.ord_hdrnumber=orderheader.ord_hdrnumber
								),0),
			0 est_ord_totalCharge ,
			0 TotalChargedUsedForCalc 
	FROM orderheader WITH (NOLOCK) 
	WHERE ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd		
		--AND ord_status in ('CMP','DSP','STD','PLN')  
		--AND ord_invoicestatus ='PPD'
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
		AND (@OnlyOrderStatusList =',,' or CHARINDEX(',' + RTRIM( ord_status ) + ',', @OnlyOrderStatusList) >0)
		AND (@OnlyCompanyList =',,' or CHARINDEX(',' + RTRIM( ord_subcompany ) + ',', @OnlyCompanyList) >0)
		AND EXISTS	(	
						Select * 
						from invoiceheader i (NOLOCK)
						where 	i.ord_hdrnumber=orderheader.ord_hdrnumber 
						and i.ivh_Invoicestatus<>'XFR'
						and (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusListToConsiderUnbilled ) >0)
					)

	-- Figure AverageRevPerBillMile for estimating
	Set @TotalBillMilesLast60Days = 	(
											select sum(ISNULL(ivh_totalmiles,0))
											From Invoiceheader (NOLOCK)
											Where ivh_deliverydate between DateAdd(d,-60,@DateStart) and  @DateStart
												and (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
												AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
												AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
												AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
												AND (@OnlyCompanyList =',,' or CHARINDEX(',' + RTRIM( ivh_company ) + ',', @OnlyCompanyList) >0)
												AND ISNULL(ivh_definition,'LH')='LH'
										)	

	Set @TotalRevenueLast60Days = 		(
											select convert(money,sum(IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)))
											From Invoiceheader (NOLOCK)
											Where ivh_deliverydate between DateAdd(d,-60,@DateStart) and  @DateStart
												and (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
												AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
												AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
												AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
												AND (@OnlyCompanyList =',,' or CHARINDEX(',' + RTRIM( ivh_company ) + ',', @OnlyCompanyList) >0)
												--AND ISNULL(ivh_definition,'LH')='LH'
										)
	Set @TotalLHRevenueLast60Days =		(
											select convert(money,sum(IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)))
											From Invoiceheader (NOLOCK)
											Where ivh_deliverydate between DateAdd(d,-60,@DateStart) and  @DateStart
												and (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
												AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
												AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
												AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
												AND (@OnlyCompanyList =',,' or CHARINDEX(',' + RTRIM( ivh_company ) + ',', @OnlyCompanyList) >0)
												AND ISNULL(ivh_definition,'LH')='LH'
										)
	
	IF (@TotalBillMilesLast60Days >0)
	BEGIN
		Set @AverageRevPerBillMile = @TotalRevenueLast60Days/ @TotalBillMilesLast60Days 	
		Update #OrderHeader
			SET  est_ord_totalCharge = @AverageRevPerBillMile * BillMiles	

	END

	--IF @EstimatedRevenueYN <> 'Y'
		Update #OrderHeader
			Set TotalChargedUsedForCalc = ISNULL(ord_totalcharge,0)
			where ord_totalcharge > 0
	
	IF @EstimatedRevenueYN = 'Y'
		Update #OrderHeader
		Set TotalChargedUsedForCalc = ISNULL(est_ord_totalCharge,0)
		where isNULL(ord_totalcharge,0)=0

	SELECT @ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) 
								THEN 1 ELSE DATEDIFF(day, @DateStart, @DateEnd) END
	Set @ThisCount =(select sum(TotalChargedUsedForCalc) from #OrderHeader)

	-- NO BACKFILL. Find old data if present
	IF (abs(DateDiff(d,Getdate(),@DateStart))>1)
	BEGIN
		Set @ThisTotal= ISNULL((
									Select DailyTotal 
									from MetricDetail (NOLOCK)
									where MetricCode=@MetricCode and PlainDate =@DateStart
								),@ThisTotal)

		Set @ThisCount = ISNULL((
									Select DailyCount 
									from MetricDetail (NOLOCK)
									where MetricCode='Metric_UnbilledRevEstTotal' and PlainDate =@DateStart
								),@ThisCount)
	END

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	if (@ShowDetail=1)
	BEGIN
		Select *, 
			Convert(Money,@ThisCount) TotalUnbilledRevForSet,
			NumInvoicesCreatedFromOrder=(Select count(*) FROM Invoiceheader i (NOLOCK) where i.ord_hdrnumber=#orderheader.ord_hdrnumber), 
			InvoiceNumber=(Select Min(ivh_invoicenumber) from invoiceheader i (NOLOCK) where i.ord_hdrnumber=#orderheader.ord_hdrnumber and ivh_invoicestatus='HLD')
		FROM #orderheader
		order by ord_completiondate

	END




GO
GRANT EXECUTE ON  [dbo].[Metric_UnbilledRevEstTotal] TO [public]
GO
