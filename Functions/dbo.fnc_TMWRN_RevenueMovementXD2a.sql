SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_RevenueMovementXD2a]
(
	@MoveNumber int = Null,
	@LegHeaderNumber int = Null,
	@BaseRevenueCategoryTLAFN char(1) = 'T', -- T(otal),L(inehaul),A(ccessorial),F(uel),N(one)
	@IncludeChargeTypeList varchar(255) = '',
	@ExcludeChargeTypeList  varchar(255) = '',
	@SubtractFuelSurchargeYN char(1) = 'N',
	@OnlyInvoicedRevenueYN char(1) = 'N',
	@InvoiceStatusList varchar(255) = '',
	@OrderStatusList varchar(255) = '',
	@MinMilesToAllocate float = 0,
	@LoadStatus varchar(3) = 'All',
	@StopStatusList varchar(255) = '',
	@BilledMilesOnlyYN char(1) = 'N',
	@NonBilledMilesOnlyYN char(1) = 'N'
) 

Returns money

As

Begin 

	Declare @Revenue money
	Declare @temp float

	-- doing this should pick all moves in which order was involved even if no specific stop
	Select @Revenue = Sum(AllocRev)
	From	(
				Select AllocRev = Round(IsNull(AvailableRev * AllocPct,0),2)
				From	(
							Select AvailableRev
								,AllocPct = 
									Case When IsNull(TreeMiles,0) = 0 Then
										0
									Else
										Cast(MoveMiles as Float) / Cast(TreeMiles as Float)
									End
							from	(
										select ord_hdrnumber
											,mov_number
											,MoveMiles
											,TreeMiles = IsNull(dbo.fnc_TMWRN_XDockTreeMilesOrderMove(ord_hdrnumber,@MoveNumber,@LegHeaderNumber,@MinMilesToAllocate,@LoadStatus,',,',@BilledMilesOnlyYN,@NonBilledMilesOnlyYN),0)
											,AvailableRev = Sum(OrderRevenue)
										From	(
													select distinct S0.ord_hdrnumber
														,S0.mov_number
														,MoveMiles = IsNull(dbo.fnc_TMWRN_MoveMiles (S0.mov_number,default,@MinMilesToAllocate,@LoadStatus,@StopStatusList,@BilledMilesOnlyYN,@NonBilledMilesOnlyYN),0)
														,OrderRevenue = IsNull(dbo.fnc_TMWRN_RevenueOrder3(@MinMilesToAllocate,default,S0.mov_number,S0.ord_hdrnumber,default,default,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,@OnlyInvoicedRevenueYN,@InvoiceStatusList,@OrderStatusList),0.00)
													from stops S0 (NOLOCK) join OrderHeader O0 (NOLOCK) on S0.ord_hdrnumber = O0.ord_hdrnumber
													where S0.ord_hdrnumber in (	Select distinct S01.ord_hdrnumber
																				From Stops S01 (NOLOCK)
																				Where S01.mov_number = @MoveNumber
																				AND S01.ord_hdrnumber <> 0 )	
												) as T1
										Where mov_number = @MoveNumber
										group by T1.ord_hdrnumber,mov_number,MoveMiles
									) as FunctionTable0 
						) as FunctionTable1 
			) as FunctionTable2

	Return @Revenue
	
End                

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_RevenueMovementXD2a] TO [public]
GO
