SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_OrdCSRAutoRating] 
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
	@OnlyRegionList varchar(128)='',
	@OnlyBookedByList varchar(128)=''	
)

AS

SET NOCOUNT ON
/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'OrdCSRAutoRating',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 403, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'CSR Auto-rating',
		@sCaptionFull = 'Percentage of orders rated at point of order entry with accessorial charges by customer service rep (CSR)',
		@sProcedureName = 'Metric_OrdCSRAutoRating',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

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
	
	Set @OnlyRegionList= ',' + ISNULL(@OnlyRegionList,'') + ','	
	Set @OnlyBookedByList= ',' + ISNULL(@OnlyBookedByList,'') + ','	
	
	SELECT @ThisTotal = COUNT(*) 
	FROM orderheader WITH (NOLOCK)
	WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
		AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
		AND (@OnlyBookedByList =',,' or CHARINDEX(',' + RTRIM( ord_bookedby ) + ',', @OnlyBookedByList) >0)
		AND (@OnlyRegionList =',,' or CHARINDEX(',' + RTRIM( ord_originregion1 ) + ',', @OnlyRegionList) >0)
		
	SELECT @ThisCount = COUNT(*) 
	FROM orderheader WITH (NOLOCK)
	WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
		AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
		AND	tar_tarriffnumber IS NOT NULL AND tar_tarriffnumber <> 'UNKNOWN' 
		AND tar_tarriffnumber <> ''
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
		AND (@OnlyBookedByList =',,' or CHARINDEX(',' + RTRIM( ord_bookedby ) + ',', @OnlyBookedByList) >0)
		AND (@OnlyRegionList =',,' or CHARINDEX(',' + RTRIM( ord_originregion1 ) + ',', @OnlyRegionList) >0)

	IF @ShowDetail = 1
	BEGIN
		SELECT ord_hdrnumber, Rated = CASE WHEN ISNULL(tar_tarriffnumber, '') <> '' AND tar_tarriffnumber <> 'UNKNOWN' THEN 'Yes' Else 'No' End
		FROM orderheader WITH (NOLOCK)
		WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
			AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
			AND (@OnlyBookedByList =',,' or CHARINDEX(',' + RTRIM( ord_bookedby ) + ',', @OnlyBookedByList) >0)
			AND (@OnlyRegionList =',,' or CHARINDEX(',' + RTRIM( ord_originregion1 ) + ',', @OnlyRegionList) >0)
		ORDER BY CASE WHEN ISNULL(tar_tarriffnumber, '') <> '' AND tar_tarriffnumber <> 'UNKNOWN' THEN 'Yes' Else 'No' End,
			ord_hdrnumber

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

GO
GRANT EXECUTE ON  [dbo].[Metric_OrdCSRAutoRating] TO [public]
GO
