SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[ps_to_e_ProdQtys_by_invoice] (@invnumb VARCHAR(15))
AS

INSERT INTO ProdQtys (OrderNumber, ProductLineNo, TestLineNo, RequestedQty, ActualQty, MeasureCode, BusinessGroup)
     SELECT OrderNumber, ProductLineNo, TestLineNo, RequestedQty, ActualQty, MeasureCode, BusinessGroup
       FROM ps_common.dbo.e_ProdQtys_vw, batchesdetail 
      WHERE e_ProdQtys_vw.OrderNumber = @invnumb
GO
GRANT EXECUTE ON  [dbo].[ps_to_e_ProdQtys_by_invoice] TO [public]
GO
