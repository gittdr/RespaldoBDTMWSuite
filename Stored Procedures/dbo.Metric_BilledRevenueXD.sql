SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE  PROCEDURE [dbo].[Metric_BilledRevenueXD]
	(
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,
	-- Additional / Optional Parameters
		@DateType varchar(50) = 'BillDate',				-- BillDate,PrintDate,TransferDate,OrderStart,OrderEnd
		@Numerator varchar(20) = 'Revenue',				-- Revenue, AllCount, InvoiceCount, CreditCount
		@Denominator varchar(20) = 'Day',				-- Day, AllCount, InvoiceCount, CreditCount
	-- revenue related parameters
		@InvoiceStatusList varchar(255) = '',
		@AllInvoiceCredit_AIC char(1) = 'A',			-- (A)ll transactions, Only (I)nvoices, Only (C)reditMemos
		@AllOrderMisc_AOM char(1) = 'A',				-- (A)ll transactions, Only (O)rder-related invoices, Only (M)isc invoices
		@BaseRevenueCategoryTLAFN char(1) ='T',
		@SubtractFuelSurchargeYN char(1) = 'N',
		@IncludeChargeTypeList varchar(255) = '', 
		@ExcludeChargeTypeList varchar(255)='',		 
	-- filtering parameters: revtypes
		@OnlyRevType1List varchar(255) ='',
		@OnlyRevType2List varchar(255) ='',
		@OnlyRevType3List varchar(255) ='',
		@OnlyRevType4List varchar(255) ='',
	-- filtering parameters: includes
		@OnlyBillToList varchar(255) = '',
		@OnlyShipperList varchar(255) = '',
		@OnlyConsigneeList varchar(255) = '',
		@OnlyOrderedByList varchar(255) = '',

	-- filtering parameters: excludes
		@ExcludeRevType1List varchar(255) ='',
		@ExcludeRevType2List varchar(255) ='',
		@ExcludeRevType3List varchar(255) ='',
		@ExcludeRevType4List varchar(255) ='',
		@ExcludeBillToList varchar(255) = '',
		@ExcludeShipperList varchar(255) = '',
		@ExcludeConsigneeList varchar(255) = '',
		@ExcludeOrderedByList varchar(255) = '',

		@MetricCode varchar(255)= 'BilledRevenueXD'
	)
