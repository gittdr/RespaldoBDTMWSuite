SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_CustomerBalance] 
	(
		--Standard Parameters
		@Result DECIMAL(20, 5) OUTPUT, 
		@ThisCount DECIMAL(20, 5) OUTPUT, 
		@ThisTotal DECIMAL(20, 5) OUTPUT, 
		@DateStart DATETIME, 
		@DateEnd DATETIME, 
		@UseMetricParms INT, 
		@ShowDetail INT,
	
		--Additional/Optional Parameters
		@OnlyInvoiceStatusList VARCHAR(128) ='XFR,RTP,PRN,PRO',
		@OnlyRevClass1List VARCHAR(128) ='',
		@OnlyRevClass2List VARCHAR(128) ='',
		@OnlyRevClass3List VARCHAR(128) ='',
		@OnlyRevClass4List VARCHAR(128) ='',
		@MetricCode VARCHAR(255)='CustomerBalance',
		@RevenueFocusPercent  INT = 10
	)

AS

	SET NOCOUNT ON

	--Populate default currency and currency date types
	Exec PopulateSessionIDParamatersInProc 'Revenue',@MetricCode 

	--Standard Metric Initialization
	/*	<METRIC-INSERT-SQL>

		EXEC MetricInitializeItem
			@sMetricCode = 'CustomerBalance',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 302, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '', -- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDecimal = 0,
			@nPlusDeltaIsGood = 1,
			@nCumulative = 0,
			@sCaption = 'Number of Customers',
			@sCaptionFull = 'Number of Customers',
			@sProcedureName = 'Metric_CustomerBalance',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'
	
		</METRIC-INSERT-SQL>
	*/

	--Standard Parameter Intialization
	SET @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	SET @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	SET @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	SET @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
	SET @OnlyInvoiceStatusList= ',' + ISNULL(@OnlyInvoiceStatusList,'') + ','

	

	--Metric Temp Table Creation
	CREATE TABLE #CustomerSum	(	

									ivh_totalCharge MONEY,
									ivh_charge MONEY,
									ivh_billto VARCHAR(8) 
								)

	-- Initialize the ##CustomerSum table (temporary) to be used for calculations.
	INSERT INTO #CustomerSum 
		SELECT 		sum(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,DEFAULT,ivh_printdate,DEFAULT,DEFAULT,DEFAULT)) as ivh_totalcharge,
				sum(dbo.fnc_CONVERTcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,DEFAULT,ivh_printdate,DEFAULT,DEFAULT,DEFAULT)) as ivh_charge,
				ivh_billto 

		FROM invoiceheader WITH (NOLOCK) 
		WHERE ivh_billdate >= @DateStart AND ivh_billdate < @DateEnd
			AND (@OnlyRevClass1List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
			AND (@OnlyInvoiceStatusList =',,' OR CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @OnlyInvoiceStatusList) >0) 
		group by ivh_billto
	DECLARE @TotalRevenue MONEY
	DECLARE @RevenueFocus MONEY
	DECLARE @BillToRevenue MONEY
	DECLARE @OneBillTo VARCHAR(8)
	DECLARE @OneBillToRevenue MONEY
	DECLARE @TotalCustomers INT
	set @TotalRevenue = (SELECT sum(ivh_totalCharge) from #CustomerSum)
	set @RevenueFocus = (@TotalRevenue * @RevenueFocusPercent) / 100
	set @BillToRevenue = 0
	set @ThisTotal = 1
	set @ThisCount = 0
	DECLARE customer_cursor CURSOR FOR
	SELECT ivh_totalCharge, ivh_billto   FROM #CustomerSum
	ORDER BY ivh_totalCharge desc 
	OPEN customer_cursor 

	-- Perform the first fetch.
	FETCH NEXT FROM customer_cursor INTO @OneBillToRevenue, @OneBillTo 

-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
	WHILE @@FETCH_STATUS = 0
	BEGIN
	   Set @ThisCount = @ThisCount + 1
	   Set @BillToRevenue = @BillToRevenue + @OneBillToRevenue 
           if @BillToRevenue > @RevenueFocus BREAK
	   -- This is executed as long as the previous fetch succeeds.
	   FETCH NEXT FROM customer_cursor INTO @OneBillToRevenue, @OneBillTo 
	END

	CLOSE customer_cursor 
	DEALLOCATE customer_cursor 

	--Set the Result
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	IF (@ShowDetail=1)
		BEGIN
			SELECT 	ivh_billto as [Bill To],
				CONVERT(MONEY,ivh_totalcharge) as [Total Charge],
				CONVERT(MONEY,ivh_charge) as Charge

			FROM #CustomerSum (NOLOCK)
			ORDER BY ivh_totalCharge desc 
		End


GO
GRANT EXECUTE ON  [dbo].[Metric_CustomerBalance] TO [public]
GO
