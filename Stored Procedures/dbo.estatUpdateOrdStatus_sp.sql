SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatUpdateOrdStatus_sp] 	@ord_hdrnumber int, @timediff int
-- Example: exec estatUpdateOrdStatus_sp 602, 2
as 
SET NOCOUNT ON

Begin
	declare @movenumber as int	
	select @movenumber = mov_number from orderheader where ord_hdrnumber = @ord_hdrnumber 
	update orderheader set ord_status = 'AVL' where ord_hdrnumber = @ord_hdrnumber 
	declare @minstop int
declare @timebump int
	select @minstop = 0
    select @timebump = 0 -- So there is no bumpt on the first stop
	select @minstop = min(stp_number) from stops where mov_number = @movenumber    

	while @minstop is not NULL
		BEGIN  		
			update stops set stp_schdtearliest = dateadd(hh, @timebump,getdate())  ,  
							 stp_schdtlatest = dateadd(hh, @timebump+1,getdate())  ,  
							 stp_arrivaldate = dateadd(hh, @timebump,getdate())  ,    
							 stp_departuredate = dateadd(hh, @timebump+1,getdate())        
			where stp_number = @minstop
            select @timebump = @timebump + @timediff
			select @minstop = min(stp_number) from stops
				where mov_number = @movenumber and stp_number > @minstop  
		END
	update orderheader set ord_priority = 'UNK' where ord_hdrnumber = @ord_hdrnumber -- 6/3/08

	exec update_move @movenumber 
        update legheader set lgh_outstatus = 'AVL' where mov_number = @movenumber 
End
GO
GRANT EXECUTE ON  [dbo].[estatUpdateOrdStatus_sp] TO [public]
GO
