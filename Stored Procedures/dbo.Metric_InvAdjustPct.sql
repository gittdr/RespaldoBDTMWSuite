SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Metric_InvAdjustPct] (
	@Result decimal(20, 5) OUTPUT, @ThisCount decimal(20, 5) OUTPUT, @ThisTotal decimal(20, 5) OUTPUT, @DateStart datetime, @DateEnd datetime, @UseMetricParms int, 
	@ShowDetail int,
	@OnlyRevClass1List varchar(128) ='',
	@OnlyRevClass2List varchar(128) ='',
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) ='',
	@MetricCode varchar(255)='InvAdjustPct'
)
AS
	SET NOCOUNT ON  -- PTS46367

	--Populate default currency and currency date types
        Exec PopulateSessionIDParamatersInProc 'Revenue',@MetricCode  

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'InvAdjustPct',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 201, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Adjustment %',
		@sCaptionFull = 'Percentage of total bills that require adjustment after invoicing',
		@sProcedureName = 'Metric_InvAdjustPct',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

/*	@CountOfCleanInvoices Int OUT, @CountOfCorrectedInvoices Int OUT, @PercentageOfInvoicesCorrected decimal(20, 5) OUT
*/
	/*
		--Returns Invoicing accuracy for a date range - DM 3/3/03
		--Sample Call
		DECLARE	@LowBillDate datetime, @HighBilldate Datetime, @ReturnDetailYN CHAR(1), @CountOfCleanInvoices Int, @CountOfCorrectedInvoices Int, @PercentageOfInvoicesCorrected decimal(20, 5)
		Select @LowBillDate ='9/2/02', @HighBillDate ='9/9/02', @ReturnDetailYN ='N'
		Exec Metric_InvAdjustPct	@LowBillDate , @HighBilldate, @ReturnDetailYN ,	@CountOfCleanInvoices OUT,@CountOfCorrectedInvoices OUT, @PercentageOfInvoicesCorrected OUT
		Select	CountOfCleanInvoices=@CountOfCleanInvoices,	CountOfCorrectedInvoices = @CountOfCorrectedInvoices , PercentageOfInvoicesCorrected=@PercentageOfInvoicesCorrected 
	*/

	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
	

	-- Count the clean invoices in the date range 
	SELECT @ThisTotal = COUNT(*) 
		FROM invoiceheader i WITH (NOLOCK)
		WHERE ivh_billdate >= @DateStart AND ivh_billdate < @DateEnd
			AND NOT EXISTS(SELECT * FROM invoiceheader i2 WITH (NOLOCK)
							WHERE i2.ord_hdrnumber = i.ord_hdrnumber
								AND	i2.ivh_creditmemo='Y'
								AND	i2.ivh_applyto=i.ivh_invoicenumber
							)
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)

	
	-- Count the creditmemos in the date range
	SELECT @ThisCount = COUNT(*) FROM invoiceheader i WITH (NOLOCK)
		WHERE ivh_billdate >= @DateStart AND ivh_billdate < @DateEnd AND i.ivh_creditmemo = 'Y'
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
	
	IF (@ShowDetail = 1)
		SELECT Ord_hdrnumber, ivh_invoicenumber, ivh_applyto, Ivh_creditMemo IsCreditMemo,
			IsReversed =
			 	(CASE WHEN (SELECT COUNT(*) FROM invoiceheader i2 WITH (NOLOCK) WHERE i2.Ord_hdrnumber = i.ord_hdrnumber AND i2.ivh_applyto=i.ivh_invoicenumber
							AND i2.ivh_creditmemo='Y')>0 THEN 'Y'
					ELSE 'N' END),
			--English
			--ivh_charge, ivh_totalCharge, 
			convert(money,IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as ivh_charge,
			convert(money,IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as ivh_totalCharge,
			ivh_billto, ivh_user_id1, ivh_user_id2
		FROM invoiceheader i WITH (NOLOCK)
		WHERE ivh_billdate >= @DateStart and ivh_billdate < @DateEnd
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)

		ORDER BY Ord_hdrnumber, ivh_invoicenumber

GO
GRANT EXECUTE ON  [dbo].[Metric_InvAdjustPct] TO [public]
GO