AS

	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:KAM,2:Terminal,3:Proyecto,4:Division,5:Cliente,6:Facturas,7:Flota

	--Populate DEFAULT currency and currency date types
	EXEC PopulateSessionIDParamatersInProc 'Revenue', @MetricCode 

	SET @InvoiceStatusList = ',' + ISNULL(@InvoiceStatusList,'') + ','

	SET @OnlyRevType1List= ',' + ISNULL(@OnlyRevType1List,'') + ','
	SET @OnlyRevType2List= ',' + ISNULL(@OnlyRevType2List,'') + ','
	SET @OnlyRevType3List= ',' + ISNULL(@OnlyRevType3List,'') + ','
	SET @OnlyRevType4List= ',' + ISNULL(@OnlyRevType4List,'') + ','

	Set @OnlyBillToList= ',' + ISNULL(@OnlyBillToList,'') + ','
	Set @OnlyShipperList= ',' + ISNULL(@OnlyShipperList,'') + ','
	Set @OnlyConsigneeList= ',' + ISNULL(@OnlyConsigneeList,'') + ','
	Set @OnlyOrderedByList= ',' + ISNULL(@OnlyOrderedByList,'') + ','

	SET @ExcludeRevType1List= ',' + ISNULL(@ExcludeRevType1List,'') + ','
	SET @ExcludeRevType2List= ',' + ISNULL(@ExcludeRevType2List,'') + ','
	SET @ExcludeRevType3List= ',' + ISNULL(@ExcludeRevType3List,'') + ','
	SET @ExcludeRevType4List= ',' + ISNULL(@ExcludeRevType4List,'') + ','

	Set @ExcludeBillToList= ',' + ISNULL(@ExcludeBillToList,'') + ','
	Set @ExcludeShipperList= ',' + ISNULL(@ExcludeShipperList,'') + ','
	Set @ExcludeConsigneeList= ',' + ISNULL(@ExcludeConsigneeList,'') + ','
	Set @ExcludeOrderedByList= ',' + ISNULL(@ExcludeOrderedByList,'') + ','

	Declare @TempInvoices Table (ivh_hdrnumber int)
	
	If (@DateType = 'BillDate')
		begin
			Insert into @TempInvoices (ivh_hdrnumber)
			Select ivh_hdrnumber
			From invoiceheader (NOLOCK)
			where ivh_billdate >= @DateStart AND ivh_billdate < @DateEnd
		end
	Else If (@DateType = 'PrintDate')
		begin
			Insert into @TempInvoices (ivh_hdrnumber)
			Select ivh_hdrnumber
			From invoiceheader (NOLOCK)
			where ivh_printdate >= @DateStart AND ivh_printdate < @DateEnd
		end
	Else If (@DateType = 'TransferDate')
		begin
			Insert into @TempInvoices (ivh_hdrnumber)
			Select ivh_hdrnumber
			From invoiceheader (NOLOCK)
			where ivh_xferdate >= @DateStart AND ivh_xferdate < @DateEnd
		end
	Else If (@DateType = 'OrderStart')
		begin
			Insert into @TempInvoices (ivh_hdrnumber)
			Select ivh_hdrnumber
			From invoiceheader (NOLOCK)
			where ivh_shipdate >= @DateStart AND ivh_shipdate < @DateEnd
		end
	Else If (@DateType = 'OrderEnd')
		begin
			Insert into @TempInvoices (ivh_hdrnumber)
			Select ivh_hdrnumber
			From invoiceheader (NOLOCK)
			where ivh_deliverydate >= @DateStart AND ivh_deliverydate < @DateEnd
		end

	SELECT InvoiceNumber = IH.ivh_invoicenumber
		,CreditMemo = IsNull(IH.ivh_creditmemo,'N')
		,ord_hdrnumber = Case when IsNull(IH.ord_hdrnumber,0) = 0 then -1 * IH.ivh_hdrnumber Else IH.ord_hdrnumber End
		,OrderNumber = IsNull(OH.ord_number,'NoOrder')
		,OrderedBy = IsNull(IH.ivh_order_by,'')
		,BillTo = IsNull(IH.ivh_billto,'')
		,BillToName = IsNull(BillToCompany.cmp_name,'')
		,Shipper = IsNull(IH.ivh_shipper,'')
		,ShipperName = Convert(varchar(100),'') -- (select cmp_name from company (NOLOCK) where cmp_id = IsNull(ord_shipper,cmp_id_start))
		,ShipperLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City (NOLOCK) where City.cty_code = IH.ivh_origincity),'UNKNOWN')
		,IH.ivh_origincity
		,ShipDate = IsNull(IH.ivh_shipdate,'19500101')
		,Consignee = IsNull(IH.ivh_consignee,'')
		,ConsigneeName = Convert(varchar(100),'') -- (select cmp_name from company (NOLOCK) where cmp_id = IsNull(ord_consignee,cmp_id_end))
		,ConsigneeLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City (NOLOCK) where City.cty_code = IH.ivh_destcity),'UNKNOWN')
		,IH.ivh_destcity
		,DeliveryDate = IsNull(IH.ivh_deliverydate,'19500101')
		,RevType1 = Convert(varchar(20),IsNull(IH.ivh_revtype1,'UNKNOWN'))
		,RevType2 = Convert(varchar(20),IsNull(IH.ivh_revtype2,'UNKNOWN'))
		,RevType3 = Convert(varchar(20),IsNull(IH.ivh_revtype3,'UNKNOWN'))
		,RevType4 = Convert(varchar(20),IsNull(IH.ivh_revtype4,'UNKNOWN'))
        ,Flota = (Select  name  from  labelfile  where abbr  = (Select trc_fleet from tractorprofile where trc_number = OH.ord_tractor ) and labeldefinition = 'Fleet')
