SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_allocatedTotOrdRevByMiles]
	(@lgh_number int)

RETURNS Money
AS
BEGIN

Declare @LghMiles float
Declare @MovMiles float
Declare @MoveNumber Int
Declare @PercentMilesThisSeg float
Declare @OrdHdrnumber int
Declare @OrdRev money

Declare @AllocatedRev money
Set @LghMiles=
	ISNULL(
		(Select Sum(stp_lgh_mileage)
		From Stops (NOLOCK)
		where 
			stops.lgh_number=@lgh_number
		)
	,0)
Set @MoveNumber =(Select mov_number from legheader(NOLOCK) where lgh_number=@lgh_number)
Set @MovMiles =
	(Select Sum(stp_lgh_mileage)
	From Stops (NOLOCK)
	where 
		stops.mov_number=@MoveNumber
	)
Set @PercentMilesThisSeg =0
IF (@MovMiles>0)
BEGIN
	Set @PercentMilesThisSeg =
		@LghMiles/@MovMiles
END 
Set @OrdHdrnumber =(Select ord_hdrnumber from legheader (NOLOCK) where lgh_number=@lgh_number)		
Set @OrdRev =(select sum(ivh_totalcharge) from Invoiceheader(NOLOCK) where ord_hdrnumber=@OrdHdrnumber and @OrdHdrnumber>0)
if ( ISNULL(@OrdRev,0)=0)
BEGIN
	Set @OrdRev =(select sum(ord_totalcharge) from Orderheader(NOLOCK) where ord_hdrnumber=@OrdHdrnumber and @OrdHdrnumber>0)
END
Set  @AllocatedRev = @OrdRev * @PercentMilesThisSeg
Return @AllocatedRev


END
GO
GRANT EXECUTE ON  [dbo].[fnc_MetricHelper_allocatedTotOrdRevByMiles] TO [public]
GO
