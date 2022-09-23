SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_BillingLag] 
(
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	@DateType varchar(25) = 'Bill', -- Transfer, Printed, Delivery, Ship
	@Mode varchar(25) = 'Bill', --Print, Transfer
	@ExcludeRebillsAndCreditMemosYN		Char(1)='Y',  
	@ExcludeSupplementalBillsYN		Char(1)='Y',  
	@RebillsOnlyYN				Char(1) ='N', 
	@OnlyRevClass1List varchar(128) ='',			-- To analyze different business units
	@OnlyRevClass2List varchar(128) ='',		
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) ='',
	@OnlyBilltoIdList  varchar(128) ='',			-- to analyze only certain customers
	@OnlyShipperIdList  varchar(128) ='',
	@OnlyConsigneeIdList  varchar(128) ='',
	@MetricCode varchar(255)='BillingLagReport',
	@OnlyIncludeNonEDIYN varchar(1) = 'N',
	@OnlyIncludeEDIYN varchar(1) = 'N',
	@EDIRemarkField varchar(255)= 'Electronic Data Interchange',
	@OnlyCompanyList varchar(255)='',
	@BillingLagStartMode varchar(255)='Delivery' --Ship

) 
AS 
	--Populate default currency and currency date types
	Exec PopulateSessionIDParamatersInProc 'Revenue',@MetricCode  

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.

	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'BillingLag', 
		@nActive = 1,	-- 1=active, 0=inactive.
		@nSort = 305, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Billing Lag',
		@sCaptionFull = 'Billing Lag Report',
		@sProcedureName = 'Metric_BillingLag',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = 'Billing' 


	</METRIC-INSERT-SQL>
*/

	Create Table #InvoiceList
	(	
		InvNumber 		Varchar(12),
		OrdNumber 		Int,
		OrderRemark		VARCHAR(25),
		MoveNumber 		Int,
		BillToID 		varchar(8),
		RevType1		Varchar(7),
		RevType2		Varchar(7),
		RevType3		Varchar(7),
		RevType4		Varchar(7),
		InvoiceStatus		Varchar(6),
		InvDefintion		Varchar(6),
		[Ship Date]	datetime,
		[Delivery Date] datetime,
		[Bill Date] datetime,
		[Print Date] datetime,
		[Transfer Date] datetime,
		TotalCharges		Money,
		BillingLag 		Decimal(8,2),
		ShipperID		Varchar(8),
		ConsigneeID		Varchar(8),
		Proyecto        varchar(10),
		Sucursal        varchar(10)
	)	

	Set nocount on	


