SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_UnallocatedTotInvRevForLegheader]
	(@lgh_number int)

RETURNS Money
AS
BEGIN
Declare @OrdHdrnumber int
Declare @InvRev money
Set @OrdHdrnumber =(Select ord_hdrnumber from legheader (NOLOCK)where lgh_number=@lgh_number)		

Set @InvRev =(select sum(Ivh_totalcharge) from Invoiceheader (NOLOCK)where ord_hdrnumber=@OrdHdrnumber and @OrdHdrnumber>0)
Return @InvRev


END
GO
