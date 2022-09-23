SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[candidates_forEDILoc] @billto varchar(8), @daysback smallint
AS

  DECLARE @cutoffdate datetime

  SELECT @cutoffdate = DATEADD(day, (0 - @daysback - 1), getdate())
  -- get orders within cut off period
  SELECT ord_hdrnumber
  INTO #temp1
  FROM   orderheader
  WHERE ord_billto = @billto and
	ord_bookdate > @cutoffdate

  -- determine all pup and drp companies on these orders
  SELECT DISTINCT stops.cmp_id
  INTO #temp2
  FROM stops, #temp1
  WHERE stops.ord_hdrnumber = #temp1.ord_hdrnumber 

  -- eliminate those for which there are already edi locations
  DELETE 
  FROM #temp2
  WHERE  cmp_id in (SELECT cmp_id
                    FROM cmpcmp
                    WHERE billto_cmp_id = @billto )

  -- bring the rest back
  SELECT c.cmp_id, c.cmp_name, c.cty_nmstct
  from #temp2 , company c
  WHERE c.cmp_id = #temp2.cmp_id

  Drop table #temp1
  Drop table #temp2
 
GO
GRANT EXECUTE ON  [dbo].[candidates_forEDILoc] TO [public]
GO
