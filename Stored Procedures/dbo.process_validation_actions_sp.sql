SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[process_validation_actions_sp]
(@rulename  varchar(255),
@param1 varchar(255),  --ord_hdrnumber
@param2 varchar(255),  --inv_hdrnumber
@param3 varchar(255),  --batch number
@param4 varchar(255)   --for future use 
)

AS
/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be called by process_validation_sp at the end of the validation process provided validation errors were encountered. This stored procedure will perform actions in response to the validation errors - e.g. set an order's status to 'On Hold'. Note: whenever a new 
'FAILURE' row is added to the validation_section table, appropriate code must be added to this procedure to perform the required action.  

*/
    

    SET NOCOUNT ON
    
    DECLARE @max_mfh_sequence   int,
            @stp_number         int,
            @lgh_number         int
    
    BEGIN
    
        IF @rulename = 'INVOICE STATUS SET TO ON HOLD'
        BEGIN
            IF convert(int,@param1) > 0
            BEGIN
                /* Will update all invoices for the order that haven't been transfered or printed */
                /* TJD 07-Jan-03 I left this updating all on purpose because we don't want to update B
                                 and not A etc... */
                UPDATE invoiceheader
                SET ivh_invoicestatus = 'HLD', ivh_mbstatus = 'HLD'
                WHERE  convert(int,@param1) = ord_hdrnumber 
                AND ivh_invoicestatus NOT IN ('XFR', 'CAN', 'PRN')
                
                /* @sparam2 holds the error batch number */
                INSERT INTO tts_errorlog
                    (err_batch,
                     err_user_id,
                     err_message,
                     err_date,
                     err_item_number)
                SELECT convert(int, @param3),
                     user,
                     'INVOICE STATUS FOR ORDER ' 
                     + @param1 +
                     ' HAS BEEN SET TO ON HOLD BECAUSE OF THE INVALID DATA',
                     getdate(),
                     @param1
             END
             ELSE
             IF convert(int,@param2) > 0 
             BEGIN
                UPDATE invoiceheader
                SET ivh_invoicestatus = 'HLD', ivh_mbstatus = 'HLD'
                WHERE ivh_hdrnumber = convert(int, @param2)
                AND ivh_invoicestatus NOT IN ('XFR', 'CAN', 'PRN')
                
                INSERT INTO tts_errorlog
                    (err_batch,
                     err_user_id,
                     err_message,
                     err_date,
                     err_item_number)
                SELECT convert(int, @param3),
                     user,
                     'INVOICE STATUS FOR INVOICE ' 
                     + @param2 +
                     ' HAS BEEN SET TO ON HOLD BECAUSE OF THE INVALID DATA',
                     getdate(),
                     @param2
             END
        END
             
    END
GO
GRANT EXECUTE ON  [dbo].[process_validation_actions_sp] TO [public]
GO
