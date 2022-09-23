SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_get_validation_groups] (@record_id int ,@event_id  int)

AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be the datasource for the d_validation_groups datawindow (common.pbl). It returns information about all the validation groups that need to be tested for a given event. It is called from nvo_validation.get_validation_groups.

TGRIFFIT 38797 12/20/2007 - changes to account for possibility of ivh_mbstatus being NULL.

KDECELLE 38797 12/27/2007 - changes to invoice status processing.  TMW testing identified a situation where both invoice and mb status are RTP
*/
    SET NOCOUNT ON
    
    DECLARE @ord_id         int,
            @inv_id         int,
            @type           char(1),
            @ord_chk        int,
            @count_chk      int,
            @row_count      int            

    BEGIN
    
        SELECT @ord_chk = COUNT(1)
        FROM orderheader
        WHERE ord_hdrnumber = @record_id
        
        CREATE TABLE #record_info
        (order_id           int     NULL,
         invoice_id         int     NULL DEFAULT 0,
         record_type        char(1) NULL    DEFAULT 'O',
         record_co_grp_id   int     NULL    DEFAULT NULL)
         
        IF @ord_chk > 0
        BEGIN

            --either the invoice or mb status must be HLD or RTP
            --but neither status should be PRN or XFR
                
            INSERT INTO #record_info
            (order_id, invoice_id, record_type)
            SELECT ord_hdrnumber,
               ivh_hdrnumber,
               'I'
            FROM invoiceheader
            WHERE
            (ivh_invoicestatus in ('HLD','RTP') or
             ivh_mbstatus in ('HLD','RTP')) and
            (ivh_invoicestatus<>'PRN' and
             ivh_invoicestatus<>'XFR' and
             ivh_mbstatus<>'PRN' and
             ivh_mbstatus<>'XFR')                       
            AND ord_hdrnumber = @record_id
             
            SELECT @count_chk = COUNT(1)FROM #record_info
            
            IF @count_chk = 0
            BEGIN
                INSERT INTO #record_info
                (order_id)
                SELECT @record_id
            END
                
            SELECT @row_count = 1
                               
            WHILE @row_count > 0
            BEGIN
                
                SELECT @ord_id = 0
                SELECT @inv_id = 0
                SELECT @type = ''
                           
                SELECT TOP 1 
                    @ord_id = order_id,
                    @inv_id = invoice_id,
                    @type = record_type
                FROM #record_info
                WHERE record_co_grp_id IS NULL
                
                /*perform the pre-validation test, one row at a time
                 * this also updates the record_co_grp_id field */
                EXECUTE pre_validation_check_sp @ord_id, @inv_id, @type, 
                @event_id
                                    
                SELECT @row_count = COUNT(1) 
                FROM #record_info
                WHERE record_co_grp_id IS NULL
                               
            END
        END    
        
        SELECT valg_id AS GroupId,
               valg_name AS GroupName,
               valg_description AS Description,
               order_id AS OrderNum,
               invoice_id AS InvoiceNum,
               record_type AS RecordType,
               CASE WHEN labelfile.abbr IS NULL
               THEN 'UNKNOWN' ELSE labelfile.name END AS Severity
        FROM validation_company_group
            INNER JOIN #record_info
                ON record_co_grp_id = valcg_id
            INNER JOIN validation_mapping
                ON valcg_id = valm_valcg_id
                AND valm_vale_id = @event_id
                AND valm_effective_from <= GETDATE()
                AND valm_effective_to >= GETDATE()
            INNER JOIN validation_event
                ON valm_vale_id = vale_id
                AND vale_active_flag = 'Y'
            INNER JOIN validation_group
                ON valm_valg_id = valg_id
                AND valg_effective_from <= GETDATE()
                AND valg_effective_to >= GETDATE()
            LEFT OUTER JOIN labelfile
                ON valm_message_severity = abbr
                AND labeldefinition = 'ValidationMessage'
        WHERE record_co_grp_id IS NOT NULL
        AND record_co_grp_id > 0  
               
        DROP TABLE #record_info
      
    END
GO
GRANT EXECUTE ON  [dbo].[d_get_validation_groups] TO [public]
GO
