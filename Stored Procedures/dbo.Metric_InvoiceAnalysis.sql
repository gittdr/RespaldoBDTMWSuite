SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_InvoiceAnalysis] 
	(
		--Standard Parameters
		@Result DECIMAL(20, 5) OUTPUT, 
		@ThisCount DECIMAL(20, 5) OUTPUT, 
		@ThisTotal DECIMAL(20, 5) OUTPUT, 
		@DateStart DATETIME, 
		@DateEnd DATETIME, 
		@UseMetricParms INT, 
		@ShowDetail INT,
		@MetricCode VARCHAR(255)='InvoiceAnalysis',

		--Additional/Optional Parameters
		@Mode CHAR(25)='Count', --Count, Revenue, Miles, RevenuePerMile, RevenuePerTractor, RevenuePerDriver, DistinctCount
		@DateType VARCHAR(100) = 'Bill', --Bill, Delivery, Transfer or Print
		@OnlyInvoiceStatusList VARCHAR(128) ='',
		@OnlyRevClass1List VARCHAR(128) ='',
		@OnlyRevClass2List VARCHAR(128) ='',
		@OnlyRevClass3List VARCHAR(128) ='',
		@OnlyRevClass4List VARCHAR(128) ='',
		@OnlyCompanyList VARCHAR(128)='',
		@OnlyTrcTerminalList VARCHAR(128)='',
		@OnlyInvoiceTypeList VARCHAR(128)='', -- A, B, C, etc.	
		@AverageOfDaysBack INT = 0,
		@OnlyBillToID VARCHAR(255)='',
		@ExcludeBillToID VARCHAR(255)=''
	)

AS

