SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtOrd_OrderEventExport_sp]
(
  @inserted UtOrd READONLY,
  @deleted  UtOrd READONLY
)
AS

SET NOCOUNT ON;

DECLARE @ord_hdrnumber  INTEGER,
        @mov_number     INTEGER,
        @newremark      VARCHAR(254),
        @oldremark      VARCHAR(254),
        @newcarrier     VARCHAR(8),
        @oldcarrier     VARCHAR(8);

DECLARE OrderCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT  i.ord_hdrnumber,
          COALESCE(i.ord_remark, ''),
          COALESCE(d.ord_remark, ''),
          COALESCE(i.ord_carrier, 'UNKNOWN'),
          COALESCE(d.ord_carrier, 'UNKNOWN'),
          i.mov_number
    FROM  @inserted i
          INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
 WHERE  COALESCE(i.ord_remark, '') <> COALESCE(d.ord_remark, '')
    OR  (COALESCE(i.ord_carrier, 'UNKNOWN') <> 'UNKNOWN'
   AND   COALESCE(i.ord_carrier, '') <> COALESCE(d.ord_carrier, ''));

OPEN OrderCursor;
FETCH OrderCursor INTO @ord_hdrnumber, @newremark, @oldremark, @newcarrier, @oldcarrier, @mov_number;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @newremark <> @oldremark
		EXECUTE dbo.insert_vin_event_export_sp @ord_hdrnumber, 'C', '', @newremark, '';

  IF @newcarrier <> @oldcarrier AND @newcarrier <> 'UNKNOWN'
		EXECUTE dbo.insert_vin_event_export_sp @ord_hdrnumber, 'L', '', @mov_number, @newcarrier;

  FETCH OrderCursor INTO @ord_hdrnumber, @newremark, @oldremark, @newcarrier, @oldcarrier, @mov_number;
END

CLOSE OrderCursor;
DEALLOCATE OrderCursor;

GO
GRANT EXECUTE ON  [dbo].[UtOrd_OrderEventExport_sp] TO [public]
GO
