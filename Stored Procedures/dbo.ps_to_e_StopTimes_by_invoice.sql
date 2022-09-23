SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[ps_to_e_StopTimes_by_invoice] (@invnumb VARCHAR(15))
AS

INSERT INTO stoptimes (OrderNumber, LocationFileNumber, test, SequenceNumber, BeginRangeSched, EndRangeSched, 
                       PickupOrDelivery, ActivityTypeCode, ArrivalTime, DepartTime, ActivityStartTime, ActivityStopTime, 
                       QualityCode, QtyComment)
     SELECT OrderNumber, LocationFileNumber, test, SequenceNumber, BeginRangeSched, EndRangeSched, 
            PickupOrDelivery, ActivityTypeCode, ArrivalTime, DepartTime, ActivityStartTime, ActivityStopTime, 
            QualityCode, QtyComment
       FROM ps_common.dbo.e_StopTimes_vw, batchesdetail 
      WHERE e_StopTimes_vw.OrderNumber = @invnumb
GO
GRANT EXECUTE ON  [dbo].[ps_to_e_StopTimes_by_invoice] TO [public]
GO
