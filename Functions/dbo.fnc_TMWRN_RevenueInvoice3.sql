SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_RevenueInvoice3] 
(
	@MilesToAllocate float = Null,
	@MoveMiles float = Null,
	@MoveNumber int = Null,
	@OrderHeaderNumber int = Null,
	@LegHeaderNumber int = Null,
	@InvoiceHeaderNumber int = Null,
	@BaseRevenueCategoryTLAFN char(1) = 'T', -- T(otal),L(inehaul),A(ccessorial),F(uel),N(one)
	@IncludeChargeTypeList varchar(255) = '',
	@ExcludeChargeTypeList  varchar(255) = '',
	@SubtractFuelSurchargeYN char(1) = 'N',
	@OnlyInvoicedRevenueYN char(1) = 'N',
	@InvoiceStatusList varchar(255) = '',
	@OrderStatusList varchar(255) = ''
) 

Returns money

As

/* Description
Provides for a "Base Revenue" calculation of the selected type.  
Thereafter you can include or exclude additional charge type 
revenue as needed.  This design should provide maximum flexibility
for zeroing in on exactly the calculations you want.

Base Revenue value of 'F' uses the FuelChargeTypes table to identify 
the appropriate charge types for the Fuel Surcharge calculations.
*/

Begin 

	Declare @Revenue money

	Declare @BilledTotalRevenue money                   
	Declare @BilledLineHaulRevenue money
	Declare @BilledAccRevenue money
	Declare @BilledFuelRevenue money
	Declare @BilledExcludeRevenue money
	Declare @BilledIncludeRevenue money

	Declare @UnbilledTotalRevenue money
	Declare @UnbilledLineHaulRevenue money
	Declare @UnbilledAccRevenue money
	Declare @UnbilledFuelRevenue money
	Declare @UnbilledExcludeRevenue money
	Declare @UnbilledIncludeRevenue money

	Declare @TotalRevenue money
	Declare @TotalLineHaulRevenue money
	Declare @TotalAccessorialRevenue money
	Declare @TotalFuelRevenue money
	Declare @TotalExcludeRevenue money
	Declare @TotalIncludeRevenue money

	Declare @IncludeRevenue money
	Declare @ExcludeRevenue money

	Declare @PercenttoAllocate float 
	Declare @other float

	-- confirm initialization of list variables
	SELECT @IncludeChargeTypeList = Case When Left(@IncludeChargeTypeList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@IncludeChargeTypeList, ''))) + ',' Else @IncludeChargeTypeList End
	SELECT @ExcludeChargeTypeList = Case When Left(@ExcludeChargeTypeList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeChargeTypeList, ''))) + ',' Else @ExcludeChargeTypeList End
	SELECT @InvoiceStatusList = Case When Left(@InvoiceStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@InvoiceStatusList, ''))) + ',' Else @InvoiceStatusList End
	SELECT @OrderStatusList = Case When Left(@OrderStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OrderStatusList, ''))) + ',' Else @OrderStatusList End

	-- start the revenue calculation process
	-- NO Unbilled revenue returned in this function
	If @BaseRevenueCategoryTLAFN = 'T'  -- if base revenue is Total, get Total Revenue
		Begin
			SELECT 	@BilledTotalRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoiceheader (NOLOCK) 
			WHERE invoiceheader.ivh_hdrnumber = @InvoiceHeaderNumber 
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 

			Set @Revenue = @BilledTotalRevenue 
		End
	Else If @BaseRevenueCategoryTLAFN = 'L'		-- if base revenue is Linehaul, get Linehaul revenue
		Begin
			SELECT 	@BilledLineHaulRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoicedetail (NOLOCK) join invoiceheader (NOLOCK) on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
						join chargetype (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
			WHERE invoiceheader.ivh_hdrnumber = @InvoiceHeaderNumber 
				AND	(
						cht_primary = 'Y'
							OR
						(cht_primary = 'N' AND IsNull(chargetype.cht_LH_Rpt,'N') = 'Y')
					)
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 

			Set @Revenue = @BilledLineHaulRevenue 
		End
	Else If @BaseRevenueCategoryTLAFN = 'A'		-- if base revenue is Accessorial, get Accessorial revenue INCLUDING FUEL
		Begin
			SELECT 	@BilledAccRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoicedetail (NOLOCK) join invoiceheader (NOLOCK) on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
						join chargetype (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
			WHERE invoiceheader.ivh_hdrnumber = @InvoiceHeaderNumber 
				AND	(cht_primary = 'N' AND IsNull(chargetype.cht_LH_Rpt,'N') = 'N')
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 

			Set @Revenue = @BilledAccRevenue 
		End
	Else If @BaseRevenueCategoryTLAFN = 'N'		-- if base revenue is None, return ZERO
		Begin
			Set @Revenue = 0.00
		End

-- get Fuel Surcharge if necessary
	If (@SubtractFuelSurchargeYN = 'Y') OR (@BaseRevenueCategoryTLAFN = 'F')
		begin
			SELECT 	@BilledFuelRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoicedetail (NOLOCK) join invoiceheader (NOLOCK) on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
						join chargetype (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
						join FuelChargeTypes (NOLOCK) on invoicedetail.cht_itemcode = FuelChargeTypes.cht_itemcode
			WHERE invoiceheader.ivh_hdrnumber = @InvoiceHeaderNumber 
				AND	(cht_primary = 'N' AND IsNull(chargetype.cht_LH_Rpt,'N') = 'N')
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 

			Set @TotalFuelRevenue = @BilledFuelRevenue 

			If @BaseRevenueCategoryTLAFN = 'F'		-- if Base Revenue is Fuel, assign Fuel to @Revenue
				Begin
					Set @Revenue = @TotalFuelRevenue
				End
		end

	-- get Included Revenue, Billed 
	If @IncludeChargeTypeList <> ',,'
		Begin
			SELECT 	@BilledIncludeRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoicedetail (NOLOCK) join invoiceheader (NOLOCK) on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
			WHERE invoiceheader.ivh_hdrnumber = @InvoiceHeaderNumber 
				And CHARINDEX(',' + RTRIM( RTrim(invoicedetail.cht_itemcode) ) + ',', @IncludeChargeTypeList ) > 0
				and ivd_charge is Not Null 
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 
		End
	Else
		Begin
			Set @BilledIncludeRevenue = 0
		End

	Set @IncludeRevenue = @BilledIncludeRevenue 

	-- get Excluded Revenue, billed 
	If @ExcludeChargeTypeList <> ',,'
		Begin
			SELECT 	@BilledExcludeRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoicedetail (NOLOCK) join invoiceheader (NOLOCK) on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
			WHERE invoiceheader.ivh_hdrnumber = @InvoiceHeaderNumber 
				And CHARINDEX(',' + RTRIM( RTrim(invoicedetail.cht_itemcode) ) + ',', @ExcludeChargeTypeList ) > 0
				and ivd_charge is Not Null 
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 
		End
	Else
		Begin
			Set @BilledExcludeRevenue = 0
		End

	Set @ExcludeRevenue = @BilledExcludeRevenue 

	-- do the final revenue calculation adjustments
	Set @Revenue = @Revenue + @IncludeRevenue - @ExcludeRevenue

	If @SubtractFuelSurchargeYN = 'Y'
		Begin
			Set @Revenue = @Revenue - @TotalFuelRevenue
		End

	Return @Revenue
End



GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_RevenueInvoice3] TO [public]
GO
