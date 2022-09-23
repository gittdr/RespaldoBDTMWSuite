SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_Customersgained] 
	(
		--Standard Parameters
		@Result DECIMAL(20, 5) OUTPUT, 
		@ThisCount DECIMAL(20, 5) OUTPUT, 
		@ThisTotal DECIMAL(20, 5) OUTPUT, 
		@DateStart DATETIME, 
		@DateEnd DATETIME, 
		@UseMetricParms INT, 
		@ShowDetail INT,
		@MetricCode VARCHAR(255)='CustomersGained',
		
		--Additional Parameters
		@OnlyRevClass1List varchar(128) ='',
		@OnlyRevClass2List varchar(128) ='',
		@OnlyRevClass3List varchar(128) ='',
		@OnlyRevClass4List varchar(128) ='',
		@PercentAboveAverageToFlagAsgained DECIMAL(2,2) = .2 ,
		@DaysInPeriod INT = 7,
		@NumberPeriodsInHistory INT = 1,
		@RequirePeriodTrend INT = 1,
		@OnlyInvoiceStatusList VARCHAR(128)='XFR,RTP,PRN,PRO,HLD',
		@Mode VARCHAR(25) = 'Miles' --Orders
	)

AS
/* --debug
		declare @Result DECIMAL(20, 5)
		declare @ThisCount DECIMAL(20, 5)
		declare @ThisTotal DECIMAL(20, 5)

		declare @DateStart DATETIME 
		set @DateStart = '03/01/05'
		declare @DateEnd DATETIME 
		set @DateEnd = '03/02/05'
		declare @UseMetricParms INT 
		set @UseMetricParms =0
		declare @ShowDetail INT
		set @ShowDetail =1
		--Additional Parameters
		declare @OnlyRevClass1List varchar(128) 
		set @OnlyRevClass1List =''
		declare @OnlyRevClass2List varchar(128)
		set @OnlyRevClass2List =''
		declare @OnlyRevClass3List varchar(128)
		set @OnlyRevClass3List =''
		declare @OnlyRevClass4List varchar(128) 
		set @OnlyRevClass4List =''
		declare @PercentAboveAverageToFlagAsgained DECIMAL(2,2) 
		set @PercentAboveAverageToFlagAsgained = .2 
		declare @DaysInPeriod INT 
		set @DaysInPeriod = 7
		declare @NumberPeriodsInHistory INT 
		set @NumberPeriodsInHistory = 10


*/
	--Additional Parameters
	Declare	@FindAverageDateStart 	datetime
	Declare	@FindAverageDateEnd 	datetime

	Set @FindAverageDateStart = dateAdd(d,-(@DaysInPeriod * (@NumberPeriodsInHistory + 1) - 1), @DateStart)
	--Set @FindAverageDateEnd = dateAdd(d, -(@DaysInPeriod * @NumberPeriodsInHistory), @DateEnd)

	SET NOCOUNT ON

	--Populate default currency and currency date types
	Exec PopulateSessionIDParamatersInProc 'Revenue',@MetricCode 

	--Standard Metric Initialization
	/*	<METRIC-INSERT-SQL>

		EXEC MetricInitializeItem
			@sMetricCode = 'Customersgained',
			@nActive = 1,	-- 1=active, 0=inactive.
			@nSort = 302, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '', -- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDecimal = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 0,
			@sCaption = 'Customers gained',
			@sCaptionFull = 'Number of customers whos business gained by a percentage above a period average.',
			@sProcedureName = 'Metric_CustomersGained',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'
	
		</METRIC-INSERT-SQL>
	*/

	--Standard Parameter Intialization
	SET @OnlyInvoiceStatusList= ',' + ISNULL(@OnlyInvoiceStatusList,'') + ','
	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	--Metric Temp Table Creation

	CREATE TABLE #CustomerSum	(	
					billto VARCHAR(8), 
					PeriodNumber int,
					DeliverDate DateTime,
					ord_hdrnumber INT,
					MoveNumber INT,
					InvoiceOrOrder VARCHAR(1),
					TotalMiles INT
								)

	-- get the invoiced miles by customer
	INSERT INTO #CustomerSum 
		SELECT 	ivh_billto, 
			DATEDIFF (d , ivh_deliverydate, @DateEnd) / @DaysInPeriod,
			ivh_deliverydate, 
			ord_hdrnumber, /* 38007 wasn't getting the ord_number, needed for counting below */
			0,
			'I',
			SUM(ivh_totalmiles)
		FROM invoiceheader WITH (NOLOCK) 
		WHERE ivh_deliverydate >= @FindAverageDateStart AND ivh_deliverydate < @DateEnd
			AND ivh_invoicestatus <> 'HLD'
			AND (@OnlyInvoiceStatusList =',,' OR CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @OnlyInvoiceStatusList) >0) 
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
			AND ord_hdrnumber > 0
		group by ivh_billto, ivh_deliverydate, ord_hdrnumber /* 38007 needed to add ord_hdrnumber */

