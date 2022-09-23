SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_OrderEventExport_sp]
(
  @inserted UtStopsConsolidated READONLY,
  @deleted  UtStopsConsolidated READONLY
)
AS

SET NOCOUNT ON

DECLARE @ord_hdrnumber      INTEGER,
        @p_vee_event_code   CHAR(1),
        @stp_departuredate  DATETIME,
        @p_vee_event_data2  VARCHAR(255)

DECLARE StopCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT  i.ord_hdrnumber,
        CASE i.stp_event
          WHEN 'LUL' THEN 'V'
          ELSE 'Y'
        END,
        i.stp_departuredate,
        CASE 
          WHEN oh.ord_billto <> 'WWLCAN' AND i.stp_event = 'LUL' THEN ''
          WHEN oh.ord_billto <> 'WWLCAN' AND i.stp_event = 'LLD' THEN CAST(oh.ord_totalcharge AS VARCHAR(255))
          ELSE CAST(i.mov_number AS VARCHAR(255))
        END
  FROM  @inserted i
          INNER JOIN @deleted d ON d.stp_number = i.stp_number
          INNER JOIN orderheader oh WITH(NOLOCK) ON oh.ord_hdrnumber = i.ord_hdrnumber
 WHERE  i.stp_status <> d.stp_status
   AND  i.stp_status = 'DNE'
   AND  i.ord_hdrnumber > 0
   AND  oh.ord_billto <> 'UNKNOWN'
   AND  oh.ord_billto <> 'UNK'
   AND  i.stp_event IN ('LLD', 'LUL');

 OPEN StopCursor;
 FETCH NEXT FROM StopCursor INTO @ord_hdrnumber, @p_vee_event_code, @stp_departuredate, @p_vee_event_data2;

 WHILE @@FETCH_STATUS = 0
 BEGIN
  EXECUTE dbo.insert_vin_event_export_sp @ord_hdrnumber, @p_vee_event_code, @stp_departuredate, @p_vee_event_data2, '';

  FETCH NEXT FROM StopCursor INTO @ord_hdrnumber, @p_vee_event_code, @stp_departuredate, @p_vee_event_data2;
 END

 CLOSE StopCursor;
 DEALLOCATE StopCursor;

GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_OrderEventExport_sp] TO [public]
GO
