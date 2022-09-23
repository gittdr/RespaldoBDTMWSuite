SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_RevenueMovement]
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


	SELECT 	@BilledLineHaulRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00),
			@BilledTotalCharge = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
	FROM    invoiceheader (NOLOCK) 
	WHERE 	invoiceheader.mov_number = @MoveNumber
		And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToIDList) > 0)) 
		And (@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @IncludeBillToIDList) > 0)) 
		And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 

	--get linehaul revenue for unbilled
	Select	@UnbilledLineHaulRevenue = sum(IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)),
			@UnbilledTotalCharge = sum(IsNull(dbo.fnc_convertcharge(ord_totalcharge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))
	From    Orderheader (NOLOCK)
	Where	orderheader.mov_number = @MoveNumber	
		And ord_hdrnumber Not In (select ord_hdrnumber from InvoiceHeader (NOLOCK))				
		And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ord_billto ) + ',', @ExcludeBillToIDList) > 0)) 
		And (@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ord_billto ) + ',', @IncludeBillToIDList) > 0)) 
		And (@OrderStatusList = ',,' OR (CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) > 0)) 		
	
	SELECT 	@ExcludeRevenue = 
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
	FROM  invoicedetail (NOLOCK) Inner Join orderheader (NOLOCK)On orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber   
	WHERE	orderheader.mov_number = @MoveNumber 
		And CHARINDEX(',' + RTRIM( RTrim(invoicedetail.cht_itemcode) ) + ',', @ExcludeChargeTypeList ) > 0
		and ivd_charge is Not Null
		And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ord_billto ) + ',', @ExcludeBillToIDList) > 0)) 
		And (@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ord_billto ) + ',', @IncludeBillToIDList) > 0)) 
		And (@OrderStatusList = ',,' OR (CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) > 0)) 		 

	SELECT 	@IncludeRevenue = 
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
	FROM  invoicedetail (NOLOCK) Inner Join orderheader (NOLOCK)On orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber   
	WHERE 	orderheader.mov_number = @MoveNumber 
		And CHARINDEX(',' + RTRIM( RTrim(invoicedetail.cht_itemcode) ) + ',', @IncludeChargeTypeList ) > 0
		and ivd_charge is Not Null 
		And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ord_billto ) + ',', @ExcludeBillToIDList) > 0)) 
		And (@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ord_billto ) + ',', @IncludeBillToIDList) > 0)) 
		And (@OrderStatusList = ',,' OR (CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) > 0)) 		 
	
	Set @TotalCharge = (IsNull(@BilledTotalCharge,0) + IsNull(@UnbilledTotalCharge,0))
	Set @LineHaulRevenue = (IsNull(@BilledLineHaulRevenue,0) + IsNull(@UnbilledLineHaulRevenue,0))

	IF @AccRevenueOnlyYN = 'Y'
	Begin
		Set @Revenue = (@TotalCharge - @LineHaulRevenue)
	End
	Else If @LineHaulRevenueOnlyYN = 'Y'
	Begin
		Set @Revenue = @LineHaulRevenue
	End
	Else If @OnlyRevenueFromChargeTypesYN = 'Y'
	Begin
		Set @Revenue = @IncludeRevenue
	End
	Else If @IncludeChargeTypeList <> ',,' And @ExcludeChargeTypeList <> ',,'
	Begin
		Set @Revenue = (@LineHaulRevenue - @ExcludeRevenue) + @IncludeRevenue
	End
	Else If @IncludeChargeTypeList <> ',,'
	Begin
		Set @Revenue = (@LineHaulRevenue + @IncludeRevenue)
	End
	Else If @ExcludeChargeTypeList <> ',,'
	Begin
		Set @Revenue = (@TotalCharge - @ExcludeRevenue)
	End
	Else
	Begin
		Set @Revenue = @TotalCharge
	End
	
	Return @Revenue

End 

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_RevenueMovement] TO [public]
GO
