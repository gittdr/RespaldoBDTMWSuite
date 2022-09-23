SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetTMSTotalQuantity2Total](@mov_number int)
RETURNS DECIMAL(10,4)
AS
BEGIN
   DECLARE @totalQuantity2 DECIMAL(10,4)
   
 SELECT @totalQuantity2 = SUM(totalQuantity2)
   FROM TMSOrder o
   join orderheader oh on o.ord_hdrnumber = oh.ord_hdrnumber
   join legheader_active lha on oh.mov_number = lha.mov_number
  where oh.mov_number = @mov_number
 
 RETURN @totalQuantity2
END
GO
GRANT EXECUTE ON  [dbo].[GetTMSTotalQuantity2Total] TO [public]
GO
GRANT REFERENCES ON  [dbo].[GetTMSTotalQuantity2Total] TO [public]
GO
