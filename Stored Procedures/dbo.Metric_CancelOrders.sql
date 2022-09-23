SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_CancelOrders] (
	--<step note="Standard Metric Parameters">
	@Result decimal(20, 5) OUTPUT, --Value of metric for the time frame passed
	@ThisCount decimal(20, 5) OUTPUT, --Numerator of the daily metric calculation
	@ThisTotal decimal(20, 5) OUTPUT, -- Denominator of the daily metric calculation
	@DateStart datetime, --Start date of metric calculation time frame
	@DateEnd datetime, --End date of metric calculation time frame
	@UseMetricParms int, --Use Metric Parm Flag
	@ShowDetail int, --Show detail flag
	--</step>

	--<step note="Additional/Optional Parameters">
	@StatusList VARCHAR(100) = 'CAN', --orderheader order status to include in calculation (ord_status)
	@OnlyRevClass1List VARCHAR(128) ='', --ord_revtype1
	@OnlyRevClass2List VARCHAR(128) ='', --ord_revtype2
	@OnlyRevClass3List VARCHAR(128) ='', --ord_revtype3
	@OnlyRevClass4List VARCHAR(128) =''  --ord_revtype4
	--</step>
	)
AS

	SET NOCOUNT ON  -- PTS46367
--<step note="Metric Initialization">
	--<step note="For use to automatically generate new metric item">

		/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
		<METRIC-INSERT-SQL>
	
		EXEC MetricInitializeItem
			@sMetricCode = 'CancelOrders',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 109, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDecimal = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 0,
			@sCaption = 'Turndowns',
			@sCaptionFull = 'Percent of loads turned down',
			@sProcedureName = 'Metric_CancelOrders',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'
		</METRIC-INSERT-SQL>
	*/

	--</step>
--</step>

--<step note="Standard Parameter Initialization">
	SET @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	SET @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	SET @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	SET @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
	SET @StatusList = ',' + ISNULL(@StatusList,'') + ','
--</step>

	-- DISPATCH 9: Percentage of loads turned down
--<step note="Create Temp Tables">
	CREATE TABLE #orderheader (	ord_hdrnumber INT, 
								ord_completiondate DATETIME, 
								ord_bookdate DATETIME, 
								ord_status VARCHAR(6), 
								ord_fromorder VARCHAR(12),
								ord_billto VARCHAR(8), 
								ord_shipper VARCHAR(8), 
								ord_consignee VARCHAR(8), 
								ord_terms VARCHAR(6), 
								ord_totalweight DECIMAL(20, 5),
								ord_refnum VARCHAR(30), 
								cmd_code VARCHAR(8), 
								ord_totalpieces DECIMAL(20, 5)
								)

--<step note="Insert orders according to rev type and completion date">
	INSERT INTO #orderheader 
	SELECT 	ord_hdrnumber, 
		ord_completiondate, 
		ord_bookdate, 
		ord_status, 
		ord_fromorder, 
		ord_billto, 
		ord_shipper, 
		ord_consignee, 
		ord_terms, 
		ord_totalweight, 
		ord_refnum, 
		cmd_code, 
		ord_totalpieces
	FROM orderheader WITH (NOLOCK) 
	WHERE ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)

--<\step>

--<step note="Set Numerator equal to count of orders with Order Status of parameter">
	SELECT @ThisCount = CONVERT(decimal(20, 5), COUNT(*)) FROM #orderheader 
		WHERE (@StatusList =',,' or CHARINDEX(',' + RTRIM( ord_status ) + ',', @StatusList) >0)
--<\step>

--<step note="Set Denominator equal to count of all orders">
	SELECT @ThisTotal = CONVERT(decimal(20, 5), COUNT(*)) FROM #orderheader 
--<\step>

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	IF (@ShowDetail=1)
	BEGIN
		SELECT 
			'TurnDownStatusList=' + @StatusList,
			IsTurnDown = (CASE WHEN (@StatusList =',,' or CHARINDEX(',' + RTRIM( ord_status ) + ',', @StatusList) >0) THEN 'Y' ELSE 'N' END),
			*
		FROM #orderheader
		ORDER BY ord_status
	END



GO
GRANT EXECUTE ON  [dbo].[Metric_CancelOrders] TO [public]
GO
