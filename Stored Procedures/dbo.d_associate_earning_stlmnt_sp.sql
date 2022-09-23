SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_associate_earning_stlmnt_sp] 
(@mov_number int, @involved_type varchar(8))
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
Returns all associate topup branches

*/
    SELECT
        e.branch_pay_header_id ,
        e.cht_itemcode         ,
        e.ivh_invoicenumber    ,
        e.inv_charge           ,
        e.split_pct            ,
        e.item_alloc_amt       ,
        e.associate_pct        ,
        e.associate_amt        ,
        e.ic_stlmnt_amt        ,
        e.ic_stlmnt_pct        ,
        e.associate_stlmnt_amt ,
        e.associate_stlmnt_pct ,
        a.ape_status,
        e.manual,
        e.ic_amt_modified,
        CONVERT(char(1), 'N') ic_allow_correction,
        e.allow_rev_allocation_edits,
        CONVERT(char(1), 'N') edit_alloc_rev
    FROM associate_pay_header h
        INNER JOIN associate_earning_detail e ON e.branch_pay_header_id = h.branch_pay_header_id
        INNER JOIN associate_pay_entry a ON h.entry_id = a.entry_id
    WHERE h.involvement_type = @involved_type
    AND a.mov_number = @mov_number
GO
GRANT EXECUTE ON  [dbo].[d_associate_earning_stlmnt_sp] TO [public]
GO
