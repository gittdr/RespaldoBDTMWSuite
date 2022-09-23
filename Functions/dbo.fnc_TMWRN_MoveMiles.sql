SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

Create FUNCTION [dbo].[fnc_TMWRN_MoveMiles]
(
	@MoveNumber int = Null,
	@LegHeaderNumber int = Null,
	@MileageForZeroLegHeader int = 0,
	@LoadStatus varchar(255)='ALL',
	@StopStatusList varchar(255) = '',
	@BilledMilesOnly char(1)= 'N', --choices Y or N
	@NonBilledMilesOnly char(1) = 'N' --choices Y or N
)

RETURNS int
AS
BEGIN

Declare @MoveMiles int
Declare @CountLegHeaderNoMiles int
Declare @BilledMiles int
Declare @TravelMiles int


SELECT @StopStatusList = Case When Left(@StopStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@StopStatusList, ''))) + ',' Else @StopStatusList End

	If @BilledMilesOnly = 'Y' OR @NonBilledMilesOnly = 'Y'
		Begin
			Set @BilledMiles = ISNULL	(	(	Select Sum(IsNull(stp_ord_mileage,0))
		  										From Stops (NOLOCK)
												where  stops.mov_number=@MoveNumber
												And
			 										(
			   											(@LoadStatus = 'ALL')
        		   											Or
			   											(@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
		           											Or
														(@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
			 										 )
			 									And (@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0)  	
											 ),0)

			If @BilledMilesOnly = 'N'	-- @BilledMilesOnly takes precedence; this is only reason to return @NonBilledMilesOnly
				Begin
					Set @TravelMiles = ISNULL	(	(	Select Sum(IsNull(stp_lgh_mileage,0))
		  												From Stops (NOLOCK)
														where  stops.mov_number=@MoveNumber
														And
			 												(
			   													(@LoadStatus = 'ALL')
        		   													Or
			   													(@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
		           													Or
																(@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
			 												 )
			 											And (@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0)  	
													),0)
					Set @MoveMiles = 
						Case When @TravelMiles >= @BilledMiles Then
							@TravelMiles - @BilledMiles
						Else
							0
						End
				End
			Else
				Begin
					Set @MoveMiles = @BilledMiles
				End
		End
	Else	-- not worried about billable/unbillable
		Begin
			Set @MoveMiles = ISNULL	(	(	Select Sum(IsNull(stp_lgh_mileage,0))
		  									From Stops (NOLOCK)
											where  stops.mov_number=@MoveNumber
											And
			 									(
			   										(@LoadStatus = 'ALL')
        		   										Or
			   										(@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
		           										Or
													(@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
			 									 )
			 								And (@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0)  	
										),0)
		End


				
--Detect to see if user wants to add miles for zero legheaders
--this really only applies if user wants to allocate revenue
--back to segment when there are zero miles(if local run inner city)
If @MileageForZeroLegHeader > 0
	Begin
		Set @CountLegHeaderNoMiles = 
			(
				select count(distinct CountLegHeadersNoMiles.lgh_number)
				from	(
							select lgh_number
							from stops (NOLOCK)
							where @MoveNumber = stops.mov_number
							And
								(
									(@LoadStatus = 'ALL')
										Or
									(@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
										Or
									(@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
								)
	       					 And (@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0)  	
							 And
								(
									(@BilledMilesOnly = 'Y' AND stops.ord_hdrnumber > 0)
										OR
									(@BilledMilesOnly = 'N')
								)
							And
								(
									(@NonBilledMilesOnly = 'Y' AND stops.ord_hdrnumber = 0)
										OR
									(@NonBilledMilesOnly = 'N')
								)
							group by stops.lgh_number
							having   IsNull(sum(stp_lgh_mileage),0) = 0 
						) as CountLegHeadersNoMiles
			)

		--Adds 25 miles per legheader if they are zero 
		If (@CountLegHeaderNoMiles > 0)
			Begin
				Set @MoveMiles = (@MoveMiles + (@MileageForZeroLegHeader * @CountLegHeaderNoMiles))
			End
	End

	Return @MoveMiles


END


GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_MoveMiles] TO [public]
GO
