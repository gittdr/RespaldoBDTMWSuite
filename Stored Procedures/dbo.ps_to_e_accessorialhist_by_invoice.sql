SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[ps_to_e_accessorialhist_by_invoice] (@invnumb VARCHAR(15))
AS

INSERT INTO accessorialhist (AccessorialFileNumber, OrderNumber, LineNumber, AccCode, DriverPayCode, EDI, EDISeq, Description,
                             Pamt, Qty, Rate, Status)
     SELECT AccessorialFileNumber, OrderNumber, LineNumber, AccCode, DriverPayCode, EDI, EDISeq, Description,
            Pamt, Qty, Rate, Status 
       FROM ps_common.dbo.e_accessorialhist_vw, batchesdetail 
      WHERE e_accessorialhist_vw.OrderNumber = @invnumb
GO
GRANT EXECUTE ON  [dbo].[ps_to_e_accessorialhist_by_invoice] TO [public]
GO