-- Get estimated miles from unbilled orders

	INSERT INTO #CustomerSum 
		SELECT 	ord_billto, 
			DATEDIFF (d , ord_completiondate , @DateEnd) / @DaysInPeriod, 
			ord_completiondate, 
			ord_hdrnumber,
			mov_number,
			'O',
			BillMiles =ISNULL((	
					Select SUM(ISNULL(stp_ord_mileage,0))
					From stops s (NOLOCK)
					where s.mov_number=orderheader.mov_number
						and s.ord_hdrnumber=orderheader.ord_hdrnumber
					),0)
		FROM OrderHeader WITH (NOLOCK) 
		WHERE ord_completiondate >= @FindAverageDateStart AND ord_completiondate < @DateEnd
		AND ord_status in ('CMP','DSP','STD','PLN')  
		AND ord_invoicestatus in ('AVL','PND') --available or pending for invoicing
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
		AND ord_hdrnumber > 0
		group by ord_billto, ord_completiondate,  ord_hdrnumber, mov_number


-- Create dummy Periods where no revenue was recorded for average calculations
DECLARE @iCnt INT
SET @iCnt = 0
While @iCnt < @NumberPeriodsInHistory 
BEGIN
	INSERT INTO #CustomerSum 
		SELECT DISTINCT (BillTo), 
			@iCnt, 
			null, 
			null,
			null,
			'T',
			0 
		FROM #CustomerSum
	SET @iCnt = @iCnt + 1
END

-- consolidate data by BillTo and PeriodNumber

	CREATE TABLE #CustomerSum2	(	
					billto VARCHAR(8), 
					PeriodNumber int,
					TotalMiles DECIMAL(14,1),
					CountOfOrders INT
								)


	INSERT INTO #CustomerSum2 
		SELECT 	billto, 
			PeriodNumber, 
			CONVERT(DECIMAL(14,1),SUM(TotalMiles)) AS TotalMiles,
			Count(Distinct ord_hdrnumber) as CountOfOrders
		FROM #CustomerSum WITH (NOLOCK) 
		group by billto, PeriodNumber 

	
