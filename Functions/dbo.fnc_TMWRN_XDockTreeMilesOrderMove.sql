SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

Create FUNCTION [dbo].[fnc_TMWRN_XDockTreeMilesOrderMove]
(
	@OrderNumber int = Null,
	@MoveNumber int = Null,
	@LegHeaderNumber int = Null,
	@MileageForZeroLegHeader int = 5,
	@LoadStatus varchar(255)='ALL',
	@StopStatusList varchar(255) = '',
	@BilledMilesOnly char(1)= 'N', --choices Y or N
	@NonBilledMilesOnly char(1) = 'N' --choices Y or N
)

RETURNS int

AS

BEGIN

	Declare @LghMiles float
	Declare @MoveMiles float
	Declare @TreeMiles float
	Declare @CountLegHeaderNoMiles int

	SELECT @StopStatusList = Case When Left(@StopStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@StopStatusList, ''))) + ',' Else @StopStatusList End

	-- since orders can span moves, function uses @MoveNumber to identify all appropriate orders and 
	-- THEN uses that list of orders to identify all connected moves; 
	If @BilledMilesOnly = 'Y'
		Begin
			Set @TreeMiles =
					(	Select sum(IsNull(stp_ord_mileage,0))
						from Stops S0 (NOLOCK) 
						Where mov_number in (	select distinct mov_number
												from Stops S1 (NOLOCK) 
												Where ord_hdrnumber = @OrderNumber	)
						   And	(
									(@LoadStatus = 'ALL')
										Or
									(@LoadStatus = 'LD' And S0.stp_loadstatus = 'LD')
										Or
									(@LoadStatus = 'MT' And S0.stp_loadstatus <> 'LD')
								)
						   And (@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0) 
					)
		End
	Else	-- @BilledMilesOnly <> 'Y'
		Begin
			Set @TreeMiles =
					(	Select sum(IsNull(stp_lgh_mileage,0))
						from Stops S0 (NOLOCK) 
						Where mov_number in (	select distinct mov_number
												from Stops S1 (NOLOCK) 
												Where ord_hdrnumber = @OrderNumber	)
							And	(
									(@LoadStatus = 'ALL')
										Or
									(@LoadStatus = 'LD' And S0.stp_loadstatus = 'LD')
										Or
									(@LoadStatus = 'MT' And S0.stp_loadstatus <> 'LD')
								)
							And (@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0)  	
							And	(
									(@NonBilledMilesOnly = 'Y' AND S0.ord_hdrnumber = 0)
										OR
									(@NonBilledMilesOnly = 'N')
								)
					)
		End
				
	--Detect to see if user wants to add miles for zero legheaders
	--this really only applies if user wants to allocate revenue
	--back to segment when there are zero miles(if local run inner city)
	If @MileageForZeroLegHeader > 0
		Begin
			Set @CountLegHeaderNoMiles = 
					(	select count(distinct CountLegHeadersNoMiles.lgh_number)
						from (	select   lgh_number
								from     stops (NOLOCK)
								where    @MoveNumber = stops.mov_number
									And	(
										  (@LoadStatus = 'ALL')
												Or
										  (@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
												Or
										  (@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
			       						)
									And	(@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0)  	
									And	(
											(@BilledMilesOnly = 'Y' AND stops.ord_hdrnumber > 0)
												OR
											(@BilledMilesOnly = 'N')
										)
			   		    			And	(
				 						   (@NonBilledMilesOnly = 'Y' AND stops.ord_hdrnumber = 0)
												OR
				 						   (@NonBilledMilesOnly = 'N')
										)
								group by stops.lgh_number
								having   IsNull(sum(stp_lgh_mileage),0) = 0 ) as CountLegHeadersNoMiles)

			--Adds @MileageForZeroLegHeader miles per legheader if they are zero 
			If (@CountLegHeaderNoMiles > 0)
				Begin
					Set @TreeMiles = (@TreeMiles + (@MileageForZeroLegHeader * @CountLegHeaderNoMiles))
				End
		End


Return @TreeMiles


END
GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_XDockTreeMilesOrderMove] TO [public]
GO
