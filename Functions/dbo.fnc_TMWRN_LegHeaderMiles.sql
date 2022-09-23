SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

Create FUNCTION [dbo].[fnc_TMWRN_LegHeaderMiles]
	(
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

	Declare @LghMiles int
	Declare @BilledMiles int
	Declare @TravelMiles int

	SELECT @StopStatusList = Case When Left(@StopStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@StopStatusList, ''))) + ',' Else @StopStatusList End

	If @BilledMilesOnly = 'Y' OR @NonBilledMilesOnly = 'Y'
		Begin
			Set @BilledMiles = ISNULL	(	(	Select Sum(IsNull(stp_ord_mileage,0))
		  										From Stops (NOLOCK)
		  										where stops.lgh_number=@LegHeaderNumber
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
		  												where stops.lgh_number=@LegHeaderNumber
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
					Set @LghMiles = @TravelMiles - @BilledMiles
/*
						Case When @TravelMiles >= @BilledMiles Then
							@TravelMiles - @BilledMiles
						Else
							0
						End
*/
				End
			Else
				Begin
					SET @LghMiles = @BilledMiles
				End
		End
	Else	-- not worried about billable/unbillable
		Begin
			Set @LghMiles = ISNULL	(	(	Select Sum(IsNull(stp_lgh_mileage,0))
		  									From Stops (NOLOCK)
		  									where stops.lgh_number=@LegHeaderNumber
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

	If (@LghMiles = 0) 
		Begin
			Set @LghMiles = @MileageForZeroLegHeader
		End

	Return @LghMiles

END
GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_LegHeaderMiles] TO [public]
GO
