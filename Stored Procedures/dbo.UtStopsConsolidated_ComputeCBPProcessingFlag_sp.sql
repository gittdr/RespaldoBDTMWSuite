SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_ComputeCBPProcessingFlag_sp]
(
  @inserted           UtStopsConsolidated READONLY,
  @deleted            UtStopsConsolidated READONLY,
  @CBPDefaultStrategy VARCHAR(100)
)
AS

SET NOCOUNT ON

DECLARE @ord_hdrnumber  INTEGER,
        @ord_cbp        INTEGER

DECLARE ORDERS_CURSOR CURSOR LOCAL FAST_FORWARD FOR
  SELECT  DISTINCT i.ord_hdrnumber  
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            INNER JOIN dbo.orderheader oh WITH(NOLOCK) ON oh.ord_hdrnumber = i.ord_hdrnumber
            INNER JOIN dbo.labelfile CurrentLabel WITH(NOLOCK) ON CurrentLabel.labeldefinition = 'dispstatus' AND CurrentLabel.abbr = oh.ord_status
            INNER JOIN dbo.labelfile AVLLabel WITH(NOLOCK) ON AVLLabel.labeldefinition = 'dispstatus' AND AVLLabel.abbr = 'AVL'
   WHERE  (i.cmp_id <> d.cmp_id 
      OR   i.stp_country <> d.stp_country)
     AND  CurrentLabel.code > AVLLabel.code;

OPEN ORDERS_CURSOR;
FETCH NEXT FROM ORDERS_CURSOR INTO @ord_hdrnumber;

WHILE @@FETCH_STATUS = 0
BEGIN
  EXECUTE dbo.cbp_is_order_cbp @ord_hdrnumber, @CBPDefaultStrategy, @ord_cbp OUT;

  UPDATE  dbo.orderheader
     SET  ord_cbp = CASE
                      WHEN @ord_cbp >= 0 THEN 'Y'
                      WHEN @ord_cbp = -1 THEN 'N'
                      ELSE 'E'
                    END
   WHERE  orderheader.ord_hdrnumber = @ord_hdrnumber
     AND  COALESCE(orderheader.ord_cbp , '') <> CASE
                                                  WHEN @ord_cbp >= 0 THEN 'Y'
                                                  WHEN @ord_cbp = -1 THEN 'N'
                                                  ELSE 'E'
                                                END;

    FETCH NEXT FROM ORDERS_CURSOR INTO @ord_hdrnumber;
END
  
CLOSE ORDERS_CURSOR;
DEALLOCATE ORDERS_CURSOR;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_ComputeCBPProcessingFlag_sp] TO [public]
GO
