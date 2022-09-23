SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TMWRN_Revenue2] 
(
	@Mode varchar(255) = 'Order',
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
	
	SELECT @IncludeChargeTypeList = Case When Left(@IncludeChargeTypeList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@IncludeChargeTypeList, ''))) + ',' Else @IncludeChargeTypeList End
	SELECT @ExcludeChargeTypeList = Case When Left(@ExcludeChargeTypeList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeChargeTypeList, ''))) + ',' Else @ExcludeChargeTypeList End
	SELECT @ExcludeBillToIDList = Case When Left(@ExcludeBillToIDList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeBillToIDList, ''))) + ',' Else @ExcludeBillToIDList End
	SELECT @IncludeBillToIDList = Case When Left(@IncludeBillToIDList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@IncludeBillToIDList, ''))) + ',' Else @IncludeBillToIDList End
	SELECT @OrderStatusList = Case When Left(@OrderStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OrderStatusList, ''))) + ',' Else @OrderStatusList End
	SELECT @InvoiceStatusList = Case When Left(@InvoiceStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@InvoiceStatusList, ''))) + ',' Else @InvoiceStatusList End
	
	
	IF @Mode = 'Invoice' 
	BEGIN 
		Set @Revenue = dbo.fnc_TMWRN_RevenueInvoice2(@MilesToAllocate,@MoveMiles,@MoveNumber,@OrderHeaderNumber,@LegHeaderNumber,@InvoiceHeaderNumber,@IncludeChargeTypeList,@ExcludeChargeTypeList,@LineHaulRevenueOnlyYN,@AccRevenueOnlyYN,@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,@OrderStatusList,@InvoiceStatusList)
	END
	ELSE IF @Mode = 'Order'
	BEGIN
		Set @Revenue = dbo.fnc_TMWRN_RevenueOrder2(@MilesToAllocate,@MoveMiles,@MoveNumber,@OrderHeaderNumber,@LegHeaderNumber,@InvoiceHeaderNumber,@IncludeChargeTypeList,@ExcludeChargeTypeList,@LineHaulRevenueOnlyYN,@AccRevenueOnlyYN,@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,@OrderStatusList,@InvoiceStatusList)
	END
	ELSE IF @Mode = 'Movement'
	BEGIN
		Set @Revenue = dbo.fnc_TMWRN_RevenueMovement2(@MilesToAllocate,@MoveMiles,@MoveNumber,@OrderHeaderNumber,@LegHeaderNumber,@InvoiceHeaderNumber,@IncludeChargeTypeList,@ExcludeChargeTypeList,@LineHaulRevenueOnlyYN,@AccRevenueOnlyYN,@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,@OrderStatusList,@InvoiceStatusList)	
	END
	ELSE IF @Mode = 'Segment'
	BEGIN
		Set @Revenue = dbo.fnc_TMWRN_RevenueSegment2(@MilesToAllocate,@MoveMiles,@MoveNumber,@OrderHeaderNumber,@LegHeaderNumber,@InvoiceHeaderNumber,@IncludeChargeTypeList,@ExcludeChargeTypeList,@LineHaulRevenueOnlyYN,@AccRevenueOnlyYN,@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,@OrderStatusList,@InvoiceStatusList)		
	END
	ELSE IF @Mode = 'LegHeader'
	BEGIN
		Set @Revenue = dbo.fnc_TMWRN_RevenueLegheader2(@MilesToAllocate,@MoveMiles,@MoveNumber,@OrderHeaderNumber,@LegHeaderNumber,@InvoiceHeaderNumber,@IncludeChargeTypeList,@ExcludeChargeTypeList,@LineHaulRevenueOnlyYN,@AccRevenueOnlyYN,@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,@OrderStatusList,@InvoiceStatusList)	
	END
	ELSE IF @Mode = 'MilesSum'
	BEGIN
		Set @Revenue = dbo.fnc_TMWRN_RevenueMilesSum2(@MilesToAllocate,@MoveMiles,@MoveNumber,@OrderHeaderNumber,@LegHeaderNumber,@InvoiceHeaderNumber,@IncludeChargeTypeList,@ExcludeChargeTypeList,@LineHaulRevenueOnlyYN,@AccRevenueOnlyYN,@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,@OrderStatusList,@InvoiceStatusList)		
	END
	
	Return @Revenue
	
End                
GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_Revenue2] TO [public]
GO
