SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Metric_OrdAccuracy] 
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
	@OnlyBookedByList varchar(128)='',
	@OnlyBilltoIDList	varchar(128) ='',
	@ExcludeBilltoIDList	varchar(128) =''
)

AS

SET NOCOUNT ON

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'OrdAccuracy',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 402, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Order Accuracy',
		@sCaptionFull = 'Percentage of orders with reference numbers, shipper, consignee, and due date',
		@sProcedureName = 'Metric_OrdAccuracy',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

	-- ORDER MANAGEMENT 2: Order Accuracy
		-- Percentage of orders with reference numbers, shipper, consignee, and due date.
	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	Set @OnlyRegionList= ',' + ISNULL(@OnlyRegionList,'') + ','	
	Set @OnlyBookedByList= ',' + ISNULL(@OnlyBookedByList,'') + ','	

	Set @OnlyBilltoIDList= ',' + ISNULL(@OnlyBilltoIDList,'') + ','
	Set @ExcludeBilltoIDList= ',' + ISNULL(@ExcludeBilltoIDList,'') + ','
	
	DECLARE @NUMBER_OF_COMPARES int

	CREATE TABLE #stats (note varchar(30) NULL, iVal int NULL, fVal decimal(20, 5) NULL)
	CREATE TABLE #invoiceheader (	ivh_hdrnumber int, 
									ivh_invoicenumber varchar(12), 
									ord_hdrnumber varchar(10), 
									ivh_printdate datetime, 
									ivh_billdate datetime,
									ivh_billto varchar(8), 
									ivh_shipper varchar(8), 
									ivh_consignee varchar(8), 
									ivh_terms varchar(3), 
									ivh_totalweight decimal(20, 5), -- Noted: ivh.terms=CHAR(3) versus ord.terms=VARCHAR(6)
									ivh_ref_number varchar(30), 
									ivh_order_cmd_code varchar(8), 
									ivh_totalpieces decimal(20, 5)
								)

	-- *******************************
	-- Initialize the #invoiceheader table (temporary) to be used for calculations.
	INSERT INTO #invoiceheader 
	SELECT	ivh_hdrnumber, 
			ivh_invoicenumber, 
			ord_hdrnumber, 
			ivh_printdate, 
			ivh_billdate, 
			ivh_billto, 
			ivh_shipper, 
			ivh_consignee, 
			ivh_terms, 
			ivh_totalweight, 
			ivh_ref_number, 
			ivh_order_cmd_code, 
			ivh_totalpieces
	FROM invoiceheader WITH (NOLOCK) 
	WHERE ivh_billdate >= @DateStart AND ivh_billdate < @DateEnd
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
		AND (@OnlyBilltoIDList =',,' or CHARINDEX(',' + RTRIM( ivh_Billto ) + ',', @OnlyBilltoIDList) >0)
		AND (@ExcludeBilltoIDList =',,' or NOT CHARINDEX(',' + RTRIM( ivh_Billto ) + ',', @ExcludeBilltoIDList) >0)

	-- *******************************	

	SELECT @NUMBER_OF_COMPARES = 8

	DELETE #stats

	INSERT INTO #stats (note, iVal)
	SELECT o.ord_hdrnumber, CASE WHEN o.ord_billto = i.ivh_billto THEN 1 ELSE 0 END
					+ CASE WHEN o.ord_shipper = i.ivh_shipper THEN 1 ELSE 0 END
					+ CASE WHEN o.ord_consignee = i.ivh_consignee THEN 1 ELSE 0 END
					+ CASE WHEN o.ord_terms = i.ivh_terms THEN 1 ELSE 0 END
					+ CASE WHEN o.ord_totalweight = i.ivh_totalweight THEN 1 ELSE 0 END
					+ CASE WHEN o.ord_refnum = i.ivh_ref_number THEN 1 ELSE 0 END
					+ CASE WHEN o.cmd_code = i.ivh_order_cmd_code THEN 1 ELSE 0 END
					+ CASE WHEN o.ord_totalpieces = i.ivh_totalpieces THEN 1 ELSE 0 END 
	FROM orderheader o WITH (NOLOCK), #invoiceheader i  	-- Doesn't it make sense to base results on invoiced today instead of completed today?
	WHERE o.ord_hdrnumber = i.ord_hdrnumber 
		AND i.ivh_hdrnumber = (SELECT MAX(ivh_hdrnumber) FROM #invoiceheader WHERE ord_hdrnumber = o.ord_hdrnumber)
		AND (@OnlyBookedByList =',,' or CHARINDEX(',' + RTRIM( ord_bookedby ) + ',', @OnlyBookedByList) >0)
		AND (@OnlyRegionList =',,' or CHARINDEX(',' + RTRIM( ord_originregion1 ) + ',', @OnlyRegionList) >0)
		

	SELECT @ThisCount = SUM(iVal * 1.0), @ThisTotal = @NUMBER_OF_COMPARES * COUNT(note) FROM #stats	
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


	IF @ShowDetail = 1
	BEGIN
		SELECT Orden = o.ord_hdrnumber, CASE WHEN o.ord_billto <> i.ivh_billto THEN 'Cliente'
					WHEN o.ord_shipper <> i.ivh_shipper THEN 'Origen'
					WHEN o.ord_consignee <> i.ivh_consignee THEN 'Destino'
					WHEN o.ord_terms <> i.ivh_terms THEN 'Terminos'
					WHEN o.ord_totalweight <> i.ivh_totalweight THEN 'Peso Total'
					WHEN o.ord_refnum <> i.ivh_ref_number THEN 'Refencia'
					WHEN o.cmd_code <> i.ivh_order_cmd_code THEN 'Codigo CMD'
					WHEN o.ord_totalpieces <> i.ivh_totalpieces THEN 'Total Piezas'
					ELSE '' END AS Modificacion					
		FROM orderheader o WITH (NOLOCK), #invoiceheader i  	-- Doesn't it make sense to base results on invoiced today instead of completed today?
		WHERE o.ord_hdrnumber = i.ord_hdrnumber 
			AND i.ivh_hdrnumber = (SELECT MAX(ivh_hdrnumber) FROM #invoiceheader WHERE ord_hdrnumber = o.ord_hdrnumber)
			AND (@OnlyBookedByList =',,' or CHARINDEX(',' + RTRIM( ord_bookedby ) + ',', @OnlyBookedByList) >0)
			AND (@OnlyRegionList =',,' or CHARINDEX(',' + RTRIM( ord_originregion1 ) + ',', @OnlyRegionList) >0)
			AND (CASE WHEN o.ord_billto <> i.ivh_billto THEN 'Cliente'
					WHEN o.ord_shipper <> i.ivh_shipper THEN 'Origen'
					WHEN o.ord_consignee <> i.ivh_consignee THEN 'Destino'
					WHEN o.ord_terms <> i.ivh_terms THEN 'Terminos'
					WHEN o.ord_totalweight <> i.ivh_totalweight THEN 'Peso Total'
					WHEN o.ord_refnum <> i.ivh_ref_number THEN 'Referencia'
					WHEN o.cmd_code <> i.ivh_order_cmd_code THEN 'Codigo CMD'
					WHEN o.ord_totalpieces <> i.ivh_totalpieces THEN 'Total Piezas'
					ELSE '' END) <> ''

	END

GO
GRANT EXECUTE ON  [dbo].[Metric_OrdAccuracy] TO [public]
GO
