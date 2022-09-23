SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[payheaderlghmiles] (@phnum INT, @totmiles INT OUT)
AS

SELECT DISTINCT lgh_number 
  INTO #temp
  FROM paydetail
 WHERE pyh_number = @phnum AND 
       lgh_number > 0

SELECT @totmiles = SUM(stp_lgh_mileage) 
  FROM stops, #temp
 WHERE #temp.lgh_number = stops.lgh_number

IF @totmiles IS NULL
   SELECT @totmiles = 0
IF @totmiles < 1
   SELECT @totmiles = 0

DROP TABLE #temp
GO
GRANT EXECUTE ON  [dbo].[payheaderlghmiles] TO [public]
GO
