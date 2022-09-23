SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Function [dbo].[fnc_TMWRN_XDRevenueOrder]
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

Returns float

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

    --trabajamos con el revenue total obtenemos el billed y unbilled revenue del total

	If @BaseRevenueCategoryTLAFN = 'T'  -- if base revenue is Total, get Total Revenue
		Begin
			SELECT 	@BilledTotalRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoiceheader (NOLOCK) 
			WHERE invoiceheader.ord_hdrnumber = @OrderHeaderNumber
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + ivh_invoicestatus + ',', @InvoiceStatusList) > 0)) 

			If @OnlyInvoicedRevenueYN = 'Y'
				Begin
					Set @UnbilledTotalRevenue = 0.00
				End
			Else
				Begin
					Select	@UnbilledTotalRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ord_totalcharge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
					From    Orderheader (NOLOCK)
					Where orderheader.ord_hdrnumber = @OrderHeaderNumber
						And NOT Exists (select ord_hdrnumber from InvoiceHeader (NOLOCK) where InvoiceHeader.ord_hdrnumber = orderheader.ord_hdrnumber AND ivh_invoicestatus <> 'CAN'   )				
						And (@OrderStatusList = ',,' OR (CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) > 0)) 	
	                   
								
								
	
				End

			Set @Revenue = @BilledTotalRevenue + @UnbilledTotalRevenue
		End

