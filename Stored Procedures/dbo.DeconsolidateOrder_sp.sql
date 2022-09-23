SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	
Create Procedure [dbo].[DeconsolidateOrder_sp] (@ordhdr integer, @mov integer, @errormsg varchar(255) out)
AS

/*
*	Created: PTS 64274 - DJM - Proc to deconsolidate an Order from a movement to a new movement. Must also Log information
*			on the original Movement and new Movement to a table for reporting purposes.
*/

Declare @origmov as integer,
	@newmov as integer,
	@ordcount as integer,
	@status as integer,
	@newleg as integer,
	@tmwuser    VARCHAR(255),
	@minstop	integer,
	@minleg		integer

Declare @removestops as Table (ord_hdrnumber	integer		not null,
	stp_number	integer		not null,
	orig_leg	integer		not null)

	  
exec gettmwuser @tmwuser output  
	
-- Validate the passed Order.
if ISNULL(@ordhdr,0) = 0
	Begin
		select @errormsg = 'Invalid Order specified. Please provide a valid OrderHeader number.'
		Return
	end
	
if not exists (select 1 from orderheader where ord_hdrnumber = @ordhdr) 
	Begin
		select @errormsg = 'Invalid Order specified. OrdHdr: ' + cast(@ordhdr as varchar(10)) + ' could not be found. Please provide a valid OrderHeader number.'
		Return
	
	end
	
if not exists (select 1 from orderheader where ord_hdrnumber = @ordhdr and mov_number = @mov) 
	Begin
		select @errormsg = 'Invalid Movement specified. OrdHdr: ' + cast(@ordhdr as varchar(10)) + ' could not be found on Movement: ' + CAST(@mov as varchar(20)) + '. Please provide a valid Movement number.'
		Return
	
	end
	
select @ordcount = count(distinct ord_hdrnumber) from stops where mov_number = @mov and isNull(ord_hdrnumber,0) > 0
if @ordcount < 2
	Begin
		select @errormsg = 'Invalid Request. OrdHdr: ' + cast(@ordhdr as varchar(10)) + ' does not appear to be consolidated on Movement: ' + CAST(@mov as varchar(10))
		Return
	
	end
	
-- check the status of the Order. Do not allow deconsolidation if the status is 'past' Availaible.
select @status = MAX(code) from labelfile l join legheader lg on l.labeldefinition = 'DispStatus' and l.abbr = lg.lgh_outstatus join stops s on lg.lgh_number = s.lgh_number 
where  lg.mov_number = @mov and s.ord_hdrnumber = @ordhdr
if @status > 210
	Begin
		select @errormsg = 'Invalid Request. OrdHdr: ' + cast(@ordhdr as varchar(10)) + ' is in a Status that does not permit automatic Deconsolidation'
		Return
	
	end


select @origmov = @mov

-- Find the stops that need to be 'moved' to the new movement and leg
insert into @removestops
select s.ord_hdrnumber,
	s.stp_number,
	s.lgh_number
from stops s where s.ord_hdrnumber = @ordhdr and s.mov_number = @mov


--Create a new movement and Leg to attache the Order and stops to.
EXEC @newmov =  getsystemnumberblock 'MOVNUM', NULL, 1  
IF @@ERROR <> 0 Return -- GOTO ERROR_EXIT2  
  
EXEC @newleg = getsystemnumberblock 'LEGHDR', NULL, 1  
IF @@ERROR <> 0 Return --GOTO ERROR_EXIT2  
  
-- Loop through the stops and change the lgh_number and mov_number
select @minstop  = isNull(min(stp_number),0) from @removestops
select @minleg = orig_leg from @removestops where stp_number = @minstop

while @minstop > 0
	Begin
		update stops
		set lgh_number = @newleg,
			mov_number = @newmov
		where stp_number = @minstop
			and lgh_number = @minleg
		
		update event
		set evt_mov_number = @newmov
		where stp_number = @minstop
	
		select @minstop  = isNull(min(stp_number),0) from @removestops where stp_number > @minstop
		select @minleg = orig_leg from @removestops where stp_number = @minstop

	End
	
-- Set the new movement on the Order
Update orderheader
set mov_number = @newmov
where ord_hdrnumber = @ordhdr
	and mov_number = @mov 


EXEC UPDATE_MOVE @newmov  

EXEC UPDATE_MOVE @mov


-- See if we need to log the Deconsolidation of the Order
if exists (select 1 from generalinfo where gi_name = 'OrderHoldLogDeconsolidate' and gi_string1 = 'Y')
begin
	select @minleg = isNull(min(orig_leg),0) from @removestops

	While @minleg > 0
		begin
			Insert into Deconsolidated_orders (do_orig_mov, do_orig_leg,do_new_leg,do_new_mov,do_ord_hdrnumber,do_date,do_userid)
			values(	@mov,
				@minleg,
				@newleg,
				@newmov,
				@ordhdr,
				GETDATE(),
				@tmwuser)
		
			select @minleg = isNull(min(orig_leg),0) from @removestops where orig_leg > @minleg
		end
End


GO
GRANT EXECUTE ON  [dbo].[DeconsolidateOrder_sp] TO [public]
GO
