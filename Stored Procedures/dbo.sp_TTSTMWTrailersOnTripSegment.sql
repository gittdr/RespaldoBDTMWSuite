SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











--Author: Brent Keeton
--********************************************************************
--Purpose: Daily Sales Report is intended to see all revenue and associated


CREATE     Procedure [dbo].[sp_TTSTMWTrailersOnTripSegment] (
@TripSegmentNo integer )

As

select distinct case when evt_trailer1 = 'UNKNOWN' Then 'UNK' else IsNull(evt_trailer1,'') end + case when evt_trailer2 Is Null or LTrim(RTrim(evt_trailer2)) = '' or evt_trailer2 = 'UNK' or evt_trailer2 = 'UNKNOWN' Then '' Else Case when evt_trailer2 = 'UNKNOWN' Then ' - ' + 'UNK' Else  ' - ' + evt_trailer2 End End from  stops (NOLOCK),event (NOLOCK)
			   where  stops.lgh_number = @TripSegmentNo
				  and 
				  stops.stp_number = event.stp_number 
				 
				  
                                 
				  
				  
				   














GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWTrailersOnTripSegment] TO [public]
GO
