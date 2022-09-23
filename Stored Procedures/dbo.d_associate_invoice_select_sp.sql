SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_associate_invoice_select_sp]
(
@mov_number int
)
 AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
Get invoice items for a move.

*/

    CREATE TABLE #a (
    ord_hdrnumber      int         NULL,
    ivh_invoicenumber  varchar(12) NULL,
    ivd_number         int         NULL,
    cht_itemcode       char(6)     NULL,
    ivd_description    varchar(30) NULL,      
    ivd_charge         money       NULL
    )

    -- Get all invoice for the move
    INSERT #a
    (   ord_hdrnumber      ,
        ivh_invoicenumber  ,
        ivd_number         ,
        cht_itemcode       ,     
        ivd_charge
    )
    SELECT DISTINCT
        ivh.ord_hdrnumber      ,
        MAX(ivh.ivh_invoicenumber),
        MAX(ivd_number),
        ivd.cht_itemcode,
        SUM(ISNULL(ivd.ivd_charge, 0))
    FROM dbo.invoicedetail ivd 
        INNER JOIN dbo.invoiceheader ivh ON ivd.ivh_hdrnumber = ivh.ivh_hdrnumber 
    WHERE ivh.mov_number =  @mov_number 
    GROUP BY ivh.ord_hdrnumber, ivd.cht_itemcode
    
    -- Keep items with positive charges only
    DELETE #a WHERE ivd_charge <= 0 
    
    -- Get invoice description
    UPDATE #a 
    SET ivd_description = ivd.ivd_description
    FROM invoicedetail ivd
    WHERE ivd.ivd_number = #a.ivd_number
    
    SELECT
        ord_hdrnumber      ,
        ivh_invoicenumber  ,
        ivd_number         ,
        cht_itemcode       ,
        ivd_description    ,     
        ivd_charge
    FROM #a
            
    DROP TABLE #a

GO
GRANT EXECUTE ON  [dbo].[d_associate_invoice_select_sp] TO [public]
GO
