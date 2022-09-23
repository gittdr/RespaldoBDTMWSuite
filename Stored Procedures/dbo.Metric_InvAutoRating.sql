SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Metric_InvAutoRating] (
	@Result decimal(20, 5) OUTPUT, @ThisCount decimal(20, 5) OUTPUT, @ThisTotal decimal(20, 5) OUTPUT, @DateStart datetime, @DateEnd datetime, @UseMetricParms int, 
	@ShowDetail int,
	@OnlyRevClass1List varchar(128) ='',
	@OnlyRevClass2List varchar(128) ='',
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) ='',
	@MetricCode varchar(255)='InvAutoRating'
)
AS
	SET NOCOUNT ON  -- PTS46367

	--Populate default currency and currency date types
        Exec PopulateSessionIDParamatersInProc 'Revenue',@MetricCode  

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'InvAutoRating',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 202, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Adjustment %',
		@sCaptionFull = 'Percentage of total orders auto-rated at invoicing',
		@sProcedureName = 'Metric_InvAutoRating',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/
	/* TESTER
	DECLARE @Result decimal(20, 5), @ThisCount decimal(20, 5), @ThisTotal decimal(20, 5), @DateStart datetime, @DateEnd datetime
	EXEC Metric_InvAutoRating @Result OUTPUT, @ThisCount OUTPUT, @ThisTotal OUTPUT, '10/1/2002', '10/19/2002', 1, 1
	select @Result, @ThisTotal, @ThisCount
	*/

	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	-- Count the clean invoices in the date range
	SELECT @ThisTotal = COUNT(*) FROM invoiceheader i WITH (NOLOCK)
		WHERE ivh_billdate >= @DateStart AND ivh_billdate < @DateEnd
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)

	
	SELECT @ThisCount = COUNT(*) FROM invoiceheader i WITH (NOLOCK)
		WHERE ivh_billdate >= @DateStart AND ivh_billdate < @DateEnd
			AND i.Tar_Number IS NOT NULL AND i.tar_number > ''
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
	
	IF (@ShowDetail = 1)
		SELECT ord_hdrnumber, ivh_invoicenumber, Tar_number, 
				tar_tarriffnumber = (SELECT tar_tarriffnumber FROM tariffheader TH WITH (NOLOCK) WHERE TH.tar_number= i.tar_number),
				tar_tariffitem, Ivh_creditMemo IsCreditMemo, 
				--English
				--ivh_charge, ivh_totalCharge, 
				convert(money,IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as ivh_charge,
				convert(money,IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as ivh_totalCharge,
				ivh_billto, ivh_user_id1, ivh_user_id2
		FROM invoiceheader i WITH (NOLOCK)
		WHERE 	ivh_billdate >= @DateStart AND ivh_billdate < @DateEnd
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)

		ORDER BY ord_hdrnumber, ivh_invoicenumber

GO
GRANT EXECUTE ON  [dbo].[Metric_InvAutoRating] TO [public]
GO
