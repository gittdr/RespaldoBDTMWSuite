SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_MakeCityCmp_sp]
(
  @inserted UtStopsConsolidated READONLY
)
AS

DECLARE @StpNumber INTEGER

DECLARE StopCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT  i.stp_number
    FROM  @inserted i
   WHERE  i.ord_hdrnumber > 0
     AND  (LEFT(i.cmp_id, 1) = '_'
      OR   i.cmp_id = 'UNKNOWN');

OPEN StopCursor;
FETCH StopCursor INTO @StpNumber;

WHILE @@FETCH_STATUS = 0
BEGIN
  EXECUTE dbo.makecitycmpid @StpNumber;
  FETCH StopCursor INTO @StpNumber;
END

CLOSE StopCursor;
DEALLOCATE StopCursor;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_MakeCityCmp_sp] TO [public]
GO