--termina calculo billed y unbilled revenue del total
-----------------------------------------

	Else If @BaseRevenueCategoryTLAFN = 'L'		-- if base revenue is Linehaul, get Linehaul revenue
		Begin
			SELECT 	@BilledLineHaulRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoiceheader (NOLOCK) INNER JOIN invoicedetail (NOLOCK) ON invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
						-- INNER JOIN chargetype (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
			WHERE 
					invoiceheader.ord_hdrnumber = @OrderHeaderNumber 
					AND ((@InvoiceStatusList = ',,' And invoiceheader.ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( invoiceheader.ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 
					AND invoicedetail.cht_itemcode IN 
							(
								SELECT chargetype.cht_itemcode 
								FROM chargetype (NOLOCK) 
								WHERE chargetype.cht_primary = 'Y' 
								OR (chargetype.cht_primary = 'N' AND IsNull(chargetype.cht_LH_Rpt,'N') = 'Y')
							)

			If @OnlyInvoicedRevenueYN = 'Y'
				Begin
					Set @UnbilledLineHaulRevenue = 0.00
				End
			Else
				Begin
					Select	@UnbilledAccRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',orderheader.ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
					FROM  invoicedetail (NOLOCK) Inner Join orderheader (NOLOCK)On orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber   
								-- join chargetype (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
					Where 
						@OrderHeaderNumber = orderheader.ord_hdrnumber 
						AND NOT Exists (select ord_hdrnumber from InvoiceHeader (NOLOCK) where InvoiceHeader.ord_hdrnumber = orderheader.ord_hdrnumber AND ivh_invoicestatus <> 'CAN')				
						And (@OrderStatusList = ',,' OR (CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) > 0)) 		
						AND invoicedetail.cht_itemcode IN 
								(
									SELECT chargetype.cht_itemcode 
									FROM chargetype (NOLOCK) 
									WHERE chargetype.cht_primary = 'N' 
									AND IsNull(chargetype.cht_LH_Rpt,'N') <> 'Y'
								)

					Select	@UnbilledTotalRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ord_totalcharge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
					From    Orderheader (NOLOCK)
					Where orderheader.ord_hdrnumber = @OrderHeaderNumber
						And NOT Exists (select ord_hdrnumber from InvoiceHeader (NOLOCK) where InvoiceHeader.ord_hdrnumber = orderheader.ord_hdrnumber AND ivh_invoicestatus <> 'CAN')				
						And (@OrderStatusList = ',,' OR (CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) > 0)) 		

					Set @UnbilledLineHaulRevenue = @UnbilledTotalRevenue - @UnbilledAccRevenue
				End

			Set @Revenue = @BilledLineHaulRevenue + @UnbilledLineHaulRevenue
		End



	Else If @BaseRevenueCategoryTLAFN = 'A'		-- if base revenue is Accessorial, get Accessorial revenue INCLUDING FUEL
		Begin
			SELECT 	@BilledAccRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoiceheader (NOLOCK) INNER JOIN invoicedetail (NOLOCK) on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
					--	join chargetype (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
			WHERE invoiceheader.ord_hdrnumber = @OrderHeaderNumber
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 
				AND invoicedetail.cht_itemcode IN 
						(
							SELECT chargetype.cht_itemcode 
							FROM chargetype (NOLOCK) 
							WHERE chargetype.cht_primary = 'N' 
							AND IsNull(chargetype.cht_LH_Rpt,'N') <> 'Y'
						)

			If @OnlyInvoicedRevenueYN = 'Y'
				Begin
					Set @UnbilledAccRevenue = 0.00
				End
			Else
				Begin
					Select	@UnbilledAccRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',orderheader.ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
					FROM  orderheader (NOLOCK) INNER JOIN invoicedetail (NOLOCK) On orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber 
						-- join chargetype (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
					Where orderheader.ord_hdrnumber = @OrderHeaderNumber
						And NOT Exists (select InvoiceHeader.ord_hdrnumber from InvoiceHeader (NOLOCK) where InvoiceHeader.ord_hdrnumber = orderheader.ord_hdrnumber AND InvoiceHeader.ivh_invoicestatus <> 'CAN')				
						And (@OrderStatusList = ',,' OR (CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) > 0)) 		
						AND invoicedetail.cht_itemcode IN 
								(
									SELECT chargetype.cht_itemcode 
									FROM chargetype (NOLOCK) 
									WHERE chargetype.cht_primary = 'N' 
									AND IsNull(chargetype.cht_LH_Rpt,'N') <> 'Y'
								)
						-- AND	(cht_primary = 'N' AND IsNull(chargetype.cht_LH_Rpt,'N') = 'N')
				End

			Set @Revenue = @BilledAccRevenue + @UnbilledAccRevenue
		End
	Else If @BaseRevenueCategoryTLAFN = 'N'		-- if base revenue is None, return ZERO
		Begin
			Set @Revenue = 0.00
		End

-- get Fuel Surcharge if necessary
	If (@SubtractFuelSurchargeYN = 'Y') OR (@BaseRevenueCategoryTLAFN = 'F')
		begin
			SELECT 	@BilledFuelRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoiceheader (NOLOCK) INNER JOIN invoicedetail (NOLOCK) on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
						-- join chargetype (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
						-- join FuelChargeTypes (NOLOCK) on invoicedetail.cht_itemcode = FuelChargeTypes.cht_itemcode
			WHERE invoiceheader.ord_hdrnumber = @OrderHeaderNumber
				-- AND	(cht_primary = 'N' AND IsNull(chargetype.cht_LH_Rpt,'N') = 'N')
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 
				AND invoicedetail.cht_itemcode IN 
					(
						SELECT chargetype.cht_itemcode 
						FROM chargetype (NOLOCK) INNER JOIN FuelChargeTypes (NOLOCK) on chargetype.cht_itemcode = FuelChargeTypes.cht_itemcode
						WHERE chargetype.cht_primary = 'N' 
						AND IsNull(chargetype.cht_LH_Rpt,'N') <> 'Y'
					)

			If @OnlyInvoicedRevenueYN = 'Y'
				Begin
					Set @UnbilledFuelRevenue = 0.00
				End
			Else
				Begin
					Select	@UnbilledFuelRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',orderheader.ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
					FROM  orderheader (NOLOCK) INNER JOIN invoicedetail (NOLOCK) ON orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber   
								-- join chargetype (NOLOCK) on invoicedetail.cht_itemcode = chargetype.cht_itemcode
								-- join FuelChargeTypes (NOLOCK) on invoicedetail.cht_itemcode = FuelChargeTypes.cht_itemcode
					Where orderheader.ord_hdrnumber = @OrderHeaderNumber
						And NOT Exists (select ord_hdrnumber from InvoiceHeader (NOLOCK) where InvoiceHeader.ord_hdrnumber = orderheader.ord_hdrnumber AND ivh_invoicestatus <> 'CAN')				
						-- AND	(cht_primary = 'N' AND IsNull(chargetype.cht_LH_Rpt,'N') = 'N')
						And (@OrderStatusList = ',,' OR (CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) > 0)) 		
						AND invoicedetail.cht_itemcode IN 
							(
								SELECT chargetype.cht_itemcode 
								FROM chargetype (NOLOCK) INNER JOIN FuelChargeTypes (NOLOCK) on chargetype.cht_itemcode = FuelChargeTypes.cht_itemcode
								WHERE chargetype.cht_primary = 'N' 
								AND IsNull(chargetype.cht_LH_Rpt,'N') <> 'Y'
							)
				End

			Set @TotalFuelRevenue = @BilledFuelRevenue + @UnbilledFuelRevenue

			If @BaseRevenueCategoryTLAFN = 'F'		-- if Base Revenue is Fuel, assign Fuel to @Revenue
				Begin
					Set @Revenue = @TotalFuelRevenue
				End
		end




	-- get Included Revenue, Billed and Unbilled
	If @IncludeChargeTypeList <> ',,'
		Begin
			SELECT 	@BilledIncludeRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoicedetail (NOLOCK) join invoiceheader (NOLOCK) on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
			WHERE invoiceheader.ord_hdrnumber = @OrderHeaderNumber
				And (invoicedetail.cht_itemcode in ('GST,PST,IVA,TAX3'))
                --And CHARINDEX(',' + RTrim(invoicedetail.cht_itemcode) + ',', @IncludeChargeTypeList ) > 0
				and ivd_charge is Not Null 
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + ivh_invoicestatus + ',', @InvoiceStatusList) > 0)) 

			If @OnlyInvoicedRevenueYN = 'Y'
				Begin
					Set @UnbilledIncludeRevenue = 0.00
				End
			Else
				Begin
					SELECT 	@UnbilledIncludeRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
					FROM  invoicedetail (NOLOCK) Join orderheader (NOLOCK)On orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber   
					Where orderheader.ord_hdrnumber = @OrderHeaderNumber
						And NOT Exists (select ord_hdrnumber from InvoiceHeader (NOLOCK) where InvoiceHeader.ord_hdrnumber = orderheader.ord_hdrnumber AND ivh_invoicestatus <> 'CAN')				
						And (invoicedetail.cht_itemcode in ('GST,PST,IVA,TAX3'))
                        --And CHARINDEX(',' + RTRIM( RTrim(invoicedetail.cht_itemcode) ) + ',', @IncludeChargeTypeList ) > 0
						and ivd_charge is Not Null 
						And (@OrderStatusList = ',,' OR (CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) > 0)) 		 
				End
		End
	Else
		Begin
			Set @BilledIncludeRevenue = 0.00
			Set @UnbilledIncludeRevenue = 0.00
		End

	Set @IncludeRevenue = @BilledIncludeRevenue + @UnbilledIncludeRevenue


