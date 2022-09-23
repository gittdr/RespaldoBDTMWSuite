SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_associate_pay_detail_sp] 
(@mov_number int)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
Returns all associate topup branches

*/

    SELECT
        h.branch_pay_header_id,
        h.segment_alloc_amt,
        d.item,
        d.revenue_pct,
        d.from_to_branch_id,
        d.amount,
        d.notes,
        d.pyd_number,
        m.ape_status
    FROM associate_pay_header h 
        INNER JOIN associate_pay_detail d ON h.branch_pay_header_id = d.branch_pay_header_id
        INNER JOIN associate_pay_entry m ON h.entry_id = m.entry_id
        AND m.mov_number = @mov_number

GO
GRANT EXECUTE ON  [dbo].[d_associate_pay_detail_sp] TO [public]
GO
