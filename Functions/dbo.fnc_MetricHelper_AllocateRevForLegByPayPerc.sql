SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_AllocateRevForLegByPayPerc]
	(@lgh_number int)

RETURNS Float
AS
BEGIN

Declare @MoveNumber int
Declare @LegPay Money
Declare @MovePay Money
Declare @PercLegPayOfMovePay FLOAT
Declare @AllocatedRev FLOAT
Declare @OrdHdrnumber int
Declare @InvRev money
Declare @OrdRev Money


Set @MoveNumber =(Select mov_number from legheader(NOLOCK) where lgh_number=@lgh_number)
Set @OrdHdrnumber =(Select ord_hdrnumber from legheader(NOLOCK) where lgh_number=@lgh_number)		
--Set @OrdRev =(select sum(ord_totalcharge) from Orderheader where ord_hdrnumber=@OrdHdrnumber and @OrdHdrnumber>0)
Set @InvRev =(select sum(ivh_totalcharge) from Invoiceheader(NOLOCK) where ord_hdrnumber=@OrdHdrnumber and @OrdHdrnumber>0)
Set @OrdRev=@InvRev
if ((@InvRev<.01) and (@OrdHdrnumber>0))
BEGIN
	Set @OrdRev=(select sum(ord_totalcharge) from Orderheader (NOLOCK)where ord_hdrnumber=@OrdHdrnumber and @OrdHdrnumber>0)
END
Set @LegPay =(Select sum(pyd_amount) from paydetail (NOLOCK)where lgh_number=@lgh_number and pyd_pretax ='Y')
Set @MovePay=
	(Select sum(pyd_amount) 
	from paydetail p (NOLOCK), Legheader l (NOLOCK)
	where 	l.mov_number=@MoveNumber
		and
		p.lgh_number=l.lgh_number
		and
		p.pyd_pretax='Y'
	)

Set @PercLegPayOfMovePay =0
IF (@MovePay>0)
BEGIN
	Set @PercLegPayOfMovePay =
		@legPay/@MovePay
END 


Set  @AllocatedRev = @OrdRev * @PercLegPayOfMovePay

Return @AllocatedRev


END
GO
