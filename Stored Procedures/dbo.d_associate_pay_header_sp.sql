SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_associate_pay_header_sp] 
(@mov_number int)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.

*/

    SELECT
        e.entry_id             ,
        h.branch_pay_header_id ,
        e.mov_number           ,
        h.ord_hdrnumber        ,
        h.lgh_number           ,
        h.trc_number           ,
        h.trl_number           ,
        h.topup_truck_id       ,
        h.branch_id            ,
        h.involvement_type     ,
        h.order_revenue        ,
        h.segment_alloc_pct    ,
        h.segment_alloc_amt    ,
        h.credit_debit         ,
        e.processed_date       ,
        e.ape_status           ,
        e.transferred_date     ,
        h.notes                ,
        e.entry_type           ,
        e.accounting_year      ,
        e.accounting_period    ,
        e.accounting_week
    FROM associate_pay_header h 
        INNER JOIN associate_pay_entry e ON h.entry_id = e.entry_id
    WHERE e.mov_number = @mov_number

GO
GRANT EXECUTE ON  [dbo].[d_associate_pay_header_sp] TO [public]
GO
