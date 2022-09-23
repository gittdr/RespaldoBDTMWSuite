SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_linked_orders_rev_ratio_sp] 
(@mov_number int)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.

*/
    DECLARE @rev_sum money

     CREATE TABLE #a
    (
        ord_hdrnumber int not null,
        ord_revenue  money not null,
        linked_ratio float not null
    
    )
       
    INSERT INTO #a
    SELECT d.ord_hdrnumber, SUM(d.ivd_charge), 0.0
    FROM invoiceheader h 
        INNER JOIN invoicedetail d ON h.ivh_hdrnumber = d.ivh_hdrnumber
    WHERE h.mov_number = @mov_number
    GROUP BY d.ord_hdrnumber
    
    SELECT @rev_sum = SUM(ord_revenue) FROM #a
    
    IF @rev_sum > 0
    BEGIN
        UPDATE #a SET linked_ratio = ord_revenue / @rev_sum
    END
    
    SELECT
        ord_hdrnumber ,
        ord_revenue  ,
        linked_ratio
    FROM #a

GO
GRANT EXECUTE ON  [dbo].[d_linked_orders_rev_ratio_sp] TO [public]
GO
