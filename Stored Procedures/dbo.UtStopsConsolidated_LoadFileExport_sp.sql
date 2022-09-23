SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_LoadFileExport_sp]
(
  @inserted UtStopsConsolidated READONLY,
  @deleted  UtStopsConsolidated READONLY
)
AS

SET NOCOUNT ON

DECLARE @lgh_number INTEGER,
        @char1      CHAR(1)

DECLARE StopCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT  DISTINCT i.lgh_number,
          CASE 
            WHEN ((i.stp_status <> d.stp_status AND i.stp_status = 'DNE') OR i.stp_arrivaldate <> d.stp_arrivaldate) AND
                 ((i.cmp_id = COALESCE(oh.ord_consignee, 'UNKNOWN') AND i.cmp_id <> 'UNKNOWN') OR i.stp_number = lgh.stp_number_end) THEN CASE WHEN i.stp_status = 'DNE' THEN 'Y' ELSE 'N' END
            WHEN COALESCE(i.stp_reasonlate, 'NULL') <> COALESCE(d.stp_reasonlate, 'NULL') THEN CASE WHEN lgh.lgh_outstatus = 'CMP' THEN 'Y' ELSE 'N' END
          END
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            INNER JOIN dbo.legheader lgh WITH(NOLOCK) ON lgh.lgh_number = i.lgh_number
            LEFT OUTER JOIN dbo.orderheader oh WITH(NOLOCK) ON oh.ord_hdrnumber = i.ord_hdrnumber
   WHERE  ((i.stp_status <> d.stp_status
     AND    i.stp_status = 'DNE')
      OR   i.stp_arrivaldate <> d.stp_arrivaldate)
     AND  ((i.cmp_id = COALESCE(oh.ord_consignee, 'UNKNOWN')
     AND   i.cmp_id <> 'UNKNOWN')
      OR   i.stp_number = lgh.stp_number_end)
      OR  COALESCE(i.stp_reasonlate, 'NULL') <> COALESCE(d.stp_reasonlate, 'NULL');

OPEN StopCursor;
FETCH NEXT FROM StopCursor INTO @lgh_number, @char1;

WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC dbo.create_segment_output @lgh_number, 'N', @char1;
      
  FETCH NEXT FROM StopCursor INTO @lgh_number, @char1;
END

CLOSE StopCursor;
DEALLOCATE StopCursor;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_LoadFileExport_sp] TO [public]
GO
