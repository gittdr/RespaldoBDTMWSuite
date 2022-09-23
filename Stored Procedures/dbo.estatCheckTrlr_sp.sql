SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- 9/5/06: 33827 - trailer beaming  
-- this uses trailer_id
Create procedure [dbo].[estatCheckTrlr_sp] 
	@trailer_id varchar(13) -- check this	
as 
SET NOCOUNT ON

declare @trlrstatus as varchar(12) 
declare @ord_hdrnumber as int 
select @trlrstatus = ''  --remains blank if trailer does not exits
select @ord_hdrnumber = 0

if exists (select 1 from trailerprofile where trl_id = @trailer_id )
begin 
-- rationale for the logic below: tmws will not allow you to beam a trailer
-- if it is on a shipment with status = STD or on a shipment with stastus = CMP
-- and asgn_enddate > the current date/time. 

-- if the trailer has an assetassignment status of STD then return that status 
-- and the order number.
	if exists 
	(select 1 from assetassignment where asgn_type = 'TRL' and asgn_status = 'STD'
		and asgn_id = @trailer_id)
	begin
		select @trlrstatus = 'STD'
	        select @ord_hdrnumber = ord_hdrnumber from legheader, assetassignment 
			where asgn_type = 'TRL' and asgn_status = 'STD'
		        and asgn_id = @trailer_id
			and assetassignment.lgh_number = legheader.lgh_number
	end
	else
	begin --It is not actively on a shipment but if it is on a completed shipment
              -- whose completion date is in the future then treat the shipment as STD.  
              -- i.e., return status = STD and the order number.
		if exists 
		(select 1 from assetassignment where asgn_type = 'TRL' and asgn_status = 'CMP'
	                and asgn_enddate > getdate()
			and asgn_id = @trailer_id)
		begin
			select @trlrstatus = 'STD'
	        select @ord_hdrnumber = ord_hdrnumber from legheader, assetassignment 
			where asgn_type = 'TRL' and asgn_status = 'CMP'
			 and asgn_enddate > getdate()
		        and asgn_id = @trailer_id
			and assetassignment.lgh_number = legheader.lgh_number
		end
		else select @trlrstatus = 'AVL'			
	end 
end
select @trlrstatus trlrstatus, @ord_hdrnumber ordernumber
GO
GRANT EXECUTE ON  [dbo].[estatCheckTrlr_sp] TO [public]
GO
