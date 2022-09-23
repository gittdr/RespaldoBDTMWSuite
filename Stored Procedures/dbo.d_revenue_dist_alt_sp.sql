SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_revenue_dist_alt_sp] 
( @mov_number int )
AS
SET NOCOUNT ON
/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.

*/

    DECLARE @tot_charges money, @err_message varchar(30)

    -- Create a temporary work table to calculate total revenue
    CREATE TABLE #revenuetotal
     (ivh_hdrnumber int null,
      det_charges money null,
      ivh_currency varchar(6) null,
      ivh_arcurrency varchar(6) null,
      ivh_currencydate datetime null,
      cex_rate money null,
      max_date datetime null,
      ar_charges money null)
    
    -- Load the temporary revenue work table with the invoices for the move
    INSERT #revenuetotal
     SELECT ivh_hdrnumber,
      0,
      ivh_currency,
      ivh_arcurrency,
      ivh_currencydate,
      1,
      null,
      0
     FROM invoiceheader
     WHERE mov_number = @mov_number
    
    -- Update the temporary revenue work table
    -- with total invoice charges minus tax based charges from invoice details
    UPDATE #revenuetotal
    SET det_charges = (SELECT SUM(ISNULL(ivd.ivd_charge, 0))
                         FROM invoicedetail ivd
                            INNER JOIN chargetype cht ON ivd.cht_itemcode = cht.cht_itemcode
                         WHERE ivd.ivh_hdrnumber = rt.ivh_hdrnumber
                         AND cht.cht_basis <> 'TAX')
     FROM invoicedetail ivd 
        INNER JOIN #revenuetotal rt ON ivd.ivh_hdrnumber = rt.ivh_hdrnumber
    
    -- Update the temporary revenue work table
    -- with the maximum related date from the currency exhange table
    UPDATE #revenuetotal
     SET max_date = (SELECT MAX(cex.cex_date)
                     FROM currency_exchange cex
                     WHERE cex.cex_date <= rt.ivh_currencydate
                     AND cex.cex_from_curr = rt.ivh_currency
                     AND cex.cex_to_curr = rt.ivh_arcurrency)
     FROM currency_exchange ce 
        INNER JOIN #revenuetotal rt
            ON ce.cex_from_curr = rt.ivh_currency
            AND ce.cex_to_curr = rt.ivh_arcurrency
            AND ce.cex_date <= rt.ivh_currencydate
         
    -- Update the temporary revenue work table
    -- with the exchange rate from the currency exhange table
    UPDATE #revenuetotal
     SET cex_rate = cex.cex_rate
     FROM currency_exchange cex
        INNER JOIN #revenuetotal rt 
            ON cex.cex_date = rt.max_date
            AND cex.cex_from_curr = rt.ivh_currency
            AND cex.cex_to_curr = rt.ivh_arcurrency
    
    -- Check for invalid currency conversion
    -- Calculate the charges in native currency (arcurrency)
    IF (SELECT COUNT (*) FROM #revenuetotal WHERE cex_rate IS NULL) > 0
        BEGIN
            SELECT @err_message = 'Currency conversion error'
        
            UPDATE #revenuetotal
            SET ar_charges = 0
        END
    ELSE
        UPDATE #revenuetotal
        SET ar_charges = ROUND(det_charges * cex_rate, 2)
    
    -- Calculate the total revenue in native currency
    SELECT @tot_charges = ROUND(SUM(ar_charges), 2)
    FROM #revenuetotal
    
    -- Create a temporary work file to use as the return set
    CREATE TABLE #revenue_dist
        (lgh_number int not null,
        earnings float null,
        lgh_tractor varchar(8) null,
        trc_type1 varchar(6) null,
        lgh_alloc_revenue float null,
        allocated_revenue float null,
        lgh_allocfactor float null,
        pyd_status varchar(6) null,
        prod_hr float null,
        tot_hr float null,
        ld_unld_time float null,
        ld_load_time float null,
        pay_status varchar(6) null)
    -- Load the work table with the legheaders
    
    INSERT INTO #revenue_dist
    SELECT DISTINCT lgh.lgh_number,
        null,
        lgh.lgh_tractor,
        lgh.trc_type1,
        lgh.lgh_alloc_revenue,
        null,
        lgh.lgh_allocfactor,
        asgn.pyd_status,
        lgh.lgh_prod_hr,
        lgh.lgh_tot_hr,
        lgh.lgh_ld_unld_time,
        lgh.lgh_load_time,
        'UNK'
    FROM legheader lgh
        LEFT OUTER JOIN assetassignment asgn ON lgh.lgh_number = asgn.lgh_number
            AND pyd_status = 'PPD'
    WHERE lgh.mov_number = @mov_number
                                -- due to outer join,
                                -- pyd_status will be null if no asgns yet
                                -- processed in settlements
                                -- this will be tested for in window to see if
                                -- all legheaders have been processed
    
    -- Update the work table with the branch id's
    -- TGRIFFIT Note: this now uses the unitallocation table and no longer the rev_unit_allocation_view
    UPDATE #revenue_dist
    SET trc_type1 = ua.branch_number
    FROM invoiceheader ivh
        INNER JOIN unitallocation ua
            ON ivh.ivh_shipdate >= ua.first_effective_date
            AND ivh.ivh_shipdate <= ua.last_effective_date
        INNER JOIN #revenue_dist rd
            ON ua.unit_number = rd.lgh_tractor  
    WHERE ivh.mov_number = @mov_number
       
    UPDATE #revenue_dist
    SET earnings = ROUND((SELECT SUM(pd.pyd_amount)
                               FROM paydetail pd
                               WHERE pd.lgh_number = rd.lgh_number
                               AND pd.pyd_pretax = 'Y'), 2),
        pay_status = (SELECT ISNULL(MIN(LTRIM(RTRIM(pyd.pyd_status +''))), 'UNK')
                        FROM paydetail pyd
                        WHERE rd.lgh_tractor = pyd.asgn_id
                        AND rd.lgh_number = pyd.lgh_number
                        AND pyd.asgn_type = 'TRC')
    FROM paydetail pd
        INNER JOIN #revenue_dist rd ON pd.lgh_number = rd.lgh_number
    
    -- If no earnings, set to 0
    UPDATE #revenue_dist
    SET earnings = ISNULL(earnings, 0)
    
    -- Select the return set
    SELECT @tot_charges,
        lgh_number,
        earnings,
        lgh_tractor,
        trc_type1,
        allocated_revenue,
        lgh_alloc_revenue,
        lgh_allocfactor,
        pyd_status,
        prod_hr,
        tot_hr,
        ld_unld_time,
        ld_load_time,
        pay_status,
        @err_message
    FROM #revenue_dist
    
    DROP TABLE #revenue_dist
    DROP TABLE #revenuetotal

GO
GRANT EXECUTE ON  [dbo].[d_revenue_dist_alt_sp] TO [public]
GO
