SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  Procedure [dbo].[SSRS_TTSTMWGetOrderNumbersOnTripSegment] ( @TripSegmentNo integer )

As

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON


select distinct ord_number from   legheader,stops,orderheader 
			   where  legheader.lgh_number = @TripSegmentNo
				  and 
				  legheader.lgh_number = stops.lgh_number 
				  --and 
				  --stp_number = ref_tablekey 
                                  --and 
                                  --ref_table ='stops' 
                                  and 
                                  stops.ord_hdrnumber = orderheader.ord_hdrnumber



GO
GRANT EXECUTE ON  [dbo].[SSRS_TTSTMWGetOrderNumbersOnTripSegment] TO [public]
GO
