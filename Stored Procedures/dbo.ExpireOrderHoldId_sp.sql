SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[ExpireOrderHoldId_sp] (@id integer, @updcount integer out)
AS

/*
*	Created: PTS 76143 - DJM - Expire only Holds for an Individual ID.  Should be called from ExpireOrderHolds_sp for
		each Hold found and from the iut_OrderHoldDefinition trigger to expire holds whenever the EndDate is change to 
		less than the current date.
*/


Update OrderHold
set ohld_active = 'N',
	ohld_terminate_comment = isNull(ohld_terminate_comment,od.hld_terminate_comment),
	ohld_enddate = GETDATE(),
	ohld_export_pending = 'Y'			
from OrderHold oh join OrderHoldDefinition od on oh.hld_id = od.hld_id
where oh.hld_id = @id
	and ohld_active = 'Y'
	
Select @updcount = @@ROWCOUNT

	
	

GO
GRANT EXECUTE ON  [dbo].[ExpireOrderHoldId_sp] TO [public]
GO
