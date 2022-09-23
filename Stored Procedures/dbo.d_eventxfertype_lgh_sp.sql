SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[d_eventxfertype_lgh_sp] (@pl_lgh int ) as

	select 	stp_event,stp_transfer_type ,count(*) as qty 
	from 	stops 
	where 	lgh_number = @pl_lgh and stp_transfer_type is not null 
	group by stp_event,stp_transfer_type 
	
GO
GRANT EXECUTE ON  [dbo].[d_eventxfertype_lgh_sp] TO [public]
GO