--drop table #temp1
	CREATE TABLE #temp1	(	
				billto VARCHAR(8), 
				AvgMiles DECIMAL(14,1),
				TotalMiles DECIMAL(14,1),
				AvgOrders INT,
				TotalOrders INT
							)

	INSERT INTO #temp1
	SELECT 	BillTo, 
		AVG(TotalMiles),  
		SUM(TotalMiles),
		AVG(CountOfOrders),
		SUM(CountOfOrders)
		FROM #CustomerSum2 WITH (NOLOCK) 
		GROUP BY BillTo


	CREATE TABLE #Results	(	
				billto VARCHAR(8), 
				AvgMiles DECIMAL(14,1),
				TotalMiles DECIMAL(14,1),
				AvgOrders INT,
				TotalOrders INT,
				ActivityPercmoreThanNorm INT,
				ActivityPercMoreThanNormOrder INT,
				MilesForLastPeriod INT,
				Miles2ndToLastPeriod INT,
				Miles3rdToLastPeriod INT,
				Miles4rdToLastPeriod INT,
				OrdersForLastPeriod INT,
				Orders2ndToLastPeriod INT,
				Orders3rdToLastPeriod INT,
				Orders4rdToLastPeriod INT
							)


	INSERT INTO #Results	
	SELECT BillTo, CONVERT(INT, AvgMiles), CONVERT(INT, TotalMiles), 
		AvgOrders, TotalOrders,
		ActivityPercmoreThanNorm = (SELECT COUNT(*)
			FROM #CustomerSum2 
			WHERE #temp1.BillTo = #CustomerSum2.BillTo
			AND	PeriodNumber < @RequirePeriodTrend 
			AND	#CustomerSum2.TotalMiles > (#temp1.AvgMiles * (1 + @PercentAboveAverageToFlagAsgained)) 
				),
		ActivityPercmoreThanNormOrder = (SELECT COUNT(*)
			FROM #CustomerSum2 
			WHERE #temp1.BillTo = #CustomerSum2.BillTo
			AND	PeriodNumber < @RequirePeriodTrend 
			AND	#CustomerSum2.CountOfOrders > (#temp1.AvgOrders * (1 + @PercentAboveAverageToFlagAsgained)) 
				),
		MilesForLastPeriod = (SELECT CONVERT(INT, TotalMiles)
					FROM #CustomerSum2 
					WHERE #temp1.BillTo = #CustomerSum2.BillTo
						AND PeriodNumber=0 --	RevPeriodOrder = 1 
					),
		Miles2ndToLastPeriod = (SELECT CONVERT(INT, TotalMiles)
					FROM #CustomerSum2 
					WHERE #temp1.BillTo = #CustomerSum2.BillTo
						AND PeriodNumber=1 --	RevPeriodOrder = 2 
					),
		Miles3rdToLastPeriod = (SELECT CONVERT(INT, TotalMiles)
					FROM #CustomerSum2 
					WHERE #temp1.BillTo = #CustomerSum2.BillTo
						AND  PeriodNumber=2 --	RevPeriodOrder = 3
					),
		Miles4rdToLastPeriod = (SELECT CONVERT(INT, TotalMiles)
					FROM #CustomerSum2 
					WHERE #temp1.BillTo = #CustomerSum2.BillTo
						AND  PeriodNumber=3 --	RevPeriodOrder = 3
					),
		OrdersForLastPeriod = (SELECT CONVERT(INT, CountOfOrders)
					FROM #CustomerSum2 
					WHERE #temp1.BillTo = #CustomerSum2.BillTo
						AND PeriodNumber=0 --	RevPeriodOrder = 1 
					),
		Orders2ndToLastPeriod = (SELECT CONVERT(INT, CountOfOrders)
					FROM #CustomerSum2 
					WHERE #temp1.BillTo = #CustomerSum2.BillTo
						AND PeriodNumber=1 --	RevPeriodOrder = 2 
					),
		Orders3rdToLastPeriod = (SELECT CONVERT(INT, CountOfOrders)
					FROM #CustomerSum2 
					WHERE #temp1.BillTo = #CustomerSum2.BillTo
						AND  PeriodNumber=2 --	RevPeriodOrder = 3
					),
		Orders4rdToLastPeriod = (SELECT CONVERT(INT, CountOfOrders)
					FROM #CustomerSum2 
					WHERE #temp1.BillTo = #CustomerSum2.BillTo
						AND  PeriodNumber=3 --	RevPeriodOrder = 3
					)

		FROM #temp1



	SELECT @ThisTotal = 1
	
	IF @Mode = 'Miles'
		SELECT @ThisCount = (SELECT COUNT(*) FROM #Results WHERE ActivityPercmoreThanNorm = @RequirePeriodTrend)
	ELSE
		SELECT @ThisCount = (SELECT COUNT(*) FROM #Results WHERE ActivityPercmoreThanNormOrder = @RequirePeriodTrend)
		
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
	
	IF (@ShowDetail = 1) 
	BEGIN
		if @Mode='Miles'
			SELECT 	cmp_name , 
				AvgMiles ,
				TotalMiles ,
				MilesForLastPeriod as MostRecentPeriod,
				Miles2ndToLastPeriod as OnePeriodBack ,
				Miles3rdToLastPeriod as TwoPeriodsBack,
				Miles4rdToLastPeriod as ThreePeriodsBack
			FROM #Results  join company on cmp_id = billto
			Where ActivityPercmoreThanNorm = @RequirePeriodTrend
		ELSE
			SELECT 	cmp_name , 
				AvgOrders ,
				TotalOrders ,
				OrdersForLastPeriod as MostRecentPeriod, 
				Orders2ndToLastPeriod as OnePeriodBack ,
				Orders3rdToLastPeriod as TwoPeriodsBack,
				Orders4rdToLastPeriod as ThreePeriodsBack
			FROM #Results  join company on cmp_id = billto
			Where ActivityPercmoreThanNormOrder = @RequirePeriodTrend
	END

		

	DROP TABLE #temp1
	DROP TABLE #CustomerSum
	DROP TABLE #CustomerSum2
	DROP TABLE #Results	

	SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[Metric_Customersgained] TO [public]
GO
