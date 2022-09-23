SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_RevenueInvoice2] 
(
	@MilesToAllocate float = Null,
	@MoveMiles float = Null,
	@MoveNumber int = Null,
	@OrderHeaderNumber int = Null,
	@LegHeaderNumber int = Null,
	@InvoiceHeaderNumber int = Null,
	@IncludeChargeTypeList varchar(255) = '',
	@ExcludeChargeTypeList  varchar(255) = '',
	@LineHaulRevenueOnlyYN	Char(1)='N',
	@AccRevenueOnlyYN		Char(1)='N',
	@OnlyRevenueFromChargeTypesYN Char(1) = 'N',
	@ExcludeBillToIDList varchar(255) = '',
	@IncludeBillToIDList varchar(255) = '',
	@OrderStatusList varchar(255) = '',
	@InvoiceStatusList varchar(255) = ''
) 

Returns money
As

Begin 

	Declare @Revenue money
	Declare @UnbilledLineHaulRevenue money
	Declare @UnbilledTotalCharge money
	Declare @BilledLineHaulRevenue money
	Declare @AccessorialRevenue money
	Declare @PercenttoAllocate float 
	Declare @ExcludeRevenue money
	Declare @IncludeRevenue money
	Declare @BilledTotalCharge money                   
	Declare @TotalCharge money
	Declare @LineHaulRevenue money
	Declare @other float

-- added 4/3/2008; takes into account whether or not charge type is rolling into LH for billing &/or reporting purposes
	SELECT 	@BilledLineHaulRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
	FROM    invoicedetail (NOLOCK) join invoiceheader (NOLOCK) on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
				join chargetype (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
	WHERE 	invoiceheader.mov_number = @MoveNumber
		AND	(
				cht_primary = 'Y'
					OR
				(cht_primary = 'N' AND IsNull(chargetype.cht_LH_Rpt,'N') = 'Y')
			)
		And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToIDList) > 0)) 
		And (@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @IncludeBillToIDList) > 0)) 
		And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 
-- end added 4/3/2008

-- changed 4/3/2008
	SELECT 	--@BilledLineHaulRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00),
-- end changed 4/3/2008
			@BilledTotalCharge = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
	FROM    invoiceheader (NOLOCK) 
	WHERE 	invoiceheader.mov_number = @MoveNumber
		And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToIDList) > 0)) 
		And (@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @IncludeBillToIDList) > 0)) 
		And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 

	--ALL Revenue on an Invoice by Default
	--If Charge Types are included -> LineHaul + just those charge types
	--If Charge Types are excluded -> LineHaul - just those charge types
	SELECT 	@ExcludeRevenue = 
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
	FROM	invoicedetail (NOLOCK) 
		Inner Join invoiceheader (NOLOCK) On invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
	WHERE invoicedetail.ivh_hdrnumber = @InvoiceHeaderNumber 
	And CHARINDEX(',' + RTRIM( RTrim(invoicedetail.cht_itemcode) ) + ',', @ExcludeChargeTypeList) >0
	and ivd_charge is Not Null 
	And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToIDList) > 0)) 
	And (@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @IncludeBillToIDList) > 0)) 
	And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 
	
		
	SELECT	@IncludeRevenue = 
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
	FROM    invoicedetail (NOLOCK) 
		Inner Join invoiceheader (NOLOCK) On invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
	WHERE invoicedetail.ivh_hdrnumber = @InvoiceHeaderNumber 
	AND CHARINDEX(',' + RTRIM( RTrim(invoicedetail.cht_itemcode) ) + ',', @IncludeChargeTypeList ) > 0
	and ivd_charge is Not Null 
	And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToIDList) > 0)) 
	And (@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @IncludeBillToIDList) > 0)) 
	And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 


	IF @AccRevenueOnlyYN = 'Y'
	Begin
		Set @Revenue = (@BilledTotalCharge - @BilledLineHaulRevenue)
	End
	Else If @LineHaulRevenueOnlyYN = 'Y'
	Begin
		Set @Revenue = @BilledLineHaulRevenue
	End
	Else If @OnlyRevenueFromChargeTypesYN = 'Y'
	Begin
		Set @Revenue = @IncludeRevenue
	End
	Else If @IncludeChargeTypeList <> ',,' And @ExcludeChargeTypeList <> ',,'
	Begin
		Set @Revenue = (@BilledLineHaulRevenue - @ExcludeRevenue) + @IncludeRevenue
	End
	Else If @IncludeChargeTypeList <> ',,'
	Begin
		Set @Revenue = (@BilledLineHaulRevenue + @IncludeRevenue)
	End
	Else If @ExcludeChargeTypeList <> ',,'
	Begin
		Set @Revenue = (@BilledTotalCharge - @ExcludeRevenue)
	End
	Else
	Begin
		Set @Revenue = @BilledTotalCharge
	End
	
	Return @Revenue
	
End   

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_RevenueInvoice2] TO [public]
GO
