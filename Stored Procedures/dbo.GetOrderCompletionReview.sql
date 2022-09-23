SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[GetOrderCompletionReview] @recordsToFetch int
as
	set rowcount @recordsToFetch
	select distinct orderheader.ord_number from orderheader
		inner join stops on stops.mov_number = orderheader.mov_number 
		inner join legheader on legheader.mov_number = orderheader.mov_number
        where	orderheader.ord_status <> 'CMP' and 
				orderheader.ord_status <> 'CAN' and 
				orderheader.ord_status <> 'MST' and 
				orderheader.ord_status <> 'ICO' and 
				stops.stp_type = 'DRP' and
				(legheader.lgh_driver1 <> 'UNKNOWN' or legheader.lgh_carrier <> 'UNKNOWN')
        group by orderheader.ord_number
        having max(stops.stp_schdtlatest) <= getdate()
        order by orderheader.ord_number
    set rowcount 0

GO
GRANT EXECUTE ON  [dbo].[GetOrderCompletionReview] TO [public]
GO
