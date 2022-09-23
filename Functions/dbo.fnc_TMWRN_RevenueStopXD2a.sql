SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_RevenueStopXD2a]
(
	@MoveNumber int = Null,
	@StopNumber int = Null,
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

	-- doing this should pick all legs in which order was involved even if no specific stop
	-- for the order on one or more of the intermediate legs
	Select @Revenue = Sum(AllocRev)
	From	(
				Select AllocRev = Round(IsNull(AvailableRev * AllocPct,0),2)
				From	(
							Select AvailableRev
								,AllocPct = Cast(StopMiles as Float) / Cast(TreeMiles as Float)
							from	(
										select ord_hdrnumber
											,stp_number
											,StopMiles
											,TreeMiles = IsNull(dbo.fnc_TMWRN_XDockTreeMilesOrderMove(ord_hdrnumber,@MoveNumber,DEFAULT,@MinMilesToAllocate,@LoadStatus,@StopStatusList,@BilledMilesOnlyYN,@NonBilledMilesOnlyYN),0)
											,AvailableRev = Sum(OrderRevenue)
										From	(
													select distinct S0.ord_hdrnumber
														,S0.stp_number
														,S0.mov_number
														,StopMiles = ISNULL(dbo.fnc_TMWRN_Miles('Stops',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,stp_number,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0)
														,OrderRevenue = IsNull(dbo.fnc_TMWRN_RevenueOrder3(@MinMilesToAllocate,default,S0.mov_number,S0.ord_hdrnumber,L0.lgh_number,default,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,@OnlyInvoicedRevenueYN,@InvoiceStatusList,@OrderStatusList),0.00)
													from stops S0 (NOLOCK) join legheader L0 (NOLOCK) on S0.mov_number = L0.mov_number
															join OrderHeader O0 (NOLOCK) on S0.ord_hdrnumber = O0.ord_hdrnumber
													where S0.ord_hdrnumber in (	Select distinct S01.ord_hdrnumber
																				From Stops S01 (NOLOCK)
																				Where S01.mov_number = @MoveNumber
																				AND S01.ord_hdrnumber <> 0 )
												) As T1
										Where stp_number = @StopNumber
										group by T1.ord_hdrnumber,stp_number,StopMiles
									) as FunctionTable0 
						) as FunctionTable1 
			) as FunctionTable2

	Return @Revenue
	
End                

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_RevenueStopXD2a] TO [public]
GO