-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:General,2:Cliente,3:Proyecto,4:Sucursal

	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
	Set @OnlyBilltoIdList = ',' + ISNULL(@OnlyBilltoIdList,'') + ','
	Set @OnlyShipperIdList = ',' + ISNULL(@OnlyShipperIdList,'') + ','
	Set @OnlyConsigneeIdList = ',' + ISNULL(@OnlyConsigneeIdList,'') + ','
	Set @OnlyCompanyList = ',' + ISNULL(@OnlyCompanyList,'') + ','
	
	IF @RebillsOnlyYN='Y'
	BEGIN
		Set @ExcludeRebillsAndCreditMemosYN='N'	
	END

	Insert into #InvoiceList
	Select	ivh_invoicenumber 	[Invoice Number],
			ord_hdrnumber  		[Order Number],
			(Select top 1 left(ord_remark,25) from orderheader (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber) as Remark,
			mov_number		[Move Number],
			ISNULL(ivh_billto,'UNKNOWN')	BillToID,
			ISNULL(ivh_revType1,'UNK') 		RevType1,
			ISNULL(ivh_revType2,'UNK') 		RevType2,
			ISNULL(ivh_revType3,'UNK') 		RevType3,
			ISNULL(ivh_revType4,'UNK') 		RevType4,
			ivh_invoicestatus 	InvoiceStatus,
			ivh_definition 		InvDefintion,
			ivh_shipdate    [Ship Date],
			ivh_deliverydate    [Delivery Date],
			ivh_billdate [Bill Date],
			ivh_printdate [Print Date],
			ivh_xferdate [Transfer Date],
			convert(money,IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) TotalCharges,
			0 as BillingLag,
			ivh_shipper ShipperID,
			Ivh_consignee ConsigneeID,
			(select ord_revtype3 from orderheader (nolock) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber),
			(select ord_revtype2 from orderheader (nolock) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)

	From Invoiceheader (NOLOCK)
	where	(
				(@DateType = 'Delivery' and ivh_deliverydate >=@DateStart and ivh_deliverydate < @DateEnd)
				OR
				(@DateType = 'Ship' and ivh_shipdate >=@DateStart and ivh_shipdate < @DateEnd)
				OR
				(@DateType = 'Bill' and ivh_billdate >=@DateStart and ivh_billdate < @DateEnd)
				OR
				(@DateType = 'Print' and ivh_printdate >=@DateStart and ivh_printdate < @DateEnd)
				OR
				(@DateType = 'Transfer' and ivh_xferdate >=@DateStart and ivh_xferdate < @DateEnd)
			)
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2List) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
		AND (@OnlyBilltoIdList =',,' or CHARINDEX(',' + RTRIM( ivh_Billto ) + ',', @OnlyBilltoIdList) >0)
		AND (@OnlyShipperIdList =',,' or CHARINDEX(',' + RTRIM( ivh_Shipper ) + ',', @OnlyShipperIdList) >0)
		AND (@OnlyConsigneeIdList =',,' or CHARINDEX(',' + RTRIM( ivh_Consignee ) + ',', @OnlyConsigneeIdList) >0)
		AND (@OnlyCompanyList =',,' or CHARINDEX(',' + RTRIM( ivh_company ) + ',', @OnlyCompanyList) >0)
		AND	(
				(@ExcludeRebillsAndCreditMemosYN='N')
				OR 
				(
					@ExcludeRebillsAndCreditMemosYN='Y'
					AND
					ISNULL(ivh_definition,'') NOT in ('CRD','RBIL')
				)
			)
		AND (	
				(@ExcludeSupplementalBillsYN='N')
				OR
				(
					@ExcludeSupplementalBillsYN='Y'
					AND
					ISNULL(ivh_definition,'') NOT in ('SUPL','MISC')
				)
			)		
		AND (	
				@RebillsOnlyYN='N'
				OR
				(
					@RebillsOnlyYN='Y'
					AND
					ivh_definition ='RBIL'
				)
			)		
		
	If @Mode = 'Print'
	BEGIN
		IF @BillingLagStartMode = 'Delivery'
			Update #InvoiceList
			Set BillingLag = DateDiff(day, [Delivery Date],[Print Date])
		ELSE 
			Update #InvoiceList
			Set BillingLag = DateDiff(day, [Ship Date],[Print Date])	
	END
	Else If @Mode = 'Bill'
	BEGIN
		IF @BillingLagStartMode = 'Delivery'
			Update #InvoiceList
			Set BillingLag = DateDiff(day, [Delivery Date],[Bill Date])
		ELSE
			Update #InvoiceList
			Set BillingLag = DateDiff(day, [Ship Date],[Bill Date])
	END
	Else If @Mode = 'Transfer'
	BEGIN
		IF @BillingLagStartMode = 'Delivery'
			Update #InvoiceList
			Set BillingLag = DateDiff(day, [Delivery Date],[Transfer Date])
		ELSE
			Update #InvoiceList
			Set BillingLag = DateDiff(day, [Ship Date],[Transfer Date])
	END
	
	IF @OnlyIncludeNonEDIYN = 'Y'
		DELETE FROM #InvoiceList WHERE (CHARINDEX(@EDIRemarkField, OrderRemark) > 0)
	
	IF @OnlyIncludeEDIYN = 'Y'
		DELETE FROM #InvoiceList WHERE (CHARINDEX(@EDIRemarkField, OrderRemark) = 0)

	Set @ThisCount = (select sum(BillingLag) from #InvoiceList)
	Set @ThisTotal = (select count(distinct OrdNumber) from #InvoiceList)

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
	
------------------------------------------------------------------------------------vista general

	IF @ShowDetail=1
	BEGIN
		Select 
        Factura = invnumber
        ,Orden = ordNumber
        ,Cliente = BillToId
        ,TerminoOrden = [Delivery Date]
        ,FechaFactura = [Bill Date]
        ,Monto = '$' + dbo.fnc_TMWRN_FormatNumbers(TotalCharges,2)
        ,DiasFacturar=dbo.fnc_TMWRN_FormatNumbers(BillingLag,2)
		From #InvoiceList
		Order by BillingLag Desc
	END

-----------------------------------------------------------------------------------vista cliente
		
  	IF @ShowDetail=2
	BEGIN
		Select 
 
        Cliente = BillToId
        ,PromedioDiasFacturar = dbo.fnc_TMWRN_FormatNumbers(AVG(BillingLag),2)
		From #InvoiceList
        group by BillToId
		Order by AVG(BillingLag) Desc
	END



	Set nocount OFF	

------------------------------------------------------------------------------------proyecto

	IF @ShowDetail=3
	BEGIN
			Select 
 
      Proyecto
        ,PromedioDiasFacturar = dbo.fnc_TMWRN_FormatNumbers(AVG(BillingLag),2)
		From #InvoiceList
        group by Proyecto
		Order by AVG(BillingLag) Desc
	END

-----------------------------------------------------------------------------------sucursal
		
  	IF @ShowDetail=4
	BEGIN
		Select 
 
        Sucursal
        ,PromedioDiasFacturar = dbo.fnc_TMWRN_FormatNumbers(AVG(BillingLag),2)
		From #InvoiceList
        group by Sucursal
		Order by AVG(BillingLag) Desc
	END



	Set nocount OFF	


GO
GRANT EXECUTE ON  [dbo].[Metric_BillingLag] TO [public]
GO
