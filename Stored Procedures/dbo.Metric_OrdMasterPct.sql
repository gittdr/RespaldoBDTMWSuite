SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_OrdMasterPct] (
	@Result decimal(20, 5) OUTPUT, @ThisCount decimal(20, 5) OUTPUT, @ThisTotal decimal(20, 5) OUTPUT, @DateStart datetime, @DateEnd datetime, @UseMetricParms int, 
	@ShowDetail int,
	@OnlyRevClass1List varchar(128) ='',
	@OnlyRevClass2List varchar(128) ='',
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) =''
	
)
AS
	SET NOCOUNT ON  -- PTS46367

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'OrdMasterPct',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 107, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Master Orders %',
		@sCaptionFull = 'Percentage of total orders created using master order templates',
		@sProcedureName = 'Metric_OrdMasterPct',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

	-- ORDER MANAGEMENT 7: Master Orders Percentage
		-- Percentage of copied orders from master orders ONLY

	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	CREATE TABLE #orderheader (ord_hdrnumber int, ord_completiondate datetime, ord_bookdate datetime, ord_status varchar(6), ord_fromorder varchar(12),
								ord_billto varchar(8), ord_shipper varchar(8), ord_consignee varchar(8), ord_terms varchar(6), ord_totalweight decimal(20, 5),
								ord_refnum varchar(30), cmd_code varchar(8), ord_totalpieces decimal(20, 5)
								)

	-- *******************************
	-- Initialize the #orderheader table (temporary) to be used for many calculations.
	INSERT INTO #orderheader 
	SELECT ord_hdrnumber, ord_completiondate, ord_bookdate, ord_status, ord_fromorder, ord_billto, ord_shipper, ord_consignee, ord_terms, ord_totalweight, ord_refnum, cmd_code, ord_totalpieces
		FROM orderheader WITH (NOLOCK) 
	WHERE ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd
		and ord_status in ('CMP','DSP','STD','PLN')  
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)

	-- *******************************	

	SELECT @ThisCount = CONVERT(decimal(20, 5), COUNT(*)) FROM #orderheader WHERE ord_fromorder IN (SELECT ord_number FROM orderheader WITH (NOLOCK) WHERE ord_status = 'MST')
	SELECT @ThisTotal = CONVERT(decimal(20, 5), COUNT(*)) from #orderheader 
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	/*
		-- Percentage of copied orders INCLUDING from master orders.
		SELECT @Count = CONVERT(decimal(20, 5), COUNT(*)) FROM #orderheader WHERE ord_fromorder IS NOT NULL
		SELECT @Total = CONVERT(decimal(20, 5), COUNT(*)) FROM #orderheader 
		SELECT 'ORDER MANAGEMENT #7a: Copied orders percentage including masters: ' + CONVERT(varchar(30), CASE @Total WHEN 0 THEN 0 ELSE 100.0 * @Count / @Total END) 
	*/

GO
GRANT EXECUTE ON  [dbo].[Metric_OrdMasterPct] TO [public]
GO