-- revenue
		,SelectedRevenue = ISNULL(dbo.fnc_TMWRN_XDRevenue('Invoice',0,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,TI.ivh_hdrnumber,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,DEFAULT,@InvoiceStatusList,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0)
		,BillMiles = Convert(float, IH.ivh_totalmiles) -- IsNull((select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = l.lgh_number),0)
		,InvoiceStatus = IH.ivh_invoicestatus
	Into #InvoiceList
	FROM @TempInvoices TI join invoiceheader IH (NOLOCK) on TI.ivh_hdrnumber = IH.ivh_hdrnumber
		Join company BillToCompany (NOLOCK) on IH.ivh_billto = BillToCompany.cmp_id
		left join orderheader OH (NOLOCK) on IH.ord_hdrnumber = OH.ord_hdrnumber
	Where (@OnlyRevType1List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype1,OH.ord_revtype1) + ',', @OnlyRevType1List) > 0)
	AND (@OnlyRevType2List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype2,OH.ord_revtype2) + ',', @OnlyRevType2list) > 0)
	AND (@OnlyRevType3List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype3,OH.ord_revtype3) + ',', @OnlyRevType3List) > 0)
	AND (@OnlyRevType4List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype4,OH.ord_revtype4) + ',', @OnlyRevType4List) > 0)

	AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype1,OH.ord_revtype1) + ',', @ExcludeRevType1List) = 0)
	AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype2,OH.ord_revtype2) + ',', @ExcludeRevType2List) = 0)
	AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype3,OH.ord_revtype3) + ',', @ExcludeRevType3List) = 0)
	AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + IsNull(IH.ivh_revtype4,OH.ord_revtype4) + ',', @ExcludeRevType4List) = 0)

	AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(IH.ivh_billto,'') + ',', @OnlyBillToList) > 0)
	AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(IH.ivh_shipper,'') + ',', @OnlyShipperList) > 0)
	AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(IH.ivh_consignee,'') + ',', @OnlyConsigneeList) > 0)
	AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(IH.ivh_order_by,'') + ',', @OnlyOrderedByList) > 0)

	AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(IH.ivh_billto,'') + ',', @ExcludeBillToList) = 0)                  
	AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(IH.ivh_shipper,'') + ',', @ExcludeShipperList) = 0)                  
	AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(IH.ivh_consignee,'') + ',', @ExcludeConsigneeList) = 0)                  
	AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(IH.ivh_order_by,'') + ',', @ExcludeOrderedByList) = 0)                  

	AND (@InvoiceStatusList =',,' or CHARINDEX(',' + IsNull(IH.ivh_invoicestatus,'') + ',', @InvoiceStatusList) > 0)		 

	-- Limit the result set to selected type of activity
	-- All or only Invoices or only CreditMemos
	If @AllInvoiceCredit_AIC = 'I'
		begin
			delete from #InvoiceList where CreditMemo = 'Y'
		end
	Else If @AllInvoiceCredit_AIC = 'C'
		begin
			delete from #InvoiceList where CreditMemo = 'N'
		end

	-- All or only Order-based invoices or only Misc Invoices
	If @AllOrderMisc_AOM = 'O'
		begin
			delete from #InvoiceList where ord_hdrnumber < 0
		end
	Else If @AllOrderMisc_AOM = 'M'
		begin
			delete from #InvoiceList where ord_hdrnumber > 0
		end

	Set @ThisCount = 
		Case 
			When @Numerator = 'Revenue' then (Select sum(SelectedRevenue) from #InvoiceList)
			When @Numerator = 'AllCount' then (Select count(InvoiceNumber) from #InvoiceList)
			When @Numerator = 'InvoiceCount' then (Select count(InvoiceNumber) from #InvoiceList where CreditMemo = 'N')
		Else -- @Numerator = 'CreditCount'
			(Select count(InvoiceNumber) from #InvoiceList where CreditMemo = 'Y')
		End

	Set @ThisTotal =
		Case
			When @Denominator = 'AllCount' then (Select COUNT(InvoiceNumber) from #InvoiceList)
			When @Denominator = 'InvoiceCount' then (Select COUNT(InvoiceNumber) from #InvoiceList where CreditMemo = 'N')
			When @Denominator = 'CreditCount' then (Select COUNT(InvoiceNumber) from #InvoiceList where CreditMemo = 'Y')
		Else -- @Denominator = 'Day'
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		End

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 

	If @ShowDetail > 0	-- get textual information we need for good data display
		Begin
			Update #InvoiceList set ShipperName = company.cmp_name
			From company (NOLOCK)
			Where #InvoiceList.Shipper = company.cmp_id 

			Update #InvoiceList set ConsigneeName = company.cmp_name
			From company (NOLOCK)
			Where #InvoiceList.Consignee = company.cmp_id 

			Update #InvoiceList set ShipperLocation = city.cty_nmstct
			From city (NOLOCK)
			Where #InvoiceList.ivh_origincity = city.cty_code

			Update #InvoiceList set ConsigneeLocation = city.cty_nmstct
			From city (NOLOCK)
			Where #InvoiceList.ivh_destcity = city.cty_code

			Update #InvoiceList set RevType1 = LF.Name
			From labelfile LF (NOLOCK)
			Where LF.labeldefinition = 'RevType1'
			AND #InvoiceList.RevType1 = LF.ABBR

			Update #InvoiceList set RevType2 = LF.Name
			From labelfile LF (NOLOCK)
			Where LF.labeldefinition = 'RevType2'
			AND #InvoiceList.RevType2 = LF.ABBR

			Update #InvoiceList set RevType3 = LF.Name
			From labelfile LF (NOLOCK)
			Where LF.labeldefinition = 'RevType3'
			AND #InvoiceList.RevType3 = LF.ABBR

			Update #InvoiceList set RevType4 = LF.Name
			From labelfile LF (NOLOCK)
			Where LF.labeldefinition = 'RevType4'
			AND #InvoiceList.RevType4 = LF.ABBR

		End

	If @ShowDetail = 1
		BEGIN
			SELECT Kam = RevType1
			,NumFacturas = Sum(Case when CreditMemo = 'N' then 1 else 0 End)
			,NumNotCredito = Sum(Case when CreditMemo = 'Y' then 1 else 0 End)
			,Totales = Sum(1)
			,CantidadFacturas = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'N' then SelectedRevenue Else 0 End),2)
			,CantidadNotCredito = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'Y' then SelectedRevenue Else 0 End),2)
			,IngresoNeto  = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			FROM #InvoiceList
			Group by RevType1
			order by RevType1
		END
	Else If @ShowDetail = 2
		BEGIN	
			SELECT Terminal = RevType2
		    ,NumFacturas = Sum(Case when CreditMemo = 'N' then 1 else 0 End)
			,NumNotCredito = Sum(Case when CreditMemo = 'Y' then 1 else 0 End)
			,Totales = Sum(1)
			,CantidadFacturas = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'N' then SelectedRevenue Else 0 End),2)
			,CantidadNotCredito = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'Y' then SelectedRevenue Else 0 End),2)
			,IngresoNeto  = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			FROM #InvoiceList
			Group by RevType2
			order by RevType2

		END
	Else If @ShowDetail = 3
		BEGIN
			SELECT Proyecto = RevType3
				,NumFacturas = Sum(Case when CreditMemo = 'N' then 1 else 0 End)
			,NumNotCredito = Sum(Case when CreditMemo = 'Y' then 1 else 0 End)
			,Totales = Sum(1)
			,CantidadFacturas = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'N' then SelectedRevenue Else 0 End),2)
			,CantidadNotCredito = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'Y' then SelectedRevenue Else 0 End),2)
			,IngresoNeto  = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			FROM #InvoiceList 
			Group by RevType3
			order by RevType3
		END
	Else If @ShowDetail = 4
		BEGIN
			SELECT Division = RevType4
				,NumFacturas = Sum(Case when CreditMemo = 'N' then 1 else 0 End)
			,NumNotCredito = Sum(Case when CreditMemo = 'Y' then 1 else 0 End)
			,Totales = Sum(1)
			,CantidadFacturas = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'N' then SelectedRevenue Else 0 End),2)
			,CantidadNotCredito = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'Y' then SelectedRevenue Else 0 End),2)
			,IngresoNeto  = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			FROM #InvoiceList 
			Group by RevType4
			order by RevType4
		END

	Else If @ShowDetail = 5
		BEGIN
			SELECT Cliente = BillTo
			,NumFacturas = Sum(Case when CreditMemo = 'N' then 1 else 0 End)
			,NumNotCredito = Sum(Case when CreditMemo = 'Y' then 1 else 0 End)
			,Totales = Sum(1)
			,CantidadFacturas = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'N' then SelectedRevenue Else 0 End),2)
			,CantidadNotCredito = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'Y' then SelectedRevenue Else 0 End),2)
			,IngresoNeto  = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			FROM #InvoiceList
			Group by BillTo
			order by BillTo
		END
	Else If @ShowDetail = 6
		Begin
			SELECT  NumFactura = InvoiceNumber
			,NotaCredito = CreditMemo
			,Orden = OrderNumber 
			,Cliente  = BillToName
			,Origen = ShipperName
			,DireccionOrigen = ShipperLocation
			,FechaEnvio = ShipDate
			,Destino = ConsigneeName
			,DireccionDestino = ConsigneeLocation
			,FechaRecibido = DeliveryDate
			,IngresoTotal = SelectedRevenue
			,InvoiceStatus 
			From #InvoiceList
			Order by InvoiceNumber
		End

	Else If @ShowDetail = 7
		BEGIN
			SELECT Flota
			,NumFacturas = Sum(Case when CreditMemo = 'N' then 1 else 0 End)
			,NumNotCredito = Sum(Case when CreditMemo = 'Y' then 1 else 0 End)
			,Totales = Sum(1)
			,CantidadFacturas = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'N' then SelectedRevenue Else 0 End),2)
			,CantidadNotCredito = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(Case when CreditMemo = 'Y' then SelectedRevenue Else 0 End),2)
			,IngresoNeto  = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			FROM #InvoiceList
			Group by Flota
			order by Flota
		END

	SET NOCOUNT OFF

-- Part 3

	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'BilledRevenueXD',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 112, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Revenue, Expense, Ops Metrics for Assets',
		@sCaptionFull = '60+ Measurements for trips by Assets',
		@sProcedureName = 'Metric_BilledRevenueXD',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = null

	</METRIC-INSERT-SQL>
	*/

GO
GRANT EXECUTE ON  [dbo].[Metric_BilledRevenueXD] TO [public]
GO