------------------------------------------------------------get Excluded Revenue, billed and unbilled
	If @ExcludeChargeTypeList <> ',,'
		Begin
           --facturado
			SELECT 	@BilledExcludeRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
			FROM    invoiceheader (NOLOCK) join invoicedetail (NOLOCK) on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
			WHERE invoiceheader.ord_hdrnumber = @OrderHeaderNumber
				 And CHARINDEX(',' + RTrim(invoicedetail.cht_itemcode) + ',', @ExcludeChargeTypeList ) > 0
				and ivd_charge is Not Null 
				And ((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + ivh_invoicestatus + ',', @InvoiceStatusList) > 0)) 
                
			If @OnlyInvoicedRevenueYN = 'Y'
				Begin
					Set @UnbilledExcludeRevenue = 0.00
				End
			Else
				Begin
                    --no facturado
					SELECT 	@UnbilledExcludeRevenue = IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
					FROM  orderheader (NOLOCK) Join invoicedetail (NOLOCK)On orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber   
					Where orderheader.ord_hdrnumber = @OrderHeaderNumber
						And NOT Exists (select ord_hdrnumber from InvoiceHeader (NOLOCK) where InvoiceHeader.ord_hdrnumber = orderheader.ord_hdrnumber AND ivh_invoicestatus <> 'CAN')				
						--And (invoicedetail.cht_itemcode in ('GST,PST,IVA,TAX3'))
                        And CHARINDEX(',' + RTrim(invoicedetail.cht_itemcode) + ',', @ExcludeChargeTypeList ) > 0
						and ivd_charge is Not Null 
						And (@OrderStatusList = ',,' OR (CHARINDEX(',' + ord_status + ',', @OrderStatusList) > 0)) 		 
				End
		End
	Else
		Begin
			Set @BilledExcludeRevenue = 0.00
			Set @UnbilledExcludeRevenue = 0.00
		End

	Set @ExcludeRevenue = @BilledExcludeRevenue + @UnbilledExcludeRevenue

	-- do the final revenue calculation adjustments
	Set @Revenue = @Revenue + @IncludeRevenue - @ExcludeRevenue

	If @SubtractFuelSurchargeYN = 'Y'
		Begin
			Set @Revenue = @Revenue - @TotalFuelRevenue
		End

	Return @Revenue

End 



GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_XDRevenueOrder] TO [public]
GO
