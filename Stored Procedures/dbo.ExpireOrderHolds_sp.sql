SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[ExpireOrderHolds_sp] (@enddate datetime, @errormsg varchar(255) out)
AS

/*
*	Created: PTS 62183 - DJM - This proc takes a Hold ID and finds any Orders that match the hold requirements.
		PTS 76143 - DJM - 03/17/201 - Modified to call new proc ExpireOrderHoldId_sp once for each Hold Definition
			instead of doing the expire directly.
*/

declare @startdate as datetime,
@parmcount	as integer,
@ordmov				integer,
@minhld				integer,
@updcount			integer

select @updcount = 0

Declare @hlddeflist table (
hld_id		integer		not null,
hld_enddate		datetime		not null)

insert into @hlddeflist
select hld_id, hld_enddate
from OrderHoldDefinition
where hld_enddate <= @enddate
	and exists (select 1 from OrderHold oh where OrderHoldDefinition.hld_id = oh.hld_id and oh.ohld_active = 'Y')

-- Do not continue if there are not holds
if (select count(*) from @hlddeflist) < 1 
	Begin
		Select @errormsg = 'No Hold Definitions found that require expiration.'
		Return
	End 
	
select @minhld = min(hld_id) from @hlddeflist

While @minhld > 0 
	Begin
		--Update OrderHold
		--set ohld_active = 'N',
		--	ohld_terminate_comment = isNull(ohld_terminate_comment,od.hld_terminate_comment),
		--	ohld_enddate = GETDATE(),
		--	ohld_export_pending = 'Y'			
		--from OrderHold oh join OrderHoldDefinition od on oh.hld_id = od.hld_id
		--where oh.hld_id = @minhld
		--	and ohld_active = 'Y'
		--	and od.hld_enddate <= @enddate
			
		
		exec ExpireOrderHoldId_sp @minhld, @updcount out
			
		Select @updcount = @updcount + @updcount
		
		--Get the next Hold Id
		select @minhld = min(hld_id) from @hlddeflist where hld_id > @minhld

	End
	
	
	select @errormsg = 'Total of ' + CAST(isNull(@updcount,0) as varchar(20)) + ' Orderhold records expired'
	

GO
GRANT EXECUTE ON  [dbo].[ExpireOrderHolds_sp] TO [public]
GO
