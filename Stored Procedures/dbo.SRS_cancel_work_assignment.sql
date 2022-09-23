SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[SRS_cancel_work_assignment] @lgh_number int, @lgh_tractor varchar(8)
as
	declare @stp_number int, @mov_number int 
	-- make sure the trip is still planned with the same tractor
	-- if tractor is passed in as null it is ignored 
	if exists (select * from legheader
		where lgh_number = @lgh_number and 
			lgh_tractor = isnull(@lgh_tractor,lgh_tractor) and
			lgh_outstatus = 'PLN')
	begin
		select @stp_number =0
		begin tran
		while exists (select * from stops 
			where lgh_number = @lgh_number and stp_number > @stp_number)
		begin
			select @stp_number = min(stp_number) from stops 
			where lgh_number = @lgh_number and stp_number > @stp_number	

			--update event
			update event
			set evt_tractor = 'UNKNOWN',
				evt_driver1 = 'UNKNOWN',
				evt_driver2 = 'UNKNOWN',
				evt_trailer1 = 'UNKNOWN',
				evt_trailer2 = 'UNKNOWN'
			where stp_number = @stp_number
		end
		select @mov_number= mov_number from stops
			where stp_number = @stp_number
		
		exec update_assetassignment @mov_number
		commit tran
		exec update_move_light @mov_number	
	end
	else
	begin
		raiserror ('SRS Error Trip has been change after SRS message was sent.',16, 3)
	end 


GO
GRANT EXECUTE ON  [dbo].[SRS_cancel_work_assignment] TO [public]
GO
