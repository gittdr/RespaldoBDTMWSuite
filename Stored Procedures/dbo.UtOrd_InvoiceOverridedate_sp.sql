SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtOrd_InvoiceOverridedate_sp]
(
  @inserted UtOrd READONLY,
  @deleted  UtOrd READONLY
)
AS   

SET NOCOUNT ON;

WITH CTE AS
(
  SELECT  i.ord_hdrnumber,
          COALESCE(c.cmp_schdearliestdateoverride, '') cmp_overridecode,
          FIRST_VALUE(s.stp_number) OVER (PARTITION BY s.ord_hdrnumber ORDER BY s.stp_sequence ASC) FirstStopNumber,
          FIRST_VALUE(s.stp_number) OVER (PARTITION BY s.ord_hdrnumber ORDER BY s.stp_sequence DESC) LastStopNumber,
          FIRST_VALUE(s.stp_number) OVER (PARTITION BY s.ord_hdrnumber ORDER BY CASE s.stp_type WHEN 'DRP' THEN 0 ELSE 99 END ASC, s.stp_sequence DESC) LastDropStopNumber,
          FIRST_VALUE(s.stp_number) OVER (PARTITION BY s.ord_hdrnumber ORDER BY CASE s.stp_type WHEN 'PUP' THEN 0 ELSE 99 END ASC, s.stp_sequence ASC) FirstPickupStopNumber
    FROM  @inserted i
            INNER JOIN @deleted d ON d.ord_hdrnumber = d.ord_hdrnumber
            INNER JOIN stops s ON s.ord_hdrnumber = i.ord_hdrnumber
            INNER JOIN company c ON c.cmp_id = i.ord_billto
   WHERE  i.ord_invoicestatus = 'AVL'
     AND  d.ord_invoicestatus <> 'AVL'
)
UPDATE  OH
   SET  OH.ord_invoice_effectivedate = CASE 
                                         WHEN CTE.cmp_overridecode = 'A' AND COALESCE(CTE.LastDropStopNumber, 0) <> 0 THEN LastDropStop.stp_departuredate
                                         WHEN CTE.cmp_overridecode = 'B' THEN OH.ord_bookdate
                                         WHEN CTE.cmp_overridecode = 'D' AND COALESCE(CTE.LastDropStopNumber, 0) <> 0 THEN LastDropStop.stp_arrivaldate
                                         WHEN CTE.cmp_overridecode = 'F' AND COALESCE(CTE.FirstPickupStopNumber, 0) <> 0 THEN FirstPickupStop.stp_arrivaldate
                                         WHEN CTE.cmp_overridecode = 'I' AND COALESCE(CTE.FirstPickupStopNumber, 0) <> 0 THEN FirstPickupStop.stp_departuredate
                                         WHEN CTE.cmp_overridecode = 'M' THEN LastStop.stp_departuredate
                                         WHEN CTE.cmp_overridecode = 'P' THEN FirstPickupStop.stp_schdtearliest
                                         WHEN CTE.cmp_overridecode = 'V' THEN OH.ord_availabledate
                                         WHEN CTE.cmp_overridecode = 'Y' THEN FirstStop.stp_schdtearliest
                                         ELSE OH.ord_invoice_effectivedate
                                       END
  FROM  orderheader OH
          INNER JOIN CTE ON CTE.ord_hdrnumber = OH.ord_hdrnumber
          INNER JOIN stops FirstStop ON FirstStop.stp_number = CTE.FirstStopNumber
          INNER JOIN stops LastStop ON LastStop.stp_number = CTE.LastStopNumber
          LEFT OUTER JOIN stops LastDropStop ON LastDropStop.stp_number = CTE.LastDropStopNumber
          LEFT OUTER JOIN stops FirstPickupStop ON FirstPickupStop.stp_number = CTE.FirstPickupStopNumber
GO
GRANT EXECUTE ON  [dbo].[UtOrd_InvoiceOverridedate_sp] TO [public]
GO
