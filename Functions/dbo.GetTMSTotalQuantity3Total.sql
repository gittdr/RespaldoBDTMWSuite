SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetTMSTotalQuantity3Total](@mov_number int)
RETURNS DECIMAL(10,4)
AS
BEGIN
   DECLARE @totalQuantity3 DECIMAL(10,4)
   
 SELECT @totalQuantity3 = SUM(totalQuantity3)
   FROM TMSOrder o
   join orderheader oh on o.ord_hdrnumber = oh.ord_hdrnumber
   join legheader_active lha on oh.mov_number = lha.mov_number
  where oh.mov_number = @mov_number
 
 RETURN @totalQuantity3
END
GO
GRANT EXECUTE ON  [dbo].[GetTMSTotalQuantity3Total] TO [public]
GO
GRANT REFERENCES ON  [dbo].[GetTMSTotalQuantity3Total] TO [public]
GO
