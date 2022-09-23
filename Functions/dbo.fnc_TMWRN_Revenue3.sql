SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_Revenue3]
(
	@Mode varchar(255) = 'Order',	-- Order, Invoice, Leg, Move
	@MinMilesToAllocate float = 5,
	@MoveMiles float = Null,
	@MoveNumber int = Null,
	@OrderHeaderNumber int = Null,
	@LegHeaderNumber int = Null,
	@StopNumber int = Null,
	@InvoiceHeaderNumber int = Null,
	@BaseRevenueCategoryTLAFN char(1) = 'T', -- T(otal),L(inehaul),A(ccessorial),F(uel),N(one)
	@IncludeChargeTypeList varchar(255) = '',
	@ExcludeChargeTypeList  varchar(255) = '',
	@SubtractFuelSurchargeYN char(1) = 'N',
	@OnlyInvoicedRevenueYN char(1) = 'N',
	@InvoiceStatusList varchar(255) = '',
	@OrderStatusList varchar(255) = '',
	@LoadStatus varchar(3) = 'All',
	@StopStatusList varchar(255) = '',
	@BilledMilesOnlyYN char(1) = 'N',
	@NonBilledMilesOnlyYN char(1) = 'N'

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

The Leg and Move revenue functions must allocate revenue across 
multiple legs and/or moves if the business activity includes
split trips and/or crossdock trips.  This requires additional
parameters in order to identify and calculate the mileage on
which the allocation is based.
*/

Begin 
	Declare @Revenue money
	
	SELECT @IncludeChargeTypeList = Case When Left(@IncludeChargeTypeList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@IncludeChargeTypeList, ''))) + ',' Else @IncludeChargeTypeList End
	SELECT @ExcludeChargeTypeList = Case When Left(@ExcludeChargeTypeList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeChargeTypeList, ''))) + ',' Else @ExcludeChargeTypeList End
	SELECT @OrderStatusList = Case When Left(@OrderStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OrderStatusList, ''))) + ',' Else @OrderStatusList End
	SELECT @InvoiceStatusList = Case When Left(@InvoiceStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@InvoiceStatusList, ''))) + ',' Else @InvoiceStatusList End
	SELECT @StopStatusList = Case When Left(@StopStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@StopStatusList, ''))) + ',' Else @StopStatusList End
	
	
	IF @Mode = 'Invoice' 
	BEGIN 
		Set @Revenue = dbo.fnc_TMWRN_RevenueInvoice3(@MinMilesToAllocate,@MoveMiles,@MoveNumber,@OrderHeaderNumber,@LegHeaderNumber,@InvoiceHeaderNumber,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,@OnlyInvoicedRevenueYN,@InvoiceStatusList,@OrderStatusList)
	END
	ELSE IF @Mode = 'Order'
	BEGIN
		Set @Revenue = dbo.fnc_TMWRN_RevenueOrder3(@MinMilesToAllocate,@MoveMiles,@MoveNumber,@OrderHeaderNumber,@LegHeaderNumber,@InvoiceHeaderNumber,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,@OnlyInvoicedRevenueYN,@InvoiceStatusList,@OrderStatusList)
	END
	ELSE IF @Mode = 'Move'
	BEGIN
		Set @Revenue = dbo.fnc_TMWRN_RevenueMovementXD2a(@MoveNumber,@LegHeaderNumber,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,@OnlyInvoicedRevenueYN,@InvoiceStatusList,@OrderStatusList,@MinMilesToAllocate,@LoadStatus,@StopStatusList,@BilledMilesOnlyYN,@NonBilledMilesOnlyYN)
	END
	ELSE IF @Mode = 'Leg'
	BEGIN
		Set @Revenue = dbo.fnc_TMWRN_RevenueSegmentXD2a(@MoveNumber,@LegHeaderNumber,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,@OnlyInvoicedRevenueYN,@InvoiceStatusList,@OrderStatusList,@MinMilesToAllocate,@LoadStatus,@StopStatusList,@BilledMilesOnlyYN,@NonBilledMilesOnlyYN)
	END
	ELSE IF @Mode = 'Stop'
	BEGIN
		Set @Revenue = dbo.fnc_TMWRN_RevenueStopXD2a(@MoveNumber,@StopNumber,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,@OnlyInvoicedRevenueYN,@InvoiceStatusList,@OrderStatusList,@MinMilesToAllocate,@LoadStatus,@StopStatusList,@BilledMilesOnlyYN,@NonBilledMilesOnlyYN)
	END
	
	Return @Revenue
	
End                



GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_Revenue3] TO [public]
GO
