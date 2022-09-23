SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_UnallocatedTotOrdRevForLegheader]
	(@lgh_number int)

RETURNS Money
AS
BEGIN
Declare @OrdHdrnumber int
Declare @OrdRev money
Set @OrdHdrnumber =(Select ord_hdrnumber from legheader (NOLOCK)where lgh_number=@lgh_number)		

Set @OrdRev =(select sum(ord_totalcharge) from Orderheader (NOLOCK)where ord_hdrnumber=@OrdHdrnumber and @OrdHdrnumber>0)
Return @OrdRev


END
GO