/*
		drop table #invoiceheader
		drop table #onlyinvoiceheader
		drop table #InvoiceHeaderFinal

		declare @Result DECIMAL(20, 5)
		declare @ThisCount DECIMAL(20, 5)
		declare @ThisTotal DECIMAL(20, 5)

		declare @DateStart DATETIME 
		set @DateStart = '03/01/05'
		declare @DateEnd DATETIME 
		set @DateEnd = '03/30/05'
		declare @UseMetricParms INT 
		set @UseMetricParms =0
		declare @ShowDetail INT
		set @ShowDetail =0

		--Additional/Optional Parameters
		declare @Mode CHAR(25)
		set @Mode = 'RevenuePerTractor'
		declare @DateType VARCHAR(100) 
		SET @DateType = 'Transfer' --Bill or Transfer
		declare @OnlyRevClass1List varchar (50)
		set @OnlyRevClass1List=''
		declare @OnlyRevClass2List varchar (50)
		set @OnlyRevClass2List=''
		declare @OnlyRevClass3List varchar (50)
		set @OnlyRevClass3List=''
		declare @OnlyRevClass4List varchar (50)
		set @OnlyRevClass4List=''
		declare @OnlyTrcTerminalList varchar (255)
		set @OnlyTrcTerminalList =''

		declare @OnlyInvoiceTypeList VARCHAR(128) -- A, B, C, etc.	
		set @OnlyInvoiceTypeList = ''
		declare @AverageOfDaysBack INT
		set @AverageOfDaysBack = 7
		declare @OnlyInvoiceStatusList VARCHAR(128) 
		set @OnlyInvoiceStatusList ='XFR'
	
		declare @MetricCode VARCHAR(128) 
*/

	SET NOCOUNT ON

	--Populate default currency and currency date types
	Exec PopulateSessionIDParamatersInProc 'Revenue',@MetricCode 

	--Standard Metric Initialization
	/*	<METRIC-INSERT-SQL>

		EXEC MetricInitializeItem
			@sMetricCode = 'InvoiceAnalysis',
			@nActive = 1,	-- 1=active, 0=inactive.
			@nSort = 300, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = 'CURR',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDecimal = 0,
			@nPlusDeltaIsGood = 1,
			@nCumulative = 0,
			@sCaption = 'Invoiced Amount',
			@sCaptionFull = 'Invoiced Amount',
			@sProcedureName = 'Metric_InvoiceAnalysis',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = 'Revenue'
	
		</METRIC-INSERT-SQL>
	*/

	--Standard Parameter Intialization
	SET @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	SET @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	SET @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	SET @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
	SET @OnlyInvoiceStatusList= ',' + ISNULL(@OnlyInvoiceStatusList,'') + ','
	SET @OnlyTrcTerminalList= ',' + ISNULL(@OnlyTrcTerminalList,'') + ','
	SET @OnlyInvoiceTypeList= ',' + ISNULL(@OnlyInvoiceTypeList,'') + ','
	SET @OnlyBillToID= ',' + ISNULL(@OnlyBillToID,'') + ','
	SET @ExcludeBillToID= ',' + ISNULL(@ExcludeBillToID,'') + ','
	SET @OnlyCompanyList= ',' + ISNULL(@OnlyCompanyList,'') + ','
	

	--Metric Temp Table Creation
	CREATE TABLE #invoiceheader	(	
									ivh_hdrnumber INT, 
									ivh_invoicenumber VARCHAR(12), 
									ord_hdrnumber INT, 
									ivh_charge MONEY,
									ivh_totalCharge MONEY,
									ivh_totalmiles FLOAT,
									ivh_Invoicestatus	VARCHAR(6),
									ivh_definition VARCHAR(6),
									ivh_deliverydate datetime,
									ivh_printdate DATETIME, 
									ivh_billdate DATETIME,
									ivh_billto VARCHAR(8), 
									ivh_shipper VARCHAR(8), 
									ivh_consignee VARCHAR(8), 
									ivh_terms VARCHAR(3), 
									ivh_totalweight DECIMAL(20, 5), -- Noted: ivh.terms=CHAR(3) versus ord.terms=VARCHAR(6)
									ivh_ref_number VARCHAR(30), 
									ivh_order_cmd_code VARCHAR(8), 
									ivh_totalpieces DECIMAL(20, 5),
									ivh_xferdate datetime,
									ivh_driver varchar(8),
									ivh_tractor varchar(8),
									ivh_trailer varchar(13)
								)

	-- Initialize the #invoiceheader table (temporary) to be used for calculations.
	INSERT INTO #invoiceheader 
		SELECT 	ivh_hdrnumber, 
				ivh_invoicenumber, 
				invoiceheader.ord_hdrnumber,
				CONVERT(MONEY,ISNULL(dbo.fnc_CONVERTcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,DEFAULT,ivh_printdate,DEFAULT,DEFAULT,DEFAULT),0)) as ivh_charge,
				CONVERT(MONEY,ISNULL(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,DEFAULT,ivh_printdate,DEFAULT,DEFAULT,DEFAULT),0)) as ivh_totalCharge,
				ivh_totalmiles,
				ivh_Invoicestatus,
				ivh_definition,
				ivh_deliverydate,
				ivh_printdate, 
				ivh_billdate, 
				ivh_billto, 
				ivh_shipper, 
				ivh_consignee, 
				ivh_terms, 
				ivh_totalweight, 
				ivh_ref_number, 
				ivh_order_cmd_code, 
				ivh_totalpieces,
				ivh_xferdate,
				ivh_driver,
				ivh_tractor,
				ivh_trailer
		FROM invoiceheader WITH (NOLOCK)
		WHERE 	(
					(@DateType = 'Bill' and ivh_billdate >= DateAdd(d, -@AverageOfDaysBack, @DateStart) AND ivh_billdate < @DateEnd)
					OR
					(@DateType = 'Transfer' and ivh_xferdate >= DateAdd(d, -@AverageOfDaysBack, @DateStart) AND ivh_xferdate < @DateEnd)
					OR
					(@DateType = 'Delivery' and ivh_deliverydate >= DateAdd(d, -@AverageOfDaysBack, @DateStart) AND ivh_deliverydate < @DateEnd)
					OR
					(@DateType = 'Print' and ivh_printdate >= DateAdd(d, -@AverageOfDaysBack, @DateStart) AND ivh_printdate < @DateEnd)
				)
			AND (@OnlyRevClass1List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
			AND (@OnlyInvoiceStatusList =',,' OR CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @OnlyInvoiceStatusList) >0)
			AND (@OnlyInvoiceTypeList =',,' OR CHARINDEX(',' + RTRIM( Right(ivh_invoicenumber,1) ) + ',', @OnlyInvoiceTypeList) >0)
			AND (@OnlyCompanyList =',,' OR CHARINDEX(',' + RTRIM( ivh_company ) + ',', @OnlyCompanyList) >0)
			AND (@OnlyBillToID =',,' OR CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @OnlyBillToID) >0)
			AND (@ExcludeBillToID =',,' OR NOT CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToID) >0)

			
	select distinct #Invoiceheader.ord_hdrnumber 
	into #OnlyInvoiceHeader
	from #invoiceheader 
	where (@OnlyTrcTerminalList =',,' OR CHARINDEX(',' + RTRIM( (SELECT trc_terminal FROM LegHeader L (NOLOCK) Where L.ord_hdrnumber = #invoiceheader.ord_hdrnumber) ) + ',', @OnlyTrcTerminalList) >0)

	Select #invoiceheader.*
	INTO #InvoiceHeaderFinal
	from #invoiceheader 
		join #onlyinvoiceheader on #invoiceheader.ord_hdrnumber = #onlyinvoiceheader.ord_hdrnumber

	SELECT @ThisTotal = DATEDIFF(DAY, @DateStart, @DateEnd)
	IF @ThisTotal = 0 SET @ThisTotal = 1



	IF @Mode = 'Count'
	BEGIN
		SELECT @ThisCount = (SELECT COUNT(OrdNum)  --Must have an order number to be counted.  
							FROM (	SELECT Distinct ord_hdrnumber as OrdNum 
									from #invoiceheaderFinal) xx
							) / (1 + @AverageOfDaysBack)
	END
	ELSE If @Mode = 'Revenue'
	BEGIN
		SELECT @ThisCount =	(
							SELECT SUM(ISNULL(ivh_TotalCharge,0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	/ (1 + @AverageOfDaysBack)
	END
	Else If @Mode = 'Miles'
	BEGIN
		SELECT @ThisCount =	(
							SELECT SUM(ISNULL(ivh_totalmiles,0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	/ (1 + @AverageOfDaysBack)
	END
	Else If @Mode = 'RevenuePerMile'
	BEGIN
		SELECT @ThisTotal =	(
							SELECT SUM(ISNULL(ivh_totalmiles,0)) 
							FROM #invoiceheaderFinal (NOLOCK)  
							)	
		SELECT @ThisCount =	(
							SELECT SUM(ISNULL(ivh_TotalCharge,0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	
	END
	ELSE If @Mode = 'LHRevenue'
	BEGIN
		SELECT @ThisCount =	(
							SELECT SUM(ISNULL(ivh_charge,0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							) / (1 + @AverageOfDaysBack)
	END
	ELSE If @Mode = 'LHRevenuePerMile'
	BEGIN
		SELECT @ThisTotal =	(
							SELECT SUM(ISNULL(ivh_totalmiles,0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	
		SELECT @ThisCount =	(
							SELECT SUM(ISNULL(ivh_charge,0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	
	END
	ELSE If @Mode = 'RevenuePerTractor'
	BEGIN
		SELECT @ThisTotal =	dbo.fnc_TMWRN_TractorCount(default,'','','','',@OnlyTrcTerminalList,'','','','','','','','','',@OnlyRevClass1List,	@OnlyRevClass2List,	@OnlyRevClass3List,	@OnlyRevClass4List,DateAdd(d, -@AverageOfDaysBack, @DateStart),@DateEnd,default,'Y','',default, default,default, default,default) / (1 + @AverageOfDaysBack)
		SELECT @ThisCount =	(
							SELECT SUM(ISNULL(ivh_TotalCharge,0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	/ (1 + @AverageOfDaysBack)

	END
	ELSE If @Mode = 'RevenuePerDriver'
	BEGIN
		SELECT @ThisTotal =	dbo.fnc_TMWRN_DriverCount(DEFAULT, 'active', DateAdd(d, -@AverageOfDaysBack, @DateStart), @DateEnd, '', '', '', '', '', '', '', '', '', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, @OnlyRevClass1List,@OnlyRevClass2List,@OnlyRevClass3List,@OnlyRevClass4List,DEFAULT, DEFAULT, 'Y', DEFAULT) / (1 + @AverageOfDaysBack)

		SELECT @ThisCount =	(
							SELECT SUM(ISNULL(ivh_TotalCharge,0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	/ (1 + @AverageOfDaysBack)

	END
	ELSE If @Mode = 'DistinctCount'--TN Added by DG to calculate a count of invoices not using ordernumbers - For example accessorial only invoices
	BEGIN
		SELECT @ThisCount =	(SELECT COUNT(*) FROM #invoiceheaderFinal (NOLOCK) 
							)	/ (1 + @AverageOfDaysBack)
	END

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	IF (@ShowDetail=1)
		BEGIN
			SELECT 	*, 
					CONVERT(INT,@thisTotal) TotalDaysInDateRange,
					CONVERT(MONEY,@ThisCount) TotalRevenueForDateRange
			FROM #invoiceheader (NOLOCK)
		End

GO
GRANT EXECUTE ON  [dbo].[Metric_InvoiceAnalysis] TO [public]
GO
