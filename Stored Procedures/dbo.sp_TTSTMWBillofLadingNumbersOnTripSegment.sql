SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








--Author: Brent Keeton
--********************************************************************
--Purpose: Daily Sales Report is intended to see all revenue and associated
--miles (by order *Each row represents an order) currently out there 
--regardless if the order has been billed or not.
--********************************************************************

--Revision History: 
-- 1. Monday November 18,2002 Fixed to allow both references 
-- to the bill of lading back to stops and orderheader 
-- Prior to version 4.4 the reference number only referenced
-- back to the stops table not the orderheader 4.4 LBK

CREATE        Procedure [dbo].[sp_TTSTMWBillofLadingNumbersOnTripSegment] (
@TripSegmentNo integer )

As

select distinct ref_number from   legheader,stops,referencenumber
			   where  legheader.lgh_number = @TripSegmentNo
				  and 
				  legheader.lgh_number = stops.lgh_number 
				  and
				  (ref_type = 'BL#' or ref_type = 'BOL')
                                  and 
                                  (stops.stp_number = referencenumber.ref_tablekey and ref_table = 'stops'
				  Or
				  stops.ord_hdrnumber = referencenumber.ref_tablekey and stops.ord_hdrnumber <> 0 and ref_table = 'orderheader')
				   











GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWBillofLadingNumbersOnTripSegment] TO [public]
GO
