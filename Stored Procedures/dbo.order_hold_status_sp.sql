SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[order_hold_status_sp] @ord_hdrnumber int

AS
/**
 * 
 * NAME:
 * dbo.
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * This procedure adjusts the ord_status and lgh_outstatus based on the presence of an orderhold.
 * A prerequisite for this procedure is the ord_status. It replaces the the third character of the
 * order status with an "H" if an active orderhold is present.
 *
 * RETURNS:
 * A return value of zero indicates success. A non-zero return value
 * indicates a failure of some type
 *
 * RESULT SETS: 
 * None
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber
 *       This parameter indicates the order number to check hold status for
 *
 * REFERENCES:
 * None
 * 
 * REVISION HISTORY:
 **/

DECLARE @oldstatus varchar(3)
DECLARE @newstatus varchar(3)
DECLARE @lgh_number int	
DECLARE @consolidated int,
	@minstop		integer,
	@mov			integer

--Begin postprocessing SQL
set @oldstatus = '   '

select @oldstatus = IsNull(ord_status,'   ')
from orderheader
where ord_hdrnumber = @ord_hdrnumber


If Exists (select 1 from orderhold where ord_hdrnumber = @ord_hdrnumber and ohld_active = 'Y')
	select @newstatus = substring(@oldstatus, 1, 2) + 'H'
Else
	begin
		select @newstatus = 
			case @oldstatus
				when 'AVH'
					then 'AVL'
				when 'GRH'
					then 'GRD'
				when 'ASH'
					then 'ASN'
				when 'PNH'
					then 'PND'
				else
					@oldstatus
			end
			
		-- PTS 69298 mak
		if exists(select 1 from OrderHold where ord_hdrnumber = @ord_hdrnumber and ohld_exceptioncode > '' )
			update orderheader
			set ord_origin_earliestdate = GETDATE()
			where ord_hdrnumber = @ord_hdrnumber		
	end
	
if @newstatus <> @oldstatus
	Begin
		update orderheader
			set ord_status = @newstatus
		where ord_hdrnumber = @ord_hdrnumber
		set @consolidated = 0
		select @lgh_number = min(lgh_number) from stops where ord_hdrnumber = @ord_hdrnumber
		select @consolidated = min(lgh_number) from stops where ord_hdrnumber = @ord_hdrnumber
		                                                   and lgh_number <> @lgh_number
		if @lgh_number <> 0 and @consolidated = 0
			update legheader
			set lgh_outstatus = @newstatus
			where lgh_number = @lgh_number
		
		if @oldstatus = 'AVL' and @newstatus = 'AVH' 
			begin
				select @minstop = min(stp_number) from stops where lgh_number = @lgh_number
				select @mov = mov_number from stops where stp_number = @minstop
				
				while @minstop > 0 
					Begin
						update stops set stp_status = 'NON' where stp_number = @minstop
						
						select @minstop = isNull(min(stp_number),0) from stops where lgh_number = @lgh_number and stp_number > @minstop
						select @mov = mov_number from stops where stp_number = @minstop
					end
							
				exec update_move_light @mov
	
			end
			
		if @oldstatus = 'AVH' and @newstatus = 'AVL' 
			begin
				select @minstop = min(stp_number) from stops where lgh_number = @lgh_number
				select @mov = mov_number from stops where stp_number = @minstop
				
				while @minstop > 0 
					Begin
						update stops set stp_status = 'OPN' where stp_number = @minstop
						
						select @minstop = min(stp_number) from stops where lgh_number = @lgh_number and stp_number > @minstop
						select @mov = mov_number from stops where stp_number = @minstop
					end
						
				exec update_move_light @mov
		
			end
		
	
		
	END

GO
GRANT EXECUTE ON  [dbo].[order_hold_status_sp] TO [public]
GO
