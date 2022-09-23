SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[process_validation_values_sp]
(@rulename  varchar(255),
@param1 varchar(255), --ord_number
@param2 varchar(255), --inv_number
@param3 varchar(255), --batch number, not currently used
@param4 varchar(255)  --for future use
)
AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be called by process_validation_sp. It will populate the #value temp table (created by process_validation_sp) with a list of values that require validation
(e.g. a list of Ref #'s for an order). This list will then be validated within the calling stored procedure.

*/
    SET NOCOUNT ON
       
    DECLARE @values_count int
    
    SET @values_count = 0
    
    BEGIN
        
        IF @rulename = 'REFERENCE ON ALL INVOICE DETAIL LINES'
        BEGIN
            /* Get reference number from all invoice lines that aren't tax
            and aren't subtotal lines */
            INSERT INTO #value
            SELECT ivd_refnum
                FROM invoicedetail d
                    INNER JOIN invoiceheader h ON d.ivh_hdrnumber = h.ivh_hdrnumber
                    INNER JOIN chargetype c ON d.cht_itemcode = c.cht_itemcode
                WHERE h.ivh_hdrnumber = CONVERT(int, @param2)
                AND c.cht_basis <> 'TAX'
                AND d.ivd_type <> 'SUB'
                AND ivh_invoicestatus <> 'XFR'
        END
        
        IF @rulename = 'REFERENCE ON ALL FREIGHT DELIVERY LOCATIONS'
        BEGIN
            INSERT INTO #value
            SELECT f.fgt_refnum
                FROM freightdetail f
                     INNER JOIN stops s ON f.stp_number = s.stp_number
                WHERE s.ord_hdrnumber = CONVERT(int,@param1)
                AND s.stp_status = 'DNE'
                AND s.stp_type = 'DRP'  
        END
        
        IF @rulename = 'TARIFF ITEM ON INVOICE'
        BEGIN
            INSERT INTO #value
            SELECT t.tar_tariffitem
                FROM tariffheader t 
                    INNER JOIN invoiceheader i ON t.tar_number = i.tar_number
                WHERE CONVERT(int, @param2) = i.ivh_hdrnumber
                AND ivh_invoicestatus <> 'XFR'
        
            /* If we don't have any, insert a blank because we might not due to join */
            If (SELECT count(*) FROM #value) = 0
              BEGIN
                INSERT into #value
                SELECT ''
              END
        END

        IF @rulename = 'INVOICE PAYMENT TERMS'
        BEGIN
          INSERT INTO #value
          SELECT ivh_terms
            FROM invoiceheader h
            WHERE CONVERT(int, @param2) = h.ivh_hdrnumber
            AND ivh_invoicestatus <> 'XFR'
        END

        IF @rulename = 'TOTAL ACTUAL QUANTITY ON INVOICE'
        BEGIN
          INSERT INTO #value
          SELECT CONVERT(varchar, SUM(DISTINCT CONVERT(int, x.ivd_actual_quantity)))
            FROM invoicedetail x 
                INNER JOIN invoiceheader t ON x.ivh_hdrnumber = t.ivh_hdrnumber
            WHERE x.ivh_hdrnumber = CONVERT(int, @param2)
            AND ISNULL(LTRIM(RTRIM(x.cmd_code)), 'UNKNOWN') <> 'UNKNOWN'
            AND  ivh_invoicestatus <> 'XFR'
            GROUP BY t.ivh_hdrnumber    
        END 

        IF @rulename = 'REFERENCE ON ALL INVOICE DETAIL LINES AND ALL FREIGHT DELIVERY LOCATIONS'
        BEGIN
            /* Get reference number from all invoice lines that aren't tax 
           and aren't subtotal lines*/
            INSERT INTO #value
            SELECT ivd_refnum
                FROM invoicedetail d
                    INNER JOIN invoiceheader h ON d.ivh_hdrnumber = h.ivh_hdrnumber 
                    INNER JOIN chargetype c ON d.cht_itemcode = c.cht_itemcode
                WHERE h.ivh_hdrnumber = CONVERT(int, @param2)
                AND c.cht_basis <> 'TAX'
                AND d.ivd_type <> 'SUB'
                AND ivh_invoicestatus <> 'XFR'
        
            INSERT INTO #value
            SELECT f.fgt_refnum
                FROM freightdetail f
                    INNER JOIN stops s ON f.stp_number = s.stp_number
                WHERE s.ord_hdrnumber = CONVERT(int,@param1)
                AND s.stp_status = 'DNE'
                AND s.stp_type = 'DRP' 
        END

        IF @rulename = 'ORDER ENTRY REFERENCE NUMBERS (HEADER AND ALL FREIGHT DELIVERY LOCATIONS)'
        BEGIN
                    
            INSERT INTO #value
            SELECT ord_refnum
                FROM orderheader
                WHERE ord_hdrnumber = CONVERT(int, @param1)
        
            INSERT INTO #value
            SELECT f.fgt_refnum
                FROM freightdetail f
                    INNER JOIN stops s ON f.stp_number = s.stp_number
                WHERE s.ord_hdrnumber = CONVERT(int,@param1)
                AND s.stp_type = 'DRP' 
        END

        SELECT @values_count = count(1)
        FROM #value
        
        RETURN @values_count
            
    END

GO
GRANT EXECUTE ON  [dbo].[process_validation_values_sp] TO [public]
GO
