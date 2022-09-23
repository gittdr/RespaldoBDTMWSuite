SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_heniffprod_billoflading] (@ordnum int)
AS

Declare
@counter int, @product varchar(50), @order_number int, @netwgt_gal int

CREATE TABLE #hbol_prod (
PRODUCT varchar(50)null,
STOP_EVENT varchar(10) NULL,
NETWGT_GAL int NULL
)

INSERT INTO #hbol_prod
SELECT       
          
       CMD.CMD_NAME PRODUCT,      
       STP.STP_TYPE STOP_EVENT,
       FGT.FGT_VOLUME NETWGT_GAL            
       
FROM orderheader    ord,
     commodity      cmd, 
     freightdetail  fgt,    
     stops	    stp
               
      
WHERE ORD.ORD_HDRNUMBER  = @ordnum           AND
      ORD.ORD_HDRNUMBER  = STP.ORD_HDRNUMBER AND
      STP.STP_NUMBER     = FGT.STP_NUMBER    AND
      FGT.CMD_CODE       = CMD.CMD_CODE  
-- PTS 24803 -- BL (start)
ORDER BY STP.stp_sequence, STP.cmp_id, FGT.fgt_sequence
-- PTS 24803 -- BL (end)

--Get the final results set
Select product, netwgt_gal
from #hbol_prod
where stop_event = 'PUP'
GO
GRANT EXECUTE ON  [dbo].[d_heniffprod_billoflading] TO [public]
GO
