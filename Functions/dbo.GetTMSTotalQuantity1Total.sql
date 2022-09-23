SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetTMSTotalQuantity1Total](@mov_number int)
RETURNS DECIMAL(10,4)
AS
BEGIN
   DECLARE @totalQuantity1 DECIMAL(10,4)
   
 SELECT @totalQuantity1 = SUM(TotalQuantity1)
   FROM TMSOrder o
   join orderheader oh on o.ord_hdrnumber = oh.ord_hdrnumber
   join legheader_active lha on oh.mov_number = lha.mov_number
  where oh.mov_number = @mov_number
 
 RETURN @totalQuantity1
END
GO
GRANT EXECUTE ON  [dbo].[GetTMSTotalQuantity1Total] TO [public]
GO
GRANT REFERENCES ON  [dbo].[GetTMSTotalQuantity1Total] TO [public]
GO
