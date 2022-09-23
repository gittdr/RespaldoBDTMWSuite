SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_associate_leginvstl_match_sp]
(
    @ord_number int,
    @lgh_number int,
    @brn_id varchar(8),
    @linked_ord_pct float
)

 AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
TGRIFFIT 42177 06/11/2008 added condition to where clause so that we only report 'INVOICE NOT FOUND' if linked
invoices are deleted (ivd_number > 0).See further comments below.

*/

    CREATE TABLE #a 
    (
        fee_schedule_itemcode   varchar(100) NULL,
        manual                  char(1)      NULL,
        ivh_invoicenumber       varchar(100) NULL,
        ivd_charge              money       NULL,
        associate_percent       money       NULL,
        pyd_amount              money       NULL,
        error_msg               varchar(50) NULL,
        allow_rev_alloc_edits   char(1)     NULL
    )

    CREATE TABLE #b
    (
        fee_schedule_itemcode varchar(6) null,
        ivd_charge  money null
    )

    DECLARE @non_inv_related_stl money
    
    -- Get all fee_schedule (invoice) items and their pays (if exist) for the given leg
    INSERT #a
    ( fee_schedule_itemcode,
     ivh_invoicenumber,
     ivd_charge,
     associate_percent,
     pyd_amount,
     error_msg
    )
    SELECT DISTINCT
         fsm.fee_schedule_itemcode,
         MAX(ivh.ivh_invoicenumber) ,
         0.0,
         0.0,
         SUM(ISNULL(pyd.pyd_amount, 0)),
         ''
    FROM dbo.invoiceheader ivh 
        INNER JOIN dbo.invoicedetail ivd ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
        LEFT OUTER JOIN dbo.paydetail pyd ON ivd.ivd_number = pyd.ivd_number
            AND pyd.lgh_number = @lgh_number
        INNER JOIN dbo.associate_fee_schedule_inv_map fsm ON ivd.cht_itemcode = fsm.cht_itemcode
        INNER JOIN dbo.chargetype cht ON ivd.cht_itemcode = cht.cht_itemcode
    WHERE ivh.ord_hdrnumber = @ord_number AND
          fsm.brn_id = @brn_id AND
          ivd.ivd_charge <> 0 
    GROUP BY fee_schedule_itemcode
    
    --( ivd.ivd_number *= pyd.ivd_number) and
    
     -- TGRIFFIT 11Jun08 - added pyd.ivd_number > 0 condition. During UAT testing BG3, it was noticed that
    -- the 'INVOICE NOT FOUND' edit was firing when we were not expecting it to (settled orders where 
    -- invoicedetail rows had not been deleted). Upon investigation we noticed that when paydetail rows are
    -- manually created (compute process) often these rows are created with an ivd_number = 0. 
    -- No row existed in the Test db's invoicedetail table with ivd_number = 0 and so the WHERE clause's sub
    -- select returned no rows. The NOT EXISTS condition was therefore true and row(s) were inserted into
    -- the temp table. This behavior has not been experienced in our PROD db.
    -- The reason is that for some reason a row exists in invoicedetail with an ivd_number = 0
    -- and so the autocreated paydetail rows with ivd_number = 0 find a match in the invoicedetail table; the
    -- sub select returns rows; the NOT EXISTS is false and no rows are inserted into the temp table.
    -- By adding the pyd.ivd_number > 0 condition, we will focus only on those rows in paydetail that have valid
    -- links to an invoicedetail row.
    
    -- Get all pay linked invoice detail items which have been deleted from invoice tables
    INSERT #a
    ( fee_schedule_itemcode,
     ivh_invoicenumber,
     ivd_charge,
     associate_percent,
     pyd_amount,
     error_msg
    )
    SELECT pyd_description,
         'ivd_number: ' + CONVERT(varchar, ivd_number),
         0.0,
         0.0,
         ISNULL(pyd.pyd_amount, 0),
         'INVOICE NOT FOUND'
    FROM dbo.paydetail pyd
    WHERE pyd.lgh_number = @lgh_number
    AND NOT EXISTS (SELECT 1 from invoicedetail ivd 
                    WHERE ivd.ivd_number = pyd.ivd_number)
    AND pyd.ivd_number > 0     
    
    -- END TGRIFFIT 11Jun08 
                    
    
    -- Get all invoice items which are not mapped to fee schedule items
    INSERT #a
    ( fee_schedule_itemcode,
     ivh_invoicenumber,
     ivd_charge,
     associate_percent,
     pyd_amount,
     error_msg
    )
    SELECT cht_description,
         ivh.ivh_invoicenumber,
         0.0,
         0.0,
         ISNULL(pyd.pyd_amount, 0),
         'NO_SCHEDULE_MAP'
    FROM dbo.invoiceheader ivh
            INNER JOIN dbo.invoicedetail ivd ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
            LEFT OUTER JOIN dbo.paydetail pyd ON ivd.ivd_number = pyd.ivd_number
                AND pyd.lgh_number  = @lgh_number
            INNER JOIN dbo.chargetype cht ON ivd.cht_itemcode = cht.cht_itemcode
    WHERE ivh.ord_hdrnumber = @ord_number AND
          ivd.ivd_charge <> 0 AND
          NOT EXISTS (SELECT 1 FROM dbo.associate_fee_schedule_inv_map
                      WHERE brn_id = @brn_id AND cht_itemcode = ivd.cht_itemcode)
    
    INSERT #b (fee_schedule_itemcode, ivd_charge)
    SELECT    ISNULL(fee_schedule_itemcode, 'UNK'),
              SUM(ivd.ivd_charge)
    FROM invoicedetail ivd
            LEFT OUTER JOIN associate_fee_schedule_inv_map fsm ON ivd.cht_itemcode = fsm.cht_itemcode
                AND fsm.brn_id = @brn_id
            INNER JOIN chargetype cht ON ivd.cht_itemcode=cht.cht_itemcode
    WHERE ivd.ord_hdrnumber = @ord_number 
    GROUP BY fee_schedule_itemcode
    
    UPDATE #a
    SET ivd_charge = #b.ivd_charge
    FROM #b
    WHERE #a.fee_schedule_itemcode = #b.fee_schedule_itemcode
    
    DROP TABLE #b
        
    -- Get associate pct
    UPDATE #a
    SET associate_percent = f.associate_percent
    FROM associate_fee_schedule f
    WHERE #a.fee_schedule_itemcode = f.fee_schedule_itemcode
    AND f.brn_id = @brn_id
    
    -- Get given leg's total pay amount which are not linked to any invoice item
    SELECT @non_inv_related_stl = SUM(pyd_amount)
    FROM paydetail 
    WHERE lgh_number = @lgh_number 
    AND ivd_number = 0
    
    IF ABS(@non_inv_related_stl) > 0
    BEGIN
        UPDATE #a 
        SET pyd_amount = pyd_amount + @non_inv_related_stl * @linked_ord_pct
        WHERE fee_schedule_itemcode = 'LHR'
        
        if @@rowcount < 1
            UPDATE #a 
            SET error_msg = 'LHR item not found.' 
            WHERE ISNULL(error_msg,'')=''
    
    END
    
    
    UPDATE #a
    SET manual = afs.manual,
       allow_rev_alloc_edits = afs.allow_rev_allocation_edits
    FROM dbo.associate_fee_schedule afs
    WHERE afs.fee_schedule_itemcode = #a.fee_schedule_itemcode
    AND afs.brn_id = @brn_id
    
    DELETE #a 
    WHERE ivd_charge = 0 
    AND ISNULL(error_msg,'')=''
    
    SELECT
        fee_schedule_itemcode   ,
        manual,
        ivh_invoicenumber       ,
        ivd_charge              ,
        associate_percent       ,
        pyd_amount              ,
        allow_rev_alloc_edits   ,
        error_msg
    FROM #a
            
    DROP TABLE #a

GO
GRANT EXECUTE ON  [dbo].[d_associate_leginvstl_match_sp] TO [public]
GO
