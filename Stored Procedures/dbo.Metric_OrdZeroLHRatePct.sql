SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_OrdZeroLHRatePct] (
	@Result decimal(20, 5) OUTPUT, @ThisCount decimal(20, 5) OUTPUT, @ThisTotal decimal(20, 5) OUTPUT, @DateStart datetime, @DateEnd datetime, @UseMetricParms int, 
	@ShowDetail int,
	@OnlyRevClass1List varchar(128) ='',
	@OnlyRevClass2List varchar(128) ='',
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) ='',
	@DateUsed varchar (128) ='BOOK' -- BOOK, or DEL 
	
)
AS
	SET NOCOUNT ON  -- PTS46367

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'OrdZeroLHRatePct',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 403, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'CSR Auto-rating',
		@sCaptionFull = 'Percentage of orders with No Line Haul Charge',
		@sProcedureName = 'Metric_OrdZeroLHRatePct',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = 'Company'

	</METRIC-INSERT-SQL>
*/

	/*	@LowBookDate datetime  	='1/1/1950', --	If Default, then Start of TODAY is used, @HighBookDate Datetime 	='1/1/1950', --	If Default, then End of TODAY is used
		@OrderBookCount	int out, @OrderTariffRatedCount Int out, @OrderLHChargeDeterminedCount 	Int out,
		@OrderAccChargeCount Int out, @PercentOrdersAutoRated decimal(20, 5) out
	*/
	
	IF (@DateStart ='1/1/1950') SET @DateStart = CONVERT(datetime, FLOOR(CONVERT(decimal(20, 5), GETDATE())))
	IF (@DateEnd ='1/1/1950') Set @DateEnd = CONVERT(datetime, CEILING(CONVERT(decimal(20, 5), GETDATE())))
	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	IF @DateUsed = 'BOOK'
		BEGIN
		SELECT @ThisTotal = COUNT(*) FROM orderheader WITH (NOLOCK)
			WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
				AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
	
				AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
				AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
				AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
				AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
	
			
		SELECT @ThisCount = COUNT(*) FROM orderheader WITH (NOLOCK)
			WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
				AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
				AND ord_charge <> 0
				AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
				AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
				AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
				AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
		END
	IF @DateUsed = 'DEL'
		BEGIN
		SELECT @ThisTotal = COUNT(*) FROM orderheader WITH (NOLOCK)
			WHERE ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd
				AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
	
				AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
				AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
				AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
				AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
	
			
		SELECT @ThisCount = COUNT(*) FROM orderheader WITH (NOLOCK)
			WHERE ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd
				AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
				AND ord_charge <> 0 
				AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
				AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
				AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
				AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
		END


/*		
	SELECT @OrderLHChargeDeterminedCount = COUNT(*)	FROM orderheader
		WHERE ord_bookdate BETWEEN @DateStart AND @DateEnd
			AND	ord_status IN ('AVL','DSP','STD', 'CMP','PND')
			AND	ord_charge>0
	
	SELECT @OrderAccChargeCount = COUNT(*) FROM orderheader
		WHERE ord_bookdate BETWENN @DateStart AND @DateEnd
			AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
			AND	ord_charge > 0 
			AND ord_charge <> ord_totalcharge
*/
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END	

	IF @ShowDetail = 1
	BEGIN
		IF @DateUsed = 'BOOK'	
		BEGIN
			SELECT ord_hdrnumber, ord_charge
	
				FROM orderheader WITH (NOLOCK)
				WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
					AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
					AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
					AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
					AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
					AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
				ORDER BY ord_charge, ord_hdrnumber
		END
		IF @DateUsed = 'DEL'	
		BEGIN
			SELECT ord_hdrnumber, ord_charge
	
				FROM orderheader WITH (NOLOCK)
				WHERE ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd
					AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
					AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
					AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
					AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
					AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
				ORDER BY ord_charge, ord_hdrnumber
		END

	END






GO
GRANT EXECUTE ON  [dbo].[Metric_OrdZeroLHRatePct] TO [public]
GO
